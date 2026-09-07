import 'dart:async';

import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';

/// Test double for [BleHeartRateAdapter] allowing fine-grained simulation of
/// BLE scanning, connection, and heart rate telemetry streams.
class FakeBleHeartRateAdapter implements BleHeartRateAdapter {
  FakeBleHeartRateAdapter();

  final _isScanningController = StreamController<bool>.broadcast();
  final _scanResultsController =
      StreamController<List<DiscoveredBleDevice>>.broadcast();
  final _statusController = StreamController<BleConnectionStatus>.broadcast();
  final _heartRateController =
      StreamController<BleHeartRateMeasurement>.broadcast();

  bool isAvailable = true;
  int startScanCalls = 0;
  int stopScanCalls = 0;
  int disconnectCalls = 0;
  String? lastConnectedId;

  String? _connectedDeviceId;
  String? _connectedDeviceName;

  @override
  String? get connectedDeviceId => _connectedDeviceId;

  @override
  String? get connectedDeviceName => _connectedDeviceName;

  @override
  Future<bool> isBluetoothAvailable() async => isAvailable;

  @override
  Stream<bool> get isScanningStream => _isScanningController.stream;

  @override
  Stream<List<DiscoveredBleDevice>> get scanResultsStream =>
      _scanResultsController.stream;

  @override
  Stream<BleConnectionStatus> get connectionStatusStream =>
      _statusController.stream;

  @override
  Stream<BleHeartRateMeasurement> get heartRateStream =>
      _heartRateController.stream;

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    startScanCalls++;
    _isScanningController.add(true);
  }

  @override
  Future<void> stopScan() async {
    stopScanCalls++;
    _isScanningController.add(false);
  }

  @override
  Future<void> connect(String deviceId) async {
    lastConnectedId = deviceId;
    _connectedDeviceId = deviceId;
    _connectedDeviceName = 'Forerunner 955';
    _statusController
      ..add(BleConnectionStatus.connecting)
      ..add(BleConnectionStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    _connectedDeviceId = null;
    _connectedDeviceName = null;
    _statusController.add(BleConnectionStatus.disconnected);
  }

  void emitScanning({required bool scanning}) {
    _isScanningController.add(scanning);
  }

  void emitDiscoveredDevices(List<DiscoveredBleDevice> devices) {
    _scanResultsController.add(devices);
  }

  void emitStatus(
    BleConnectionStatus status, {
    String? deviceId,
    String? deviceName,
  }) {
    _connectedDeviceId = deviceId;
    _connectedDeviceName = deviceName;
    _statusController.add(status);
  }

  void emitHeartRate(BleHeartRateMeasurement measurement) {
    _heartRateController.add(measurement);
  }

  @override
  void dispose() {
    unawaited(_isScanningController.close());
    unawaited(_scanResultsController.close());
    unawaited(_statusController.close());
    unawaited(_heartRateController.close());
  }
}
