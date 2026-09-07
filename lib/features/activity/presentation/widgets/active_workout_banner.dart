import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/recording/active_workout_summary.dart';

/// Global active workout banner displayed when any workout is in progress.
/// Tapping it immediately navigates back to the active workout screen.
class ActiveWorkoutBanner extends ConsumerWidget {
  const ActiveWorkoutBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ActiveWorkoutSummary? summary;
    try {
      summary = ref.watch(activeWorkoutSummaryProvider);
    } on Object {
      return const SizedBox.shrink();
    }
    final active = summary;
    if (active == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final colorScheme = theme.colorScheme;

    final (icon, iconColor) = _iconFor(active.activityType);
    final durationStr = _formatDuration(active.elapsedDuration);

    void navigateToWorkout() {
      try {
        unawaited(GoRouter.of(context).push(active.routePath));
      } on Object {
        // Fallback if not inside GoRouter scope
      }
    }

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 6,
      child: InkWell(
        onTap: navigateToWorkout,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacingMd,
            vertical: tokens.spacingSm + 2,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: iconColor.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                // Animated / Highlighted Icon Badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: tokens.spacingMd),

                // Title & Live Metrics
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              active.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (active.isPaused) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade800,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PAUSED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            durationStr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '·  ${active.keyMetricLabel}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: tokens.spacingSm),

                // Return / Resume Button
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: navigateToWorkout,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Resume'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(ActivityType type) {
    return switch (type) {
      ActivityType.run => (Icons.directions_run, Colors.orange),
      ActivityType.walk => (Icons.directions_walk, Colors.blue),
      ActivityType.hike => (Icons.hiking, Colors.green),
      ActivityType.ride => (Icons.directions_bike, Colors.teal),
      ActivityType.strength => (Icons.fitness_center, Colors.deepPurple),
      ActivityType.hiit => (Icons.flash_on, Colors.deepOrange),
      ActivityType.yoga => (Icons.self_improvement, Colors.indigo),
      ActivityType.pilates => (Icons.accessibility_new, Colors.purple),
      ActivityType.swim => (Icons.pool, Colors.cyan),
      ActivityType.other => (Icons.sports, Colors.blueGrey),
    };
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }
}
