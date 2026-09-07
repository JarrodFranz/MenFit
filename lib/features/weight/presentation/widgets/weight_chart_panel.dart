import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/weight_copy.dart';
import 'package:menfit_app/features/weight/presentation/weight_history_providers.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_trend_chart.dart';

/// The chart plus the copy that has to travel with it: never the chart on
/// its own.
///
/// The fluid-shift note is not decoration — it is the reason task 2.2
/// exists, and a weight chart shipped without it is the anxious surface
/// this feature was meant to replace. Hence one widget for both, with no
/// switch to turn the copy off: no caller can mount the graph and forget
/// the sentence, on the Progress card or anywhere else.
class WeightChartPanel extends ConsumerWidget {
  const WeightChartPanel({
    required this.range,
    required this.unitSystem,
    required this.seriesMode,
    required this.showCycleOverlay,
    this.height = 240,
    super.key,
  });

  final WeightRange range;
  final UnitSystem unitSystem;
  final WeightSeriesMode seriesMode;
  final bool showCycleOverlay;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Range-independent, like the header's "latest reading": it separates
    // "she has never logged anything" from "this window happens to be
    // empty", which are different sentences (see `weight_copy.dart`).
    final hasAnyReading = ref.watch(latestWeightLogProvider).value != null;

    return ref
        .watch(weightTrendProvider(range))
        .when(
          loading: () => SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SizedBox(
            height: height,
            child: Center(
              child: Text(
                userMessageFor(error),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          data: (series) {
            if (series.isEmpty) {
              return _NoteText(
                hasAnyReading
                    ? weightRangeEmptyMessage
                    : weightEmptyStateMessage,
                height: height,
              );
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: KeyedSubtree(
                key: ValueKey(
                  '${series.points.length}_${seriesMode.name}_$range',
                ),
                child: _PlottedPanel(
                  series: series,
                  unitSystem: unitSystem,
                  seriesMode: seriesMode,
                  showCycleOverlay: showCycleOverlay,
                  height: height,
                ),
              ),
            );
          },
        );
  }
}

/// The chart itself and the notes that travel with it, for a range that has
/// at least one reading in it.
///
/// Split out so the cycle overlay can be resolved against the **plotted
/// span** — which only exists once the series is known to be non-empty —
/// rather than against the selected range's calendar bounds.
class _PlottedPanel extends ConsumerWidget {
  const _PlottedPanel({
    required this.series,
    required this.unitSystem,
    required this.seriesMode,
    required this.showCycleOverlay,
    required this.height,
  });

  final WeightTrendSeries series;
  final UnitSystem unitSystem;
  final WeightSeriesMode seriesMode;
  final bool showCycleOverlay;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    // Watched only when the bands are actually drawn: phasing a window
    // through the prediction engine is real work, and a user with the
    // overlay off should not pay for it. The window is the plotted span,
    // because that is the only stretch the chart can paint across.
    final phaseByDay = showCycleOverlay
        ? (ref
                  .watch(
                    weightCyclePhasesProvider(
                      start: series.points.first.day,
                      end: series.points.last.day,
                    ),
                  )
                  .value ??
              const <LocalDate, CyclePhase>{})
        : const <LocalDate, CyclePhase>{};

    // The legend and the cycle explainer describe *shaded bands*, so they
    // may only appear when a band is actually drawn. Only
    // [bandedCyclePhases] produce one, so a window phased entirely as
    // follicular/ovulatory paints nothing and must say nothing — a
    // non-empty map is not the same claim.
    final hasBands = phaseByDay.values.any(bandedCyclePhases.contains);
    final enhancedSemantics = ref
        .watch(accessibilityControllerProvider)
        .enhancedSemantics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeightTrendChart(
          series: series,
          unitSystem: unitSystem,
          seriesMode: seriesMode,
          phaseByDay: phaseByDay,
          height: height,
          enhancedSemantics: enhancedSemantics,
        ),
        if (hasBands) ...[
          SizedBox(height: tokens.spacingSm),
          const WeightPhaseLegend(),
        ],
        if (!series.hasTrend) ...[
          SizedBox(height: tokens.spacingSm),
          _SparseMilestoneIndicator(count: series.points.length),
          SizedBox(height: tokens.spacingSm),
          const _NoteText(weightMinimumDataNote),
        ],
        SizedBox(height: tokens.spacingSm),
        _NoteText(weightFluidNote(unitSystem)),
        if (hasBands) ...[
          SizedBox(height: tokens.spacingSm),
          const _NoteText(weightCycleContextNote),
        ],
      ],
    );
  }
}

class _SparseMilestoneIndicator extends StatelessWidget {
  const _SparseMilestoneIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clamped = count.clamp(0, minimumDaysForWeightTrend);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < minimumDaysForWeightTrend; i++) ...[
                if (i > 0) SizedBox(width: tokens.spacingXs),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < clamped
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            '$clamped of $minimumDaysForWeightTrend days logged',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteText extends StatelessWidget {
  const _NoteText(this.text, {this.height});

  final String text;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    if (height == null) return label;
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(
            Theme.of(context).extension<AppTokens>()!.spacingMd,
          ),
          child: DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            child: label,
          ),
        ),
      ),
    );
  }
}
