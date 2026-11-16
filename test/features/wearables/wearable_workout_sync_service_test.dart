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

    group('workout permission gap (steps granted, exercise not)', () {
      HealthWorkoutSession strength() => HealthWorkoutSession(
        externalId: 'garmin-strength-1',
        activityType: ActivityType.strength,
        title: 'Garmin Strength',
        startedAt: DateTime.now().toUtc().subtract(const Duration(hours: 3)),
        endedAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
        sourceName: 'Garmin Connect',
      );

      test('background sync does not prompt and reports the gap', () async {
        healthAdapter
          ..workoutPermissionGranted = false
          ..workoutsToReturn = [strength()];

        final result = await service.syncAll();

        expect(healthAdapter.requestPermissionsCallCount, 0);
        expect(result.syncedCount, 0);
        expect(healthAdapter.workoutReadCallCount, 0);
        expect(result.isSuccess, isFalse);
        expect(
          result.errorMessage,
          WearableWorkoutSyncService.workoutPermissionMissingMessage,
        );
        expect(await activityRepo.getActivities(), isEmpty);
      });

      test('user-initiated sync requests access, then imports', () async {
        healthAdapter
          ..workoutPermissionGranted = false
          ..workoutsToReturn = [strength()];

        final result = await service.syncAll(requestPermissionIfMissing: true);

        expect(healthAdapter.requestPermissionsCallCount, 1);
        expect(healthAdapter.workoutReadCallCount, 1);
        expect(result.isSuccess, isTrue);
        expect(result.syncedCount, 1);
        final saved = await activityRepo.getActivities();
        expect(saved.single.activityType, ActivityType.strength);
      });

      test(
        'user refuses the sheet: reports the gap, imports nothing',
        () async {
          healthAdapter
            ..workoutPermissionGranted = false
            ..denyWorkoutOnRequest = true
            ..workoutsToReturn = [strength()];

          final result = await service.syncAll(
            requestPermissionIfMissing: true,
          );

          expect(healthAdapter.requestPermissionsCallCount, 1);
          expect(healthAdapter.workoutReadCallCount, 0);
          expect(result.isSuccess, isFalse);
          expect(await activityRepo.getActivities(), isEmpty);
        },
      );

      test('undisclosed iOS access requests only on explicit sync', () async {
        healthAdapter
          ..workoutPermissionGranted = null
          ..workoutsToReturn = [strength()];

        final background = await service.syncAll();
        expect(background.syncedCount, 1);
        expect(healthAdapter.requestPermissionsCallCount, 0);
        expect(healthAdapter.workoutReadCallCount, 1);

        await service.syncAll(requestPermissionIfMissing: true);
        expect(healthAdapter.requestPermissionsCallCount, 1);
        expect(healthAdapter.workoutReadCallCount, 2);
        expect(await healthAdapter.hasWorkoutPermission(), isNull);

        await service.syncAll(requestPermissionIfMissing: true);
        expect(healthAdapter.requestPermissionsCallCount, 2);
        expect(healthAdapter.workoutReadCallCount, 3);
      });

      test(
        'undisclosed denied access stays an empty read after requesting',
        () async {
          healthAdapter
            ..workoutPermissionGranted = null
            ..denyWorkoutOnRequest = true;

          final result = await service.syncAll(
            requestPermissionIfMissing: true,
          );
          expect(healthAdapter.requestPermissionsCallCount, 1);
          expect(healthAdapter.workoutReadCallCount, 1);
          expect(result.syncedCount, 0);
          expect(await activityRepo.getActivities(), isEmpty);
        },
      );

      test(
        'failed authorization with unknown access skips the health read',
        () async {
          healthAdapter
            ..workoutPermissionGranted = null
            ..permissionRequestSucceeds = false
            ..workoutsToReturn = [strength()];

          final result = await service.syncAll(
            requestPermissionIfMissing: true,
          );

          expect(healthAdapter.requestPermissionsCallCount, 1);
          expect(await healthAdapter.hasWorkoutPermission(), isNull);
          expect(healthAdapter.workoutReadCallCount, 0);
          expect(result.isSuccess, isFalse);
          expect(
            result.errorMessage,
            WearableWorkoutSyncService.workoutPermissionMissingMessage,
          );
          expect(result.syncedCount, 0);
          expect(await activityRepo.getActivities(), isEmpty);
        },
      );

      test('already granted: never re-prompts', () async {
        healthAdapter.workoutsToReturn = [strength()];

        await service.syncAll(requestPermissionIfMissing: true);

        expect(healthAdapter.requestPermissionsCallCount, 0);
      });
    });

    test(
      'unsupported health skips permissions and still imports wrist strength',
      () async {
        healthAdapter
          ..supported = false
          ..workoutPermissionGranted = false;
        watchAdapter.wristWorkouts = [
          WatchWristWorkout(
            externalId: 'wrist-strength',
            activityType: ActivityType.strength,
            startedAt: DateTime.utc(2026, 9, 4, 6),
            endedAt: DateTime.utc(2026, 9, 4, 7),
            totalDistanceMeters: 130,
            source: 'Watch',
          ),
        ];
        final result = await service.syncAll(requestPermissionIfMissing: true);
        expect(result.isSuccess, isTrue);
        expect(result.syncedCount, 1);
        expect(healthAdapter.requestPermissionsCallCount, 0);
        expect(healthAdapter.workoutReadCallCount, 0);
        expect((await activityRepo.getActivities()).single.distanceMeters, 0);
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

    test(
      'a strength session carrying overlapping step distance is imported '
      'with no distance; a run in the same sync keeps its distance',
      () async {
        final start = DateTime.now().toUtc().subtract(const Duration(hours: 5));
        healthAdapter.workoutsToReturn = [
          HealthWorkoutSession(
            externalId: 'garmin-strength-distance',
            activityType: ActivityType.strength,
            title: 'Garmin Strength',
            startedAt: start,
            endedAt: start.add(const Duration(minutes: 38, seconds: 42)),
            distanceMeters: 130,
            sourceName: 'Garmin Connect',
          ),
          HealthWorkoutSession(
            externalId: 'garmin-run-distance',
            activityType: ActivityType.run,
            title: 'Garmin Run',
            startedAt: start.add(const Duration(hours: 2)),
            endedAt: start.add(const Duration(hours: 2, minutes: 30)),
            distanceMeters: 5000,
            sourceName: 'Garmin Connect',
          ),
        ];

        final result = await service.syncAll();
        expect(result.syncedCount, 2);

        final saved = await activityRepo.getActivities();
        final strength = saved.singleWhere(
          (a) => a.activityType == ActivityType.strength,
        );
        final run = saved.singleWhere(
          (a) => a.activityType == ActivityType.run,
        );
        expect(strength.distanceMeters, 0);
        expect(strength.hasDistance, isFalse);
        expect(strength.avgPaceSecondsPerKm, isNull);
        expect(run.distanceMeters, 5000);
      },
    );
  });
}
