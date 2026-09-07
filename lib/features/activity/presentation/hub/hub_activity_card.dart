import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_controller.dart';

/// Single activity card with stats, in-place edit button, and delete action.
class HubActivityCard extends ConsumerWidget {
  const HubActivityCard({
    required this.activity,
    required this.unitSystem,
    super.key,
  });

  final Activity activity;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final textTheme = Theme.of(context).textTheme;

    final dateStr = DateFormat.yMMMd().format(activity.startedAt.toLocal());
    final timeStr = DateFormat.jm().format(activity.startedAt.toLocal());

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: themedCardShape(
        context,
        radius: 16,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => ActivityDetailRouteData(activity.id).go(context),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$dateStr • $timeStr',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit activity',
                    onPressed: () {
                      ActivityDetailEditRouteData(activity.id).go(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete activity',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacingSm),
              _renderActivityMetrics(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderActivityMetrics(BuildContext context) {
    final details = activity.workoutDetails;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (details is StrengthWorkoutDetails) {
      final volStr = details.totalVolumeKg >= 1000
          ? '${(details.totalVolumeKg / 1000).toStringAsFixed(1)} t'
          : '${details.totalVolumeKg.toStringAsFixed(0)} kg';
      return Wrap(
        spacing: 16,
        children: [
          Text(
            'Volume: $volStr',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${details.exercises.length} exercises • ${details.totalSets} sets',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${activity.movingTime.inMinutes} min',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    } else if (details is SwimWorkoutDetails) {
      return Wrap(
        spacing: 16,
        children: [
          Text(
            '${details.calculatedDistanceMeters.toStringAsFixed(0)} m '
            '(${details.laps} laps)',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            details.stroke,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${activity.movingTime.inMinutes} min',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    } else if (details is HiitWorkoutDetails) {
      return Wrap(
        spacing: 16,
        children: [
          Text(
            '${details.completedRounds} rounds',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${details.workSeconds}s work / ${details.restSeconds}s rest',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${activity.movingTime.inMinutes} min',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    } else if (details is MindfulWorkoutDetails) {
      return Wrap(
        spacing: 16,
        children: [
          // Sequence practices may carry no style / focus area but do carry
          // their poses; render what is known, never a blank chip.
          if (details.style.isNotEmpty)
            Text(
              details.style,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          if (details.focusArea.isNotEmpty)
            Text(
              details.focusArea,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (details.poses.isNotEmpty)
            Text(
              '${details.poses.length} poses',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          Text(
            '${activity.movingTime.inMinutes} min',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Default distance metrics
    final distUnit = unitSystem == UnitSystem.imperial ? 'mi' : 'km';
    final distVal = unitSystem == UnitSystem.imperial
        ? (activity.distanceMeters / 1609.34).toStringAsFixed(2)
        : (activity.distanceMeters / 1000.0).toStringAsFixed(2);

    final pace = formatPace(
      activity.distanceMeters > 0
          ? activity.movingTime.inSeconds / (activity.distanceMeters / 1000.0)
          : 0,
      unitSystem,
    );

    return Wrap(
      spacing: 16,
      children: [
        if (activity.distanceMeters > 0)
          Text(
            '$distVal $distUnit',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        Text(
          '${activity.movingTime.inMinutes} min',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (activity.distanceMeters > 0)
          Text(
            pace,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this activity?'),
        content: const Text(
          'This will remove it from your activity history. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(activityDetailControllerProvider(activity.id).notifier)
          .delete();
    }
  }
}

class EmptyHubActivitiesCard extends StatelessWidget {
  const EmptyHubActivitiesCard({required this.type, super.key});

  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              _emptyStateIconFor(type),
              size: 40,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No ${type.label} activities logged yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _emptyStateIconFor(ActivityType type) => switch (type) {
  ActivityType.run => Icons.directions_run_outlined,
  ActivityType.walk => Icons.directions_walk_outlined,
  ActivityType.hike => Icons.terrain_outlined,
  ActivityType.ride => Icons.directions_bike_outlined,
  ActivityType.strength => Icons.fitness_center_outlined,
  ActivityType.yoga => Icons.self_improvement_outlined,
  ActivityType.hiit => Icons.flash_on_outlined,
  ActivityType.pilates => Icons.accessibility_new_outlined,
  ActivityType.swim => Icons.pool_outlined,
  ActivityType.other => Icons.sports_outlined,
};
