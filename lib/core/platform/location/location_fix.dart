import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_fix.freezed.dart';

/// A single point-in-time location reading from the platform location
/// service.
///
/// This is the adapter-boundary type: `LocationAdapter.fixes` emits these,
/// and `features/activity/domain/recording_session.dart` consumes them
/// without ever importing a plugin type — the domain layer stays plugin-free
/// (architecture_overview.md rule 4). Never logged: coordinates are S2/S3
/// data (`knowledge/engineering/security_and_privacy.md`).
@freezed
abstract class LocationFix with _$LocationFix {
  const factory LocationFix({
    /// UTC.
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    double? elevationMeters,
    double? horizontalAccuracyMeters,
    double? speedMetersPerSecond,
  }) = _LocationFix;
}
