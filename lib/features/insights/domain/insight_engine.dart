import 'package:menfit_app/features/insights/domain/daily_observation.dart';
import 'package:menfit_app/features/insights/domain/evaluators/cycle_phase_evaluator.dart';
import 'package:menfit_app/features/insights/domain/evaluators/hydration_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/evaluators/protein_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/evaluators/wellbeing_output_evaluator.dart';
import 'package:menfit_app/features/insights/domain/insight_dataset.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';

/// The single entry point for cross-domain personal insights.
///
/// Pure and deterministic: it reads no clock, no repository, and no
/// storage. The same list of [DailyObservation]s always yields the same
/// list of [PersonalInsight]s in the same order, which is what makes the
/// whole feature testable against hand-computed fixtures.
///
/// What it does **not** do is as important as what it does. It cannot say
/// why anything happened, cannot recommend a change, and cannot compare
/// the user to anyone else — see [PersonalInsight] for how that is
/// enforced by the shape of the result rather than by wording.
class InsightEngine {
  const InsightEngine({
    this.proteinEvaluator = const ProteinOutputEvaluator(),
    this.wellbeingEvaluator = const WellbeingOutputEvaluator(),
    this.cyclePhaseEvaluator = const CyclePhaseEvaluator(),
    this.hydrationEvaluator = const HydrationOutputEvaluator(),
  });

  final ProteinOutputEvaluator proteinEvaluator;
  final WellbeingOutputEvaluator wellbeingEvaluator;
  final CyclePhaseEvaluator cyclePhaseEvaluator;
  final HydrationOutputEvaluator hydrationEvaluator;

  /// Finds every pattern in [observations] that clears
  /// [InsightThresholds], ranked strongest first and capped at
  /// `InsightThresholds.maxSimultaneousInsights`.
  ///
  /// At most one insight survives per [InsightKind]: an evaluator may find
  /// the same pairing in more than one metric, and showing "protein and
  /// distance" beside "protein and tonnage" would present one pattern
  /// twice and read as corroboration. The strongest metric for a kind
  /// wins; the others are discarded.
  ///
  /// Ranking is by confidence, then effect size, then sample size, then
  /// [InsightKind] declaration order — the last purely so ties resolve the
  /// same way every run rather than by list arrival order.
  List<PersonalInsight> evaluate(List<DailyObservation> observations) {
    final dataset = InsightDataset.from(observations);

    final found = <PersonalInsight>[
      ...proteinEvaluator.evaluate(dataset),
      ...wellbeingEvaluator.evaluate(dataset),
      ...cyclePhaseEvaluator.evaluate(dataset),
      ...hydrationEvaluator.evaluate(dataset),
    ];

    final bestPerKind = <InsightKind, PersonalInsight>{};
    for (final insight in found) {
      final existing = bestPerKind[insight.kind];
      if (existing == null || _rank(insight, existing) < 0) {
        bestPerKind[insight.kind] = insight;
      }
    }

    final ranked = bestPerKind.values.toList()..sort(_rank);
    if (ranked.length <= InsightThresholds.maxSimultaneousInsights) {
      return List<PersonalInsight>.unmodifiable(ranked);
    }
    return List<PersonalInsight>.unmodifiable(
      ranked.take(InsightThresholds.maxSimultaneousInsights),
    );
  }

  /// Negative when [a] should be shown before [b].
  ///
  /// A total order once kinds are unique, so the unstable `List.sort` is
  /// still deterministic. While *de*duplicating, where both sides share a
  /// kind, a full tie resolves to 0 and the first-emitted insight is kept
  /// — and emission order is itself fixed, since every evaluator walks a
  /// `const` list of metrics.
  static int _rank(PersonalInsight a, PersonalInsight b) {
    final byConfidence = b.confidence.index.compareTo(a.confidence.index);
    if (byConfidence != 0) return byConfidence;

    final byEffect = b.effectSize.compareTo(a.effectSize);
    if (byEffect != 0) return byEffect;

    final bySample = b.pairedObservations.compareTo(a.pairedObservations);
    if (bySample != 0) return bySample;

    return a.kind.index.compareTo(b.kind.index);
  }
}
