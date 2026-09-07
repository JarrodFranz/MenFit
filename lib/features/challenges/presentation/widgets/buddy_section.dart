import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/buddy_code_dialog.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_progress_row.dart';

/// The buddy half of the detail screen: their last pasted figure, or the
/// invitation to paste one.
///
/// Having no buddy snapshot is a completely normal, permanently-fine
/// state — two people can run a challenge together and never exchange a
/// single progress code — so the empty state says what would happen if
/// they pasted one and then stops talking.
class BuddySection extends StatelessWidget {
  const BuddySection({required this.buddy, super.key});

  final BuddyParticipant? buddy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final participant = buddy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          buddySectionHeading,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        if (participant == null)
          Text(
            buddyEmptyLine,
            key: const Key('buddyEmptyLine'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          ChallengeProgressRow(
            label: participant.displayName,
            percentLabel: formatPercent(participant.progressPercent),
            percent: participant.progressPercent,
            semanticsLabel: buddyProgressSemanticsLabel(
              participant.displayName,
              participant.progressPercent,
            ),
            color: theme.colorScheme.tertiary,
            note: buddyAsOfLine(participant.asOf),
          ),
          if (participant.reachedGoal) ...[
            SizedBox(height: tokens.spacingXs),
            Text(
              buddyReachedLine(participant.displayName),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
        SizedBox(height: tokens.spacingSm),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('pasteBuddyCodeButton'),
            onPressed: () => _paste(context),
            icon: const Icon(Icons.content_paste_rounded, size: 18),
            label: const Text(pasteBuddyCodeLabel),
          ),
        ),
      ],
    );
  }

  Future<void> _paste(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final displayName = await BuddyCodeDialog.show(context);
    if (displayName == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(buddyImportedMessage(displayName))),
    );
  }
}
