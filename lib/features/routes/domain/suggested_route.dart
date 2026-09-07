import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';

part 'suggested_route.freezed.dart';

/// One candidate round-trip route produced by a
/// `RouteSuggestionService`, not yet saved — nothing is persisted until
/// the user explicitly saves one (privacy: start points are typically
/// home-adjacent, `knowledge/engineering/security_and_privacy.md`).
@freezed
abstract class SuggestedRoute with _$SuggestedRoute {
  const factory SuggestedRoute({
    /// The route's polyline, in travel order. Round trips start and end at
    /// (approximately) the requested start point.
    required List<GeoPoint> points,

    /// Actual route length in metres (the service targets, but rarely
    /// exactly hits, the requested distance).
    required double distanceMeters,

    /// Service-estimated travel time, when provided.
    Duration? estimatedDuration,

    /// Total climb in metres, when the service returned elevation data.
    double? ascentMeters,

    /// Total descent in metres, when the service returned elevation data.
    double? descentMeters,
  }) = _SuggestedRoute;
}
