import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

Activity _activity({
  required ActivityType type,
  required double distanceMeters,
  Duration movingTime = const Duration(minutes: 30),
}) {
  final now = DateTime.utc(2026, 10, 6);
  return Activity(
    id: 'a1',
    activityType: type,
    title: 'Session',
    startedAt: now,
    movingTime: movingTime,
    elapsedTime: movingTime,
    distanceMeters: distanceMeters,
    source: ActivitySource.recorded,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ActivityType.tracksDistance', () {
    test('distance types track distance', () {
      for (final type in [
        ActivityType.run,
        ActivityType.walk,
        ActivityType.hike,
        ActivityType.ride,
        ActivityType.swim,
        ActivityType.other,
      ]) {
        expect(type.tracksDistance, isTrue, reason: type.name);
      }
    });

    test('strength, yoga, HIIT and pilates do not', () {
      for (final type in [
        ActivityType.strength,
        ActivityType.yoga,
        ActivityType.hiit,
        ActivityType.pilates,
      ]) {
        expect(type.tracksDistance, isFalse, reason: type.name);
      }
    });

    test('every type is classified (no silent default)', () {
      // A new enum value must be added to the exhaustive switch; this pins
      // the split so a change to it is a deliberate test edit.
      final tracking = ActivityType.values.where((t) => t.tracksDistance);
      expect(tracking.length, 6);
    });

    test('countedDistanceMeters zeroes a non-distance type only', () {
      expect(ActivityType.strength.countedDistanceMeters(130), 0);
      expect(ActivityType.yoga.countedDistanceMeters(800), 0);
      expect(ActivityType.run.countedDistanceMeters(5000), 5000);
      expect(ActivityType.other.countedDistanceMeters(1200), 1200);
    });
  });

  group('Activity.hasDistance', () {
    test('false for strength even with a stored distance', () {
      expect(
        _activity(type: ActivityType.strength, distanceMeters: 130).hasDistance,
        isFalse,
      );
    });

    test('true for a run with distance, false for a run without', () {
      expect(
        _activity(type: ActivityType.run, distanceMeters: 5000).hasDistance,
        isTrue,
      );
      expect(
        _activity(type: ActivityType.run, distanceMeters: 0).hasDistance,
        isFalse,
      );
    });
  });

  group('Activity.avgPaceSecondsPerKm guard', () {
    test('a normal run has its pace (5 km in 30:00 = 6:00 /km)', () {
      expect(
        _activity(
          type: ActivityType.run,
          distanceMeters: 5000,
        ).avgPaceSecondsPerKm,
        360,
      );
    });

    test('the reported strength case (0.13 km in 38:42) has no pace', () {
      expect(
        _activity(
          type: ActivityType.strength,
          distanceMeters: 130,
          movingTime: const Duration(minutes: 38, seconds: 42),
        ).avgPaceSecondsPerKm,
        isNull,
      );
    });

    test('a non-distance type never has a pace, even with real distance', () {
      expect(
        _activity(
          type: ActivityType.hiit,
          distanceMeters: 3000,
        ).avgPaceSecondsPerKm,
        isNull,
      );
    });

    test('a distance under the minimum has no pace', () {
      expect(
        _activity(
          type: ActivityType.run,
          distanceMeters: minPaceDistanceMeters - 1,
          movingTime: const Duration(seconds: 40),
        ).avgPaceSecondsPerKm,
        isNull,
      );
      expect(
        _activity(
          type: ActivityType.run,
          distanceMeters: minPaceDistanceMeters,
          movingTime: const Duration(seconds: 60),
        ).avgPaceSecondsPerKm,
        300,
      );
    });

    test('a pace slower than the plausible cap is not shown', () {
      // 0.3 km over 40:00 on an "other" session: 133:20 /km.
      expect(
        _activity(
          type: ActivityType.other,
          distanceMeters: 300,
          movingTime: const Duration(minutes: 40),
        ).avgPaceSecondsPerKm,
        isNull,
      );
      // Exactly at the cap is still a pace (1 km in 60:00).
      expect(
        _activity(
          type: ActivityType.hike,
          distanceMeters: 1000,
          movingTime: const Duration(minutes: 60),
        ).avgPaceSecondsPerKm,
        maxPlausiblePaceSecondsPerKm,
      );
    });

    test('zero distance has no pace', () {
      expect(
        _activity(
          type: ActivityType.run,
          distanceMeters: 0,
        ).avgPaceSecondsPerKm,
        isNull,
      );
    });
  });
}
