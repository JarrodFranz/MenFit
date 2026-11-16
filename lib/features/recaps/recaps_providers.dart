import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/recaps/data/recap_marker_store.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_builder.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recaps_providers.g.dart';

/// Composition surface for the `recaps` feature (ADR 007).
///
/// The only legal way for another feature (`home`'s trigger widget,
/// `progress`'s recap history section) to reach this feature's logic and
/// storage — other features may import this file, never `data/` or
/// `presentation/` directly.
@Riverpod(keepAlive: true)
RecapMarkerStore recapMarkerStore(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecapMarkerStore(prefs);
}

/// Preference controller for whether automatic monthly recap stories are
/// presented on startup. Defaults to true.
@Riverpod(keepAlive: true)
class ShowAutomaticRecapsController extends _$ShowAutomaticRecapsController {
  static const String prefKey = 'show_automatic_recaps';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(prefKey) ?? true;
  }

  Future<void> toggle({required bool enabled}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = enabled;
    await prefs.setBool(prefKey, enabled);
  }
}

/// Builds the [MonthRecap] for an arbitrary [period], gathering every
/// source through the owning feature's composition surface (ADR 007) —
/// never a `data/` import. Returns `null` when [RecapBuilder]'s
/// sparse-data guard applies.
///
/// One-shot (`Future`, not `Stream`): a recap describes a period that has
/// already finished, so nothing about it changes once its inputs have been
/// read - unlike the rest of this codebase's mostly-live providers, a
/// live-updating recap would only mean pointlessly re-running this fairly
/// expensive aggregation on every unrelated activity/water/nutrition log
/// while the story screen is open.
///
/// ## Cost, and why it is safe on the launch path
///
/// This runs from Home's `RecapTriggerListener` whenever a recap is due,
/// so its cost lands on an app launch. It is honestly not cheap: the
/// prior-records fold walks *every activity ever logged* before the
/// period, scanning each recorded activity's GPS track five times (once
/// per `standardEffortDistances` target) inside
/// `foldActivityIntoRecords`. A year of runs is on the order of a million
/// sample comparisons.
///
/// What makes that acceptable rather than a freeze:
/// - **Nothing forces it before first paint.** Every consumer is async and
///   renders a non-blocking placeholder first —
///   `recapTriggerControllerProvider` `await`s this and its listener acts
///   only on a later `AsyncData`, and the history section renders from
///   `AsyncValue.when`. Home paints while this is still pending.
/// - **The queries are off the UI isolate.** Drift on native runs its
///   executor in a background isolate (`core/db/app_database.dart`), and
///   the sample reads are now batched
///   (`ActivityRepository.getSamplesForActivities`) rather than one
///   awaited round trip per historical activity, which is what used to
///   dominate the wall clock here.
/// - **Peak memory stays bounded.** The prior fold is walked in chunks of
///   [_priorFoldChunkSize] activities, so a whole history's tracks are
///   never all resident at once.
///
/// The *arithmetic* still runs on the UI isolate and is the remaining
/// cost. It is deliberately not pushed through `compute()`: the payload
/// would be the sample lists themselves, and copying hundreds of
/// thousands of `ActivitySample`s across an isolate boundary plausibly
/// costs more than the scan it would offload. The cheaper win, if this
/// ever measures as a problem, is upstream — `bestEffortFor` rebuilds the
/// same cleaned/cumulative-distance track once per target distance, so a
/// multi-target variant in `activity/domain/track_analysis.dart` would cut
/// the geometry work ~5x with no isolate involved. Tracked in
/// `knowledge/product/deferred.md`.
///
/// `retry: _noRetry` — see [_noRetry] for why this one must fail fast.
@Riverpod(retry: _noRetry)
Future<MonthRecap?> recapForPeriod(Ref ref, RecapPeriod period) async {
  final activityRepo = ref.watch(activityRepositoryProvider);
  final waterRepo = ref.watch(waterRepositoryProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  final goalsRepo = ref.watch(nutritionGoalsRepositoryProvider);
  final wellbeingRepo = ref.watch(wellbeingRepositoryProvider);

  // One-shot snapshots through the repositories' `get...` methods, never
  // `watchXxx().first`: `Stream.first` only completes once it has
  // cancelled its subscription, and cancelling a Drift query stream
  // resolves through a root-zone future that escapes `flutter_test`'s
  // `FakeAsync` — under a widget test the await never completes while the
  // test pumps, and the stranded half-run query then deadlocks
  // `AppDatabase.close()` in `tearDown`. See
  // `features/activity/domain/activity_repository.dart#getActivities`.
  final allActivities = await activityRepo.getActivities();

  final periodActivities = allActivities
      .where((a) => _fallsWithin(a, period))
      .toList();
  final priorActivities =
      allActivities
          .where(
            (a) => LocalDate.fromDateTime(
              a.startedAt.toLocal(),
            ).isBefore(period.start),
          )
          .toList()
        ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

  // Best-ever cardio records as of just before the period started, so
  // `RecapBuilder` can tell a genuine PR apart from a merely-good session.
  //
  // Walked a chunk at a time rather than either extreme: one bulk fetch of
  // every historical track would hold a whole year of GPS samples resident
  // at once (`personal_records.dart#computePersonalRecords`'s memory note
  // is about exactly that), while the original await-per-activity put one
  // serialised query per activity on the app-launch path. Fold order is
  // irrelevant to the result — `foldActivityIntoRecords` tie-breaks on
  // `startedAt`, not on iteration order.
  var priorRecords = const PersonalRecords(bestEfforts: {});
  final priorMaxWeights = <String, double>{};
  for (
    var offset = 0;
    offset < priorActivities.length;
    offset += _priorFoldChunkSize
  ) {
    final end = offset + _priorFoldChunkSize;
    final chunk = priorActivities.sublist(
      offset,
      end < priorActivities.length ? end : priorActivities.length,
    );
    // Only `recorded` activities have a track to fetch; a manual one still
    // competes for the distance/elevation PRs, just with no samples.
    final chunkSamples = await activityRepo.getSamplesForActivities([
      for (final a in chunk)
        if (a.source == ActivitySource.recorded) a.id,
    ]);

    for (final activity in chunk) {
      priorRecords = foldActivityIntoRecords(
        current: priorRecords,
        activity: activity,
        samples: chunkSamples[activity.id] ?? const <ActivitySample>[],
      );

      final details = activity.workoutDetails;
      if (details is StrengthWorkoutDetails) {
        for (final exercise in details.exercises) {
          final sessionMax = exercise.sets
              .where((s) => s.isCompleted)
              .fold<double>(0, (max, s) => s.weightKg > max ? s.weightKg : max);
          if (sessionMax <= 0) continue;
          final key = exercise.name.trim().toLowerCase();
          if (sessionMax > (priorMaxWeights[key] ?? 0)) {
            priorMaxWeights[key] = sessionMax;
          }
        }
      }
    }
  }

  // The period's own tracks, which `RecapBuilder` needs in full and all at
  // once — a single period is a month, so this is bounded by what he can
  // log in ~31 days, not by his whole history.
  final samplesByActivityId = await activityRepo.getSamplesForActivities([
    for (final activity in periodActivities)
      if (activity.source == ActivitySource.recorded) activity.id,
  ]);

  final waterTotalsByDay = await waterRepo.getWaterTotalsForRange(
    period.start,
    period.end,
  );
  final nutritionEntries = await nutritionRepo.getEntriesForRange(
    period.start,
    period.end,
  );
  final nutritionGoals = await goalsRepo.getGoals();
  // `ref.read`, not `.watch`: this whole function is a one-shot snapshot of
  // a *finished* period (see the class dartdoc above), so the protein
  // target's calorie basis is fixed at whatever it is right now rather
  // than tracking a live provider that could move after this recap has
  // already been built. Same basis `dayCalorieTargetProvider` resolves for
  // every other nutrition surface — never `nutritionGoals.calorieTargetKcal`
  // directly (`nutrition_providers.dart#fuelingConsistency`).
  final basisKcal = ref.read(dayCalorieTargetProvider).targetKcal;
  final checkins = await wellbeingRepo.getRecentCheckins(
    period.totalDays,
    period.end,
  );

  return const RecapBuilder().build(
    period: period,
    periodActivities: periodActivities,
    samplesByActivityId: samplesByActivityId,
    priorRecords: priorRecords,
    priorMaxWeightsByExercise: priorMaxWeights,
    waterTotalsByDay: waterTotalsByDay,
    periodNutritionEntries: nutritionEntries,
    nutritionGoals: nutritionGoals,
    basisKcal: basisKcal,
    periodCheckins: checkins,
  );
}

/// Retry policy for [recapForPeriodProvider]: never. The first failure is
/// the answer.
///
/// Riverpod 3 retries a failed async provider *by default*
/// (`ProviderContainer.defaultRetry`: up to 10 attempts, 200ms doubling to
/// 6.4s, and it retries anything that isn't an `Error` — `AppException`
/// implements `Exception`, so a `StorageException` qualifies). While it is
/// retrying, the provider sits in `AsyncLoading(retrying: true)`, **not**
/// `AsyncError` — so `.future` does not complete and no caller learns
/// anything for ~38 seconds.
///
/// That default is written for a flaky network read. This is a local Drift
/// read plus a pure fold: a storage failure here means the database is
/// locked, missing or corrupt, which waiting does not fix, and re-running
/// the whole-history aggregation (see [recapForPeriod]'s cost note) ten
/// times spends real CPU to arrive at the same failure much later.
///
/// Both callers want it now rather than later:
/// - the history row (`presentation/widgets/recap_history_section.dart`)
///   holds a spinner until this settles, so silent retrying would leave a
///   just-tapped row spinning for most of a minute — precisely the
///   no-feedback problem that busy state exists to fix;
/// - Home's trigger (`presentation/recap_trigger_controller.dart`) fails
///   silently either way, and its natural retry cadence is the next Home
///   mount: cheaper, and better timed than ten immediate re-runs.
///
/// Deliberately *not* applied to [recentRecapPeriods]: that one is two
/// cheap one-shot reads whose failure just hides the section, so the free
/// retry there can only help.
Duration? _noRetry(int retryCount, Object error) => null;

/// How many historical activities' samples [recapForPeriod] fetches and
/// folds at a time.
///
/// A round-trip/memory trade-off, not a correctness knob: bigger means
/// fewer queries but more GPS tracks resident at once (a single recorded
/// hour is ~3,600 samples), smaller means the opposite. 25 keeps a peak of
/// a few dozen tracks while turning a 300-activity history into ~12
/// queries instead of 300.
const int _priorFoldChunkSize = 25;

/// Whether [activity]'s **local** calendar day falls inside [period],
/// both ends inclusive. Local, not UTC: a period is a range of calendar
/// days he lived through (`core/domain/local_date.dart`).
bool _fallsWithin(Activity activity, RecapPeriod period) {
  final day = LocalDate.fromDateTime(activity.startedAt.toLocal());
  return !day.isBefore(period.start) && !day.isAfter(period.end);
}

/// How many recap periods [recentRecapPeriodsProvider] surfaces at most.
const int recapHistoryLimit = 6;

/// Every completed calendar month recap period available to revisit,
/// newest-ending-first, capped at [recapHistoryLimit] — powers the
/// Progress screen's re-viewable recap history (`TASKS_TO_DO.md` Task
/// 1.3's second entry point).
///
/// A candidate month is only offered once it clears the same bar
/// [RecapBuilder.minSessionsForMonthRecap] applies when actually building
/// one. Without that, a brand-new account's Progress screen showed six
/// months whose only possible answer was "there's not quite enough logged
/// for this period to recap yet" — a list of six dead ends is worse than
/// no list.
@riverpod
Future<List<RecapPeriod>> recentRecapPeriods(Ref ref) async {
  final activityRepo = ref.watch(activityRepositoryProvider);
  // One whole-history snapshot, reused for every candidate month below —
  // never `watchActivities().first` (see
  // `features/activity/domain/activity_repository.dart#getActivities`).
  final allActivities = await activityRepo.getActivities();
  final today = LocalDate.today();

  final periods = <RecapPeriod>[];

  // Walk backwards from the most recently completed month, one month at a
  // time - cheap since it's pure date arithmetic plus an in-memory count
  // over the snapshot above, no I/O per month. The number of months
  // *considered* is unchanged; only which of them survive is new, so a
  // long-lapsed history still can't push the window further back.
  var monthCursor = mostRecentCompletedMonth(today);
  for (var i = 0; i < recapHistoryLimit; i++) {
    if (_hasEnoughSessions(allActivities, monthCursor)) {
      periods.add(monthCursor);
    }
    monthCursor = mostRecentCompletedMonth(monthCursor.start);
  }

  periods.sort((a, b) => b.end.compareTo(a.end));
  return periods.take(recapHistoryLimit).toList();
}

/// Whether [activities] contain enough sessions inside [period] for
/// [RecapBuilder] to build a month recap at all. Stops counting the moment
/// the bar is cleared.
bool _hasEnoughSessions(List<Activity> activities, RecapPeriod period) {
  var count = 0;
  for (final activity in activities) {
    if (!_fallsWithin(activity, period)) continue;
    count++;
    if (count >= RecapBuilder.minSessionsForMonthRecap) return true;
  }
  return false;
}
