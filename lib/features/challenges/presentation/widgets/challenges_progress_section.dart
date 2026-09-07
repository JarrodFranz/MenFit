import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// The Progress screen's Buddy challenges card, and the way into
/// `/challenges`.
///
/// Mounted by `features/progress` through `challenges_widgets.dart`
/// (ADR 007's UI-composition amendment), the same shape as
/// `AchievementsProgressSection` and `WeightProgressSection`.
///
/// ## Why it counts and does not compute
///
/// It watches [activeChallengesProvider] — one small table read — and
/// deliberately never touches `selfProgressProvider`, which walks the
/// whole activity log per challenge. That walk is the right cost for a
/// screen opened on purpose; paying it once per challenge on every visit
/// to a dashboard the card merely sits on is not. Exactly the reasoning
/// `AchievementsProgressSection` records for reading awards rather than
/// progress.
///
/// Like the Weight and Achievements cards, it renders with nothing to
/// show: this is the only place the feature can be found from, and its
/// empty state is an invitation rather than a nag.
class ChallengesProgressSection extends ConsumerWidget {
  const ChallengesProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final active =
        ref.watch(activeChallengesProvider).value ?? const <Challenge>[];

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
                  challengesSectionTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.groups_2_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            if (active.isEmpty)
              Text(
                challengesEmptyLine,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Text(
                activeChallengeCountLine(active.length),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: tokens.spacingSm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const Key('challengesSectionOpenButton'),
                onPressed: () =>
                    unawaited(const ChallengesRouteData().push<void>(context)),
                icon: const Icon(Icons.groups_2_rounded, size: 18),
                label: const Text(challengesSectionOpenLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
