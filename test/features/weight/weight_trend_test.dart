import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';

/// Fixtures are hand-computed in the test bodies rather than generated, so
/// a change in the engine that happens to be self-consistent still fails.
void main() {
  final day1 = LocalDate(2026, 3, 1);
  final stamp = DateTime.utc(2026, 3, 1, 7);

  WeightLog log(
    int dayOffset,
    double weightKg, {
    String? id,
    DateTime? createdAt,
  }) {
    final day = day1.addDays(dayOffset);
    return WeightLog(
      id: id ?? '${day.toIso()}-$weightKg',
      day: day,
      weightKg: weightKg,
      createdAt: createdAt ?? stamp,
      updatedAt: createdAt ?? stamp,
    );
  }

  /// Consecutive daily readings starting on [day1].
  List<WeightLog> run(List<double> values) => [
    for (var i = 0; i < values.length; i++) log(i, values[i]),
  ];

  group('latestReadingPerDay', () {
    test('keeps the last reading recorded on a day with several', () {
      final logs = [
        log(0, 60, id: 'morning', createdAt: DateTime.utc(2026, 3, 1, 7)),
        log(0, 61.4, id: 'evening', createdAt: DateTime.utc(2026, 3, 1, 19)),
      ];

      final collapsed = latestReadingPerDay(logs);

      expect(collapsed, hasLength(1));
      expect(collapsed.single.id, 'evening');
      expect(collapsed.single.weightKg, 61.4);
    });

    test('does not average a day with several readings', () {
      final collapsed = latestReadingPerDay([
        log(0, 60, id: 'a', createdAt: DateTime.utc(2026, 3, 1, 7)),
        log(0, 62, id: 'b', createdAt: DateTime.utc(2026, 3, 1, 20)),
      ]);

      expect(
        collapsed.single.weightKg,
        62,
        reason: 'a mean would be a number they never saw on their scale',
      );
    });

    test('breaks a same-millisecond tie on id, as the repository does', () {
      final at = DateTime.utc(2026, 3, 1, 7);
      final collapsed = latestReadingPerDay([
        log(0, 60, id: 'b', createdAt: at),
        log(0, 61, id: 'a', createdAt: at),
      ]);

      expect(collapsed.single.id, 'b');
    });

    test('is order-independent: a reversed input gives the same answer', () {
      final logs = run([60, 61, 62]);

      expect(
        [
          for (final entry in latestReadingPerDay(logs.reversed.toList()))
            entry.id,
        ],
        [for (final entry in latestReadingPerDay(logs)) entry.id],
      );
    });

    test('returns one point per day, oldest first', () {
      final points = latestReadingPerDay(run([60, 61, 62]));

      expect(
        [for (final entry in points) entry.day],
        [
          day1,
          day1.addDays(1),
          day1.addDays(2),
        ],
      );
    });

    test('is empty for no logs', () {
      expect(latestReadingPerDay(const []), isEmpty);
    });
  });

  group('rolling median', () {
    test('matches a hand-computed 7-day window', () {
      final series = computeWeightTrend(
        logs: run([60, 61, 60, 62, 60, 61, 60]),
      );

      // Windows are trailing and calendar-based; the first two days hold
      // fewer than `minimumReadingsInTrendWindow` readings.
      expect(
        [for (final point in series.points) point.trendKg],
        [null, null, 60.0, 60.5, 60.0, 60.5, 60.0],
      );
    });

    test('a single outlier does not move the line', () {
      final withOutlier = computeWeightTrend(
        logs: run([60, 60, 60, 60, 60, 65, 60]),
      );
      final without = computeWeightTrend(
        logs: run([60, 60, 60, 60, 60, 60, 60]),
      );

      expect(withOutlier.points.last.trendKg, 60);
      expect(without.points.last.trendKg, 60);
    });

    test('the window is calendar days, not a count of readings', () {
      // Readings on days 0, 1, 2 and then 10, 11, 12: day 12's window
      // reaches back to day 6, so only the three recent readings vote.
      final series = computeWeightTrend(
        logs: [
          log(0, 60),
          log(1, 60),
          log(2, 60),
          log(10, 70),
          log(11, 70),
          log(12, 70),
        ],
      );

      expect(series.points.last.trendKg, 70);
    });
  });

  group('exponential moving average', () {
    test('matches a hand-computed alpha = 0.25 recursion', () {
      final series = computeWeightTrend(
        logs: run([60, 60, 60, 60, 60, 65, 60]),
        method: WeightTrendMethod.exponentialMovingAverage,
      );

      // 60, 60, 60, 60, 60, 0.25*65 + 0.75*60 = 61.25,
      // then 0.25*60 + 0.75*61.25 = 60.9375.
      expect(series.points[5].trendKg, closeTo(61.25, 1e-9));
      expect(series.points.last.trendKg, closeTo(60.9375, 1e-9));
    });

    test('absorbs an outlier the median ignores', () {
      final logs = run([60, 60, 60, 60, 60, 65, 60]);

      final ema = computeWeightTrend(
        logs: logs,
        method: WeightTrendMethod.exponentialMovingAverage,
      );
      final median = computeWeightTrend(logs: logs);

      expect(ema.points.last.trendKg, greaterThan(median.points.last.trendKg!));
    });

    test('restarts after a gap longer than the window', () {
      final series = computeWeightTrend(
        logs: [
          log(0, 60),
          log(1, 60),
          log(2, 60),
          log(3, 60),
          log(4, 60),
          log(19, 70),
          log(20, 70),
          log(21, 70),
        ],
        method: WeightTrendMethod.exponentialMovingAverage,
      );

      expect(
        series.points.last.trendKg,
        closeTo(70, 1e-9),
        reason:
            'carrying a fortnight-old average forward would report a '
            'stale number as a current one',
      );
    });
  });

  group('gaps', () {
    test('missing days produce no points at all', () {
      final series = computeWeightTrend(
        logs: [log(0, 60), log(1, 60), log(2, 60), log(3, 60), log(29, 62)],
      );

      expect(series.points, hasLength(5));
      expect(
        [for (final point in series.points) point.day],
        [
          day1,
          day1.addDays(1),
          day1.addDays(2),
          day1.addDays(3),
          day1.addDays(29),
        ],
      );
    });

    test('the first reading back after a gap carries no trend value', () {
      final series = computeWeightTrend(
        logs: [log(0, 60), log(1, 60), log(2, 60), log(3, 60), log(29, 62)],
      );

      expect(series.points.last.trendKg, isNull);
    });

    test('no trend value is ever outside the range of real readings', () {
      final series = computeWeightTrend(
        logs: run([60, 61, 62, 63, 64, 65, 66]),
      );

      for (final point in series.points) {
        final value = point.trendKg;
        if (value == null) continue;
        expect(value, inInclusiveRange(60, 66));
      }
    });
  });

  group('minimum-data gate', () {
    test('four days of readings get no trend line', () {
      final series = computeWeightTrend(logs: run([60, 61, 60, 61]));

      expect(series.points, hasLength(4));
      expect(series.hasTrend, isFalse);
      expect(series.points.every((point) => point.trendKg == null), isTrue);
      expect(series.direction, WeightTrendDirection.undetermined);
      expect(series.trendChangeKg, isNull);
    });

    test('five days of readings do', () {
      final series = computeWeightTrend(logs: run([60, 61, 60, 61, 60]));

      expect(series.hasTrend, isTrue);
    });

    test('the readings survive the gate even though the trend does not', () {
      final series = computeWeightTrend(logs: run([60, 61, 60]));

      expect([for (final point in series.points) point.weightKg], [60, 61, 60]);
    });

    test('an empty log list gives an empty series', () {
      final series = computeWeightTrend(logs: const []);

      expect(series.isEmpty, isTrue);
      expect(series.hasTrend, isFalse);
      expect(series.latest, isNull);
      expect(series.direction, WeightTrendDirection.undetermined);
    });
  });

  group('direction', () {
    test('rises when the smoothed line ends higher than it started', () {
      final series = computeWeightTrend(
        logs: run([60, 60, 60, 61, 62, 63, 64, 65]),
      );

      expect(series.direction, WeightTrendDirection.rising);
      expect(series.trendChangeKg, greaterThan(0));
    });

    test('falls when it ends lower', () {
      final series = computeWeightTrend(
        logs: run([65, 65, 65, 64, 63, 62, 61, 60]),
      );

      expect(series.direction, WeightTrendDirection.falling);
      expect(series.trendChangeKg, lessThan(0));
    });

    test('holds steady inside the threshold', () {
      final series = computeWeightTrend(
        logs: run([60, 60.2, 60.1, 60, 60.2, 60.1]),
      );

      expect(series.direction, WeightTrendDirection.steady);
      expect(series.trendChangeKg!.abs(), lessThan(trendSteadyThresholdKg));
    });

    test('carries no valence in its own vocabulary', () {
      expect(
        {for (final value in WeightTrendDirection.values) value.name},
        {'rising', 'falling', 'steady', 'undetermined'},
        reason:
            'a name like `improving` or `gaining` would give '
            'presentation somewhere to hang a verdict',
      );
    });
  });

  group('purity', () {
    test('the same logs always give the same series', () {
      final logs = run([60, 61, 60, 62, 60, 61, 60]);

      final first = computeWeightTrend(logs: logs);
      final second = computeWeightTrend(logs: logs);

      expect(
        [for (final point in first.points) point.trendKg],
        [for (final point in second.points) point.trendKg],
      );
    });

    test('does not mutate the list it was given', () {
      final logs = run([62, 60, 61]);
      final idsBefore = [for (final entry in logs) entry.id];

      computeWeightTrend(logs: logs);

      expect([for (final entry in logs) entry.id], idsBefore);
    });
  });
}
