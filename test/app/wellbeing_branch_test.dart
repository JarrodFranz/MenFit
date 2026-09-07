import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/app/router/router.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Covers the promotion of Wellbeing from a nested `/home/wellbeing` route
/// to its own top-level `/wellbeing` branch (see `routes.dart`).
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    // setMockInitialValues must be called exactly once per test - onboarding
    // is marked complete so the router's redirect leaves this test on the
    // main shell (router.dart).
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

    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  /// Flush Drift's stream-cleanup timers under a pump we control before the
  /// framework's own teardown (central testing-pitfalls.md).
  Future<void> settleDrift(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('/wellbeing resolves to WellbeingScreen', (tester) async {
    final container = await pumpApp(tester);

    container.read(routerProvider).go('/wellbeing');
    await tester.pumpAndSettle();

    expect(find.byType(WellbeingScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Wellbeing'),
      ),
      findsOneWidget,
    );

    await settleDrift(tester);
  });

  testWidgets(
    'selecting Wellbeing from another tab switches branches instead of '
    'stacking onto that tab',
    (tester) async {
      await pumpApp(tester);

      // Start on Home (the initial location).
      expect(find.text('Welcome back'), findsOneWidget);

      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: navigationBar,
          matching: find.text('Wellbeing'),
        ),
      );
      await tester.pumpAndSettle();

      // Landed on the Wellbeing screen, still inside the shell chrome.
      expect(find.byType(WellbeingScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Proof it's a branch switch, not a push onto Home's navigator: a
      // pushed route would leave Home underneath and get an
      // automatically-added back button. A branch root has neither - its
      // own navigator's stack contains only the branch's initial route.
      expect(find.text('Welcome back'), findsNothing);
      expect(find.byType(BackButton), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.arrow_back,
        ),
        findsNothing,
      );

      await settleDrift(tester);
    },
  );
}
