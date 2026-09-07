import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/domain/workout_milestone.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';

/// Pure evaluation service that detects newly unlocked personal records,
/// volume milestones, and consistency achievements upon completing a workout.
class MilestoneEvaluator {
  const MilestoneEvaluator();

  /// Evaluates milestones for distance/cardio activities (Run, Walk, Hike, Ride).
  List<WorkoutMilestone> evaluateCardioMilestones({
    required Activity newActivity,
    required PersonalRecords? priorRecords,
    int weeklyWorkoutCount = 1,
    CyclePhase? phase,
    double? phaseLongestDistance,
  }) {
    final milestones = <WorkoutMilestone>[];

    // 1. Cycle-Phase Distance PR
    if (phase != null &&
        phase != CyclePhase.none &&
        newActivity.distanceMeters >= 500) {
      if (phaseLongestDistance != null &&
          newActivity.distanceMeters > phaseLongestDistance) {
        milestones.add(
          WorkoutMilestone(
            type: WorkoutMilestoneType.cyclePhasePr,
            title: '${phase.label} Phase Record! 🌸',
            subtitle:
                '${(newActivity.distanceMeters / 1000).toStringAsFixed(2)} km '
                '— Your longest session during ${phase.label} phase!',
            badgeLabel: '${phase.label} Best',
            isPersonalRecord: true,
          ),
        );
      }
    }

    // 1. Longest Distance PR
    if (newActivity.distanceMeters >= 500) {
      final priorLongest = priorRecords?.longestDistance?.value ?? 0.0;
      if (priorLongest > 0 && newActivity.distanceMeters > priorLongest) {
        final diffKm = ((newActivity.distanceMeters - priorLongest) / 1000)
            .toStringAsFixed(2);
        milestones.add(
          WorkoutMilestone(
            type: WorkoutMilestoneType.longestDistance,
            title: 'New Longest Distance!',
            subtitle:
                '${(newActivity.distanceMeters / 1000).toStringAsFixed(2)} '
                'km (+$diffKm km)',
            badgeLabel: 'Distance PR',
            isPersonalRecord: true,
          ),
        );
      }
    }

    // 2. Most Elevation Gain PR
    final elevation = newActivity.elevationGainMeters;
    if (elevation != null && elevation >= 20) {
      final priorElevation = priorRecords?.mostElevationGain?.value ?? 0.0;
      if (priorElevation > 0 && elevation > priorElevation) {
        final diffM = (elevation - priorElevation).round();
        milestones.add(
          WorkoutMilestone(
            type: WorkoutMilestoneType.mostElevation,
            title: 'Highest Elevation Climb!',
            subtitle: '${elevation.round()} m climbed (+$diffM m)',
            badgeLabel: 'Climb PR',
            isPersonalRecord: true,
          ),
        );
      }
    }

    // 3. Weekly Consistency Milestone
    if (weeklyWorkoutCount >= 3) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.weeklyConsistency,
          title: '$weeklyWorkoutCount Workouts This Week! 🔥',
          subtitle: 'Consistency is your greatest superpower',
          badgeLabel: '$weeklyWorkoutCount× Week',
        ),
      );
    }

    // 4. Default completion milestone if no specific PR
    if (milestones.isEmpty) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.sessionCompleted,
          title: '${newActivity.activityType.label} Completed!',
          subtitle:
              '${(newActivity.distanceMeters / 1000).toStringAsFixed(2)} km '
              'in ${_formatDuration(newActivity.movingTime)}',
          badgeLabel: 'Logged',
        ),
      );
    }

    return milestones;
  }

  /// Evaluates milestones for strength workouts (weight, reps, volume tonnage).
  List<WorkoutMilestone> evaluateStrengthMilestones({
    required Activity newActivity,
    required List<StrengthExercise> exercises,
    required Map<String, double> priorMaxWeights,
    int weeklyWorkoutCount = 1,
    bool isNewRoutine = false,
    CyclePhase? phase,
    Map<String, double>? phaseMaxWeights,
  }) {
    final milestones = <WorkoutMilestone>[];

    // 1. Check Exercise PRs (heaviest weight lifted)
    for (final exercise in exercises) {
      final completedSets = exercise.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isEmpty) continue;

      final sessionMaxWeight = completedSets.fold<double>(
        0,
        (max, s) => s.weightKg > max ? s.weightKg : max,
      );

      if (sessionMaxWeight <= 0) continue;

      final normalizedName = exercise.name.trim().toLowerCase();
      final priorMax = priorMaxWeights[normalizedName];

      if (priorMax != null && priorMax > 0) {
        if (sessionMaxWeight > priorMax) {
          final diff = (sessionMaxWeight - priorMax).toStringAsFixed(1);
          milestones.add(
            WorkoutMilestone(
              type: WorkoutMilestoneType.strengthExercisePr,
              title: 'New PR: ${exercise.name} 🏆',
              subtitle: '${sessionMaxWeight.toStringAsFixed(1)} kg (+$diff kg)',
              badgeLabel: 'Weight PR',
              isPersonalRecord: true,
            ),
          );
        }
      } else if (phase != null &&
          phase != CyclePhase.none &&
          phaseMaxWeights != null) {
        final phaseMax = phaseMaxWeights[normalizedName];
        if (phaseMax != null && sessionMaxWeight > phaseMax) {
          final diff = (sessionMaxWeight - phaseMax).toStringAsFixed(1);
          milestones.add(
            WorkoutMilestone(
              type: WorkoutMilestoneType.cyclePhasePr,
              title: '${phase.label} Peak: ${exercise.name} 🌸',
              subtitle:
                  '${sessionMaxWeight.toStringAsFixed(1)} kg '
                  '(+$diff kg in ${phase.label})',
              badgeLabel: '${phase.label} Peak',
              isPersonalRecord: true,
            ),
          );
        }
      }
    }

    // 2. Session Tonnage Volume Milestone
    final totalTonnage = exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .fold<double>(
          0,
          (sum, s) => sum + (s.reps * s.weightKg),
        );

    if (totalTonnage >= 10000) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.strengthVolumeMilestone,
          title: '10,000 kg Club! 🏆',
          subtitle: 'Moved ${totalTonnage.toStringAsFixed(0)} kg of iron today',
          badgeLabel: '10k Tonnage',
        ),
      );
    } else if (totalTonnage >= 5000) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.strengthVolumeMilestone,
          title: '5,000 kg Milestone! 🐘',
          subtitle:
              'Moved ${totalTonnage.toStringAsFixed(0)} kg — elephant power!',
          badgeLabel: '5k Tonnage',
        ),
      );
    } else if (totalTonnage >= 2500) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.strengthVolumeMilestone,
          title: '2,500 kg Moved! 🏋️',
          subtitle:
              '${totalTonnage.toStringAsFixed(0)} kg total session volume',
          badgeLabel: '2.5k Tonnage',
        ),
      );
    } else if (totalTonnage >= 1000) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.strengthVolumeMilestone,
          title: '1,000 kg Milestone! 💪',
          subtitle:
              '${totalTonnage.toStringAsFixed(0)} kg total session volume',
          badgeLabel: '1k Tonnage',
        ),
      );
    }

    // 3. New Routine Milestone
    if (isNewRoutine) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.routineFirstCompleted,
          title: 'New Routine Mastered! ✨',
          subtitle: 'First time completing ${newActivity.title}',
          badgeLabel: 'New Routine',
        ),
      );
    }

    // 4. Weekly Consistency Milestone
    if (weeklyWorkoutCount >= 3) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.weeklyConsistency,
          title: '$weeklyWorkoutCount Workouts This Week! 🔥',
          subtitle: 'Dedication in motion',
          badgeLabel: '$weeklyWorkoutCount× Week',
        ),
      );
    }

    // 5. Default completion milestone
    if (milestones.isEmpty) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.sessionCompleted,
          title: 'Strength Workout Complete! 💥',
          subtitle:
              '${exercises.length} exercises · '
              '${_formatDuration(newActivity.movingTime)}',
          badgeLabel: 'Crushed It',
        ),
      );
    }

    return milestones;
  }

  /// Evaluates milestones for interval (HIIT), mindful (Yoga/Pilates), swim, or manual workouts.
  List<WorkoutMilestone> evaluateGenericMilestones({
    required Activity newActivity,
    int weeklyWorkoutCount = 1,
    String? customSubtitle,
    CyclePhase? phase,
  }) {
    final milestones = <WorkoutMilestone>[];

    if (phase != null && phase != CyclePhase.none) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.cyclePhasePr,
          title: '${phase.label} Phase ${newActivity.activityType.label} 🌸',
          subtitle:
              'Honoring your energy with mindful movement in your '
              '${phase.label} phase',
          badgeLabel: phase.label,
        ),
      );
    }

    if (weeklyWorkoutCount >= 3) {
      milestones.add(
        WorkoutMilestone(
          type: WorkoutMilestoneType.weeklyConsistency,
          title: '$weeklyWorkoutCount Workouts This Week! 🔥',
          subtitle: 'Consistency builds unstoppable momentum',
          badgeLabel: '$weeklyWorkoutCount× Week',
        ),
      );
    }

    final durationFormatted = _formatDuration(newActivity.movingTime);
    milestones.add(
      WorkoutMilestone(
        type: WorkoutMilestoneType.sessionCompleted,
        title: '${newActivity.activityType.label} Complete! ✨',
        subtitle:
            customSubtitle ?? '$durationFormatted dedicated to your wellbeing',
        badgeLabel: 'Done',
      ),
    );

    return milestones;
  }

  static String _formatDuration(Duration duration) {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    if (duration.inHours > 0) {
      final h = duration.inHours;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s}s';
  }
}
