import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/sharing/share_feedback.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/share_capture.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// Identifies the opaque code string itself, as opposed to the copy around
/// it. Named rather than inline so the tests that must skip it and the
/// widget that renders it cannot drift apart.
const Key challengeCodeTextKey = Key('challengeCodeText');

/// A code, big enough to read aloud and selectable enough to copy by
/// hand, with Share and Copy beside it.
///
/// [SelectableText] rather than [Text] on purpose: the buttons cover the
/// common case, but a code is also something people photograph, read out
/// over the phone, or drag half of into a message, and a non-selectable
/// string forecloses all three.
///
/// Both buttons are offered and neither is a fallback for the other: the
/// OS share sheet (ADR 011) is the fast path on a phone, and the
/// clipboard is the one that always works - Windows share fails on some
/// editions and desktop Firefox has no Web Share API. The text handed to
/// the share sheet is the code and nothing else, byte-identical to what
/// Copy writes, so the byte-level privacy argument in
/// `domain/challenge_codes.dart` covers both paths at once.
class ChallengeCodePanel extends ConsumerWidget {
  const ChallengeCodePanel({
    required this.code,
    this.copyButtonKey,
    super.key,
  });

  final String code;

  final Key? copyButtonKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacingMd),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          child: SelectableText(
            code,
            // The one string on any challenge surface that is not copy:
            // base64url of a binary payload. The widget-level vocabulary
            // sweeps skip it by this key, because a random 58-character
            // body contains "pms" or "bmi" about once in a few hundred
            // codes and a flaky privacy gate is a privacy gate that gets
            // deleted. Every label around it is still swept.
            key: challengeCodeTextKey,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        // The Builder is what gives `sharePositionOrigin` the button's own
        // rect, which is what the iPad popover anchors to.
        Builder(
          builder: (buttonContext) => FilledButton.tonalIcon(
            onPressed: () => _share(buttonContext, ref),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text(shareCodeLabel),
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        FilledButton.tonalIcon(
          key: copyButtonKey,
          onPressed: () => _copy(context),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text(copyCodeLabel),
        ),
      ],
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(sharingAdapterProvider)
        .shareText(code, sharePositionOrigin: shareOriginOf(context));
    final message = shareOutcomeMessage(outcome);
    if (message == null) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: code));
    messenger.showSnackBar(
      const SnackBar(content: Text(codeCopiedMessage)),
    );
  }
}
