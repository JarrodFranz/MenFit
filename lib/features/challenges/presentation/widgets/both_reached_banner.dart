import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// The one outcome this feature celebrates: both people reached their own
/// goals.
///
/// There is no counterpart banner for "one of you did", and there never
/// will be — a card that fires when exactly one person finished is a card
/// whose meaning is "and the other did not". Each participant's own
/// arrival is said quietly on their own row instead
/// (`challenges_copy.dart#selfReachedLine` / `#buddyReachedLine`).
class BothReachedBanner extends StatelessWidget {
  const BothReachedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('bothReachedBanner'),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingSm,
        vertical: tokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 18,
            color: colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: tokens.spacingXs),
          Flexible(
            child: Text(
              bothReachedTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
