import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

/// The result of a wearable synchronization run.
class WearableSyncResult {
  const WearableSyncResult({
    required this.syncedCount,
    required this.duplicatesSkippedCount,
    required this.syncedAt,
    this.importedActivityTitles = const [],
    this.errorMessage,
  });

  factory WearableSyncResult.empty() => WearableSyncResult(
    syncedCount: 0,
    duplicatesSkippedCount: 0,
    syncedAt: DateTime.now().toUtc(),
  );

  final int syncedCount;
  final int duplicatesSkippedCount;
  final DateTime syncedAt;
  final List<String> importedActivityTitles;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

/// Service orchestrating the auto-sync and ingestion of workouts from external
/// wearables (Garmin Connect, Apple Watch, WearOS).
class WearableWorkoutSyncService {
  WearableWorkoutSyncService({
    required this.healthAdapter,
    required this.watchAdapter,
    required this.activityRepository,
  });

  final HealthPlatformAdapter healthAdapter;
  final WatchCompanionAdapter watchAdapter;
  final ActivityRepository activityRepository;

  static const workoutPermissionMissingMessage =
      'Workout access is not granted. Allow Exercise and Distance for '
      'MenFit in Health Connect / Apple Health, then sync again.';

  /// Syncs completed workouts from Health Connect / Apple Health and connected
  /// watch companions.
  /// Only user-initiated sync may request missing permissions.
  Future<WearableSyncResult> syncAll({
    DateTime? since,
    bool requestPermissionIfMissing = false,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final startTime = since ?? now.subtract(const Duration(days: 30));

      final existingActivities = await activityRepository.getActivities();

      // Collect external IDs and timestamps of already imported activities
      final knownExternalIds = <String>{};
      for (final a in existingActivities) {
        if (a.workoutDetails is WearableWorkoutDetails) {
          final id = (a.workoutDetails! as WearableWorkoutDetails).externalId;
          if (id != null) knownExternalIds.add(id);
        }
      }

      var syncedCount = 0;
      var skippedCount = 0;
      final importedTitles = <String>[];

      // 1. Sync completed workouts from HealthPlatform (Garmin Connect / HealthKit / Health Connect)
      String? permissionNotice;
      var healthWorkouts = const <HealthWorkoutSession>[];
      if (await healthAdapter.isSupported()) {
        var canRead = await healthAdapter.hasWorkoutPermission();
        if (canRead != true && requestPermissionIfMissing) {
          final requested = await healthAdapter.requestPermissions();
          canRead = requested
              ? await healthAdapter.hasWorkoutPermission()
              : false;
        }
        if (canRead != false) {
          healthWorkouts = await healthAdapter.getCompletedWorkouts(
            start: startTime,
            end: now,
          );
        } else {
          permissionNotice = workoutPermissionMissingMessage;
        }
      }

      for (final session in healthWorkouts) {
        if (_isDuplicateHealthWorkout(
          session,
          existingActivities,
          knownExternalIds,
        )) {
          skippedCount++;
          continue;
        }

        final activity = _createActivityFromHealthSession(session, now);

        await activityRepository.saveActivity(activity);
        knownExternalIds.add(session.externalId);
        syncedCount++;
        importedTitles.add(activity.title);
      }

      // 2. Sync standalone wrist workouts from WatchCompanionAdapter (Apple Watch / WearOS)
      final wristWorkouts = await watchAdapter.pollOfflineWristWorkouts();
      for (final wristWorkout in wristWorkouts) {
        if (_isDuplicateWristWorkout(
          wristWorkout,
          existingActivities,
          knownExternalIds,
        )) {
          skippedCount++;
          continue;
        }

        final (activity, samples) = _createActivityFromWristWorkout(
          wristWorkout,
          now,
        );

        if (samples.isNotEmpty) {
          await activityRepository.saveRecordedActivity(activity, samples);
        } else {
          await activityRepository.saveActivity(activity);
        }

        knownExternalIds.add(wristWorkout.externalId);
        syncedCount++;
        importedTitles.add(activity.title);
      }

      return WearableSyncResult(
        syncedCount: syncedCount,
        duplicatesSkippedCount: skippedCount,
        syncedAt: now,
        importedActivityTitles: importedTitles,
        errorMessage: permissionNotice,
      );
    } on Object catch (e) {
      return WearableSyncResult(
        syncedCount: 0,
        duplicatesSkippedCount: 0,
        syncedAt: DateTime.now().toUtc(),
        errorMessage: e.toString(),
      );
    }
  }

  bool _isDuplicateHealthWorkout(
    HealthWorkoutSession session,
    List<Activity> existing,
    Set<String> knownExternalIds,
  ) {
    if (knownExternalIds.contains(session.externalId)) return true;

    // Guard against re-importing identical activity by timestamp and type
    for (final a in existing) {
      if (a.activityType == session.activityType) {
        final diffSeconds = a.startedAt
            .difference(session.startedAt)
            .inSeconds
            .abs();
        if (diffSeconds < 90) return true;
      }
    }
    return false;
  }

  bool _isDuplicateWristWorkout(
    WatchWristWorkout workout,
    List<Activity> existing,
    Set<String> knownExternalIds,
  ) {
    if (knownExternalIds.contains(workout.externalId)) return true;

    for (final a in existing) {
      if (a.activityType == workout.activityType) {
        final diffSeconds = a.startedAt
            .difference(workout.startedAt)
            .inSeconds
            .abs();
        if (diffSeconds < 90) return true;
      }
    }
    return false;
  }

  Activity _createActivityFromHealthSession(
    HealthWorkoutSession session,
    DateTime now,
  ) {
    final activityId = EntityId.generate();
    final sourceLabel = session.isGarmin
        ? 'Garmin Connect'
        : (session.isAppleWatch
              ? 'Apple Watch'
              : (session.isWearOs ? 'WearOS' : session.sourceName));

    final details = WearableWorkoutDetails(
      wearableSource: sourceLabel,
      externalId: session.externalId,
      caloriesBurnedKcal: session.totalEnergyKcal,
    );

    return Activity(
      id: activityId,
      activityType: session.activityType,
      title: session.title,
      startedAt: session.startedAt,
      movingTime: session.duration,
      elapsedTime: session.duration,
      distanceMeters: session.activityType.countedDistanceMeters(
        session.distanceMeters ?? 0.0,
      ),
      avgHeartRate: session.avgHeartRate,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );
  }

  (Activity, List<ActivitySample>) _createActivityFromWristWorkout(
    WatchWristWorkout workout,
    DateTime now,
  ) {
    final activityId = EntityId.generate();
    final details = WearableWorkoutDetails(
      wearableSource: workout.source,
      externalId: workout.externalId,
      caloriesBurnedKcal: workout.caloriesBurnedKcal,
      avgCadence: workout.avgCadence,
    );

    final samples = workout.samples.map((s) {
      return ActivitySample(
        id: EntityId.generate(),
        activityId: activityId,
        timestamp: s.timestamp,
        latitude: s.latitude,
        longitude: s.longitude,
        elevationMeters: s.elevationMeters,
        heartRate: s.heartRate,
      );
    }).toList();

    final activity = Activity(
      id: activityId,
      activityType: workout.activityType,
      title: '${workout.source} ${workout.activityType.label}',
      startedAt: workout.startedAt,
      movingTime: workout.duration,
      elapsedTime: workout.duration,
      distanceMeters: workout.activityType.countedDistanceMeters(
        workout.totalDistanceMeters,
      ),
      avgHeartRate: workout.avgHeartRate,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );

    return (activity, samples);
  }
}
