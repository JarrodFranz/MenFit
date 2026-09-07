import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/routes/data/last_location_store.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LastLocationStore with null SharedPreferences', () {
    test('returns null and writes are no-ops', () async {
      const store = LastLocationStore(null);
      expect(store.getLastLocation(), isNull);
      await expectLater(
        store.saveLastLocation(
          const GeoPoint(latitude: -33.8688, longitude: 151.2093),
        ),
        completes,
      );
      await expectLater(store.clear(), completes);
      expect(store.getLastLocation(), isNull);
    });
  });

  group('LastLocationStore with SharedPreferences', () {
    late SharedPreferences prefs;
    late LastLocationStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = LastLocationStore(prefs);
    });

    test('reads null initially when nothing stored', () {
      expect(store.getLastLocation(), isNull);
    });

    test('persists and retrieves location accurately', () async {
      const point = GeoPoint(latitude: -33.8688, longitude: 151.2093);
      await store.saveLastLocation(point);

      final retrieved = store.getLastLocation();
      expect(retrieved, isNotNull);
      expect(retrieved!.latitude, closeTo(-33.8688, 0.0001));
      expect(retrieved.longitude, closeTo(151.2093, 0.0001));
    });

    test('clears stored location', () async {
      const point = GeoPoint(latitude: 51.5074, longitude: -0.1278);
      await store.saveLastLocation(point);
      expect(store.getLastLocation(), isNotNull);

      await store.clear();
      expect(store.getLastLocation(), isNull);
    });

    test(
      'returns null if latitude or longitude is missing or NaN/infinite',
      () async {
        await prefs.setDouble('routes_last_location_lat', -33.8688);
        // lng missing
        expect(store.getLastLocation(), isNull);

        await prefs.setDouble('routes_last_location_lng', double.infinity);
        expect(store.getLastLocation(), isNull);
      },
    );
  });
}
