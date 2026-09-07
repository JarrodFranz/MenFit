import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// Compares one cycle phase's sessions against every other logged phase's,
/// pooled.
///
/// ## What this is allowed to say, and what it is not
///
/// `knowledge/domain/womens_health.md` is explicit that phase estimation
/// is an estimate, that the literature on cycle-phase training effects is
/// mixed, and that any training or nutrition recommendation tied to phase
/// needs a documented evidence review first. This evaluator therefore
/// produces **only a description of days she herself logged**. It has no
/// vocabulary for "women in this phase", for what she should do about it,
/// or for what will happen if she does. [PersonalInsight] carries no
/// free text, so that limit is structural rather than a matter of
/// wording discipline downstream.
///
/// ## Why the effect-size floor is higher here
///
/// Picking the strongest of up to four phases is a multiple comparison:
/// with four candidate phases the chance of one separating from the rest
/// by luck alone is roughly four times that of a single pre-chosen
/// comparison. The floor is raised from the "medium" boundary to the
/// "large" one (`InsightThresholds.minCliffsDeltaCyclePhase`) to absorb
/// that, in place of a p-value correction the sample sizes here could
/// never support.
///
/// Days with no phase, or [CyclePhase.none], are excluded entirely; a
/// phase with fewer than `InsightThresholds.minObservationsPerGroup` days
/// can never be the focus, though its days still count towards the pooled
/// comparison group.
class CyclePhaseEvaluator {
  const CyclePhaseEvaluator();

  static const List<CyclePhase> _phases = [
    CyclePhase.menstrual,
    CyclePhase.follicular,
    CyclePhase.ovulatory,
    CyclePhase.luteal,
  ];

  List<PersonalInsight> evaluate(InsightDataset dataset) {
    final insights = <PersonalInsight>[];

    final exertion = _bestPhaseInsight(
      dataset: dataset,
      metric: InsightMetric.perceivedExertion,
      kind: InsightKind.cyclePhaseExertion,
    );
    if (exertion != null) insights.add(exertion);

    for (final metric in const [
      InsightMetric.runDistanceMeters,
      InsightMetric.strengthTonnageKg,
    ]) {
      final output = _bestPhaseInsight(
        dataset: dataset,
        metric: metric,
        kind: InsightKind.cyclePhaseOutput,
      );
      if (output != null) insights.add(output);
    }

    return insights;
  }

  PersonalInsight? _bestPhaseInsight({
    required InsightDataset dataset,
    required InsightMetric metric,
    required InsightKind kind,
  }) {
    final byPhase = <CyclePhase, List<ObservationSample>>{
      for (final phase in _phases) phase: <ObservationSample>[],
    };

    for (final day in dataset.days) {
      if (!day.hasTrackedPhase) continue;
      final bucket = byPhase[day.cyclePhase];
      if (bucket == null) continue;
      final value = day.metricValue(metric);
      if (value == null) continue;
      bucket.add(ObservationSample(day: day.day, value: value));
    }

    PersonalInsight? best;
    for (final phase in _phases) {
      final focus = byPhase[phase]!;
      if (focus.length < InsightThresholds.minObservationsPerGroup) continue;

      final rest = <ObservationSample>[
        for (final other in _phases)
          if (other != phase) ...byPhase[other]!,
      ];

      final insight = compareGroups(
        kind: kind,
        metric: metric,
        groupA: InsightGroup.cyclePhaseFocus,
        groupB: InsightGroup.otherCyclePhases,
        samplesA: focus,
        samplesB: rest,
        minEffectSize: InsightThresholds.minCliffsDeltaCyclePhase,
        cyclePhase: phase,
      );
      if (insight == null) continue;

      // Strict `>` keeps the earliest phase in `_phases` order on a tie,
      // so the same input always yields the same phase.
      if (best == null || insight.effectSize > best.effectSize) {
        best = insight;
      }
    }
    return best;
  }
}
