import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/insights/domain/insight_statistics.dart';

void main() {
  group('median', () {
    test('returns null for an empty sample rather than zero', () {
      expect(median(const []), isNull);
    });

    test('returns the middle value of an odd-length sample', () {
      expect(median(const [3, 1, 2]), 2);
    });

    test('averages the two middle values of an even-length sample', () {
      expect(median(const [4, 1, 3, 2]), 2.5);
    });

    test('does not move when a single extreme value is added', () {
      final withoutOutlier = median(const [5, 5, 5, 5, 5])!;
      final withOutlier = median(const [5, 5, 5, 5, 5, 100000])!;
      expect(withoutOutlier, 5);
      expect(withOutlier, 5);
    });

    test('leaves the input list untouched', () {
      final values = <double>[3, 1, 2];
      median(values);
      expect(values, <double>[3, 1, 2]);
    });
  });

  group('trimmedMean', () {
    test('returns null for an empty sample', () {
      expect(trimmedMean(const []), isNull);
    });

    test('discards the requested proportion from each tail', () {
      // 5 values, 20% trim => one value cut from each end, leaving 2,3,4.
      expect(trimmedMean(const [1, 2, 3, 4, 100], proportion: 0.2), 3);
    });

    test('never trims a small sample away to nothing', () {
      expect(trimmedMean(const [1, 2], proportion: 0.5), 1.5);
      expect(trimmedMean(const [7], proportion: 0.4), 7);
    });

    test('leaves the input list untouched', () {
      final values = <double>[9, 1, 5];
      trimmedMean(values);
      expect(values, <double>[9, 1, 5]);
    });
  });

  group('cliffsDelta', () {
    test('returns null when either sample is empty', () {
      expect(cliffsDelta(const [], const [1]), isNull);
      expect(cliffsDelta(const [1], const []), isNull);
    });

    test('is +1 when every left value exceeds every right value', () {
      expect(cliffsDelta(const [3, 4, 5], const [1, 2]), 1);
    });

    test('is -1 when every left value is below every right value', () {
      expect(cliffsDelta(const [1, 2], const [3, 4, 5]), -1);
    });

    test('is 0 for identical samples', () {
      expect(cliffsDelta(const [1, 2], const [1, 2]), 0);
    });

    test('counts pairs, not magnitudes, so an outlier moves it little', () {
      // One value in the right sample is 1000x the rest; delta shifts by
      // exactly the one pair it flips, not by the size of the gap.
      final clean = cliffsDelta(const [5, 5, 5, 5], const [1, 1, 1, 1])!;
      final withOutlier = cliffsDelta(
        const [5, 5, 5, 5],
        const [1, 1, 1, 5000],
      )!;
      expect(clean, 1);
      expect(withOutlier, 0.5);
    });

    test('matches a hand-computed overlapping case', () {
      // left 10,10,10,10,100 vs right 9,9,200,200,200:
      // greater = 10, lesser = 15, pairs = 25 => -0.2.
      final delta = cliffsDelta(
        const [10, 10, 10, 10, 100],
        const [9, 9, 200, 200, 200],
      );
      expect(delta, closeTo(-0.2, 1e-9));
    });
  });

  group('relativeDifference', () {
    test('expresses the gap as a fraction of the lower value', () {
      expect(
        relativeDifference(higher: 5700, lower: 5000),
        closeTo(0.14, 1e-9),
      );
    });

    test('is null when the lower value is not strictly positive', () {
      expect(relativeDifference(higher: 5, lower: 0), isNull);
      expect(relativeDifference(higher: 5, lower: -3), isNull);
    });
  });
}
