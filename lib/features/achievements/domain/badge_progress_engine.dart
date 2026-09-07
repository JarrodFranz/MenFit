import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_inputs.dart';
import 'package:menfit_app/features/achievements/domain/badge_metrics.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

/// The tier rank the ladder walk refuses to climb past.
///
/// Purely defensive. [computeBadgeMetrics] guarantees finite, non-negative
/// values, and every progression is strictly increasing, so the walk always
/// terminates on real data long before this. It exists so that a future
/// metric which forgets that guarantee produces a wrong badge rather than a
/// hung isolate.
const int maxResolvableTierRank = 1000;

/// Evaluates every badge in [catalogue] against [inputs].
///
/// Pure and deterministic — the same inputs always give the same answer,
/// and nothing here reads a clock (`inputs.today` is the only "now" there
/// is) or a repository. Persisted awards are **not** consulted: this
/// function says what the data currently earns, and
/// `domain/award_diff.dart` compares that against what has already been
/// recorded.
///
/// The result is in catalogue order, one entry per badge, always — a badge
/// with nothing yet earned still appears, with zero progress towards
/// Bronze, because "every badge on offer" is one of the three things the
/// screen has to show.
List<BadgeProgress> evaluateBadges({
  required BadgeInputs inputs,
  List<BadgeDefinition> catalogue = badgeCatalogue,
}) {
  final metrics = computeBadgeMetrics(inputs);
  final conditions = computeBadgeConditions(inputs);
  return [
    for (final definition in catalogue)
      evaluateBadge(
        definition: definition,
        metrics: metrics,
        conditions: conditions,
      ),
  ];
}

/// Evaluates one badge against already-computed [metrics] and [conditions].
///
/// ## Progress
///
/// A tiered badge's bar runs from the tier they have to the tier they are
/// working towards: `(value - currentThreshold) / (nextThreshold -
/// currentThreshold)`, with `currentThreshold = 0` before Bronze. Clamped
/// to `[0, 1]`, so it is never negative and never overflows — a value
/// sitting exactly on a threshold reads as that tier earned and `0`
/// progress towards the next, not as `1` towards a tier they have not got.
///
/// A one-off is `1` or `0`. There is no partial credit for a first.
BadgeProgress evaluateBadge({
  required BadgeDefinition definition,
  required Map<BadgeMetric, double> metrics,
  required Set<BadgeCondition> conditions,
}) {
  switch (definition.kind) {
    case BadgeKind.oneOff:
      final earned = conditions.contains(definition.condition);
      return BadgeProgress(
        definition: definition,
        value: earned ? 1 : 0,
        isEarned: earned,
        progressToNext: earned ? 1 : 0,
      );

    case BadgeKind.tiered:
      final ladder = definition.ladder!;
      final value = metrics[definition.metric] ?? 0;
      final earnedTier = _highestTierReached(ladder: ladder, value: value);
      final nextTier = earnedTier == null ? BadgeTier.bronze : earnedTier.next;
      final currentThreshold = earnedTier == null
          ? 0.0
          : ladder.thresholdFor(earnedTier);
      final nextThreshold = ladder.thresholdFor(nextTier);
      final span = nextThreshold - currentThreshold;
      final fraction = span <= 0 ? 0.0 : (value - currentThreshold) / span;

      return BadgeProgress(
        definition: definition,
        value: value,
        isEarned: earnedTier != null,
        earnedTier: earnedTier,
        nextTier: nextTier,
        currentThreshold: currentThreshold,
        nextThreshold: nextThreshold,
        remainingToNext: nextThreshold > value ? nextThreshold - value : 0,
        progressToNext: fraction.clamp(0.0, 1.0),
      );
  }
}

/// The highest tier whose threshold [value] has reached, or `null` when it
/// has not reached Bronze.
///
/// A threshold is reached at `>=`, so landing exactly on the number earns
/// the tier.
BadgeTier? _highestTierReached({
  required BadgeLadder ladder,
  required double value,
}) {
  if (value < ladder.bronze) return null;
  var tier = BadgeTier.bronze;
  while (tier.rank < maxResolvableTierRank) {
    final next = tier.next;
    if (value < ladder.thresholdFor(next)) return tier;
    tier = next;
  }
  return tier;
}
