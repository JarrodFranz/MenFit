import 'dart:async';

import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';

WatchCompanionAdapter createDefaultWatchAdapter() =>
    const StubWatchCompanionAdapter();

/// Stub implementation for non-supported platforms (Web, Windows Desktop,
/// headless tests).
class StubWatchCompanionAdapter implements WatchCompanionAdapter {
  const StubWatchCompanionAdapter();

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<WatchCompanionInfo?> getCompanionInfo() async => null;

  @override
  Future<bool> sendCommand(WatchCommand command) async => false;

  @override
  Stream<WatchMessage> get messageStream => const Stream.empty();

  @override
  Future<List<WatchWristWorkout>> pollOfflineWristWorkouts() async => const [];
}
