import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';

/// The recovery-decision prompt (§5.9 of the product handover spec) —
/// offered after a check-in save reports significant symptoms
/// (`domain/recovery_prompt.dart#hasSignificantSymptoms`) and today isn't
/// already active or protected. Positively framed throughout: never
/// "excused/failed" (`knowledge/product/terminology.md`). F3: the copy is
/// deliberately honest about the actual consequence of each choice —
/// accepting protects the day; declining ("Keep training") leaves it
/// unprotected, same as any other day. An earlier version of this copy
/// claimed "your streak stays safe either way," which was simply false —
/// declining does not protect anything. Never repeat that claim here.
///
/// A plain, stateless prompt - the caller (`checkin_sheet.dart`) owns
/// deciding *whether* to show it and what happens after: [show] resolves
/// to `true` if the user chose "Make it a recovery day," `false` if they
/// chose "Keep training," and `null` if they dismissed it another way
/// (tapping the scrim). The caller treats every non-`true` outcome as a
/// dismissal for this session (see
/// `recovery_prompt_dismissal_controller.dart`) - a bare backdrop tap
/// shouldn't be treated as more eager to hear the prompt again than an
/// explicit "no thanks" would be.
class RecoveryPromptSheet extends StatelessWidget {
  const RecoveryPromptSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showAppBottomSheet<bool>(
      context: context,
      builder: (_) => const RecoveryPromptSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    // Keyboard/nav-bar padding is `showAppBottomSheet`'s job, not this
    // widget's.
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make today a recovery day?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                "You've logged some tough symptoms. A recovery day keeps "
                'your streak safe — no questions asked.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingLg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Make it a recovery day'),
                ),
              ),
              SizedBox(height: tokens.spacingSm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Keep training'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
