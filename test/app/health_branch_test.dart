import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/app/router/router.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/features/health/presentation/health_screen.dart';
import 'package:menfit_app/features/settings/presentation/settings_screen.dart';
import 'package:menfit_app/features/wearables/presentation/wearables_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/steps/fake_health_platform_adapter.dart';

/// Health is a shell tab; Settings left the shell and lives under Home
/// (`/home/settings`), opened from the Home app-bar gear (ADR 002
/// amendment, 2026-11-16).
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester, double width) async {
    tester.view
      ..physicalSize = Size(width, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
          healthPlatformAdapterProvider.overrideWithValue(
            FakeHealthPlatformAdapter(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  // Drift cancels its stream queries on a timer; the tree must be unmounted
  // and that timer flushed inside the test body, before the binding checks
  // for pending timers (a tearDown runs too late).
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  String pathOf(ProviderContainer container) =>
      container.read(routerProvider).routeInformationProvider.value.uri.path;

  Finder navigationAt(double width) =>
      width < 600 ? find.byType(NavigationBar) : find.byType(NavigationRail);

  int selectedIndex(WidgetTester tester, double width) => width < 600
      ? tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex
      : tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex!;

  for (final width in [400.0, 1280.0]) {
    testWidgets('tapping Health shows HealthScreen at /health at $width', (
      tester,
    ) async {
      final container = await pumpApp(tester, width);
      await tester.tap(
        find.descendant(of: navigationAt(width), matching: find.text('Health')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HealthScreen), findsOneWidget);
      expect(pathOf(container), '/health');
      expect(
        find.descendant(
          of: navigationAt(width),
          matching: find.text('Settings'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('the Home gear opens Settings at /home/settings and back '
        'returns to Home at $width', (tester) async {
      final container = await pumpApp(tester, width);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(pathOf(container), '/home/settings');
      expect(selectedIndex(tester, width), 0);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsNothing);
      expect(pathOf(container), '/home');
      expect(selectedIndex(tester, width), 0);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('a deep SettingsWearablesRouteData().go lands on Wearables '
        'with Home selected at $width', (tester) async {
      final container = await pumpApp(tester, width);
      // Start on another tab so the assertion proves the deep link moves
      // the shell back to Home rather than leaving the old tab selected.
      await tester.tap(
        find.descendant(of: navigationAt(width), matching: find.text('Keto')),
      );
      await tester.pumpAndSettle();

      const SettingsWearablesRouteData().go(
        tester.element(find.byType(Scaffold).first),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WearablesScreen), findsOneWidget);
      expect(pathOf(container), '/home/settings/wearables');
      expect(selectedIndex(tester, width), 0);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
