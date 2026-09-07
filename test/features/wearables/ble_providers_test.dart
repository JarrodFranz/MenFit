import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';

import 'fake_ble_heart_rate_adapter.dart';

void main() {
  group('BleScanningController', () {
    test('starts and stops scan through adapter', () async {
      final fakeAdapter = FakeBleHeartRateAdapter();
      final container = ProviderContainer(
        overrides: [
          bleHeartRateAdapterProvider.overrideWithValue(fakeAdapter),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(bleScanningControllerProvider.notifier);

      expect(container.read(bleScanningControllerProvider).isScanning, isFalse);

      await controller.startScan();
      expect(fakeAdapter.startScanCalls, 1);

      fakeAdapter.emitScanning(scanning: true);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(bleScanningControllerProvider).isScanning, isTrue);

      const testDevice = DiscoveredBleDevice(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'Garmin Forerunner 955',
        rssi: -62,
      );
      fakeAdapter.emitDiscoveredDevices([testDevice]);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(bleScanningControllerProvider);
      expect(state.discoveredDevices, hasLength(1));
      expect(state.discoveredDevices.first.name, 'Garmin Forerunner 955');

      await controller.stopScan();
      expect(fakeAdapter.stopScanCalls, 1);
    });
  });

  group('BleConnectionController', () {
    test('connects, receives heart rate, and streams live BPM', () async {
      final fakeAdapter = FakeBleHeartRateAdapter();
      final container = ProviderContainer(
        overrides: [
          bleHeartRateAdapterProvider.overrideWithValue(fakeAdapter),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        bleConnectionControllerProvider.notifier,
      );

      expect(
        container.read(bleConnectionControllerProvider).status,
        BleConnectionStatus.disconnected,
      );
      expect(container.read(currentLiveHeartRateProvider), isNull);

      await controller.connect('DEV_123');
      expect(fakeAdapter.lastConnectedId, 'DEV_123');
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(bleConnectionControllerProvider).status,
        BleConnectionStatus.connected,
      );
      expect(
        container.read(bleConnectionControllerProvider).deviceName,
        'Forerunner 955',
      );

      // Emit heart rate measurement
      const measurement = BleHeartRateMeasurement(
        heartRateBpm: 148,
        contactSupported: true,
        contactDetected: true,
      );
      fakeAdapter.emitHeartRate(measurement);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(bleConnectionControllerProvider).currentBpm,
        148,
      );
      expect(container.read(currentLiveHeartRateProvider), 148);

      // Disconnect
      await controller.disconnect();
      expect(fakeAdapter.disconnectCalls, 1);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(bleConnectionControllerProvider).status,
        BleConnectionStatus.disconnected,
      );
      expect(container.read(currentLiveHeartRateProvider), isNull);
    });
  });
}
