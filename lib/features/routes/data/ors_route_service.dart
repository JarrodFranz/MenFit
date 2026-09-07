import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_suggestion_service.dart';
import 'package:menfit_app/features/routes/domain/suggested_route.dart';

/// [RouteSuggestionService] backed by OpenRouteService's round-trip
/// and directional directions API.
///
/// Supports:
/// - **Loop routes**: Circular routes generated via ORS round-trip API with
///   adaptive waypoint density and anti-backtracking / spur detection.
/// - **Out-and-Back routes**: Directional outward-and-return routes projected
///   at radial bearings, ensuring high distance accuracy.
/// - **Proximity Ranking & Outlier Filtering**: Probes multiple candidate
///   orientations, discards extreme distance blowouts, penalizes
///   retraced/overlapping paths, and ranks returned routes by closest match
///   to the requested target distance.
class OrsRouteService implements RouteSuggestionService {
  OrsRouteService({
    required this._dio,
    required this._apiKey,
    this._baseUrl = 'https://api.openrouteservice.org',
  });

  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  /// ORS round-trip generation degrades badly (or is rejected) for very
  /// long targets; 100 km comfortably covers every plausible run/walk/
  /// hike/ride loop this app suggests.
  @override
  double get maxTargetMeters => 100 * 1000;

  /// Waypoint count for generated loops adapted to target length.
  /// For shorter targets (<= 3.5 km), fewer waypoints (3 instead of 5)
  /// prevent tight-grid street detours from blowing out distance.
  static int _roundTripPointsFor(double targetMeters) {
    if (targetMeters <= 3500) return 3;
    return 5;
  }

  @override
  Future<List<SuggestedRoute>> suggestRoundTrips({
    required GeoPoint start,
    required double targetMeters,
    required ActivityType activityType,
    RouteShapePreference shapePreference = RouteShapePreference.loop,
    int count = 3,
  }) async {
    if (_apiKey.isEmpty) {
      throw const ValidationException(
        message: 'OpenRouteService API key is not configured',
        userMessageKey: 'error.routes.apiKeyMissing',
      );
    }
    if (!targetMeters.isFinite ||
        targetMeters <= 0 ||
        targetMeters > maxTargetMeters) {
      throw const ValidationException(
        message: 'Target distance out of supported range',
      );
    }
    if (count < 1) {
      throw const ValidationException(
        message: 'Suggestion count must be at least 1',
      );
    }

    final profile = _profileFor(activityType);
    final candidates = <SuggestedRoute>[];
    AppException? firstFailure;

    switch (shapePreference) {
      case RouteShapePreference.loop:
        await _collectLoopCandidates(
          profile: profile,
          start: start,
          targetMeters: targetMeters,
          desiredCount: count,
          candidates: candidates,
          onFailure: (e) => firstFailure ??= e,
        );
      case RouteShapePreference.outAndBack:
        await _collectOutAndBackCandidates(
          profile: profile,
          start: start,
          targetMeters: targetMeters,
          desiredCount: count,
          candidates: candidates,
          onFailure: (e) => firstFailure ??= e,
        );
      case RouteShapePreference.any:
        // Probe both loop and out-and-back, pooling the results
        await _collectLoopCandidates(
          profile: profile,
          start: start,
          targetMeters: targetMeters,
          desiredCount: count,
          candidates: candidates,
          onFailure: (e) => firstFailure ??= e,
        );
        await _collectOutAndBackCandidates(
          profile: profile,
          start: start,
          targetMeters: targetMeters,
          desiredCount: count,
          candidates: candidates,
          onFailure: (e) => firstFailure ??= e,
        );
    }

    final ranked = _rankAndFilterCandidates(
      candidates: candidates,
      targetMeters: targetMeters,
      shapePreference: shapePreference,
      maxResults: count,
    );

    if (ranked.isEmpty) {
      throw firstFailure ??
          const NetworkException(
            message: 'Route suggestion produced no routes',
          );
    }
    return ranked;
  }

  Future<void> _collectLoopCandidates({
    required String profile,
    required GeoPoint start,
    required double targetMeters,
    required int desiredCount,
    required List<SuggestedRoute> candidates,
    required void Function(AppException) onFailure,
  }) async {
    final points = _roundTripPointsFor(targetMeters);

    // Probe across multiple seeds (and complementary waypoint densities)
    // to discover clean loops without dead-end spurs.
    final probeLimit = desiredCount == 1 ? 1 : math.max(desiredCount, 4);
    final probePoints = targetMeters <= 3500
        ? [points, points, points, 4, points, 4]
        : [points, points, points, 3, 4, 3];
    final probeSeeds = [0, 1, 2, 3, 4, 5];

    for (var i = 0; i < probeSeeds.length && i < probeLimit; i++) {
      try {
        final route = await _fetchRoundTrip(
          profile: profile,
          start: start,
          targetMeters: targetMeters,
          points: probePoints[i],
          seed: probeSeeds[i],
        );
        candidates.add(route);
      } on AppException catch (failure) {
        onFailure(failure);
      }
    }
  }

  Future<void> _collectOutAndBackCandidates({
    required String profile,
    required GeoPoint start,
    required double targetMeters,
    required int desiredCount,
    required List<SuggestedRoute> candidates,
    required void Function(AppException) onFailure,
  }) async {
    // Compass bearings spaced around 360 degrees
    const allBearings = [0.0, 120.0, 240.0, 60.0, 180.0, 300.0];
    final turnDistanceMeters = (targetMeters / 2) * 0.88;

    for (final bearing in allBearings) {
      if (candidates.length >= desiredCount) break;
      try {
        final dest = destinationPoint(
          startLatitude: start.latitude,
          startLongitude: start.longitude,
          distanceMeters: turnDistanceMeters,
          bearingDegrees: bearing,
        );
        final outward = await _fetchPointToPoint(
          profile: profile,
          start: start,
          end: GeoPoint(latitude: dest.latitude, longitude: dest.longitude),
        );
        // Create closed out-and-back route
        final closedPoints = [
          ...outward.points,
          ...outward.points.reversed.skip(1),
        ];
        final totalDistance = outward.distanceMeters * 2;
        final totalDuration = outward.estimatedDuration != null
            ? outward.estimatedDuration! * 2
            : null;
        final totalAscent =
            (outward.ascentMeters ?? 0) + (outward.descentMeters ?? 0);
        final totalDescent =
            (outward.descentMeters ?? 0) + (outward.ascentMeters ?? 0);

        candidates.add(
          SuggestedRoute(
            points: closedPoints,
            distanceMeters: totalDistance,
            estimatedDuration: totalDuration,
            ascentMeters: totalAscent > 0 ? totalAscent : null,
            descentMeters: totalDescent > 0 ? totalDescent : null,
          ),
        );
      } on AppException catch (failure) {
        onFailure(failure);
      }
    }
  }

  List<SuggestedRoute> _rankAndFilterCandidates({
    required List<SuggestedRoute> candidates,
    required double targetMeters,
    required RouteShapePreference shapePreference,
    required int maxResults,
  }) {
    if (candidates.isEmpty) return const [];

    // Filter extreme distance outliers (> 40% error) when closer
    // candidates exist
    final hasCloseMatch = candidates.any(
      (r) => (r.distanceMeters - targetMeters).abs() / targetMeters <= 0.35,
    );
    final filtered = hasCloseMatch
        ? candidates
              .where(
                (r) =>
                    (r.distanceMeters - targetMeters).abs() / targetMeters <=
                    0.40,
              )
              .toList()
        : List<SuggestedRoute>.from(candidates);

    if (shapePreference == RouteShapePreference.loop) {
      // Calculate backtrack / self-overlap ratio for each candidate
      final scoredCandidates = filtered.map((r) {
        final backtrack = calculateRouteBacktrackRatio(r.points);
        final distError =
            (r.distanceMeters - targetMeters).abs() / targetMeters;
        // Composite score: heavily penalize routes with dead-end spurs / retracing
        final score = distError + (backtrack * 3.0);
        return (route: r, backtrack: backtrack, score: score);
      }).toList();

      // If we have clean loops with <= 8% backtrack, discard routes
      // with heavy backtracking (> 12%)
      final hasCleanLoop = scoredCandidates.any((sc) => sc.backtrack <= 0.08);
      final cleanScored =
          (hasCleanLoop
                ? scoredCandidates.where((sc) => sc.backtrack <= 0.12).toList()
                : scoredCandidates)
            ..sort((a, b) => a.score.compareTo(b.score));

      return cleanScored.map((sc) => sc.route).take(maxResults).toList();
    } else {
      filtered.sort((a, b) {
        final errorA = (a.distanceMeters - targetMeters).abs();
        final errorB = (b.distanceMeters - targetMeters).abs();
        return errorA.compareTo(errorB);
      });
      return filtered.take(maxResults).toList();
    }
  }

  Future<SuggestedRoute> _fetchRoundTrip({
    required String profile,
    required GeoPoint start,
    required double targetMeters,
    required int points,
    required int seed,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/v2/directions/$profile/geojson',
        data: {
          'coordinates': [
            [start.longitude, start.latitude],
          ],
          'options': {
            'round_trip': {
              'length': targetMeters,
              'points': points,
              'seed': seed,
            },
          },
          'elevation': true,
        },
        options: Options(
          headers: {
            'Authorization': _apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e, st) {
      final message = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => 'Route service request timed out',
        DioExceptionType.badResponse =>
          'Route service returned HTTP ${e.response?.statusCode}',
        _ => 'Route service request failed',
      };
      throw NetworkException(message: message, cause: e, stackTrace: st);
    }

    try {
      return _parseRoute(response.data!);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw NetworkException(
        message: 'Route service returned an unexpected response shape',
        cause: e,
        stackTrace: st,
      );
    }
  }

  Future<SuggestedRoute> _fetchPointToPoint({
    required String profile,
    required GeoPoint start,
    required GeoPoint end,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/v2/directions/$profile/geojson',
        data: {
          'coordinates': [
            [start.longitude, start.latitude],
            [end.longitude, end.latitude],
          ],
          'elevation': true,
        },
        options: Options(
          headers: {
            'Authorization': _apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e, st) {
      final message = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => 'Route service request timed out',
        DioExceptionType.badResponse =>
          'Route service returned HTTP ${e.response?.statusCode}',
        _ => 'Route service request failed',
      };
      throw NetworkException(message: message, cause: e, stackTrace: st);
    }

    try {
      return _parseRoute(response.data!);
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw NetworkException(
        message: 'Route service returned an unexpected response shape',
        cause: e,
        stackTrace: st,
      );
    }
  }

  SuggestedRoute _parseRoute(Map<String, dynamic> body) {
    final features = body['features'] as List<dynamic>;
    if (features.isEmpty) {
      throw const NetworkException(
        message: 'Route service returned no route features',
      );
    }
    final feature = features.first as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final points = [
      for (final position in coordinates.cast<List<dynamic>>())
        GeoPoint(
          latitude: (position[1] as num).toDouble(),
          longitude: (position[0] as num).toDouble(),
        ),
    ];
    if (points.isEmpty) {
      throw const NetworkException(
        message: 'Route service returned an empty geometry',
      );
    }

    final properties = feature['properties'] as Map<String, dynamic>;
    final summary = properties['summary'] as Map<String, dynamic>;
    final distance = (summary['distance'] as num).toDouble();
    final durationSeconds = (summary['duration'] as num?)?.toDouble();

    // MEASURED 2026-08-28 against the live API: a **round-trip** response's
    // summary carries only `distance` and `duration` — no `ascent`/`descent`,
    // even with `elevation: true`. (Point-to-point directions do include
    // them, which is where the earlier claim in this class's doc came from.)
    // The elevation is not missing, only unsummarised: each position comes
    // back as `[lon, lat, ele]`, and this parser used to read the first two
    // and throw the third away — so every suggested route reported no
    // climb at all, and `routes.descent_meters` (added at schema v10
    // precisely so descent stopped being discarded) could never be filled.
    //
    // So: prefer the provider's own figures when it states them, and derive
    // them from the geometry when it does not.
    final elevations = [
      for (final position in coordinates.cast<List<dynamic>>())
        if (position.length > 2) (position[2] as num).toDouble(),
    ];
    final derived = _elevationChange(elevations);
    final ascent = (summary['ascent'] as num?)?.toDouble() ?? derived?.ascent;
    final descent =
        (summary['descent'] as num?)?.toDouble() ?? derived?.descent;

    return SuggestedRoute(
      points: points,
      distanceMeters: distance,
      estimatedDuration: durationSeconds == null
          ? null
          : Duration(seconds: durationSeconds.round()),
      ascentMeters: ascent,
      descentMeters: descent,
    );
  }

  /// Total climb and total drop along [elevations], in metres, or `null` when
  /// there are too few points to say anything.
  ///
  /// Uses **hysteresis** rather than summing every consecutive delta: terrain
  /// models wobble by a metre or so between adjacent points, and naively
  /// adding every rise turns a flat towpath into hundreds of metres of
  /// "climb". Only once the run away from the last anchor exceeds
  /// [_elevationThresholdMeters] is it counted, and the anchor moves there.
  ///
  /// The trade is deliberate and worth stating: a genuine climb gentler than
  /// the threshold across its whole length is not counted, and a final
  /// partial rise below it is dropped. Under-reporting a hill slightly is the
  /// right way to be wrong here — the alternative systematically invents
  /// elevation that isn't there, on every route, and this figure is only ever
  /// shown as a rounded whole number beside a suggestion.
  ({double ascent, double descent})? _elevationChange(List<double> elevations) {
    if (elevations.length < 2) return null;

    var ascent = 0.0;
    var descent = 0.0;
    var anchor = elevations.first;
    for (final elevation in elevations.skip(1)) {
      final delta = elevation - anchor;
      if (delta >= _elevationThresholdMeters) {
        ascent += delta;
        anchor = elevation;
      } else if (delta <= -_elevationThresholdMeters) {
        descent += -delta;
        anchor = elevation;
      }
    }
    return (ascent: ascent, descent: descent);
  }

  /// How far the ground must move from the last anchor before it counts as a
  /// real change rather than terrain-model noise.
  static const double _elevationThresholdMeters = 2;

  /// ORS routing profile per activity type. Running has no dedicated ORS
  /// profile; `foot-walking` yields runnable pedestrian loops.
  String _profileFor(ActivityType activityType) => switch (activityType) {
    ActivityType.hike => 'foot-hiking',
    ActivityType.ride => 'cycling-regular',
    _ => 'foot-walking',
  };
}

/// Computes the ratio of polyline length that backtracks / retraces itself
/// along the same path (e.g. out-and-back spurs or overlaps).
/// Returns a value between 0.0 (pure clean loop with no backtracking) and
/// 1.0 (pure out-and-back route retracing 100% of itself).
double calculateRouteBacktrackRatio(
  List<GeoPoint> points, {
  double proximityThresholdMeters = 35.0,
}) {
  if (points.length < 4) return 0;

  final cumDists = <double>[0];
  var totalLength = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final d = haversineDistanceMeters(
      points[i].latitude,
      points[i].longitude,
      points[i + 1].latitude,
      points[i + 1].longitude,
    );
    totalLength += d;
    cumDists.add(totalLength);
  }

  if (totalLength < 50) return 0;

  final segments =
      <
        ({
          GeoPoint p1,
          GeoPoint p2,
          double length,
          double bearing,
          double midLat,
          double midLon,
          double routePos,
        })
      >[];

  for (var i = 0; i < points.length - 1; i++) {
    final len = cumDists[i + 1] - cumDists[i];
    if (len < 0.5) continue;
    final p1 = points[i];
    final p2 = points[i + 1];
    final bearing = initialBearingDegrees(
      startLatitude: p1.latitude,
      startLongitude: p1.longitude,
      endLatitude: p2.latitude,
      endLongitude: p2.longitude,
    );
    segments.add((
      p1: p1,
      p2: p2,
      length: len,
      bearing: bearing,
      midLat: (p1.latitude + p2.latitude) / 2.0,
      midLon: (p1.longitude + p2.longitude) / 2.0,
      routePos: cumDists[i],
    ));
  }

  final minSeparation = math.min(150, totalLength * 0.05);

  var overlappingLength = 0.0;
  for (var i = 0; i < segments.length; i++) {
    final s1 = segments[i];
    var isOverlap = false;
    for (var j = 0; j < segments.length; j++) {
      final s2 = segments[j];
      if ((s1.routePos - s2.routePos).abs() < minSeparation) continue;

      // Antiparallel bearing (>= 115 deg) means opposite direction
      if (angleDifferenceDegrees(s1.bearing, s2.bearing) >= 115.0) {
        final dist = distancePointToSegmentMeters(
          pointLat: s1.midLat,
          pointLon: s1.midLon,
          segStartLat: s2.p1.latitude,
          segStartLon: s2.p1.longitude,
          segEndLat: s2.p2.latitude,
          segEndLon: s2.p2.longitude,
        );
        if (dist <= proximityThresholdMeters) {
          isOverlap = true;
          break;
        }
      }
    }
    if (isOverlap) {
      overlappingLength += s1.length;
    }
  }

  return (overlappingLength / totalLength).clamp(0.0, 1.0);
}
