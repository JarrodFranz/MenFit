import 'dart:async';

import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_stub.dart'
    if (dart.library.io) 'package:menfit_app/core/platform/wearables/watch_companion_io.dart'
    as impl;

/// Status and metadata of a paired watch companion device.
class WatchCompanionInfo {
  const WatchCompanionInfo({
    required this.deviceName,
    required this.platform,
    required this.isAppInstalled,
    required this.isReachable,
  });

  final String deviceName;
  final String platform; // "Apple Watch (watchOS)" or "WearOS"
  final bool isAppInstalled;
  final bool isReachable;
}

/// Abstract contract for communicating with smartwatch companion apps
/// (Apple Watch via WatchConnectivity, WearOS via Wearable Data Layer).
abstract class WatchCompanionAdapter {
  const WatchCompanionAdapter();

  factory WatchCompanionAdapter.create() => impl.createDefaultWatchAdapter();

  /// Whether the current device platform supports watch companion connectivity.
  Future<bool> isSupported();

  /// Information about any connected watch device, or null if none paired.
  Future<WatchCompanionInfo?> getCompanionInfo();

  /// Sends a command to the watch (e.g. start/pause/stop workout).
  Future<bool> sendCommand(WatchCommand command);

  /// Transmits current menstrual cycle phase context to the watch display.
  Future<bool> sendCycleContext(WatchCycleContext context);

  /// Stream of incoming messages (telemetry, wrist workouts) from the watch.
  Stream<WatchMessage> get messageStream;

  /// Fetches any completed workouts recorded offline on the wrist that are
  /// waiting to be synchronized into MenFit.
  Future<List<WatchWristWorkout>> pollOfflineWristWorkouts();
}
