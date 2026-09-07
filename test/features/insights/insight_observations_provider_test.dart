import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/insights_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression guard for the `.first`-snapshot deadlock.
///
/// [insightObservationsProvider] aggregates six repositories in one
/// `Future`. When it reads a stream-only repository as `watchXxx().first`,
/// those awaits never complete inside a widget test: `Stream.first`
/// resolves its future only *after* the subscription it opened has been
/// cancelled, and cancelling a Drift query stream resolves through a future
/// owned by the SDK's root zone, which is outside `flutter_test`'s
/// `FakeAsync` and so is never driven by `tester.pump`. The provider then
/// sits half-run holding Drift's database-opening lock, and
/// `AppDatabase.close()` in `tearDown` blocks on that lock forever — a
/// zero-CPU hang no per-test timeout catches, because the test *body* has
/// already finished. `test/app/app_shell_test.dart` hung on exactly this.
///
/// So this asserts the strong property: the provider reaches `AsyncData`
/// **without** the test ever escaping to the real event loop (no
/// `tester.runAsync`). Only genuine one-shot `get...` reads can do that. If
/// a `watchXxx().first` snapshot is reintroduced, this fails on
/// `AsyncLoading` instead of hanging the suite.
///
/// The database is closed inside the test body rather than in a `tearDown`:
/// on failure the close is the thing that would hang, and a hung teardown
/// is exactly the failure mode this file exists to stop.
void main() {
  testWidgets('resolves while the test only pumps the FakeAsync clock', (
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
      insightObservationsProvider,
      (previous, next) {},
    );

    // A pumped widget gives the binding a tree to drive; the provider
    // itself is observed through the container above.
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    expect(
      subscription.read(),
      isA<AsyncData<List<DailyObservation>>>(),
      reason:
          'insightObservations must complete without escaping FakeAsync - '
          "see this file's dartdoc.",
    );

    container.dispose();
    await database.close();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
