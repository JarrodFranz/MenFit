import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

void main() {
  group('StrengthWorkoutDetails', () {
    test(
      'calculates volume, completed sets, reps, and avg rest accurately',
      () {
        const details = StrengthWorkoutDetails(
          exercises: [
            StrengthExercise(
              name: 'Barbell Squat',
              sets: [
                StrengthSet(
                  setNumber: 1,
                  reps: 10,
                  weightKg: 60,
                  durationSeconds: 30,
                  restSeconds: 90,
                ),
                StrengthSet(
                  setNumber: 2,
                  reps: 8,
                  weightKg: 70,
                  durationSeconds: 28,
                  restSeconds: 120,
                ),
                StrengthSet(
                  setNumber: 3,
                  reps: 6,
                  weightKg: 80,
                  durationSeconds: 25,
                  isCompleted: false, // Incomplete set should not count toward completed sets/reps
                ),
              ],
            ),
            StrengthExercise(
              name: 'Bench Press',
              sets: [
                StrengthSet(
                  setNumber: 1,
                  reps: 10,
                  weightKg: 40,
                  durationSeconds: 25,
                  restSeconds: 60,
                ),
              ],
            ),
          ],
        );

        // Volume = (10*60) + (8*70) + (6*80) + (10*40)
        //        = 600 + 560 + 480 + 400 = 2040
        expect(details.totalVolumeKg, 2040.0);
        expect(details.totalSets, 3);
        expect(details.totalReps, 28);
        // Avg rest = (90 + 120 + 60) / 3 = 90.0
        expect(details.avgRestSeconds, 90.0);

        // Serialization round-trip
        final jsonStr = details.toStorage();
        final decoded =
            WorkoutDetails.fromStorage(jsonStr) as StrengthWorkoutDetails?;
        expect(decoded, isNotNull);
        expect(decoded!.exercises.length, 2);
        expect(decoded.exercises.first.name, 'Barbell Squat');
        expect(decoded.exercises.first.sets.length, 3);
        expect(decoded.totalVolumeKg, 2040.0);
      },
    );
  });

  group('HiitWorkoutDetails', () {
    test('calculates work and rest times and round-trips JSON', () {
      const details = HiitWorkoutDetails(
        workSeconds: 40,
        restSeconds: 20,
        totalRounds: 8,
        completedRounds: 8,
        intervalExercises: ['Burpees', 'Mountain Climbers'],
      );

      expect(details.totalWorkTimeSeconds, 320); // 8 * 40
      expect(details.totalRestTimeSeconds, 140); // 7 * 20

      final jsonStr = details.toStorage();
      final decoded =
          WorkoutDetails.fromStorage(jsonStr) as HiitWorkoutDetails?;
      expect(decoded, isNotNull);
      expect(decoded!.workSeconds, 40);
      expect(decoded.restSeconds, 20);
      expect(decoded.completedRounds, 8);
      expect(decoded.intervalExercises, ['Burpees', 'Mountain Climbers']);
    });
  });

  group('MindfulWorkoutDetails', () {
    test('an unanswered RPE round-trips as null and omits the JSON key', () {
      // "Never asked" must stay distinguishable from "answered": a hard
      // default here is what kept every perceived-exertion insight
      // dormant (see insight_observation_mapper.dart).
      const details = MindfulWorkoutDetails();
      expect(details.rpe, isNull);

      final json = details.toJson();
      expect(json.containsKey('rpe'), isFalse);

      final parsed = WorkoutDetails.fromJson(json);
      expect((parsed as MindfulWorkoutDetails?)?.rpe, isNull);
    });

    test('round-trips Yoga/Pilates data', () {
      const details = MindfulWorkoutDetails(
        style: 'Yin Yoga',
        focusArea: 'Hip Opening & Spine',
        rpe: 5,
        poses: ['Dragon Pose', 'Pigeon Pose'],
      );

      final jsonStr = details.toStorage();
      final decoded =
          WorkoutDetails.fromStorage(jsonStr) as MindfulWorkoutDetails?;
      expect(decoded, isNotNull);
      expect(decoded!.style, 'Yin Yoga');
      expect(decoded.focusArea, 'Hip Opening & Spine');
      expect(decoded.rpe, 5);
      expect(decoded.poses, ['Dragon Pose', 'Pigeon Pose']);
    });
  });

  group('SwimWorkoutDetails', () {
    test('computes total distance and round-trips JSON', () {
      const details = SwimWorkoutDetails(
        poolLengthMeters: 50,
        laps: 30,
      );

      expect(details.calculatedDistanceMeters, 1500.0);

      final jsonStr = details.toStorage();
      final decoded =
          WorkoutDetails.fromStorage(jsonStr) as SwimWorkoutDetails?;
      expect(decoded, isNotNull);
      expect(decoded!.poolLengthMeters, 50.0);
      expect(decoded.laps, 30);
      expect(decoded.stroke, 'Freestyle');
      expect(decoded.calculatedDistanceMeters, 1500.0);
    });
  });

  group('WearableWorkoutDetails', () {
    test('round-trips JSON and storage string accurately', () {
      const details = WearableWorkoutDetails(
        wearableSource: 'Garmin Forerunner 265',
        externalId: 'garmin-run-456',
        caloriesBurnedKcal: 420,
        avgCadence: 172,
        maxHeartRate: 182,
      );

      expect(details.wearableSource, 'Garmin Forerunner 265');
      expect(details.externalId, 'garmin-run-456');
      expect(details.caloriesBurnedKcal, 420.0);
      expect(details.avgCadence, 172);
      expect(details.maxHeartRate, 182);

      final jsonStr = details.toStorage();
      final decoded =
          WorkoutDetails.fromStorage(jsonStr) as WearableWorkoutDetails?;
      expect(decoded, isNotNull);
      expect(decoded!.wearableSource, 'Garmin Forerunner 265');
      expect(decoded.externalId, 'garmin-run-456');
      expect(decoded.caloriesBurnedKcal, 420.0);
      expect(decoded.avgCadence, 172);
      expect(decoded.maxHeartRate, 182);
    });
  });
}
