import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression guard for the `.first`-snapshot deadlock — the recaps half of
/// `test/features/insights/insight_observations_provider_test.dart`, whose
/// dartdoc explains the mechanism in full.
///
/// Both providers here used to read `watchActivities()`/`watchRecords()`/
/// `watchRecentCheckins()` as `.first` snapshots, which never resolve while
/// a widget test is only pumping the `FakeAsync` clock and strand Drift's
/// database-opening lock when they don't.
void main() {
  Future<void> pumpAFew(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('recentRecapPeriods resolves under FakeAsync alone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    final subscription = container.listen(
      recentRecapPeriodsProvider,
      (previous, next) {},
    );

    await pumpAFew(tester);

    expect(subscription.read(), isA<AsyncData<List<RecapPeriod>>>());

    container.dispose();
    await database.close();
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('recapForPeriod resolves under FakeAsync alone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    final period = mostRecentCompletedMonth(LocalDate(2026, 7, 15));
    final subscription = container.listen(
      recapForPeriodProvider(period),
      (previous, next) {},
    );

    await pumpAFew(tester);

    // An empty database trips `RecapBuilder`'s sparse-data guard, so the
    // value is `null` - what matters is that it is a *value* at all.
    expect(subscription.read(), isA<AsyncData<MonthRecap?>>());

    container.dispose();
    await database.close();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
