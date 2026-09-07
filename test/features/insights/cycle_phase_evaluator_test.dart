import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/cycle_phase_evaluator.dart';
import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

import 'insight_fixtures.dart';

void main() {
  const evaluator = CyclePhaseEvaluator();

  List<PersonalInsight> run(List<DailyObservation> days) =>
      evaluator.evaluate(InsightDataset.from(days));

  test('singles out one phase against the rest when phases are unevenly '
      'represented', () {
    // 5 menstrual days at RPE 8, 3 follicular at 4, 6 luteal at 6.
    final days = <DailyObservation>[
      for (var i = 1; i <= 5; i++) obs(i, phase: CyclePhase.menstrual, rpe: 8),
      for (var i = 6; i <= 8; i++) obs(i, phase: CyclePhase.follicular, rpe: 4),
      for (var i = 9; i <= 14; i++) obs(i, phase: CyclePhase.luteal, rpe: 6),
    ];

    final insight = run(days).single;
    expect(insight.kind, InsightKind.cyclePhaseExertion);
    expect(insight.metric, InsightMetric.perceivedExertion);
    expect(insight.cyclePhase, CyclePhase.menstrual);
    expect(insight.higherGroup, InsightGroup.cyclePhaseFocus);
    expect(insight.lowerGroup, InsightGroup.otherCyclePhases);
    expect(insight.higherGroupCount, 5);
    expect(insight.lowerGroupCount, 9);
    expect(insight.pairedObservations, 14);
    expect(insight.higherTypicalValue, 8);
    expect(insight.lowerTypicalValue, 6);
    expect(insight.effectSize, closeTo(1, 1e-9));
  });

  test('a phase with fewer than 4 days can never be the one singled out', () {
    // Follicular is by far the most extreme, and by far the smallest.
    final days = <DailyObservation>[
      for (var i = 1; i <= 5; i++) obs(i, phase: CyclePhase.menstrual, rpe: 5),
      for (var i = 6; i <= 8; i++) obs(i, phase: CyclePhase.follicular, rpe: 1),
      for (var i = 9; i <= 13; i++) obs(i, phase: CyclePhase.luteal, rpe: 5),
    ];

    expect(run(days), isEmpty);
  });

  test('applies a stricter effect-size floor than an ordinary '
      'comparison', () {
    // Cliff's delta here is 0.333 - past the ordinary medium floor, short
    // of the large floor the four-way phase search requires.
    final days = <DailyObservation>[
      for (var i = 1; i <= 6; i++) obs(i, phase: CyclePhase.menstrual, rpe: 5),
      obs(7, phase: CyclePhase.luteal, rpe: 4),
      obs(8, phase: CyclePhase.luteal, rpe: 4),
      for (var i = 9; i <= 12; i++) obs(i, phase: CyclePhase.luteal, rpe: 6),
    ];

    expect(run(days), isEmpty);

    // The very same numbers do clear the ordinary floor, which is what
    // makes this a test of the correction rather than of the data.
    final ordinary = compareGroups(
      kind: InsightKind.sleepScoreSameDayOutput,
      metric: InsightMetric.perceivedExertion,
      groupA: InsightGroup.higherSleepScore,
      groupB: InsightGroup.lowerSleepScore,
      samplesA: samples(repeated(5, 6)),
      samplesB: samples(const [4, 4, 6, 6, 6, 6], startIndex: 20),
    );
    expect(ordinary, isNotNull);
    expect(ordinary!.effectSize, closeTo(1 / 3, 1e-9));
  });

  test('ignores days with no tracked phase', () {
    final days = <DailyObservation>[
      for (var i = 1; i <= 5; i++) obs(i, phase: CyclePhase.menstrual, rpe: 8),
      for (var i = 6; i <= 14; i++) obs(i, phase: CyclePhase.luteal, rpe: 6),
      // Untracked days, and days explicitly resolved to `none`, are not a
      // phase and must not be pooled into the comparison group.
      for (var i = 15; i <= 25; i++) obs(i, rpe: 1),
      for (var i = 26; i <= 36; i++) obs(i, phase: CyclePhase.none, rpe: 1),
    ];

    final insight = run(days).single;
    expect(insight.pairedObservations, 14);
    expect(insight.lowerGroupCount, 9);
  });

  test('produces nothing without at least 10 phase-tagged sessions', () {
    final days = <DailyObservation>[
      for (var i = 1; i <= 5; i++) obs(i, phase: CyclePhase.menstrual, rpe: 8),
      for (var i = 6; i <= 9; i++) obs(i, phase: CyclePhase.luteal, rpe: 4),
    ];
    expect(run(days), isEmpty);
  });

  test('produces nothing when a phase is tagged but no session was '
      'logged', () {
    final days = <DailyObservation>[
      for (var i = 1; i <= 8; i++) obs(i, phase: CyclePhase.menstrual),
      for (var i = 9; i <= 16; i++) obs(i, phase: CyclePhase.luteal),
    ];
    expect(run(days), isEmpty);
  });
}
