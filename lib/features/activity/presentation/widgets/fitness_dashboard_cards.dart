import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_energy.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/steps/steps_widgets.dart';

/// "At a Glance" modular fitness and movement cards inspired by Garmin Connect.
/// Displays daily steps ring with 7-day consistency, active energy burn,
/// weekly exercise volume, and workout metrics.
class FitnessDashboardCards extends ConsumerStatefulWidget {
  const FitnessDashboardCards({
    required this.activities,
    required this.unitSystem,
    super.key,
  });

  final List<Activity> activities;
  final UnitSystem unitSystem;

  @override
  ConsumerState<FitnessDashboardCards> createState() =>
      _FitnessDashboardCardsState();
}

class _FitnessDashboardCardsState extends ConsumerState<FitnessDashboardCards> {
  // The post-frame `stepsSync.syncRecent()` that used to live here moved
  // into `StepsRingCard` when that card was lifted into `features/steps`:
  // the card that shows the step history is the right owner of the sync
  // that fills it, and leaving a second trigger here would fire the same
  // throttled call twice per mount.

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final isSyncEnabled = ref.watch(fitnessDeviceSyncControllerProvider);
    final healthState = ref.watch(healthSyncProvider);
    final todaySnapshot = healthState.latestSnapshot;
    final profile = ref.watch(userProfileProvider).value;

    // Calculate energy burned from today's logged activities
    final now = DateTime.now();
    final today = LocalDate.today();
    // `startedAt` is a UTC instant; compare on the LOCAL calendar day or a
    // workout just after local midnight east of UTC counts as yesterday
    // (found in review 2026-09-04; `home_today_overview.dart` already did
    // this correctly).
    final todayActivities = widget.activities.where(
      (a) => LocalDate.fromDateTime(a.startedAt.toLocal()) == today,
    );
    final todayWorkoutKcal = calculateTotalActiveCaloriesKcal(
      activities: todayActivities,
      profile: profile,
      referenceDate: now,
    );

    // Calculate weekly metrics from activities
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recentActivities = widget.activities
        .where(
          (a) => a.startedAt.isAfter(sevenDaysAgo),
        )
        .toList();

    var weeklyMeters = 0.0;
    var weeklySeconds = 0;
    for (final a in recentActivities) {
      weeklyMeters += a.distanceMeters;
      weeklySeconds += a.movingTime.inSeconds;
    }
    final weeklyDuration = Duration(seconds: weeklySeconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'At a Glance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Card: Steps & 7-Day Consistency (Garmin Style).
            // One shared definition with the home dashboard - see
            // `features/steps/steps_widgets.dart`.
            const Expanded(child: StepsRingCard()),
            SizedBox(width: tokens.spacingSm),
            // Right Card: Active Energy & Workout Volume
            Expanded(
              child: Column(
                children: [
                  _ActiveEnergyCard(
                    isSyncEnabled: isSyncEnabled,
                    watchCaloriesKcal: todaySnapshot?.activeCaloriesKcal,
                    workoutCaloriesKcal: todayWorkoutKcal,
                    hasWorkoutsToday: todayActivities.isNotEmpty,
                    onTap: () {
                      if (!isSyncEnabled) {
                        const SettingsRouteData().go(context);
                      } else {
                        unawaited(
                          ref.read(healthSyncProvider.notifier).syncToday(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: tokens.spacingSm),
                  _WeeklyVolumeCard(
                    weeklyMeters: weeklyMeters,
                    weeklyDuration: weeklyDuration,
                    workoutCount: recentActivities.length,
                    unitSystem: widget.unitSystem,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Active energy burned card.
class _ActiveEnergyCard extends StatelessWidget {
  const _ActiveEnergyCard({
    required this.isSyncEnabled,
    required this.watchCaloriesKcal,
    required this.workoutCaloriesKcal,
    required this.hasWorkoutsToday,
    this.onTap,
  });

  final bool isSyncEnabled;
  final double? watchCaloriesKcal;
  final double workoutCaloriesKcal;
  final bool hasWorkoutsToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalKcal = (watchCaloriesKcal != null && watchCaloriesKcal! > 0)
        ? math.max(watchCaloriesKcal!, workoutCaloriesKcal)
        : (workoutCaloriesKcal > 0
              ? workoutCaloriesKcal
              : (watchCaloriesKcal ?? 0.0));

    final String kcalStr;
    final String subtitle;

    if (totalKcal > 0) {
      kcalStr = '${totalKcal.round()} kcal';
      if (watchCaloriesKcal != null &&
          watchCaloriesKcal! > 0 &&
          workoutCaloriesKcal > 0) {
        subtitle = 'Watch & workouts';
      } else if (workoutCaloriesKcal > 0) {
        subtitle = "From today's workouts";
      } else {
        subtitle = 'Burned today';
      }
    } else if (isSyncEnabled || hasWorkoutsToday) {
      kcalStr = '0 kcal';
      subtitle = 'Burned today';
    } else {
      kcalStr = 'Connect';
      subtitle = 'Fitness device';
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Active Energy',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      // Two words in a card half a phone wide (~84dp of
                      // header), where this was clipped to "Active…" at
                      // *default* text size on a 320dp screen. It wraps
                      // between the words, never inside one.
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                kcalStr,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekly volume & distance summary card.
class _WeeklyVolumeCard extends StatelessWidget {
  const _WeeklyVolumeCard({
    required this.weeklyMeters,
    required this.weeklyDuration,
    required this.workoutCount,
    required this.unitSystem,
  });

  final double weeklyMeters;
  final Duration weeklyDuration;
  final int workoutCount;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final distanceStr = formatDistance(weeklyMeters, unitSystem);
    final durationStr = formatDuration(weeklyDuration);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 18,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Weekly Volume',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    // Same as `_ActiveEnergyCard` above: two words, ~84dp,
                    // clipped at default settings before this.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              distanceStr,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$durationStr · $workoutCount workouts',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
