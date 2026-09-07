import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/badge_display.dart';

/// The Progress screen's Achievements card, and the way into the trophy
/// case at `/achievements`.
///
/// Mounted by `features/progress` through `achievements_widgets.dart`
/// (ADR 007's UI-composition amendment), the same shape as
/// `WeightProgressSection`, `RecapHistorySection` and
/// `InsightDiscoverySection`.
///
/// ## Why it reads awards and not progress
///
/// It deliberately watches only [badgeAwardsProvider] — a small
/// day-keyed table — and never [badgeProgressProvider], which walks the
/// user's entire activity, check-in, water and cycle history. That walk is
/// the right cost for a screen opened deliberately; paying it on every
/// visit to a dashboard the card merely sits on is not. So the card
/// celebrates what is already recorded, and the counting happens behind
/// the door.
///
/// The count itself is [earnedBadgeCount], the same function the trophy
/// case header uses — one definition of "in the case" (data-earned or
/// awarded), each surface passing what it knows. The card is therefore
/// behind the case only in the moments between a rung being crossed and
/// the detector recording it, which is exactly the "already recorded"
/// contract above and never a disagreement about a badge she holds.
///
/// Like the Weight card and unlike the insight and recap cards, it renders
/// with nothing earned: this is the only place the trophy case can be
/// found from, and its empty state is an invitation.
class AchievementsProgressSection extends ConsumerWidget {
  const AchievementsProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final awards = ref.watch(badgeAwardsProvider).value ?? const <BadgeAward>[];
    final earnedCount = earnedBadgeCount(awards: awards);
    final highestTier = _highestTier(awards);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  achievementsSectionTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.emoji_events_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              earnedCountLine(earnedCount),
              style: earnedCount == 0
                  ? textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    )
                  : textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
            ),
            if (highestTier != null) ...[
              SizedBox(height: tokens.spacingXs),
              Text(
                highestTierLine(highestTier),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: tokens.spacingSm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const Key('achievementsSectionOpenButton'),
                onPressed: () => unawaited(
                  const AchievementsRouteData().push<void>(context),
                ),
                icon: const Icon(Icons.emoji_events_rounded, size: 18),
                label: const Text(achievementsSectionOpenLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The highest rung across every award held, or `null` when only one-off
  /// badges (which have no tier) have been earned.
  BadgeTier? _highestTier(List<BadgeAward> awards) {
    BadgeTier? highest;
    for (final award in awards) {
      final tier = award.tier;
      if (tier == null) continue;
      if (highest == null || tier > highest) highest = tier;
    }
    return highest;
  }
}
