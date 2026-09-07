import 'dart:async';

import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/safety/domain/live_tracking.dart';
import 'package:menfit_app/features/safety/domain/live_tracking_service.dart';

/// In-memory local implementation of [LiveTrackingService] adhering to
/// offline-first architecture (ADR-004).
///
/// Manages live session states and broadcasts telemetry updates through a
/// reactive stream.
class LocalLiveTrackingService implements LiveTrackingService {
  LocalLiveTrackingService();

  final StreamController<LiveTrackingSession?> _sessionController =
      StreamController<LiveTrackingSession?>.broadcast();

  LiveTrackingSession? _currentSession;
  final List<LiveLocationPacket> _packets = [];

  @override
  LiveTrackingSession? get currentSession => _currentSession;

  /// Returns recorded location packets for the active session.
  List<LiveLocationPacket> get recordedPackets => List.unmodifiable(_packets);

  @override
  Stream<LiveTrackingSession?> watchSession() async* {
    yield _currentSession;
    yield* _sessionController.stream;
  }

  @override
  Future<LiveTrackingSession> startSession({
    required String userName,
    Duration duration = const Duration(hours: 3),
  }) async {
    _packets.clear();
    final session = LiveTrackingSession.create(
      userName: userName,
      duration: duration,
    );
    _currentSession = session;
    _sessionController.add(session);
    return session;
  }

  @override
  Future<void> publishFix({
    required LocationFix fix,
    int? batteryPercentage,
    bool isStationary = false,
  }) async {
    final session = _currentSession;
    if (session == null || session.isExpired()) return;

    final packet = LiveLocationPacket.fromLocationFix(
      fix: fix,
      batteryPercentage: batteryPercentage,
      status: session.status,
      isStationary: isStationary,
    );

    _packets.add(packet);
    final updated = session.copyWith(lastPacket: packet);
    _currentSession = updated;
    _sessionController.add(updated);
  }

  @override
  Future<void> pauseSession() async {
    final session = _currentSession;
    if (session == null || session.isExpired()) return;

    final updated = session.copyWith(status: LiveTrackingStatus.paused);
    _currentSession = updated;
    _sessionController.add(updated);
  }

  @override
  Future<void> resumeSession() async {
    final session = _currentSession;
    if (session == null || session.isExpired()) return;

    final updated = session.copyWith(status: LiveTrackingStatus.active);
    _currentSession = updated;
    _sessionController.add(updated);
  }

  @override
  Future<void> completeSession() async {
    final session = _currentSession;
    if (session == null) return;

    final now = DateTime.now();
    // Allow link to remain visible for 2 hours post-workout
    final updated = session.copyWith(
      status: LiveTrackingStatus.completed,
      expiresAt: now.add(const Duration(hours: 2)),
    );
    _currentSession = updated;
    _sessionController.add(updated);
  }

  @override
  Future<void> cancelSession() async {
    final session = _currentSession;
    if (session == null) return;

    final updated = session.copyWith(status: LiveTrackingStatus.cancelled);
    _currentSession = updated;
    _sessionController.add(updated);
  }

  /// Closes internal stream controllers upon teardown.
  void dispose() {
    unawaited(_sessionController.close());
  }
}
