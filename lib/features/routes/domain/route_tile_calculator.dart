import 'dart:math' as math;

import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:meta/meta.dart';

/// A Slippy Map tile coordinate at zoom level [z].
@immutable
class TileCoordinate {
  const TileCoordinate({
    required this.z,
    required this.x,
    required this.y,
  });

  final int z;
  final int x;
  final int y;

  /// Unique path identifier `{z}/{x}/{y}`.
  String get key => '$z/$x/$y';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileCoordinate && other.z == z && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(z, x, y);

  @override
  String toString() => 'TileCoordinate(z: $z, x: $x, y: $y)';
}

/// Pure functions for Slippy Map / Web Mercator coordinate calculations.
class RouteTileCalculator {
  const RouteTileCalculator._();

  /// Converts a WGS84 [lat] and [lon] to a [TileCoordinate] at [zoom].
  static TileCoordinate latLonToTile(double lat, double lon, int zoom) {
    assert(zoom >= 0 && zoom <= 22, 'Zoom level must be between 0 and 22');
    final n = math.pow(2, zoom).toDouble();
    final clampedLon = lon.clamp(-180.0, 180.0);
    // Clamp latitude to Web Mercator limits (~85.0511 degrees).
    final clampedLat = lat.clamp(-85.05112878, 85.05112878);

    final x = ((clampedLon + 180.0) / 360.0 * n).floor().clamp(
      0,
      n.toInt() - 1,
    );

    final latRad = clampedLat * math.pi / 180.0;
    final logTerm =
        math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi;
    final y = ((1.0 - logTerm) / 2.0 * n).floor().clamp(0, n.toInt() - 1);

    return TileCoordinate(z: zoom, x: x, y: y);
  }

  /// Converts tile coordinates [x], [y] at [zoom] to the top-left WGS84
  /// latitude and longitude.
  static (double lat, double lon) tileToLatLon(int x, int y, int zoom) {
    final n = math.pow(2, zoom).toDouble();
    final lon = (x / n) * 360.0 - 180.0;
    final latRad = math.atan(_sinh(math.pi * (1.0 - 2.0 * y / n)));
    final lat = latRad * 180.0 / math.pi;
    return (lat, lon);
  }

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2.0;

  /// Computes the complete deduplicated set of map tile coordinates along
  /// [points] for zoom levels from [minZoom] through [maxZoom], padded by
  /// [margin] tiles in every direction.
  static Set<TileCoordinate> computeRouteCorridorTiles(
    List<GeoPoint> points, {
    int minZoom = 12,
    int maxZoom = 16,
    int margin = 1,
  }) {
    if (points.isEmpty) return const {};

    final tiles = <TileCoordinate>{};

    for (var z = minZoom; z <= maxZoom; z++) {
      final maxIndex = math.pow(2, z).toInt() - 1;

      // Sample along each segment so wide polyline spans don't miss tiles.
      for (var i = 0; i < points.length; i++) {
        final p1 = points[i];
        final p2 = i < points.length - 1 ? points[i + 1] : points[i];

        final distanceApproxMeters = _approxDistanceMeters(
          p1.latitude,
          p1.longitude,
          p2.latitude,
          p2.longitude,
        );

        // At zoom 16, one tile is ~600m. Step every ~150m along segments.
        final steps = math.max(1, (distanceApproxMeters / 150.0).ceil());

        for (var step = 0; step <= steps; step++) {
          final fraction = step / steps;
          final lat = p1.latitude + (p2.latitude - p1.latitude) * fraction;
          final lon = p1.longitude + (p2.longitude - p1.longitude) * fraction;

          final centerTile = latLonToTile(lat, lon, z);

          for (var dx = -margin; dx <= margin; dx++) {
            for (var dy = -margin; dy <= margin; dy++) {
              final x = (centerTile.x + dx).clamp(0, maxIndex);
              final y = (centerTile.y + dy).clamp(0, maxIndex);
              tiles.add(TileCoordinate(z: z, x: x, y: y));
            }
          }
        }
      }
    }

    return tiles;
  }

  /// Approximate distance in meters between two lat/lon coordinates.
  static double _approxDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final lat1Rad = lat1 * math.pi / 180.0;
    final lat2Rad = lat2 * math.pi / 180.0;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1Rad) *
            math.cos(lat2Rad);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Estimates the total download size in bytes for [tileCount] raster tiles.
  /// Standard raster PNG/JPG tiles average ~22 KB each.
  static int estimateSizeBytes(int tileCount) => tileCount * 22 * 1024;
}
