import 'dart:async';

import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_stub.dart'
    if (dart.library.io) 'package:menfit_app/core/platform/wearables/ble_heart_rate_io.dart'
    as impl;

/// Represents a nearby Bluetooth Low Energy sensor discovered during scan.
class DiscoveredBleDevice {
  const DiscoveredBleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });

  /// The unique hardware address or UUID of the device.
  final String id;

  /// The advertised name (e.g. "Forerunner 265", "Garmin HRM-Dual").
  final String name;

  /// Received Signal Strength Indicator in dBm (e.g. -65).
  final int rssi;
}

/// Lifecycle connection state for a Bluetooth Low Energy peripheral.
enum BleConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting;

  bool get isConnected => this == BleConnectionStatus.connected;
  bool get isConnecting => this == BleConnectionStatus.connecting;
}

/// Hardware abstraction contract for Bluetooth Low Energy Heart Rate monitors.
abstract class BleHeartRateAdapter {
  const BleHeartRateAdapter();

  /// Creates the default platform BLE adapter for the current runtime.
  factory BleHeartRateAdapter.create() => impl.createDefaultBleAdapter();

  /// Whether Bluetooth LE hardware is supported and turned on.
  Future<bool> isBluetoothAvailable();

  /// Stream indicating whether an active BLE scan is in progress.
  Stream<bool> get isScanningStream;

  /// Stream emitting deduplicated discovered heart rate sensors.
  Stream<List<DiscoveredBleDevice>> get scanResultsStream;

  /// Begins scanning for nearby Heart Rate sensors (service 0x180D or HRM).
  Future<void> startScan({Duration timeout = const Duration(seconds: 15)});

  /// Stops an in-progress scan.
  Future<void> stopScan();

  /// Connects to the sensor identified by [deviceId] and subscribes to
  /// Heart Rate notifications (service 0x180D, characteristic 0x2A37).
  Future<void> connect(String deviceId);

  /// Disconnects from the currently connected sensor, if any.
  Future<void> disconnect();

  /// Stream emitting active connection status changes.
  Stream<BleConnectionStatus> get connectionStatusStream;

  /// Stream emitting real-time decoded heart rate measurements.
  Stream<BleHeartRateMeasurement> get heartRateStream;

  /// Identifier of the currently connected device, or `null`.
  String? get connectedDeviceId;

  /// Name of the currently connected device, or `null`.
  String? get connectedDeviceName;

  /// Releases stream controllers and adapter resources.
  void dispose();
}
