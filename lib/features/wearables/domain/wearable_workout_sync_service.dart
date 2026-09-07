import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/cycle_repository.dart';

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
/// wearables (Garmin Connect, Apple Watch, WearOS) with menstrual
/// cycle-phase tagging.
class WearableWorkoutSyncService {
  WearableWorkoutSyncService({
    required this.healthAdapter,
    required this.watchAdapter,
    required this.activityRepository,
    required this.cycleRepository,
    CyclePredictionEngine? predictionEngine,
  }) : predictionEngine = predictionEngine ?? CyclePredictionEngine();

  final HealthPlatformAdapter healthAdapter;
  final WatchCompanionAdapter watchAdapter;
  final ActivityRepository activityRepository;
  final CycleRepository cycleRepository;
  final CyclePredictionEngine predictionEngine;

  /// Syncs completed workouts from Health Connect / Apple Health and connected
  /// watch companions, tagging each with the hormonal cycle phase.
  Future<WearableSyncResult> syncAll({DateTime? since}) async {
    try {
      final now = DateTime.now().toUtc();
      final startTime = since ?? now.subtract(const Duration(days: 30));

      final existingActivities = await activityRepository.getActivities();
      final cycleRecords = await cycleRepository.getRecords();
      final today = LocalDate.today();

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
      final healthWorkouts = await healthAdapter.getCompletedWorkouts(
        start: startTime,
        end: now,
      );

      for (final session in healthWorkouts) {
        if (_isDuplicateHealthWorkout(
          session,
          existingActivities,
          knownExternalIds,
        )) {
          skippedCount++;
          continue;
        }

        final cyclePhase = _resolveCyclePhase(
          session.startedAt,
          cycleRecords,
          today,
        );
        final activity = _createActivityFromHealthSession(
          session,
          cyclePhase,
          now,
        );

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

        final cyclePhase = _resolveCyclePhase(
          wristWorkout.startedAt,
          cycleRecords,
          today,
        );
        final (activity, samples) = _createActivityFromWristWorkout(
          wristWorkout,
          cyclePhase,
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

  String? _resolveCyclePhase(
    DateTime startedAt,
    List<CycleRecord> cycleRecords,
    LocalDate today,
  ) {
    try {
      final date = LocalDate.fromDateTime(startedAt);
      final status = predictionEngine.getDayStatus(
        date: date,
        records: cycleRecords,
        today: today,
      );
      return status.phase != CyclePhase.none ? status.phase.label : null;
    } on Object catch (_) {
      return null;
    }
  }

  Activity _createActivityFromHealthSession(
    HealthWorkoutSession session,
    String? cyclePhase,
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
      cyclePhase: cyclePhase,
      caloriesBurnedKcal: session.totalEnergyKcal,
    );

    return Activity(
      id: activityId,
      activityType: session.activityType,
      title: session.title,
      startedAt: session.startedAt,
      movingTime: session.duration,
      elapsedTime: session.duration,
      distanceMeters: session.distanceMeters ?? 0.0,
      avgHeartRate: session.avgHeartRate,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );
  }

  (Activity, List<ActivitySample>) _createActivityFromWristWorkout(
    WatchWristWorkout workout,
    String? cyclePhase,
    DateTime now,
  ) {
    final activityId = EntityId.generate();
    final details = WearableWorkoutDetails(
      wearableSource: workout.source,
      externalId: workout.externalId,
      cyclePhase: cyclePhase,
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
      distanceMeters: workout.totalDistanceMeters,
      avgHeartRate: workout.avgHeartRate,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );

    return (activity, samples);
  }
}
