import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';

/// The awards [progress] earns that [existingAwards] does not already hold.
///
/// Pure: the two things that would otherwise make it untestable — the
/// moment and the id — are injected as [awardedAt] and [generateId].
///
/// ## Every crossed tier, not just the highest
///
/// A tiered badge yields one award per tier **up to and including** the one
/// reached, so a user who logs a year of history at once, or who crosses
/// two rungs between two runs of the detector, ends up with the complete
/// ladder rather than a Gold with no Bronze under it. The trophy case shows
/// a ladder; a ladder with rungs missing looks like a bug, and a user who
/// never sees their Bronze has effectively had it taken from them.
///
/// The consequence is worth naming for whoever wires the celebration: the
/// **first** detector run on an established install can return a large
/// list. That is correct — they did earn them — but presentation should
/// decide how to show twenty awards at once rather than firing twenty
/// celebrations.
///
/// ## Ordering
///
/// Catalogue order, and within a badge lowest tier first, so a caller that
/// simply walks the list celebrates Bronze before Silver.
///
/// [awardedAt] is normalised to UTC, matching every other timestamp this
/// app persists.
List<BadgeAward> newlyEarnedAwards({
  required List<BadgeProgress> progress,
  required List<BadgeAward> existingAwards,
  required DateTime awardedAt,
  required String Function() generateId,
}) {
  final held = <(String, String)>{
    for (final award in existingAwards) award.identity,
  };
  final stamp = awardedAt.toUtc();
  final fresh = <BadgeAward>[];

  for (final badge in progress) {
    final badgeId = badge.definition.id;

    if (badge.earnedTier == null) {
      // Either a one-off, or a tiered badge with nothing earned yet. Only
      // the former can produce an award, and only when it is earned.
      if (!badge.isEarned) continue;
      final identity = (badgeId, oneOffAwardTierKey);
      if (!held.add(identity)) continue;
      fresh.add(
        BadgeAward(id: generateId(), badgeId: badgeId, awardedAt: stamp),
      );
      continue;
    }

    for (final tier in badge.earnedTiers) {
      final identity = (badgeId, awardTierKey(tier));
      if (!held.add(identity)) continue;
      fresh.add(
        BadgeAward(
          id: generateId(),
          badgeId: badgeId,
          awardedAt: stamp,
          tier: tier,
        ),
      );
    }
  }

  return fresh;
}
