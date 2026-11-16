import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:menfit_app/core/platform/health/health_vitals_aggregation.dart';
import 'package:menfit_app/core/platform/health/health_vitals_reader.dart';
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';

void main() {
  final now = DateTime.utc(2026, 11, 16, 9);
  DateTime at(int hoursAgo, [int minutes = 0]) =>
      now.subtract(Duration(hours: hoursAgo, minutes: minutes));

  SleepSample stage(
    SleepStageKind? kind,
    DateTime start,
    DateTime end, {
    String source = 'watch',
  }) => (start: start, end: end, source: source, stage: kind);

  group('latestReading', () {
    test('picks the latest point inside the window', () {
      final latest = latestReading(
        [
          (at: at(3), value: 60),
          (at: at(1), value: 72),
          (at: at(2), value: 65),
        ],
        from: at(24),
        to: now,
      );
      expect(latest?.value, 72);
      expect(latest?.at, at(1));
    });

    test('ignores points outside the window and non-finite values', () {
      final latest = latestReading(
        [
          (at: at(30), value: 50),
          (at: now.add(const Duration(minutes: 1)), value: 99),
          (at: at(1), value: double.nan),
          (at: at(5), value: 61),
        ],
        from: at(24),
        to: now,
      );
      expect(latest?.value, 61);
    });

    test('null when nothing is in range', () {
      expect(latestReading(const [], from: at(24), to: now), isNull);
    });
  });

  group('normaliseSpo2Percent', () {
    test('HealthKit fraction becomes a percentage', () {
      expect(normaliseSpo2Percent(0.97), closeTo(97, 1e-9));
      expect(normaliseSpo2Percent(1), 100);
    });

    test('Health Connect percentage is unchanged', () {
      expect(normaliseSpo2Percent(96), 96);
    });
  });

  group('summariseSleep — Health Connect session', () {
    test('sums stages; asleep excludes awake', () {
      final s = summariseSleep([
        stage(null, at(9), at(1)),
        stage(SleepStageKind.light, at(9), at(7)),
        stage(SleepStageKind.awake, at(7), at(7, -30)),
        stage(SleepStageKind.deep, at(7, -30), at(5)),
        stage(SleepStageKind.rem, at(5), at(1)),
      ], now: now)!;
      expect(s.start, at(9));
      expect(s.end, at(1));
      expect(s.asleep, const Duration(hours: 7, minutes: 30));
      expect(s.light, const Duration(hours: 2));
      expect(s.deep, const Duration(hours: 1, minutes: 30));
      expect(s.rem, const Duration(hours: 4));
      expect(s.awake, const Duration(minutes: 30));
    });

    test('session without stages: asleep is the session, stages null', () {
      final s = summariseSleep([stage(null, at(9), at(1))], now: now)!;
      expect(s.asleep, const Duration(hours: 8));
      expect(s.deep, isNull);
      expect(s.light, isNull);
      expect(s.rem, isNull);
      expect(s.awake, isNull);
    });

    test('one source per night: most asleep wins, others are ignored', () {
      final s = summariseSleep([
        stage(null, at(33), at(25)), // ended outside the 24 h window
        stage(null, at(9), at(2), source: 'phone'),
        stage(null, at(8), at(1)),
        stage(SleepStageKind.deep, at(8), at(1)),
        stage(SleepStageKind.light, at(9), at(3), source: 'phone'),
      ], now: now)!;
      expect(s.end, at(1));
      expect(s.asleep, const Duration(hours: 7));
      expect(s.light, Duration.zero);
    });

    test('watch session with stages beats a later stage-less phone span', () {
      final s = summariseSleep([
        stage(null, at(9), at(2)),
        stage(SleepStageKind.light, at(9), at(6)),
        stage(SleepStageKind.awake, at(6), at(5)),
        stage(SleepStageKind.deep, at(5), at(2)),
        // Phone "in bed" span: longer and ends later, but no stages.
        stage(null, at(10), at(0, 30), source: 'phone'),
      ], now: now)!;
      expect(s.start, at(9));
      expect(s.end, at(2));
      expect(s.asleep, const Duration(hours: 6));
      expect(s.awake, const Duration(hours: 1));
    });

    test('a single stage-less session still counts', () {
      final s = summariseSleep([
        stage(null, at(10), at(2), source: 'phone'),
      ], now: now)!;
      expect(s.asleep, const Duration(hours: 8));
      expect(s.end, at(2));
      expect(s.deep, isNull);
    });

    test('nothing ending in the last 24 h gives null', () {
      expect(summariseSleep([stage(null, at(33), at(25))], now: now), isNull);
    });
  });

  group('summariseSleep — HealthKit stage samples', () {
    test('rebuilds the night and de-duplicates overlapping sources', () {
      final s = summariseSleep([
        // Watch with stages.
        stage(SleepStageKind.light, at(8), at(6)),
        stage(SleepStageKind.awake, at(6), at(5, 40)),
        stage(SleepStageKind.deep, at(5, 40), at(4)),
        stage(SleepStageKind.rem, at(4), at(2)),
        // A phone app covering the same night with less asleep time.
        stage(SleepStageKind.asleep, at(7), at(3), source: 'phone'),
        // An afternoon nap two days ago is a different night.
        stage(SleepStageKind.asleep, at(40), at(39)),
      ], now: now)!;
      expect(s.start, at(8));
      expect(s.end, at(2));
      expect(s.asleep, const Duration(hours: 5, minutes: 40));
      expect(s.awake, const Duration(minutes: 20));
      expect(s.deep, const Duration(hours: 1, minutes: 40));
    });

    test('overlapping samples from one source are not double-counted', () {
      final s = summariseSleep([
        stage(SleepStageKind.asleep, at(8), at(2)),
        stage(SleepStageKind.asleep, at(6), at(4)),
      ], now: now)!;
      expect(s.asleep, const Duration(hours: 6));
      expect(s.deep, isNull);
    });

    test('awake-only samples give null', () {
      expect(
        summariseSleep([stage(SleepStageKind.awake, at(3), at(2))], now: now),
        isNull,
      );
    });

    test('samples separated by more than the gap are separate nights', () {
      final s = summariseSleep([
        stage(SleepStageKind.asleep, at(20), at(14)),
        stage(SleepStageKind.asleep, at(4), at(2)),
      ], now: now)!;
      expect(s.start, at(4));
      expect(s.asleep, const Duration(hours: 2));
    });
  });

  group('HealthVitalsReader.requestTypes', () {
    test('Android asks for RMSSD and the sleep session, never SDNN', () {
      final types = HealthVitalsReader.requestTypes(android: true);
      expect(types, contains(HealthDataType.HEART_RATE_VARIABILITY_RMSSD));
      expect(types, contains(HealthDataType.SLEEP_SESSION));
      expect(
        types,
        isNot(contains(HealthDataType.HEART_RATE_VARIABILITY_SDNN)),
      );
    });

    test('iOS asks for SDNN and has no session type', () {
      final types = HealthVitalsReader.requestTypes(android: false);
      expect(types, contains(HealthDataType.HEART_RATE_VARIABILITY_SDNN));
      expect(types, isNot(contains(HealthDataType.SLEEP_SESSION)));
      expect(
        types,
        isNot(contains(HealthDataType.HEART_RATE_VARIABILITY_RMSSD)),
      );
    });

    test('vitals only: the steps/workout types are not re-requested', () {
      for (final android in [true, false]) {
        final types = HealthVitalsReader.requestTypes(android: android);
        for (final excluded in [
          HealthDataType.STEPS,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
          HealthDataType.WORKOUT,
          HealthDataType.DISTANCE_DELTA,
        ]) {
          expect(types, isNot(contains(excluded)));
        }
      }
    });
  });

  test('snapshot and sleep toString print no values', () {
    final snapshot = HealthVitalsSnapshot(
      readAt: now,
      latestHeartRateBpm: 71,
      bloodOxygenPercent: 97,
      sleep: SleepSummary(start: at(9), end: at(1), asleep: Duration.zero),
    );
    expect(snapshot.toString(), isNot(contains('71')));
    expect(snapshot.toString(), isNot(contains('97')));
    expect(snapshot.sleep.toString(), isNot(contains('2026')));
    expect(snapshot.isEmpty, isFalse);
    expect(HealthVitalsSnapshot(readAt: now).isEmpty, isTrue);
  });
}
