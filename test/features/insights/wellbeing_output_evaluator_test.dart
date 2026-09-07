import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/wellbeing_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

import 'insight_fixtures.dart';

void main() {
  const evaluator = WellbeingOutputEvaluator();

  List<PersonalInsight> run(List<DailyObservation> days) =>
      evaluator.evaluate(InsightDataset.from(days));

  test('compares higher-score days with lower-score days on the same '
      'day', () {
    final days = [
      for (var i = 1; i <= 5; i++) obs(i, sleep: 5, runMeters: 6000),
      for (var i = 6; i <= 10; i++) obs(i, sleep: 1, runMeters: 5000),
    ];

    final insight = run(days).single;
    expect(insight.kind, InsightKind.sleepScoreSameDayOutput);
    expect(insight.metric, InsightMetric.runDistanceMeters);
    expect(insight.higherGroup, InsightGroup.higherSleepScore);
    expect(insight.pairedObservations, 10);
    expect(insight.relativeDifference, closeTo(0.2, 1e-9));
  });

  test('drops the neutral middle score from both arms', () {
    final days = [
      for (var i = 1; i <= 5; i++) obs(i, sleep: 5, runMeters: 6000),
      for (var i = 6; i <= 10; i++) obs(i, sleep: 1, runMeters: 5000),
      // Four days scored 3 with wildly atypical runs. Folding them into
      // either arm would take the sample to 14 and drag the medians.
      for (var i = 11; i <= 14; i++) obs(i, sleep: 3, runMeters: 100000),
    ];

    final insight = run(days).single;
    expect(insight.pairedObservations, 10);
    expect(insight.higherTypicalValue, 6000);
    expect(insight.lowerTypicalValue, 5000);
  });

  test('drops days where the score was never answered', () {
    final days = [
      for (var i = 1; i <= 5; i++) obs(i, sleep: 5, runMeters: 6000),
      for (var i = 6; i <= 10; i++) obs(i, sleep: 1, runMeters: 5000),
      // Logged runs, no check-in. A null score is not a low score.
      for (var i = 11; i <= 16; i++) obs(i, runMeters: 100000),
    ];

    final insight = run(days).single;
    expect(insight.pairedObservations, 10);
  });

  test('a single extreme session does not flip the verdict', () {
    // Medians say the higher-sleep days ran further. Arithmetic means say
    // the opposite (15000 m against 20833 m), purely because of one
    // 100 km entry among the low-sleep days.
    final days = [
      for (var i = 1; i <= 5; i++) obs(i, sleep: 5, runMeters: 6000),
      obs(6, sleep: 5, runMeters: 60000),
      for (var i = 7; i <= 11; i++) obs(i, sleep: 1, runMeters: 5000),
      obs(12, sleep: 1, runMeters: 100000),
    ];

    final insight = run(days).single;
    expect(insight.higherGroup, InsightGroup.higherSleepScore);
    expect(insight.lowerGroup, InsightGroup.lowerSleepScore);
    expect(insight.higherTypicalValue, 6000);
    expect(insight.lowerTypicalValue, 5000);
    expect(insight.effectSize, closeTo(24 / 36, 1e-9));
  });

  test('energy is reported as its own kind', () {
    final days = [
      for (var i = 1; i <= 5; i++) obs(i, energy: 4, runMeters: 6000),
      for (var i = 6; i <= 10; i++) obs(i, energy: 2, runMeters: 5000),
    ];

    final insight = run(days).single;
    expect(insight.kind, InsightKind.energyScoreSameDayOutput);
    expect(insight.higherGroup, InsightGroup.higherEnergyScore);
  });

  test('sleep and energy are found independently of each other', () {
    final days = [
      for (var i = 1; i <= 5; i++) obs(i, sleep: 5, energy: 5, runMeters: 6000),
      for (var i = 6; i <= 10; i++)
        obs(i, sleep: 1, energy: 1, runMeters: 5000),
    ];

    expect(
      run(days).map((insight) => insight.kind),
      containsAll(<InsightKind>[
        InsightKind.sleepScoreSameDayOutput,
        InsightKind.energyScoreSameDayOutput,
      ]),
    );
  });

  test('produces nothing when only one arm has days', () {
    final days = [
      for (var i = 1; i <= 12; i++) obs(i, sleep: 5, runMeters: 6000),
    ];
    expect(run(days), isEmpty);
  });
}
