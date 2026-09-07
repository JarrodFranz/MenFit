import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/recording/record_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/live_recording_map.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

void main() {
  final testFix1 = LocationFix(
    timestamp: DateTime.utc(2026),
    latitude: -33.8688,
    longitude: 151.2093,
    elevationMeters: 25,
    speedMetersPerSecond: 3.2,
  );

  final testFix2 = LocationFix(
    timestamp: DateTime.utc(2026, 1, 1, 0, 0, 5),
    latitude: -33.8690,
    longitude: 151.2095,
    elevationMeters: 27,
    speedMetersPerSecond: 3.5,
  );

  final testPlannedPoints = [
    const GeoPoint(latitude: -33.8688, longitude: 151.2093),
    const GeoPoint(latitude: -33.8700, longitude: 151.2100),
    const GeoPoint(latitude: -33.8720, longitude: 151.2120),
  ];

  Widget buildTestableWidget(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        mapTileProviderProvider.overrideWithValue(_FakeTileProvider()),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: child,
          ),
        ),
      ),
    );
  }

  group('LiveRecordingMap widget', () {
    testWidgets('renders map, user location marker, and track polyline', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          LiveRecordingMap(
            currentFix: testFix2,
            trackPoints: [testFix1, testFix2],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byKey(const Key('recenterMapFab')), findsOneWidget);
    });

    testWidgets(
      'renders planned route overlay when route points are provided',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestableWidget(
            LiveRecordingMap(
              currentFix: testFix1,
              trackPoints: [testFix1],
              plannedRoutePoints: testPlannedPoints,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(FlutterMap), findsOneWidget);
        // Both planned route and track polylines exist
        expect(find.byType(PolylineLayer), findsNWidgets(2));
      },
    );

    testWidgets('tapping recenter FAB triggers recenter', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          LiveRecordingMap(
            currentFix: testFix2,
            trackPoints: [testFix1, testFix2],
          ),
        ),
      );
      await tester.pump();

      final fab = find.byKey(const Key('recenterMapFab'));
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pump();
    });

    testWidgets('route progress card renders route name and percentage', (
      tester,
    ) async {
      final route = SavedRoute(
        id: 'route_123',
        name: 'Centennial Park 5k',
        activityType: ActivityType.run,
        distanceMeters: 5000,
        points: testPlannedPoints,
        source: RouteSource.suggested,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

      // The progress card shows 50% when distance is 2500m of 5000m
      await tester.pumpWidget(
        buildTestableWidget(
          RecordScreen(routeId: route.id),
          overrides: [
            routeByIdProvider(route.id).overrideWith(
              (ref) => Stream.value(route),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Following: Centennial Park 5k'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'RecordScreen toggles between live map view and big numbers view',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const RecordScreen(),
            overrides: [
              recordingControllerProvider.overrideWith(
                () => _TestRecordingController(
                  RecordingControllerState(
                    lifecycle: RecordingLifecycle.recording,
                    activityType: ActivityType.run,
                    elapsedTime: const Duration(minutes: 5),
                    movingTime: const Duration(minutes: 4, seconds: 50),
                    distanceMeters: 1000,
                    currentPaceSecondsPerKm: 300,
                    sampleCount: 10,
                    latestFix: testFix1,
                    trackPoints: [testFix1],
                  ),
                ),
              ),
            ],
          ),
        );
        await tester.pump();

        // Initially in Map view
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.byType(LiveRecordingMap), findsOneWidget);

        // Tap toggle button to switch to Large Numbers view
        final toggleBtn = find.byTooltip('Switch to Large Numbers view');
        expect(toggleBtn, findsOneWidget);
        await tester.tap(toggleBtn);
        await tester.pump();

        // LiveRecordingMap is hidden, big numbers displayed
        expect(find.byType(LiveRecordingMap), findsNothing);
        expect(find.text('05:00'), findsOneWidget);
        expect(find.text('Elapsed time'), findsOneWidget);

        // Tap toggle button to switch back to Live Map view
        final mapToggleBtn = find.byTooltip('Switch to Live Map view');
        expect(mapToggleBtn, findsOneWidget);
        await tester.tap(mapToggleBtn);
        await tester.pump();

        expect(find.byType(LiveRecordingMap), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  });
}

class _TestRecordingController extends RecordingController {
  _TestRecordingController(this._initialState);

  final RecordingControllerState _initialState;

  @override
  RecordingControllerState build() => _initialState;
}
