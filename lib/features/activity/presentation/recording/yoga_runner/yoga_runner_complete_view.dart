import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';

/// The end of the sequence: what she practised, and the one button that
/// saves it.
///
/// Nothing is written until she presses Save — a practice that saved itself
/// the instant the last pose ran out would record sessions she walked away
/// from mid-way through.
class YogaRunnerCompleteView extends StatelessWidget {
  const YogaRunnerCompleteView({
    required this.state,
    required this.onSave,
    required this.onPractiseAgain,
    this.saving = false,
    super.key,
  });

  final YogaRunnerState state;
  final VoidCallback onSave;

  /// True while the write is in flight. Both buttons go dead for it: a
  /// second tap on Save would write the practice twice under two ids, and
  /// stepping back into the last pose mid-save would save a practice that
  /// is no longer over.
  final bool saving;

  /// Steps back into the last pose, for when the chime landed early.
  final VoidCallback onPractiseAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final scheme = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingLg),
      children: [
        SizedBox(height: tokens.spacingLg),
        Icon(
          Icons.self_improvement,
          size: 72,
          color: scheme.primary,
        ),
        SizedBox(height: tokens.spacingMd),
        Semantics(
          liveRegion: true,
          child: Text(
            'Sequence complete',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: tokens.spacingMd),
        Container(
          padding: EdgeInsets.all(tokens.spacingLg),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
          child: Column(
            children: [
              Text(
                formatDuration(state.practisedTime),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              Text(
                'practised',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                '${formatDuration(state.elapsedTime)} elapsed · '
                '${state.poseCount} poses',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        FilledButton.icon(
          key: const Key('yogaRunnerSaveButton'),
          onPressed: saving ? null : onSave,
          icon: const Icon(Icons.check),
          label: Text(saving ? 'Saving…' : 'Save practice'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        TextButton(
          onPressed: saving ? null : onPractiseAgain,
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Back to the last pose'),
        ),
      ],
    );
  }
}
