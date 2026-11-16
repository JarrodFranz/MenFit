import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/settings/presentation/widgets/garmin_connect_dialog.dart';
import 'package:menfit_app/features/wearables/presentation/widgets/ble_sensor_card.dart';
import 'package:menfit_app/features/wearables/wearables_providers.dart';

/// Screen allowing users to manage Garmin Connect sync, Apple Watch / WearOS
/// companion integration, and live Bluetooth heart rate streaming.
class WearablesScreen extends ConsumerWidget {
  const WearablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wearablesState = ref.watch(wearablesControllerProvider);
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wearables & Watch'),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacingMd),
        children: [
          _buildGarminCard(
            context,
            ref,
            tokens,
            colorScheme,
            textTheme,
            wearablesState,
          ),
          SizedBox(height: tokens.spacingMd),
          _buildCompanionCard(
            context,
            ref,
            tokens,
            colorScheme,
            textTheme,
            wearablesState,
          ),
          SizedBox(height: tokens.spacingMd),
          const BleSensorCard(),
          SizedBox(height: tokens.spacingLg),
          Text(
            'Synced Wearable Workouts',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          _buildRecentSyncedList(
            tokens,
            colorScheme,
            textTheme,
            activitiesAsync,
          ),
        ],
      ),
    );
  }

  Widget _buildGarminCard(
    BuildContext context,
    WidgetRef ref,
    AppTokens tokens,
    ColorScheme colorScheme,
    TextTheme textTheme,
    WearablesState state,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacingSm),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Icon(
                    Icons.watch_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Garmin Connect Sync',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Health Connect / Apple Health Bridge',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Garmin setup guide',
                  onPressed: () => showGarminConnectDialog(context),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              'Outdoor runs, rides, and workouts from your Garmin watch are '
              'automatically ingested into MenFit.',
              style: textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.spacingMd),
            if (state.lastResult != null)
              Container(
                margin: EdgeInsets.only(bottom: tokens.spacingSm),
                padding: EdgeInsets.all(tokens.spacingSm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.lastResult!.isSuccess
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: state.lastResult!.isSuccess
                          ? colorScheme.primary
                          : colorScheme.error,
                      size: 18,
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: Text(
                        !state.lastResult!.isSuccess
                            ? state.lastResult!.errorMessage!
                            : state.lastResult!.syncedCount > 0
                            ? 'Synced ${state.lastResult!.syncedCount} '
                                  'new workout(s)!'
                            : 'Everything is up to date (no new workouts).',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                icon: state.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  state.isSyncing ? 'Syncing...' : 'Sync Workouts Now',
                ),
                onPressed: state.isSyncing
                    ? null
                    : () => ref
                          .read(wearablesControllerProvider.notifier)
                          .syncAll(userInitiated: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionCard(
    BuildContext context,
    WidgetRef ref,
    AppTokens tokens,
    ColorScheme colorScheme,
    TextTheme textTheme,
    WearablesState state,
  ) {
    final companion = state.companionInfo;
    final isPaired = companion != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(tokens.spacingSm),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Icon(
                    Icons.devices_other_outlined,
                    color: colorScheme.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watch Companion App',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isPaired
                            ? '${companion.deviceName} (${companion.platform})'
                            : 'Apple Watch & WearOS (menfit app)',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacingSm,
                    vertical: tokens.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: isPaired
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Text(
                    isPaired ? 'Paired' : 'Standby',
                    style: textTheme.labelSmall?.copyWith(
                      color: isPaired
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              'Record standalone workouts on an Apple Watch or WearOS device '
              'with the MenFit companion app installed. For Garmin watches or '
              'chest straps broadcasting optical HR, connect via Bluetooth '
              'below.',
              style: textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('Sync Wrist Workouts'),
                    onPressed: state.isSyncing
                        ? null
                        : () => ref
                              .read(wearablesControllerProvider.notifier)
                              .syncAll(userInitiated: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSyncedList(
    AppTokens tokens,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AsyncValue<List<Activity>> activitiesAsync,
  ) {
    return activitiesAsync.when(
      data: (activities) {
        final wearableWorkouts = activities
            .where((a) => a.workoutDetails is WearableWorkoutDetails)
            .take(10)
            .toList();

        if (wearableWorkouts.isEmpty) {
          return Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingLg),
              child: Center(
                child: Text(
                  'No wearable workouts synced yet.\n'
                  'Tap "Sync Workouts Now" above to import your runs.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: wearableWorkouts.map((activity) {
            final details = activity.workoutDetails! as WearableWorkoutDetails;
            final distanceKm = (activity.distanceMeters / 1000).toStringAsFixed(
              2,
            );
            final durationStr = formatDuration(activity.movingTime);

            return Card(
              margin: EdgeInsets.only(bottom: tokens.spacingSm),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    activity.activityType == ActivityType.run
                        ? Icons.directions_run
                        : (activity.activityType == ActivityType.ride
                              ? Icons.directions_bike
                              : Icons.fitness_center),
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(
                  activity.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${details.wearableSource} • $distanceKm km • $durationStr'
                  '${activity.avgHeartRate != null ? ' • '
                            '${activity.avgHeartRate} bpm' : ''}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
