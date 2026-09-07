import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/streaks/domain/streak_assembly.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';

void main() {
  final today = LocalDate(2026, 8, 26);

  Activity activity({required DateTime startedAt, String id = 'a1'}) {
    return Activity(
      id: id,
      activityType: ActivityType.run,
      title: 'Run',
      startedAt: startedAt,
      movingTime: const Duration(minutes: 30),
      elapsedTime: const Duration(minutes: 30),
      distanceMeters: 5000,
      source: ActivitySource.manual,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  CycleRecord record({
    required LocalDate start,
    LocalDate? end,
    String id = 'r1',
  }) {
    return CycleRecord(
      id: id,
      periodStart: start,
      periodEnd: end,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  StreakResult assemble({
    List<Activity> activities = const [],
    Set<LocalDate> recoveryDays = const {},
    Set<LocalDate> flareProtectedDays = const {},
    List<CycleRecord> records = const [],
    bool pausingEnabled = true,
    LocalDate? asOf,
  }) {
    return assembleStreakResult(
      activities: activities,
      recoveryDays: recoveryDays,
      flareProtectedDays: flareProtectedDays,
      records: records,
      pausingEnabled: pausingEnabled,
      today: asOf ?? today,
    );
  }

  test('every source empty -> the zero fast-path', () {
    final result = assemble();
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 0);
    expect(result.todayStatus, DayStatus.unscheduled);
    expect(result.todaySatisfied, isFalse);
  });

  test(
    'an activity logged at 23:30 lands on that local day, not the next one',
    () {
      // A naive implementation that skipped `.toLocal()` (or applied it
      // twice) risks shifting a late-night activity onto the wrong
      // calendar day. `DateTime(...)` without a `.utc` constructor
      // produces a *local*-time value on this test's machine, so
      // `startedAt.toLocal()` inside `assembleStreakResult` is a no-op
      // here and 23:30 must land on the same local day it was logged on.
      final lateNight = DateTime(2026, 8, 26, 23, 30);
      final result = assemble(
        activities: [activity(startedAt: lateNight)],
        asOf: LocalDate(2026, 8, 26),
      );
      expect(result.todaySatisfied, isTrue);
      expect(result.currentStreak, 1);
    },
  );

  test(
    'pausingEnabled toggles whether a logged period bridges or breaks the '
    'streak',
    () {
      // Satisfied 5 days ago, a 4-day logged period immediately after it
      // (days -4..-1), satisfied again today. With pausing on, the period
      // bridges the two satisfied days into one streak; with it off, the
      // same days are plain unsatisfied gaps that break the streak.
      final activities = [
        activity(startedAt: today.addDays(-5).toLocalNoonDateTime()),
        activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
      ];
      final records = [
        record(start: today.addDays(-4), end: today.addDays(-1)),
      ];

      final withPausing = assemble(activities: activities, records: records);
      final withoutPausing = assemble(
        activities: activities,
        records: records,
        pausingEnabled: false,
      );

      expect(withPausing.currentStreak, 2); // today + day -5, bridged
      expect(withoutPausing.currentStreak, 1); // just today; day -1 breaks it
    },
  );

  test(
    'B5: an ongoing period (null end) covering today keeps today protected '
    'and preserves the streak through the real assembly chain - guards an '
    'off-by-one in the ongoing-period-to-today cap that would silently '
    'kill the protected card',
    () {
      // Satisfied 5 days ago, then an ongoing period (no end logged yet)
      // starting 4 days ago - it must cover every day from its start
      // through *today inclusive*, bridging the streak and marking today
      // protected.
      final activities = [
        activity(startedAt: today.addDays(-5).toLocalNoonDateTime()),
      ];
      final records = [record(start: today.addDays(-4))]; // periodEnd: null

      final result = assemble(activities: activities, records: records);

      expect(result.todayStatus, DayStatus.protectedRecovery);
      expect(result.currentStreak, 1); // day -5, bridged all the way through
    },
  );

  test('earliest range spans activities, period records, and flares', () {
    final oldActivityDay = today.addDays(-10);
    final activities = [
      activity(startedAt: oldActivityDay.toLocalNoonDateTime()),
      activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
    ];
    final oldPeriodStart = today.addDays(-20);
    final records = [
      record(start: oldPeriodStart, end: today.addDays(-19)),
    ];
    final olderFlareDay = {today.addDays(-25)};

    // Should not throw and should reflect today's satisfied activity even
    // though the period and the flare both predate every activity.
    final result = assemble(
      activities: activities,
      records: records,
      flareProtectedDays: olderFlareDay,
    );
    expect(result.todaySatisfied, isTrue);
  });

  group('protection source: explicit recovery days', () {
    test('a day in recoveryDays protects it, bridging a gap', () {
      final result = assemble(
        activities: [
          activity(startedAt: today.addDays(-2).toLocalNoonDateTime()),
          activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
        ],
        recoveryDays: {today.addDays(-1)},
      );
      // Two satisfied days (today, today -2) bridged by one protected day
      // (today -1) in between.
      expect(result.currentStreak, 2);
    });

    test('recovery-day protection applies even when pausing is disabled', () {
      final result = assemble(
        activities: [
          activity(startedAt: today.addDays(-2).toLocalNoonDateTime()),
          activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
        ],
        recoveryDays: {today.addDays(-1)},
        pausingEnabled: false,
      );
      expect(result.currentStreak, 2);
    });
  });

  group('protection source: flare-protected days', () {
    // NOTE: filtering by `FlareImpact` (only `unableToTrain` protects, not
    // `reducedTraining`/`none`) happens upstream, in
    // `WellbeingRepository.watchProtectingFlareDays` - by the time a day
    // reaches `flareProtectedDays` here, it's already been decided to
    // protect. That impact-filtering behaviour is covered by
    // `wellbeing_repository_test.dart`'s `watchProtectingFlareDays` group,
    // not here.
    test('a day in flareProtectedDays protects it, bridging a gap', () {
      final result = assemble(
        activities: [
          activity(startedAt: today.addDays(-2).toLocalNoonDateTime()),
          activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
        ],
        flareProtectedDays: {today.addDays(-1)},
      );
      // Two satisfied days bridged by the one flare-protected day.
      expect(result.currentStreak, 2);
    });

    test(
      'RETROACTIVE flare logging protects a past day and heals a '
      'previously-broken streak (spec §33)',
      () {
        final activities = [
          activity(startedAt: today.addDays(-2).toLocalNoonDateTime()),
          activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
        ];

        final before = assemble(activities: activities);
        expect(before.currentStreak, 1); // the gap on day -1 breaks it

        // Logging the flare after the fact, covering exactly the gap.
        final after = assemble(
          activities: activities,
          flareProtectedDays: {today.addDays(-1)},
        );
        expect(after.currentStreak, 2); // retroactively healed
      },
    );

    test(
      'F1: a flare-protected day 500+ days before today still bridges into '
      'longestStreak - flare-based protection must never expire, unlike a '
      'time-windowed query would allow',
      () {
        final oldGapDay = today.addDays(-501);
        final result = assemble(
          activities: [
            activity(startedAt: today.addDays(-502).toLocalNoonDateTime()),
            activity(
              startedAt: today.addDays(-500).toLocalNoonDateTime(),
              id: 'a2',
            ),
          ],
          flareProtectedDays: {oldGapDay},
        );
        // The old window boundary (a former fixed 400-day flare-protection
        // window - see `streaks/streaks_providers.dart`'s history) sat
        // well inside this 500+ day range - this guards `assembleStreakResult`
        // itself never reintroduces any such windowing.
        expect(result.longestStreak, 2);
      },
    );
  });

  group('precedence: satisfied beats protected', () {
    test(
      'a day that is both a logged activity AND protected by every source '
      'still counts as satisfied, not merely protected',
      () {
        final doubleCoveredDay = today.addDays(-1);
        final result = assemble(
          activities: [
            activity(startedAt: doubleCoveredDay.toLocalNoonDateTime()),
            activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
          ],
          recoveryDays: {doubleCoveredDay},
          flareProtectedDays: {doubleCoveredDay},
          records: [record(start: doubleCoveredDay, end: doubleCoveredDay)],
        );
        expect(result.todaySatisfied, isTrue);
        expect(result.currentStreak, 2); // both days count as satisfied
      },
    );
  });

  group('toggle off: period days stop protecting, flare days still do', () {
    // Same shape for both cases: satisfied two days ago, a single day gap
    // (day -1), satisfied today.
    List<Activity> gapActivities() => [
      activity(startedAt: today.addDays(-2).toLocalNoonDateTime()),
      activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
    ];

    test(
      'with pausing disabled, a period-covered gap day is NOT protected - '
      'it still breaks the streak',
      () {
        final withPausing = assemble(
          activities: gapActivities(),
          records: [
            record(start: today.addDays(-1), end: today.addDays(-1)),
          ],
        );
        final withoutPausing = assemble(
          activities: gapActivities(),
          records: [
            record(start: today.addDays(-1), end: today.addDays(-1)),
          ],
          pausingEnabled: false,
        );

        expect(withPausing.currentStreak, 2); // bridged via the period day
        expect(withoutPausing.currentStreak, 1); // today only; the gap broke it
      },
    );

    test(
      'with pausing disabled, a flare-covered gap day IS still protected - '
      'flare protection is independent of the period toggle',
      () {
        final withoutPausing = assemble(
          activities: gapActivities(),
          flareProtectedDays: {today.addDays(-1)},
          pausingEnabled: false,
        );

        expect(withoutPausing.currentStreak, 2); // still bridged via the flare
      },
    );
  });
}

extension on LocalDate {
  /// A local noon [DateTime] for this date - a stand-in for "some instant
  /// that unambiguously falls on this local calendar day", since
  /// `Activity.startedAt` is a UTC instant in production but these tests
  /// care only about which local day it lands on.
  DateTime toLocalNoonDateTime() => DateTime(year, month, day, 12);
}
