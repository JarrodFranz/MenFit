import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/data/route_tile_cache_service.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/presentation/widgets/route_offline_card.dart';
import 'package:menfit_app/features/routes/route_cache_providers.dart';

void main() {
  final testRoute = SavedRoute(
    id: 'route-test-1',
    name: 'Ridge Trail',
    activityType: ActivityType.run,
    distanceMeters: 4500,
    points: const [
      GeoPoint(latitude: 51.5074, longitude: -0.1278),
      GeoPoint(latitude: 51.5150, longitude: -0.1200),
    ],
    source: RouteSource.suggested,
    createdAt: DateTime.utc(2026, 8),
    updatedAt: DateTime.utc(2026, 8),
  );

  Widget host(
    SavedRoute route, {
    RouteCacheMetadata? metadata,
    Map<String, RouteTileDownloadProgress> downloads = const {},
  }) {
    return ProviderScope(
      overrides: [
        routeCacheMetadataProvider(route.id).overrideWithValue(metadata),
        routeTileDownloadControllerProvider.overrideWith(
          () => _FakeDownloadController(downloads),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: RouteOfflineCard(route: route),
          ),
        ),
      ),
    );
  }

  testWidgets('renders not-cached state with download button', (tester) async {
    await tester.pumpWidget(host(testRoute));
    await tester.pumpAndSettle();

    expect(find.text('Offline trail map'), findsOneWidget);
    expect(find.text('Download for offline'), findsOneWidget);
  });

  testWidgets('renders cached state with badge and tile details', (
    tester,
  ) async {
    final meta = RouteCacheMetadata(
      routeId: testRoute.id,
      tileCount: 45,
      sizeBytes: 1048576, // 1.0 MB
      downloadedAt: DateTime.utc(2026, 8, 2),
    );

    await tester.pumpWidget(host(testRoute, metadata: meta));
    await tester.pumpAndSettle();

    expect(find.text('Offline map ready'), findsOneWidget);
    expect(find.text('Cached'), findsOneWidget);
    expect(find.text('45 tiles · 1.0 MB'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('renders downloading progress state', (tester) async {
    final progress = RouteTileDownloadProgress(
      routeId: testRoute.id,
      totalTiles: 100,
      downloadedTiles: 45,
      status: RouteTileDownloadStatus.inProgress,
    );

    await tester.pumpWidget(
      host(
        testRoute,
        downloads: {testRoute.id: progress},
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Downloading 45 of 100 tiles (45%)'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}

class _FakeDownloadController extends RouteTileDownloadController {
  _FakeDownloadController(this._initial);

  final Map<String, RouteTileDownloadProgress> _initial;

  @override
  Map<String, RouteTileDownloadProgress> build() => _initial;
}
