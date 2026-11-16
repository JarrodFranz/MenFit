import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:menfit_app/core/platform/health/health_platform_stub.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';

class MockHealthPlatformAdapter implements HealthPlatformAdapter {
  MockHealthPlatformAdapter({
    this.supported = true,
    this.permissionsGranted = true,
    this.stepsToReturn = 7500,
    this.activeCaloriesToReturn = 320,
    this.workoutsToReturn = const [],
  });

  bool supported;
  bool permissionsGranted;
  int stepsToReturn;
  double? activeCaloriesToReturn;
  List<HealthWorkoutSession> workoutsToReturn;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> hasPermissions() async => permissionsGranted;

  @override
  Future<bool> hasStepsPermission() async => permissionsGranted;

  @override
  Future<bool> hasWorkoutPermission() async => permissionsGranted;

  @override
  Future<bool> requestPermissions() async {
    permissionsGranted = true;
    return true;
  }

  @override
  Future<HealthDataSnapshot?> getSnapshotForDate(LocalDate date) async {
    if (!permissionsGranted) return null;
    return HealthDataSnapshot(
      date: date,
      steps: stepsToReturn,
      activeCaloriesKcal: activeCaloriesToReturn,
      lastSyncedAt: DateTime.utc(2026, 8, 29),
      source: 'Mock Health',
    );
  }

  @override
  Future<List<DailyStepTotal>> getDailyStepTotals(
    LocalDate start,
    LocalDate end,
  ) async {
    if (!permissionsGranted) return const [];
    return [
      DailyStepTotal(date: start, steps: stepsToReturn, source: 'Mock Health'),
    ];
  }

  @override
  Future<List<HealthWorkoutSession>> getCompletedWorkouts({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!permissionsGranted) return const [];
    return workoutsToReturn;
  }
}

void main() {
  group('StubHealthPlatformAdapter', () {
    test('stub defaults safely to unsupported with empty records', () async {
      const stub = StubHealthPlatformAdapter();
      expect(await stub.isSupported(), isFalse);
      expect(await stub.hasPermissions(), isFalse);
      expect(await stub.hasStepsPermission(), isFalse);
      expect(await stub.requestPermissions(), isFalse);
      expect(await stub.getSnapshotForDate(LocalDate.today()), isNull);
      expect(
        await stub.getDailyStepTotals(LocalDate.today(), LocalDate.today()),
        isEmpty,
      );
    });
  });

  group('HealthSyncNotifier', () {
    test(
      'initializes and syncs today data when permissions are granted',
      () async {
        final mock = MockHealthPlatformAdapter(
          stepsToReturn: 8400,
        );

        final element = ProviderContainer(
          overrides: [
            healthPlatformAdapterProvider.overrideWithValue(mock),
          ],
        );

        final notifier = element.read(healthSyncProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = element.read(healthSyncProvider);
        expect(notifier, isNotNull);
        expect(state.isSupported, isTrue);
        expect(state.hasPermissions, isTrue);
        expect(state.latestSnapshot?.steps, equals(8400));
        expect(state.latestSnapshot?.source, equals('Mock Health'));

        element.dispose();
      },
    );

    test(
      'requestPermissions requests from adapter and updates state',
      () async {
        final mock = MockHealthPlatformAdapter(
          permissionsGranted: false,
          stepsToReturn: 5200,
        );

        final element = ProviderContainer(
          overrides: [
            healthPlatformAdapterProvider.overrideWithValue(mock),
          ],
        );

        final notifier = element.read(healthSyncProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(element.read(healthSyncProvider).hasPermissions, isFalse);

        final granted = await notifier.requestPermissions();
        expect(granted, isTrue);
        expect(element.read(healthSyncProvider).hasPermissions, isTrue);
        expect(
          element.read(healthSyncProvider).latestSnapshot?.steps,
          equals(5200),
        );

        element.dispose();
      },
    );
  });
}
