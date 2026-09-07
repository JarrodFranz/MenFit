import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';

/// Factory providing the native [BleHeartRateAdapter] implementation.
BleHeartRateAdapter createDefaultBleAdapter() => BleHeartRateIo();

/// Native [BleHeartRateAdapter] implementation backed by `flutter_blue_plus`.
class BleHeartRateIo implements BleHeartRateAdapter {
  BleHeartRateIo();

  final _scanResultsController =
      StreamController<List<DiscoveredBleDevice>>.broadcast();
  final _connectionStatusController =
      StreamController<BleConnectionStatus>.broadcast();
  final _heartRateController =
      StreamController<BleHeartRateMeasurement>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceConnectionSubscription;
  StreamSubscription<List<int>>? _charNotificationSubscription;

  BluetoothDevice? _connectedDevice;
  String? _connectedDeviceId;
  String? _connectedDeviceName;

  @override
  Future<bool> isBluetoothAvailable() async {
    try {
      final supported = await FlutterBluePlus.isSupported;
      if (!supported) return false;
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get isScanningStream => FlutterBluePlus.isScanning;

  @override
  Stream<List<DiscoveredBleDevice>> get scanResultsStream =>
      _scanResultsController.stream;

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    await stopScan();

    final discoveredMap = <String, DiscoveredBleDevice>{};

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        if (_isHeartRateDevice(result)) {
          final id = result.device.remoteId.str;
          final name = _resolveDeviceName(result);
          discoveredMap[id] = DiscoveredBleDevice(
            id: id,
            name: name,
            rssi: result.rssi,
          );
        }
      }
      _scanResultsController.add(discoveredMap.values.toList());
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
      );
    } on Object catch (_) {
      // Degrades gracefully if Bluetooth permissions or adapter are off.
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    } on Object catch (_) {}
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  @override
  Future<void> connect(String deviceId) async {
    await stopScan();
    await disconnect();

    _connectionStatusController.add(BleConnectionStatus.connecting);

    try {
      final device = BluetoothDevice.fromId(deviceId);
      _connectedDevice = device;
      _connectedDeviceId = deviceId;
      _connectedDeviceName = device.platformName.isNotEmpty
          ? device.platformName
          : 'Heart Rate Sensor';

      _deviceConnectionSubscription = device.connectionState.listen((
        connectionState,
      ) {
        switch (connectionState) {
          case BluetoothConnectionState.connected:
            _connectionStatusController.add(BleConnectionStatus.connected);
          case BluetoothConnectionState.disconnected:
            _connectionStatusController.add(BleConnectionStatus.disconnected);
            _connectedDevice = null;
            _connectedDeviceId = null;
            _connectedDeviceName = null;
        }
      });

      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 12),
      );

      final services = await device.discoverServices();
      final hrService = services.cast<BluetoothService?>().firstWhere(
        (s) => s?.uuid.str.toLowerCase().contains('180d') ?? false,
        orElse: () => null,
      );

      if (hrService == null) {
        throw StateError('Sensor does not expose standard Heart Rate Service');
      }

      final hrChar = hrService.characteristics
          .cast<BluetoothCharacteristic?>()
          .firstWhere(
            (c) => c?.uuid.str.toLowerCase().contains('2a37') ?? false,
            orElse: () => null,
          );

      if (hrChar == null) {
        throw StateError('Heart Rate characteristic (0x2A37) not found');
      }

      await hrChar.setNotifyValue(true);
      _charNotificationSubscription = hrChar.onValueReceived.listen((rawBytes) {
        if (rawBytes.isNotEmpty) {
          final data = BleHeartRateParser.parse(Uint8List.fromList(rawBytes));
          if (data != null) {
            _heartRateController.add(data);
          }
        }
      });

      _connectionStatusController.add(BleConnectionStatus.connected);
    } on Object catch (_) {
      await disconnect();
      _connectionStatusController.add(BleConnectionStatus.disconnected);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(BleConnectionStatus.disconnecting);
    }
    await _charNotificationSubscription?.cancel();
    _charNotificationSubscription = null;
    await _deviceConnectionSubscription?.cancel();
    _deviceConnectionSubscription = null;

    try {
      await _connectedDevice?.disconnect();
    } on Object catch (_) {}

    _connectedDevice = null;
    _connectedDeviceId = null;
    _connectedDeviceName = null;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(BleConnectionStatus.disconnected);
    }
  }

  @override
  Stream<BleConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Stream<BleHeartRateMeasurement> get heartRateStream =>
      _heartRateController.stream;

  @override
  String? get connectedDeviceId => _connectedDeviceId;

  @override
  String? get connectedDeviceName => _connectedDeviceName;

  @override
  void dispose() {
    unawaited(stopScan());
    unawaited(disconnect());
    unawaited(_scanResultsController.close());
    unawaited(_connectionStatusController.close());
    unawaited(_heartRateController.close());
  }

  bool _isHeartRateDevice(ScanResult r) {
    final hasHrService = r.advertisementData.serviceUuids.any(
      (u) => u.str.toLowerCase().contains('180d'),
    );
    if (hasHrService) return true;

    final name = _resolveDeviceName(r).toLowerCase();
    if (name.isEmpty) return false;

    return name.contains('garmin') ||
        name.contains('forerunner') ||
        name.contains('fenix') ||
        name.contains('venu') ||
        name.contains('instinct') ||
        name.contains('vivoactive') ||
        name.contains('polar') ||
        name.contains('hrm') ||
        name.contains('heart') ||
        name.contains('tickr') ||
        name.contains('wahoo') ||
        name.contains('coros') ||
        name.contains('suunto');
  }

  String _resolveDeviceName(ScanResult r) {
    if (r.advertisementData.advName.trim().isNotEmpty) {
      return r.advertisementData.advName.trim();
    }
    if (r.device.platformName.trim().isNotEmpty) {
      return r.device.platformName.trim();
    }
    return 'Heart Rate Sensor';
  }
}
