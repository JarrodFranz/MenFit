import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

part 'saved_route.freezed.dart';

/// Where a saved route came from. Mirrors the persisted `source` column
/// (see `core/db/tables/routes.dart`).
enum RouteSource {
  suggested;

  /// Parses the persisted string form, defaulting to [suggested] for any
  /// unrecognised value (future sources degrade gracefully on old builds).
  static RouteSource fromStorage(String value) {
    return switch (value) {
      _ => RouteSource.suggested,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    RouteSource.suggested => 'suggested',
  };
}

/// A route the user explicitly saved (routes are S2-tier location data —
/// see `core/db/tables/routes.dart` for the persistence rules).
///
/// Mirrors the `routes` table one field at a time; the geometry TEXT
/// column (encoded polyline) is decoded to [points] at the repository
/// boundary (`data/drift_route_repository.dart`), so nothing above data/
/// ever sees the encoding.
@freezed
abstract class SavedRoute with _$SavedRoute {
  const factory SavedRoute({
    required String id,
    required String name,
    required ActivityType activityType,
    required double distanceMeters,

    /// The route's polyline, in travel order.
    required List<GeoPoint> points,
    required RouteSource source,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,
    Duration? estimatedDuration,

    /// Total climb in metres, when the source provided elevation data.
    double? ascentMeters,

    /// Total descent in metres, when the source provided elevation data.
    /// A closed loop's descent is close to — but rarely exactly — its
    /// ascent, so it's stored rather than derived.
    double? descentMeters,
  }) = _SavedRoute;
}
