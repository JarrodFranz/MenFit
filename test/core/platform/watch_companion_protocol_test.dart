import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_protocol.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

void main() {
  group('WatchCompanionProtocol', () {
    test('WatchCommand serialization round-trip', () {
      final now = DateTime.utc(2026, 9, 4, 12);
      final command = WatchCommand(
        action: 'start',
        timestamp: now,
        workoutType: ActivityType.run,
      );

      final json = command.toJson();
      expect(json['type'], 'command');
      expect(json['action'], 'start');
      expect(json['workoutType'], 'run');

      final parsed = WatchMessage.fromJson(json) as WatchCommand?;
      expect(parsed, isNotNull);
      expect(parsed!.action, 'start');
      expect(parsed.workoutType, ActivityType.run);
      expect(parsed.timestamp, now);
    });

    test('WatchTelemetry serialization round-trip', () {
      final now = DateTime.utc(2026, 9, 4, 12, 5);
      final telemetry = WatchTelemetry(
        timestamp: now,
        heartRate: 158,
        cadence: 168,
        paceSecondsPerKm: 320.5,
        distanceMeters: 1200,
        elapsedSeconds: 384,
      );

      final json = telemetry.toJson();
      expect(json['type'], 'telemetry');
      expect(json['heartRate'], 158);
      expect(json['cadence'], 168);

      final parsed = WatchMessage.fromJson(json) as WatchTelemetry?;
      expect(parsed, isNotNull);
      expect(parsed!.heartRate, 158);
      expect(parsed.cadence, 168);
      expect(parsed.paceSecondsPerKm, 320.5);
      expect(parsed.distanceMeters, 1200.0);
      expect(parsed.elapsedSeconds, 384);
    });

    test('WatchWristWorkout serialization round-trip', () {
      final start = DateTime.utc(2026, 9, 4, 9);
      final end = DateTime.utc(2026, 9, 4, 9, 30);
      final workout = WatchWristWorkout(
        externalId: 'wrist-workout-101',
        activityType: ActivityType.run,
        startedAt: start,
        endedAt: end,
        totalDistanceMeters: 5100,
        caloriesBurnedKcal: 340,
        avgHeartRate: 154,
        avgCadence: 164,
        source: 'Apple Watch',
        samples: [
          WatchWristSample(
            timestamp: start,
            latitude: -33.8688,
            longitude: 151.2093,
            elevationMeters: 45,
            heartRate: 145,
          ),
          WatchWristSample(
            timestamp: end,
            latitude: -33.8700,
            longitude: 151.2100,
            elevationMeters: 48,
            heartRate: 160,
          ),
        ],
      );

      final json = workout.toJson();
      expect(json['type'], 'wrist_workout');
      expect(json['externalId'], 'wrist-workout-101');
      expect(json['totalDistanceMeters'], 5100.0);

      final parsed = WatchMessage.fromJson(json) as WatchWristWorkout?;
      expect(parsed, isNotNull);
      expect(parsed!.externalId, 'wrist-workout-101');
      expect(parsed.activityType, ActivityType.run);
      expect(parsed.duration, const Duration(minutes: 30));
      expect(parsed.caloriesBurnedKcal, 340.0);
      expect(parsed.avgHeartRate, 154);
      expect(parsed.avgCadence, 164);
      expect(parsed.samples.length, 2);
      expect(parsed.samples.first.heartRate, 145);
    });

    test('WatchCycleContext serialization round-trip', () {
      const context = WatchCycleContext(
        phaseName: 'Follicular',
        cycleDayNumber: 8,
        daysUntilNextPeriod: 20,
        advice: 'Energy begins rising as estrogen increases.',
      );

      final json = context.toJson();
      expect(json['type'], 'cycle_context');
      expect(json['phaseName'], 'Follicular');
      expect(json['cycleDayNumber'], 8);
      expect(json['daysUntilNextPeriod'], 20);

      final parsed = WatchMessage.fromJson(json) as WatchCycleContext?;
      expect(parsed, isNotNull);
      expect(parsed!.phaseName, 'Follicular');
      expect(parsed.cycleDayNumber, 8);
      expect(parsed.daysUntilNextPeriod, 20);
      expect(parsed.advice, contains('estrogen'));
    });
  });
}
