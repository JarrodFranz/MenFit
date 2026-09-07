import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// Turns a [PersonalInsight]'s enum-and-number parts into the one sentence
/// shape this feature is allowed to say.
///
/// ## The shape, and why it is fixed
///
/// > *Across N logged days, `metric` was X% higher on `group` than on
/// > `other group`.*
///
/// Three properties are load-bearing, and every phrase below is chosen to
/// preserve them:
///
/// 1. **It is descriptive, never causal.** No "because", no "when you ...,
///    you ...", no "this improves". The domain layer cannot express
///    causation ([PersonalInsight] has no free text at all), and this
///    layer must not reintroduce it in prose.
/// 2. **It never advises.** No "try", no "aim for", no "should". A
///    training or nutrition recommendation tied to any of these signals —
///    cycle phase above all — needs a documented evidence review first
///    (`knowledge/domain/womens_health.md` rule 2).
/// 3. **It never generalises past her.** Every phrase is second-person and
///    about her own logs. Nothing here may say what women, or athletes, or
///    anyone else does.
///
/// The sample size is always carried in the sentence itself — an insight
/// read without its `n` is a stronger claim than the data supports, which
/// is exactly why [PersonalInsight.pairedObservations] is exported.
String composeInsightSentence(PersonalInsight insight) {
  final percent = (insight.relativeDifference * 100).round();
  final higher = _groupPhrase(insight.higherGroup, insight.cyclePhase);
  final lower = _groupPhrase(insight.lowerGroup, insight.cyclePhase);

  return 'Across ${insight.pairedObservations} logged days, '
      '${_metricPhrase(insight.metric)} was $percent% higher on '
      '$higher than on $lower.';
}

/// The supporting line under the sentence: how firmly the data separates,
/// and the span of days the comparison drew on.
///
/// "Emerging"/"Clear" are [InsightConfidence]'s own two words — deliberately
/// not a percentage or a p-value, which would invite reading a personal,
/// self-reported pattern as a test result.
String composeInsightFootnote(PersonalInsight insight) {
  final label = switch (insight.confidence) {
    InsightConfidence.emerging => 'Emerging pattern',
    InsightConfidence.clear => 'Clear pattern',
  };
  final start = _formatDay(insight.rangeStart);
  final end = _formatDay(insight.rangeEnd);
  return '$label · $start – $end';
}

String _metricPhrase(InsightMetric metric) {
  return switch (metric) {
    InsightMetric.runDistanceMeters => 'your run distance',
    InsightMetric.strengthTonnageKg => 'your lifting volume',
    InsightMetric.perceivedExertion => 'your perceived exertion',
  };
}

/// Names one side of the comparison as a set of *her* days.
///
/// The cycle phrasings say "your estimated luteal days" / "your other
/// estimated phases" rather than naming what a phase is or does. Two
/// things are load-bearing there. They never describe the phase, because
/// the only defensible statement is which of her own days fell in it. And
/// they say **estimated**, not "logged": what she logs is a period start,
/// and everything past "her period is logged now" is
/// `CyclePredictionEngine`'s arithmetic over her median cycle length —
/// prediction, which `knowledge/domain/womens_health.md` requires be
/// labelled as an estimate everywhere it is shown.
String _groupPhrase(InsightGroup group, CyclePhase? phase) {
  return switch (group) {
    InsightGroup.proteinTargetMet => 'days after you hit your protein target',
    InsightGroup.proteinTargetNotMet =>
      "days after you didn't hit your protein target",
    InsightGroup.higherSleepScore => 'days you rated your sleep higher',
    InsightGroup.lowerSleepScore => 'days you rated your sleep lower',
    InsightGroup.higherEnergyScore => 'days you rated your energy higher',
    InsightGroup.lowerEnergyScore => 'days you rated your energy lower',
    InsightGroup.hydrationTargetMet => 'days you hit your hydration target',
    InsightGroup.hydrationTargetNotMet =>
      "days you didn't hit your hydration target",
    InsightGroup.cyclePhaseFocus => 'your estimated ${_phraseFor(phase)} days',
    InsightGroup.otherCyclePhases => 'your other estimated phases',
  };
}

/// `PersonalInsight.cyclePhase` is non-null for exactly the two cycle
/// kinds, so the fallback is unreachable in practice; it exists so a
/// malformed insight degrades to a vaguer true sentence ("your estimated
/// cycle days") rather than throwing in a widget build.
String _phraseFor(CyclePhase? phase) {
  if (phase == null || phase == CyclePhase.none) return 'cycle';
  return phase.label.toLowerCase();
}

String _formatDay(LocalDate day) =>
    DateFormat.MMMd().format(DateTime(day.year, day.month, day.day));
