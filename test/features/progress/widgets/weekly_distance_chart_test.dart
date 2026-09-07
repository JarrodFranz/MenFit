import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/progress/presentation/widgets/weekly_distance_chart.dart';

/// Mirrors `weekly_distance_chart.dart`'s private `_maxYFor` formula (the
/// smallest multiple of [interval] that is `>= maxValue`) - duplicated
/// here rather than exported, since only [niceInterval] itself needed to
/// become a public, independently-testable pure function (F4).
double _maxYFor(double maxValue, double interval) {
  if (maxValue <= 0) return interval;
  final steps = (maxValue / interval).ceil();
  return steps * interval;
}

/// Mirrors `weekly_distance_chart.dart`'s private `_axisLabel` formatting
/// rule (0 decimals for a whole-number step, 1 decimal otherwise).
String _axisLabel(double value, double interval) {
  final stepNeedsDecimal = interval != interval.roundToDouble();
  return stepNeedsDecimal ? value.toStringAsFixed(1) : value.round().toString();
}

void main() {
  group('niceInterval', () {
    test('maxValue 0 falls back to a 1.0 step', () {
      expect(niceInterval(0), 1.0);
    });

    test('maxValue 1.0 (tiny volume) uses a 0.5 step', () {
      expect(niceInterval(1), 0.5);
    });

    test('maxValue 2.0 (still tiny) uses a 0.5 step', () {
      expect(niceInterval(2), 0.5);
    });

    test('maxValue 7 uses a 2.0 step', () {
      expect(niceInterval(7), 2.0);
    });

    test('maxValue 10 uses a 5.0 step', () {
      expect(niceInterval(10), 5.0);
    });

    test('maxValue 48 uses a 20.0 step', () {
      expect(niceInterval(48), 20.0);
    });

    test('never returns a sub-1.0 step once maxValue reaches 3', () {
      for (final maxValue in [3.0, 3.5, 4, 5, 9, 29, 99, 1000]) {
        expect(
          niceInterval(maxValue.toDouble()),
          greaterThanOrEqualTo(1.0),
          reason: 'maxValue=$maxValue',
        );
      }
    });

    for (final maxValue in [0.0, 1.0, 2.0, 7.0, 10.0, 48.0]) {
      test(
        'maxValue $maxValue: gridlines are exact multiples of the interval, '
        'and their formatted labels contain no duplicates',
        () {
          final interval = niceInterval(maxValue);
          final maxY = _maxYFor(maxValue, interval);

          expect(maxY, greaterThanOrEqualTo(maxValue));

          final gridlineCount = (maxY / interval).round();
          // Exactly representable: walking up by `interval` a whole number
          // of times lands, within floating-point noise, exactly on maxY.
          expect(
            gridlineCount * interval,
            closeTo(maxY, 1e-9),
          );
          // 3-5 gridlines (0 through maxY, inclusive) is this function's
          // target range for any real (positive) chart - the degenerate
          // maxValue=0 case (an all-zero week) just needs *a* sane axis,
          // not a specific gridline count.
          if (maxValue > 0) {
            expect(gridlineCount + 1, inInclusiveRange(3, 5));
          }

          final labels = [
            for (var i = 0; i <= gridlineCount; i++)
              _axisLabel(i * interval, interval),
          ];
          expect(
            labels.toSet(),
            hasLength(labels.length),
            reason: 'duplicate axis labels: $labels',
          );
        },
      );
    }
  });
}
