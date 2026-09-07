import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:menfit_app/core/config/env.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// [LocationAdapter] backed by `package:geolocator` (ADR 008).
///
/// The only file in this feature/adapter that may import `package:geolocator`
/// or `package:permission_handler` — everything above this adapter (domain
/// logic, the recording controller/screen) only ever sees [LocationFix] /
/// [LocationCapabilities] / [LocationPermissionResult]
/// (architecture_overview.md rule 4). Platform branching uses [kIsWeb] +
/// [defaultTargetPlatform] — deliberately no `dart:io` import so this file
/// stays web-safe.
///
/// Per ADR 008, `ACCESS_BACKGROUND_LOCATION` is never requested — recording
/// relies on a foreground-started foreground service (Android) /
/// `allowBackgroundLocationUpdates` with when-in-use auth (iOS) to keep
/// receiving updates with the screen off. `permission_handler` is used only
/// for `Permission.notification` on Android, before starting the FGS
/// notification path; a denial there is non-blocking (recording proceeds
/// without a visible notification, which the OS still tolerates for a
/// short-lived foreground service tied to an active screen session).
class GeolocatorLocationAdapter implements LocationAdapter {
  const GeolocatorLocationAdapter();

  @override
  LocationCapabilities get capabilities {
    // One-shot positions (route-suggest start point) work everywhere
    // geolocator has an endorsed implementation: Android/iOS/macOS, Web
    // (browser geolocation), and Windows. Continuous recording is
    // mobile-only (foreground service / background updates — ADR 008).
    final canGetCurrentPosition =
        kIsWeb ||
        switch (defaultTargetPlatform) {
          TargetPlatform.android ||
          TargetPlatform.iOS ||
          TargetPlatform.macOS ||
          TargetPlatform.windows => true,
          _ => false,
        };
    const currentPositionReason =
        'Getting your location is not supported on this device — tap the '
        'map to choose a start point instead.';

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return LocationCapabilities(
        canRecordActivities: true,
        canGetCurrentPosition: canGetCurrentPosition,
        currentPositionReason: canGetCurrentPosition
            ? null
            : currentPositionReason,
      );
    }
    return LocationCapabilities(
      canRecordActivities: false,
      reason:
          'Recording works on your phone — log activities manually '
          'here.',
      canGetCurrentPosition: canGetCurrentPosition,
      currentPositionReason: canGetCurrentPosition
          ? null
          : currentPositionReason,
    );
  }

  @override
  Future<LocationPermissionResult> checkPermission() async {
    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) {
        return LocationPermissionResult.servicesDisabled;
      }
      final permission = await geo.Geolocator.checkPermission();
      return _toResult(permission);
    } catch (e, st) {
      throw UnknownException(
        message: 'Failed to check location permission',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<LocationPermissionResult> requestPermission() async {
    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) {
        return LocationPermissionResult.servicesDisabled;
      }
      final permission = await geo.Geolocator.requestPermission();
      return _toResult(permission);
    } catch (e, st) {
      throw UnknownException(
        message: 'Failed to request location permission',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<LocationFix> fixes() async* {
    // Best-effort only: POST_NOTIFICATIONS denial doesn't block recording,
    // it just means the OS may suppress the foreground-service notification
    // (the FGS itself still runs). Android-only, guarded by platform check
    // rather than duplicating geolocator's own location-permission handling
    // (see class doc).
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await ph.Permission.notification.request();
      } on Object catch (_) {
        // Non-blocking — proceed without a guaranteed notification.
      }
    }

    try {
      yield* geo.Geolocator.getPositionStream(
        locationSettings: _locationSettings(),
      ).map(_toFix);
    } on geo.LocationServiceDisabledException catch (e, st) {
      throw PermissionException(
        message: 'Location services are disabled',
        cause: e,
        stackTrace: st,
      );
    } on geo.PermissionDeniedException catch (e, st) {
      throw PermissionException(
        message: 'Location permission denied',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        message: 'Location stream failed',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<LocationFix> getCurrentPosition() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        // Default settings: `accuracy` already defaults to `best` (see
        // `_locationSettings`'s doc), and a one-shot fix needs none of the
        // platform-specific stream/foreground-service configuration.
        locationSettings: const geo.LocationSettings(),
      );
      return _toFix(position);
    } on geo.LocationServiceDisabledException catch (e, st) {
      throw PermissionException(
        message: 'Location services are disabled',
        cause: e,
        stackTrace: st,
      );
    } on geo.PermissionDeniedException catch (e, st) {
      throw PermissionException(
        message: 'Location permission denied',
        cause: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        message: 'Failed to get current position',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Builds platform-appropriate [geo.LocationSettings] per the verified
  /// facts in `knowledge/research/run_tracking_stack.md` /
  /// `knowledge/decisions/008_run_recording_stack.md`.
  ///
  /// `accuracy` is left unset on every branch below — [geo.LocationSettings]
  /// (and both platform subclasses) already default it to
  /// [geo.LocationAccuracy.best], which is what recording wants, so setting
  /// it explicitly would just be a redundant-argument lint with no
  /// behavioural difference.
  geo.LocationSettings _locationSettings() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return geo.AndroidSettings(
        distanceFilter: 3,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: geo.ForegroundNotificationConfig(
          notificationTitle: AppEnv.instance.appName,
          notificationText: 'Recording your activity',
          setOngoing: true,
        ),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return geo.AppleSettings(
        activityType: geo.ActivityType.fitness,
        distanceFilter: 3,
        // Both spelled out despite matching AppleSettings' own defaults:
        // this pair is exactly what makes screen-off recording work per
        // ADR 008, so leaving it to an upstream default we don't control
        // is the wrong kind of implicit here.
        // ignore: avoid_redundant_argument_values
        pauseLocationUpdatesAutomatically: false,
        // Same reasoning as above.
        // ignore: avoid_redundant_argument_values
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    // Windows/Web/other: recording is unreachable via `capabilities`, but a
    // plain settings object keeps this method total.
    return const geo.LocationSettings();
  }

  LocationPermissionResult _toResult(geo.LocationPermission permission) {
    return switch (permission) {
      geo.LocationPermission.whileInUse ||
      geo.LocationPermission.always => LocationPermissionResult.granted,
      geo.LocationPermission.deniedForever =>
        LocationPermissionResult.deniedForever,
      geo.LocationPermission.denied ||
      geo.LocationPermission.unableToDetermine =>
        LocationPermissionResult.denied,
    };
  }

  LocationFix _toFix(geo.Position position) {
    return LocationFix(
      timestamp: position.timestamp.toUtc(),
      latitude: position.latitude,
      longitude: position.longitude,
      elevationMeters: position.hasAltitude ? position.altitude : null,
      horizontalAccuracyMeters: position.hasAccuracy ? position.accuracy : null,
      speedMetersPerSecond: position.hasSpeed ? position.speed : null,
    );
  }
}
