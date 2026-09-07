import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';

WatchCompanionAdapter createDefaultWatchAdapter() => IoWatchCompanionAdapter();

/// Production implementation of [WatchCompanionAdapter] backed by native
/// platform channels (WatchConnectivity on iOS and Wearable Data Layer on
/// Android).
class IoWatchCompanionAdapter implements WatchCompanionAdapter {
  IoWatchCompanionAdapter({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.femfit.app/wearables') {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  final MethodChannel _channel;
  final _messageController = StreamController<WatchMessage>.broadcast();

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    try {
      if (call.method == 'onMessageReceived') {
        final rawMap = Map<String, dynamic>.from(call.arguments as Map);
        final message = WatchMessage.fromJson(rawMap);
        if (message != null) {
          _messageController.add(message);
        }
      }
    } on Object catch (_) {
      // Swallowed safely; invalid incoming message dropped
    }
  }

  @override
  Future<bool> isSupported() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final supported = await _channel.invokeMethod<bool>('isSupported');
      return supported ?? false;
    } on MissingPluginException {
      return false;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<WatchCompanionInfo?> getCompanionInfo() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>(
        'getCompanionInfo',
      );
      if (res == null) return null;
      return WatchCompanionInfo(
        deviceName: res['deviceName'] as String? ?? 'Connected Watch',
        platform: Platform.isIOS ? 'Apple Watch (watchOS)' : 'WearOS',
        isAppInstalled: res['isAppInstalled'] as bool? ?? false,
        isReachable: res['isReachable'] as bool? ?? false,
      );
    } on MissingPluginException {
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<bool> sendCommand(WatchCommand command) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final success = await _channel.invokeMethod<bool>(
        'sendCommand',
        command.toJson(),
      );
      return success ?? false;
    } on MissingPluginException {
      return false;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sendCycleContext(WatchCycleContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final success = await _channel.invokeMethod<bool>(
        'sendCycleContext',
        context.toJson(),
      );
      return success ?? false;
    } on MissingPluginException {
      return false;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Stream<WatchMessage> get messageStream => _messageController.stream;

  @override
  Future<List<WatchWristWorkout>> pollOfflineWristWorkouts() async {
    if (!Platform.isAndroid && !Platform.isIOS) return const [];
    try {
      final list = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'pollOfflineWristWorkouts',
      );
      if (list == null) return const [];

      final workouts = <WatchWristWorkout>[];
      for (final raw in list) {
        final map = Map<String, dynamic>.from(raw);
        final w = WatchWristWorkout.fromJson(map);
        workouts.add(w);
      }
      return workouts;
    } on MissingPluginException {
      return const [];
    } on Object catch (_) {
      return const [];
    }
  }
}
