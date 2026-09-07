import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/weight_copy.dart';
import 'package:menfit_app/features/weight/presentation/weight_history_providers.dart';
import 'package:menfit_app/features/weight/presentation/weight_view_controller.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_chart_panel.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_log_dialog.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_summary_header.dart';

/// The Progress screen's Weight card: the last three months at a glance,
/// a way to log a reading, and a way through to the full history.
///
/// Mounted by `features/progress` through `weight_widgets.dart` (ADR 007's
/// UI-composition amendment), the same shape as `RecapHistorySection` and
/// `InsightDiscoverySection`.
///
/// Unlike those two it renders even with nothing logged: an empty
/// discovery card is a nag, but a weight card with no readings is the only
/// place the feature can be found from, and its empty state is an
/// invitation with no target attached (see
/// `presentation/weight_copy.dart`).
class WeightProgressSection extends ConsumerWidget {
  const WeightProgressSection({super.key});

  /// The card always shows three months, whatever the full screen is set
  /// to: a Progress card is a glance, and inheriting a range the user
  /// picked on another screen would make the card change shape for
  /// reasons invisible from here.
  static const WeightRange cardRange = WeightRange.threeMonths;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final view = ref.watch(weightViewControllerProvider);
    final hasCycleContext =
        ref.watch(weightHasCycleContextProvider).value ?? false;
    final series = ref.watch(weightTrendProvider(cardRange)).value;
    final latest = ref.watch(latestWeightLogProvider).value;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    weightSectionTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Icon(
                  Icons.monitor_weight_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            WeightSummaryHeader(
              latest: latest,
              direction: series?.direction ?? WeightTrendDirection.undetermined,
              unitSystem: unitSystem,
            ),
            SizedBox(height: tokens.spacingSm),
            WeightChartPanel(
              range: cardRange,
              unitSystem: unitSystem,
              seriesMode: view.seriesMode,
              showCycleOverlay: view.overlayVisibleWhen(
                hasCycleData: hasCycleContext,
              ),
              height: 160,
            ),
            SizedBox(height: tokens.spacingSm),
            // A `Row` here overflowed to the right by 9px at 100% text on a
            // 320dp phone and by 78px with the accessibility switches on:
            // two buttons whose combined intrinsic width is a function of
            // the label text can never be made to fit a fixed row by
            // shrinking anything. `Wrap` drops the second button onto its
            // own line instead, which costs one line of height and nothing
            // else.
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('weightSectionLogButton'),
                  onPressed: () =>
                      WeightLogDialog.show(context, unitSystem: unitSystem),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Log weight'),
                ),
                TextButton(
                  key: const Key('weightSectionHistoryButton'),
                  onPressed: () =>
                      unawaited(const WeightRouteData().push<void>(context)),
                  child: const Text('View history'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
