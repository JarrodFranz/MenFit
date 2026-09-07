import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_tile_calculator.dart';

void main() {
  group('RouteTileCalculator', () {
    test('latLonToTile converts known London coordinates at zoom 12', () {
      final tile = RouteTileCalculator.latLonToTile(51.5074, -0.1278, 12);
      expect(tile.z, 12);
      expect(tile.x, 2046);
      expect(tile.y, 1362);
      expect(tile.key, '12/2046/1362');
    });

    test('tileToLatLon round-trips back to the same tile coordinate', () {
      const zoom = 14;
      const origX = 8192;
      const origY = 5440;
      final (lat, lon) = RouteTileCalculator.tileToLatLon(origX, origY, zoom);
      final roundTrip = RouteTileCalculator.latLonToTile(lat, lon, zoom);

      expect(roundTrip.z, zoom);
      expect(roundTrip.x, origX);
      expect(roundTrip.y, origY);
    });

    test('computeRouteCorridorTiles returns empty set for empty route', () {
      final tiles = RouteTileCalculator.computeRouteCorridorTiles(const []);
      expect(tiles, isEmpty);
    });

    test('computeRouteCorridorTiles calculates count for single point', () {
      const point = GeoPoint(latitude: 51.5074, longitude: -0.1278);
      // For minZoom 12 to maxZoom 14 (3 levels), margin 1 = 3x3 = 9 tiles/level
      final tiles = RouteTileCalculator.computeRouteCorridorTiles(
        const [point],
        maxZoom: 14,
      );

      expect(tiles.length, 27); // 9 tiles * 3 zoom levels
    });

    test('computeRouteCorridorTiles interpolates between distant points', () {
      // 2 points ~2.5 km apart along London Embankment
      const p1 = GeoPoint(latitude: 51.5074, longitude: -0.1278);
      const p2 = GeoPoint(latitude: 51.5150, longitude: -0.0900);

      final tiles = RouteTileCalculator.computeRouteCorridorTiles(
        const [p1, p2],
        minZoom: 16,
        margin: 0,
      );

      // Interpolation along ~2.5km generates multiple intermediate tiles
      expect(tiles.length, greaterThan(3));
    });

    test(
      'computeRouteCorridorTiles deduplicates overlapping corridor tiles',
      () {
        const p1 = GeoPoint(latitude: 51.5074, longitude: -0.1278);
        const p2 = GeoPoint(latitude: 51.5080, longitude: -0.1270);

        final tiles = RouteTileCalculator.computeRouteCorridorTiles(
          const [p1, p2, p1], // Out and back loop
          minZoom: 13,
          maxZoom: 13,
        );

        // Verify all tile coordinates in the returned set are unique
        final keys = tiles.map((t) => t.key).toSet();
        expect(keys.length, tiles.length);
      },
    );

    test('estimateSizeBytes calculates accurate byte estimation', () {
      final bytes = RouteTileCalculator.estimateSizeBytes(10);
      expect(bytes, 10 * 22 * 1024);
    });

    test('TileCoordinate equality and hashCode', () {
      const t1 = TileCoordinate(z: 14, x: 100, y: 200);
      const t2 = TileCoordinate(z: 14, x: 100, y: 200);
      const t3 = TileCoordinate(z: 14, x: 101, y: 200);

      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
      expect(t1, isNot(equals(t3)));
      expect(t1.toString(), 'TileCoordinate(z: 14, x: 100, y: 200)');
    });
  });
}
