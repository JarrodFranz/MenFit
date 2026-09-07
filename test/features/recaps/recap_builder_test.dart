import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_builder.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_pr_highlight.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';

/// Every fixture lives in July 2026 (31 days), so `consistencyRatio`
/// denominators below are all `31`.
final RecapPeriod _july = RecapPeriod.forMonth(LocalDate(2026, 7, 1));

/// A **completed-cycle** period spanning exactly the same 1–31 July window
/// as [_july], so any month-vs-cycle-end difference a test sees is down to
/// [RecapPeriod.kind] alone and never to the dates.
///
/// Most tests below use this rather than [_july] because the two kinds
/// carry different sparse-data bars (`RecapBuilder.build`): a month recap
/// demands 3+ sessions, while a cycle-end recap only demands *some*
/// content in the period. That lets a hydration/fueling/wellbeing test
/// bring exactly the data it is about — water, food, check-ins — without
/// padding in three unrelated sessions it then has to reason about.
final RecapPeriod _julyCycle = RecapPeriod.forCompletedCycle(
  cycleStart: CycleRecord(
    id: 'cycle-july-start',
    periodStart: LocalDate(2026, 7, 1),
    createdAt: DateTime.utc(2026, 7),
    updatedAt: DateTime.utc(2026, 7),
  ),
  nextCycleStart: CycleRecord(
    id: 'cycle-august-start',
    periodStart: LocalDate(2026, 8, 1),
    createdAt: DateTime.utc(2026, 8),
    updatedAt: DateTime.utc(2026, 8),
  ),
);

/// A UTC instant that is unambiguously *[day] July local time* in any
/// timezone the suite might run in — `RecapBuilder` buckets activities by
/// `startedAt.toLocal()`, so building the instant from a local wall clock
/// (rather than a fixed UTC noon) is what keeps these fixtures from
/// drifting a day on a machine far from UTC.
DateTime _at(int day, {int hour = 12}) => DateTime(2026, 7, day, hour).toUtc();

Activity _activity({
  required String id,
  required int day,
  ActivityType type = ActivityType.run,
  double distanceMeters = 0,
  Duration movingTime = const Duration(minutes: 30),
  double? elevationGainMeters,
  ActivitySource source = ActivitySource.manual,
  WorkoutDetails? workoutDetails,
  int hour = 12,
}) {
  final startedAt = _at(day, hour: hour);
  return Activity(
    id: id,
    activityType: type,
    title: id,
    startedAt: startedAt,
    movingTime: movingTime,
    elapsedTime: movingTime,
    distanceMeters: distanceMeters,
    source: source,
    createdAt: startedAt,
    updatedAt: startedAt,
    elevationGainMeters: elevationGainMeters,
    workoutDetails: workoutDetails,
  );
}

StrengthWorkoutDetails _strength({
  required String name,
  required int setCount,
  required int reps,
  required double weightKg,
}) {
  return StrengthWorkoutDetails(
    exercises: [
      StrengthExercise(
        name: name,
        sets: [
          for (var i = 1; i <= setCount; i++)
            StrengthSet(setNumber: i, reps: reps, weightKg: weightKg),
        ],
      ),
    ],
  );
}

DailyCheckin _checkin(int day, {int? energy, int? sleep}) {
  final at = _at(day);
  return DailyCheckin(
    id: 'c$day',
    day: LocalDate(2026, 7, day),
    createdAt: at,
    updatedAt: at,
    energy: energy,
    sleep: sleep,
  );
}

NutritionEntry _entry(
  int day, {
  required double proteinGrams,
  double caloriesKcal = 400,
}) {
  final at = _at(day);
  return NutritionEntry(
    id: 'n$day-${proteinGrams.toStringAsFixed(0)}',
    day: LocalDate(2026, 7, day),
    meal: MealType.lunch,
    foodName: 'Fixture food',
    quantityServings: 1,
    quantityAmount: 1,
    perServing: NutritionFacts(
      caloriesKcal: caloriesKcal,
      proteinGrams: proteinGrams,
    ),
    createdAt: at,
    updatedAt: at,
  );
}

NutritionGoals _goals({double? proteinTargetGrams}) => NutritionGoals(
  id: 'goals',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  proteinTargetGrams: proteinTargetGrams,
);

/// Standing records from *before* the period, high enough that nothing a
/// test logs inside the period can beat them — lets a totals-focused test
/// assert on totals without PR highlights appearing as a side effect.
PersonalRecords _unbeatableRecords() => PersonalRecords(
  bestEfforts: const {},
  longestDistance: PrEntry<double>(
    activityId: 'historic',
    activityTitle: 'Historic long run',
    startedAt: DateTime.utc(2025),
    value: 50000,
  ),
);

/// A straight-line (fixed longitude, increasing latitude) track — the same
/// fixture shape `test/features/activity/track_analysis_test.dart` uses, so
/// each 0.0001° step is a predictable ~11.12 m.
List<ActivitySample> _straightTrack({
  required String activityId,
  required int count,
  Duration step = const Duration(seconds: 1),
}) {
  final base = _at(20, hour: 8);
  return [
    for (var i = 0; i < count; i++)
      ActivitySample(
        id: '$activityId-s$i',
        activityId: activityId,
        timestamp: base.add(step * i),
        latitude: i * 0.0001,
        longitude: 0,
      ),
  ];
}

CycleRecap? _build({
  RecapPeriod? period,
  List<Activity> activities = const [],
  Map<String, List<ActivitySample>> samples = const {},
  PersonalRecords priorRecords = const PersonalRecords(bestEfforts: {}),
  Map<String, double> priorMaxWeights = const {},
  Map<LocalDate, int> water = const {},
  List<NutritionEntry> nutrition = const [],
  NutritionGoals? goals,
  List<DailyCheckin> checkins = const [],
  Map<LocalDate, CyclePhase> phaseByDay = const {},
  bool hasAnyCycleData = true,
}) {
  return const RecapBuilder().build(
    period: period ?? _july,
    periodActivities: activities,
    samplesByActivityId: samples,
    priorRecords: priorRecords,
    priorMaxWeightsByExercise: priorMaxWeights,
    waterTotalsByDay: water,
    periodNutritionEntries: nutrition,
    nutritionGoals: goals,
    periodCheckins: checkins,
    phaseByDay: phaseByDay,
    hasAnyCycleData: hasAnyCycleData,
  );
}

void main() {
  group('RecapBuilder totals', () {
    test('sums distance by type, tonnage, mindful minutes and active '
        'days over hand-computed fixtures', () {
      final recap = _build(
        priorRecords: _unbeatableRecords(),
        priorMaxWeights: const {'barbell squat': 100},
        activities: [
          // Two sessions on the same day: two sessions, one active day.
          _activity(id: 'a1', day: 1, distanceMeters: 5000, hour: 7),
          _activity(id: 'a2', day: 1, distanceMeters: 3000, hour: 18),
          _activity(
            id: 'a3',
            day: 5,
            type: ActivityType.walk,
            distanceMeters: 2000,
          ),
          _activity(
            id: 'a4',
            day: 8,
            type: ActivityType.yoga,
            movingTime: const Duration(minutes: 45),
          ),
          _activity(
            id: 'a5',
            day: 9,
            type: ActivityType.pilates,
            movingTime: const Duration(minutes: 20),
          ),
          _activity(
            id: 'a6',
            day: 10,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Barbell Squat',
              setCount: 3,
              reps: 5,
              weightKg: 60,
            ),
          ),
        ],
      );

      expect(recap, isNotNull);
      expect(recap!.sessionCount, 6);
      expect(recap.distanceByType[ActivityType.run], 8000);
      expect(recap.distanceByType[ActivityType.walk], 2000);
      expect(recap.totalDistanceMeters, 10000);
      // 3 sets x 5 reps x 60 kg.
      expect(recap.totalTonnageKg, 900);
      expect(recap.mindfulMinutes, 65);
      // 5 distinct active days (1, 5, 8, 9, 10) out of July's 31.
      expect(recap.period.totalDays, 31);
      expect(recap.consistencyRatio, closeTo(5 / 31, 1e-9));
      expect(recap.topPrs, isEmpty);
    });

    test('omits zero-distance activity types from distanceByType', () {
      final recap = _build(
        priorRecords: _unbeatableRecords(),
        activities: [
          _activity(id: 'a1', day: 1, distanceMeters: 5000),
          _activity(
            id: 'a2',
            day: 2,
            type: ActivityType.yoga,
            movingTime: const Duration(minutes: 40),
          ),
          _activity(
            id: 'a3',
            day: 3,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Bench Press',
              setCount: 2,
              reps: 8,
              weightKg: 40,
            ),
          ),
        ],
        priorMaxWeights: const {'bench press': 100},
      );

      expect(recap!.distanceByType.keys, [ActivityType.run]);
      expect(recap.distanceByType.containsKey(ActivityType.yoga), isFalse);
      expect(recap.distanceByType.containsKey(ActivityType.strength), isFalse);
    });

    test('never manufactures a zero for a metric with nothing logged', () {
      // A cycle-end period whose only content is a single check-in - the
      // sparsest recap the guard still builds. Every optional metric must
      // be absent rather than a shaming "0" (Task 1.3's framing rule,
      // enforced here rather than in the slide widgets).
      final recap = _build(
        period: _julyCycle,
        checkins: [_checkin(1)],
      );

      expect(recap, isNotNull);
      expect(recap!.sessionCount, 0);
      expect(recap.consistencyRatio, 0.0);
      expect(recap.distanceByType, isEmpty);
      expect(recap.totalDistanceMeters, isNull);
      expect(recap.totalTonnageKg, isNull);
      expect(recap.mindfulMinutes, isNull);
      expect(recap.hydrationConsistencyRatio, isNull);
      expect(recap.fuelingConsistencyRatio, isNull);
      expect(recap.topPrs, isEmpty);
      expect(recap.wellbeingObservation, isNull);
    });

    test('strength work with no completed weight yields no tonnage', () {
      final recap = _build(
        period: _julyCycle,
        priorRecords: _unbeatableRecords(),
        activities: [
          _activity(
            id: 'a1',
            day: 4,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Bodyweight Squat',
              setCount: 3,
              reps: 12,
              weightKg: 0,
            ),
          ),
        ],
      );

      expect(recap!.totalTonnageKg, isNull);
      expect(recap.topPrs, isEmpty);
    });
  });

  group('RecapBuilder sparse-data guard', () {
    List<Activity> sessions(int count) => [
      for (var i = 0; i < count; i++)
        _activity(id: 'a$i', day: i + 1, distanceMeters: 1000),
    ];

    test('month recap: null below 3 sessions even with cycle data', () {
      // The defining regression case: one old period record elsewhere in
      // the app must NOT cause a hollow month recap to interrupt the user
      // (this exact shape broke settings_delete_data_test's seeded state).
      expect(
        _build(activities: sessions(2), priorRecords: _unbeatableRecords()),
        isNull,
      );
      expect(_build(priorRecords: _unbeatableRecords()), isNull);
      expect(
        _build(
          activities: sessions(2),
          priorRecords: _unbeatableRecords(),
          hasAnyCycleData: false,
        ),
        isNull,
      );
    });

    test('month recap: builds at 3 sessions even with no cycle data', () {
      final recap = _build(
        activities: sessions(3),
        priorRecords: _unbeatableRecords(),
        hasAnyCycleData: false,
      );

      expect(recap, isNotNull);
      expect(recap!.sessionCount, 3);
    });

    test('cycle-end recap: builds below 3 sessions with cycle data', () {
      final recap = _build(
        period: _julyCycle,
        activities: sessions(2),
        priorRecords: _unbeatableRecords(),
      );

      expect(recap, isNotNull);
      expect(recap!.sessionCount, 2);
    });

    test('cycle-end recap: builds on water, food or check-ins alone', () {
      // Content for a cycle-end recap is anything she logged during the
      // cycle - a woman tracking her cycle who logged only food and water
      // through it still gets a modest recap.
      final onWaterAlone = _build(
        period: _julyCycle,
        priorRecords: _unbeatableRecords(),
        water: {LocalDate(2026, 7, 3): 1500},
      );
      expect(onWaterAlone, isNotNull);
      // No sessions at all, and the recap says so honestly.
      expect(onWaterAlone!.sessionCount, 0);

      expect(
        _build(
          period: _julyCycle,
          priorRecords: _unbeatableRecords(),
          nutrition: [_entry(4, proteinGrams: 20)],
        ),
        isNotNull,
      );

      expect(
        _build(
          period: _julyCycle,
          priorRecords: _unbeatableRecords(),
          checkins: [_checkin(5, energy: 3)],
        ),
        isNotNull,
      );
    });

    test('cycle-end recap: null when the period has no content at all', () {
      // A completed cycle alone is not enough when there is not a single
      // session, check-in, water day or nutrition entry inside the period
      // to talk about.
      expect(
        _build(period: _julyCycle, priorRecords: _unbeatableRecords()),
        isNull,
      );
    });
  });

  group('RecapBuilder hydration consistency', () {
    test('is days-hit over days-logged, not over calendar days', () {
      final recap = _build(
        period: _julyCycle,
        priorRecords: _unbeatableRecords(),
        water: {
          LocalDate(2026, 7, 1): 2500,
          LocalDate(2026, 7, 2): 1200,
          LocalDate(2026, 7, 3): 2000,
          LocalDate(2026, 7, 4): 800,
        },
      );

      // 2 of the 4 logged days hit 2000 ml - the other 27 days of July
      // were never logged and so are neither a hit nor a miss.
      expect(recap!.hydrationConsistencyRatio, closeTo(0.5, 1e-9));
    });

    test('is null when no water was logged at all', () {
      // A check-in is what gets this period past the sparse-data guard; it
      // has no bearing on hydration either way.
      final recap = _build(period: _julyCycle, checkins: [_checkin(1)]);
      expect(recap!.hydrationConsistencyRatio, isNull);
    });

    test(
      'is null when water was logged but never hit target (no 0% shaming)',
      () {
        final recap = _build(
          period: _julyCycle,
          water: {
            LocalDate(2026, 7, 1): 500,
            LocalDate(2026, 7, 2): 1999,
            LocalDate(2026, 7, 3): 1200,
          },
        );

        expect(recap!.hydrationConsistencyRatio, isNull);
      },
    );

    test('is null when water was logged on fewer than 3 days', () {
      final recap = _build(
        period: _julyCycle,
        water: {
          LocalDate(2026, 7, 1): 2500,
          LocalDate(2026, 7, 2): 2200,
        },
      );

      expect(recap!.hydrationConsistencyRatio, isNull);
    });

    test(
      'counts a day exactly on target as a hit when at least 3 days logged',
      () {
        final recap = _build(
          period: _julyCycle,
          water: {
            LocalDate(2026, 7, 1): 2000,
            LocalDate(2026, 7, 2): 2000,
            LocalDate(2026, 7, 3): 2000,
          },
        );
        expect(recap!.hydrationConsistencyRatio, 1.0);
      },
    );
  });

  group('RecapBuilder fueling consistency', () {
    test('is days-met over days-logged at the 85% protein threshold', () {
      final recap = _build(
        period: _julyCycle,
        goals: _goals(proteinTargetGrams: 100),
        nutrition: [
          _entry(1, proteinGrams: 90),
          _entry(2, proteinGrams: 50),
          // Exactly on the 85% threshold counts as met.
          _entry(3, proteinGrams: 85),
        ],
      );

      expect(recap!.fuelingConsistencyRatio, closeTo(2 / 3, 1e-9));
    });

    test('is null when protein target was never hit (no 0% shaming)', () {
      final recap = _build(
        period: _julyCycle,
        goals: _goals(proteinTargetGrams: 100),
        nutrition: [
          _entry(1, proteinGrams: 50),
          _entry(2, proteinGrams: 40),
          _entry(3, proteinGrams: 30),
        ],
      );

      expect(recap!.fuelingConsistencyRatio, isNull);
    });

    test('is null when fewer than 3 days logged', () {
      final recap = _build(
        period: _julyCycle,
        goals: _goals(proteinTargetGrams: 100),
        nutrition: [
          _entry(1, proteinGrams: 90),
          _entry(2, proteinGrams: 90),
        ],
      );

      expect(recap!.fuelingConsistencyRatio, isNull);
    });

    test('ignores a day whose entries total nothing at all', () {
      final recap = _build(
        period: _julyCycle,
        goals: _goals(proteinTargetGrams: 100),
        nutrition: [
          _entry(1, proteinGrams: 90),
          _entry(2, proteinGrams: 90),
          _entry(3, proteinGrams: 90),
          _entry(4, proteinGrams: 0, caloriesKcal: 0),
        ],
      );

      expect(recap!.fuelingConsistencyRatio, 1.0);
    });

    test('is null with no protein target set', () {
      final recap = _build(
        period: _julyCycle,
        goals: _goals(),
        nutrition: [_entry(1, proteinGrams: 90)],
      );

      expect(recap!.fuelingConsistencyRatio, isNull);
    });

    test('is null with a target but nothing logged', () {
      // The check-in only clears the sparse-data guard - it is not food.
      final recap = _build(
        period: _julyCycle,
        goals: _goals(proteinTargetGrams: 100),
        checkins: [_checkin(1)],
      );
      expect(recap!.fuelingConsistencyRatio, isNull);
    });
  });

  group('RecapBuilder personal records', () {
    test('credits the first three PRs chronologically, with the phase '
        'each was set in', () {
      final recap = _build(
        priorMaxWeights: const {'deadlift': 60},
        phaseByDay: {
          LocalDate(2026, 7, 2): CyclePhase.follicular,
          LocalDate(2026, 7, 12): CyclePhase.luteal,
          LocalDate(2026, 7, 15): CyclePhase.menstrual,
        },
        activities: [
          _activity(
            id: 'a1',
            day: 2,
            distanceMeters: 10000,
            elevationGainMeters: 300,
          ),
          _activity(id: 'a2', day: 12, distanceMeters: 12000),
          _activity(
            id: 'a3',
            day: 15,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Deadlift',
              setCount: 3,
              reps: 5,
              weightKg: 80,
            ),
          ),
        ],
      );

      // Four PRs were set; the recap shows the first three in the order
      // they happened (there is no ranking pass - see RecapBuilder).
      expect(recap!.topPrs, hasLength(3));

      expect(recap.topPrs[0].type, RecapPrType.longestDistance);
      expect(recap.topPrs[0].label, 'Longest distance');
      expect(recap.topPrs[0].valueLabel, '10.00 km');
      expect(recap.topPrs[0].phase, CyclePhase.follicular);
      expect(recap.topPrs[0].achievedAt, _at(2));

      expect(recap.topPrs[1].type, RecapPrType.mostElevation);
      expect(recap.topPrs[1].label, 'Highest climb');
      expect(recap.topPrs[1].valueLabel, '300 m');
      expect(recap.topPrs[1].phase, CyclePhase.follicular);

      expect(recap.topPrs[2].type, RecapPrType.longestDistance);
      expect(recap.topPrs[2].valueLabel, '12.00 km');
      expect(recap.topPrs[2].phase, CyclePhase.luteal);
    });

    test('leaves phase null on a day no cycle data covers', () {
      // `phaseByDay` - not the period kind - is the only source of phase,
      // so an empty map leaves a PR unphased even in a cycle-end recap.
      final recap = _build(
        period: _julyCycle,
        activities: [_activity(id: 'a1', day: 2, distanceMeters: 10000)],
      );

      expect(recap!.topPrs, hasLength(1));
      expect(recap.topPrs.single.phase, isNull);
    });

    test('a session that merely equals the standing record is not a PR', () {
      final recap = _build(
        period: _julyCycle,
        priorRecords: PersonalRecords(
          bestEfforts: const {},
          longestDistance: PrEntry<double>(
            activityId: 'historic',
            activityTitle: 'Historic long run',
            startedAt: DateTime.utc(2025),
            value: 10000,
          ),
        ),
        activities: [_activity(id: 'a1', day: 2, distanceMeters: 10000)],
      );

      expect(recap!.topPrs, isEmpty);
    });

    test('accumulates strength records chronologically within the '
        'period', () {
      final recap = _build(
        priorMaxWeights: const {'deadlift': 60},
        activities: [
          _activity(
            id: 'a1',
            day: 2,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Deadlift',
              setCount: 3,
              reps: 5,
              weightKg: 70,
            ),
          ),
          _activity(
            id: 'a2',
            day: 9,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Deadlift',
              setCount: 3,
              reps: 3,
              weightKg: 80,
            ),
          ),
          // Below the 80 kg already set earlier this same period.
          _activity(
            id: 'a3',
            day: 16,
            type: ActivityType.strength,
            workoutDetails: _strength(
              name: 'Deadlift',
              setCount: 3,
              reps: 5,
              weightKg: 75,
            ),
          ),
        ],
      );

      expect(recap!.topPrs, hasLength(2));
      expect(recap.topPrs[0].type, RecapPrType.strengthWeight);
      expect(recap.topPrs[0].label, 'Deadlift');
      expect(recap.topPrs[0].valueLabel, '70.0 kg');
      expect(recap.topPrs[1].valueLabel, '80.0 kg');
    });

    test('ignores an uncompleted heavy set', () {
      final recap = _build(
        period: _julyCycle,
        priorMaxWeights: const {'deadlift': 60},
        activities: [
          _activity(
            id: 'a1',
            day: 2,
            type: ActivityType.strength,
            workoutDetails: const StrengthWorkoutDetails(
              exercises: [
                StrengthExercise(
                  name: 'Deadlift',
                  sets: [
                    StrengthSet(
                      setNumber: 1,
                      reps: 1,
                      weightKg: 90,
                      isCompleted: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

      expect(recap!.topPrs, isEmpty);
      // The set she racked but never lifted is not tonnage either: with
      // nothing completed, there is no strength work to report at all.
      // (`CycleRecap.totalTonnageKg`: "summed across every completed set".)
      expect(recap.totalTonnageKg, isNull);
    });

    test('tonnage counts completed sets only, not planned ones', () {
      final recap = _build(
        period: _julyCycle,
        priorMaxWeights: const {'bench press': 200},
        activities: [
          _activity(
            id: 'a1',
            day: 3,
            type: ActivityType.strength,
            workoutDetails: const StrengthWorkoutDetails(
              exercises: [
                StrengthExercise(
                  name: 'Bench Press',
                  sets: [
                    // 2 x (8 x 50) = 800 kg actually lifted.
                    StrengthSet(setNumber: 1, reps: 8, weightKg: 50),
                    StrengthSet(setNumber: 2, reps: 8, weightKg: 50),
                    // Planned, racked, never done - worth 800 kg more if
                    // it were wrongly counted.
                    StrengthSet(
                      setNumber: 3,
                      reps: 8,
                      weightKg: 50,
                      isCompleted: false,
                    ),
                    StrengthSet(
                      setNumber: 4,
                      reps: 8,
                      weightKg: 50,
                      isCompleted: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

      expect(recap!.totalTonnageKg, 800);
    });

    test('detects a best-effort PR from a recorded track', () {
      const trackId = 'recorded-1';
      final samples = _straightTrack(activityId: trackId, count: 130);

      final recap = _build(
        period: _julyCycle,
        priorRecords: _unbeatableRecords(),
        phaseByDay: {LocalDate(2026, 7, 20): CyclePhase.ovulatory},
        activities: [
          _activity(
            id: trackId,
            day: 20,
            hour: 8,
            distanceMeters: 1400,
            source: ActivitySource.recorded,
            movingTime: const Duration(seconds: 129),
          ),
        ],
        samples: {trackId: samples},
      );

      final effort = recap!.topPrs.singleWhere(
        (pr) => pr.type == RecapPrType.bestEffort,
      );
      expect(effort.label, '1 km best effort');
      expect(effort.phase, CyclePhase.ovulatory);
      expect(effort.valueLabel, isNotEmpty);
    });

    test('ignores samples for a manually-logged activity', () {
      const id = 'manual-1';
      final recap = _build(
        period: _julyCycle,
        priorRecords: _unbeatableRecords(),
        activities: [
          _activity(
            id: id,
            day: 20,
            hour: 8,
            distanceMeters: 1400,
            movingTime: const Duration(seconds: 129),
          ),
        ],
        samples: {id: _straightTrack(activityId: id, count: 130)},
      );

      expect(recap!.topPrs, isEmpty);
    });
  });

  // The observation shares the insights engine's statistical floor
  // (`insights/domain/insight_thresholds.dart`), reached through
  // `RecapBuilder._buildWellbeingObservation`: sleep 4-5 is the higher
  // arm, 1-2 the lower, the neutral 3 belongs to neither, each arm needs
  // 4 days, and the two arms' *medians* must differ by 10% with a Cliff's
  // delta of at least 0.33. The numbers below are asserted through the
  // builder rather than against the constants, so a future change to
  // either has to be a deliberate one.
  group('RecapBuilder wellbeing observation', () {
    List<DailyCheckin> checkins({
      required int goodSleepDays,
      required int otherDays,
      int goodSleepEnergy = 5,
      int otherEnergy = 2,
      int unpairedDays = 0,
      int neutralSleepDays = 0,
      int neutralSleepEnergy = 1,
    }) {
      var day = 1;
      return [
        for (var i = 0; i < goodSleepDays; i++)
          _checkin(day++, energy: goodSleepEnergy, sleep: 5),
        for (var i = 0; i < otherDays; i++)
          _checkin(day++, energy: otherEnergy, sleep: 2),
        for (var i = 0; i < neutralSleepDays; i++)
          _checkin(day++, energy: neutralSleepEnergy, sleep: 3),
        for (var i = 0; i < unpairedDays; i++) _checkin(day++, energy: 4),
      ];
    }

    test('stays silent below 8 check-ins, however strong the pattern', () {
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(goodSleepDays: 4, otherDays: 3),
      );

      expect(recap!.wellbeingObservation, isNull);
    });

    test('names the pattern at 8 check-ins, descriptively only', () {
      // 4 and 4 is exactly the shared per-arm floor, and energy 5 against
      // energy 2 separates completely (Cliff's delta 1.0).
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(goodSleepDays: 4, otherDays: 4),
      );

      final observation = recap!.wellbeingObservation;
      expect(observation, isNotNull);
      expect(
        observation,
        'On the days you logged better sleep, your energy check-ins '
        'tended to be higher too.',
      );
      // Descriptive, never causal or prescriptive
      // (`knowledge/domain/womens_health.md`).
      final lower = observation!.toLowerCase();
      for (final banned in const [
        'because',
        'cause',
        'due to',
        'should',
        'you need',
        'try to',
      ]) {
        expect(lower, isNot(contains(banned)));
      }
    });

    test('stays silent with 8 check-ins but too few fully answered', () {
      // Three answered both, two answered both the other way, three
      // answered energy alone — neither arm reaches four.
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(
          goodSleepDays: 3,
          otherDays: 2,
          unpairedDays: 3,
        ),
      );

      expect(recap!.wellbeingObservation, isNull);
    });

    test('stays silent when every logged night was a good one', () {
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(goodSleepDays: 8, otherDays: 0),
      );

      expect(recap!.wellbeingObservation, isNull);
    });

    test('stays silent when the difference is too small to be worth '
        'naming', () {
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(
          goodSleepDays: 4,
          otherDays: 4,
          goodSleepEnergy: 3,
          otherEnergy: 3,
        ),
      );

      expect(recap!.wellbeingObservation, isNull);
    });

    test('stays silent when one arm is a single night against seven', () {
      // The finding this gate exists for: the arms used only have to be
      // non-empty, so one well-slept night with high energy against seven
      // poor ones produced a sentence about her body.
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(goodSleepDays: 7, otherDays: 1),
      );

      expect(recap!.wellbeingObservation, isNull);

      // ...and the mirror image, one poor night against seven good ones.
      final mirrored = _build(
        period: _julyCycle,
        checkins: checkins(goodSleepDays: 1, otherDays: 7),
      );

      expect(mirrored!.wellbeingObservation, isNull);
    });

    test('drops neutral sleep nights from both arms rather than topping '
        'one up', () {
      // Twelve check-ins, but five of them scored sleep 3 — the "I did
      // not really think about it" middle of a five-point self-report.
      // Splitting those into the lower arm would take it to eight and
      // manufacture the comparison; they belong to neither arm, so the
      // lower arm is still three and the observation stays absent.
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(
          goodSleepDays: 4,
          otherDays: 3,
          neutralSleepDays: 5,
        ),
      );

      expect(recap!.wellbeingObservation, isNull);
    });

    test('stays silent when the two arms overlap too much to separate', () {
      // Four days each and medians 4.0 vs 3.5 — past the per-arm floor and
      // past the 10% median difference — but the distributions interleave
      // (Cliff's delta 0.125, well under 0.33), so the "difference" is two
      // orderings away from vanishing. A mean gap alone could not see it.
      final recap = _build(
        period: _julyCycle,
        checkins: [
          _checkin(1, energy: 3, sleep: 5),
          _checkin(2, energy: 4, sleep: 5),
          _checkin(3, energy: 4, sleep: 4),
          _checkin(4, energy: 5, sleep: 4),
          _checkin(5, energy: 1, sleep: 2),
          _checkin(6, energy: 2, sleep: 1),
          _checkin(7, energy: 5, sleep: 2),
          _checkin(8, energy: 5, sleep: 1),
        ],
      );

      expect(recap!.wellbeingObservation, isNull);
    });

    test('stays silent when better-slept days scored lower, never naming '
        'the reverse', () {
      final recap = _build(
        period: _julyCycle,
        checkins: checkins(
          goodSleepDays: 4,
          otherDays: 4,
          goodSleepEnergy: 2,
          otherEnergy: 5,
        ),
      );

      expect(recap!.wellbeingObservation, isNull);
    });
  });
}
