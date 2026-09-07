import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/group_comparison.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// Compares same-day sessions on days with a higher logged sleep (or
/// energy) score against days with a lower one.
///
/// Same day rather than next day: the check-in asks how they woke up
/// feeling, so it already precedes the session it is paired with.
///
/// Scores are 1-5 ordinals. Days scoring 3 are dropped from **both**
/// arms rather than assigned by a median split
/// (`InsightThresholds.highCheckinScore` /
/// `InsightThresholds.lowCheckinScore`): the middle of a five-point
/// self-report is where "I didn't really think about it" lands, and
/// splitting it would let the arbitrary side it fell on manufacture a
/// difference. Dropping it costs sample size, which the gates then
/// enforce honestly.
class WellbeingOutputEvaluator {
  const WellbeingOutputEvaluator();

  static const List<InsightMetric> _metrics = [
    InsightMetric.runDistanceMeters,
    InsightMetric.strengthTonnageKg,
    InsightMetric.perceivedExertion,
  ];

  List<PersonalInsight> evaluate(InsightDataset dataset) {
    final insights = <PersonalInsight>[];
    for (final metric in _metrics) {
      final sleep = _evaluate(
        dataset: dataset,
        metric: metric,
        kind: InsightKind.sleepScoreSameDayOutput,
        highScoreGroup: InsightGroup.higherSleepScore,
        lowScoreGroup: InsightGroup.lowerSleepScore,
        score: (day) => day.sleep,
      );
      if (sleep != null) insights.add(sleep);

      final energy = _evaluate(
        dataset: dataset,
        metric: metric,
        kind: InsightKind.energyScoreSameDayOutput,
        highScoreGroup: InsightGroup.higherEnergyScore,
        lowScoreGroup: InsightGroup.lowerEnergyScore,
        score: (day) => day.energy,
      );
      if (energy != null) insights.add(energy);
    }
    return insights;
  }

  PersonalInsight? _evaluate({
    required InsightDataset dataset,
    required InsightMetric metric,
    required InsightKind kind,
    required InsightGroup highScoreGroup,
    required InsightGroup lowScoreGroup,
    required int? Function(DailyObservation day) score,
  }) {
    final high = <ObservationSample>[];
    final low = <ObservationSample>[];

    for (final day in dataset.days) {
      final value = score(day);
      if (value == null) continue;

      final isHigh = value >= InsightThresholds.highCheckinScore;
      final isLow = value <= InsightThresholds.lowCheckinScore;
      if (!isHigh && !isLow) continue;

      final metricValue = day.metricValue(metric);
      if (metricValue == null) continue;

      final sample = ObservationSample(day: day.day, value: metricValue);
      if (isHigh) {
        high.add(sample);
      } else {
        low.add(sample);
      }
    }

    return compareGroups(
      kind: kind,
      metric: metric,
      groupA: highScoreGroup,
      groupB: lowScoreGroup,
      samplesA: high,
      samplesB: low,
    );
  }
}
