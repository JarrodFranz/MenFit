import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/safety/domain/live_tracking.dart';

/// Service contract managing live-tracking session lifecycle and location
/// broadcasting.
abstract class LiveTrackingService {
  /// The currently active live-tracking session, or null if inactive.
  LiveTrackingSession? get currentSession;

  /// Stream of session updates emitted as location fixes or status changes
  /// occur.
  Stream<LiveTrackingSession?> watchSession();

  /// Starts a new live-tracking session for [userName] with an unguessable
  /// token and returns the session.
  Future<LiveTrackingSession> startSession({
    required String userName,
    Duration duration = const Duration(hours: 3),
  });

  /// Broadcasts a new location fix and device telemetry packet.
  Future<void> publishFix({
    required LocationFix fix,
    int? batteryPercentage,
    bool isStationary = false,
  });

  /// Marks the current session as paused.
  Future<void> pauseSession();

  /// Resumes the current session after a pause.
  Future<void> resumeSession();

  /// Concludes the workout, transitioning to completed status with a 2-hour
  /// expiration buffer.
  Future<void> completeSession();

  /// Explicitly revokes and cancels the current live-tracking link immediately.
  Future<void> cancelSession();
}
