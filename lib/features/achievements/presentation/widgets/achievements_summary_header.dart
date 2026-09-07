import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/badge_display.dart';

/// The trophy case's header: what they hold, and the highest rung they have
/// reached.
///
/// Deliberately **not** "7 of 23 badges (30%)". A completion percentage
/// turns a case of things they are proud of into a list of things they have
/// not done yet, and the one number that would grow fastest is the number
/// of badges *missing* — which is a number this screen has no business
/// showing. Counting up, never counting down.
///
/// [progress] is expected to be the merged list from
/// `presentation/badge_display.dart`, which is what the case renders — so
/// the count here and the count on the Progress card are the same number,
/// computed by the same [earnedBadgeCount].
class AchievementsSummaryHeader extends StatelessWidget {
  const AchievementsSummaryHeader({required this.progress, super.key});

  final List<BadgeProgress> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;

    final earnedCount = earnedBadgeCount(progress: progress);
    final highestTier = highestEarnedTier(progress);

    return Card(
      key: const Key('achievementsSummaryHeader'),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                SizedBox(width: tokens.spacingSm),
                Text(
                  trophyCaseTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              earnedCountLine(earnedCount),
              style: earnedCount == 0
                  ? theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    )
                  : theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
            ),
            if (highestTier != null) ...[
              SizedBox(height: tokens.spacingXs),
              Text(
                highestTierLine(highestTier),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (earnedCount > 0) ...[
              SizedBox(height: tokens.spacingXs),
              Text(
                trophyCaseInviteLine,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The highest tier held across [progress], or `null` when no tiered badge
/// has been reached yet (one-offs have no tier and so never answer this).
BadgeTier? highestEarnedTier(List<BadgeProgress> progress) {
  BadgeTier? highest;
  for (final badge in progress) {
    final tier = badge.earnedTier;
    if (tier == null) continue;
    if (highest == null || tier > highest) highest = tier;
  }
  return highest;
}
