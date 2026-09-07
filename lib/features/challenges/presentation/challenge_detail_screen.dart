import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/presentation/challenge_view_providers.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/both_reached_banner.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/buddy_section.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_celebration_sheet.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_progress_row.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/leave_challenge_button.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/progress_code_sheet.dart';

/// One challenge in full: what it asks, where she is in it, where her
/// buddy was when she last said, and the two codes that carry those two
/// facts between phones.
///
/// Reached at `/challenges/:challengeId`.
///
/// ## What this screen shows about her, and what it does not
///
/// It shows her percentage against her own target. It does **not** show
/// her adjusted target, it does not show how many of her days were
/// protected, and — since 2026-09-02 — it does not show her raw work
/// either. All three are in `ChallengeSelfProgress` and all three stay
/// there.
///
/// The third one used to be here, described as an accepted residual.
/// **That residual is closed, and this paragraph replaces the note that
/// accepted it.** Raw work alone says nothing; raw work *beside* her
/// percentage, the shared target and the window is four numbers from
/// which her protected-day count follows exactly:
///
/// ```text
/// protectedDays = windowDays − round(windowDays × (raw ÷ percent) ÷ target)
/// ```
///
/// 42.3 km at 50% of a 100 km target over 30 days resolves to five
/// protected days and nothing else — a screenshot of this screen, sent to
/// the one person best placed to read it, would have said when her period
/// was. Her raw distance still lives in her activity history, where it is
/// one number on a screen that says nothing about a challenge.
///
/// The rule is now mechanical rather than a matter of care on this screen:
/// `test/features/challenges/challenge_surfaces_privacy_test.dart` renders
/// every challenge surface with a protected-days fixture and fails if any
/// one of them puts raw work and an adjusted percentage alongside the
/// nominal target and the window. What is guaranteed *structurally*, by
/// the encoder's signature, is the other half — that the code she sends
/// carries the percentage alone (`domain/challenge_codes.dart`).
class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({required this.challengeId, super.key});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final challengeAsync = ref.watch(challengeDetailProvider(challengeId));

    return Scaffold(
      appBar: AppBar(title: const Text(challengeDetailTitle)),
      body: SafeArea(
        // Pinned to the top like the other challenge screens; Center floated
        // the body mid-screen (seen on device 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: challengeAsync.when(
              data: (challenge) => challenge == null
                  ? const ChallengeGoneMessage()
                  : _DetailBody(challenge: challenge),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Padding(
                padding: EdgeInsets.all(tokens.spacingMd),
                child: Center(child: Text(userMessageFor(error))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final blueprint = challenge.blueprint;

    final progress = ref.watch(selfProgressProvider(challenge.id)).value;
    final pair = challengePairOf(challenge, progress);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            challengeTargetLine(blueprint),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            '${challengeActivityLine(blueprint.activityTypes)} · '
            '${challengeWindowLine(
              blueprint.windowStart,
              blueprint.windowEnd,
            )}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            originLine(challenge.origin),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingLg),
          if (pair != null) ...[
            ChallengeProgressRow(
              label: selfLabel,
              percentLabel: formatPercent(pair.self.progressPercent),
              percent: pair.self.progressPercent,
              semanticsLabel: selfProgressSemanticsLabel(
                pair.self.progressPercent,
              ),
              color: theme.colorScheme.primary,
            ),
            if (pair.self.reachedGoal) ...[
              SizedBox(height: tokens.spacingXs),
              Text(
                selfReachedLine,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: tokens.spacingMd),
            const _FairnessNote(),
            SizedBox(height: tokens.spacingMd),
            FilledButton.tonalIcon(
              key: const Key('shareProgressButton'),
              onPressed: () => _shareProgress(context, ref, pair.self),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: const Text(shareProgressLabel),
            ),
          ],
          SizedBox(height: tokens.spacingLg),
          const Divider(),
          SizedBox(height: tokens.spacingSm),
          BuddySection(buddy: pair?.buddy ?? _buddyOf(challenge)),
          if (pair != null && pair.bothReachedGoal) ...[
            SizedBox(height: tokens.spacingLg),
            const BothReachedBanner(),
            SizedBox(height: tokens.spacingXs),
            Text(bothReachedLine, style: theme.textTheme.bodyMedium),
            SizedBox(height: tokens.spacingSm),
            FilledButton.icon(
              key: const Key('openCelebrationCardButton'),
              onPressed: () => ChallengeCelebrationSheet.show(
                context,
                blueprint: blueprint,
                selfDisplayName: challenge.selfDisplayName,
                buddyDisplayName: pair.buddy!.displayName,
              ),
              icon: const Icon(Icons.celebration_rounded, size: 18),
              label: const Text(celebrationOpenLabel),
            ),
          ],
          SizedBox(height: tokens.spacingLg),
          const Divider(),
          LeaveChallengeButton(challengeId: challenge.id),
          SizedBox(height: tokens.spacingXl),
        ],
      ),
    );
  }

  /// The buddy participant when her own progress has not resolved yet —
  /// what the buddy sent does not depend on what the user has done, so it
  /// should not wait on it.
  BuddyParticipant? _buddyOf(Challenge challenge) {
    final snapshot = challenge.buddy;
    return snapshot == null ? null : BuddyParticipant(snapshot);
  }

  Future<void> _shareProgress(
    BuildContext context,
    WidgetRef ref,
    SelfParticipant self,
  ) {
    final code = ref
        .read(challengeCodeServiceProvider)
        .progressCodeFor(
          challenge,
          progressPercent: self.progressPercent,
          asOf: ref.read(challengesTodayProvider),
        );
    return ProgressCodeSheet.show(context, code: code);
  }
}

/// The one place the pro-rating is acknowledged, in words and never in
/// numbers — see `challenges_copy.dart#fairnessNote`.
class _FairnessNote extends StatelessWidget {
  const _FairnessNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Container(
      key: const Key('challengeFairnessNote'),
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: tokens.spacingXs),
          Expanded(
            child: Text(
              fairnessNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
