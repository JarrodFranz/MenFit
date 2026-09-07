import 'dart:math' as math;

/// Mean Earth radius in metres (spherical approximation), matching the
/// constant geolocator itself uses for `Geolocator.distanceBetween`.
const double _earthRadiusMeters = 6371000;

/// Great-circle distance between two lat/lon points, in metres, via the
/// haversine formula (https://en.wikipedia.org/wiki/Haversine_formula).
///
/// Pure function — no platform/plugin dependency — so
/// `recording_session.dart` can accumulate distance between consecutive
/// `LocationFix`es without importing anything geolocator-specific.
double haversineDistanceMeters(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  final dLat = _degToRad(endLatitude - startLatitude);
  final dLon = _degToRad(endLongitude - startLongitude);
  final lat1 = _degToRad(startLatitude);
  final lat2 = _degToRad(endLatitude);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return _earthRadiusMeters * c;
}

/// Computes the destination lat/lon coordinate from a given start point,
/// distance in metres, and initial bearing in degrees clockwise from North.
({double latitude, double longitude}) destinationPoint({
  required double startLatitude,
  required double startLongitude,
  required double distanceMeters,
  required double bearingDegrees,
}) {
  final distRatio = distanceMeters / _earthRadiusMeters;
  final bearingRad = _degToRad(bearingDegrees);
  final lat1 = _degToRad(startLatitude);
  final lon1 = _degToRad(startLongitude);

  final sinLat1 = math.sin(lat1);
  final cosLat1 = math.cos(lat1);
  final sinDist = math.sin(distRatio);
  final cosDist = math.cos(distRatio);

  final lat2 = math.asin(
    sinLat1 * cosDist + cosLat1 * sinDist * math.cos(bearingRad),
  );
  final lon2 =
      lon1 +
      math.atan2(
        math.sin(bearingRad) * sinDist * cosLat1,
        cosDist - sinLat1 * math.sin(lat2),
      );

  return (
    latitude: _radToDeg(lat2),
    longitude: _normalizeLongitude(_radToDeg(lon2)),
  );
}

double _degToRad(double degrees) => degrees * math.pi / 180;

double _radToDeg(double radians) => radians * 180 / math.pi;

double _normalizeLongitude(double lon) {
  var norm = lon;
  while (norm > 180) {
    norm -= 360;
  }
  while (norm < -180) {
    norm += 360;
  }
  return norm;
}

/// Computes the initial bearing (forward azimuth) from start to end in
/// degrees [0, 360).
double initialBearingDegrees({
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
}) {
  final lat1 = _degToRad(startLatitude);
  final lat2 = _degToRad(endLatitude);
  final dLon = _degToRad(endLongitude - startLongitude);

  final y = math.sin(dLon) * math.cos(lat2);
  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  final radians = math.atan2(y, x);
  return (_radToDeg(radians) + 360.0) % 360.0;
}

/// Smallest angle difference between two bearings in degrees [0, 180].
double angleDifferenceDegrees(double b1, double b2) {
  final diff = (b1 - b2).abs() % 360.0;
  return diff > 180.0 ? 360.0 - diff : diff;
}

/// Computes the perpendicular distance in metres from a point
/// (pointLat, pointLon) to a line segment (segStartLat, segStartLon)
/// -> (segEndLat, segEndLon).
double distancePointToSegmentMeters({
  required double pointLat,
  required double pointLon,
  required double segStartLat,
  required double segStartLon,
  required double segEndLat,
  required double segEndLon,
}) {
  final latMid = _degToRad((segStartLat + segEndLat) / 2.0);
  final cosLat = math.cos(latMid);
  final x1 = _degToRad(segStartLon) * cosLat * _earthRadiusMeters;
  final y1 = _degToRad(segStartLat) * _earthRadiusMeters;
  final x2 = _degToRad(segEndLon) * cosLat * _earthRadiusMeters;
  final y2 = _degToRad(segEndLat) * _earthRadiusMeters;
  final px = _degToRad(pointLon) * cosLat * _earthRadiusMeters;
  final py = _degToRad(pointLat) * _earthRadiusMeters;

  final dx = x2 - x1;
  final dy = y2 - y1;
  final segLenSq = dx * dx + dy * dy;
  if (segLenSq == 0) {
    return math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
  }

  final t = ((px - x1) * dx + (py - y1) * dy) / segLenSq;
  final clampedT = t.clamp(0.0, 1.0);
  final projX = x1 + clampedT * dx;
  final projY = y1 + clampedT * dy;
  return math.sqrt(
    (px - projX) * (px - projX) + (py - projY) * (py - projY),
  );
}
