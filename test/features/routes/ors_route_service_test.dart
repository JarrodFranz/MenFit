import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/data/ors_route_service.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_suggestion_service.dart';
import 'package:menfit_app/features/routes/domain/suggested_route.dart';

/// Scripted [HttpClientAdapter]: every request is recorded, and the
/// response (or thrown [DioException]) is produced by [onRequest]. NO real
/// network I/O anywhere in this file - dio never gets past this adapter.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.onRequest);

  final Future<ResponseBody> Function(
    RequestOptions options,
    Map<String, dynamic> body,
  )
  onRequest;

  final List<RequestOptions> requests = [];
  final List<Map<String, dynamic>> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = options.data as Map<String, dynamic>;
    bodies.add(body);
    return onRequest(options, body);
  }

  @override
  void close({bool force = false}) {}
}

/// A canned ORS GeoJSON round-trip response (shape verified against the
/// live API docs - see `ors_route_service.dart`'s class doc).
String _geoJson({
  required double distance,
  double? duration,
  double? ascent,
  double? descent,
  List<List<double>>? coordinates,
}) {
  return jsonEncode({
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'properties': {
          'summary': {
            'distance': distance,
            'duration': ?duration,
            'ascent': ?ascent,
            'descent': ?descent,
          },
        },
        'geometry': {
          'type': 'LineString',
          'coordinates':
              coordinates ??
              [
                [-0.1278, 51.5074, 12.0],
                [-0.1265, 51.5085, 15.5],
                [-0.1278, 51.5074, 12.0],
              ],
        },
      },
    ],
    'bbox': [-0.1278, 51.5074, -0.1265, 51.5085],
  });
}

ResponseBody _jsonResponse(String body, {int status = 200}) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  const start = GeoPoint(latitude: 51.5074, longitude: -0.1278);

  (OrsRouteService, _ScriptedAdapter) buildService(
    Future<ResponseBody> Function(RequestOptions, Map<String, dynamic>)
    onRequest, {
    String apiKey = 'test-key',
  }) {
    final adapter = _ScriptedAdapter(onRequest);
    final dio = Dio()..httpClientAdapter = adapter;
    return (OrsRouteService(dio: dio, apiKey: apiKey), adapter);
  }

  test(
    'happy path: parses coordinates (lon/lat swapped), distance, duration, '
    'ascent/descent exactly, one request per suggestion with distinct '
    'seeds',
    () async {
      final (service, adapter) = buildService(
        (options, body) async => _jsonResponse(
          _geoJson(
            distance: 5123.4,
            duration: 3690.6,
            ascent: 42.5,
            descent: 41.9,
          ),
        ),
      );

      final routes = await service.suggestRoundTrips(
        start: start,
        targetMeters: 5000,
        activityType: ActivityType.run,
      );

      expect(routes, hasLength(3));
      final route = routes.first;
      expect(route.distanceMeters, 5123.4);
      expect(route.estimatedDuration, const Duration(seconds: 3691));
      expect(route.ascentMeters, 42.5);
      expect(route.descentMeters, 41.9);
      // GeoJSON positions are [lon, lat, ele] - the parser must swap.
      expect(route.points, hasLength(3));
      expect(route.points.first.latitude, 51.5074);
      expect(route.points.first.longitude, -0.1278);
      expect(route.points[1].latitude, 51.5085);
      expect(route.points[1].longitude, -0.1265);

      expect(adapter.requests.length, greaterThanOrEqualTo(3));
      for (final options in adapter.requests) {
        expect(options.method, 'POST');
        expect(
          options.uri.toString(),
          'https://api.openrouteservice.org/v2/directions/foot-walking/geojson',
        );
        expect(options.headers['Authorization'], 'test-key');
      }
      // Asserted as a whole map: seeds vary across requests
      expect(adapter.bodies.first, {
        'coordinates': [
          [-0.1278, 51.5074],
        ],
        'options': {
          'round_trip': {'length': 5000.0, 'points': 5, 'seed': 0},
        },
        'elevation': true,
      });
    },
  );

  test('a summary without duration parses with a null duration', () async {
    final (service, _) = buildService(
      (options, body) async => _jsonResponse(
        _geoJson(
          distance: 4800,
          coordinates: [
            [-0.1278, 51.5074],
            [-0.1265, 51.5085],
          ],
        ),
      ),
    );

    final routes = await service.suggestRoundTrips(
      start: start,
      targetMeters: 5000,
      activityType: ActivityType.run,
      count: 1,
    );

    expect(routes.single.distanceMeters, 4800);
    expect(routes.single.estimatedDuration, isNull);
    // 2D positions: nothing stated and nothing to derive from.
    expect(routes.single.ascentMeters, isNull);
    expect(routes.single.descentMeters, isNull);
  });

  group('elevation the provider does not summarise', () {
    // MEASURED against the live API on 2026-08-28: a round trip's summary
    // carries only `distance` and `duration`, even with `elevation: true`.
    // The elevation is present per-position, and used to be thrown away, so
    // every suggested route reported no climb whatsoever.
    Future<SuggestedRoute> routeFor(List<List<double>> coordinates) async {
      final (service, _) = buildService(
        (options, body) async => _jsonResponse(
          _geoJson(distance: 4800, coordinates: coordinates),
        ),
      );
      final routes = await service.suggestRoundTrips(
        start: start,
        targetMeters: 5000,
        activityType: ActivityType.run,
        count: 1,
      );
      return routes.single;
    }

    test('is derived from the geometry when the summary omits it', () async {
      final route = await routeFor([
        [-0.1278, 51.5074, 10],
        [-0.1265, 51.5085, 30],
        [-0.1270, 51.5090, 15],
        [-0.1278, 51.5074, 10],
      ]);

      // Up 20, then down 20 across two steps, back to the start.
      expect(route.ascentMeters, 20);
      expect(route.descentMeters, 20);
    });

    test('a stated summary still wins over the derived figure', () async {
      final (service, _) = buildService(
        (options, body) async => _jsonResponse(
          _geoJson(distance: 4800, ascent: 42.5, descent: 41.9),
        ),
      );

      final routes = await service.suggestRoundTrips(
        start: start,
        targetMeters: 5000,
        activityType: ActivityType.run,
        count: 1,
      );

      // The default fixture's own geometry would derive 3.5/3.5.
      expect(routes.single.ascentMeters, 42.5);
      expect(routes.single.descentMeters, 41.9);
    });

    test(
      'terrain-model wobble does not become hundreds of metres of climb',
      () async {
        // A genuinely flat towpath, sampled with +-1 m of noise. Summing every
        // consecutive rise would invent ~6 m of climb over these few points and
        // far more over a real 379-point route; hysteresis reports none.
        final route = await routeFor([
          for (final (i, ele) in [10.0, 11.0, 10.2, 11.1, 10.0, 10.8].indexed)
            [-0.1278 + i * 0.001, 51.5074, ele],
        ]);

        expect(route.ascentMeters, 0);
        expect(route.descentMeters, 0);
      },
    );

    test('a real climb larger than the threshold is still counted', () async {
      final route = await routeFor([
        [-0.1278, 51.5074, 100],
        [-0.1268, 51.5080, 102.5],
        [-0.1258, 51.5086, 105],
      ]);

      expect(route.ascentMeters, 5);
      expect(route.descentMeters, 0);
    });

    test('a single position yields no figures rather than zero', () async {
      final route = await routeFor([
        [-0.1278, 51.5074, 10],
      ]);

      // Nothing to compare against: "we do not know" is not "flat".
      expect(route.ascentMeters, isNull);
      expect(route.descentMeters, isNull);
    });
  });

  group('profile mapping per ActivityType', () {
    for (final (type, profile) in [
      (ActivityType.run, 'foot-walking'),
      (ActivityType.walk, 'foot-walking'),
      (ActivityType.hike, 'foot-hiking'),
      (ActivityType.ride, 'cycling-regular'),
    ]) {
      test('$type -> $profile', () async {
        final (service, adapter) = buildService(
          (options, body) async => _jsonResponse(_geoJson(distance: 5000)),
        );
        await service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: type,
          count: 1,
        );
        expect(
          adapter.requests.single.uri.path,
          '/v2/directions/$profile/geojson',
        );
      });
    }
  });

  group('failures', () {
    test('HTTP 4xx on every attempt -> NetworkException, static '
        'message', () async {
      final (service, _) = buildService(
        (options, body) async =>
            _jsonResponse('{"error": "unauthorized"}', status: 401),
      );

      await expectLater(
        service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Route service returned HTTP 401',
          ),
        ),
      );
    });

    test('HTTP 5xx -> NetworkException', () async {
      final (service, _) = buildService(
        (options, body) async => _jsonResponse('{}', status: 500),
      );

      await expectLater(
        service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
          count: 1,
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Route service returned HTTP 500',
          ),
        ),
      );
    });

    test('timeout -> NetworkException with the static timeout '
        'message', () async {
      final (service, _) = buildService(
        (options, body) async => throw DioException.connectionTimeout(
          requestOptions: options,
          timeout: const Duration(seconds: 10),
        ),
      );

      await expectLater(
        service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Route service request timed out',
          ),
        ),
      );
    });

    test('exception messages never leak coordinates or the API key', () async {
      final (service, _) = buildService(
        (options, body) async => _jsonResponse('{}', status: 500),
      );

      try {
        await service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
          count: 1,
        );
        fail('expected a NetworkException');
      } on NetworkException catch (e) {
        expect(e.message, isNot(contains('51.5')));
        expect(e.message, isNot(contains('0.1278')));
        expect(e.message, isNot(contains('test-key')));
        expect(e.toString(), isNot(contains('51.5')));
        expect(e.toString(), isNot(contains('test-key')));
      }
    });

    test('unexpected response shape -> NetworkException', () async {
      final (service, _) = buildService(
        (options, body) async => _jsonResponse('{"features": []}'),
      );

      await expectLater(
        service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
          count: 1,
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('partial failure: some seeds fail, the successes are still '
        'returned', () async {
      var call = 0;
      final (service, _) = buildService((options, body) async {
        call++;
        if (call == 2 || call == 4) return _jsonResponse('{}', status: 500);
        return _jsonResponse(_geoJson(distance: 5000));
      });

      final routes = await service.suggestRoundTrips(
        start: start,
        targetMeters: 5000,
        activityType: ActivityType.run,
      );
      expect(routes, hasLength(2));
    });
  });

  test('the advertised bound is the one actually enforced', () async {
    final (service, adapter) = buildService(
      (options, body) async => _jsonResponse(_geoJson(distance: 5000)),
    );

    // Presentation validates against `maxTargetMeters` before sending a
    // start point anywhere, so the two must not drift apart.
    expect(service.maxTargetMeters, 100 * 1000);
    await service.suggestRoundTrips(
      start: start,
      targetMeters: service.maxTargetMeters,
      activityType: ActivityType.run,
      count: 1,
    );
    expect(adapter.requests, hasLength(1));

    await expectLater(
      service.suggestRoundTrips(
        start: start,
        targetMeters: service.maxTargetMeters + 1,
        activityType: ActivityType.run,
        count: 1,
      ),
      throwsA(isA<ValidationException>()),
    );
    expect(adapter.requests, hasLength(1), reason: 'no second request');
  });

  group('input validation (no request made)', () {
    test('missing API key -> ValidationException with the dedicated '
        'message key, WITHOUT any request', () async {
      final (service, adapter) = buildService(
        (options, body) async => fail('must not hit the network'),
        apiKey: '',
      );

      await expectLater(
        service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.userMessageKey,
            'userMessageKey',
            'error.routes.apiKeyMissing',
          ),
        ),
      );
      expect(adapter.requests, isEmpty);
    });

    for (final target in [0.0, -5.0, double.nan, 150 * 1000.0]) {
      test('target $target m -> ValidationException, no request', () async {
        final (service, adapter) = buildService(
          (options, body) async => fail('must not hit the network'),
        );

        await expectLater(
          service.suggestRoundTrips(
            start: start,
            targetMeters: target,
            activityType: ActivityType.run,
          ),
          throwsA(isA<ValidationException>()),
        );
        expect(adapter.requests, isEmpty);
      });
    }
  });

  group('adaptive waypoints, out-and-back shapes, and proximity ranking', () {
    test(
      'short targets (<= 3.5 km) request 3 waypoints for triangle loops',
      () async {
        final (service, adapter) = buildService(
          (options, body) async => _jsonResponse(_geoJson(distance: 3050)),
        );

        await service.suggestRoundTrips(
          start: start,
          targetMeters: 3000,
          activityType: ActivityType.run,
          count: 1,
        );

        final body = adapter.bodies.single;
        final options = body['options'] as Map<String, dynamic>;
        final roundTrip = options['round_trip'] as Map<String, dynamic>;
        expect(roundTrip['points'], 3);
      },
    );

    test(
      'out-and-back generates a closed round-trip with doubled distance/duration',
      () async {
        final (service, adapter) = buildService(
          (options, body) async => _jsonResponse(
            _geoJson(
              distance: 1500,
              duration: 600,
              ascent: 10,
              descent: 5,
              coordinates: [
                [-0.1278, 51.5074, 10.0],
                [-0.1265, 51.5085, 20.0],
              ],
            ),
          ),
        );

        final routes = await service.suggestRoundTrips(
          start: start,
          targetMeters: 3000,
          activityType: ActivityType.run,
          shapePreference: RouteShapePreference.outAndBack,
          count: 1,
        );

        expect(routes, hasLength(1));
        final route = routes.single;
        expect(route.distanceMeters, 3000);
        expect(route.estimatedDuration, const Duration(seconds: 1200));
        // Outward ascent 10 + return ascent 5 = 15
        expect(route.ascentMeters, 15);
        // Outward descent 5 + return descent 10 = 15
        expect(route.descentMeters, 15);
        // Closed loop: outward + return
        expect(route.points.first, route.points.last);
        expect(adapter.requests.single.method, 'POST');
      },
    );

    test(
      'proximity ranking discards 7km+ outliers when close 3km match exists',
      () async {
        var call = 0;
        final (service, _) = buildService((options, body) async {
          call++;
          if (call == 1) {
            return _jsonResponse(_geoJson(distance: 3100)); // 3.3% error
          } else if (call == 2 || call >= 4) {
            return _jsonResponse(
              _geoJson(distance: 7400),
            ); // 146% error (outlier)
          } else {
            return _jsonResponse(_geoJson(distance: 3200)); // 6.6% error
          }
        });

        final routes = await service.suggestRoundTrips(
          start: start,
          targetMeters: 3000,
          activityType: ActivityType.run,
        );

        // The 7400m outlier was filtered out because close matches existed
        expect(routes.length, 2);
        expect(routes[0].distanceMeters, 3100);
        expect(routes[1].distanceMeters, 3200);
      },
    );

    test(
      'loop shape filters out routes with high backtracking/spurs in favor of clean loops',
      () async {
        // Option 1: Loop with a 400m dead-end spur that doubles back on itself
        final spurCoordinates = [
          [-0.1278, 51.5074, 10.0],
          [-0.1200, 51.5074, 10.0],
          [-0.1200, 51.5120, 10.0], // Spur out
          [-0.1200, 51.5074, 10.0], // Spur back
          [-0.1200, 51.5000, 10.0],
          [-0.1278, 51.5000, 10.0],
          [-0.1278, 51.5074, 10.0],
        ];
        // Option 2: Clean polygon loop with 0% backtracking
        final cleanCoordinates = [
          [-0.1278, 51.5074, 10.0],
          [-0.1200, 51.5074, 10.0],
          [-0.1200, 51.5000, 10.0],
          [-0.1278, 51.5000, 10.0],
          [-0.1278, 51.5074, 10.0],
        ];

        var call = 0;
        final (service, _) = buildService((options, body) async {
          call++;
          if (call == 1) {
            // First returned is loop with spur (5020m)
            return _jsonResponse(
              _geoJson(distance: 5020, coordinates: spurCoordinates),
            );
          } else {
            // Second returned is clean loop (5050m)
            return _jsonResponse(
              _geoJson(distance: 5050, coordinates: cleanCoordinates),
            );
          }
        });

        final routes = await service.suggestRoundTrips(
          start: start,
          targetMeters: 5000,
          activityType: ActivityType.run,
        );

        // Clean loop should be prioritized over the spur route
        expect(routes.first.distanceMeters, 5050);
      },
    );
  });
}
