import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';

/// Every day in the range, newest first: the date, the count, and a tick
/// when the count reached the target.
///
/// A day with no row shows [stepsNoDataRowLabel] and no tick — never a
/// zero, and never an unticked row that reads as "they didn't reach it".
/// The tick is accompanied by a semantics label rather than standing on
/// colour alone.
///
/// Shrink-wraps (`shrinkWrap`, [NeverScrollableScrollPhysics]) because it
/// sits inside the screen's own scroll view; at most 31 rows, so the whole
/// list is cheap to build.
class StepsDailyList extends StatelessWidget {
  const StepsDailyList({
    required this.days,
    required this.target,
    super.key,
  });

  /// Oldest-first, as [buildStepsDays] returns them; rendered reversed.
  final List<StepsDayView> days;
  final int target;

  @override
  Widget build(BuildContext context) {
    final ordered = days.reversed.toList();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: ordered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _StepsDayRow(
        key: ValueKey('steps-day-${ordered[index].day.toIso()}'),
        day: ordered[index],
        target: target,
      ),
    );
  }
}

class _StepsDayRow extends StatelessWidget {
  const _StepsDayRow({required this.day, required this.target, super.key});

  final StepsDayView day;
  final int target;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final steps = day.steps;
    final metTarget = day.metTarget(target);
    final dateLabel = DateFormat(
      'EEE d MMM',
    ).format(DateTime(day.day.year, day.day.month, day.day.day));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateLabel,
              style: textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: tokens.spacingSm),
          Text(
            steps == null
                ? stepsNoDataRowLabel
                : NumberFormat.decimalPattern().format(steps),
            style: steps == null
                ? textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  )
                : textTheme.bodyMedium?.tabularFigures,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: tokens.spacingSm),
          SizedBox(
            width: 20,
            child: metTarget
                ? Semantics(
                    label: 'target reached',
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
