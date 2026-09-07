import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/app/router/router.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'with onboarding already complete, the app starts on home and '
    'navigating to /onboarding redirects straight back',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      // setMockInitialValues must be called exactly once per test.
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(database),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Welcome to MenFit'), findsNothing);

      // Directly navigating to /onboarding is redirected straight back.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      );
      container.read(routerProvider).go('/onboarding');
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Welcome to MenFit'), findsNothing);

      // Flush Drift's stream-cleanup timers under a pump we control before
      // the framework's own teardown (central testing-pitfalls.md).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
