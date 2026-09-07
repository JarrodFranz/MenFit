import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:menfit_app/features/steps/presentation/steps_view_controller.dart';

/// Week / Month selector plus the `< This Week >` anchor stepper.
///
/// The same shape as the Progress screen's header, minus the Day segment
/// ([stepsPeriods]) and reusing [ProgressPeriod]'s range arithmetic rather
/// than a second copy of it. Forward is disabled once the anchor is inside
/// the current period, so no navigation reaches the future.
///
/// Stateless and callback-driven so it can be pumped without providers.
class StepsPeriodHeader extends StatelessWidget {
  const StepsPeriodHeader({
    required this.period,
    required this.anchor,
    required this.today,
    required this.onPeriodChanged,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final ProgressPeriod period;
  final LocalDate anchor;
  final LocalDate today;
  final ValueChanged<ProgressPeriod> onPeriodChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final canGoForward = period.canGoForward(anchor, today);

    return Column(
      children: [
        Center(
          child: SegmentedButton<ProgressPeriod>(
            key: const Key('stepsPeriodSelector'),
            showSelectedIcon: false,
            segments: [
              for (final value in stepsPeriods)
                ButtonSegment(value: value, label: Text(value.label)),
            ],
            selected: {period},
            onSelectionChanged: (selection) => onPeriodChanged(selection.first),
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const Key('stepsPreviousPeriod'),
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous ${period.label.toLowerCase()}',
              onPressed: onPrevious,
            ),
            Flexible(
              child: Text(
                period.formatRange(anchor, today),
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              key: const Key('stepsNextPeriod'),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next ${period.label.toLowerCase()}',
              onPressed: canGoForward ? onNext : null,
            ),
          ],
        ),
      ],
    );
  }
}
