import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';

void main() {
  const point = GeoPoint(latitude: 51.5074, longitude: -0.1278);

  group('toString never reveals a coordinate (S2)', () {
    test('directly', () {
      // Freezed's generated toString prints both fields; one accidental
      // '$point' in a log line or exception message is all it takes to put
      // a home-adjacent location somewhere readable later.
      expect(point.toString(), isNot(contains('51.5')));
      expect(point.toString(), isNot(contains('0.1278')));
    });

    test('through string interpolation', () {
      expect('start: $point', isNot(contains('51.5')));
    });

    test('through an exception message built by interpolation', () {
      final error = StateError('bad start point: $point');
      expect(error.toString(), isNot(contains('51.5')));
    });

    test('through a containing entity', () {
      final route = SavedRoute(
        id: 'r1',
        name: 'Loop',
        activityType: ActivityType.run,
        distanceMeters: 5000,
        points: const [point],
        source: RouteSource.suggested,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(route.toString(), isNot(contains('51.5')));
      expect(route.toString(), isNot(contains('0.1278')));
    });
  });

  test('equality and copyWith still behave as a value type', () {
    expect(
      point,
      const GeoPoint(latitude: 51.5074, longitude: -0.1278),
      reason: 'redacting toString must not disturb value semantics',
    );
    expect(point.copyWith(latitude: 0).latitude, 0);
    expect(point.copyWith(latitude: 0).longitude, -0.1278);
  });
}
