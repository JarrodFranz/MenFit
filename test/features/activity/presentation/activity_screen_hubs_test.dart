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
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/presentation/activity_screen.dart';
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

/// The Activity tab's restructured top section: type tiles that open the
/// matching hub in one tap, with Record and Log Previous underneath and no
/// floating Record button duplicating them.
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<Widget> scoped(Widget child) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
        locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
      ],
      child: child,
    );
  }

  /// Pumps the real app and lands on the Activity tab, so a tile tap goes
  /// through the real router.
  Future<void> pumpActivityTab(
    WidgetTester tester, {
    Size surface = const Size(500, 900),
  }) async {
    tester.view
      ..physicalSize = surface
      ..devicePixelRatio = 1;

    await tester.pumpWidget(await scoped(const App()));
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    await tester.tap(
      find.descendant(of: navigationBar, matching: find.text('Train')),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps the screen on its own — no shell, no navigation bar — which is
  /// what a layout guard at a narrow width wants to measure.
  Future<void> pumpActivityScreen(
    WidgetTester tester, {
    required Size surface,
  }) async {
    tester.view
      ..physicalSize = surface
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      await scoped(
        MaterialApp(
          theme: AppTheme.light(),
          home: const ActivityScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("a type tile opens that type's hub in one tap", (tester) async {
    await pumpActivityTab(tester);

    // The tooltip disambiguates the tile from the same-named filter chip
    // further down the screen.
    await tester.tap(find.byTooltip('Open Run hub'));
    await tester.pumpAndSettle();

    expect(find.text('Run Hub'), findsOneWidget);
    expect(find.text('Run Overview'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('each tile carries its own type through to the hub', (
    tester,
  ) async {
    await pumpActivityTab(tester);

    await tester.tap(find.byTooltip('Open Strength hub'));
    await tester.pumpAndSettle();

    expect(find.text('Strength Hub'), findsOneWidget);
    expect(find.text('Run Hub'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'Record and Log Previous sit under the hubs, with no floating Record',
    (tester) async {
      await pumpActivityTab(tester);

      expect(find.text('Exercise Hubs'), findsWidgets);
      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Log Previous'), findsOneWidget);

      // The old "Focused Tools" card strip is gone, and with it the second
      // set of hub entry points ("Running", "Walking", "Cycling"...).
      expect(find.text('Focused Tools'), findsNothing);
      expect(find.text('Running'), findsNothing);
      expect(find.text('Walking'), findsNothing);

      // Record is a fixed button now, so nothing floats over At a Glance.
      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('top section lays out at 320dp with 150% text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final errors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = errors.add;

    try {
      await pumpActivityScreen(tester, surface: const Size(320, 800));

      expect(find.text('Exercise Hubs'), findsOneWidget);
      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Log Previous'), findsOneWidget);
    } finally {
      FlutterError.onError = previousOnError;
    }

    expect(
      errors.map((e) => e.exceptionAsString()).toList(),
      isEmpty,
      reason:
          'the Exercise Hubs row and the Record / Log Previous pair must lay '
          'out at the narrowest supported width and the largest text scale',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
