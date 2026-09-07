import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/insights/application/insight_observation_mapper.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';

final LocalDate _today = LocalDate(2026, 6, 30);
final DateTime _stamp = DateTime.utc(2026, 6, 30, 9);

/// The day [daysAgo] before [_today].
LocalDate _day(int daysAgo) => _today.addDays(-daysAgo);

Activity _activity({
  required LocalDate day,
  ActivityType type = ActivityType.run,
  double distanceMeters = 5000,
  WorkoutDetails? details,
}) {
  final startedAt = DateTime(day.year, day.month, day.day, 7);
  return Activity(
    id: 'activity-${day.toIso()}-${type.toStorage()}',
    activityType: type,
    title: 'Session',
    startedAt: startedAt,
    movingTime: const Duration(minutes: 30),
    elapsedTime: const Duration(minutes: 30),
    distanceMeters: distanceMeters,
    source: ActivitySource.manual,
    createdAt: _stamp,
    updatedAt: _stamp,
    workoutDetails: details,
  );
}

NutritionEntry _entry({required LocalDate day, double proteinGrams = 40}) {
  return NutritionEntry(
    id: 'entry-${day.toIso()}',
    day: day,
    meal: MealType.lunch,
    foodName: 'Food',
    quantityServings: 1,
    quantityAmount: 1,
    perServing: NutritionFacts(
      caloriesKcal: 400,
      proteinGrams: proteinGrams,
      carbsGrams: 30,
      fatGrams: 10,
    ),
    createdAt: _stamp,
    updatedAt: _stamp,
  );
}

DailyCheckin _checkin({required LocalDate day}) {
  return DailyCheckin(
    id: 'checkin-${day.toIso()}',
    day: day,
    createdAt: _stamp,
    updatedAt: _stamp,
    energy: 4,
    sleep: 5,
    soreness: 2,
    stress: 1,
    pain: 1,
  );
}

NutritionGoals _goals({double? proteinTargetGrams = 110}) {
  return NutritionGoals(
    id: 'goals',
    createdAt: _stamp,
    updatedAt: _stamp,
    proteinTargetGrams: proteinTargetGrams,
  );
}

List<DailyObservation> _build({
  List<Activity> activities = const [],
  List<NutritionEntry> entries = const [],
  NutritionGoals? goals,
  Map<LocalDate, int> water = const {},
  List<DailyCheckin> checkins = const [],
}) {
  return buildDailyObservations(
    today: _today,
    activities: activities,
    nutritionEntries: entries,
    nutritionGoals: goals,
    waterTotalsByDay: water,
    checkins: checkins,
  );
}

DailyObservation _observationFor(
  List<DailyObservation> observations,
  LocalDate day,
) {
  return observations.firstWhere((observation) => observation.day == day);
}

void main() {
  group('buildDailyObservations', () {
    test('emits every calendar day in the window, oldest first', () {
      final observations = _build();

      expect(observations, hasLength(insightWindowDays));
      expect(observations.first.day, _day(insightWindowDays - 1));
      expect(observations.last.day, _today);
    });

    test('a day with every source present maps each one through', () {
      final day = _day(3);
      final observations = _build(
        activities: [
          _activity(day: day),
          _activity(
            day: day,
            type: ActivityType.strength,
            distanceMeters: 0,
            details: const StrengthWorkoutDetails(
              exercises: [
                StrengthExercise(
                  name: 'Squat',
                  sets: [
                    StrengthSet(setNumber: 1, reps: 5, weightKg: 60),
                    StrengthSet(setNumber: 2, reps: 5, weightKg: 60),
                    // Not completed: excluded from tonnage, unlike
                    // `StrengthWorkoutDetails.totalVolumeKg`.
                    StrengthSet(
                      setNumber: 3,
                      reps: 5,
                      weightKg: 60,
                      isCompleted: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        entries: [_entry(day: day, proteinGrams: 95)],
        goals: _goals(),
        water: {day: 1800},
        checkins: [_checkin(day: day)],
      );

      final observation = _observationFor(observations, day);

      expect(observation.energy, 4);
      expect(observation.sleep, 5);
      expect(observation.soreness, 2);
      expect(observation.stress, 1);
      expect(observation.pain, 1);
      expect(observation.proteinGrams, 95);
      expect(observation.proteinTargetGrams, 110);
      expect(observation.waterMl, 1800);
      expect(observation.sessions, hasLength(2));
      expect(observation.metricValue(InsightMetric.runDistanceMeters), 5000);
      expect(
        observation.metricValue(InsightMetric.strengthTonnageKg),
        600,
        reason: 'two completed sets of 5 x 60 kg; the third was not completed',
      );
    });

    test('a day with no check-in and no diary carries nulls, never zeros', () {
      final logged = _day(2);
      final bare = _day(1);
      final observations = _build(
        entries: [_entry(day: logged)],
        goals: _goals(),
        water: {logged: 1500},
        checkins: [_checkin(day: logged)],
      );

      final observation = _observationFor(observations, bare);

      expect(observation.energy, isNull);
      expect(observation.sleep, isNull);
      expect(observation.soreness, isNull);
      expect(observation.stress, isNull);
      expect(observation.pain, isNull);
      expect(
        observation.proteinGrams,
        isNull,
        reason: 'an unlogged day is not a day they ate no protein',
      );
      expect(
        observation.proteinTargetMet(0.85),
        isNull,
        reason:
            'a target with no intake logged against it settles nothing - '
            'never "not met"',
      );
      expect(
        observation.waterMl,
        isNull,
        reason: 'absent from the water totals map means never logged',
      );
    });

    test('a rest day yields null for every output metric, never zero', () {
      final observations = _build(
        activities: [_activity(day: _day(5))],
      );

      final restDay = _observationFor(observations, _day(4));

      expect(restDay.sessions, isEmpty);
      expect(restDay.metricValue(InsightMetric.runDistanceMeters), isNull);
      expect(restDay.metricValue(InsightMetric.strengthTonnageKg), isNull);
      expect(restDay.metricValue(InsightMetric.perceivedExertion), isNull);
    });

    test(
      'a stated RPE reaches the observation, and the day reports their '
      'median',
      () {
        final day = _day(6);
        final observations = _build(
          activities: [
            _activity(
              day: day,
              type: ActivityType.other,
              distanceMeters: 0,
              details: const GeneralWorkoutDetails(rpe: 9),
            ),
            _activity(
              day: day,
              type: ActivityType.yoga,
              distanceMeters: 0,
              details: const MindfulWorkoutDetails(rpe: 3),
            ),
          ],
        );

        final observation = _observationFor(observations, day);

        expect(observation.sessions, hasLength(2));
        expect(
          observation.sessions.map((s) => s.perceivedExertion),
          containsAll(<int>[9, 3]),
        );
        expect(observation.metricValue(InsightMetric.perceivedExertion), 6.0);
      },
    );

    test(
      'an unanswered RPE stays null rather than becoming a fabricated 6',
      () {
        final day = _day(6);
        final observations = _build(
          activities: [
            _activity(
              day: day,
              type: ActivityType.yoga,
              distanceMeters: 0,
              // No `rpe:` — they were never asked. `workout_details.dart`
              // used to default this to 6, which is what kept every
              // exertion insight dormant.
              details: const MindfulWorkoutDetails(),
            ),
          ],
        );

        final observation = _observationFor(observations, day);

        expect(observation.sessions.single.perceivedExertion, isNull);
        expect(
          observation.metricValue(InsightMetric.perceivedExertion),
          isNull,
          reason: 'no session stated an RPE, so the day has no typical one',
        );
      },
    );

    test('statedPerceivedExertion passes a stored value through', () {
      final activity = _activity(
        day: _day(1),
        type: ActivityType.yoga,
        distanceMeters: 0,
        details: const MindfulWorkoutDetails(rpe: 10),
      );

      expect(statedPerceivedExertion(activity), 10);
    });

    test('statedPerceivedExertion is null when nothing was answered', () {
      expect(
        statedPerceivedExertion(
          _activity(
            day: _day(1),
            type: ActivityType.yoga,
            distanceMeters: 0,
            details: const MindfulWorkoutDetails(),
          ),
        ),
        isNull,
      );
      expect(
        statedPerceivedExertion(
          _activity(
            day: _day(2),
            type: ActivityType.other,
            distanceMeters: 0,
            details: const GeneralWorkoutDetails(),
          ),
        ),
        isNull,
      );
    });

    test('detail types that carry no RPE state none', () {
      // Strength, HIIT and swim have no RPE field at all, so there is
      // nothing to map even in principle — they must not borrow one.
      expect(
        statedPerceivedExertion(
          _activity(
            day: _day(3),
            type: ActivityType.hiit,
            distanceMeters: 0,
            details: const HiitWorkoutDetails(
              workSeconds: 40,
              restSeconds: 20,
              totalRounds: 8,
              completedRounds: 8,
            ),
          ),
        ),
        isNull,
      );
      expect(
        statedPerceivedExertion(_activity(day: _day(4))),
        isNull,
        reason: 'a run carries no workout details at all',
      );
    });

    test('hydration targets are never invented', () {
      final day = _day(1);
      final observations = _build(water: {day: 2500});

      final observation = _observationFor(observations, day);

      expect(observation.waterMl, 2500);
      expect(
        observation.waterTargetMl,
        isNull,
        reason: 'the app has no user-set hydration target to compare against',
      );
      expect(observation.hydrationTargetMet(0.85), isNull);
    });

    test('a strength session with no sets recorded reports null tonnage', () {
      final day = _day(7);
      final observations = _build(
        activities: [
          _activity(
            day: day,
            type: ActivityType.strength,
            distanceMeters: 0,
            details: const StrengthWorkoutDetails(
              exercises: [StrengthExercise(name: 'Squat')],
            ),
          ),
        ],
      );

      final observation = _observationFor(observations, day);

      expect(observation.sessions.single.strengthTonnageKg, isNull);
      expect(observation.metricValue(InsightMetric.strengthTonnageKg), isNull);
    });

    test('activities outside the window are dropped', () {
      final observations = _build(
        activities: [
          _activity(day: _day(insightWindowDays)),
          _activity(day: _today.addDays(1)),
        ],
      );

      expect(
        observations.every((observation) => observation.sessions.isEmpty),
        isTrue,
      );
    });
  });

  group('resolveProteinTargetGrams', () {
    test('reads the goals row the fueling evaluator reads', () {
      expect(resolveProteinTargetGrams(_goals()), 110);
    });

    test('treats an unset or non-positive target as no target at all', () {
      expect(resolveProteinTargetGrams(null), isNull);
      expect(resolveProteinTargetGrams(_goals(proteinTargetGrams: null)), null);
      expect(resolveProteinTargetGrams(_goals(proteinTargetGrams: 0)), isNull);
    });
  });

  group('completedTonnageKg', () {
    test('is null for a non-strength session', () {
      expect(
        completedTonnageKg(
          const HiitWorkoutDetails(
            workSeconds: 30,
            restSeconds: 30,
            totalRounds: 5,
            completedRounds: 5,
          ),
        ),
        isNull,
      );
      expect(completedTonnageKg(null), isNull);
    });

    test('sums only completed sets', () {
      const details = StrengthWorkoutDetails(
        exercises: [
          StrengthExercise(
            name: 'Deadlift',
            sets: [
              StrengthSet(setNumber: 1, reps: 3, weightKg: 80),
              StrengthSet(
                setNumber: 2,
                reps: 3,
                weightKg: 80,
                isCompleted: false,
              ),
            ],
          ),
          StrengthExercise(
            name: 'Row',
            sets: [StrengthSet(setNumber: 1, reps: 10, weightKg: 20)],
          ),
        ],
      );

      expect(completedTonnageKg(details), 3 * 80 + 10 * 20);
    });
  });
}
