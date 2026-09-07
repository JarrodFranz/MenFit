import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/application/challenge_code_service.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// Takes the buddy's pasted progress code and applies it.
///
/// Every one of the five outcomes gets a sentence, and only two of them
/// are problems:
///
/// * **Imported** — closes, and the screen behind says whose figure moved.
/// * **Not newer** — a gentle "you already have this one", styled as
///   information rather than as an error. Codes travel through chat
///   threads, so pasting Monday's on Friday is an ordinary thing to do,
///   and the stored snapshot deliberately refuses to go backwards
///   (`application/challenge_code_service.dart#importProgressCode`).
///   Re-pasting the identical code is idempotent for the same reason.
/// * **Your own code** — also information rather than an error, and the
///   sentence says what to do with it instead. Two codes for the same
///   challenge sit next to each other in the same chat thread; pasting
///   the wrong one is an ordinary slip, and letting it through would
///   overwrite the buddy's figure with the user's own.
/// * **Unknown challenge** — the code is fine and belongs elsewhere.
/// * **Unusable** — one of the five typed rejections, in words
///   (`challenges_copy.dart#progressCodeRejectionMessage`).
class BuddyCodeDialog extends ConsumerStatefulWidget {
  const BuddyCodeDialog({super.key});

  /// Resolves to the buddy's display name when a code was applied, and to
  /// `null` when nothing changed.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const BuddyCodeDialog(),
    );
  }

  @override
  ConsumerState<BuddyCodeDialog> createState() => _BuddyCodeDialogState();
}

class _BuddyCodeDialogState extends ConsumerState<BuddyCodeDialog> {
  final TextEditingController _controller = TextEditingController();

  String? _message;
  bool _messageIsProblem = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final navigator = Navigator.of(context);
    setState(() {
      _message = null;
      _isSubmitting = true;
    });

    ImportProgressResult result;
    try {
      result = await ref
          .read(challengeCodeServiceProvider)
          .importProgressCode(_controller.text.trim());
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _message = userMessageFor(error);
        _messageIsProblem = true;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case BuddyProgressImported(:final challenge):
        navigator.pop(challenge.buddy?.displayName);
      case BuddyProgressNotNewer():
        setState(() {
          _message = buddyNotNewerMessage;
          _messageIsProblem = false;
        });
      case BuddyProgressIsYourOwn():
        setState(() {
          _message = buddyOwnCodeMessage;
          // Information, not an error: she pasted one of two very similar
          // strings, and the sentence tells her which one to send instead.
          _messageIsProblem = false;
        });
      case BuddyProgressUnknownChallenge():
        setState(() {
          _message = buddyUnknownChallengeMessage;
          _messageIsProblem = true;
        });
      case BuddyProgressUnusable(:final reason):
        setState(() {
          _message = progressCodeRejectionMessage(reason);
          _messageIsProblem = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return AlertDialog(
      title: const Text(pasteBuddyCodeLabel),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('buddyCodeField'),
              controller: _controller,
              autofocus: true,
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: buddyCodeFieldLabel,
                helperText: buddyCodeHelper,
              ),
            ),
            if (_message case final message?) ...[
              SizedBox(height: tokens.spacingSm),
              Text(
                message,
                key: const Key('buddyCodeFeedback'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _messageIsProblem
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('buddyCodeSubmitButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(importBuddyCodeLabel),
        ),
      ],
    );
  }
}
