import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_code_panel.dart';

/// The sheet that hands over a progress code.
///
/// The **only** surface in this feature where something derived from her
/// own data leaves the device, which is why
/// [progressCodePrivacyNote] is on it and not tucked into a settings page:
/// the moment to say what a code contains is the moment before she sends
/// one.
///
/// The code itself is built by
/// `application/challenge_code_service.dart#progressCodeFor`, which is
/// handed a percentage, a name and a date and has no parameter that could
/// carry anything else — the sheet cannot widen what it shows because it
/// is never given more (`domain/challenge_codes.dart`'s privacy
/// invariant).
class ProgressCodeSheet extends StatelessWidget {
  const ProgressCodeSheet({required this.code, super.key});

  final String code;

  static Future<void> show(BuildContext context, {required String code}) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProgressCodeSheet(code: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    // Bottom inset comes from `showAppBottomSheet`; no `SafeArea` here.
    return Padding(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            progressCodeTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          Text(progressCodeLine, style: theme.textTheme.bodyMedium),
          SizedBox(height: tokens.spacingMd),
          ChallengeCodePanel(
            code: code,
            copyButtonKey: const Key('progressCodeCopyButton'),
          ),
          SizedBox(height: tokens.spacingMd),
          Text(
            progressCodePrivacyNote,
            key: const Key('progressCodePrivacyNote'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(doneLabel),
          ),
        ],
      ),
    );
  }
}
