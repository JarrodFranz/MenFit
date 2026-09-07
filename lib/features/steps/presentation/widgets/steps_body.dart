import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';
import 'package:menfit_app/features/steps/presentation/steps_view_controller.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_message_panel.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_period_header.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_range_view.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

/// The explanatory panel (when there is one) and the range views (when
/// there is anything to draw).
///
/// ## Why `permissionNeeded` stays panel-only
///
/// The other two non-available states are statements of fact about the
/// device — no platform here, sync switched off — and the rows underneath
/// are simply the history, correctly labelled. A permission prompt is a
/// *question*, and a chart drawn under it reads as an answer: "this is what
/// you will get once you allow it", when in truth it is whatever was synced
/// before access was revoked. Rather than caption around that ambiguity,
/// the screen asks the question on its own and shows the history once it
/// has an answer.
class StepsBody extends ConsumerStatefulWidget {
  const StepsBody({
    required this.availability,
    required this.permissionRefused,
    required this.stillChecking,
    required this.onRequestPermission,
    required this.onRangeChanged,
    required this.syncFailed,
    super.key,
  });

  final StepsAvailability availability;

  /// A permission request came back refused.
  final bool permissionRefused;

  /// The platform never answered the access check in time.
  final bool stillChecking;

  final Future<void> Function() onRequestPermission;
  final VoidCallback onRangeChanged;
  final bool syncFailed;

  @override
  ConsumerState<StepsBody> createState() => _StepsBodyState();
}

class _StepsBodyState extends ConsumerState<StepsBody> {
  /// Latches once a range with rows has been seen in this session.
  ///
  /// Without it, a read-only screen that showed the history and was then
  /// stepped back to an empty month would drop the period header along with
  /// the chart — taking away the only control that could bring her back.
  /// Deliberately assigned during `build` and never un-set: it only ever
  /// turns on, and it turns on in the very build that already has the rows,
  /// so no extra frame or `setState` is involved.
  ///
  /// It governs **whether the views are mounted** and nothing else. The
  /// panel's wording is decided by the range actually on screen — see
  /// [_panelBody].
  bool _sawHistory = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final availability = widget.availability;

    if (availability == StepsAvailability.permissionNeeded) {
      return StepsMessagePanel(
        key: const Key('stepsPermissionPanel'),
        icon: Icons.lock_outline,
        title: stepsPermissionTitle,
        body: stepsPermissionBody,
        actionLabel: stepsPermissionAction,
        onAction: () => unawaited(widget.onRequestPermission()),
        footnote: widget.permissionRefused
            ? stepsPermissionRefusedBody
            : (widget.stillChecking ? stepsStillCheckingNote : null),
      );
    }

    final isAvailable = availability == StepsAvailability.available;
    final view = ref.watch(stepsViewControllerProvider);
    final target = ref.watch(stepsTargetProvider);
    final controller = ref.read(stepsViewControllerProvider.notifier);
    final today = LocalDate.today();
    final range = view.period.rangeFor(view.anchor);
    final rowsAsync = ref.watch(
      dailyStepsRangeProvider(range.start, range.end),
    );
    final hasRows = rowsAsync.value?.isNotEmpty ?? false;
    if (hasRows) _sawHistory = true;

    // The current week/month runs past today; days that have not happened
    // are not "missing data" and must not be counted as such.
    final displayEnd = range.end.isAfter(today) ? today : range.end;
    final showViews = isAvailable || _sawHistory;

    final panel = switch (availability) {
      StepsAvailability.unsupportedPlatform => StepsMessagePanel(
        key: const Key('stepsUnsupportedPanel'),
        icon: Icons.devices_other_outlined,
        title: stepsUnsupportedTitle,
        body: _panelBody(
          hasRows: hasRows,
          withHistory: stepsUnsupportedBodyWithHistory,
          without: stepsUnsupportedBody,
        ),
      ),
      StepsAvailability.syncOff => StepsMessagePanel(
        key: const Key('stepsSyncOffPanel'),
        icon: Icons.sync_disabled_outlined,
        title: stepsSyncOffTitle,
        body: _panelBody(
          hasRows: hasRows,
          withHistory: stepsSyncOffBodyWithHistory,
          without: stepsSyncOffBody,
        ),
        actionLabel: stepsSyncOffAction,
        // `go`, not `push`: Settings is a shell branch, so this switches
        // tabs rather than stacking a second Settings on top of Steps -
        // the same call `_ActiveEnergyCard` makes from the dashboard.
        onAction: () => const SettingsRouteData().go(context),
      ),
      // `available` needs no explanation, and `permissionNeeded` returned
      // above.
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (panel != null) ...[panel, SizedBox(height: tokens.spacingLg)],
        if (showViews) ...[
          StepsPeriodHeader(
            period: view.period,
            anchor: view.anchor,
            today: today,
            onPeriodChanged: (period) {
              controller.selectPeriod(period);
              widget.onRangeChanged();
            },
            onPrevious: () {
              controller.previous();
              widget.onRangeChanged();
            },
            onNext: () {
              controller.next();
              widget.onRangeChanged();
            },
          ),
          SizedBox(height: tokens.spacingMd),
          // Only where a failed read is news: on a device that cannot read
          // steps at all, "couldn't read steps just now" is noise on top of
          // a panel that already said why.
          if (widget.syncFailed && isAvailable) ...[
            Text(
              stepsSyncFailedMessage,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
          ],
          rowsAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacingMd),
              child: Text(
                userMessageFor(error),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            data: (rows) => StepsRangeView(
              days: buildStepsDays(
                start: range.start,
                end: displayEnd,
                stepsByDay: {for (final row in rows) row.day: row.steps},
              ),
              target: target,
              today: DateTime(today.year, today.month, today.day),
            ),
          ),
          SizedBox(height: tokens.spacingLg),
        ],
      ],
    );
  }

  /// The panel's wording, decided by **the range on screen** rather than by
  /// [_sawHistory].
  ///
  /// The two questions differ: the latch asks "is there any history worth
  /// keeping the controls for", the copy asks "is there a chart under this
  /// sentence right now". Stepping back to an empty month keeps the header
  /// and the chart mounted, but "the history below was synced on your
  /// phone" would then point at an empty chart and be false.
  String _panelBody({
    required bool hasRows,
    required String withHistory,
    required String without,
  }) => hasRows ? withHistory : without;
}
