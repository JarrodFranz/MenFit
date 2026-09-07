import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

void main() {
  group('HealthWorkoutSession', () {
    test('constructs session and calculates duration correctly', () {
      final start = DateTime.utc(2026, 9, 4, 10);
      final end = DateTime.utc(2026, 9, 4, 10, 45, 30);
      final session = HealthWorkoutSession(
        externalId: 'test-session-123',
        activityType: ActivityType.run,
        title: 'Garmin Outdoor Run',
        startedAt: start,
        endedAt: end,
        distanceMeters: 8200,
        totalEnergyKcal: 540,
        avgHeartRate: 155,
        sourceName: 'Garmin Connect',
        sourceId: 'com.garmin.android.apps.connectmobile',
      );

      expect(session.externalId, 'test-session-123');
      expect(session.activityType, ActivityType.run);
      expect(session.duration, const Duration(minutes: 45, seconds: 30));
      expect(session.distanceMeters, 8200.0);
      expect(session.totalEnergyKcal, 540.0);
      expect(session.avgHeartRate, 155);
      expect(session.isGarmin, isTrue);
      expect(session.isAppleWatch, isFalse);
      expect(session.isWearOs, isFalse);
    });

    test('correctly identifies Apple Watch provenance', () {
      final session = HealthWorkoutSession(
        externalId: 'apple-session-456',
        activityType: ActivityType.walk,
        title: 'Apple Watch Walk',
        startedAt: DateTime.utc(2026, 9, 4, 8),
        endedAt: DateTime.utc(2026, 9, 4, 8, 30),
        sourceName: 'Apple Watch',
        sourceId: 'com.apple.health',
      );

      expect(session.isGarmin, isFalse);
      expect(session.isAppleWatch, isTrue);
      expect(session.isWearOs, isFalse);
    });

    test('correctly identifies WearOS provenance', () {
      final session = HealthWorkoutSession(
        externalId: 'wearos-session-789',
        activityType: ActivityType.ride,
        title: 'Pixel Watch Ride',
        startedAt: DateTime.utc(2026, 9, 4, 7),
        endedAt: DateTime.utc(2026, 9, 4, 8),
        sourceName: 'Pixel Watch',
        sourceId: 'com.google.android.apps.fitness',
      );

      expect(session.isGarmin, isFalse);
      expect(session.isAppleWatch, isFalse);
      expect(session.isWearOs, isTrue);
    });
  });
}
