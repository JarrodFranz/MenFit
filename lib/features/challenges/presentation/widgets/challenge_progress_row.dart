import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// One participant's standing: her label, her percentage, and a bar.
///
/// Used for both people, and deliberately identical for both — a
/// different treatment for "you" and "her" is the first step towards a
/// scoreboard, and the domain layer has no way to say who is ahead
/// anyway (`domain/challenge_progress.dart`).
///
/// The bar's fill is clamped to its own track while the **number is
/// not**: 112% renders as a full bar reading "112%". Clamping the label
/// too would quietly delete the best part of going past your own goal.
///
/// Accessibility: the sentence goes in [semanticsLabel], which is handed
/// to [LinearProgressIndicator.semanticsLabel]; `semanticsValue` is left
/// to the framework, which validates it as a number or percentage and
/// throws on a sentence (see the same note on
/// `features/achievements/presentation/achievements_copy.dart#progressSemanticsLabel`).
class ChallengeProgressRow extends StatelessWidget {
  const ChallengeProgressRow({
    required this.label,
    required this.percentLabel,
    required this.percent,
    required this.semanticsLabel,
    required this.color,
    this.note,
    super.key,
  });

  /// "You", or the buddy's chosen display name.
  final String label;

  /// The already-formatted percentage, e.g. `'112%'`.
  final String percentLabel;

  /// The raw percentage, used only to size the bar.
  final double percent;

  final String semanticsLabel;

  final Color color;

  /// A quiet trailing line — "as of 12 Sep" under the buddy's bar, or
  /// "42.3 km so far" under the user's own.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Text(
              percentLabel,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          child: LinearProgressIndicator(
            value: _barValue,
            minHeight: 8,
            color: color,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            semanticsLabel: semanticsLabel,
          ),
        ),
        if (note case final note?) ...[
          SizedBox(height: tokens.spacingXs),
          Text(
            note,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  double get _barValue {
    if (!percent.isFinite) return 0;
    return (percent / 100).clamp(0.0, 1.0);
  }
}
