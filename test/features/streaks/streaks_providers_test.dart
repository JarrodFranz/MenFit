import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final today = LocalDate.today();

  late db.AppDatabase database;
  late ProviderContainer container;

  /// An instant that lands on [day] in this machine's local timezone -
  /// mirrors how a real `Activity.startedAt` (a UTC instant) is produced
  /// and later mapped back onto a local day by `streak_assembly.dart`.
  DateTime instantOnLocalDay(LocalDate day) {
    return DateTime(day.year, day.month, day.day, 12).toUtc();
  }

  Activity activity({required LocalDate day, required String id}) {
    return Activity(
      id: id,
      activityType: ActivityType.run,
      title: 'Run',
      startedAt: instantOnLocalDay(day),
      movingTime: const Duration(minutes: 30),
      elapsedTime: const Duration(minutes: 30),
      distanceMeters: 5000,
      source: ActivitySource.manual,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  FlareEvent flare({
    required LocalDate day,
    required FlareImpact impact,
    String id = 'flare-1',
  }) {
    return FlareEvent(
      id: id,
      day: day,
      severity: FlareSeverity.moderate,
      impact: impact,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  /// Waits until [streakResultProvider] emits a value matching [predicate]
  /// (checking the current value immediately, then every subsequent
  /// emission), instead of racing a bare `await ... .future` immediately
  /// after triggering a write - Drift's `.watch()` streams (which back
  /// every repository stream `streakResultProvider` combines) notify
  /// watchers asynchronously after a write completes, not synchronously as
  /// part of it (the same `expectLater(... emitsThrough(...))` reasoning the
  /// repository tests use, adapted here since a
  /// Riverpod `StreamProvider` in this Riverpod version has no `.stream`
  /// accessor to hand to `expectLater` directly).
  Future<StreakResult> waitFor(bool Function(StreakResult) predicate) async {
    final completer = Completer<StreakResult>();
    final subscription = container.listen(streakResultProvider, (
      previous,
      next,
    ) {
      final value = next.value;
      if (value != null && predicate(value) && !completer.isCompleted) {
        completer.complete(value);
      }
    }, fireImmediately: true);
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      subscription.close();
    }
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    // streakResultProvider is a StreamProvider (default autoDispose): see
    // `testing-pitfalls.md`'s Riverpod v3 test trap - without an active
    // listener it can be torn down mid-flight on its very first (pending)
    // emission. A no-op listen keeps it alive for the container's
    // lifetime, matching how a watching widget would keep it alive in the
    // real app.
    container.listen(streakResultProvider, (previous, next) {});
  });

  test('an empty database produces the zero result', () async {
    final result = await container.read(streakResultProvider.future);
    expect(result.currentStreak, 0);
    expect(result.longestStreak, 0);
  });

  test(
    "a saved activity on an instant that lands on today's local day is "
    'reflected as satisfied, and a later activity recomputes the stream',
    () async {
      final activityRepository = container.read(activityRepositoryProvider);

      await activityRepository.saveActivity(
        activity(day: today, id: 'today-activity'),
      );
      final afterFirst = await waitFor(
        (r) => r.todaySatisfied && r.currentStreak == 1,
      );
      expect(afterFirst.todaySatisfied, isTrue);

      // A second activity yesterday extends the streak once persisted -
      // proves the provider recomputes on further source changes, not
      // just the first one.
      await activityRepository.saveActivity(
        activity(day: today.addDays(-1), id: 'yesterday-activity'),
      );
      final afterSecond = await waitFor((r) => r.currentStreak == 2);
      expect(afterSecond.currentStreak, 2);
    },
  );

  test(
    'marking recovery days retroactively bridges a previously broken '
    'streak (the signature scenario)',
    () async {
      final activityRepository = container.read(activityRepositoryProvider);
      final recoveryRepository = container.read(recoveryRepositoryProvider);

      // Satisfied 5 days ago, nothing logged for the 4 days after that,
      // satisfied again today - a plain gap, streak currently broken.
      await activityRepository.saveActivity(
        activity(day: today.addDays(-5), id: 'old'),
      );
      await activityRepository.saveActivity(activity(day: today, id: 'new'));

      final before = await waitFor((r) => r.currentStreak == 1);
      expect(before.currentStreak, 1); // the gap 1-4 days ago broke it

      // Mark the gap as recovery *after the fact*, covering it exactly.
      await recoveryRepository.markRecoveryDays(
        today.addDays(-4),
        today.addDays(-1),
      );

      final after = await waitFor((r) => r.currentStreak == 2);
      expect(after.currentStreak, 2); // retroactively bridged
    },
  );

  test(
    'RETROACTIVE flare logging (impact unableToTrain) heals a previously '
    'broken streak through the real provider chain (spec §33)',
    () async {
      final activityRepository = container.read(activityRepositoryProvider);
      final wellbeingRepository = container.read(wellbeingRepositoryProvider);

      await activityRepository.saveActivity(
        activity(day: today.addDays(-2), id: 'old'),
      );
      await activityRepository.saveActivity(activity(day: today, id: 'new'));

      final before = await waitFor((r) => r.currentStreak == 1);
      expect(before.currentStreak, 1); // the gap on day -1 broke it

      // Logging the flare after the fact, covering exactly the gap.
      await wellbeingRepository.saveFlare(
        flare(day: today.addDays(-1), impact: FlareImpact.unableToTrain),
      );

      final after = await waitFor((r) => r.currentStreak == 2);
      expect(after.currentStreak, 2); // retroactively healed
    },
  );

  test(
    'F1: an unableToTrain flare 500+ days old still bridges into '
    'longestStreak through the real provider chain - flare-based '
    'protection must never expire (the old fixed-window bug this guards '
    'against would have silently dropped it)',
    () async {
      final activityRepository = container.read(activityRepositoryProvider);
      final wellbeingRepository = container.read(wellbeingRepositoryProvider);

      await activityRepository.saveActivity(
        activity(day: today.addDays(-502), id: 'old'),
      );
      await activityRepository.saveActivity(
        activity(day: today.addDays(-500), id: 'less-old'),
      );
      await wellbeingRepository.saveFlare(
        flare(day: today.addDays(-501), impact: FlareImpact.unableToTrain),
      );

      final result = await waitFor((r) => r.longestStreak == 2);
      expect(result.longestStreak, 2);
    },
  );

  test(
    'marking a recovery day via recoveryRepositoryProvider protects today '
    'through the real provider chain',
    () async {
      final recoveryRepository = container.read(recoveryRepositoryProvider);

      final before = await waitFor(
        (r) => r.todayStatus == DayStatus.unscheduled,
      );
      expect(before.todayStatus, DayStatus.unscheduled);

      await recoveryRepository.markRecoveryDay(today);

      final after = await waitFor(
        (r) => r.todayStatus == DayStatus.protectedRecovery,
      );
      expect(after.todayStatus, DayStatus.protectedRecovery);
      expect(after.isProtectedToday, isTrue);
    },
  );

  test(
    'B5: a multi-day recovery range covering today keeps today protected '
    'and preserves the streak through the real provider chain - guards an '
    'off-by-one at the today end of the range that would silently kill the '
    'protected card',
    () async {
      final activityRepository = container.read(activityRepositoryProvider);
      final recoveryRepository = container.read(recoveryRepositoryProvider);

      await activityRepository.saveActivity(
        activity(day: today.addDays(-5), id: 'old'),
      );
      // The range runs up to and including today.
      await recoveryRepository.markRecoveryDays(today.addDays(-4), today);

      final result = await waitFor(
        (r) =>
            r.todayStatus == DayStatus.protectedRecovery &&
            r.currentStreak == 1,
      );
      expect(result.todayStatus, DayStatus.protectedRecovery);
      expect(result.currentStreak, 1);
    },
  );

  group('durationUntilNextLocalMidnight (S2)', () {
    test('a normal day is just the plain time-of-day gap to midnight', () {
      final now = DateTime(2026, 7, 15, 22, 15);
      // July is not near a DST transition in virtually any real-world
      // timezone (Northern-hemisphere transitions cluster around
      // March/November, Southern-hemisphere ones around April/October) -
      // a reliably "boring" date to assert an exact value against
      // regardless of which machine runs this test.
      expect(
        durationUntilNextLocalMidnight(now),
        const Duration(hours: 1, minutes: 45),
      );
    });

    test(
      'midnight itself is exactly 24h from the following midnight on a '
      'boring day',
      () {
        final now = DateTime(2026, 7, 15);
        expect(durationUntilNextLocalMidnight(now), const Duration(hours: 24));
      },
    );

    test('handles a month/year rollover', () {
      final now = DateTime(2026, 12, 31, 22);
      expect(durationUntilNextLocalMidnight(now), const Duration(hours: 2));
    });

    // These dates straddle known DST transitions (US 2026-03-08 /
    // 2026-11-01, UK/EU 2026-03-29 / 2026-10-25 - the same dates as
    // `local_date_test.dart`'s DST group). Rather than hard-coding "23" or
    // "25" hours (which would only be correct if this machine's local
    // timezone happens to be US or UK), the expectation is derived
    // independently from the two instants' own UTC offsets: wall-clock
    // time is always exactly 24h apart, so real elapsed time is `24h -
    // (offset at the next midnight - offset at now)`. On a host timezone
    // with no transition on that date (e.g. a CI box running in UTC), both
    // offsets are equal and this correctly reduces to a plain 24h - the
    // test is honest either way, instead of being flaky outside a US/UK
    // timezone.
    for (final date in [
      DateTime(2026, 3, 8),
      DateTime(2026, 11),
      DateTime(2026, 3, 29),
      DateTime(2026, 10, 25),
    ]) {
      test('is DST-honest across $date', () {
        final nextMidnight = DateTime(date.year, date.month, date.day + 1);
        final expected =
            const Duration(hours: 24) -
            (nextMidnight.timeZoneOffset - date.timeZoneOffset);
        expect(durationUntilNextLocalMidnight(date), expected);
      });
    }
  });
}
