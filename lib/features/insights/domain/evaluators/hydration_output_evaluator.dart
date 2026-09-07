import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// Compares same-day sessions on days when the hydration target was
/// reached against days when it was not.
///
/// Same-day rather than lagged, because water is logged across the whole
/// day including around the session itself. That makes the direction of
/// this pairing especially unknowable — a long session is a reason to
/// drink more — which is exactly why nothing here, and nothing in
/// [PersonalInsight], can phrase it as one thing producing the other.
///
/// Stays silent whenever `DailyObservation.waterTargetMl` is absent. The
/// app has no hydration-target concept yet, so in practice this evaluator
/// is dormant until a caller has one to supply; that is the intended
/// behaviour rather than a reason to invent a default target, which would
/// have the engine measuring against a number the user never chose.
class HydrationOutputEvaluator {
  const HydrationOutputEvaluator();

  static const List<InsightMetric> _metrics = [
    InsightMetric.runDistanceMeters,
    InsightMetric.strengthTonnageKg,
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
      final targetMet = day.hydrationTargetMet(
        InsightThresholds.targetMetFraction,
      );
      if (targetMet == null) continue;

      final value = day.metricValue(metric);
      if (value == null) continue;

      final sample = ObservationSample(day: day.day, value: value);
      if (targetMet) {
        met.add(sample);
      } else {
        notMet.add(sample);
      }
    }

    return compareGroups(
      kind: InsightKind.hydrationTargetSameDayOutput,
      metric: metric,
      groupA: InsightGroup.hydrationTargetMet,
      groupB: InsightGroup.hydrationTargetNotMet,
      samplesA: met,
      samplesB: notMet,
    );
  }
}
