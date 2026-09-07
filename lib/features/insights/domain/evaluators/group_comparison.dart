import 'dart:math' as math;

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/insights/domain/insight_statistics.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// One retained day: the metric value it contributed, and the day it came
/// from (kept so an insight can state the range it covers).
class ObservationSample {
  const ObservationSample({required this.day, required this.value});

  final LocalDate day;
  final double value;
}

/// The single gate every insight in this feature passes through.
///
/// Every evaluator funnels here rather than doing its own arithmetic, so
/// there is exactly one place where the sample-size, effect-size, and
/// confidence rules live and exactly one place to audit them.
///
/// Returns `null` — meaning *this insight does not exist* — unless all of
/// the following hold:
///
/// 1. at least `InsightThresholds.minPairedObservations` retained days in
///    total;
/// 2. at least `InsightThresholds.minObservationsPerGroup` in **each**
///    group;
/// 3. the lower group's median is strictly positive (a relative
///    difference against zero is undefined);
/// 4. the relative difference between medians reaches
///    `InsightThresholds.minRelativeDifference`;
/// 5. the absolute Cliff's delta reaches the effective effect-size floor.
///
/// [minEffectSize] may only ever **raise** the floor: it is combined with
/// `InsightThresholds.minCliffsDelta` by taking the larger of the two, so
/// no caller can weaken the gate by passing a small number.
PersonalInsight? compareGroups({
  required InsightKind kind,
  required InsightMetric metric,
  required InsightGroup groupA,
  required InsightGroup groupB,
  required List<ObservationSample> samplesA,
  required List<ObservationSample> samplesB,
  double minEffectSize = InsightThresholds.minCliffsDelta,
}) {
  final countA = samplesA.length;
  final countB = samplesB.length;
  final total = countA + countB;

  if (total < InsightThresholds.minPairedObservations) return null;
  if (countA < InsightThresholds.minObservationsPerGroup) return null;
  if (countB < InsightThresholds.minObservationsPerGroup) return null;

  final valuesA = samplesA.map((sample) => sample.value).toList();
  final valuesB = samplesB.map((sample) => sample.value).toList();

  final medianA = median(valuesA)!;
  final medianB = median(valuesB)!;

  final aIsHigher = medianA >= medianB;
  final higherMedian = aIsHigher ? medianA : medianB;
  final lowerMedian = aIsHigher ? medianB : medianA;

  final difference = relativeDifference(
    higher: higherMedian,
    lower: lowerMedian,
  );
  if (difference == null) return null;
  if (difference < InsightThresholds.minRelativeDifference) return null;

  final delta = cliffsDelta(valuesA, valuesB)!.abs();
  final floor = math.max(minEffectSize, InsightThresholds.minCliffsDelta);
  if (delta < floor) return null;

  final days = [
    ...samplesA.map((sample) => sample.day),
    ...samplesB.map((sample) => sample.day),
  ]..sort();

  return PersonalInsight(
    kind: kind,
    metric: metric,
    higherGroup: aIsHigher ? groupA : groupB,
    lowerGroup: aIsHigher ? groupB : groupA,
    higherTypicalValue: higherMedian,
    lowerTypicalValue: lowerMedian,
    higherGroupCount: aIsHigher ? countA : countB,
    lowerGroupCount: aIsHigher ? countB : countA,
    relativeDifference: difference,
    effectSize: delta,
    pairedObservations: total,
    confidence: resolveConfidence(
      pairedObservations: total,
      effectSize: delta,
      relativeDifference: difference,
    ),
    rangeStart: days.first,
    rangeEnd: days.last,
  );
}

/// Maps sample size and effect size onto the two confidence words.
///
/// All three conditions must hold for [InsightConfidence.clear]; anything
/// that merely clears the gates is [InsightConfidence.emerging]. There is
/// deliberately no third, higher tier — no amount of self-reported data
/// from one person earns a word stronger than "clear".
InsightConfidence resolveConfidence({
  required int pairedObservations,
  required double effectSize,
  required double relativeDifference,
}) {
  final bigEnough =
      pairedObservations >= InsightThresholds.clearConfidenceMinObservations;
  final separatedEnough =
      effectSize >= InsightThresholds.clearConfidenceMinCliffsDelta;
  final largeEnough =
      relativeDifference >=
      InsightThresholds.clearConfidenceMinRelativeDifference;

  if (bigEnough && separatedEnough && largeEnough) {
    return InsightConfidence.clear;
  }
  return InsightConfidence.emerging;
}
