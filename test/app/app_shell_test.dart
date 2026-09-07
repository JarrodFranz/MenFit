import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
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
    'app pumps, shows the home screen and all 5 destinations, and '
    'navigating to Settings shows the theme selector',
    (tester) async {
      // Force a compact width so navigation renders as a bottom
      // NavigationBar, independent of the default test surface size.
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      // setMockInitialValues must be called exactly once per test - a
      // second call silently resets the in-memory backing store. Onboarding
      // is marked complete so the router's redirect (router.dart) leaves
      // this test on the main shell instead of sending it to /onboarding.
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Home screen is visible by default.
      expect(find.text('Welcome back'), findsOneWidget);

      // All 5 shell destinations are present in the bottom NavigationBar.
      // (Scoped to the NavigationBar because some labels, e.g. "Nutrition",
      // also appear as home-screen dashboard card titles.)
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      for (final label in [
        'Home',
        'Train',
        'Nutrition',
        'Recovery',
        'Settings',
      ]) {
        expect(
          find.descendant(of: navigationBar, matching: find.text(label)),
          findsOneWidget,
        );
      }

      // Navigating to Settings shows the working theme-mode selector.
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Settings')),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(SegmentedButton<ThemeMode>),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    },
  );

  testWidgets(
    'shell renders all 5 destination labels with no overflow at compact '
    '(375x812) and expanded (1200x900) window sizes',
    (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      const expectedLabels = [
        'Home',
        'Train',
        'Nutrition',
        'Recovery',
        'Settings',
      ];

      // Build the widget tree once and just resize the view for each
      // check below - a second `pumpWidget` would build a second `App`
      // (and a second `AppDatabase`) over the same providers rather than
      // resizing the existing one.
      tester.view
        ..physicalSize = const Size(375, 812)
        ..devicePixelRatio = 1;

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

      // Compact: a 375dp-wide phone, five destinations in a bottom
      // NavigationBar - the tight end of the supported range.
      expect(tester.takeException(), isNull);

      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);
      for (final label in expectedLabels) {
        expect(
          find.descendant(of: navigationBar, matching: find.text(label)),
          findsOneWidget,
        );
      }

      // Expanded: a NavigationRail instead, with room to spare.
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final navigationRail = find.byType(NavigationRail);
      expect(navigationRail, findsOneWidget);
      for (final label in expectedLabels) {
        expect(
          find.descendant(of: navigationRail, matching: find.text(label)),
          findsOneWidget,
        );
      }

      // Flush Drift's stream-cleanup timers under a pump we control before
      // the framework's own teardown (central testing-pitfalls.md).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
