import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// The way out of one challenge.
///
/// Settings' "Delete my data" takes everything at once; this takes one
/// thing, which is the half of `knowledge/engineering/security_and_privacy.md`'s
/// rules 7 and 8 that a whole-account wipe does not satisfy — a woman who
/// wants a particular person's name off her phone should not have to
/// choose between keeping it and deleting her training history.
///
/// **Hard delete, with a confirm.** There is no `deleted_at` column to
/// hide the row behind (`core/db/tables/challenges.dart`), so leaving
/// removes the buddy's chosen name along with the challenge, on this
/// device only. The dialog says both of those things and states **no
/// numbers**: a confirm dialog is not a place to restate a target or a
/// percentage, least of all on the way out.
class LeaveChallengeButton extends ConsumerWidget {
  const LeaveChallengeButton({required this.challengeId, super.key});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: const Key('leaveChallengeButton'),
        onPressed: () => _confirmAndLeave(context, ref),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(leaveChallengeLabel),
        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
      ),
    );
  }

  Future<void> _confirmAndLeave(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('leaveChallengeDialog'),
        title: const Text(leaveChallengeTitle),
        content: const Text(leaveChallengeBody),
        actions: [
          TextButton(
            key: const Key('leaveChallengeCancelButton'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(leaveChallengeCancelLabel),
          ),
          FilledButton(
            key: const Key('leaveChallengeConfirmButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(leaveChallengeConfirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(challengeRepositoryProvider).deleteChallenge(challengeId);
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }

    // Popped before the message, so the message lands on the list she is
    // looking at rather than on a screen whose challenge no longer exists.
    if (navigator.canPop()) navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text(leftChallengeMessage)));
  }
}

/// What the detail screen shows when its challenge is no longer there.
///
/// Reachable two ways: she left it in another window, or "Delete my data"
/// ran while this screen was open. Either way a blank [Scaffold] is the
/// one answer that tells her nothing, so this says what happened and
/// offers the way back.
class ChallengeGoneMessage extends StatelessWidget {
  const ChallengeGoneMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final navigator = Navigator.of(context);

    return Center(
      key: const Key('challengeGoneMessage'),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              challengeGoneLine,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            if (navigator.canPop())
              FilledButton.tonal(
                key: const Key('challengeGoneBackButton'),
                onPressed: navigator.pop,
                child: const Text(challengeGoneBackLabel),
              ),
          ],
        ),
      ),
    );
  }
}
