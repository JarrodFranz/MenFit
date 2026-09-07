/// Google polyline-algorithm (precision 5) encode/decode for route
/// geometry.
///
/// Pure Dart, no dependencies — used by the routes feature to persist a
/// suggested route's geometry as a compact TEXT column
/// (`core/db/tables/routes.dart`) instead of a relational point table:
/// unlike recorded GPS tracks (`activity_samples`, kept relational for
/// per-point analytics), a suggested route's geometry is only ever read
/// back whole for drawing, never queried per point.
///
/// Format reference: the standard "Encoded Polyline Algorithm Format"
/// (deltas of round(value * 1e5), zigzag-signed, base-64-ish chunks offset
/// by 63). Round-trips are exact at 5-decimal precision (~1 m), which is
/// finer than the underlying route data.
library;

/// A latitude/longitude pair for [encodePolyline]/[decodePolyline].
///
/// A record (not a class) so this utility stays dependency-free in both
/// directions — callers map their own point types at the call site.
typedef PolylinePoint = ({double latitude, double longitude});

/// Encodes [points] into a polyline-5 string. An empty list encodes to
/// `''`.
String encodePolyline(List<PolylinePoint> points) {
  final buffer = StringBuffer();
  var previousLatitude = 0;
  var previousLongitude = 0;

  for (final point in points) {
    final latitude = (point.latitude * 1e5).round();
    final longitude = (point.longitude * 1e5).round();
    _encodeValue(latitude - previousLatitude, buffer);
    _encodeValue(longitude - previousLongitude, buffer);
    previousLatitude = latitude;
    previousLongitude = longitude;
  }
  return buffer.toString();
}

/// Decodes a polyline-5 [encoded] string back into points. `''` decodes to
/// an empty list.
///
/// Throws [FormatException] for a malformed string (truncated chunk
/// sequence or a dangling latitude with no longitude).
List<PolylinePoint> decodePolyline(String encoded) {
  final points = <PolylinePoint>[];
  var index = 0;
  var latitude = 0;
  var longitude = 0;

  while (index < encoded.length) {
    final (latDelta, afterLat) = _decodeValue(encoded, index);
    if (afterLat >= encoded.length) {
      throw const FormatException(
        'Malformed polyline: latitude without a longitude',
      );
    }
    final (lonDelta, afterLon) = _decodeValue(encoded, afterLat);
    latitude += latDelta;
    longitude += lonDelta;
    points.add((latitude: latitude / 1e5, longitude: longitude / 1e5));
    index = afterLon;
  }
  return points;
}

void _encodeValue(int value, StringBuffer buffer) {
  // Zigzag: left-shift, invert when negative, so the sign lives in the low
  // bit and small magnitudes stay short.
  var v = value < 0 ? ~(value << 1) : value << 1;
  while (v >= 0x20) {
    buffer.writeCharCode((0x20 | (v & 0x1f)) + 63);
    v >>= 5;
  }
  buffer.writeCharCode(v + 63);
}

(int value, int nextIndex) _decodeValue(String encoded, int startIndex) {
  var index = startIndex;
  var result = 0;
  var shift = 0;
  int chunk;
  do {
    if (index >= encoded.length) {
      throw const FormatException('Malformed polyline: truncated chunk');
    }
    chunk = encoded.codeUnitAt(index) - 63;
    if (chunk < 0) {
      throw FormatException(
        'Malformed polyline: invalid character at index $index',
      );
    }
    index++;
    result |= (chunk & 0x1f) << shift;
    shift += 5;
  } while (chunk >= 0x20);
  final value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  return (value, index);
}
