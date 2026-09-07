import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

part 'activity.freezed.dart';

/// The kind of activity logged. Mirrors the persisted `activity_type`
/// column (see `core/db/tables/activities.dart`).
enum ActivityType {
  run,
  walk,
  hike,
  ride,
  strength,
  yoga,
  hiit,
  pilates,
  swim,
  other;

  /// Parses the persisted string form, defaulting to [run] for any
  /// unrecognised value.
  static ActivityType fromStorage(String value) {
    return switch (value) {
      'walk' => ActivityType.walk,
      'hike' => ActivityType.hike,
      'ride' => ActivityType.ride,
      'strength' => ActivityType.strength,
      'yoga' => ActivityType.yoga,
      'hiit' => ActivityType.hiit,
      'pilates' => ActivityType.pilates,
      'swim' => ActivityType.swim,
      'other' => ActivityType.other,
      _ => ActivityType.run,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    ActivityType.run => 'run',
    ActivityType.walk => 'walk',
    ActivityType.hike => 'hike',
    ActivityType.ride => 'ride',
    ActivityType.strength => 'strength',
    ActivityType.yoga => 'yoga',
    ActivityType.hiit => 'hiit',
    ActivityType.pilates => 'pilates',
    ActivityType.swim => 'swim',
    ActivityType.other => 'other',
  };

  /// Human-readable display label (title case).
  String get label => switch (this) {
    ActivityType.run => 'Run',
    ActivityType.walk => 'Walk',
    ActivityType.hike => 'Hike',
    ActivityType.ride => 'Ride',
    ActivityType.strength => 'Strength',
    ActivityType.yoga => 'Yoga',
    ActivityType.hiit => 'HIIT',
    ActivityType.pilates => 'Pilates',
    ActivityType.swim => 'Swim',
    ActivityType.other => 'Other',
  };
}

/// Where an activity's data came from. `manual` activities have no
/// `ActivitySample`s; `recorded` ones do (GPS recording arrives in wave
/// C3) — presentation code uses this to decide whether to show a route
/// map.
enum ActivitySource {
  manual,
  recorded;

  /// Parses the persisted string form, defaulting to [manual] for any
  /// unrecognised value.
  static ActivitySource fromStorage(String value) {
    return switch (value) {
      'recorded' => ActivitySource.recorded,
      _ => ActivitySource.manual,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    ActivitySource.manual => 'manual',
    ActivitySource.recorded => 'recorded',
  };
}

/// A logged run/walk/hike/ride.
///
/// Mirrors `core/db/tables/activities.dart` one field at a time; mapping to
/// and from the Drift row happens in `data/drift_activity_repository.dart`
/// so the Drift type never leaks above the data layer (coding_standards.md).
/// [distanceMeters] and [elevationGainMeters] are canonical metric storage —
/// presentation converts via `domain/pace_format.dart`.
@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    required ActivityType activityType,
    required String title,

    /// UTC.
    required DateTime startedAt,

    /// Time actually moving. Equal to [elapsedTime] for manually-logged
    /// activities, which don't track pauses.
    required Duration movingTime,

    /// Total elapsed time, including any stopped time.
    required Duration elapsedTime,
    required double distanceMeters,
    required ActivitySource source,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,
    String? notes,
    double? elevationGainMeters,
    int? avgHeartRate,

    /// The saved route this activity was started from, if any (see
    /// `features/routes/domain/saved_route.dart`). Kept when the route is
    /// later deleted — presentation simply stops resolving a name for it.
    String? routeId,

    /// Type-specific structured metadata (e.g. Strength sets/reps/rest,
    /// HIIT intervals, Yoga/Pilates mindfulness, Swim laps).
    WorkoutDetails? workoutDetails,
  }) = _Activity;

  const Activity._();

  /// Average moving pace, in seconds per kilometre. `null` when
  /// [distanceMeters] is zero (or negative) — pace is undefined without
  /// distance, not zero.
  double? get avgPaceSecondsPerKm {
    if (distanceMeters <= 0) return null;
    final km = distanceMeters / 1000;
    return movingTime.inSeconds / km;
  }

  /// Average moving speed, in kilometres per hour. `0` when [movingTime]
  /// is zero (avoids a divide-by-zero rather than returning an undefined
  /// value — unlike pace, "0 km/h" is a meaningful speed).
  double get avgSpeedKmh {
    if (movingTime.inSeconds <= 0) return 0;
    final hours = movingTime.inSeconds / 3600;
    return (distanceMeters / 1000) / hours;
  }

  /// Rating of Perceived Exertion, 1-10, as stated by the user — `null`
  /// when the workout type doesn't collect one, or when she was asked and
  /// left it unanswered. Never coalesce this to a number; see
  /// [MindfulWorkoutDetails.rpe].
  int? get rpe => switch (workoutDetails) {
    MindfulWorkoutDetails(:final rpe) => rpe,
    GeneralWorkoutDetails(:final rpe) => rpe,
    WearableWorkoutDetails(:final rpe) => rpe,
    _ => null,
  };
}
