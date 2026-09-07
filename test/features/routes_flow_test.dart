import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/home/presentation/home_screen.dart';
import 'package:menfit_app/features/routes/data/drift_route_repository.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/route_suggest_screen_test.dart'
    show FakeLocationAdapter, FakeRouteSuggestionService, FakeTileProvider;

/// Tears the tree down and pumps one frame so live Drift stream timers get
/// a chance to fire and cancel, instead of being reported as pending.
///
/// Top-level, not a local closure inside [main]: it is referenced from
/// `pumpApp`'s `addTearDown`, and Dart does not hoist local functions.
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<({db.AppDatabase database, FakeRouteSuggestionService service})>
  pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1200)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    // Registered AFTER database.close so it runs BEFORE it (teardowns are
    // LIFO), and registered here rather than called at the end of each test
    // body so it runs even when a test FAILS. Without this, one failing
    // expectation leaves the tree mounted with live Drift stream timers,
    // teardown never settles, and every remaining test in the file reports
    // "did not complete" while the run hangs for minutes - which is exactly
    // what made this file wedge the whole suite.
    addTearDown(() => flushDriftTimers(tester));
    final service = FakeRouteSuggestionService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
          mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
          routeSuggestionServiceProvider.overrideWithValue(service),
          routeSuggestionsConfiguredProvider.overrideWithValue(true),
          locationAdapterProvider.overrideWithValue(FakeLocationAdapter()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return (database: database, service: service);
  }

  Future<void> settleRealAsync(WidgetTester tester) async {
    // Let UI-triggered Drift writes complete outside the fake-async zone
    // (central testing-pitfalls.md), then pump for the resulting UI.
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    // Settle exit animations (e.g. a closing dialog whose text would
    // otherwise still be findable mid-flight). Real-zone snackbar timers
    // don't block this - pending timers aren't scheduled frames.
    await tester.pumpAndSettle();
  }

  Future<void> goToRoutesScreen(WidgetTester tester) async {
    final navigationBar = find.byType(NavigationBar);
    await tester.tap(
      find.descendant(of: navigationBar, matching: find.text('Train')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Routes'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'signature flow: suggest 5 km -> three options -> pick one -> save -> '
    'it appears in the saved-routes list',
    (tester) async {
      final harness = await pumpApp(tester);

      await goToRoutesScreen(tester);
      expect(find.textContaining('No saved routes yet'), findsOneWidget);

      await tester.tap(find.text('Suggest a route'));
      await tester.pumpAndSettle();
      expect(find.text('Find routes'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Distance'),
        '5',
      );
      await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
      // flutter_map's single-tap fires after the double-tap window lapses.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();
      await tester.pump();

      expect(harness.service.requests, hasLength(1));
      expect(find.text('Option 1'), findsOneWidget);
      // Option 3 sits below the fold now that the routing disclosure shares
      // the screen with the map, and the list builds lazily - scroll to it
      // rather than asserting on whatever happens to be built. The
      // scrollable is named explicitly: the screen has more than one
      // (the map has its own), and the default picks by `.single`.
      // Option 3 sits below the fold now that the routing disclosure shares
      // the screen with the map, and the ListView builds lazily - scroll to
      // it rather than asserting on whatever happens to be built.
      //
      // Dragged from a fixed point low in the 500x1200 viewport, but ABOVE
      // the shell's bottom NavigationBar (~80px) - and deliberately not via
      // `scrollUntilVisible` or a plain `drag` on the ListView, both of
      // which start from its centre, which is the FlutterMap: the map
      // swallows the gesture as a pan instead of scrolling the page.
      for (var i = 0; i < 12 && find.text('Option 3').evaluate().isEmpty; i++) {
        await tester.dragFrom(const Offset(250, 1000), const Offset(0, -300));
        await tester.pump();
      }
      expect(find.text('Option 3'), findsOneWidget);

      // Pick the second option, save it under its default name.
      await tester.ensureVisible(find.text('Option 2'));
      await tester.tap(find.text('Option 2'));
      await tester.pump();
      await tester.ensureVisible(find.text('Save route'));
      await tester.tap(find.text('Save route'));
      await tester.pumpAndSettle();

      // Name dialog, prefilled with the unit-aware default.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('5.1 km Run loop'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Save'),
        ),
      );
      await settleRealAsync(tester);

      // Saved - snackbar confirms; dismiss it deterministically (its
      // auto-dismiss timer lives in the real zone - testing-pitfalls.md).
      expect(find.text('Route saved'), findsOneWidget);
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
          .clearSnackBars();
      await tester.pump();

      // Exactly one row persisted, geometry encoded.
      final rows = await harness.database.select(harness.database.routes).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, '5.1 km Run loop');
      expect(rows.single.activityType, 'run');
      expect(rows.single.distanceMeters, 5100);

      // Back on the routes list, the saved route shows.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('5.1 km Run loop'), findsOneWidget);
      expect(find.textContaining('5.10 km'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'route detail: stats + map, rename, start-with-route chip on the '
    'record screen',
    (tester) async {
      final harness = await pumpApp(tester);
      final now = DateTime.utc(2026, 8, 27, 8);
      await DriftRouteRepository(harness.database).saveRoute(
        SavedRoute(
          id: 'route-1',
          name: 'River loop',
          activityType: ActivityType.run,
          distanceMeters: 5100,
          points: const [
            GeoPoint(latitude: 51.5074, longitude: -0.1278),
            GeoPoint(latitude: 51.51, longitude: -0.12),
            GeoPoint(latitude: 51.5074, longitude: -0.1278),
          ],
          source: RouteSource.suggested,
          estimatedDuration: const Duration(minutes: 31),
          ascentMeters: 41,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await goToRoutesScreen(tester);
      await tester.tap(find.text('River loop'));
      await tester.pumpAndSettle();

      expect(find.text('River loop'), findsOneWidget);
      expect(find.textContaining('5.10 km'), findsOneWidget);
      expect(find.text('31:00'), findsOneWidget);
      expect(find.text('41 m'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);

      // Rename.
      await tester.tap(find.byTooltip('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Hill loop',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Save'),
        ),
      );
      await settleRealAsync(tester);
      expect(find.text('Hill loop'), findsOneWidget);
      expect(find.text('River loop'), findsNothing);

      // Start run (android test platform -> recording capable): lands on
      // the record pre-start view with the Following chip.
      await tester.tap(find.text('Start run'));
      await tester.pumpAndSettle();
      expect(find.text('Following: Hill loop'), findsOneWidget);
      expect(find.text('Start recording'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets('route detail: delete (confirmed) returns to an empty list', (
    tester,
  ) async {
    final harness = await pumpApp(tester);
    final now = DateTime.utc(2026, 8, 27, 8);
    await DriftRouteRepository(harness.database).saveRoute(
      SavedRoute(
        id: 'route-1',
        name: 'River loop',
        activityType: ActivityType.walk,
        distanceMeters: 3000,
        points: const [GeoPoint(latitude: 51.5, longitude: -0.12)],
        source: RouteSource.suggested,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await goToRoutesScreen(tester);
    await tester.tap(find.text('River loop'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this route?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await settleRealAsync(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('No saved routes yet'), findsOneWidget);
    // Soft delete: the row is kept, only hidden.
    final rows = await harness.database.select(harness.database.routes).get();
    expect(rows.single.deletedAt, isNotNull);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'activity detail shows a tappable "Route:" chip when the activity was '
    'started from a route',
    (tester) async {
      final harness = await pumpApp(tester);
      final now = DateTime.utc(2026, 8, 27, 8);
      await DriftRouteRepository(harness.database).saveRoute(
        SavedRoute(
          id: 'route-1',
          name: 'River loop',
          activityType: ActivityType.run,
          distanceMeters: 5100,
          points: const [GeoPoint(latitude: 51.5, longitude: -0.12)],
          source: RouteSource.suggested,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await DriftActivityRepository(harness.database).saveActivity(
        Activity(
          id: EntityId.generate(),
          activityType: ActivityType.run,
          title: 'Route run',
          startedAt: now,
          movingTime: const Duration(minutes: 30),
          elapsedTime: const Duration(minutes: 30),
          distanceMeters: 5100,
          source: ActivitySource.manual,
          routeId: 'route-1',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Train')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Route run'));
      await tester.pumpAndSettle();

      expect(find.text('Route: River loop'), findsOneWidget);

      // Tapping the chip lands on the route's detail screen.
      await tester.tap(find.text('Route: River loop'));
      await tester.pumpAndSettle();
      expect(find.text('River loop'), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'home screen -> Record GPS Run -> Suggest Route works without '
    'GlobalKey error',
    (tester) async {
      await pumpApp(tester);

      // Pushed from the Home tab's own BuildContext, which is exactly what
      // this test guards: `/activity/record` is a ROOT-level route, and
      // pushing one from inside a shell branch is what used to raise the
      // `GlobalKey<NavigatorState>#root` duplication error. It used to get
      // here by tapping Home's "Record GPS Run" quick-launch card; that
      // card was removed in the 2026-09-03 dashboard redesign (Record now
      // lives on the Activity tab), so the push is made directly rather
      // than through a tile that no longer exists. The branch it is pushed
      // from - Home - is unchanged, and that is the part under test.
      final homeContext = tester.element(find.byType(HomeScreen));
      unawaited(const ActivityRecordRouteData().push<void>(homeContext));
      await tester.pumpAndSettle();

      // On RecordScreen pre-start view, tap Suggest Route
      expect(find.text('Suggest Route'), findsOneWidget);
      await tester.tap(find.text('Suggest Route'));
      await tester.pumpAndSettle();

      // Suggest a route screen should be visible
      expect(find.text('Suggest a route'), findsOneWidget);
      expect(find.text('Find routes'), findsOneWidget);

      // Pop back to RecordScreen
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Record'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );
}
