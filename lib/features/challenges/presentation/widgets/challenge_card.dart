import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/presentation/challenge_view_providers.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/both_reached_banner.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_progress_row.dart';

/// One challenge in the list: what it asks, when it runs, how they are
/// getting on, and — if a code has been pasted — how their buddy is.
///
/// ## One bar, and the buddy as a sentence
///
/// Their own progress gets the bar. The buddy's figure is a line of text
/// (`challenges_copy.dart#buddyCardLine`), and the asymmetry is the point:
/// two bars stacked two spacings apart are a comparison whether or not
/// anything says so. A reader does not read "48%" and "30%" there, they
/// read which one is longer — and the two lengths mean nothing against
/// each other, because each percentage is measured against a target only
/// its owner knows (`domain/challenge_progress_engine.dart`). The domain
/// layer cannot express a leader (`domain/challenge_progress.dart`); a
/// second bar would let the layout express one anyway.
///
/// The detail screen still draws both bars, and that is deliberate: it is
/// a screen they open on purpose, the fairness note sits between the two,
/// and there is room there for the sentence that explains what the second
/// number is. A list card is glanced at, and a caption on a glance is a
/// caption nobody reads.
class ChallengeCard extends ConsumerWidget {
  const ChallengeCard({required this.challenge, super.key});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final progress = ref.watch(selfProgressProvider(challenge.id)).value;
    final pair = challengePairOf(challenge, progress);
    final blueprint = challenge.blueprint;

    return Card(
      key: Key('challengeCard_${challenge.id}'),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        onTap: () => unawaited(
          ChallengeDetailRouteData(challenge.id).push<void>(context),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      challengeTargetLine(blueprint),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              Text(
                '${challengeActivityLine(blueprint.activityTypes)} · '
                '${challengeWindowLine(
                  blueprint.windowStart,
                  blueprint.windowEnd,
                )}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              if (pair == null)
                const _ProgressPlaceholder()
              else ...[
                ChallengeProgressRow(
                  label: selfLabel,
                  percentLabel: formatPercent(pair.self.progressPercent),
                  percent: pair.self.progressPercent,
                  semanticsLabel: selfProgressSemanticsLabel(
                    pair.self.progressPercent,
                  ),
                  color: colorScheme.primary,
                ),
                if (pair.buddy case final BuddyParticipant buddy) ...[
                  SizedBox(height: tokens.spacingSm),
                  Text(
                    buddyCardLine(
                      buddy.displayName,
                      buddy.progressPercent,
                      buddy.asOf,
                    ),
                    key: const Key('challengeCardBuddyLine'),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (pair.bothReachedGoal) ...[
                  SizedBox(height: tokens.spacingSm),
                  const BothReachedBanner(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown while their own progress is still being computed.
///
/// A blank space rather than a bar at zero: a bar at zero is a claim
/// about what they have done, and "not counted yet" is not "nothing".
class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
    );
  }
}
