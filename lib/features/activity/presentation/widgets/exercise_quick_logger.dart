import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/widgets/activity_primary_actions.dart';

/// Top section of the Train tab: one tile per exercise type, each opening
/// that type's hub directly, with the tab's actions underneath.
///
/// The tiles used to open a per-type options sheet (hub / live tracker /
/// route / manual entry). Every one of those launchers already exists inside
/// the hub itself, so the sheet was a whole extra tap between the user and
/// the screen they were heading for; the tile now goes straight there.
///
/// Strength leads the row rather than sitting fifth where the enum happens
/// to declare it — the same ordering the type filter chips below use. The
/// action block underneath lives in [ActivityPrimaryActions].
class ExerciseQuickLogger extends StatelessWidget {
  const ExerciseQuickLogger({
    required this.capabilities,
    super.key,
  });

  final LocationCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    // The tile is a fixed box holding an icon badge above a label, so both
    // axes have to grow with the text scaler or the label is clipped
    // horizontally and the column overflows vertically. Clamped because the
    // row scrolls horizontally: past ~1.5x a wider tile just means fewer
    // types visible without a swipe.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
    final tileWidth = 72 * scale;
    final tileHeight = 92 * scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Hubs',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        SizedBox(
          height: tileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _hubOrder.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: tokens.spacingSm),
            itemBuilder: (context, index) =>
                _ExerciseHubTile(type: _hubOrder[index], width: tileWidth),
          ),
        ),
        SizedBox(height: tokens.spacingMd),
        ActivityPrimaryActions(capabilities: capabilities),
        if (!capabilities.canRecordActivities &&
            capabilities.reason != null) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            capabilities.reason!,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Hub tiles in product order: strength first, then everything else in
/// declaration order. Mirrors the type filter chips in `activity_screen.dart`
/// — the first thing the Train tab offers is what the app is about, not
/// whichever type the enum happens to list first.
final List<ActivityType> _hubOrder = [
  ActivityType.strength,
  ...ActivityType.values.where((t) => t != ActivityType.strength),
];

class _ExerciseHubTile extends StatelessWidget {
  const _ExerciseHubTile({required this.type, required this.width});

  final ActivityType type;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = 'Open ${type.label} hub';
    void openHub() => unawaited(
      ExerciseHubRouteData(type: type.toStorage()).push<void>(context),
    );

    // One node for the whole tile: the label already names the type, so the
    // icon and the caption underneath would only repeat it.
    return Semantics(
      button: true,
      label: label,
      onTap: openHub,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: openHub,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconFor(type),
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  type.label,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(ActivityType type) => switch (type) {
  ActivityType.run => Icons.directions_run,
  ActivityType.walk => Icons.directions_walk,
  ActivityType.hike => Icons.terrain,
  ActivityType.ride => Icons.directions_bike,
  ActivityType.strength => Icons.fitness_center,
  ActivityType.yoga => Icons.self_improvement,
  ActivityType.hiit => Icons.flash_on,
  ActivityType.pilates => Icons.accessibility_new,
  ActivityType.swim => Icons.pool,
  ActivityType.other => Icons.sports,
};
