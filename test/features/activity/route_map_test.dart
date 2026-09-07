import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/presentation/widgets/route_map.dart';

/// A [TileProvider] that never touches the network: every tile resolves to
/// a 1x1 transparent PNG (flutter_map's own `TileProvider.transparentImage`
/// bytes). Every widget test that pumps a [RouteMap] (here and in
/// `activity_flow_test.dart`-style detail-screen tests) MUST override
/// [mapTileProviderProvider] with this - the real default
/// ([NetworkTileProvider]) would attempt actual HTTP requests.
class FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

List<ActivitySample> _buildSamples() {
  final base = DateTime.utc(2026, 1, 1, 8);
  return [
    for (var i = 0; i < 5; i++)
      ActivitySample(
        id: 'sample-$i',
        activityId: 'activity-1',
        timestamp: base.add(Duration(seconds: i * 10)),
        latitude: 51.500 + i * 0.001,
        longitude: -0.140 + i * 0.001,
      ),
  ];
}

void main() {
  testWidgets("renders a FlutterMap with the samples' polyline, start/end "
      'markers, and attribution', (tester) async {
    final samples = _buildSamples();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: RouteMap(samples: samples)),
        ),
      ),
    );
    // Let the map lay itself out; no real network I/O to await - the fake
    // tile provider resolves synchronously from an in-memory image.
    await tester.pump();

    expect(find.byType(FlutterMap), findsOneWidget);

    final polylineLayer = tester.widget<PolylineLayer>(
      find.byType(PolylineLayer),
    );
    expect(polylineLayer.polylines, hasLength(1));
    expect(polylineLayer.polylines.single.points, hasLength(samples.length));

    final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    expect(markerLayer.markers, hasLength(2));
    expect(markerLayer.markers[0].point.latitude, samples.first.latitude);
    expect(markerLayer.markers[1].point.latitude, samples.last.latitude);

    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
  });

  testWidgets('performs no real network I/O (fake tile provider only)', (
    tester,
  ) async {
    // Guards the test-design invariant itself: if a future change swaps in
    // the real NetworkTileProvider default, `flutter_test`'s binding throws
    // for any attempted HTTP call - this test would fail loudly rather than
    // silently hitting the network. Asserting the fake type is present is a
    // cheap, fast way to pin that no other TileProvider is in play.
    final samples = _buildSamples();
    final fakeTileProvider = FakeTileProvider();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapTileProviderProvider.overrideWithValue(fakeTileProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: RouteMap(samples: samples)),
        ),
      ),
    );
    await tester.pump();

    final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
    expect(tileLayer.tileProvider, same(fakeTileProvider));
  });
}
