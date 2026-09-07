import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_hub_providers.g.dart';

/// Aggregated metrics for a specific exercise type hub.
class ExerciseHubStats {
  const ExerciseHubStats({
    required this.type,
    required this.totalActivities,
    required this.totalDuration,
    required this.totalDistanceMeters,
    required this.totalElevationGainMeters,
    required this.totalVolumeKg,
    required this.totalSets,
    required this.totalLaps,
    required this.totalRounds,
    this.primaryFocusOrStyle,
  });

  final ActivityType type;
  final int totalActivities;
  final Duration totalDuration;
  final double totalDistanceMeters;
  final double totalElevationGainMeters;
  final double totalVolumeKg;
  final int totalSets;
  final int totalLaps;
  final int totalRounds;
  final String? primaryFocusOrStyle;

  double get totalDistanceKm => totalDistanceMeters / 1000.0;
  double get totalDistanceMiles => totalDistanceKm * 0.621371;

  double get avgPaceSecondsPerKm {
    if (totalDistanceKm <= 0) return 0;
    return totalDuration.inSeconds / totalDistanceKm;
  }
}

/// Streams all activities matching [ActivityType], ordered chronologically.
@riverpod
Stream<List<Activity>> exerciseHubActivities(Ref ref, ActivityType type) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActivities().map((list) {
    return list.where((a) => a.activityType == type).toList();
  });
}

/// Calculates aggregated statistics for [ActivityType].
@riverpod
ExerciseHubStats exerciseHubStats(Ref ref, ActivityType type) {
  final activities =
      ref.watch(exerciseHubActivitiesProvider(type)).value ?? const [];

  var totalSeconds = 0;
  var totalDistance = 0.0;
  var totalElevation = 0.0;
  var totalVolume = 0.0;
  var totalSets = 0;
  var totalLaps = 0;
  var totalRounds = 0;
  final styleCounts = <String, int>{};

  for (final a in activities) {
    totalSeconds += a.movingTime.inSeconds;
    totalDistance += a.distanceMeters;
    totalElevation += a.elevationGainMeters ?? 0.0;

    final details = a.workoutDetails;
    if (details is StrengthWorkoutDetails) {
      totalVolume += details.totalVolumeKg;
      totalSets += details.totalSets;
    } else if (details is SwimWorkoutDetails) {
      totalLaps += details.laps;
    } else if (details is HiitWorkoutDetails) {
      totalRounds += details.completedRounds;
    } else if (details is MindfulWorkoutDetails) {
      final style = details.style;
      if (style.isNotEmpty) {
        styleCounts[style] = (styleCounts[style] ?? 0) + 1;
      }
    }
  }

  String? primaryStyle;
  if (styleCounts.isNotEmpty) {
    primaryStyle = styleCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  return ExerciseHubStats(
    type: type,
    totalActivities: activities.length,
    totalDuration: Duration(seconds: totalSeconds),
    totalDistanceMeters: totalDistance,
    totalElevationGainMeters: totalElevation,
    totalVolumeKg: totalVolume,
    totalSets: totalSets,
    totalLaps: totalLaps,
    totalRounds: totalRounds,
    primaryFocusOrStyle: primaryStyle,
  );
}
