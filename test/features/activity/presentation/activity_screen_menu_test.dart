import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities => const LocationCapabilities(
    canRecordActivities: true,
  );

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => const Stream.empty();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'ActivityScreen hamburger menu renders and shows options',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 800)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appDatabaseProvider.overrideWithValue(database),
            locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Train')),
      );
      await tester.pumpAndSettle();

      // Top hamburger menu icon.
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Open the hamburger menu.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify menu options. "Exercise Hubs" is NOT one of them any more:
      // the on-screen hub tiles replaced the menu item (and the bottom
      // sheet behind it), so the only match is the section heading on the
      // screen behind the open menu.
      expect(find.text('Exercise Hubs'), findsOneWidget);
      expect(find.text('Import Garmin / GPX / FIT'), findsOneWidget);
      expect(find.text('Saved Routes'), findsOneWidget);
      expect(find.text('Fitness & Health Devices'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
