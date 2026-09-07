import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// Compares training output on the day **after** a day whose protein
/// target was met against output on the day after one where it was not.
///
/// The lag is deliberate and is the only ordering assumption here: it
/// pairs each day's fuelling with the *following* day's session so that
/// the session cannot have influenced the intake figure it is paired
/// with. That removes one obvious reverse-direction artefact. It does not
/// establish direction — nothing in a self-logged observational record
/// can, which is why [PersonalInsight] has no way to say so.
///
/// A day is dropped unless it has both a logged intake and a target in
/// force, and the following day is present with a usable metric value.
class ProteinOutputEvaluator {
  const ProteinOutputEvaluator();

  static const List<InsightMetric> _metrics = [
    InsightMetric.strengthTonnageKg,
    InsightMetric.runDistanceMeters,
  ];

  List<PersonalInsight> evaluate(InsightDataset dataset) {
    final insights = <PersonalInsight>[];
    for (final metric in _metrics) {
      final insight = _evaluateMetric(dataset, metric);
      if (insight != null) insights.add(insight);
    }
    return insights;
  }

  PersonalInsight? _evaluateMetric(
    InsightDataset dataset,
    InsightMetric metric,
  ) {
    final met = <ObservationSample>[];
    final notMet = <ObservationSample>[];

    for (final day in dataset.days) {
      final targetMet = day.proteinTargetMet(
        InsightThresholds.targetMetFraction,
      );
      if (targetMet == null) continue;

      final nextDay = dataset.next(day);
      if (nextDay == null) continue;

      final value = nextDay.metricValue(metric);
      if (value == null) continue;

      final sample = ObservationSample(day: nextDay.day, value: value);
      if (targetMet) {
        met.add(sample);
      } else {
        notMet.add(sample);
      }
    }

    return compareGroups(
      kind: InsightKind.proteinTargetNextDayOutput,
      metric: metric,
      groupA: InsightGroup.proteinTargetMet,
      groupB: InsightGroup.proteinTargetNotMet,
      samplesA: met,
      samplesB: notMet,
    );
  }
}
