import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/routes/domain/country_map_center.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

void main() {
  group('MapCameraTarget', () {
    test('value equality, hashCode, and toString', () {
      const target1 = MapCameraTarget(
        latitude: -25.2744,
        longitude: 133.7751,
        zoom: 4,
      );
      const target2 = MapCameraTarget(
        latitude: -25.2744,
        longitude: 133.7751,
        zoom: 4,
      );
      const target3 = MapCameraTarget(
        latitude: 51.5074,
        longitude: -0.1278,
        zoom: 14,
      );

      expect(target1, equals(target2));
      expect(target1.hashCode, equals(target2.hashCode));
      expect(target1, isNot(equals(target3)));
      expect(
        target1.toString(),
        equals('MapCameraTarget(lat: -25.2744, lng: 133.7751, zoom: 4.0)'),
      );
    });

    test('conversions to and from GeoPoint', () {
      const point = GeoPoint(latitude: -33.8688, longitude: 151.2093);
      final target = MapCameraTarget.fromPoint(point, zoom: 13.5);

      expect(target.latitude, equals(-33.8688));
      expect(target.longitude, equals(151.2093));
      expect(target.zoom, equals(13.5));
      expect(target.toGeoPoint(), equals(point));
    });
  });

  group('countryMapCenterFor', () {
    test('defaults to Australia when countryCode is null', () {
      final target = countryMapCenterFor(null);
      expect(target.latitude, closeTo(-25.2744, 0.001));
      expect(target.longitude, closeTo(133.7751, 0.001));
      expect(target.zoom, equals(4));
    });

    test('maps AU and lowercase au to Australia', () {
      final upper = countryMapCenterFor('AU');
      final lower = countryMapCenterFor('au');
      expect(upper, equals(lower));
      expect(upper.latitude, closeTo(-25.2744, 0.001));
      expect(upper.longitude, closeTo(133.7751, 0.001));
      expect(upper.zoom, equals(4));
    });

    test('maps major countries accurately', () {
      final nz = countryMapCenterFor('NZ');
      expect(nz.latitude, closeTo(-40.9006, 0.001));
      expect(nz.longitude, closeTo(174.8860, 0.001));
      expect(nz.zoom, equals(5));

      final gb = countryMapCenterFor('GB');
      final uk = countryMapCenterFor('UK');
      expect(gb, equals(uk));
      expect(gb.latitude, closeTo(54.5, 0.001));
      expect(gb.longitude, closeTo(-2.5, 0.001));

      final us = countryMapCenterFor('US');
      expect(us.latitude, closeTo(39.8283, 0.001));
      expect(us.longitude, closeTo(-98.5795, 0.001));

      final ca = countryMapCenterFor('CA');
      expect(ca.latitude, closeTo(56.1304, 0.001));
      expect(ca.longitude, closeTo(-106.3468, 0.001));

      final de = countryMapCenterFor('DE');
      expect(de.latitude, closeTo(51.1657, 0.001));
    });

    test('falls back to Australia on unrecognised country code', () {
      final fallback = countryMapCenterFor('ZZ');
      expect(fallback.latitude, closeTo(-25.2744, 0.001));
      expect(fallback.longitude, closeTo(133.7751, 0.001));
      expect(fallback.zoom, equals(4));
    });
  });
}
