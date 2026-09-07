import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/routes/data/location_search_service.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

void main() {
  group('LocationSearchService', () {
    test('short or empty queries return empty list', () async {
      final dio = Dio();
      final service = LocationSearchService(dio: dio, apiKey: 'test-key');

      expect(await service.search(''), isEmpty);
      expect(await service.search('a'), isEmpty);
      expect(await service.search('  '), isEmpty);
    });

    test('parses direct coordinate pair without network request', () async {
      final dio = Dio();
      final service = LocationSearchService(dio: dio, apiKey: '');

      final results = await service.search('-33.8688, 151.2093');
      expect(results.length, 1);
      expect(
        results.first.point,
        const GeoPoint(latitude: -33.8688, longitude: 151.2093),
      );
      expect(results.first.name, contains('-33.8688'));
    });

    test('parses OpenRouteService autocomplete GeoJSON features', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeOrsAdapter({
          'features': [
            {
              'geometry': {
                'coordinates': [151.2400, -33.8915],
              },
              'properties': {
                'name': 'Bondi Beach',
                'label': 'Bondi Beach, Sydney, Australia',
              },
            },
            {
              'geometry': {
                'coordinates': [151.2333, -33.8970],
              },
              'properties': {
                'name': 'Centennial Park',
                'label': 'Centennial Park, NSW, Australia',
              },
            },
          ],
        });

      final service = LocationSearchService(
        dio: dio,
        apiKey: 'test-key',
      );

      final results = await service.search('Bondi');
      expect(results.length, 2);
      expect(results[0].name, 'Bondi Beach');
      expect(results[0].point.latitude, -33.8915);
      expect(results[0].point.longitude, 151.2400);
      expect(results[0].secondaryText, 'Bondi Beach, Sydney, Australia');

      expect(results[1].name, 'Centennial Park');
      expect(results[1].point.latitude, -33.8970);
    });

    test('falls back to Nominatim when ORS returns empty or fails', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeNominatimAdapter([
          {
            'lat': '-37.8136',
            'lon': '144.9631',
            'name': 'Melbourne',
            'display_name': 'Melbourne, Victoria, Australia',
          },
        ]);

      final service = LocationSearchService(
        dio: dio,
        apiKey: '', // Empty key triggers Nominatim
      );

      final results = await service.search('Melbourne');
      expect(results.length, 1);
      expect(results.first.name, 'Melbourne');
      expect(results.first.point.latitude, -37.8136);
      expect(results.first.point.longitude, 144.9631);
      expect(results.first.secondaryText, 'Melbourne, Victoria, Australia');
    });

    test('ranks results closest to proximity point first '
        '(suburb > state > country)', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeNominatimAdapter([
          {
            'lat': '-38.3585',
            'lon': '141.6177',
            'name': 'Portland',
            'display_name':
                '27, Silvester Street, Portland, Victoria, 3305, Australia',
            'address': {
              'house_number': '27',
              'road': 'Silvester Street',
              'town': 'Portland',
              'state': 'Victoria',
              'country': 'Australia',
            },
          },
          {
            'lat': '-27.2280',
            'lon': '153.1110',
            'name': 'Redcliffe',
            'display_name':
                '27, Silvester Street, Redcliffe, '
                'Queensland, 4020, Australia',
            'address': {
              'house_number': '27',
              'road': 'Silvester Street',
              'suburb': 'Redcliffe',
              'state': 'Queensland',
              'country': 'Australia',
            },
          },
          {
            'lat': '43.8827',
            'lon': '-79.0078',
            'name': 'Ajax',
            'display_name': '27, Silvester Street, Ajax, Ontario, Canada',
            'address': {
              'house_number': '27',
              'road': 'Silvester Street',
              'city': 'Ajax',
              'state': 'Ontario',
              'country': 'Canada',
            },
          },
        ]);

      final service = LocationSearchService(dio: dio, apiKey: '');

      // User searching from Brisbane / Redcliffe QLD (-27.23, 153.11)
      final results = await service.search(
        '27 Silvester street',
        proximity: const GeoPoint(latitude: -27.23, longitude: 153.11),
      );

      expect(results.length, 3);
      // Redcliffe QLD (local suburb, ~1km away) must be first
      expect(results[0].name, '27 Silvester Street');
      expect(results[0].secondaryText, 'Redcliffe, Queensland, Australia');
      expect(results[0].point.latitude, -27.2280);

      // Portland VIC (interstate, ~1600km away) must be second
      expect(results[1].name, '27 Silvester Street');
      expect(results[1].secondaryText, 'Portland, Victoria, Australia');
      expect(results[1].point.latitude, -38.3585);

      // Ajax Canada (international, ~15000km away) must be last
      expect(results[2].name, '27 Silvester Street');
      expect(results[2].secondaryText, 'Ajax, Ontario, Canada');
      expect(results[2].point.latitude, 43.8827);
    });
  });
}

class _FakeOrsAdapter implements HttpClientAdapter {
  _FakeOrsAdapter(this.jsonMap);
  final Map<String, dynamic> jsonMap;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = utf8.encode(jsonEncode(jsonMap));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeNominatimAdapter implements HttpClientAdapter {
  _FakeNominatimAdapter(this.jsonList);
  final List<dynamic> jsonList;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = utf8.encode(jsonEncode(jsonList));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
