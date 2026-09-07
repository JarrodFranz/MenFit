import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
// `show AppDatabase`: the generated Drift row classes include their own
// `Activity`, which would collide with the domain entity this test builds
// fixtures from.
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/recaps/domain/recap_builder.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `recentRecapPeriods` offers a month only once it clears the same bar
/// `RecapBuilder` would apply when actually building that month's recap —
/// otherwise a brand-new account's Progress screen listed six rows whose
/// only possible answer was "not enough logged yet".
///
/// Dated relative to the real `LocalDate.today()` rather than a fixed
/// calendar: the provider reads today itself, so a hard-coded month would
/// stop being one of the candidate months the day after it was written.
void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  final lastMonth = mostRecentCompletedMonth(LocalDate.today());
  final monthBefore = mostRecentCompletedMonth(lastMonth.start);

  /// Saves [count] manual activities inside [period], each at local noon so
  /// the provider's local-calendar-day check can't land them either side of
  /// a timezone boundary. Days 1..count — every month has at least 28.
  Future<void> logSessions(RecapPeriod period, int count) async {
    final repo = container.read(activityRepositoryProvider);
    for (var day = 1; day <= count; day++) {
      final startedAt = DateTime(
        period.start.year,
        period.start.month,
        day,
        12,
      ).toUtc();
      await repo.saveActivity(
        Activity(
          id: EntityId.generate(),
          activityType: ActivityType.run,
          title: 'Run',
          startedAt: startedAt,
          movingTime: const Duration(minutes: 30),
          elapsedTime: const Duration(minutes: 30),
          distanceMeters: 5000,
          source: ActivitySource.manual,
          createdAt: startedAt,
          updatedAt: startedAt,
        ),
      );
    }
  }

  /// Keeps a listener on the provider for as long as the container lives:
  /// an `autoDispose` provider read with `.future` alone would be disposed
  /// the moment the read returns.
  Future<List<RecapPeriod>> read() {
    container.listen(recentRecapPeriodsProvider, (_, _) {});
    return container.read(recentRecapPeriodsProvider.future);
  }

  test('a brand-new account is offered nothing at all', () async {
    expect(await read(), isEmpty);
  });

  test("a month below the builder's session bar is not offered", () async {
    await logSessions(lastMonth, RecapBuilder.minSessionsForMonthRecap - 1);

    final periods = await read();

    expect(
      periods.where((p) => p.key == lastMonth.key),
      isEmpty,
      reason: 'that month could only ever answer "not enough logged yet"',
    );
  });

  test('a month that clears the bar is offered', () async {
    await logSessions(lastMonth, RecapBuilder.minSessionsForMonthRecap);

    final periods = await read();

    expect(periods.map((p) => p.key), contains(lastMonth.key));
  });

  test('sessions in one month do not qualify a different month', () async {
    await logSessions(lastMonth, RecapBuilder.minSessionsForMonthRecap);

    final periods = await read();

    expect(periods.map((p) => p.key), isNot(contains(monthBefore.key)));
  });

  test('the cap is unchanged: never more than recapHistoryLimit, '
      'newest-ending first', () async {
    var month = lastMonth;
    for (var i = 0; i < recapHistoryLimit; i++) {
      await logSessions(month, RecapBuilder.minSessionsForMonthRecap);
      month = mostRecentCompletedMonth(month.start);
    }

    final periods = await read();

    expect(periods, hasLength(recapHistoryLimit));
    for (var i = 1; i < periods.length; i++) {
      expect(
        periods[i].end.isAfter(periods[i - 1].end),
        isFalse,
        reason: 'sorted newest-ending first',
      );
    }
    expect(
      periods.first.key,
      lastMonth.key,
      reason: 'the most recently completed month leads the list',
    );
  });
}
