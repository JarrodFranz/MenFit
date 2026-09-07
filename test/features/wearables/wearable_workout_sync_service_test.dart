import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/cycle_repository.dart';
import 'package:menfit_app/features/wearables/domain/wearable_workout_sync_service.dart';

import '../activity/fake_activity_repository.dart';
import '../steps/fake_health_platform_adapter.dart';

class FakeCycleRepository implements CycleRepository {
  List<CycleRecord> records = [];

  @override
  Future<List<CycleRecord>> getRecords() async => List.of(records);

  @override
  Stream<List<CycleRecord>> watchRecords() => Stream.value(records);

  @override
  Future<void> saveRecord(CycleRecord record) async => records.add(record);

  @override
  Future<void> saveRecords(List<CycleRecord> newRecords) async =>
      records.addAll(newRecords);

  @override
  Future<void> deleteRecord(String id) async =>
      records.removeWhere((r) => r.id == id);

  @override
  Stream<bool> watchStreakPausingEnabled() => Stream.value(true);

  @override
  Future<void> clearStreakPausingPreference() async {}

  @override
  Future<void> deleteAllData() async {
    records.clear();
  }

  @override
  Future<void> setStreakPausingEnabled({required bool enabled}) async {}
}

class FakeWatchCompanionAdapter implements WatchCompanionAdapter {
  List<WatchWristWorkout> wristWorkouts = [];
  WatchCompanionInfo? companionInfo;
  WatchCycleContext? lastSentCycleContext;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<WatchCompanionInfo?> getCompanionInfo() async => companionInfo;

  @override
  Future<bool> sendCommand(WatchCommand command) async => true;

  @override
  Future<bool> sendCycleContext(WatchCycleContext context) async {
    lastSentCycleContext = context;
    return true;
  }

  @override
  Stream<WatchMessage> get messageStream => const Stream.empty();

  @override
  Future<List<WatchWristWorkout>> pollOfflineWristWorkouts() async =>
      List.of(wristWorkouts);
}

void main() {
  late FakeHealthPlatformAdapter healthAdapter;
  late FakeWatchCompanionAdapter watchAdapter;
  late FakeActivityRepository activityRepo;
  late FakeCycleRepository cycleRepo;
  late WearableWorkoutSyncService service;

  setUp(() {
    healthAdapter = FakeHealthPlatformAdapter();
    watchAdapter = FakeWatchCompanionAdapter();
    activityRepo = FakeActivityRepository();
    cycleRepo = FakeCycleRepository();
    service = WearableWorkoutSyncService(
      healthAdapter: healthAdapter,
      watchAdapter: watchAdapter,
      activityRepository: activityRepo,
      cycleRepository: cycleRepo,
    );
  });

  group('WearableWorkoutSyncService', () {
    test(
      'syncs completed workout from Garmin Connect and tags cycle phase',
      () async {
        // Setup a logged cycle so the user has an active cycle phase
        // Period started 7 days ago -> currently in Follicular phase
        final today = LocalDate.today();
        final periodStart = today.addDays(-7);
        cycleRepo.records.add(
          CycleRecord(
            id: 'cycle-1',
            periodStart: periodStart,
            periodEnd: periodStart.addDays(4),
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

        final workoutStart = DateTime.now().toUtc().subtract(
          const Duration(hours: 2),
        );
        final workoutEnd = workoutStart.add(const Duration(minutes: 42));

        healthAdapter.workoutsToReturn = [
          HealthWorkoutSession(
            externalId: 'garmin-outdoor-run-001',
            activityType: ActivityType.run,
            title: 'Garmin Run',
            startedAt: workoutStart,
            endedAt: workoutEnd,
            distanceMeters: 7500,
            totalEnergyKcal: 480,
            avgHeartRate: 156,
            sourceName: 'Garmin Connect',
            sourceId: 'com.garmin.android.apps.connectmobile',
          ),
        ];

        final result = await service.syncAll();

        expect(result.syncedCount, 1);
        expect(result.duplicatesSkippedCount, 0);
        expect(result.isSuccess, isTrue);

        final savedActivities = await activityRepo.getActivities();
        expect(savedActivities.length, 1);

        final saved = savedActivities.first;
        expect(saved.activityType, ActivityType.run);
        expect(saved.distanceMeters, 7500.0);
        expect(saved.avgHeartRate, 156);
        expect(saved.workoutDetails, isA<WearableWorkoutDetails>());

        final details = saved.workoutDetails! as WearableWorkoutDetails;
        expect(details.wearableSource, 'Garmin Connect');
        expect(details.externalId, 'garmin-outdoor-run-001');
        expect(details.cyclePhase, 'Follicular');
        expect(details.caloriesBurnedKcal, 480.0);
      },
    );

    test('deduplicates already ingested workouts by externalId', () async {
      healthAdapter.workoutsToReturn = [
        HealthWorkoutSession(
          externalId: 'external-dup-1',
          activityType: ActivityType.walk,
          title: 'Morning Walk',
          startedAt: DateTime.utc(2026, 9, 4, 7),
          endedAt: DateTime.utc(2026, 9, 4, 7, 30),
          distanceMeters: 2500,
          sourceName: 'Apple Watch',
        ),
      ];

      // First sync -> imports 1
      final res1 = await service.syncAll();
      expect(res1.syncedCount, 1);

      // Second sync with same externalId -> skips 1
      final res2 = await service.syncAll();
      expect(res2.syncedCount, 0);
      expect(res2.duplicatesSkippedCount, 1);
    });

    test(
      'syncs offline wrist workout with GPS/HR samples from watch companion',
      () async {
        final start = DateTime.utc(2026, 9, 4, 6);
        final end = DateTime.utc(2026, 9, 4, 6, 25);

        watchAdapter.wristWorkouts = [
          WatchWristWorkout(
            externalId: 'wrist-run-99',
            activityType: ActivityType.run,
            startedAt: start,
            endedAt: end,
            totalDistanceMeters: 4200,
            caloriesBurnedKcal: 310,
            avgHeartRate: 152,
            avgCadence: 168,
            source: 'WearOS Watch',
            samples: [
              WatchWristSample(
                timestamp: start,
                latitude: -33.86,
                longitude: 151.20,
                elevationMeters: 10,
                heartRate: 140,
              ),
              WatchWristSample(
                timestamp: end,
                latitude: -33.87,
                longitude: 151.21,
                elevationMeters: 12,
                heartRate: 155,
              ),
            ],
          ),
        ];

        final result = await service.syncAll();
        expect(result.syncedCount, 1);

        final saved = await activityRepo.getActivities();
        expect(saved.length, 1);
        expect(saved.first.title, 'WearOS Watch Run');
        expect(saved.first.workoutDetails, isA<WearableWorkoutDetails>());

        final samples = await activityRepo.getSamples(saved.first.id);
        expect(samples.length, 2);
        expect(samples.first.heartRate, 140);
      },
    );
  });
}
