/// Pure aggregation of logged activities into weekly totals, for the
/// Progress screen's trend chart and stat tiles.
///
/// Weeks bucket by **user-local calendar week, Monday start** — there is no
/// per-user "week starts on" preference yet (see `knowledge/product/deferred.md`
/// if one is ever requested); Monday is chosen to match the ISO-8601 week
/// convention rather than a Sunday-start week.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

part 'weekly_summary.freezed.dart';

/// One calendar week's aggregated activity totals.
@freezed
abstract class WeeklySummary with _$WeeklySummary {
  const factory WeeklySummary({
    /// The Monday that starts this week (see [mondayOf]).
    required LocalDate weekStart,
    required double distanceMeters,
    required Duration movingTime,
    required int activityCount,
  }) = _WeeklySummary;
}

/// The Monday on or before [day] — the start of [day]'s calendar week under
/// the Monday-start convention this feature uses throughout.
///
/// Pure calendar arithmetic via [LocalDate.addDays], so it's correct across
/// month/year boundaries the same way [LocalDate] itself is (DST-free,
/// UTC-noon-anchored) — there is no local-time math here to get wrong at a
/// boundary.
LocalDate mondayOf(LocalDate day) {
  final weekday = DateTime.utc(day.year, day.month, day.day).weekday;
  return day.addDays(-(weekday - 1));
}

/// Buckets [activities] into the last [weeks] calendar weeks (Monday start),
/// ending with the week containing [today], oldest first.
///
/// Always returns exactly [weeks] entries, zero-filled for any week with no
/// activity — callers never need to special-case a short list. An activity's
/// UTC [Activity.startedAt] is converted to the user's local calendar day
/// (`.toLocal()`) before bucketing — the same UTC-instant-to-local-day
/// pattern used throughout (see `core/domain/local_date.dart`) — so an
/// activity logged late on a Sunday evening lands in that Sunday's week, not
/// whatever UTC day it might roll over into.
///
/// v1 counts every [ActivityType] together (run/walk/hike/ride all
/// contribute to the same weekly totals) — per-type breakdowns are deferred
/// until there's a concrete UI need (see `knowledge/product/deferred.md`,
/// same rationale as `domain/personal_records.dart`).
List<WeeklySummary> computeWeeklySummaries({
  required List<Activity> activities,
  required LocalDate today,
  int weeks = 12,
}) {
  final currentWeekStart = mondayOf(today);
  final weekStarts = [
    for (var i = weeks - 1; i >= 0; i--) currentWeekStart.addDays(-7 * i),
  ];

  final totals = {for (final weekStart in weekStarts) weekStart: _Totals()};

  for (final activity in activities) {
    final localDay = LocalDate.fromDateTime(activity.startedAt.toLocal());
    final weekStart = mondayOf(localDay);
    final bucket = totals[weekStart];
    // Outside the [weeks]-window (older than the chart covers) - ignored.
    if (bucket == null) continue;
    bucket
      ..distanceMeters += activity.distanceMeters
      ..movingTime += activity.movingTime
      ..activityCount += 1;
  }

  return [
    for (final weekStart in weekStarts)
      WeeklySummary(
        weekStart: weekStart,
        distanceMeters: totals[weekStart]!.distanceMeters,
        movingTime: totals[weekStart]!.movingTime,
        activityCount: totals[weekStart]!.activityCount,
      ),
  ];
}

/// Mutable accumulator used only while building [computeWeeklySummaries]'s
/// result - never exposed outside this file.
class _Totals {
  double distanceMeters = 0;
  Duration movingTime = Duration.zero;
  int activityCount = 0;
}
