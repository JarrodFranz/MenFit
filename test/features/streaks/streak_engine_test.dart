import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';

void main() {
  final today = LocalDate(2026, 8, 26);
  LocalDate d(int offset) => today.addDays(offset);

  group('simple runs', () {
    test('every day satisfied up to today: streak grows by day count', () {
      final result = computeStreaks(
        activeDays: {d(0), d(-1), d(-2), d(-3)},
        protectedDays: const {},
        today: today,
      );
      expect(result.currentStreak, 4);
      expect(result.longestStreak, 4);
      expect(result.todayStatus, DayStatus.completedActivity);
      expect(result.isProtectedToday, isFalse);
      expect(result.todaySatisfied, isTrue);
    });

    test('a single satisfied day today only', () {
      final result = computeStreaks(
        activeDays: {d(0)},
        protectedDays: const {},
        today: today,
      );
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
    });
  });

  group('gap breaks', () {
    test(
      'a plain unsatisfied/unprotected day in the past breaks the streak',
      () {
        // Satisfied 3 days ago, gap 2 days ago, satisfied yesterday and today.
        final result = computeStreaks(
          activeDays: {d(0), d(-1), d(-3)},
          protectedDays: const {},
          today: today,
        );
        expect(result.currentStreak, 2); // today, yesterday only
        expect(result.longestStreak, 2);
      },
    );
  });

  group('protection bridging (the signature scenario)', () {
    test(
      'active Mon-Tue, protected Wed-Fri (inactive), active Sat -> current '
      'streak of 3 counting Sat, Tue, Mon',
      () {
        final sat = today; // today = Saturday, in this test's calendar.
        final fri = sat.addDays(-1);
        final thu = sat.addDays(-2);
        final wed = sat.addDays(-3);
        final tue = sat.addDays(-4);
        final mon = sat.addDays(-5);

        final result = computeStreaks(
          activeDays: {mon, tue, sat},
          protectedDays: {wed, thu, fri},
          today: sat,
        );
        expect(result.currentStreak, 3);
        expect(result.todaySatisfied, isTrue);
        expect(result.todayStatus, DayStatus.completedActivity);
        expect(result.isProtectedToday, isFalse);
      },
    );

    test('long protected stretch (2-week protection) bridges the streak', () {
      final activeBefore = d(-20);
      // Every day strictly between activeBefore and today is protected, so
      // nothing breaks the backward walk between the two satisfied days.
      final protectedRun = <LocalDate>{
        for (var i = -19; i < 0; i++) d(i), // 19 protected days
      };

      final result = computeStreaks(
        activeDays: {activeBefore, d(0)},
        protectedDays: protectedRun,
        today: today,
      );
      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
    });
  });

  group('active on a protected day', () {
    test(
      'a day that is both logged active and protected counts as satisfied '
      '- satisfied takes precedence, the streak extends',
      () {
        final protectedDay = d(-1);
        final result = computeStreaks(
          activeDays: {d(0), protectedDay, d(-2)},
          protectedDays: {protectedDay},
          today: today,
        );
        expect(result.currentStreak, 3);
      },
    );
  });

  group('today pending', () {
    test(
      "yesterday satisfied, today nothing -> streak alive at yesterday's "
      'count',
      () {
        final result = computeStreaks(
          activeDays: {d(-1), d(-2)},
          protectedDays: const {},
          today: today,
        );
        expect(result.currentStreak, 2);
        expect(result.todaySatisfied, isFalse);
        expect(result.todayStatus, DayStatus.unscheduled);
        expect(result.isProtectedToday, isFalse);
      },
    );

    test(
      'today unsatisfied+unprotected does NOT break (pending), but a gap '
      'on yesterday DOES',
      () {
        // day -2 satisfied, day -1 (yesterday) a genuine gap, today empty.
        final result = computeStreaks(
          activeDays: {d(-2)},
          protectedDays: const {},
          today: today,
        );
        expect(result.currentStreak, 0);
        expect(result.longestStreak, 1); // the day -2 run still happened
      },
    );
  });

  group('protection-disabled equivalent', () {
    test(
      'empty protectedDays: a former protected day behaves as a plain gap',
      () {
        // Same shape as the bridging scenario, but with no protected days at
        // all (as if every protection source were off) - the mid-week gap
        // now breaks the streak instead of bridging it.
        final sat = today;
        final mon = sat.addDays(-5);
        final tue = sat.addDays(-4);

        final result = computeStreaks(
          activeDays: {mon, tue, sat},
          protectedDays: const {}, // nothing protected
          today: sat,
        );
        expect(
          result.currentStreak,
          1,
        ); // only Sat counts; Wed-Fri gap broke it
      },
    );
  });

  group('longest streak', () {
    test('longest streak across a bridge and a later reset', () {
      // Mon,Tue satisfied; Wed-Fri protected; Sat satisfied (run of 6,
      // bridged) then a real gap, then a single day much later.
      final mon = d(-20);
      final tue = d(-19);
      final wed = d(-18);
      final thu = d(-17);
      final fri = d(-16);
      final sat = d(-15);
      // Gap from d(-14) to d(-2).
      final laterSingleDay = d(-1);

      final result = computeStreaks(
        activeDays: {mon, tue, sat, laterSingleDay, today},
        protectedDays: {wed, thu, fri},
        today: today,
      );
      // Longest run: Mon,Tue,(Wed,Thu,Fri bridged),Sat = 3 satisfied days
      // in that run (Mon, Tue, Sat).
      expect(result.longestStreak, 3);
      // Current streak: today + yesterday (laterSingleDay) = 2.
      expect(result.currentStreak, 2);
    });

    test('both empty -> zeros', () {
      final result = computeStreaks(
        activeDays: const {},
        protectedDays: const {},
        today: today,
      );
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.todayStatus, DayStatus.unscheduled);
      expect(result.isProtectedToday, isFalse);
      expect(result.todaySatisfied, isFalse);
    });
  });

  group('protected today only', () {
    test(
      'a single protected today with nothing else -> 0 current, '
      'protectedRecovery today',
      () {
        final result = computeStreaks(
          activeDays: const {},
          protectedDays: {today},
          today: today,
        );
        expect(result.currentStreak, 0);
        expect(result.todayStatus, DayStatus.protectedRecovery);
        expect(result.isProtectedToday, isTrue);
        expect(result.todaySatisfied, isFalse);
      },
    );
  });

  group('B4/B5: protected today with an active run behind it', () {
    test(
      'today protected, yesterday and the day before satisfied -> current '
      'streak of 2, protectedRecovery today, longest streak 2',
      () {
        final result = computeStreaks(
          activeDays: {d(-1), d(-2)},
          protectedDays: {d(0)},
          today: today,
        );
        expect(result.currentStreak, 2);
        expect(result.todayStatus, DayStatus.protectedRecovery);
        expect(result.isProtectedToday, isTrue);
        expect(result.longestStreak, 2);
      },
    );

    test(
      'today protected, an earlier gap breaks the run before it -> current '
      'streak counts only the days after the gap, still protectedRecovery '
      'today',
      () {
        // Satisfied 4 days ago, a genuine gap 3 days ago, satisfied on
        // days -2 and -1, protected today. The gap must still break the
        // backward walk even though today itself is (separately)
        // protected.
        final result = computeStreaks(
          activeDays: {d(-4), d(-2), d(-1)},
          protectedDays: {d(0)},
          today: today,
        );
        expect(result.currentStreak, 2); // just d(-1), d(-2); d(-3) is a gap
        expect(result.isProtectedToday, isTrue);
        expect(result.longestStreak, 2);
      },
    );
  });
}
