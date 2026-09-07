import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';
import 'package:menfit_app/features/activity/presentation/widgets/splits_section.dart';

/// A hand-built [Split] with sane defaults for fields the fairness logic
/// under test (`splitHighlightFlags`) doesn't care about - only [index],
/// [distanceMeters], and [paceSecondsPerKm] matter to it.
Split _split({
  required int index,
  required double distanceMeters,
  required double paceSecondsPerKm,
}) {
  return Split(
    index: index,
    distanceMeters: distanceMeters,
    duration: Duration(
      milliseconds: (paceSecondsPerKm * distanceMeters).round(),
    ),
    paceSecondsPerKm: paceSecondsPerKm,
  );
}

void main() {
  group('splitHighlightFlags', () {
    test('the single fastest full split is flagged', () {
      final splits = [
        _split(index: 1, distanceMeters: 1000, paceSecondsPerKm: 300),
        _split(index: 2, distanceMeters: 1000, paceSecondsPerKm: 250),
        _split(index: 3, distanceMeters: 1000, paceSecondsPerKm: 280),
      ];

      expect(
        splitHighlightFlags(splits, 1000),
        [false, true, false],
      );
    });

    test(
      'a fast trailing partial split never wins, even if it is faster than '
      'every full split (F5)',
      () {
        final splits = [
          _split(index: 1, distanceMeters: 1000, paceSecondsPerKm: 300),
          _split(index: 2, distanceMeters: 1000, paceSecondsPerKm: 280),
          // Trailing partial (shorter than splitMeters=1000), deceptively
          // fast - would win under a naive "fastest of all splits" rule.
          _split(index: 3, distanceMeters: 150, paceSecondsPerKm: 100),
        ];

        expect(
          splitHighlightFlags(splits, 1000),
          [false, true, false],
          reason: 'split 2 (fastest FULL split) wins, not the fast partial',
        );
      },
    );

    test(
      'on an exact pace tie between full splits, only the first tied split '
      'is flagged (F5)',
      () {
        final splits = [
          _split(index: 1, distanceMeters: 1000, paceSecondsPerKm: 300),
          _split(index: 2, distanceMeters: 1000, paceSecondsPerKm: 250),
          _split(index: 3, distanceMeters: 1000, paceSecondsPerKm: 250),
        ];

        expect(
          splitHighlightFlags(splits, 1000),
          [false, true, false],
        );
      },
    );

    test(
      'degenerate case: a single trailing partial split (no full split at '
      'all) still gets highlighted - falls back to its own baseline',
      () {
        final splits = [
          _split(index: 1, distanceMeters: 400, paceSecondsPerKm: 300),
        ];

        expect(splitHighlightFlags(splits, 1000), [true]);
      },
    );

    test('an empty split list returns an empty flag list', () {
      expect(splitHighlightFlags(const [], 1000), isEmpty);
    });

    test(
      'a full split that happens to exactly equal splitMeters is never '
      'mistaken for the trailing partial',
      () {
        // Two full splits, the second one (the last in the list) has
        // distanceMeters exactly equal to splitMeters - it must still be
        // treated as a full split (eligible to win), not misclassified as
        // partial just for being last.
        final splits = [
          _split(index: 1, distanceMeters: 1000, paceSecondsPerKm: 300),
          _split(index: 2, distanceMeters: 1000, paceSecondsPerKm: 200),
        ];

        expect(splitHighlightFlags(splits, 1000), [false, true]);
      },
    );
  });
}
