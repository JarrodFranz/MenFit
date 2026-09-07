/// Picking the one badge the home dashboard names.
///
/// Pure Dart, no Flutter. Its own function rather than `awards.first`
/// because the card must not depend on a repository ordering it doesn't
/// control: `badgeAwardsProvider` documents newest-first today, and a
/// dashboard that silently starts naming the oldest badge if that ever
/// changes is exactly the kind of quiet wrong this codebase keeps finding.
library;

import 'package:menfit_app/features/achievements/domain/badge_award.dart';

/// The most recently awarded badge, or `null` when none have been earned.
///
/// Ties (two rungs of the same badge crossed in the same moment, which the
/// detector does record together) resolve to the **higher tier**: reaching
/// Gold through Silver in one go is a Gold, and naming the Silver would
/// undersell what just happened. A one-off has no tier and loses a tie to a
/// tiered award at the same instant, which is the same reasoning - the
/// tiered one carries the rung.
BadgeAward? mostRecentAward(Iterable<BadgeAward> awards) {
  BadgeAward? best;
  for (final award in awards) {
    if (best == null) {
      best = award;
      continue;
    }
    if (award.awardedAt.isAfter(best.awardedAt)) {
      best = award;
      continue;
    }
    if (award.awardedAt == best.awardedAt) {
      final tier = award.tier;
      final bestTier = best.tier;
      if (tier != null && (bestTier == null || tier > bestTier)) {
        best = award;
      }
    }
  }
  return best;
}
