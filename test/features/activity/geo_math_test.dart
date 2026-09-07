import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';

void main() {
  group('haversineDistanceMeters', () {
    test('same point is zero distance', () {
      expect(haversineDistanceMeters(51.5074, -0.1278, 51.5074, -0.1278), 0);
    });

    test('0.001 degree of latitude is ~111.19m', () {
      final distance = haversineDistanceMeters(0, 0, 0.001, 0);
      expect(distance, closeTo(111.19, 0.1));
    });

    test('Paris to London is ~343.5km', () {
      // Paris: 48.8566N, 2.3522E. London: 51.5074N, -0.1278E.
      final distanceKm =
          haversineDistanceMeters(48.8566, 2.3522, 51.5074, -0.1278) / 1000;
      expect(distanceKm, closeTo(343.5, 2));
    });

    test('is symmetric', () {
      final forward = haversineDistanceMeters(
        48.8566,
        2.3522,
        51.5074,
        -0.1278,
      );
      final backward = haversineDistanceMeters(
        51.5074,
        -0.1278,
        48.8566,
        2.3522,
      );
      expect(forward, closeTo(backward, 0.001));
    });
  });

  group('initialBearingDegrees and angleDifferenceDegrees', () {
    test('due North is 0 degrees', () {
      final bearing = initialBearingDegrees(
        startLatitude: 0,
        startLongitude: 0,
        endLatitude: 1,
        endLongitude: 0,
      );
      expect(bearing, closeTo(0, 0.1));
    });

    test('due East is 90 degrees', () {
      final bearing = initialBearingDegrees(
        startLatitude: 0,
        startLongitude: 0,
        endLatitude: 0,
        endLongitude: 1,
      );
      expect(bearing, closeTo(90, 0.1));
    });

    test('angleDifferenceDegrees calculates shortest angular difference', () {
      expect(angleDifferenceDegrees(0, 180), 180);
      expect(angleDifferenceDegrees(10, 350), 20);
      expect(angleDifferenceDegrees(90, 270), 180);
      expect(angleDifferenceDegrees(45, 90), 45);
    });
  });

  group('distancePointToSegmentMeters', () {
    test('point on segment has ~0 distance', () {
      final dist = distancePointToSegmentMeters(
        pointLat: 0.5,
        pointLon: 0,
        segStartLat: 0,
        segStartLon: 0,
        segEndLat: 1,
        segEndLon: 0,
      );
      expect(dist, closeTo(0, 1));
    });

    test('perpendicular distance away from line', () {
      // 0.001 deg lon at equator is ~111.19m
      final dist = distancePointToSegmentMeters(
        pointLat: 0.5,
        pointLon: 0.001,
        segStartLat: 0,
        segStartLon: 0,
        segEndLat: 1,
        segEndLon: 0,
      );
      expect(dist, closeTo(111.19, 1));
    });
  });
}
