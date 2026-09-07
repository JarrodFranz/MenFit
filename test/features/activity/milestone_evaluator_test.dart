import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/domain/workout_milestone.dart';

void main() {
  const evaluator = MilestoneEvaluator();

  group('MilestoneEvaluator - Cardio', () {
    test('detects new longest distance PR', () {
      final prior = PersonalRecords(
        bestEfforts: const {},
        longestDistance: PrEntry(
          activityId: 'old-1',
          activityTitle: '5k Run',
          startedAt: DateTime.utc(2026),
          value: 5000,
        ),
      );

      final newRun = Activity(
        id: 'new-1',
        activityType: ActivityType.run,
        title: 'Morning Long Run',
        startedAt: DateTime.utc(2026, 2),
        movingTime: const Duration(minutes: 45),
        elapsedTime: const Duration(minutes: 45),
        distanceMeters: 7500,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2),
        updatedAt: DateTime.utc(2026, 2),
      );

      final milestones = evaluator.evaluateCardioMilestones(
        newActivity: newRun,
        priorRecords: prior,
      );

      expect(
        milestones.any((m) => m.type == WorkoutMilestoneType.longestDistance),
        isTrue,
      );
      final pr = milestones.firstWhere(
        (m) => m.type == WorkoutMilestoneType.longestDistance,
      );
      expect(pr.isPersonalRecord, isTrue);
      expect(pr.title, contains('Longest Distance'));
      expect(pr.subtitle, contains('7.50 km'));
    });

    test('detects highest elevation climb PR', () {
      final prior = PersonalRecords(
        bestEfforts: const {},
        mostElevationGain: PrEntry(
          activityId: 'old-1',
          activityTitle: 'Trail Run',
          startedAt: DateTime.utc(2026),
          value: 120,
        ),
      );

      final newHike = Activity(
        id: 'new-1',
        activityType: ActivityType.hike,
        title: 'Mountain Hike',
        startedAt: DateTime.utc(2026, 2),
        movingTime: const Duration(hours: 2),
        elapsedTime: const Duration(hours: 2),
        distanceMeters: 4000,
        elevationGainMeters: 250,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2),
        updatedAt: DateTime.utc(2026, 2),
      );

      final milestones = evaluator.evaluateCardioMilestones(
        newActivity: newHike,
        priorRecords: prior,
      );

      expect(
        milestones.any((m) => m.type == WorkoutMilestoneType.mostElevation),
        isTrue,
      );
      final pr = milestones.firstWhere(
        (m) => m.type == WorkoutMilestoneType.mostElevation,
      );
      expect(pr.isPersonalRecord, isTrue);
      expect(pr.subtitle, contains('250 m'));
    });

    test('awards weekly consistency badge for 3+ workouts', () {
      final newRun = Activity(
        id: 'run-3',
        activityType: ActivityType.run,
        title: 'Friday Easy Run',
        startedAt: DateTime.utc(2026, 2, 6),
        movingTime: const Duration(minutes: 25),
        elapsedTime: const Duration(minutes: 25),
        distanceMeters: 3000,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2, 6),
        updatedAt: DateTime.utc(2026, 2, 6),
      );

      final milestones = evaluator.evaluateCardioMilestones(
        newActivity: newRun,
        priorRecords: null,
        weeklyWorkoutCount: 3,
      );

      expect(
        milestones.any((m) => m.type == WorkoutMilestoneType.weeklyConsistency),
        isTrue,
      );
      final consistency = milestones.firstWhere(
        (m) => m.type == WorkoutMilestoneType.weeklyConsistency,
      );
      expect(consistency.title, contains('3 Workouts This Week'));
    });
  });

  group('MilestoneEvaluator - Strength', () {
    test('detects weight PR on an exercise and tonnage milestone', () {
      final activity = Activity(
        id: 'strength-1',
        activityType: ActivityType.strength,
        title: 'Lower Body Strength',
        startedAt: DateTime.utc(2026, 2),
        movingTime: const Duration(minutes: 50),
        elapsedTime: const Duration(minutes: 50),
        distanceMeters: 0,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2),
        updatedAt: DateTime.utc(2026, 2),
      );

      final exercises = [
        const StrengthExercise(
          name: 'Barbell Squat',
          sets: [
            StrengthSet(setNumber: 1, reps: 8, weightKg: 60),
            StrengthSet(setNumber: 2, reps: 8, weightKg: 70),
            StrengthSet(setNumber: 3, reps: 6, weightKg: 75),
          ],
        ),
        const StrengthExercise(
          name: 'Hip Thrust',
          sets: [
            StrengthSet(setNumber: 1, reps: 10, weightKg: 80),
            StrengthSet(setNumber: 2, reps: 10, weightKg: 90),
            StrengthSet(setNumber: 3, reps: 10, weightKg: 100),
          ],
        ),
      ];

      final priorMaxWeights = {
        'barbell squat': 70.0,
        'hip thrust': 90.0,
      };

      final milestones = evaluator.evaluateStrengthMilestones(
        newActivity: activity,
        exercises: exercises,
        priorMaxWeights: priorMaxWeights,
      );

      // Squat 75 > 70 => PR
      expect(
        milestones.any(
          (m) => m.title.contains('Barbell Squat') && m.isPersonalRecord,
        ),
        isTrue,
      );

      // Hip Thrust 100 > 90 => PR
      expect(
        milestones.any(
          (m) => m.title.contains('Hip Thrust') && m.isPersonalRecord,
        ),
        isTrue,
      );

      // Total Tonnage: (8*60)+(8*70)+(6*75) + (10*80)+(10*90)+(10*100)
      // = 480+560+450 + 800+900+1000 = 4190 kg => 2,500 kg Moved
      expect(
        milestones.any(
          (m) => m.type == WorkoutMilestoneType.strengthVolumeMilestone,
        ),
        isTrue,
      );
      final tonnage = milestones.firstWhere(
        (m) => m.type == WorkoutMilestoneType.strengthVolumeMilestone,
      );
      expect(tonnage.title, contains('2,500 kg'));
    });

    test('detects 5,000 kg and 10,000 kg volume club', () {
      final activity = Activity(
        id: 'strength-heavy',
        activityType: ActivityType.strength,
        title: 'Heavy Leg Day',
        startedAt: DateTime.utc(2026, 2),
        movingTime: const Duration(hours: 1),
        elapsedTime: const Duration(hours: 1),
        distanceMeters: 0,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2),
        updatedAt: DateTime.utc(2026, 2),
      );

      final exercises = [
        const StrengthExercise(
          name: 'Leg Press',
          sets: [
            StrengthSet(setNumber: 1, reps: 15, weightKg: 200),
            StrengthSet(setNumber: 2, reps: 15, weightKg: 200),
            StrengthSet(setNumber: 3, reps: 15, weightKg: 200),
            StrengthSet(setNumber: 4, reps: 15, weightKg: 200),
          ],
        ),
      ];

      // 4 * 15 * 200 = 12,000 kg => 10,000 kg Club
      final milestones = evaluator.evaluateStrengthMilestones(
        newActivity: activity,
        exercises: exercises,
        priorMaxWeights: const {},
      );

      final tonnage = milestones.firstWhere(
        (m) => m.type == WorkoutMilestoneType.strengthVolumeMilestone,
      );
      expect(tonnage.title, contains('10,000 kg Club'));
    });

    test('detects first routine completed', () {
      final activity = Activity(
        id: 'strength-new',
        activityType: ActivityType.strength,
        title: 'Upper Hypertrophy A',
        startedAt: DateTime.utc(2026, 2),
        movingTime: const Duration(minutes: 40),
        elapsedTime: const Duration(minutes: 40),
        distanceMeters: 0,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2),
        updatedAt: DateTime.utc(2026, 2),
      );

      final milestones = evaluator.evaluateStrengthMilestones(
        newActivity: activity,
        exercises: const [],
        priorMaxWeights: const {},
        isNewRoutine: true,
      );

      expect(
        milestones.any(
          (m) => m.type == WorkoutMilestoneType.routineFirstCompleted,
        ),
        isTrue,
      );
    });
  });

  group('MilestoneEvaluator - Generic', () {
    test('evaluates generic workout with custom subtitle', () {
      final activity = Activity(
        id: 'yoga-1',
        activityType: ActivityType.yoga,
        title: 'Vinyasa Flow',
        startedAt: DateTime.utc(2026, 2),
        movingTime: const Duration(minutes: 45),
        elapsedTime: const Duration(minutes: 45),
        distanceMeters: 0,
        source: ActivitySource.recorded,
        createdAt: DateTime.utc(2026, 2),
        updatedAt: DateTime.utc(2026, 2),
      );

      final milestones = evaluator.evaluateGenericMilestones(
        newActivity: activity,
        customSubtitle: 'Full Body Flow session completed 🧘‍♀️',
      );

      expect(milestones.first.type, WorkoutMilestoneType.sessionCompleted);
      expect(milestones.first.subtitle, contains('Full Body Flow'));
    });
  });
}
