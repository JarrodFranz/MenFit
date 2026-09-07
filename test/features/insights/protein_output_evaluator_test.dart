import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/protein_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

import 'insight_fixtures.dart';

void main() {
  const evaluator = ProteinOutputEvaluator();

  List<PersonalInsight> run(List<DailyObservation> days) =>
      evaluator.evaluate(InsightDataset.from(days));

  /// Days 1-12 log protein against a 100 g target: 1-6 meet it, 7-12 do
  /// not. Strength tonnage runs one day behind: days 2-7 at 5700 kg (the
  /// mornings after a met target) and days 8-13 at 5000 kg.
  List<DailyObservation> baseline() => [
    obs(1, proteinGrams: 100, proteinTargetGrams: 100),
    for (var i = 2; i <= 6; i++)
      obs(i, proteinGrams: 100, proteinTargetGrams: 100, tonnageKg: 5700),
    obs(7, proteinGrams: 50, proteinTargetGrams: 100, tonnageKg: 5700),
    for (var i = 8; i <= 12; i++)
      obs(i, proteinGrams: 50, proteinTargetGrams: 100, tonnageKg: 5000),
    obs(13, tonnageKg: 5000),
  ];

  test('pairs each day with the following day and reports the effect', () {
    final insights = run(baseline());

    expect(insights, hasLength(1));
    final insight = insights.single;
    expect(insight.kind, InsightKind.proteinTargetNextDayOutput);
    expect(insight.metric, InsightMetric.strengthTonnageKg);
    expect(insight.higherGroup, InsightGroup.proteinTargetMet);
    expect(insight.lowerGroup, InsightGroup.proteinTargetNotMet);
    expect(insight.higherTypicalValue, 5700);
    expect(insight.lowerTypicalValue, 5000);
    expect(insight.relativeDifference, closeTo(0.14, 1e-9));
    expect(insight.pairedObservations, 12);
    expect(insight.higherGroupCount, 6);
    expect(insight.lowerGroupCount, 6);
    expect(insight.confidence, InsightConfidence.emerging);
    // The range covers the outcome days, which is what the insight is
    // actually about.
    expect(insight.rangeStart, day(2));
    expect(insight.rangeEnd, day(13));
  });

  test('produces nothing below 10 paired observations', () {
    final days = [
      obs(1, proteinGrams: 100, proteinTargetGrams: 100),
      for (var i = 2; i <= 4; i++)
        obs(i, proteinGrams: 100, proteinTargetGrams: 100, tonnageKg: 5700),
      obs(5, proteinGrams: 50, proteinTargetGrams: 100, tonnageKg: 5700),
      for (var i = 6; i <= 8; i++)
        obs(i, proteinGrams: 50, proteinTargetGrams: 100, tonnageKg: 5000),
      obs(9, tonnageKg: 5000),
    ];

    // 4 met and 4 not-met pairs: a perfectly clean 14% separation that
    // the engine still refuses to report.
    expect(run(days), isEmpty);
  });

  test('drops days with no logged protein instead of scoring them as '
      'unmet', () {
    final days = [
      obs(1, proteinGrams: 100, proteinTargetGrams: 100),
      for (var i = 2; i <= 6; i++)
        obs(i, proteinGrams: 100, proteinTargetGrams: 100, tonnageKg: 5700),
      obs(7, proteinGrams: 50, proteinTargetGrams: 100, tonnageKg: 5700),
      for (var i = 8; i <= 10; i++)
        obs(i, proteinGrams: 50, proteinTargetGrams: 100, tonnageKg: 5000),
      // Six days where nothing was logged at all. Zero grams would count
      // as a missed target and inflate the not-met arm from 4 to 10.
      for (var i = 11; i <= 16; i++)
        obs(i, proteinTargetGrams: 100, tonnageKg: 5000),
      obs(17, tonnageKg: 5000),
    ];

    final insight = run(days).single;
    expect(insight.pairedObservations, 10);
    expect(insight.higherGroupCount, 6);
    expect(insight.lowerGroupCount, 4);
  });

  test('produces nothing when no protein target is set', () {
    final days = [
      for (var i = 1; i <= 6; i++) obs(i, proteinGrams: 100, tonnageKg: 5700),
      for (var i = 7; i <= 13; i++) obs(i, proteinGrams: 50, tonnageKg: 5000),
    ];
    expect(run(days), isEmpty);
  });

  test('drops a pair when the following day is missing from the data', () {
    final days = baseline()
        .where((observation) => observation.day != day(7))
        .toList();

    final insight = run(days).single;
    expect(insight.pairedObservations, 10);
    expect(insight.higherGroupCount, 5);
    expect(insight.lowerGroupCount, 5);
  });

  test('drops a pair when the following day has no session, rather than '
      'counting it as zero output', () {
    final days = [
      ...baseline(),
      // Three more met days whose following days are rest days. Treating
      // a rest day as zero output would add them to the met arm.
      for (var i = 14; i <= 16; i++)
        obs(i, proteinGrams: 100, proteinTargetGrams: 100),
      obs(17),
    ];

    final insight = run(days).single;
    expect(insight.pairedObservations, 12);
    expect(insight.higherGroupCount, 6);
  });

  test('is silent about a metric the days never recorded', () {
    // The baseline has no runs at all, so no distance insight exists
    // beside the tonnage one.
    final insights = run(baseline());
    expect(
      insights.where((i) => i.metric == InsightMetric.runDistanceMeters),
      isEmpty,
    );
  });
}
