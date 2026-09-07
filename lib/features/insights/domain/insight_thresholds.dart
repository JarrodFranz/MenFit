/// The statistical gates every personal insight must clear before it is
/// allowed to exist.
///
/// These are deliberately `static const` on a class with no constructor
/// rather than parameters on the engine: an insight makes a claim about a
/// woman's body from sparse, self-reported data, so no caller — not a
/// controller, not a test, not a debug flag — may relax them. An insight
/// below any gate is **absent**, never "shown with lower confidence".
///
/// Choices and why (see also `knowledge/domain/womens_health.md`, which
/// gates what this product may claim):
///
/// * [minPairedObservations] — 10. Below ~10 retained pairs the median of
///   either arm is dominated by one or two sessions, and the sign of the
///   comparison flips on a single extra log. Ten is not a significance
///   threshold; it is the point below which the number shown would be
///   noise dressed as self-knowledge.
/// * [minObservationsPerGroup] — 4. A group of 1-3 has no meaningful
///   median at all. Both arms must clear this independently, so an
///   insight built on "18 days where she hit protein and 2 where she
///   didn't" cannot surface.
/// * [minRelativeDifference] — 0.10. The difference the UI will read out
///   ("14% higher") has to be large enough that a reader would notice it
///   in her own life. A 3% difference in weekly distance is not a pattern,
///   it is rounding.
/// * [minCliffsDelta] — 0.33. Relative difference alone can be produced by
///   one outlier session, so a second, rank-based effect size has to agree.
///   Cliff's delta is the probability that a randomly chosen day from one
///   group out-measures a randomly chosen day from the other, minus the
///   reverse; it uses only orderings, so it is unaffected by how extreme
///   an outlier is. 0.33 is the conventional "medium" boundary
///   (Romano et al., 2006), i.e. the two groups genuinely separate rather
///   than overlap.
/// * [clearConfidence...] — the bar for calling a pattern *clear* rather
///   than *emerging*: twice the minimum sample, a large rank separation,
///   and half again the minimum relative difference.
/// * [maxSimultaneousInsights] — 3. More than a handful of "we noticed
///   this about you" cards stops being discovery and starts being a
///   verdict on her body.
class InsightThresholds {
  const InsightThresholds._();

  /// Minimum number of complete predictor/outcome pairs retained after
  /// incomplete days are dropped.
  static const int minPairedObservations = 10;

  /// Minimum number of observations in *each* arm of a comparison.
  static const int minObservationsPerGroup = 4;

  /// Minimum relative difference between the two group medians, as a
  /// fraction of the lower median (0.10 = 10%).
  static const double minRelativeDifference = 0.10;

  /// Minimum absolute Cliff's delta for a two-group comparison.
  static const double minCliffsDelta = 0.33;

  /// Sample size at or above which a pattern may be called *clear*.
  static const int clearConfidenceMinObservations = 20;

  /// Absolute Cliff's delta at or above which a pattern may be called
  /// *clear*.
  static const double clearConfidenceMinCliffsDelta = 0.474;

  /// Relative difference at or above which a pattern may be called
  /// *clear*.
  static const double clearConfidenceMinRelativeDifference = 0.15;

  /// How many insights may surface at once.
  static const int maxSimultaneousInsights = 3;

  /// Fraction of a nutrition target that counts as "met".
  ///
  /// Matches `features/nutrition/domain/fueling_consistency_evaluator.dart`
  /// deliberately: two surfaces telling the user different things about
  /// the same day would be worse than either threshold being slightly off.
  static const double targetMetFraction = 0.85;

  /// Check-in scores (1-5) at or above this count as the *higher* arm.
  ///
  /// The neutral middle (3) is dropped from both arms rather than split
  /// by a median: an ordinal 1-5 self-report has a large, uninformative
  /// middle, and a median split would shuffle it into whichever arm
  /// happened to be smaller and manufacture a difference.
  static const int highCheckinScore = 4;

  /// Check-in scores (1-5) at or below this count as the *lower* arm.
  static const int lowCheckinScore = 2;
}
