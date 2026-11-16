import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_platform_io.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

/// The `health` plugin fills a Health Connect workout's `totalDistance` by
/// summing every `DistanceRecord` overlapping the session window, so a
/// strength session arrives carrying the steps walked between sets. These
/// pin the import-side filter applied to that raw value.
void main() {
  group('workoutDistanceMeters', () {
    test('a strength session with overlapping step distance gets none', () {
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(
          ActivityType.strength,
          130,
        ),
        isNull,
      );
    });

    test('yoga, pilates and HIIT sessions get none', () {
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.yoga, 420),
        isNull,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.pilates, 90),
        isNull,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.hiit, 1500),
        isNull,
      );
    });

    test('a run keeps its distance', () {
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.run, 7500),
        7500,
      );
    });

    test('walk, hike, ride, swim and other keep theirs', () {
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.walk, 3200),
        3200,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.hike, 9000),
        9000,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.ride, 25000),
        25000,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.swim, 1500),
        1500,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.other, 2000),
        2000,
      );
    });

    test('a missing, zero, negative or non-finite value is no distance', () {
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.run, null),
        isNull,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.run, 0),
        isNull,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(ActivityType.run, -5),
        isNull,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(
          ActivityType.run,
          double.nan,
        ),
        isNull,
      );
      expect(
        IoHealthPlatformAdapter.workoutDistanceMeters(
          ActivityType.run,
          double.infinity,
        ),
        isNull,
      );
    });
  });
}
