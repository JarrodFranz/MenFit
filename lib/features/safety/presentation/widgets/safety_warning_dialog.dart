import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/safety/domain/safety_checkin_engine.dart';
import 'package:menfit_app/features/safety/safety_providers.dart';

/// Shows the [SafetyWarningDialog] connected to [SafetyMonitorController].
Future<void> showSafetyWarningDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const SafetyWarningDialogWrapper(),
  );
}

/// Reactive wrapper that ticks the countdown timer and pops when dismissed.
class SafetyWarningDialogWrapper extends ConsumerStatefulWidget {
  const SafetyWarningDialogWrapper({super.key});

  @override
  ConsumerState<SafetyWarningDialogWrapper> createState() =>
      _SafetyWarningDialogWrapperState();
}

class _SafetyWarningDialogWrapperState
    extends ConsumerState<SafetyWarningDialogWrapper> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        unawaited(
          ref.read(safetyMonitorControllerProvider.notifier).tickCountdown(),
        );
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyMonitorControllerProvider);
    final controller = ref.read(safetyMonitorControllerProvider.notifier);

    ref.listen(safetyMonitorControllerProvider, (previous, next) {
      if (!next.isWarningActive && (previous?.isWarningActive ?? true)) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    final reason = state.warningReason ?? SafetyAlertReason.inactivity;

    return SafetyWarningDialog(
      reason: reason,
      secondsRemaining: state.warningSecondsRemaining,
      onDismissSafe: controller.dismissWarning,
      onTriggerSos: () => controller.triggerSos(reason: reason),
      onExtendDeadline: reason == SafetyAlertReason.checkinDeadline
          ? () => controller.extendDeadline(const Duration(minutes: 15))
          : null,
    );
  }
}

/// Modal dialog shown when stationary inactivity is detected or when a
/// safety check-in deadline passes during an outdoor workout.
class SafetyWarningDialog extends StatelessWidget {
  const SafetyWarningDialog({
    required this.reason,
    required this.secondsRemaining,
    required this.onDismissSafe,
    required this.onTriggerSos,
    super.key,
    this.onExtendDeadline,
  });

  final SafetyAlertReason reason;
  final int secondsRemaining;
  final VoidCallback onDismissSafe;
  final VoidCallback onTriggerSos;
  final VoidCallback? onExtendDeadline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = theme.extension<AppTokens>()!;

    final isDeadline = reason == SafetyAlertReason.checkinDeadline;
    final title = isDeadline ? 'Check-in Overdue' : 'Are You OK?';
    final description = isDeadline
        ? "You have reached your estimated return time and haven't "
              'checked in.'
        : 'FemFit noticed you have stopped moving for several minutes.';

    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          side: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
        titlePadding: EdgeInsets.only(
          top: tokens.spacingLg,
          left: tokens.spacingLg,
          right: tokens.spacingLg,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacingLg,
          vertical: tokens.spacingMd,
        ),
        actionsPadding: EdgeInsets.all(tokens.spacingMd),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(tokens.spacingSm),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: colorScheme.onErrorContainer,
                size: 28,
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingLg),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: tokens.spacingMd,
                horizontal: tokens.spacingLg,
              ),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'SOS ALERT IN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.error,
                    ),
                  ),
                  SizedBox(height: tokens.spacingXs),
                  Text(
                    '${secondsRemaining}s',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              'If you do not respond, an emergency message with your '
              'GPS location will be prepared for your contacts.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: tokens.spacingMd),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("I'm OK — Continue Workout"),
                onPressed: onDismissSafe,
              ),
              if (onExtendDeadline != null) ...[
                SizedBox(height: tokens.spacingXs),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
                  ),
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Add 15 Minutes to Check-in'),
                  onPressed: onExtendDeadline,
                ),
              ],
              SizedBox(height: tokens.spacingXs),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
                ),
                icon: const Icon(Icons.sos),
                label: const Text('Send Emergency SOS Now'),
                onPressed: onTriggerSos,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
