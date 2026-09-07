import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/weight_copy.dart';
import 'package:menfit_app/features/weight/presentation/weight_history_providers.dart';
import 'package:menfit_app/features/weight/presentation/weight_view_controller.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_chart_panel.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_history_list.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_log_dialog.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_summary_header.dart';

/// The full weight history: trend chart, range and overlay controls, and
/// the readings themselves.
///
/// Reached at `/weight` from the Progress screen's Weight section.
class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    final view = ref.watch(weightViewControllerProvider);
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final series = ref.watch(weightTrendProvider(view.range)).value;
    final latest = ref.watch(latestWeightLogProvider).value;
    final logs = ref.watch(weightLogsInRangeProvider(view.range)).value;

    return Scaffold(
      appBar: AppBar(title: const Text(weightSectionTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('weightLogFab'),
        onPressed: () => WeightLogDialog.show(context, unitSystem: unitSystem),
        icon: const Icon(Icons.add),
        label: const Text('Log weight'),
      ),
      body: SafeArea(
        // Pinned to the top: a Center around a shrink-wrapping scroll view
        // floats short content mid-screen (seen on device 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RangeSelector(selected: view.range),
                  SizedBox(height: tokens.spacingMd),
                  WeightSummaryHeader(
                    latest: latest,
                    direction:
                        series?.direction ?? WeightTrendDirection.undetermined,
                    unitSystem: unitSystem,
                  ),
                  SizedBox(height: tokens.spacingMd),
                  WeightChartPanel(
                    range: view.range,
                    unitSystem: unitSystem,
                    seriesMode: view.seriesMode,
                  ),
                  SizedBox(height: tokens.spacingMd),
                  _ChartControls(
                    seriesMode: view.seriesMode,
                    showSeriesToggle: series?.hasTrend ?? false,
                  ),
                  SizedBox(height: tokens.spacingLg),
                  Text('History', style: textTheme.titleMedium),
                  WeightHistoryList(
                    logs: logs ?? const [],
                    unitSystem: unitSystem,
                  ),
                  // Clears the extended FAB so the last row stays tappable.
                  SizedBox(height: tokens.spacingXl * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector({required this.selected});

  final WeightRange selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<WeightRange>(
        key: const Key('weightRangeSelector'),
        showSelectedIcon: false,
        segments: [
          for (final range in WeightRange.values)
            ButtonSegment(value: range, label: Text(range.label)),
        ],
        selected: {selected},
        onSelectionChanged: (selection) => ref
            .read(weightViewControllerProvider.notifier)
            .selectRange(selection.first),
      ),
    );
  }
}

class _ChartControls extends ConsumerWidget {
  const _ChartControls({
    required this.seriesMode,
    required this.showSeriesToggle,
  });

  final WeightSeriesMode seriesMode;
  final bool showSeriesToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final controller = ref.read(weightViewControllerProvider.notifier);

    return Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Hidden rather than disabled when there is no trend line: a
        // greyed-out "Trend only" invites tapping something that cannot
        // work yet, and the panel already says why there is no line.
        if (showSeriesToggle)
          SegmentedButton<WeightSeriesMode>(
            key: const Key('weightSeriesModeSelector'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: WeightSeriesMode.readingsAndTrend,
                label: Text('Readings + trend'),
              ),
              ButtonSegment(
                value: WeightSeriesMode.trendOnly,
                label: Text('Trend only'),
              ),
            ],
            selected: {seriesMode},
            onSelectionChanged: (selection) =>
                controller.selectSeriesMode(selection.first),
          ),
      ],
    );
  }
}
