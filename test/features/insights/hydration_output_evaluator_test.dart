import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/hydration_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

import 'insight_fixtures.dart';

void main() {
  const evaluator = HydrationOutputEvaluator();

  List<PersonalInsight> run(List<DailyObservation> days) =>
      evaluator.evaluate(InsightDataset.from(days));

  test('compares same-day sessions either side of the hydration '
      'target', () {
    final days = [
      for (var i = 1; i <= 6; i++)
        obs(i, waterMl: 2000, waterTargetMl: 2000, runMeters: 6000),
      for (var i = 7; i <= 12; i++)
        obs(i, waterMl: 500, waterTargetMl: 2000, runMeters: 5000),
    ];

    final insight = run(days).single;
    expect(insight.kind, InsightKind.hydrationTargetSameDayOutput);
    expect(insight.higherGroup, InsightGroup.hydrationTargetMet);
    expect(insight.pairedObservations, 12);
    expect(insight.relativeDifference, closeTo(0.2, 1e-9));
  });

  test('stays silent when no hydration target exists', () {
    // The app has no hydration-target concept yet. Absent a target the
    // evaluator must not invent one.
    final days = [
      for (var i = 1; i <= 6; i++) obs(i, waterMl: 2000, runMeters: 6000),
      for (var i = 7; i <= 12; i++) obs(i, waterMl: 500, runMeters: 5000),
    ];
    expect(run(days), isEmpty);
  });

  test('drops days where no water was logged', () {
    final days = [
      for (var i = 1; i <= 6; i++)
        obs(i, waterMl: 2000, waterTargetMl: 2000, runMeters: 6000),
      for (var i = 7; i <= 10; i++)
        obs(i, waterMl: 500, waterTargetMl: 2000, runMeters: 5000),
      // Unlogged water is not zero water; these must not swell the
      // not-met arm from 4 to 10.
      for (var i = 11; i <= 16; i++)
        obs(i, waterTargetMl: 2000, runMeters: 5000),
    ];

    final insight = run(days).single;
    expect(insight.pairedObservations, 10);
    expect(insight.lowerGroupCount, 4);
  });

  test('counts 85% of the target as met, matching the fuelling '
      'evaluator', () {
    final days = [
      for (var i = 1; i <= 6; i++)
        obs(i, waterMl: 1700, waterTargetMl: 2000, runMeters: 6000),
      for (var i = 7; i <= 12; i++)
        obs(i, waterMl: 1600, waterTargetMl: 2000, runMeters: 5000),
    ];

    final insight = run(days).single;
    expect(insight.higherGroup, InsightGroup.hydrationTargetMet);
    expect(insight.higherGroupCount, 6);
  });
}
