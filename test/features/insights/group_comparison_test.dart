import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

import 'insight_fixtures.dart';

/// Every insight in the feature funnels through `compareGroups`, so these
/// are the tests that decide what the app is willing to claim.
void main() {
  PersonalInsight? compare(
    List<double> a,
    List<double> b, {
    double minEffectSize = InsightThresholds.minCliffsDelta,
  }) {
    return compareGroups(
      kind: InsightKind.proteinTargetNextDayOutput,
      metric: InsightMetric.strengthTonnageKg,
      groupA: InsightGroup.proteinTargetMet,
      groupB: InsightGroup.proteinTargetNotMet,
      samplesA: samples(a),
      samplesB: samples(b, startIndex: 100),
      minEffectSize: minEffectSize,
    );
  }

  group('sample-size gates', () {
    test(
      'below 10 paired observations there is no insight, however large '
      'the separation',
      () {
        // 5 v 4 = 9 pairs, perfectly separated, 10x difference.
        final insight = compare(repeated(100, 5), repeated(10, 4));
        expect(insight, isNull);
      },
    );

    test('exactly 10 paired observations is enough', () {
      final insight = compare(repeated(100, 5), repeated(10, 5));
      expect(insight, isNotNull);
      expect(insight!.pairedObservations, 10);
    });

    test('fewer than 4 in one arm produces no insight', () {
      // 11 v 3 = 14 pairs overall, but one arm cannot carry a median.
      expect(compare(repeated(100, 11), repeated(10, 3)), isNull);
      expect(compare(repeated(100, 3), repeated(10, 11)), isNull);
    });

    test('4 in the smaller arm is enough', () {
      final insight = compare(repeated(100, 6), repeated(10, 4));
      expect(insight, isNotNull);
      expect(insight!.lowerGroupCount, 4);
    });
  });

  group('effect-size gates', () {
    test('a trivial difference produces no insight even when perfectly '
        'separated', () {
      // Medians 102 v 97 => 5.15% apart, under the 10% floor, although
      // Cliff's delta is a perfect 1.0.
      final insight = compare(
        const [100, 101, 102, 103, 104],
        const [95, 96, 97, 98, 99],
      );
      expect(insight, isNull);
    });

    test('a large median gap with heavily overlapping groups produces no '
        'insight', () {
      // Medians 10 v 200 (a 19x difference) but Cliff's delta is only
      // -0.2: the groups interleave, so the gap is one or two sessions,
      // not a pattern.
      final insight = compare(
        const [10, 10, 10, 10, 100],
        const [9, 9, 200, 200, 200],
      );
      expect(insight, isNull);
    });

    test('the effect-size floor cannot be lowered by a caller', () {
      final insight = compare(
        const [10, 10, 10, 10, 100],
        const [9, 9, 200, 200, 200],
        minEffectSize: 0,
      );
      expect(insight, isNull);
    });

    test('the effect-size floor can be raised by a caller', () {
      // Delta here is 1.0, so a floor above 1 rejects everything.
      expect(compare(repeated(100, 5), repeated(10, 5)), isNotNull);
      expect(
        compare(repeated(100, 5), repeated(10, 5), minEffectSize: 1.01),
        isNull,
      );
    });

    test('a zero median in the lower group produces no insight', () {
      // A relative difference against zero is undefined; the engine
      // refuses rather than reporting an infinite improvement.
      expect(compare(repeated(100, 5), repeated(0, 5)), isNull);
    });

    test('identical groups produce no insight', () {
      expect(compare(repeated(100, 6), repeated(100, 6)), isNull);
    });
  });

  group('effect-size arithmetic', () {
    test('matches a hand-computed 14% fixture', () {
      // 6 days at 5700 kg against 6 days at 5000 kg.
      // relative difference = 700 / 5000 = 0.14
      // Cliff's delta = every pair favours the first group = 1.0
      final insight = compare(repeated(5700, 6), repeated(5000, 6))!;

      expect(insight.higherTypicalValue, 5700);
      expect(insight.lowerTypicalValue, 5000);
      expect(insight.relativeDifference, closeTo(0.14, 1e-9));
      expect(insight.effectSize, closeTo(1, 1e-9));
      expect(insight.pairedObservations, 12);
      expect(insight.higherGroupCount, 6);
      expect(insight.lowerGroupCount, 6);
    });

    test('reports the median, so one extreme session cannot set the '
        'number shown', () {
      // The mean of the first group is 20500; its median is 5700, and
      // the median is what reaches the user.
      final insight = compare(
        const [5700, 5700, 5700, 5700, 5700, 94500],
        repeated(5000, 6),
      )!;
      expect(insight.higherTypicalValue, 5700);
    });

    test('names whichever group actually measured higher', () {
      final insight = compare(repeated(5000, 6), repeated(5700, 6))!;
      expect(insight.higherGroup, InsightGroup.proteinTargetNotMet);
      expect(insight.lowerGroup, InsightGroup.proteinTargetMet);
      expect(insight.higherGroupCount, 6);
      expect(insight.higherTypicalValue, 5700);
    });

    test('covers the full range of days that contributed', () {
      final insight = compareGroups(
        kind: InsightKind.proteinTargetNextDayOutput,
        metric: InsightMetric.strengthTonnageKg,
        groupA: InsightGroup.proteinTargetMet,
        groupB: InsightGroup.proteinTargetNotMet,
        samplesA: samples(repeated(5700, 6), startIndex: 3),
        samplesB: samples(repeated(5000, 6), startIndex: 20),
      )!;
      expect(insight.rangeStart, day(3));
      expect(insight.rangeEnd, day(25));
    });
  });

  group('confidence tiers', () {
    test('a fixture that only just clears every gate is emerging', () {
      final insight = compare(repeated(5700, 6), repeated(5000, 6))!;
      expect(insight.confidence, InsightConfidence.emerging);
    });

    test('a large, cleanly separated sample is clear', () {
      // n = 20, delta = 1.0, relative difference = 0.20.
      final insight = compare(repeated(6000, 10), repeated(5000, 10))!;
      expect(insight.confidence, InsightConfidence.clear);
    });

    test('a large sample with a small relative difference stays '
        'emerging', () {
      // n = 20 and delta = 1.0, but 12% is under the 15% clear bar.
      final insight = compare(repeated(5600, 10), repeated(5000, 10))!;
      expect(insight.relativeDifference, closeTo(0.12, 1e-9));
      expect(insight.confidence, InsightConfidence.emerging);
    });

    test('resolveConfidence needs all three conditions', () {
      expect(
        resolveConfidence(
          pairedObservations: 20,
          effectSize: 0.9,
          relativeDifference: 0.2,
        ),
        InsightConfidence.clear,
      );
      expect(
        resolveConfidence(
          pairedObservations: 19,
          effectSize: 0.9,
          relativeDifference: 0.2,
        ),
        InsightConfidence.emerging,
      );
      expect(
        resolveConfidence(
          pairedObservations: 40,
          effectSize: 0.4,
          relativeDifference: 0.9,
        ),
        InsightConfidence.emerging,
      );
      expect(
        resolveConfidence(
          pairedObservations: 40,
          effectSize: 0.9,
          relativeDifference: 0.14,
        ),
        InsightConfidence.emerging,
      );
    });
  });
}
