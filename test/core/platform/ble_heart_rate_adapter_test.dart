import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_stub.dart';

void main() {
  group('BleHeartRateStub', () {
    test('provides safe default values without throwing', () async {
      final stub = createDefaultBleAdapter();

      expect(await stub.isBluetoothAvailable(), isFalse);
      expect(stub.connectedDeviceId, isNull);
      expect(stub.connectedDeviceName, isNull);

      final isScanning = await stub.isScanningStream.first;
      expect(isScanning, isFalse);

      final devices = await stub.scanResultsStream.first;
      expect(devices, isEmpty);

      final status = await stub.connectionStatusStream.first;
      expect(status, BleConnectionStatus.disconnected);

      // Verify no-op methods do not throw
      await stub.startScan();
      await stub.stopScan();
      await stub.connect('MOCK_ID');
      await stub.disconnect();
      stub.dispose();
    });
  });
}
