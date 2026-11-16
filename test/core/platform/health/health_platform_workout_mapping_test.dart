import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:menfit_app/core/platform/health/health_platform_io.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

void main() {
  group('IoHealthPlatformAdapter.mapWorkoutActivityType', () {
    test(
      'maps strength and lifting types correctly for Android Health Connect',
      () {
        expect(
          IoHealthPlatformAdapter.mapWorkoutActivityType(
            HealthWorkoutActivityType.STRENGTH_TRAINING,
          ),
          ActivityType.strength,
        );
        expect(
          IoHealthPlatformAdapter.mapWorkoutActivityType(
            HealthWorkoutActivityType.WEIGHTLIFTING,
          ),
          ActivityType.strength,
        );
        expect(
          IoHealthPlatformAdapter.mapWorkoutActivityType(
            HealthWorkoutActivityType.CALISTHENICS,
          ),
          ActivityType.strength,
        );
        expect(
          IoHealthPlatformAdapter.mapWorkoutActivityType(
            HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
          ),
          ActivityType.strength,
        );
        expect(
          IoHealthPlatformAdapter.mapWorkoutActivityType(
            HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING,
          ),
          ActivityType.strength,
        );
      },
    );

    test('maps treadmill and stationary cardio activities', () {
      expect(
        IoHealthPlatformAdapter.mapWorkoutActivityType(
          HealthWorkoutActivityType.RUNNING_TREADMILL,
        ),
        ActivityType.run,
      );
      expect(
        IoHealthPlatformAdapter.mapWorkoutActivityType(
          HealthWorkoutActivityType.WALKING_TREADMILL,
        ),
        ActivityType.walk,
      );
      expect(
        IoHealthPlatformAdapter.mapWorkoutActivityType(
          HealthWorkoutActivityType.BIKING_STATIONARY,
        ),
        ActivityType.ride,
      );
      expect(
        IoHealthPlatformAdapter.mapWorkoutActivityType(
          HealthWorkoutActivityType.SWIMMING_POOL,
        ),
        ActivityType.swim,
      );
      expect(
        IoHealthPlatformAdapter.mapWorkoutActivityType(
          HealthWorkoutActivityType.SWIMMING_OPEN_WATER,
        ),
        ActivityType.swim,
      );
    });
  });

  group('IoHealthPlatformAdapter.detectActivityTypeFallback', () {
    test('extracts activity type from workout string hints', () {
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Strength Workout',
        ),
        ActivityType.strength,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Weight lifting session',
        ),
        ActivityType.strength,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Gym body conditioning',
        ),
        ActivityType.strength,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Treadmill Run',
        ),
        ActivityType.run,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Outdoor Walk',
        ),
        ActivityType.walk,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Road Cycling',
        ),
        ActivityType.ride,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'High Intensity Interval',
        ),
        ActivityType.hiit,
      );
      expect(
        IoHealthPlatformAdapter.detectActivityTypeFallback(
          wsType: 'Something Unknown',
        ),
        ActivityType.other,
      );
    });
  });

  group('IoHealthPlatformAdapter.workoutReadTypes', () {
    test('Android needs distance, calories and steps alongside WORKOUT', () {
      // health 13.3.2 reads DistanceRecord, TotalCaloriesBurnedRecord and
      // StepsRecord inside every exercise session with no permission check;
      // any one missing empties the whole workout read.
      expect(
        IoHealthPlatformAdapter.workoutReadTypes(android: true),
        containsAll(<HealthDataType>[
          HealthDataType.WORKOUT,
          HealthDataType.DISTANCE_DELTA,
          HealthDataType.TOTAL_CALORIES_BURNED,
          HealthDataType.STEPS,
        ]),
      );
    });

    test('iOS asks only for WORKOUT (DISTANCE_DELTA is Android-only)', () {
      expect(IoHealthPlatformAdapter.workoutReadTypes(android: false), [
        HealthDataType.WORKOUT,
      ]);
    });
  });
}
