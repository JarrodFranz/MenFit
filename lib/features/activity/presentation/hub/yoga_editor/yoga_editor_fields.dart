import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';

/// Gaps offered as one tap. Anything else is a preference we have never been
/// asked for; the domain still accepts 0–60 (`maxTransitionSeconds`).
const List<int> kTransitionPresetSeconds = [0, 3, 5, 10];

/// Optional style for a sequence, from the single source of truth
/// (`MindfulStyles.yogaStyles`). Tapping the selected chip clears it — a
/// sequence with no style is a normal sequence, not an unfinished one.
class YogaStylePicker extends StatelessWidget {
  const YogaStylePicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Style (optional)', style: theme.textTheme.labelLarge),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            for (final style in MindfulStyles.yogaStyles)
              ChoiceChip(
                key: ValueKey('yogaEditorStyle_$style'),
                label: Text(style),
                selected: selected == style,
                onSelected: (isSelected) =>
                    onChanged(isSelected ? style : null),
              ),
          ],
        ),
      ],
    );
  }
}

/// The gap held between two consecutive poses, with the current value shown
/// beside the label so the chips are never the only place it is readable.
class YogaTransitionPicker extends StatelessWidget {
  const YogaTransitionPicker({
    required this.seconds,
    required this.onChanged,
    super.key,
  });

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Transition between poses',
                style: theme.textTheme.labelLarge,
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Text(
              '${seconds}s',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            for (final preset in kTransitionPresetSeconds)
              ChoiceChip(
                key: ValueKey('yogaEditorTransition_$preset'),
                label: Text(preset == 0 ? 'None' : '${preset}s'),
                selected: seconds == preset,
                onSelected: (_) => onChanged(preset),
              ),
          ],
        ),
      ],
    );
  }
}
