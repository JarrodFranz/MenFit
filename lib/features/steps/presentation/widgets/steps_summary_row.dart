import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';

/// Total, daily average and days-at-target for the selected range.
///
/// Both the average and the at-target count are qualified with "of N days
/// with data" — see [computeStepsRangeStats]. The at-target count is
/// reported as a count and nothing else: no praise for clearing it, no
/// remark about the days that did not.
///
/// Lays out as three, two or one column depending on the width it is given,
/// so a 320dp screen at 150% text scale reflows instead of overflowing.
class StepsSummaryRow extends StatelessWidget {
  const StepsSummaryRow({
    required this.stats,
    required this.target,
    super.key,
  });

  final StepsRangeStats stats;
  final int target;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final numberFormat = NumberFormat.decimalPattern();
    final average = stats.average;
    final caption = stepsDaysWithDataCaption(stats.daysWithData);

    final tiles = <Widget>[
      _StepsStatTile(
        key: const ValueKey('steps-stat-total'),
        label: stepsTotalLabel,
        value: numberFormat.format(stats.totalSteps),
      ),
      _StepsStatTile(
        key: const ValueKey('steps-stat-average'),
        label: stepsAverageLabel,
        value: average == null ? '—' : numberFormat.format(average),
        caption: stats.hasAnyData ? caption : null,
      ),
      _StepsStatTile(
        key: const ValueKey('steps-stat-at-target'),
        label: stepsAtTargetLabel,
        value: '${stats.daysAtTarget}',
        caption: stats.hasAnyData ? caption : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final spacing = tokens.spacingMd;
        final columns = available >= 330 ? 3 : (available >= 220 ? 2 : 1);
        final tileWidth = (available - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}

class _StepsStatTile extends StatelessWidget {
  const _StepsStatTile({
    required this.label,
    required this.value,
    this.caption,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final caption = this.caption;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)
              .tabularFigures,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (caption != null)
          Text(
            caption,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
