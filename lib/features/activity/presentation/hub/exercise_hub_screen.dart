import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/hub/exercise_hub_providers.dart';
import 'package:menfit_app/features/activity/presentation/hub/hub_action_buttons.dart';
import 'package:menfit_app/features/activity/presentation/hub/hub_activity_card.dart';
import 'package:menfit_app/features/activity/presentation/hub/hub_stats_overview.dart';
import 'package:menfit_app/features/activity/presentation/hub/screen_awake_section.dart';
import 'package:menfit_app/features/activity/presentation/hub/type_specific_custom_tools.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_controller.dart';

/// Focused window for a specific [ActivityType] with aggregate stats,
/// live/manual launchers, custom domain tools, and recent history with
/// in-place editing.
class ExerciseHubScreen extends ConsumerWidget {
  const ExerciseHubScreen({
    required this.type,
    super.key,
  });

  final ActivityType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(exerciseHubStatsProvider(type));
    final activitiesAsync = ref.watch(exerciseHubActivitiesProvider(type));
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final capabilities = ref.read(locationAdapterProvider).capabilities;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // `Flexible` on the text, not a bare `Row` child: the icon is a
        // fixed 22dp but "Strength Hub" at the largest settings is wider
        // than the title box a 320dp phone can give it, and the row
        // overflowed to the right by up to 35px rather than letting the
        // title ellipsise the way an app-bar title normally does.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(type), size: 22),
            const SizedBox(width: 8),
            Flexible(child: Text('${type.label} Hub')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Log ${type.label}',
            onPressed: () {
              ref
                  .read(manualEntryControllerProvider.notifier)
                  .setInitialType(type);
              unawaited(
                ActivityLogRouteData(type: type.toStorage()).push<void>(
                  context,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: ListView(
              padding: EdgeInsets.all(tokens.spacingMd),
              children: [
                // 1. Overview & Aggregate Stats
                HubStatsOverview(
                  type: type,
                  stats: stats,
                  unitSystem: unitSystem,
                ),
                SizedBox(height: tokens.spacingLg),

                // 2. Primary Quick Action Buttons
                HubActionButtons(
                  type: type,
                  capabilities: capabilities,
                ),
                SizedBox(height: tokens.spacingLg),

                // 3. Custom Tools Specific to this Exercise Type
                TypeSpecificCustomTools(type: type),
                SizedBox(height: tokens.spacingLg),

                // 4. Per-type session behaviour - after the tools, not
                // before: a settings switch must not push the type's
                // primary content (cycle banner, sequences) below the fold.
                ScreenAwakeSection(type: type),
                SizedBox(height: tokens.spacingLg),

                // 5. Recent Activity Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recent ${type.label} Activity',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    activitiesAsync.when(
                      data: (list) => Text(
                        '${list.length} total',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),

                // 6. Filtered Activity List with In-Place Edit & Delete
                activitiesAsync.when(
                  data: (activities) {
                    if (activities.isEmpty) {
                      return EmptyHubActivitiesCard(type: type);
                    }
                    return Column(
                      children: activities.map((activity) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: tokens.spacingSm),
                          child: HubActivityCard(
                            activity: activity,
                            unitSystem: unitSystem,
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      userMessageFor(err),
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
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
