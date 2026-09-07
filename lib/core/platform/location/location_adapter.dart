import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';

part 'location_adapter.freezed.dart';

/// Whether this platform/build can record a GPS activity, and if not, why —
/// so presentation code can show an honest explanation instead of a dead
/// button (see `record_screen.dart` entry point on `activity_screen.dart`).
@freezed
abstract class LocationCapabilities with _$LocationCapabilities {
  const factory LocationCapabilities({
    required bool canRecordActivities,

    /// Plain-language reason shown to the user when
    /// [canRecordActivities] is `false`. `null` when it's `true`.
    String? reason,

    /// Whether [LocationAdapter.getCurrentPosition] works on this
    /// platform/build. Broader than [canRecordActivities]: a one-shot
    /// position needs no background stream or foreground service, so it
    /// also works on Web and Windows (geolocator's endorsed
    /// implementations), where continuous recording doesn't. Defaults to
    /// `false` so existing test fakes that only script recording stay
    /// honest.
    @Default(false) bool canGetCurrentPosition,

    /// Plain-language reason shown to the user when
    /// [canGetCurrentPosition] is `false`. `null` when it's `true`.
    String? currentPositionReason,
  }) = _LocationCapabilities;
}

/// Outcome of a permission check/request.
enum LocationPermissionResult {
  granted,
  denied,

  /// Denied "don't ask again" (Android) / denied permanently (iOS) — only
  /// resolvable by the user via OS settings.
  deniedForever,

  /// The device's location services (not just this app's permission) are
  /// switched off.
  servicesDisabled,
}

/// Platform abstraction over GPS location for activity recording.
///
/// Concrete platform behaviour (geolocator settings, permission flow) lives
/// in `GeolocatorLocationAdapter` (`geolocator_location_adapter.dart`) —
/// nothing outside that file may import `package:geolocator` or
/// `package:permission_handler` (architecture_overview.md rule 4). Domain
/// code (`features/activity/domain/recording_session.dart`) only ever sees
/// [LocationFix] via [fixes].
abstract interface class LocationAdapter {
  /// Whether this platform/build supports GPS recording at all. Checked
  /// before offering the Record entry point — Windows/Web report `false`
  /// with a [LocationCapabilities.reason] rather than a runtime error.
  LocationCapabilities get capabilities;

  /// Checks the current permission state without prompting the user.
  Future<LocationPermissionResult> checkPermission();

  /// Prompts the user for location permission if not already
  /// granted/denied-forever, and returns the resulting state.
  Future<LocationPermissionResult> requestPermission();

  /// A stream of location updates for an in-progress recording. Starting a
  /// foreground-service notification (Android) is a side effect of
  /// subscribing; cancelling the subscription stops updates and tears the
  /// notification down. Only one recording is ever active at a time, so
  /// callers should not subscribe more than once concurrently.
  Stream<LocationFix> fixes();

  /// One-shot current position (e.g. the route-suggest "Use my location"
  /// start point). No foreground service, no stream — callers should run
  /// the [checkPermission]/[requestPermission] flow first; a denied
  /// permission or unavailable service surfaces as a `PermissionException`,
  /// anything else as an `UnknownException`. Only callable when
  /// [LocationCapabilities.canGetCurrentPosition] is `true`.
  Future<LocationFix> getCurrentPosition();
}
