import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

/// Fixture builders shared by the achievements tests.
///
/// Every one takes a **local** `DateTime` for `startedAt` where the local
/// calendar day or the hour matters, because that is what the metric layer
/// reads (`LocalDate.fromDateTime(startedAt.toLocal())`). A UTC instant
/// here would make an "early bird" test pass or fail on the machine's
/// timezone rather than on the code.
final DateTime fixtureStamp = DateTime.utc(2026);

int _sequence = 0;

/// Resets the fixture id counter, so ids are stable within a test.
void resetFixtureIds() => _sequence = 0;

/// [elevationGainMeters] defaults to `null`, which is what the great
/// majority of real activities carry: manual entry has no elevation field,
/// so only GPS-recorded and file-imported sessions have a number here. A
/// fixture that defaulted it to `0` would quietly stop the absence case
/// from ever being exercised.
Activity activityFixture({
  required ActivityType type,
  required DateTime startedAt,
  double distanceMeters = 0,
  Duration movingTime = const Duration(minutes: 30),
  double? elevationGainMeters,
  WorkoutDetails? workoutDetails,
}) {
  return Activity(
    id: 'activity-${_sequence++}',
    activityType: type,
    title: '${type.label} session',
    startedAt: startedAt,
    movingTime: movingTime,
    elapsedTime: movingTime,
    distanceMeters: distanceMeters,
    elevationGainMeters: elevationGainMeters,
    source: ActivitySource.manual,
    createdAt: fixtureStamp,
    updatedAt: fixtureStamp,
    workoutDetails: workoutDetails,
  );
}

/// A swim of [laps] lengths of [poolLengthMeters], with [distanceMeters]
/// stored alongside it — pass `0` for the laps-only case that the metric's
/// fallback exists for.
Activity swimFixture({
  required DateTime startedAt,
  int laps = 0,
  double poolLengthMeters = 25,
  double distanceMeters = 0,
}) {
  return activityFixture(
    type: ActivityType.swim,
    startedAt: startedAt,
    distanceMeters: distanceMeters,
    workoutDetails: SwimWorkoutDetails(
      laps: laps,
      poolLengthMeters: poolLengthMeters,
    ),
  );
}

/// An interval session of [completedRounds] out of [totalRounds].
Activity hiitFixture({
  required DateTime startedAt,
  int totalRounds = 8,
  int? completedRounds,
  ActivityType type = ActivityType.hiit,
}) {
  return activityFixture(
    type: type,
    startedAt: startedAt,
    workoutDetails: HiitWorkoutDetails(
      workSeconds: 40,
      restSeconds: 20,
      totalRounds: totalRounds,
      completedRounds: completedRounds ?? totalRounds,
    ),
  );
}

/// A walk of [metres] on [day], at a neutral mid-morning hour so it lands
/// in neither the early-bird nor the night-owl window.
Activity walkFixture(LocalDate day, double metres) {
  return activityFixture(
    type: ActivityType.walk,
    startedAt: DateTime(day.year, day.month, day.day, 10),
    distanceMeters: metres,
  );
}

/// A walk on [day] carrying [climbMetres] of recorded climbing — pass a
/// negative value for the corrupt-row case the ascent metric clamps.
Activity walkFixtureWithClimb(LocalDate day, double climbMetres) {
  return activityFixture(
    type: ActivityType.walk,
    startedAt: DateTime(day.year, day.month, day.day, 10),
    elevationGainMeters: climbMetres,
  );
}

/// A strength session whose completed sets total [completedKg], with an
/// extra unfinished set worth [uncompletedKg] that must not be counted.
Activity strengthFixture({
  required DateTime startedAt,
  required double completedKg,
  double uncompletedKg = 0,
}) {
  return activityFixture(
    type: ActivityType.strength,
    startedAt: startedAt,
    workoutDetails: StrengthWorkoutDetails(
      exercises: [
        StrengthExercise(
          name: 'Squat',
          sets: [
            StrengthSet(setNumber: 1, reps: 1, weightKg: completedKg),
            if (uncompletedKg > 0)
              StrengthSet(
                setNumber: 2,
                reps: 1,
                weightKg: uncompletedKg,
                isCompleted: false,
              ),
          ],
        ),
      ],
    ),
  );
}

/// The set of [LocalDate]s from [start] through [end], inclusive.
Set<LocalDate> daysBetween(LocalDate start, LocalDate end) {
  final days = <LocalDate>{};
  var cursor = start;
  while (!cursor.isAfter(end)) {
    days.add(cursor);
    cursor = cursor.addDays(1);
  }
  return days;
}
