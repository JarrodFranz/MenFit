import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// One figure in the day's summary: a label, the value, and an optional
/// second line (a target, or a note about how complete the value is).
///
/// Every summary figure uses this one widget at the same size and weight.
/// That is the mechanism behind "protein and iron get equal billing"
/// (`knowledge/domain/nutrition.md`): the two adequacy indicators sit in the
/// same row, in identical tiles, so neither can be quietly demoted by a
/// style change to the other.
class NutritionStatTile extends StatelessWidget {
  const NutritionStatTile({
    required this.label,
    required this.value,
    this.note,
    super.key,
  });

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingXs),
          Text(value, style: textTheme.titleMedium),
          if (note != null) ...[
            SizedBox(height: tokens.spacingXs),
            Text(
              note!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
