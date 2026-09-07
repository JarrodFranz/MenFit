import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/suggested_route.dart';

/// Preferred geometry for suggested routes.
enum RouteShapePreference {
  /// Circular loop that starts and finishes at the start point along
  /// different paths.
  loop,

  /// Out-and-back route that travels outwards in one direction and returns
  /// along the same path.
  outAndBack,

  /// Searches for both loops and out-and-back routes, selecting the best
  /// distance matches.
  any;

  String get label => switch (this) {
    RouteShapePreference.loop => 'Loop',
    RouteShapePreference.outAndBack => 'Out & Back',
    RouteShapePreference.any => 'Any',
  };
}

/// Produces round-trip route suggestions ("I want to run X km — show me
/// routes").
///
/// The abstraction boundary for the external routing provider
/// (OpenRouteService today — `data/ors_route_service.dart`); nothing above
/// the data layer knows which provider is in use. Failures are typed
/// `AppException`s: `NetworkException` for HTTP/timeout/response-shape
/// problems, `ValidationException` for bad inputs, and a
/// `ValidationException` with `userMessageKey: 'error.routes.apiKeyMissing'`
/// when called without a configured API key (the UI checks configuration
/// first and shows a setup card instead — see
/// `routes_providers.dart#routeSuggestionsConfigured`).
abstract interface class RouteSuggestionService {
  /// The largest target length this provider will accept, in metres
  /// (see [suggestRoundTrips]'s `targetMeters`).
  ///
  /// Part of the domain contract (not an implementation detail) so callers
  /// can reject an over-long distance *before* sending a start point over
  /// the network — presentation validates against this rather than reaching
  /// into a concrete provider. Providers differ, so it's an instance
  /// getter, not a constant.
  double get maxTargetMeters;

  /// Suggests up to [count] round-trip routes starting and ending at
  /// [start], each targeting a length of [targetMeters], suitable for
  /// [activityType] (on-foot profiles for run/walk/hike, cycling for
  /// ride) and adhering to [shapePreference].
  ///
  /// Returns at least one route on success (fewer than [count] when the
  /// provider produced duplicates/failures for some variants); throws a
  /// typed `AppException` when none could be produced.
  Future<List<SuggestedRoute>> suggestRoundTrips({
    required GeoPoint start,
    required double targetMeters,
    required ActivityType activityType,
    RouteShapePreference shapePreference = RouteShapePreference.loop,
    int count = 3,
  });
}
