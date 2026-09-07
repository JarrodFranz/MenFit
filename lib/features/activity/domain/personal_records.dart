/// Pure aggregation of personal records (PRs) across every logged
/// `Activity`: fastest time per standard effort distance, longest single
/// activity, and most elevation gained in a single activity.
///
/// v1 tracks PRs across every activity type together (a run and a hike both
/// contribute to "longest distance", for instance) - per-`ActivityType` PRs
/// are deferred (see `knowledge/product/deferred.md`) until there's a
/// concrete UI need to split them out.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';

part 'personal_records.freezed.dart';

/// One personal-record holder: which activity set it, when, and the record
/// [value] itself (a [Duration] for a best-effort PR, or a `double` -
/// metres - for the longest-distance/most-elevation PRs).
@freezed
abstract class PrEntry<T> with _$PrEntry<T> {
  const factory PrEntry({
    required String activityId,
    required String activityTitle,

    /// UTC.
    required DateTime startedAt,
    required T value,
  }) = _PrEntry<T>;
}

/// The full set of personal records computed by [computePersonalRecords].
@freezed
abstract class PersonalRecords with _$PersonalRecords {
  const factory PersonalRecords({
    /// Fastest [PrEntry] per `standardEffortDistances` target (metres) that
    /// at least one activity's samples cover. Distances no activity has
    /// reached yet are simply absent from the map.
    required Map<double, PrEntry<Duration>> bestEfforts,
    PrEntry<double>? longestDistance,
    PrEntry<double>? mostElevationGain,
  }) = _PersonalRecords;
}

/// Computes [PersonalRecords] across [allActivities].
///
/// Longest-distance and most-elevation-gain PRs are read straight off each
/// [Activity] and so apply to every activity regardless of source - a
/// manually-logged run with no GPS samples still competes for those two.
/// Best-effort PRs require a track to scan (`track_analysis.dart`), so an
/// activity only competes for those when [samplesByActivityId] has a
/// non-empty entry for its id; callers only need to populate that map for
/// `recorded` activities (manual ones have no samples to fetch).
///
/// **Tie-break rule (F3)**: on an exact tie for any of the three PRs (same
/// best-effort duration, same distance, same elevation gain), the activity
/// with the **earliest** `startedAt` keeps the record - the original
/// record-setter is never displaced by a later activity that merely equals
/// it. This holds regardless of [allActivities]' iteration order (see
/// [_beatsRecord]).
///
/// Performance note: this rescans every activity's full sample list on
/// every call - acceptable at local-data scale (thousands of activities,
/// each scanned in O(samples)), but it means a full recompute redoes the
/// full scan on every activity change rather than incrementally updating.
/// [samplesByActivityId] holding every recorded activity's samples at once
/// is this function's own memory cost, which is why the composition-surface
/// provider (`activity_providers.dart#personalRecordsProvider`) doesn't
/// call this batch form at all - it folds one activity at a time via
/// [foldActivityIntoRecords] instead, so only one activity's samples are
/// ever resident at a time (F7). Per-activity effort *caching* (avoiding
/// the rescan itself, not just the memory) is still deferred until
/// profiling shows it's needed (see `knowledge/product/deferred.md`).
PersonalRecords computePersonalRecords({
  required List<Activity> allActivities,
  required Map<String, List<ActivitySample>> samplesByActivityId,
}) {
  var result = const PersonalRecords(bestEfforts: {});
  for (final activity in allActivities) {
    result = foldActivityIntoRecords(
      current: result,
      activity: activity,
      samples: samplesByActivityId[activity.id] ?? const [],
    );
  }
  return result;
}

/// Folds a single [activity] (and its [samples], empty for a manual
/// activity or one not yet fetched) into [current], returning the updated
/// [PersonalRecords] - the same per-activity step [computePersonalRecords]
/// runs in a loop, but exposed on its own (F7) so a caller can fetch and
/// fold one activity at a time (discarding its samples immediately
/// afterwards) instead of holding every recorded activity's full sample
/// list in memory at once just to make one batch call. See
/// `activity_providers.dart#personalRecordsProvider`, which does exactly
/// that.
///
/// Longest-distance and most-elevation-gain PRs are read straight off
/// [activity] and so apply regardless of source - a manually-logged run
/// with no GPS samples still competes for those two. Best-effort PRs
/// require [samples] to be non-empty.
PersonalRecords foldActivityIntoRecords({
  required PersonalRecords current,
  required Activity activity,
  required List<ActivitySample> samples,
}) {
  var longestDistance = current.longestDistance;
  var mostElevationGain = current.mostElevationGain;
  var bestEfforts = current.bestEfforts;

  if (activity.distanceMeters > 0 &&
      _beatsRecord(
        current: longestDistance,
        candidateValue: activity.distanceMeters,
        candidateStartedAt: activity.startedAt,
        isStrictlyBetter: (candidate, current) => candidate > current,
      )) {
    longestDistance = _entryFor(activity, activity.distanceMeters);
  }

  final elevation = activity.elevationGainMeters;
  if (elevation != null &&
      _beatsRecord(
        current: mostElevationGain,
        candidateValue: elevation,
        candidateStartedAt: activity.startedAt,
        isStrictlyBetter: (candidate, current) => candidate > current,
      )) {
    mostElevationGain = _entryFor(activity, elevation);
  }

  if (samples.isNotEmpty) {
    for (final targetMeters in standardEffortDistances) {
      final effort = bestEffortFor(samples, targetMeters);
      if (effort == null) continue;

      if (_beatsRecord(
        current: bestEfforts[targetMeters],
        candidateValue: effort.duration,
        candidateStartedAt: activity.startedAt,
        isStrictlyBetter: (candidate, current) => candidate < current,
      )) {
        // Copy-on-write: `current.bestEfforts` (and every intermediate
        // fold's map) must never be mutated in place - callers may hold a
        // reference to an earlier [PersonalRecords] (e.g. to diff against)
        // and immutability is the whole point of returning a new value.
        bestEfforts = {
          ...bestEfforts,
          targetMeters: _entryFor(activity, effort.duration),
        };
      }
    }
  }

  return PersonalRecords(
    bestEfforts: bestEfforts,
    longestDistance: longestDistance,
    mostElevationGain: mostElevationGain,
  );
}

PrEntry<T> _entryFor<T>(Activity activity, T value) => PrEntry(
  activityId: activity.id,
  activityTitle: activity.title,
  startedAt: activity.startedAt,
  value: value,
);

/// Whether a candidate scoring [candidateValue] (set at
/// [candidateStartedAt]) should replace [current] as a PR holder.
///
/// [isStrictlyBetter] defines "record-worthy" for the value type at hand
/// (`>` for a distance/elevation PR, `<` for a best-effort [Duration] - a
/// smaller duration is the win there). On an exact tie (neither value is
/// strictly better than the other), the **earlier** [candidateStartedAt]
/// keeps the record - i.e. the original record-setter is never displaced
/// by a later activity that merely equals it. This is implemented as an
/// explicit tie-break rather than left as an accident of iteration order:
/// [computePersonalRecords] previously used a bare strict `>`/`<`
/// comparison, which happened to keep whichever tied activity was iterated
/// *first* - correct only when its activity list also happened to be
/// ordered oldest-first, and silently wrong (crediting a later duplicate
/// performance) for any other input order.
bool _beatsRecord<T>({
  required PrEntry<T>? current,
  required T candidateValue,
  required DateTime candidateStartedAt,
  required bool Function(T candidate, T current) isStrictlyBetter,
}) {
  if (current == null) return true;
  if (isStrictlyBetter(candidateValue, current.value)) return true;
  if (!isStrictlyBetter(current.value, candidateValue) &&
      candidateStartedAt.isBefore(current.startedAt)) {
    // Neither is strictly better than the other, i.e. an exact tie.
    return true;
  }
  return false;
}
