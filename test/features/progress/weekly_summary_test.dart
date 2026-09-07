import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';

Activity _activity({
  required String id,
  required DateTime startedAt,
  double distanceMeters = 5000,
  Duration movingTime = const Duration(minutes: 30),
}) {
  return Activity(
    id: id,
    activityType: ActivityType.run,
    title: 'Run $id',
    startedAt: startedAt,
    movingTime: movingTime,
    elapsedTime: movingTime,
    distanceMeters: distanceMeters,
    source: ActivitySource.manual,
    createdAt: startedAt,
    updatedAt: startedAt,
  );
}

void main() {
  group('mondayOf', () {
    test('a Monday maps to itself', () {
      // 2026-08-24 is a Monday.
      final monday = LocalDate(2026, 8, 24);
      expect(mondayOf(monday), monday);
    });

    test('a Sunday maps to the Monday 6 days earlier', () {
      // 2026-08-30 is a Sunday.
      final sunday = LocalDate(2026, 8, 30);
      expect(mondayOf(sunday), LocalDate(2026, 8, 24));
    });

    test("a mid-week day maps to that week's Monday", () {
      // 2026-08-27 is a Thursday.
      final thursday = LocalDate(2026, 8, 27);
      expect(mondayOf(thursday), LocalDate(2026, 8, 24));
    });

    test('crosses a month boundary correctly', () {
      // 2026-09-01 is a Tuesday; its week starts Monday 2026-08-31.
      final tuesday = LocalDate(2026, 9, 1);
      expect(mondayOf(tuesday), LocalDate(2026, 8, 31));
    });

    test('crosses a year boundary correctly', () {
      // 2026-01-01 is a Thursday; its week starts Monday 2025-12-29.
      final newYearsDay = LocalDate(2026, 1, 1);
      expect(mondayOf(newYearsDay), LocalDate(2025, 12, 29));
    });
  });

  group('computeWeeklySummaries', () {
    test('returns exactly `weeks` entries, zero-filled, when there are no '
        'activities', () {
      final today = LocalDate(2026, 8, 25); // A Tuesday.
      final summaries = computeWeeklySummaries(
        activities: const [],
        today: today,
      );

      expect(summaries, hasLength(12));
      for (final summary in summaries) {
        expect(summary.distanceMeters, 0);
        expect(summary.movingTime, Duration.zero);
        expect(summary.activityCount, 0);
      }
    });

    test('the last entry is the current week and entries are oldest-first', () {
      final today = LocalDate(2026, 8, 25); // A Tuesday.
      final summaries = computeWeeklySummaries(
        activities: const [],
        today: today,
      );

      expect(summaries.last.weekStart, mondayOf(today));
      for (var i = 0; i < summaries.length - 1; i++) {
        expect(
          summaries[i].weekStart.isBefore(summaries[i + 1].weekStart),
          isTrue,
        );
      }
      // Consecutive weeks are exactly 7 days apart, across the full window.
      expect(
        summaries.first.weekStart.difference(summaries.last.weekStart),
        7 * 11,
      );
    });

    test('an activity late on a Sunday evening (local time) lands in that '
        "Sunday's week, not a UTC-rollover week", () {
      final today = LocalDate(2026, 8, 25); // A Tuesday.
      // UTC 2026-08-24 23:30 is Sunday 2026-08-23 local at UTC-1 - but we
      // pass an already-local-equivalent instant by using a UTC timestamp
      // that itself falls late Sunday UTC, then rely on `.toLocal()` inside
      // `computeWeeklySummaries` doing nothing extra in this test's host
      // timezone. To keep this test deterministic regardless of the host's
      // timezone, construct the activity's `startedAt` UTC instant so that
      // its *local* rendering is guaranteed late Sunday: since
      // `DateTime.toLocal()` only shifts by whole hours/minutes of a fixed
      // offset, choose 23:30 UTC on Sunday 2026-08-23 - any real-world
      // timezone offset keeps this within Sunday 2026-08-23 or rolls it to
      // Monday 2026-08-24, both of which fall in the *same* Monday-start
      // week (2026-08-17's week ends Sun 23rd; the week starting Mon 24th
      // begins immediately after). To avoid that ambiguity entirely, assert
      // against whatever week the activity actually lands in via
      // `LocalDate.fromDateTime(startedAt.toLocal())` rather than hardcoding
      // a week, proving the bucketing is *local-day* based, not
      // UTC-day-based.
      final startedAt = DateTime.utc(2026, 8, 23, 23, 30);
      final expectedWeek = mondayOf(
        LocalDate.fromDateTime(startedAt.toLocal()),
      );

      final summaries = computeWeeklySummaries(
        activities: [_activity(id: 'a1', startedAt: startedAt)],
        today: today,
      );

      final matching = summaries.where((s) => s.weekStart == expectedWeek);
      expect(matching, hasLength(1));
      expect(matching.single.activityCount, 1);
    });

    test('sums distance/time and counts activities within the same week', () {
      final today = LocalDate(2026, 8, 25); // A Tuesday.
      final monday = mondayOf(today);
      // Built from *local* noon on each intended calendar day, then
      // converted to UTC for `startedAt` - this keeps the test's intended
      // local calendar day correct regardless of the host machine's
      // timezone (unlike hardcoding a UTC instant and hoping the local
      // conversion doesn't cross a day boundary).
      final mondayLocalNoon = DateTime(
        monday.year,
        monday.month,
        monday.day,
        12,
      );
      final tuesdayLocalNoon = DateTime(
        monday.year,
        monday.month,
        monday.day + 1,
        12,
      );
      final activities = [
        _activity(
          id: 'a1',
          startedAt: mondayLocalNoon.toUtc(),
          movingTime: const Duration(minutes: 25),
        ),
        _activity(
          id: 'a2',
          startedAt: tuesdayLocalNoon.toUtc(),
          distanceMeters: 3000,
          movingTime: const Duration(minutes: 15),
        ),
      ];

      final summaries = computeWeeklySummaries(
        activities: activities,
        today: today,
      );

      final currentWeek = summaries.singleWhere((s) => s.weekStart == monday);
      expect(currentWeek.distanceMeters, 8000);
      expect(currentWeek.movingTime, const Duration(minutes: 40));
      expect(currentWeek.activityCount, 2);
    });

    test('an activity older than the `weeks` window is ignored, not counted '
        'toward the oldest bucket', () {
      final today = LocalDate(2026, 8, 25);
      final tooOld = DateTime.utc(2020);

      final summaries = computeWeeklySummaries(
        activities: [_activity(id: 'old', startedAt: tooOld)],
        today: today,
      );

      for (final summary in summaries) {
        expect(summary.activityCount, 0);
      }
    });

    test(
      'a UTC-constructed and a local-constructed late-Sunday activity are '
      'each bucketed into the week of their own LOCAL day, deterministically '
      'regardless of the host timezone (F8)',
      () {
        final today = LocalDate(2026, 8, 25); // A Tuesday.

        // Two different Sundays (7 days apart - far more than any real
        // timezone offset, +-14h at most, could ever shift a date), each
        // built via a different construction path: one directly as a UTC
        // instant (already late Sunday UTC-side), one from *local* 23:30
        // converted to UTC (so its UTC representation may land on a
        // different calendar day than its intended local one, depending on
        // the host's offset). Being 7 days apart means their expected
        // weeks can never coincide under any real host timezone, so this
        // test's assertions hold deterministically everywhere.
        final utcSunday = DateTime.utc(2026, 8, 16, 23, 30);
        final localSunday = DateTime(2026, 8, 9, 23, 30).toUtc();

        final expectedWeekForUtc = mondayOf(
          LocalDate.fromDateTime(utcSunday.toLocal()),
        );
        final expectedWeekForLocal = mondayOf(
          LocalDate.fromDateTime(localSunday.toLocal()),
        );
        expect(
          expectedWeekForUtc,
          isNot(expectedWeekForLocal),
          reason: 'the two Sundays are 7 days apart - this must always hold',
        );

        final summaries = computeWeeklySummaries(
          activities: [
            _activity(
              id: 'utc-sunday',
              startedAt: utcSunday,
              distanceMeters: 1000,
            ),
            _activity(
              id: 'local-sunday',
              startedAt: localSunday,
              distanceMeters: 2000,
            ),
          ],
          today: today,
        );

        final utcWeek = summaries.singleWhere(
          (s) => s.weekStart == expectedWeekForUtc,
        );
        expect(utcWeek.distanceMeters, 1000);
        expect(utcWeek.activityCount, 1);

        final localWeek = summaries.singleWhere(
          (s) => s.weekStart == expectedWeekForLocal,
        );
        expect(localWeek.distanceMeters, 2000);
        expect(localWeek.activityCount, 1);
      },
    );

    test('defaults to a 12-week window', () {
      final summaries = computeWeeklySummaries(
        activities: const [],
        today: LocalDate(2026, 8, 25),
      );
      expect(summaries, hasLength(12));
    });
  });
}
