import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_adapter.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';
import 'package:menfit_app/features/wearables/presentation/wearables_screen.dart';
import 'package:menfit_app/features/wearables/wearables_providers.dart';

import '../activity/fake_activity_repository.dart';
import '../steps/fake_health_platform_adapter.dart';
import 'fake_ble_heart_rate_adapter.dart';
import 'wearable_workout_sync_service_test.dart';

void main() {
  testWidgets('WearablesScreen renders all cards and sync action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeActivityRepo = FakeActivityRepository();
    final fakeWatchAdapter = FakeWatchCompanionAdapter();
    final fakeCycleRepo = FakeCycleRepository();
    final fakeHealthAdapter = FakeHealthPlatformAdapter();
    final fakeBleAdapter = FakeBleHeartRateAdapter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activityRepositoryProvider.overrideWithValue(fakeActivityRepo),
          watchCompanionAdapterProvider.overrideWithValue(fakeWatchAdapter),
          cycleRepositoryProvider.overrideWithValue(fakeCycleRepo),
          healthPlatformAdapterProvider.overrideWithValue(fakeHealthAdapter),
          bleHeartRateAdapterProvider.overrideWithValue(fakeBleAdapter),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const WearablesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Garmin Card
    expect(find.text('Garmin Connect Sync'), findsOneWidget);
    expect(find.text('Health Connect / Apple Health Bridge'), findsOneWidget);
    expect(find.text('Sync Workouts Now'), findsOneWidget);

    // Verify Companion Card
    expect(find.text('Watch Companion App'), findsOneWidget);
    expect(find.text('Send Cycle Phase'), findsOneWidget);
    expect(find.text('Sync Wrist Workouts'), findsOneWidget);

    // Verify BLE Card
    expect(find.text('Optical HR & BLE Sensors'), findsOneWidget);
    expect(find.text('Scan for Heart Rate Sensors'), findsOneWidget);

    // Verify Empty state for synced workouts
    expect(find.text('Synced Wearable Workouts'), findsOneWidget);
    expect(
      find.textContaining('No wearable workouts synced yet'),
      findsOneWidget,
    );

    // Tap Sync Workouts Now
    await tester.tap(find.text('Sync Workouts Now'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify result message rendered
    expect(find.textContaining('Everything is up to date'), findsOneWidget);
  });

  testWidgets('WearablesScreen discovers, connects, and streams live HR', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeActivityRepo = FakeActivityRepository();
    final fakeWatchAdapter = FakeWatchCompanionAdapter();
    final fakeCycleRepo = FakeCycleRepository();
    final fakeHealthAdapter = FakeHealthPlatformAdapter();
    final fakeBleAdapter = FakeBleHeartRateAdapter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activityRepositoryProvider.overrideWithValue(fakeActivityRepo),
          watchCompanionAdapterProvider.overrideWithValue(fakeWatchAdapter),
          cycleRepositoryProvider.overrideWithValue(fakeCycleRepo),
          healthPlatformAdapterProvider.overrideWithValue(fakeHealthAdapter),
          bleHeartRateAdapterProvider.overrideWithValue(fakeBleAdapter),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const WearablesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Scan button
    await tester.tap(find.text('Scan for Heart Rate Sensors'));
    await tester.pump();

    // Simulate scan active and discovered device
    fakeBleAdapter.emitScanning(scanning: true);
    const testDevice = DiscoveredBleDevice(
      id: 'GARMIN_955',
      name: 'Forerunner 955',
      rssi: -58,
    );
    fakeBleAdapter.emitDiscoveredDevices([testDevice]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Stop Scanning'), findsOneWidget);
    expect(find.text('Discovered Sensors'), findsOneWidget);
    expect(find.text('Forerunner 955'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);

    // Tap Connect
    await tester.tap(find.text('Connect'));
    fakeBleAdapter.emitScanning(scanning: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Connected state
    expect(find.text('Connected'), findsWidgets);
    expect(find.text('Disconnect'), findsOneWidget);

    // Emit live heart rate telemetry
    const measurement = BleHeartRateMeasurement(
      heartRateBpm: 156,
      contactSupported: true,
      contactDetected: true,
    );
    fakeBleAdapter.emitHeartRate(measurement);
    await tester.pumpAndSettle();

    expect(find.text('156'), findsOneWidget);
    expect(find.text('bpm'), findsOneWidget);
    expect(find.text('Skin contact detected'), findsOneWidget);

    // Disconnect
    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();

    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('Scan for Heart Rate Sensors'), findsOneWidget);
  });
}
