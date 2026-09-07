import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/protein_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/insight_engine.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

import 'insight_fixtures.dart';

void main() {
  const engine = InsightEngine();

  /// A fixture rich enough that four separate kinds clear every gate:
  /// sleep, energy and hydration on same-day run distance, and protein on
  /// the following day's output.
  ///
  /// [offset] shifts every date without touching a single number, which
  /// is how the "no clock" property is checked.
  List<DailyObservation> richFixture({int offset = 0}) {
    return <DailyObservation>[
      obs(
        1 + offset,
        sleep: 5,
        energy: 5,
        waterMl: 2000,
        waterTargetMl: 2000,
        proteinGrams: 100,
        proteinTargetGrams: 100,
        runMeters: 6000,
      ),
      for (var i = 2; i <= 12; i++)
        obs(
          i + offset,
          sleep: 5,
          energy: 5,
          waterMl: 2000,
          waterTargetMl: 2000,
          proteinGrams: 100,
          proteinTargetGrams: 100,
          runMeters: 6000,
          tonnageKg: 5700,
        ),
      obs(
        13 + offset,
        sleep: 1,
        energy: 1,
        waterMl: 500,
        waterTargetMl: 2000,
        proteinGrams: 50,
        proteinTargetGrams: 100,
        runMeters: 5000,
        tonnageKg: 5700,
      ),
      for (var i = 14; i <= 24; i++)
        obs(
          i + offset,
          sleep: 1,
          energy: 1,
          waterMl: 500,
          waterTargetMl: 2000,
          proteinGrams: 50,
          proteinTargetGrams: 100,
          runMeters: 5000,
          tonnageKg: 5000,
        ),
      obs(25 + offset, tonnageKg: 5000),
    ];
  }

  test('returns nothing for an empty history', () {
    expect(engine.evaluate(const []), isEmpty);
  });

  test('caps how many insights surface at once', () {
    final insights = engine.evaluate(richFixture());
    expect(insights, hasLength(InsightThresholds.maxSimultaneousInsights));
  });

  test('ranks by strength, not by declaration order', () {
    final insights = engine.evaluate(richFixture());

    // Sleep, energy and hydration all separate perfectly (delta 1.0) on
    // 24 days; protein separates slightly less well, so it is the one
    // the cap drops - even though its kind is declared first.
    expect(
      insights.map((insight) => insight.kind).toList(),
      <InsightKind>[
        InsightKind.sleepScoreSameDayOutput,
        InsightKind.energyScoreSameDayOutput,
        InsightKind.hydrationTargetSameDayOutput,
      ],
    );
    for (final insight in insights) {
      expect(insight.confidence, InsightConfidence.clear);
      expect(insight.effectSize, closeTo(1, 1e-9));
    }
  });

  test('the dropped insight was a real one, not a rejected one', () {
    // Guards the previous test: protein is absent because of the cap,
    // which is only meaningful if it would otherwise have surfaced.
    const proteinEvaluator = ProteinOutputEvaluator();
    final direct = proteinEvaluator.evaluate(
      InsightDataset.from(richFixture()),
    );
    expect(direct, isNotEmpty);

    final kinds = engine.evaluate(richFixture()).map((i) => i.kind);
    expect(kinds, isNot(contains(InsightKind.proteinTargetNextDayOutput)));
  });

  test('shows each kind at most once, keeping its strongest metric', () {
    final insights = engine.evaluate(richFixture());
    final kinds = insights.map((insight) => insight.kind).toList();
    expect(kinds.toSet(), hasLength(kinds.length));

    final sleep = insights.firstWhere(
      (insight) => insight.kind == InsightKind.sleepScoreSameDayOutput,
    );
    // Sleep also separates on strength tonnage, but less cleanly; only
    // the stronger of the two reaches the user.
    expect(sleep.metric, InsightMetric.runDistanceMeters);
  });

  test('is deterministic regardless of the order days arrive in', () {
    final forwards = engine.evaluate(richFixture());
    final backwards = engine.evaluate(richFixture().reversed.toList());
    expectSameInsights(forwards, backwards);
  });

  test('keeps the first observation when a day appears twice', () {
    final duplicated = <DailyObservation>[
      ...richFixture(),
      // A second, wildly different observation for day 1.
      obs(1, sleep: 1, energy: 1, runMeters: 999999),
    ];
    expectSameInsights(
      engine.evaluate(richFixture()),
      engine.evaluate(duplicated),
    );
  });

  test('reads no clock: shifting every date leaves the statistics '
      'identical', () {
    final original = engine.evaluate(richFixture());
    final shifted = engine.evaluate(richFixture(offset: 365));

    expect(shifted, hasLength(original.length));
    for (var i = 0; i < original.length; i++) {
      expect(shifted[i].kind, original[i].kind);
      expect(shifted[i].metric, original[i].metric);
      expect(shifted[i].effectSize, original[i].effectSize);
      expect(shifted[i].relativeDifference, original[i].relativeDifference);
      expect(shifted[i].pairedObservations, original[i].pairedObservations);
      expect(shifted[i].confidence, original[i].confidence);
      // Only the range moves, and by exactly the shift.
      expect(original[i].rangeStart.difference(shifted[i].rangeStart), 365);
      expect(original[i].rangeEnd.difference(shifted[i].rangeEnd), 365);
    }
  });

  test('every surfaced insight carries the sample size behind it', () {
    for (final insight in engine.evaluate(richFixture())) {
      expect(
        insight.pairedObservations,
        greaterThanOrEqualTo(InsightThresholds.minPairedObservations),
      );
      expect(
        insight.pairedObservations,
        insight.higherGroupCount + insight.lowerGroupCount,
      );
      expect(
        insight.higherGroupCount,
        greaterThanOrEqualTo(InsightThresholds.minObservationsPerGroup),
      );
      expect(
        insight.lowerGroupCount,
        greaterThanOrEqualTo(InsightThresholds.minObservationsPerGroup),
      );
      expect(
        insight.relativeDifference,
        greaterThanOrEqualTo(InsightThresholds.minRelativeDifference),
      );
      expect(
        insight.effectSize,
        greaterThanOrEqualTo(InsightThresholds.minCliffsDelta),
      );
    }
  });

  test('sparse data produces no insight at all', () {
    // Nine well-separated days: exactly the shape a new user has, and
    // exactly the shape the app must stay quiet about.
    final days = [
      for (var i = 1; i <= 4; i++)
        obs(
          i,
          sleep: 5,
          energy: 5,
          waterMl: 2000,
          waterTargetMl: 2000,
          proteinGrams: 100,
          proteinTargetGrams: 100,
          runMeters: 6000,
        ),
      for (var i = 5; i <= 9; i++)
        obs(
          i,
          sleep: 1,
          energy: 1,
          waterMl: 500,
          waterTargetMl: 2000,
          proteinGrams: 50,
          proteinTargetGrams: 100,
          runMeters: 5000,
        ),
    ];
    expect(engine.evaluate(days), isEmpty);
  });
}

void expectSameInsights(
  List<PersonalInsight> actual,
  List<PersonalInsight> expected,
) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i].kind, expected[i].kind);
    expect(actual[i].metric, expected[i].metric);
    expect(actual[i].higherGroup, expected[i].higherGroup);
    expect(actual[i].lowerGroup, expected[i].lowerGroup);
    expect(actual[i].higherTypicalValue, expected[i].higherTypicalValue);
    expect(actual[i].lowerTypicalValue, expected[i].lowerTypicalValue);
    expect(actual[i].relativeDifference, expected[i].relativeDifference);
    expect(actual[i].effectSize, expected[i].effectSize);
    expect(actual[i].pairedObservations, expected[i].pairedObservations);
    expect(actual[i].confidence, expected[i].confidence);
    expect(actual[i].cyclePhase, expected[i].cyclePhase);
    expect(actual[i].rangeStart, expected[i].rangeStart);
    expect(actual[i].rangeEnd, expected[i].rangeEnd);
  }
}
