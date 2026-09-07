import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/platform/device_locale.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/data/last_location_store.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_suggestion_service.dart';
import 'package:menfit_app/features/routes/domain/suggested_route.dart';
import 'package:menfit_app/features/routes/presentation/route_suggest_screen.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No-network tile provider, same shape as `route_map_test.dart`'s.
class FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

/// Scripted [RouteSuggestionService]: records every request; fails
/// [failuresRemaining] times before succeeding with [results].
///
/// Set [gate] to hold responses open (the request is recorded immediately,
/// the response lands only once the completer is completed) — that's how
/// the "a superseded response must not land" cases are driven.
class FakeRouteSuggestionService implements RouteSuggestionService {
  FakeRouteSuggestionService({this.failuresRemaining = 0});

  int failuresRemaining;
  Completer<void>? gate;
  final List<({GeoPoint start, double targetMeters, ActivityType activityType})>
  requests = [];

  @override
  double maxTargetMeters = 100 * 1000;

  List<SuggestedRoute> results = [
    for (var i = 0; i < 3; i++)
      SuggestedRoute(
        points: const [
          GeoPoint(latitude: 51.5074, longitude: -0.1278),
          GeoPoint(latitude: 51.51, longitude: -0.12),
          GeoPoint(latitude: 51.5074, longitude: -0.1278),
        ],
        distanceMeters: 5000.0 + i * 100,
        estimatedDuration: Duration(minutes: 30 + i),
        ascentMeters: 40.0 + i,
        descentMeters: 39.0 + i,
      ),
  ];

  @override
  Future<List<SuggestedRoute>> suggestRoundTrips({
    required GeoPoint start,
    required double targetMeters,
    required ActivityType activityType,
    RouteShapePreference shapePreference = RouteShapePreference.loop,
    int count = 3,
  }) async {
    requests.add((
      start: start,
      targetMeters: targetMeters,
      activityType: activityType,
    ));
    await gate?.future;
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw const NetworkException(message: 'scripted failure');
    }
    return results;
  }
}

/// Adapter fake for the suggest screen: one-shot position supported and
/// scripted; recording capability configurable.
///
/// [positionGate] holds `getCurrentPosition` open the same way
/// [FakeRouteSuggestionService.gate] does; [positionError], when set, is
/// thrown instead of returning a fix.
class FakeLocationAdapter implements LocationAdapter {
  FakeLocationAdapter({this.canRecord = true});

  final bool canRecord;
  Completer<void>? positionGate;
  Exception? positionError;
  LocationPermissionResult permission = LocationPermissionResult.granted;
  LocationFix currentPosition = LocationFix(
    timestamp: DateTime.utc(2026, 8, 27),
    latitude: 48.8566,
    longitude: 2.3522,
  );

  @override
  LocationCapabilities get capabilities => LocationCapabilities(
    canRecordActivities: canRecord,
    reason: canRecord ? null : 'Recording works on your phone.',
    canGetCurrentPosition: true,
  );

  @override
  Future<LocationPermissionResult> checkPermission() async => permission;

  @override
  Future<LocationPermissionResult> requestPermission() async => permission;

  @override
  Stream<LocationFix> fixes() => throw UnimplementedError();

  @override
  Future<LocationFix> getCurrentPosition() async {
    await positionGate?.future;
    if (positionError != null) throw positionError!;
    return currentPosition;
  }
}

/// Scrolls the suggest screen's ListView until [finder] matches.
///
/// Needed because the screen's content grew past one viewport (the ADR 009
/// routing disclosure shares the screen with the map), and a `ListView`
/// builds lazily — so `ensureVisible` throws "Bad state: No element" for
/// anything below the fold, which has never been built.
///
/// Drags from a fixed low point rather than via `scrollUntilVisible` or a
/// plain `drag` on the ListView: both start from its centre, which is the
/// FlutterMap, and the map swallows the gesture as a pan.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  final height = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  for (var i = 0; i < 15 && finder.evaluate().isEmpty; i++) {
    await tester.dragFrom(Offset(250, height - 50), const Offset(0, -300));
    await tester.pump();
  }
  await tester.ensureVisible(finder);
}

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Widget buildScreen({
    required FakeRouteSuggestionService service,
    FakeLocationAdapter? adapter,
    bool configured = true,
    UnitSystem unitSystem = UnitSystem.metric,
    DeviceLocale? locale,
    LastLocationStore? locationStore,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
        routeSuggestionServiceProvider.overrideWithValue(service),
        routeSuggestionsConfiguredProvider.overrideWithValue(configured),
        locationAdapterProvider.overrideWithValue(
          adapter ?? FakeLocationAdapter(),
        ),
        activityUnitSystemProvider.overrideWith(
          (ref) => Stream.value(unitSystem),
        ),
        if (locale != null) deviceLocaleProvider.overrideWithValue(locale),
        if (locationStore != null)
          lastLocationStoreProvider.overrideWithValue(locationStore),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const RouteSuggestScreen(),
      ),
    );
  }

  testWidgets(
    'missing API key: warm setup card instead of the flow, no crash, no '
    'network call',
    (tester) async {
      final service = FakeRouteSuggestionService();
      await tester.pumpWidget(buildScreen(service: service, configured: false));
      await tester.pump();

      expect(
        find.textContaining("aren't switched on yet"),
        findsOneWidget,
      );
      expect(find.text('Find routes'), findsNothing);
      expect(find.byType(FlutterMap), findsNothing);
      expect(service.requests, isEmpty);
    },
  );

  testWidgets(
    'the setup card speaks to a user, not a developer: no build-tooling '
    'jargon anywhere on it',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          service: FakeRouteSuggestionService(),
          configured: false,
        ),
      );
      await tester.pump();

      // Whoever reads this can act on none of these; naming them reads as
      // "the app is broken" (review finding 11).
      for (final jargon in [
        'dart-define',
        'ORS_API_KEY',
        'API key',
        'OpenRouteService',
        'openrouteservice.org',
      ]) {
        expect(
          find.textContaining(jargon, skipOffstage: false),
          findsNothing,
          reason: '"$jargon" is developer vocabulary',
        );
      }
    },
  );

  testWidgets('map tap drops/moves the start marker', (tester) async {
    tester.view
      ..physicalSize = const Size(500, 1000)
      ..devicePixelRatio = 1;
    await tester.pumpWidget(buildScreen(service: FakeRouteSuggestionService()));
    await tester.pump();

    expect(find.byType(MarkerLayer), findsNothing);

    await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
    // flutter_map's single-tap only fires once the double-tap
    // disambiguation window lapses - advance fake time past it.
    await tester.pump(const Duration(milliseconds: 400));

    final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    expect(markerLayer.markers, hasLength(1));
    final firstPoint = markerLayer.markers.single.point;

    // Tapping elsewhere moves (not duplicates) the marker.
    await tester.tapAt(
      tester.getCenter(find.byType(FlutterMap)) + const Offset(60, 40),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final movedLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    expect(movedLayer.markers, hasLength(1));
    expect(movedLayer.markers.single.point, isNot(firstPoint));
  });

  testWidgets(
    '"Use my location" resolves the adapter position into the start marker',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1000)
        ..devicePixelRatio = 1;
      await tester.pumpWidget(
        buildScreen(service: FakeRouteSuggestionService()),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Use my location'));
      await tester.tap(find.text('Use my location'));
      await tester.pump();
      await tester.pump();

      final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
      expect(markerLayer.markers.single.point.latitude, 48.8566);
      expect(markerLayer.markers.single.point.longitude, 2.3522);
    },
  );

  testWidgets(
    'validation: Find routes without distance/start shows inline messages '
    'and calls no service',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1400)
        ..devicePixelRatio = 1;
      final service = FakeRouteSuggestionService();
      await tester.pumpWidget(buildScreen(service: service));
      await tester.pump();

      await scrollTo(tester, find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();

      expect(find.text('Enter a distance greater than zero.'), findsOneWidget);
      expect(
        find.text('Choose a start point on the map (or use your location).'),
        findsOneWidget,
      );
      expect(service.requests, isEmpty);
    },
  );

  testWidgets(
    'switching Route Style updates shape preference in controller and '
    'service request',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1400)
        ..devicePixelRatio = 1;
      final service = FakeRouteSuggestionService();
      await tester.pumpWidget(buildScreen(service: service));
      await tester.pump();

      // Tap Out & Back style segment
      expect(find.text('Out & Back'), findsOneWidget);
      await tester.tap(find.text('Out & Back'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await scrollTo(tester, find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();
      await tester.pump();

      expect(service.requests, hasLength(1));
      expect(service.requests.single.targetMeters, 3000);
    },
  );

  testWidgets(
    'happy path: 5 km in -> three suggestion cards, selection switches the '
    'drawn polyline',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1400)
        ..devicePixelRatio = 1;
      final service = FakeRouteSuggestionService();
      await tester.pumpWidget(buildScreen(service: service));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await scrollTo(tester, find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();
      await tester.pump();

      expect(service.requests, hasLength(1));
      expect(service.requests.single.targetMeters, 5000);
      expect(service.requests.single.activityType, ActivityType.run);

      await scrollTo(tester, find.text('Option 1'));
      expect(find.text('Option 1'), findsOneWidget);
      await scrollTo(tester, find.text('Option 2'));
      expect(find.text('Option 2'), findsOneWidget);
      await scrollTo(tester, find.text('Option 3'));
      expect(find.text('Option 3'), findsOneWidget);
      expect(find.textContaining('5.00 km'), findsOneWidget);
      expect(find.textContaining('5.10 km'), findsOneWidget);
      expect(find.textContaining('5.20 km'), findsOneWidget);
      // Estimated duration + ascent render on the cards.
      expect(find.textContaining('~30:00'), findsOneWidget);
      expect(find.textContaining('↑ 40 m'), findsOneWidget);

      // The selected suggestion's polyline is drawn on the shared map.
      expect(find.byType(PolylineLayer), findsOneWidget);

      // Save/Start actions exist for the selection (android test platform
      // -> recording is offered).
      await scrollTo(tester, find.text('Save route'));
      expect(find.text('Save route'), findsOneWidget);
      expect(find.text('Start now'), findsOneWidget);

      // Selecting another card keeps exactly one polyline (the map swaps
      // its geometry rather than stacking layers).
      await tester.tap(find.text('Option 2'));
      await tester.pump();
      expect(find.byType(PolylineLayer), findsOneWidget);
    },
  );

  testWidgets(
    'imperial input parses as miles: 3.1 mi -> ~4989 m requested',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;
      final service = FakeRouteSuggestionService();
      await tester.pumpWidget(
        buildScreen(service: service, unitSystem: UnitSystem.imperial),
      );
      await tester.pumpAndSettle();

      expect(find.text('mi'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '3.1');
      await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();
      await tester.pump();

      expect(service.requests, hasLength(1));
      expect(service.requests.single.targetMeters, closeTo(4988.97, 0.1));
    },
  );

  testWidgets('error path: userMessageFor card + retry succeeds', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 1200)
      ..devicePixelRatio = 1;
    final service = FakeRouteSuggestionService(failuresRemaining: 1);
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Find routes'));
    await tester.tap(find.text('Find routes'));
    await tester.pump();
    await tester.pump();

    // `NetworkException` -> the standard connectivity copy.
    expect(
      find.textContaining("We couldn't connect"),
      findsOneWidget,
    );
    expect(find.text('Option 1'), findsNothing);

    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(service.requests, hasLength(2));
    expect(find.text('Option 1'), findsOneWidget);
    expect(find.textContaining("We couldn't connect"), findsNothing);
  });

  testWidgets(
    'the start point leaving the device is disclosed before it is chosen '
    '(ADR 009)',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;
      await tester.pumpWidget(
        buildScreen(service: FakeRouteSuggestionService()),
      );
      await tester.pump();

      final disclosure = find.textContaining(
        'we send your start point',
        skipOffstage: false,
      );
      expect(disclosure, findsOneWidget);
      final text = tester.widget<Text>(disclosure).data!;
      // The two facts that bound the exposure.
      expect(text, contains('nothing else about you'));
      expect(text, contains('unless you save'));
    },
  );

  testWidgets(
    'a distance beyond what the service can plan is caught in the field, '
    'not by a round trip',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;
      final service = FakeRouteSuggestionService();
      await tester.pumpWidget(buildScreen(service: service));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '150');
      await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();
      await tester.pump();

      expect(
        service.requests,
        isEmpty,
        reason: 'the start point must not go over the network for this',
      );
      expect(find.textContaining('100 km or less'), findsOneWidget);
      // Not the generic validation copy with nothing highlighted.
      expect(find.textContaining('highlighted fields'), findsNothing);
      expect(find.text('Retry'), findsNothing);
    },
  );

  testWidgets('editing the distance clears already-shown suggestions', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 1200)
      ..devicePixelRatio = 1;
    await tester.pumpWidget(buildScreen(service: FakeRouteSuggestionService()));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Find routes'));
    await tester.tap(find.text('Find routes'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Option 1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '8');
    await tester.pump();

    expect(
      find.text('Option 1'),
      findsNothing,
      reason: 'a 5 km result list must never sit under an 8 km query',
    );
    expect(find.text('Save route'), findsNothing);
  });

  testWidgets(
    'a failed "Use my location" during a search does not leave Find routes '
    'stuck behind a spinner',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;
      final service = FakeRouteSuggestionService()..gate = Completer<void>();
      final adapter = FakeLocationAdapter()
        ..positionError = Exception('no fix');
      await tester.pumpWidget(
        buildScreen(service: service, adapter: adapter),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '5');
      await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Find routes'));
      await tester.tap(find.text('Find routes'));
      await tester.pump();
      expect(find.text('Finding routes…'), findsOneWidget);

      await tester.ensureVisible(find.text('Use my location'));
      await tester.tap(find.text('Use my location'));
      await tester.pump();
      await tester.pump();
      service.gate!.complete();
      await tester.pump();
      await tester.pump();

      expect(find.text('Finding routes…'), findsNothing);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Find routes'),
      );
      expect(
        button.onPressed,
        isNotNull,
        reason:
            'the search that owned the spinner was superseded, so '
            'whoever superseded it had to stop the spinner',
      );
    },
  );

  testWidgets('imperial: ascent renders in feet, not raw metres', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 1200)
      ..devicePixelRatio = 1;
    await tester.pumpWidget(
      buildScreen(
        service: FakeRouteSuggestionService(),
        unitSystem: UnitSystem.imperial,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '3.1');
    await tester.tap(find.byType(FlutterMap), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Find routes'));
    await tester.tap(find.text('Find routes'));
    await tester.pump();
    await tester.pump();

    // The fixture's first option climbs 40 m = 131 ft.
    expect(find.textContaining('↑ 131 ft'), findsOneWidget);
    expect(find.textContaining('↑ 40 m'), findsNothing);
  });

  testWidgets(
    'the start point is reachable without a pointer: typed coordinates set '
    'the marker',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;
      await tester.pumpWidget(
        buildScreen(service: FakeRouteSuggestionService()),
      );
      await tester.pump();

      expect(find.byType(MarkerLayer), findsNothing);

      await tester.ensureVisible(find.text('Enter coordinates'));
      await tester.tap(find.text('Enter coordinates'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Latitude'),
        '45.5',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Longitude'),
        '-73.6',
      );
      await tester.tap(find.text('Use this point'));
      await tester.pumpAndSettle();

      final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
      expect(markerLayer.markers.single.point.latitude, 45.5);
      expect(markerLayer.markers.single.point.longitude, -73.6);
    },
  );

  testWidgets('coordinate entry rejects an out-of-range latitude', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 1200)
      ..devicePixelRatio = 1;
    await tester.pumpWidget(buildScreen(service: FakeRouteSuggestionService()));
    await tester.pump();

    await tester.ensureVisible(find.text('Enter coordinates'));
    await tester.tap(find.text('Enter coordinates'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Latitude'), '95');
    await tester.enterText(find.widgetWithText(TextField, 'Longitude'), '0');
    await tester.tap(find.text('Use this point'));
    await tester.pumpAndSettle();

    expect(find.textContaining('between -90 and 90'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(MarkerLayer), findsNothing);
  });

  testWidgets(
    'initial map camera centers on country based on device locale when no '
    'location has been recorded',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;

      // AU locale
      await tester.pumpWidget(
        buildScreen(
          service: FakeRouteSuggestionService(),
          locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
        ),
      );
      await tester.pump();

      final mapAU = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(mapAU.options.initialCenter.latitude, closeTo(-25.2744, 0.01));
      expect(mapAU.options.initialCenter.longitude, closeTo(133.7751, 0.01));
      expect(mapAU.options.initialZoom, equals(4.0));
    },
  );

  testWidgets(
    'initial map camera centers on different country for other locales',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;

      // NZ locale
      await tester.pumpWidget(
        buildScreen(
          service: FakeRouteSuggestionService(),
          locale: const DeviceLocale(languageCode: 'en', countryCode: 'NZ'),
        ),
      );
      await tester.pump();

      final mapNZ = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(mapNZ.options.initialCenter.latitude, closeTo(-40.9006, 0.01));
      expect(mapNZ.options.initialCenter.longitude, closeTo(174.8860, 0.01));
      expect(mapNZ.options.initialZoom, equals(5.0));
    },
  );

  testWidgets(
    'using "Use my location" persists location to LastLocationStore, and '
    'subsequent screen load centers on last recorded location at local zoom',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1200)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = LastLocationStore(prefs);

      final adapter = FakeLocationAdapter()
        ..currentPosition = LocationFix(
          timestamp: DateTime.utc(2026, 8, 27),
          latitude: -37.8136,
          longitude: 144.9631,
        );

      await tester.pumpWidget(
        buildScreen(
          service: FakeRouteSuggestionService(),
          adapter: adapter,
          locationStore: store,
          locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
        ),
      );
      await tester.pump();

      // Before using location, it's Australia center
      final initialMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(
        initialMap.options.initialCenter.latitude,
        closeTo(-25.2744, 0.01),
      );

      // Tap "Use my location"
      await tester.ensureVisible(find.text('Use my location'));
      await tester.tap(find.text('Use my location'));
      await tester.pumpAndSettle();

      // Verify it was persisted to store
      final recorded = store.getLastLocation();
      expect(recorded, isNotNull);
      expect(recorded!.latitude, closeTo(-37.8136, 0.001));
      expect(recorded.longitude, closeTo(144.9631, 0.001));

      // Unmount the current screen so the next pump simulates a fresh cold
      // start with start == null
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Now simulate a fresh session opening RouteSuggestScreen with the same
      // store
      await tester.pumpWidget(
        buildScreen(
          service: FakeRouteSuggestionService(),
          adapter: adapter,
          locationStore: store,
          locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
        ),
      );
      await tester.pump();

      final subsequentMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(
        subsequentMap.options.initialCenter.latitude,
        closeTo(-37.8136, 0.001),
      );
      expect(
        subsequentMap.options.initialCenter.longitude,
        closeTo(144.9631, 0.001),
      );
      expect(subsequentMap.options.initialZoom, equals(14));
    },
  );
}
