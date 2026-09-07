import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

import 'fake_health_platform_adapter.dart';

void main() {
  late db.AppDatabase database;
  late FakeHealthPlatformAdapter adapter;

  /// A container wired to an in-memory database and the fake adapter.
  ///
  /// [syncEnabled] overrides the fitness-device sync toggle, which is the
  /// user's explicit per-source permission for reading her health platform.
  /// Its real default is `false`, so every test that expects a sync to
  /// happen has to say so — which is the point.
  ProviderContainer makeContainer({bool syncEnabled = true}) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        healthPlatformAdapterProvider.overrideWithValue(adapter),
        fitnessDeviceSyncControllerProvider.overrideWithValue(syncEnabled),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<List<DailySteps>> storedRows(ProviderContainer container) {
    return container
        .read(stepsRepositoryProvider)
        .getRange(LocalDate(2000, 1, 1), LocalDate(2100, 1, 1));
  }

  /// A fixed "now" for every test in this file, and the calendar day it
  /// falls on.
  ///
  /// **Not cosmetic.** `syncRange` clamps its end to today, so a window
  /// written in literal dates means one thing when the suite runs before
  /// those dates and another when it runs after: the first version of this
  /// file asked for `2026-09-01 .. 2026-09-05` and would have passed only
  /// until the wall clock reached 2026-09-04, then silently started
  /// dropping two days. A test whose result depends on the calendar day it
  /// runs on is a flaky test.
  ///
  /// The pin is late enough that every literal window below sits wholly in
  /// the past and nothing is clamped. The clamp's own behaviour is proved
  /// in its own group, with windows written *relative* to [pinnedToday].
  final pinnedNow = DateTime(2026, 9, 10, 9);
  final pinnedToday = LocalDate(2026, 9, 10);

  /// The sync notifier with its clock pinned.
  ///
  /// The only route to the notifier in this file, deliberately: reaching it
  /// through `container.read(...)` directly would put a test back on the
  /// wall clock, which is the bug this helper exists to make unavailable.
  StepsSync syncNotifier(
    ProviderContainer container, {
    DateTime Function()? clock,
  }) {
    return container.read(stepsSyncProvider.notifier)
      ..clock = clock ?? (() => pinnedNow);
  }

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    adapter = FakeHealthPlatformAdapter();
  });

  tearDown(() async {
    await database.close();
  });

  group('syncRange', () {
    test('writes one row per day of the window', () async {
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 5));

      final rows = await storedRows(container);
      expect(rows.map((r) => r.day.toIso()), [
        '2026-09-01',
        '2026-09-02',
        '2026-09-03',
        '2026-09-04',
        '2026-09-05',
      ]);
      expect(rows.every((r) => r.steps == 8000), isTrue);
      expect(rows.first.source, 'Health Connect');
    });

    test('reports synced and records the sync time', () async {
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 2));

      final state = container.read(stepsSyncProvider);
      expect(state.lastOutcome, StepsSyncOutcome.synced);
      expect(state.lastSyncedAt, isNotNull);
      expect(state.syncing, isFalse);
    });

    test('a source the platform cannot name is stored as null', () async {
      adapter.sourceLabel = null;
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 1));

      expect((await storedRows(container)).single.source, isNull);
    });
  });

  group('the platform cannot answer', () {
    test('an unsupported platform reports unsupported and writes '
        'nothing', () async {
      adapter.supported = false;
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 5));

      expect(
        container.read(stepsSyncProvider).lastOutcome,
        StepsSyncOutcome.unsupported,
      );
      expect(await storedRows(container), isEmpty);
      expect(adapter.rangeCallCount, 0);
      expect(
        container.read(stepsSyncProvider).lastSyncedAt,
        isNull,
        reason: 'a window that was never read is not a successful sync',
      );
    });

    test('a missing permission reports noPermission, never failure', () async {
      adapter.stepsPermissionGranted = false;
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 5));

      expect(
        container.read(stepsSyncProvider).lastOutcome,
        StepsSyncOutcome.noPermission,
        reason:
            'a user who has simply not granted access must not be told '
            'something went wrong',
      );
      expect(await storedRows(container), isEmpty);
      expect(adapter.rangeCallCount, 0);
    });

    test(
      'an adapter that throws reports failed and does not rethrow',
      () async {
        adapter.throwOnRange = true;
        final container = makeContainer();

        // No expectLater(throwsA): a background sync must never take the app
        // down, so this await simply completes.
        await syncNotifier(container)
            .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 5));

        expect(
          container.read(stepsSyncProvider).lastOutcome,
          StepsSyncOutcome.failed,
        );
        expect(await storedRows(container), isEmpty);
        expect(container.read(stepsSyncProvider).syncing, isFalse);
      },
    );

    test('a throwing permission check is a failure, not a silent '
        'success', () async {
      adapter.throwOnPermissions = true;
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 2));

      expect(
        container.read(stepsSyncProvider).lastOutcome,
        StepsSyncOutcome.failed,
      );
      expect(await storedRows(container), isEmpty);
    });

    test('a failed attempt does not move lastSyncedAt', () async {
      final container = makeContainer();
      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 1));
      final firstSuccess = container.read(stepsSyncProvider).lastSyncedAt;

      adapter.throwOnRange = true;
      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 1));

      expect(container.read(stepsSyncProvider).lastSyncedAt, firstSuccess);
      expect(
        container.read(stepsSyncProvider).lastOutcome,
        StepsSyncOutcome.failed,
      );
    });
  });

  group('the sync toggle is her permission', () {
    test('nothing is read or written while the toggle is off', () async {
      final container = makeContainer(syncEnabled: false);

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 5));
      await syncNotifier(container).syncRecent();

      expect(
        adapter.permissionCallCount,
        0,
        reason: 'her stated preference is checked before the adapter is',
      );
      expect(adapter.rangeCallCount, 0);
      expect(await storedRows(container), isEmpty);
      expect(container.read(stepsSyncProvider).lastOutcome, isNull);
    });
  });

  group('syncRecent', () {
    test('covers `days` calendar days ending today, inclusive', () async {
      final container = makeContainer();

      await syncNotifier(container).syncRecent(days: 7);

      final today = pinnedToday;
      final (start, end) = adapter.requestedWindows.single;
      expect(end, today);
      expect(start, today.addDays(-6));
      expect(await storedRows(container), hasLength(7));
    });

    test('defaults to a 35-day window', () async {
      final container = makeContainer();

      await syncNotifier(container).syncRecent();

      final (start, end) = adapter.requestedWindows.single;
      expect(start.difference(end), 34);
    });

    test('is a no-op within the throttle window', () async {
      final container = makeContainer();
      await syncNotifier(container).syncRecent(days: 3);
      expect(adapter.rangeCallCount, 1);

      await syncNotifier(container).syncRecent(days: 3);

      expect(
        adapter.rangeCallCount,
        1,
        reason:
            'a successful sync less than StepsSync.throttle ago makes the '
            'next syncRecent a no-op',
      );
    });

    test('force: true overrides the throttle', () async {
      final container = makeContainer();
      await syncNotifier(container).syncRecent(days: 3);

      await syncNotifier(container).syncRecent(days: 3, force: true);

      expect(adapter.rangeCallCount, 2);
    });

    test('a failed attempt does not arm the throttle', () async {
      adapter.throwOnRange = true;
      final container = makeContainer();
      await syncNotifier(container).syncRecent(days: 3);
      adapter.throwOnRange = false;

      await syncNotifier(container).syncRecent(days: 3);

      expect(
        adapter.rangeCallCount,
        2,
        reason: 'the throttle measures from the last success, not the last try',
      );
      expect(
        container.read(stepsSyncProvider).lastOutcome,
        StepsSyncOutcome.synced,
      );
    });

    test("today's row is re-upserted, never duplicated, as the day "
        'accrues', () async {
      final container = makeContainer();
      final today = pinnedToday;

      adapter.stepsPerDay = 3000;
      await syncNotifier(container).syncRecent(days: 3);
      adapter.stepsPerDay = 9100;
      await syncNotifier(container).syncRecent(days: 3, force: true);

      final rows = await storedRows(container);
      expect(rows, hasLength(3), reason: 'one row per day, still');
      final todayRow = rows.firstWhere((r) => r.day == today);
      expect(
        todayRow.steps,
        9100,
        reason: 'the day is still accruing, so the later reading supersedes',
      );
    });

    test('a days count below 1 still syncs today rather than an '
        'inverted window', () async {
      final container = makeContainer();

      await syncNotifier(container).syncRecent(days: 0);

      final (start, end) = adapter.requestedWindows.single;
      expect(start, end);
      expect(end, pinnedToday);
    });
  });
  group('the future is never synced (ADR 013: no fabricated zero days)', () {
    test('a window ending in the future is clamped to today', () async {
      final container = makeContainer();
      final today = pinnedToday;

      await syncNotifier(container)
          .syncRange(today.addDays(-2), today.addDays(5));

      final (start, end) = adapter.requestedWindows.single;
      expect(start, today.addDays(-2));
      expect(
        end,
        today,
        reason:
            'the platform must never be asked about a day that has not '
            'happened - it may answer 0 rather than refusing',
      );
    });

    test('no row is written for any future day', () async {
      final container = makeContainer();
      final today = pinnedToday;

      await syncNotifier(container)
          .syncRange(today.addDays(-2), today.addDays(5));

      final rows = await storedRows(container);
      expect(rows, hasLength(3));
      expect(
        rows.every((r) => !r.day.isAfter(today)),
        isTrue,
        reason:
            'a zero for a day that has not occurred is the one thing '
            'ADR 013 forbids outright',
      );
      expect(rows.last.day, today);
    });

    test('a future day the adapter volunteers anyway is still not '
        'stored', () async {
      // The clamp fixes what is asked for; this covers what is stored. A
      // misbehaving platform that answers outside the requested window
      // must not be able to put a count against a day that has not
      // happened.
      final container = makeContainer();
      final today = pinnedToday;
      adapter.extraTotals = [
        DailyStepTotal(date: today.addDays(3), steps: 0),
        DailyStepTotal(date: today.addDays(1), steps: 4000),
      ];

      await syncNotifier(container).syncRange(today.addDays(-1), today);

      final rows = await storedRows(container);
      expect(rows.every((r) => !r.day.isAfter(today)), isTrue);
      expect(rows, hasLength(2));
    });

    test('a window starting after today does nothing at all', () async {
      final container = makeContainer();
      final today = pinnedToday;

      await syncNotifier(container)
          .syncRange(today.addDays(1), today.addDays(7));

      expect(adapter.rangeCallCount, 0);
      expect(
        adapter.permissionCallCount,
        0,
        reason: 'an entirely future window is dropped before the adapter',
      );
      expect(await storedRows(container), isEmpty);
    });

    test('a window ending today is passed through unchanged', () async {
      final container = makeContainer();
      final today = pinnedToday;

      await syncNotifier(container).syncRange(today.addDays(-4), today);

      final (start, end) = adapter.requestedWindows.single;
      expect(start, today.addDays(-4));
      expect(end, today);
      expect(await storedRows(container), hasLength(5));
    });
  });

  group('an energy-only grant is not a steps grant', () {
    test('reports noPermission and writes nothing', () async {
      // The real adapter's `hasPermissions` is an OR across steps and the
      // two energy types, so this configuration passes it. Gating on it
      // would show an empty chart that blames her data rather than the
      // missing grant.
      adapter = FakeHealthPlatformAdapter.energyOnly();
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 5));

      expect(
        await adapter.hasPermissions(),
        isTrue,
        reason:
            'the OR passes - which is exactly why the sync must not '
            'use it',
      );
      expect(
        container.read(stepsSyncProvider).lastOutcome,
        StepsSyncOutcome.noPermission,
      );
      expect(await storedRows(container), isEmpty);
      expect(adapter.rangeCallCount, 0);
    });

    test('the steps-specific query is the one the sync asks', () async {
      final container = makeContainer();

      await syncNotifier(container)
          .syncRange(LocalDate(2026, 9, 1), LocalDate(2026, 9, 1));

      expect(adapter.stepsPermissionCallCount, 1);
    });
  });

  group('the throttle expires', () {
    /// A clock the test moves by hand. `LocalDate.today(clock:)` reads the
    /// calendar fields off whatever this returns, and the throttle compares
    /// its UTC form, so a local `DateTime` is what the production code
    /// would see from `DateTime.now`.
    late DateTime fakeNow;
    DateTime clock() => fakeNow;

    setUp(() => fakeNow = DateTime(2026, 9, 3, 8));

    test('lets go once StepsSync.throttle has elapsed', () async {
      final container = makeContainer();
      final notifier = syncNotifier(container, clock: clock);

      await notifier.syncRecent(days: 3);
      expect(adapter.rangeCallCount, 1);

      // 59 minutes later: still suppressed.
      fakeNow = fakeNow.add(const Duration(minutes: 59));
      await notifier.syncRecent(days: 3);
      expect(adapter.rangeCallCount, 1);

      // Just past the hour: allowed, with no `force`.
      fakeNow = fakeNow.add(const Duration(minutes: 2));
      await notifier.syncRecent(days: 3);
      expect(
        adapter.rangeCallCount,
        2,
        reason:
            'without an injectable clock this direction is untestable, and '
            '"the throttle never lets go" would pass the suppression test',
      );
    });

    test('the throttle boundary is measured from the last success', () async {
      final container = makeContainer();
      final notifier = syncNotifier(container, clock: clock);

      await notifier.syncRecent(days: 3);
      fakeNow = fakeNow.add(const Duration(hours: 2));
      await notifier.syncRecent(days: 3);
      expect(adapter.rangeCallCount, 2);

      // The second success reset the window; 10 minutes on is suppressed
      // again.
      fakeNow = fakeNow.add(const Duration(minutes: 10));
      await notifier.syncRecent(days: 3);
      expect(adapter.rangeCallCount, 2);
    });

    test('the injected clock also fixes "today" and syncedAt', () async {
      final container = makeContainer();
      final notifier = syncNotifier(container, clock: clock);

      await notifier.syncRecent(days: 1);

      final (start, end) = adapter.requestedWindows.single;
      expect(start, LocalDate(2026, 9, 3));
      expect(end, LocalDate(2026, 9, 3));
      expect(
        container.read(stepsSyncProvider).lastSyncedAt,
        DateTime(2026, 9, 3, 8).toUtc(),
      );
      expect((await storedRows(container)).single.syncedAt.isUtc, isTrue);
    });
  });
}
