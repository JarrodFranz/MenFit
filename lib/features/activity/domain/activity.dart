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

  /// Whether distance is a meaningful measure of this kind of activity -
  /// the single predicate every distance reader goes through.
  ///
  /// `false` for strength, yoga, HIIT and pilates: a wearable that sums the
  /// platform's distance records over such a session's window picks up the
  /// steps walked between sets, so any distance attached to one is noise.
  /// [other] stays `true` because it covers both manual "other" entries with
  /// a typed distance and wearable sessions the mapper could not classify
  /// (rowing, skiing, skating) where distance is real.
  bool get tracksDistance => switch (this) {
    ActivityType.run ||
    ActivityType.walk ||
    ActivityType.hike ||
    ActivityType.ride ||
    ActivityType.swim ||
    ActivityType.other => true,
    ActivityType.strength ||
    ActivityType.yoga ||
    ActivityType.hiit ||
    ActivityType.pilates => false,
  };

  /// [meters] as this type may count it: unchanged when it [tracksDistance],
  /// otherwise `0` (the stored "no distance" value - the column is not
  /// nullable). Applied when activities are read and written, so totals,
  /// badges, charts and stat tiles never see a non-distance type's distance.
  double countedDistanceMeters(double meters) => tracksDistance ? meters : 0;
}

/// Display threshold for average pace; short records may contain incidental
/// distance. This is a presentation heuristic, not a physiological limit.
const double minPaceDistanceMeters = 200;

/// Slowest average pace displayed (60:00 /km), a presentation heuristic
/// for incidental distance rather than a judgement of the activity.
const double maxPlausiblePaceSecondsPerKm = 3600;

/// Parses the `:type` segment of `/activity/hub/:type`, defaulting to
/// [ActivityType.strength] for anything unrecognised.
///
/// Deliberately *not* [ActivityType.fromStorage], which defaults to
/// [ActivityType.run] and must keep doing so: it reads persisted rows,
/// where an unknown value is most likely a run written by another build.
/// A hub URL that does not parse is a navigation bug instead, and MenFit
/// is strength-first — silently landing on the Run hub would contradict
/// the product rather than degrade gracefully.
ActivityType hubTypeFromRoute(String raw) {
  for (final type in ActivityType.values) {
    if (type.toStorage() == raw) return type;
  }
  return ActivityType.strength;
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

  /// Whether this activity has a distance worth showing: its type
  /// [ActivityType.tracksDistance] and a positive distance was recorded.
  bool get hasDistance => activityType.tracksDistance && distanceMeters > 0;

  /// Average moving pace, in seconds per kilometre. `null` — pace
  /// undefined, never zero — when the type does not track distance, when
  /// [distanceMeters] is under [minPaceDistanceMeters], or when the result
  /// would be slower than [maxPlausiblePaceSecondsPerKm] (a 0.13 km
  /// "distance" over a 38-minute session is not a 295:25 /km pace).
  double? get avgPaceSecondsPerKm {
    if (!activityType.tracksDistance) return null;
    if (!distanceMeters.isFinite || distanceMeters < minPaceDistanceMeters) {
      return null;
    }
    final pace = movingTime.inSeconds / (distanceMeters / 1000);
    if (pace <= 0 || pace > maxPlausiblePaceSecondsPerKm) return null;
    return pace;
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
  /// when the workout type doesn't collect one, or when they were asked and
  /// left it unanswered. Never coalesce this to a number; see
  /// [MindfulWorkoutDetails.rpe].
  int? get rpe => switch (workoutDetails) {
    MindfulWorkoutDetails(:final rpe) => rpe,
    GeneralWorkoutDetails(:final rpe) => rpe,
    WearableWorkoutDetails(:final rpe) => rpe,
    _ => null,
  };
}
