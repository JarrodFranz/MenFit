import 'dart:async';

import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ble_providers.g.dart';

/// Provides the active [BleHeartRateAdapter] singleton.
@Riverpod(keepAlive: true)
BleHeartRateAdapter bleHeartRateAdapter(Ref ref) {
  final adapter = BleHeartRateAdapter.create();
  ref.onDispose(adapter.dispose);
  return adapter;
}

/// State representing an active or completed BLE heart rate sensor scan.
class BleScanningState {
  const BleScanningState({
    this.isScanning = false,
    this.discoveredDevices = const [],
    this.errorMessage,
  });

  final bool isScanning;
  final List<DiscoveredBleDevice> discoveredDevices;
  final String? errorMessage;

  BleScanningState copyWith({
    bool? isScanning,
    List<DiscoveredBleDevice>? discoveredDevices,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BleScanningState(
      isScanning: isScanning ?? this.isScanning,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controls scanning for nearby Bluetooth Heart Rate monitors.
@Riverpod(keepAlive: true)
class BleScanningController extends _$BleScanningController {
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<List<DiscoveredBleDevice>>? _resultsSub;

  @override
  BleScanningState build() {
    final adapter = ref.watch(bleHeartRateAdapterProvider);

    if (_isScanningSub != null) {
      unawaited(_isScanningSub!.cancel());
    }
    _isScanningSub = adapter.isScanningStream.listen((isScanning) {
      state = state.copyWith(isScanning: isScanning);
    });

    if (_resultsSub != null) {
      unawaited(_resultsSub!.cancel());
    }
    _resultsSub = adapter.scanResultsStream.listen((devices) {
      state = state.copyWith(discoveredDevices: devices);
    });

    ref.onDispose(() {
      if (_isScanningSub != null) {
        unawaited(_isScanningSub!.cancel());
      }
      if (_resultsSub != null) {
        unawaited(_resultsSub!.cancel());
      }
    });

    return const BleScanningState();
  }

  /// Triggers a BLE scan for nearby Heart Rate sensors.
  Future<void> startScan({
    Duration? timeout,
  }) async {
    final adapter = ref.read(bleHeartRateAdapterProvider);
    state = state.copyWith(clearError: true);
    try {
      if (timeout != null) {
        await adapter.startScan(timeout: timeout);
      } else {
        await adapter.startScan();
      }
    } on Object catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  /// Stops an ongoing BLE scan.
  Future<void> stopScan() async {
    final adapter = ref.read(bleHeartRateAdapterProvider);
    await adapter.stopScan();
  }
}

/// State representing the active connection to a BLE Heart Rate sensor.
class BleConnectionState {
  const BleConnectionState({
    this.status = BleConnectionStatus.disconnected,
    this.deviceId,
    this.deviceName,
    this.currentBpm,
    this.contactSupported = false,
    this.contactDetected = false,
    this.errorMessage,
  });

  final BleConnectionStatus status;
  final String? deviceId;
  final String? deviceName;
  final int? currentBpm;
  final bool contactSupported;
  final bool contactDetected;
  final String? errorMessage;

  BleConnectionState copyWith({
    BleConnectionStatus? status,
    String? deviceId,
    String? deviceName,
    int? currentBpm,
    bool? contactSupported,
    bool? contactDetected,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BleConnectionState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      currentBpm: currentBpm ?? this.currentBpm,
      contactSupported: contactSupported ?? this.contactSupported,
      contactDetected: contactDetected ?? this.contactDetected,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Manages connection, telemetry subscription, and live BPM streaming from a
/// connected Bluetooth Heart Rate monitor.
@Riverpod(keepAlive: true)
class BleConnectionController extends _$BleConnectionController {
  StreamSubscription<BleConnectionStatus>? _statusSub;
  StreamSubscription<BleHeartRateMeasurement>? _hrSub;

  @override
  BleConnectionState build() {
    final adapter = ref.watch(bleHeartRateAdapterProvider);

    if (_statusSub != null) {
      unawaited(_statusSub!.cancel());
    }
    _statusSub = adapter.connectionStatusStream.listen((status) {
      state = state.copyWith(
        status: status,
        deviceId: status == BleConnectionStatus.connected
            ? adapter.connectedDeviceId
            : null,
        deviceName: status == BleConnectionStatus.connected
            ? adapter.connectedDeviceName
            : null,
        currentBpm: status == BleConnectionStatus.connected
            ? state.currentBpm
            : null,
      );
    });

    if (_hrSub != null) {
      unawaited(_hrSub!.cancel());
    }
    _hrSub = adapter.heartRateStream.listen((data) {
      state = state.copyWith(
        currentBpm: data.heartRateBpm,
        contactSupported: data.contactSupported,
        contactDetected: data.contactDetected,
      );
    });

    ref.onDispose(() {
      if (_statusSub != null) {
        unawaited(_statusSub!.cancel());
      }
      if (_hrSub != null) {
        unawaited(_hrSub!.cancel());
      }
    });

    return const BleConnectionState();
  }

  /// Connects to the sensor identified by [deviceId].
  Future<void> connect(String deviceId) async {
    final adapter = ref.read(bleHeartRateAdapterProvider);
    state = state.copyWith(
      status: BleConnectionStatus.connecting,
      deviceId: deviceId,
      clearError: true,
    );
    try {
      await adapter.connect(deviceId);
    } on Object catch (error) {
      state = state.copyWith(
        status: BleConnectionStatus.disconnected,
        errorMessage: error.toString(),
      );
    }
  }

  /// Disconnects from the current sensor.
  Future<void> disconnect() async {
    final adapter = ref.read(bleHeartRateAdapterProvider);
    await adapter.disconnect();
    state = const BleConnectionState();
  }
}

/// Streams the current instantaneous heart rate in BPM, or null when
/// disconnected.
@riverpod
int? currentLiveHeartRate(Ref ref) {
  final connection = ref.watch(bleConnectionControllerProvider);
  return connection.status == BleConnectionStatus.connected
      ? connection.currentBpm
      : null;
}
