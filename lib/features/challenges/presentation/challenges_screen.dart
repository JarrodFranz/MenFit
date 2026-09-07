import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_card.dart';

/// Every challenge on this device: the ones still running, and the ones
/// that have finished.
///
/// Reached at `/challenges` from the Progress screen's Buddy challenges
/// card.
///
/// ## The split is derived, never stored
///
/// "Active" and "finished" come from the window against
/// `challengesTodayProvider`, not from a flag on the row — a challenge
/// does not change when it ends, the calendar moves
/// (`challenges_providers.dart`).
///
/// ## Finished challenges are kept and de-emphasised, not hidden
///
/// A finished challenge is something they did, and the mutual celebration
/// lives on it. It sits in a collapsed section rather than on the main
/// list so that "what am I doing now" is the first thing the screen
/// answers.
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    final activeAsync = ref.watch(activeChallengesProvider);
    final archivedAsync = ref.watch(archivedChallengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(challengesScreenTitle)),
      body: SafeArea(
        // Pinned to the top: a Center around a shrink-wrapping scroll view
        // floats short content mid-screen (seen on device 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _EntryActions(),
                  SizedBox(height: tokens.spacingLg),
                  activeAsync.when(
                    data: (active) => _ActiveSection(challenges: active),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _SectionError(
                      message: userMessageFor(error),
                    ),
                  ),
                  SizedBox(height: tokens.spacingLg),
                  archivedAsync.when(
                    data: (archived) => _FinishedSection(challenges: archived),
                    loading: SizedBox.shrink,
                    error: (error, _) => _SectionError(
                      message: userMessageFor(error),
                    ),
                  ),
                  SizedBox(height: tokens.spacingLg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryActions extends StatelessWidget {
  const _EntryActions();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: [
        FilledButton.icon(
          key: const Key('challengesCreateButton'),
          onPressed: () => unawaited(
            const CreateChallengeRouteData().push<void>(context),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(startChallengeLabel),
        ),
        OutlinedButton.icon(
          key: const Key('challengesJoinButton'),
          onPressed: () => unawaited(
            const JoinChallengeRouteData().push<void>(context),
          ),
          icon: const Icon(Icons.content_paste_rounded, size: 18),
          label: const Text(joinChallengeLabel),
        ),
      ],
    );
  }
}

class _ActiveSection extends StatelessWidget {
  const _ActiveSection({required this.challenges});

  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    if (challenges.isEmpty) {
      return Text(
        challengesEmptyLine,
        key: const Key('challengesEmptyLine'),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          activeChallengesHeading,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        for (final challenge in challenges)
          ChallengeCard(key: ValueKey(challenge.id), challenge: challenge),
      ],
    );
  }
}

class _FinishedSection extends StatelessWidget {
  const _FinishedSection({required this.challenges});

  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return ExpansionTile(
      key: const Key('finishedChallengesSection'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        finishedChallengesHeading,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      children: [
        for (final challenge in challenges)
          ChallengeCard(key: ValueKey(challenge.id), challenge: challenge),
      ],
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
