import 'dart:async';

import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';

/// Factory providing a platform-safe stub implementation of
/// [BleHeartRateAdapter].
BleHeartRateAdapter createDefaultBleAdapter() => const BleHeartRateStub();

/// Platform-safe stub implementation for web, desktop, and test environments.
class BleHeartRateStub implements BleHeartRateAdapter {
  const BleHeartRateStub();

  @override
  Future<bool> isBluetoothAvailable() async => false;

  @override
  Stream<bool> get isScanningStream => Stream.value(false);

  @override
  Stream<List<DiscoveredBleDevice>> get scanResultsStream =>
      Stream.value(const []);

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {}

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String deviceId) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Stream<BleConnectionStatus> get connectionStatusStream =>
      Stream.value(BleConnectionStatus.disconnected);

  @override
  Stream<BleHeartRateMeasurement> get heartRateStream => const Stream.empty();

  @override
  String? get connectedDeviceId => null;

  @override
  String? get connectedDeviceName => null;

  @override
  void dispose() {}
}
