import 'package:meta/meta.dart';

/// Categories of workout achievements and motivational milestones.
enum WorkoutMilestoneType {
  /// Broken fastest time on a standard distance (e.g. 1k, 5k, 10k).
  runningBestEffort,

  /// New all-time longest distance activity.
  longestDistance,

  /// New all-time highest elevation climb.
  mostElevation,

  /// New heaviest lift or highest reps on a specific strength exercise.
  strengthExercisePr,

  /// Crossing a session tonnage milestone (e.g., 1,000 kg, 2,500 kg, 5,000 kg).
  strengthVolumeMilestone,

  /// Completing a routine for the first time.
  routineFirstCompleted,

  /// Consistency streak or weekly workout frequency milestone (e.g. 3rd
  /// workout this week).
  weeklyConsistency,

  /// Broken fastest pace, longest distance, or heaviest lift during a
  /// specific menstrual cycle phase (e.g. Follicular Best Effort, Luteal Peak).
  cyclePhasePr,

  /// Consistently met daily fueling and protein targets over rolling 7 days.
  fuelingConsistency,

  /// Streak protected during recovery or period day.
  streakShieldActive,

  /// Reached the daily 2,000 ml hydration goal.
  hydrationTargetHit,

  /// Baseline completion milestone celebrating showing up.
  sessionCompleted,
}

/// Represents an individual achievement or personal milestone unlocked
/// during a workout.
@immutable
class WorkoutMilestone {
  const WorkoutMilestone({
    required this.type,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.isPersonalRecord = false,
  });

  /// The category of this milestone.
  final WorkoutMilestoneType type;

  /// Headline title (e.g. "New Personal Record!", "Volume Milestone").
  final String title;

  /// Descriptive detail (e.g. "Barbell Squat: 65.0 kg × 5 reps (+2.5 kg)").
  final String subtitle;

  /// Short badge chip label (e.g. "PR", "5k Best", "5,000 kg", "3× Week").
  final String? badgeLabel;

  /// Whether this milestone represents a newly broken personal record.
  final bool isPersonalRecord;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutMilestone &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          title == other.title &&
          subtitle == other.subtitle &&
          badgeLabel == other.badgeLabel &&
          isPersonalRecord == other.isPersonalRecord;

  @override
  int get hashCode => Object.hash(
    type,
    title,
    subtitle,
    badgeLabel,
    isPersonalRecord,
  );

  @override
  String toString() =>
      'WorkoutMilestone($type, title: $title, subtitle: $subtitle, '
      'isPR: $isPersonalRecord)';
}
