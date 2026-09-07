import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

/// Camera target (center coordinates and zoom level) for map views.
@immutable
class MapCameraTarget {
  const MapCameraTarget({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  MapCameraTarget.fromPoint(GeoPoint point, {required this.zoom})
    : latitude = point.latitude,
      longitude = point.longitude;

  final double latitude;
  final double longitude;
  final double zoom;

  GeoPoint toGeoPoint() => GeoPoint(latitude: latitude, longitude: longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapCameraTarget &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          zoom == other.zoom;

  @override
  int get hashCode => Object.hash(latitude, longitude, zoom);

  @override
  String toString() =>
      'MapCameraTarget(lat: $latitude, lng: $longitude, zoom: $zoom)';
}

/// Returns the central coordinates and country-scale zoom for an ISO 3166-1
/// alpha-2 [countryCode].
///
/// Defaults to Australia if [countryCode] is null or unrecognised.
MapCameraTarget countryMapCenterFor(String? countryCode) {
  if (countryCode == null) {
    return const MapCameraTarget(
      latitude: -25.2744,
      longitude: 133.7751,
      zoom: 4,
    );
  }

  return switch (countryCode.toUpperCase()) {
    'AU' => const MapCameraTarget(
      latitude: -25.2744,
      longitude: 133.7751,
      zoom: 4,
    ),
    'NZ' => const MapCameraTarget(
      latitude: -40.9006,
      longitude: 174.8860,
      zoom: 5,
    ),
    'GB' || 'UK' => const MapCameraTarget(
      latitude: 54.5,
      longitude: -2.5,
      zoom: 5.2,
    ),
    'US' => const MapCameraTarget(
      latitude: 39.8283,
      longitude: -98.5795,
      zoom: 4,
    ),
    'CA' => const MapCameraTarget(
      latitude: 56.1304,
      longitude: -106.3468,
      zoom: 3.5,
    ),
    'IE' => const MapCameraTarget(
      latitude: 53.4129,
      longitude: -8.2439,
      zoom: 6.2,
    ),
    'ZA' => const MapCameraTarget(
      latitude: -30.5595,
      longitude: 22.9375,
      zoom: 5,
    ),
    'DE' => const MapCameraTarget(
      latitude: 51.1657,
      longitude: 10.4515,
      zoom: 5.5,
    ),
    'FR' => const MapCameraTarget(
      latitude: 46.2276,
      longitude: 2.2137,
      zoom: 5.5,
    ),
    'IT' => const MapCameraTarget(
      latitude: 41.8719,
      longitude: 12.5674,
      zoom: 5.5,
    ),
    'ES' => const MapCameraTarget(
      latitude: 40.4637,
      longitude: -3.7492,
      zoom: 5.5,
    ),
    'NL' => const MapCameraTarget(
      latitude: 52.1326,
      longitude: 5.2913,
      zoom: 6.8,
    ),
    'BE' => const MapCameraTarget(
      latitude: 50.5039,
      longitude: 4.4699,
      zoom: 7,
    ),
    'CH' => const MapCameraTarget(
      latitude: 46.8182,
      longitude: 8.2275,
      zoom: 7,
    ),
    'AT' => const MapCameraTarget(
      latitude: 47.5162,
      longitude: 14.5501,
      zoom: 6.5,
    ),
    'SE' => const MapCameraTarget(
      latitude: 60.1282,
      longitude: 18.6435,
      zoom: 4.5,
    ),
    'NO' => const MapCameraTarget(
      latitude: 60.4720,
      longitude: 8.4689,
      zoom: 4.5,
    ),
    'DK' => const MapCameraTarget(
      latitude: 56.2639,
      longitude: 9.5018,
      zoom: 6.5,
    ),
    'FI' => const MapCameraTarget(
      latitude: 61.9241,
      longitude: 25.7482,
      zoom: 4.8,
    ),
    'PL' => const MapCameraTarget(
      latitude: 51.9194,
      longitude: 19.1451,
      zoom: 5.8,
    ),
    'PT' => const MapCameraTarget(
      latitude: 39.3999,
      longitude: -8.2245,
      zoom: 6.2,
    ),
    'GR' => const MapCameraTarget(
      latitude: 39.0742,
      longitude: 21.8243,
      zoom: 6,
    ),
    'JP' => const MapCameraTarget(
      latitude: 36.2048,
      longitude: 138.2529,
      zoom: 5,
    ),
    'SG' => const MapCameraTarget(
      latitude: 1.3521,
      longitude: 103.8198,
      zoom: 11,
    ),
    'IN' => const MapCameraTarget(
      latitude: 20.5937,
      longitude: 78.9629,
      zoom: 4.5,
    ),
    'BR' => const MapCameraTarget(
      latitude: -14.2350,
      longitude: -51.9253,
      zoom: 3.8,
    ),
    'MX' => const MapCameraTarget(
      latitude: 23.6345,
      longitude: -102.5528,
      zoom: 4.8,
    ),
    _ => const MapCameraTarget(
      latitude: -25.2744,
      longitude: 133.7751,
      zoom: 4,
    ),
  };
}
