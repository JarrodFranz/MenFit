import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_controller.dart';

/// Custom tools for Swimming (Pool length calculator & non-starting preview).
class SwimCustomSection extends ConsumerWidget {
  const SwimCustomSection({super.key});

  void _showSwimPoolDialog(
    BuildContext context,
    WidgetRef ref, {
    required int defaultLength,
    required String title,
  }) {
    var poolLength = defaultLength;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose your lane pool length for lap tracking:'),
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 25, label: Text('25m')),
                    ButtonSegment(value: 33, label: Text('33m')),
                    ButtonSegment(value: 50, label: Text('50m')),
                  ],
                  selected: {poolLength},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) {
                      setDialogState(() => poolLength = set.first);
                    }
                  },
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
                      .read(swimTrackerControllerProvider.notifier)
                      .startWorkoutIfNeeded();
                  ref
                      .read(swimTrackerControllerProvider.notifier)
                      .setPoolLength(poolLength.toDouble());
                  unawaited(
                    const SwimTrackerRouteData().push<void>(context),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Swim'),
              ),
            ],
          ),
        ),
      ),
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
              'Pool Presets',
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
                  avatar: const Icon(Icons.pool, size: 16),
                  label: const Text('25m Short Course'),
                  onPressed: () => _showSwimPoolDialog(
                    context,
                    ref,
                    defaultLength: 25,
                    title: '25m Pool Preset',
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.waves, size: 16),
                  label: const Text('50m Olympic Pool'),
                  onPressed: () => _showSwimPoolDialog(
                    context,
                    ref,
                    defaultLength: 50,
                    title: '50m Olympic Pool Preset',
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
