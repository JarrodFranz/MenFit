import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/wearables/domain/wearable_workout_sync_service.dart';

import '../activity/fake_activity_repository.dart';
import '../steps/fake_health_platform_adapter.dart';

class FakeWatchCompanionAdapter implements WatchCompanionAdapter {
  List<WatchWristWorkout> wristWorkouts = [];
  WatchCompanionInfo? companionInfo;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<WatchCompanionInfo?> getCompanionInfo() async => companionInfo;

  @override
  Future<bool> sendCommand(WatchCommand command) async => true;

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
  late WearableWorkoutSyncService service;

  setUp(() {
    healthAdapter = FakeHealthPlatformAdapter();
    watchAdapter = FakeWatchCompanionAdapter();
    activityRepo = FakeActivityRepository();
    service = WearableWorkoutSyncService(
      healthAdapter: healthAdapter,
      watchAdapter: watchAdapter,
      activityRepository: activityRepo,
    );
  });

  group('WearableWorkoutSyncService', () {
    test(
      'syncs a completed workout from Garmin Connect into an activity',
      () async {
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
