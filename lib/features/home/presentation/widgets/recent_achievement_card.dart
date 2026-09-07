import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/achievements_widgets.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/home/domain/home_recent_award.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_card.dart';

/// The last badge the user earned, named on the home dashboard.
///
/// Reads `badgeAwardsProvider` — the persisted awards alone — and
/// deliberately **not** `badgeDisplayProgress`: that walks the user's
/// entire history of activities, check-ins and water days to work out what
/// the data currently earns, which is a price the trophy case pays because
/// it is showing the whole case. This card names one badge the user has
/// already been given, and an award is the one part of achievements
/// that is stored precisely because it cannot be recomputed
/// (`achievements_providers.dart`).
///
/// An award whose badge has left the catalogue is treated as no award: there
/// would be no title to name it with. Same rule as `earnedBadgeCount`.
class RecentAchievementCard extends ConsumerWidget {
  const RecentAchievementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awards = ref.watch(badgeAwardsProvider).value ?? const <BadgeAward>[];
    final award = mostRecentAward(
      awards.where((award) => badgeDefinitionFor(award.badgeId) != null),
    );
    final definition = award == null ? null : badgeDefinitionFor(award.badgeId);

    return HomeCard(
      icon: Icons.emoji_events_outlined,
      title: 'Recent achievement',
      onTap: () => unawaited(const AchievementsRouteData().push<void>(context)),
      semanticsLabel: definition == null
          ? 'No badges yet, see what is on offer'
          : 'Most recent badge, ${definition.title}. Open achievements',
      child: award == null || definition == null
          ? const _NoBadgesYet()
          : _AwardSummary(award: award, definition: definition),
    );
  }
}

class _AwardSummary extends StatelessWidget {
  const _AwardSummary({required this.award, required this.definition});

  final BadgeAward award;
  final BadgeDefinition definition;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // The tier's name in words beside the crest, never the crest alone —
    // a colour and a shape are not something every user can read
    // (`presentation/widgets/badge_emblem.dart`).
    final tierLabel = award.tier?.label ?? 'Earned';
    final awardedOn = DateFormat.yMMMd().format(award.awardedAt.toLocal());

    return Row(
      children: [
        BadgeEmblem(
          kind: definition.kind,
          tier: award.tier,
          isEarned: true,
          size: 40,
        ),
        SizedBox(width: tokens.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                definition.title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$tierLabel · $awardedOn',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoBadgesYet extends StatelessWidget {
  const _NoBadgesYet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No badges yet',
          style: textTheme.bodyMedium,
        ),
        Text(
          "See what's on offer",
          style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }
}
