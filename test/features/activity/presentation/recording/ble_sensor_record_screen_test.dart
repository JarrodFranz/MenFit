import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/platform/speech/speech_providers.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/map_tile_provider.dart';
import 'package:menfit_app/features/activity/presentation/recording/record_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';
import 'package:menfit_app/features/wearables/presentation/ble_sensor_sheet.dart';

import '../../../../core/platform/audio/fake_audio_cue_player.dart';
import '../../../../core/platform/speech/fake_speech_adapter.dart';
import '../../../wearables/fake_ble_heart_rate_adapter.dart';

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}

class _StubLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities =>
      const LocationCapabilities(canRecordActivities: true);

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => const Stream.empty();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

class _TestRecordingController extends RecordingController {
  _TestRecordingController(this._initialState);

  final RecordingControllerState _initialState;

  @override
  RecordingControllerState build() => _initialState;
}

void main() {
  late FakeSpeechAdapter fakeSpeech;
  late FakeAudioCuePlayer fakePlayer;
  late FakeBleHeartRateAdapter fakeBleAdapter;

  setUp(() {
    fakeSpeech = FakeSpeechAdapter();
    fakePlayer = FakeAudioCuePlayer();
    fakeBleAdapter = FakeBleHeartRateAdapter();
  });

  Widget buildScreen({
    RecordingControllerState state = const RecordingControllerState(),
  }) {
    return ProviderScope(
      overrides: [
        mapTileProviderProvider.overrideWithValue(_FakeTileProvider()),
        locationAdapterProvider.overrideWithValue(_StubLocationAdapter()),
        speechAdapterProvider.overrideWithValue(fakeSpeech),
        audioCuePlayerProvider.overrideWithValue(fakePlayer),
        bleHeartRateAdapterProvider.overrideWithValue(fakeBleAdapter),
        recordingControllerProvider.overrideWith(
          () => _TestRecordingController(state),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const RecordScreen(),
      ),
    );
  }

  group('RecordScreen BLE Heart Rate Sensor', () {
    testWidgets('renders Heart Rate Sensor button on pre-start screen', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recordBleSensorButton')), findsOneWidget);
      expect(find.text('Heart Rate Sensor'), findsOneWidget);
    });

    testWidgets(
      'tapping Heart Rate Sensor button opens BleSensorSheet, connects, and '
      'updates button on RecordScreen',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // Tap the sensor button to open the sheet
        await tester.tap(find.byKey(const Key('recordBleSensorButton')));
        await tester.pumpAndSettle();

        expect(find.byType(BleSensorSheet), findsOneWidget);
        expect(find.text('Heart Rate Sensors'), findsOneWidget);
        expect(find.text('Scan for Heart Rate Sensors'), findsOneWidget);

        // Tap Scan
        await tester.tap(find.text('Scan for Heart Rate Sensors'));
        await tester.pump();

        fakeBleAdapter.emitScanning(scanning: true);
        const testDevice = DiscoveredBleDevice(
          id: 'POLAR_H10',
          name: 'Polar H10 12345',
          rssi: -62,
        );
        fakeBleAdapter.emitDiscoveredDevices([testDevice]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Stop Scanning'), findsOneWidget);
        expect(find.text('Discovered Sensors'), findsOneWidget);
        expect(find.text('Polar H10 12345'), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);

        // Tap Connect
        await tester.tap(find.text('Connect'));
        fakeBleAdapter.emitScanning(scanning: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Connected'), findsWidgets);
        expect(find.text('Disconnect'), findsOneWidget);

        // Emit live HR telemetry
        const measurement = BleHeartRateMeasurement(
          heartRateBpm: 142,
          contactSupported: true,
          contactDetected: true,
        );
        fakeBleAdapter.emitHeartRate(measurement);
        await tester.pumpAndSettle();

        expect(find.text('142'), findsOneWidget);
        expect(find.text('bpm'), findsOneWidget);

        // Close the sheet
        await tester.tap(
          find.byKey(const Key('bleSensorSheetCloseButton')),
        );
        await tester.pumpAndSettle();

        // BleSensorSheet is dismissed and we are back on RecordScreen
        expect(find.byType(BleSensorSheet), findsNothing);
        expect(find.byKey(const Key('recordBleSensorButton')), findsOneWidget);
        // The button label now shows the connected device and live bpm
        expect(find.textContaining('142 bpm'), findsOneWidget);
      },
    );
  });
}
