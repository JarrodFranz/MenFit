import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';

/// Custom tools for HIIT (Interval presets with non-starting config dialog).
class HiitCustomSection extends ConsumerWidget {
  const HiitCustomSection({super.key});

  void _showHiitConfigDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int defaultWork,
    required int defaultRest,
    required int defaultRounds,
  }) {
    var work = defaultWork;
    var rest = defaultRest;
    var rounds = defaultRounds;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            final totalSeconds = (work + rest) * rounds;
            final mins = totalSeconds ~/ 60;
            final secs = totalSeconds % 60;
            final totalTimeStr = mins > 0
                ? '${mins}m ${secs > 0 ? "${secs}s" : ""}'
                : '${secs}s';

            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Duration: $totalTimeStr',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStepperRow(
                    label: 'Work Interval',
                    value: '${work}s',
                    onMinus: work > 5
                        ? () => setDialogState(() => work -= 5)
                        : null,
                    onPlus: work < 300
                        ? () => setDialogState(() => work += 5)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildStepperRow(
                    label: 'Rest Interval',
                    value: '${rest}s',
                    onMinus: rest > 0
                        ? () => setDialogState(() => rest -= 5)
                        : null,
                    onPlus: rest < 180
                        ? () => setDialogState(() => rest += 5)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildStepperRow(
                    label: 'Total Rounds',
                    value: '$rounds',
                    onMinus: rounds > 1
                        ? () => setDialogState(() => rounds--)
                        : null,
                    onPlus: rounds < 50
                        ? () => setDialogState(() => rounds++)
                        : null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Close'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    ref
                        .read(hiitTrackerControllerProvider.notifier)
                        .startWorkoutIfNeeded(
                          workSeconds: work,
                          restSeconds: rest,
                          totalRounds: rounds,
                        );
                    unawaited(
                      HiitTrackerRouteData(
                        work: work,
                        rest: rest,
                        rounds: rounds,
                      ).push<void>(context),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Workout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _buildStepperRow({
    required String label,
    required String value,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onMinus,
        ),
        SizedBox(
          width: 44,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onPlus,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: themedCardShape(
        context,
        radius: 16,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interval Presets',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingSm,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.timer_outlined, size: 16),
                  label: const Text('Tabata (20s/10s × 8)'),
                  onPressed: () => _showHiitConfigDialog(
                    context,
                    ref,
                    title: 'Tabata Protocol',
                    defaultWork: 20,
                    defaultRest: 10,
                    defaultRounds: 8,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.bolt, size: 16),
                  label: const Text('Power 40/20 × 6'),
                  onPressed: () => _showHiitConfigDialog(
                    context,
                    ref,
                    title: 'Power Intervals',
                    defaultWork: 40,
                    defaultRest: 20,
                    defaultRounds: 6,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.alarm, size: 16),
                  label: const Text('EMOM (45s/15s × 10)'),
                  onPressed: () => _showHiitConfigDialog(
                    context,
                    ref,
                    title: 'EMOM Intervals',
                    defaultWork: 45,
                    defaultRest: 15,
                    defaultRounds: 10,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.tune, size: 16),
                  label: const Text('Custom Interval'),
                  onPressed: () => _showHiitConfigDialog(
                    context,
                    ref,
                    title: 'Custom Intervals',
                    defaultWork: 30,
                    defaultRest: 30,
                    defaultRounds: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
