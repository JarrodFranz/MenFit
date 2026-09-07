import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_point.freezed.dart';

/// A plain latitude/longitude pair for route geometry.
///
/// The routes feature's domain layer stays Flutter/plugin-free
/// (architecture_overview.md rule 1), so it can't use flutter_map's
/// `LatLng` (latlong2 is a map-stack dependency); presentation converts at
/// the widget boundary. Coordinates are S2-tier data — never log them
/// (`knowledge/engineering/security_and_privacy.md`).
@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({
    required double latitude,
    required double longitude,
  }) = _GeoPoint;

  const GeoPoint._();

  /// Deliberately reveals nothing.
  ///
  /// Freezed's generated `toString` prints both coordinates, so a single
  /// accidental interpolation — `'...: $point'` in a log line, an exception
  /// message, or an assertion — would put an S2 location (typically
  /// home-adjacent) somewhere it can be read later. Same reasoning as
  /// `core/domain/local_date.dart`'s parse/assert messages, which keep
  /// period dates out of exception strings by construction rather than by
  /// remembering each time.
  @override
  String toString() => 'GeoPoint(<redacted>)';
}
