import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_bar_chart.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_daily_list.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_summary_row.dart';

/// Chart, summary and daily list for one already-resolved range.
///
/// Pure: it is handed [days] (one entry per calendar day, gaps included as
/// `null`) and a [target], and reads no providers — so the screen's
/// availability/loading/error branching stays in one place and this can be
/// pumped in a test with a literal list.
class StepsRangeView extends StatelessWidget {
  const StepsRangeView({
    required this.days,
    required this.target,
    required this.today,
    super.key,
  });

  final List<StepsDayView> days;
  final int target;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final stats = computeStepsRangeStats(days, target: target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepsBarChart(days: days, target: target, today: today),
        SizedBox(height: tokens.spacingLg),
        StepsSummaryRow(stats: stats, target: target),
        SizedBox(height: tokens.spacingLg),
        Text(stepsHistoryHeading, style: textTheme.titleMedium),
        SizedBox(height: tokens.spacingXs),
        StepsDailyList(days: days, target: target),
      ],
    );
  }
}
