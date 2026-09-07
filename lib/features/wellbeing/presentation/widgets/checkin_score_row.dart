import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

const Map<String, String> _metricDefinitions = {
  'Energy':
      'Your overall physical and mental vitality and alertness level today.',
  'Sleep':
      'The restfulness, quality, and restorative depth of your sleep '
      'last night.',
  'Soreness':
      'Normal exercise-induced muscular fatigue, tightness, and DOMS (Delayed '
      'Onset Muscle Soreness) that gradually improves with rest and gentle '
      'movement.',
  'Pain':
      'Acute, sharp, throbbing, or localized joint/tendon discomfort indicating '
      'potential tissue overload or injury risk. Unlike standard training '
      'soreness, pain does not improve with simply pushing through.',
  'Stress':
      'Mental, emotional, and lifestyle pressure or cognitive tension you '
      'are experiencing today.',
};

/// A label plus six tap-to-select score segments (0-5), used by
/// `../checkin_sheet.dart` for each of its five score fields. Tapping the
/// already-selected value clears it back to `null`.
///
/// Includes an informational ('i') button next to each metric label
/// providing clinically grounded definitions (e.g. Soreness vs. Pain).
class CheckinScoreRow extends StatelessWidget {
  const CheckinScoreRow({
    required this.label,
    required this.value,
    required this.errorText,
    required this.onSelect,
    super.key,
  });

  final String label;
  final int? value;
  final String? errorText;
  final ValueChanged<int> onSelect;

  void _showInfoDialog(BuildContext context) {
    final definition =
        _metricDefinitions[label] ??
        'Record your $label level on a scale from 0 to 5.';
    final isSorenessOrPain = label == 'Soreness' || label == 'Pain';

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text('$label Definition'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (isSorenessOrPain) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Clinical difference: Soreness is expected muscle '
                    'fatigue that naturally subsides with rest. Pain '
                    'indicates potential tissue distress or injury that '
                    'warrants listening to your body.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              tooltip: '$label definition',
              onPressed: () => _showInfoDialog(context),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingXs),
        Row(
          children: [
            for (var score = 0; score <= 5; score++) ...[
              if (score > 0) SizedBox(width: tokens.spacingXs),
              Expanded(
                child: _ScoreSegment(
                  fieldLabel: label,
                  score: score,
                  selected: value == score,
                  onTap: () => onSelect(score),
                ),
              ),
            ],
          ],
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacingXs),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _ScoreSegment extends StatelessWidget {
  const _ScoreSegment({
    required this.fieldLabel,
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final String fieldLabel;
  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$fieldLabel score $score',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
          child: Text(
            '$score',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
