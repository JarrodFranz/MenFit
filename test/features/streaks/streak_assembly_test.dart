import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
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

  StreakResult assemble({
    List<Activity> activities = const [],
    Set<LocalDate> recoveryDays = const {},
    Set<LocalDate> flareProtectedDays = const {},
    LocalDate? asOf,
  }) {
    return assembleStreakResult(
      activities: activities,
      recoveryDays: recoveryDays,
      flareProtectedDays: flareProtectedDays,
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

  test('earliest range spans activities, recovery days and flares', () {
    final oldActivityDay = today.addDays(-10);
    final activities = [
      activity(startedAt: oldActivityDay.toLocalNoonDateTime()),
      activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
    ];
    final olderRecoveryDay = {today.addDays(-20)};
    final olderFlareDay = {today.addDays(-25)};

    // Should not throw and should reflect today's satisfied activity even
    // though the recovery day and the flare both predate every activity.
    final result = assemble(
      activities: activities,
      recoveryDays: olderRecoveryDay,
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

    test('a recovery day protects independently of any flare', () {
      final result = assemble(
        activities: [
          activity(startedAt: today.addDays(-2).toLocalNoonDateTime()),
          activity(startedAt: today.toLocalNoonDateTime(), id: 'a2'),
        ],
        recoveryDays: {today.addDays(-1)},
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
        );
        expect(result.todaySatisfied, isTrue);
        expect(result.currentStreak, 2); // both days count as satisfied
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
