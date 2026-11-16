import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/application/activity_import_service.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/activity_list_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/exercise_quick_logger.dart';
import 'package:menfit_app/features/activity/presentation/widgets/fitness_dashboard_cards.dart';

enum _ActivityMenuOption {
  importFile,
  routes,
  settings,
}

/// The Activity tab: Exercise Hubs (one tile per type, each opening that
/// type's hub) with Record / Log Previous at top, "At a Glance" fitness
/// dashboard in the middle, filterable exercise type overview, and
/// chronological workout history.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  ActivityType? _selectedTypeFilter;

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityListControllerProvider);
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final capabilities = ref.read(locationAdapterProvider).capabilities;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train'),
        actions: [
          PopupMenuButton<_ActivityMenuOption>(
            icon: const Icon(Icons.menu),
            tooltip: 'Train menu',
            onSelected: (option) {
              switch (option) {
                case _ActivityMenuOption.importFile:
                  unawaited(_handleImport(context, ref));
                case _ActivityMenuOption.routes:
                  const ActivityRoutesRouteData().go(context);
                case _ActivityMenuOption.settings:
                  const SettingsRouteData().go(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _ActivityMenuOption.importFile,
                child: Row(
                  children: [
                    Icon(Icons.file_upload_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Import Garmin / GPX / FIT'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _ActivityMenuOption.routes,
                child: Row(
                  children: [
                    Icon(Icons.route_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Saved Routes'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _ActivityMenuOption.settings,
                child: Row(
                  children: [
                    Icon(Icons.watch_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Fitness & Health Devices'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: activitiesAsync.when(
          data: (allActivities) {
            final filteredActivities = _selectedTypeFilter == null
                ? allActivities
                : allActivities
                      .where((a) => a.activityType == _selectedTypeFilter)
                      .toList();

            return ListView(
              // No bottom reserve: the floating Record button that used to
              // need one was removed once Record moved under the Exercise
              // Hubs row, where it no longer covers the At a Glance cards.
              padding: EdgeInsets.all(tokens.spacingMd),
              children: [
                ExerciseQuickLogger(
                  capabilities: capabilities,
                ),
                SizedBox(height: tokens.spacingLg),
                if (_selectedTypeFilter == null) ...[
                  FitnessDashboardCards(
                    activities: allActivities,
                    unitSystem: unitSystem,
                  ),
                ] else ...[
                  _ActivityTypeOverviewCard(
                    type: _selectedTypeFilter!,
                    activities: filteredActivities,
                    unitSystem: unitSystem,
                  ),
                ],
                SizedBox(height: tokens.spacingLg),

                // Exercise Type Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTypeFilter == null
                          ? 'Recent Workouts'
                          : '${_selectedTypeFilter!.label} History',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedTypeFilter != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedTypeFilter = null;
                          });
                        },
                        child: const Text('Show All'),
                      ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
                // Sized by the chips themselves rather than a hard-coded
                // 36dp box: that box clamped every chip below the platform
                // tap-target floor and, worse, made the Large Touch Targets
                // preference unable to grow them at all.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedTypeFilter == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedTypeFilter = null;
                              });
                            }
                          },
                        ),
                      ),
                      // Strength leads, then everything else in declaration
                      // order: the first chip after "All" is the one this
                      // app is about, not whichever type the enum happens
                      // to list first.
                      ...[
                        ActivityType.strength,
                        ...ActivityType.values.where(
                          (t) => t != ActivityType.strength,
                        ),
                      ].map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            avatar: Icon(_iconFor(type), size: 16),
                            label: Text(type.label),
                            selected: _selectedTypeFilter == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTypeFilter = selected ? type : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: tokens.spacingMd),
                if (filteredActivities.isEmpty)
                  _EmptyState(
                    capabilities: capabilities,
                    customMessage: _selectedTypeFilter != null
                        ? 'No ${_selectedTypeFilter!.label} workouts '
                              'recorded yet.'
                        : null,
                  )
                else
                  ..._buildDayGroups(
                    context,
                    filteredActivities,
                    unitSystem,
                    tokens,
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(userMessageFor(error))),
        ),
      ),
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(activityImportServiceProvider);
      final imported = await service.pickAndImportFile();
      if (imported == null || !context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Imported "${imported.activity.title}" successfully'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                ActivityDetailRouteData(imported.activity.id).go(context);
              },
            ),
          ),
        );
    } on FormatException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Import failed: ${e.message}'),
            duration: const Duration(seconds: 3),
          ),
        );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not import file: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }
}

/// Overview card showing aggregate stats for a specific filtered exercise type.
class _ActivityTypeOverviewCard extends StatelessWidget {
  const _ActivityTypeOverviewCard({
    required this.type,
    required this.activities,
    required this.unitSystem,
  });

  final ActivityType type;
  final List<Activity> activities;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    var totalMovingSec = 0;
    var totalDistanceMeters = 0.0;
    var totalVolumeKg = 0.0;
    var totalSets = 0;
    var totalLaps = 0;

    for (final act in activities) {
      totalMovingSec += act.movingTime.inSeconds;
      totalDistanceMeters += act.distanceMeters;

      if (act.workoutDetails case final StrengthWorkoutDetails s) {
        totalVolumeKg += s.totalVolumeKg;
        totalSets += s.totalSets;
      } else if (act.workoutDetails case final SwimWorkoutDetails sw) {
        totalLaps += sw.laps;
      }
    }

    final totalDurationStr = formatDuration(Duration(seconds: totalMovingSec));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(type), color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${type.label} Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${activities.length} '
                  '${activities.length == 1 ? 'workout' : 'workouts'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (type == ActivityType.strength) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    label: 'TOTAL VOLUME',
                    value: '${totalVolumeKg.toStringAsFixed(0)} kg',
                  ),
                  _StatColumn(label: 'TOTAL SETS', value: '$totalSets'),
                  _StatColumn(label: 'TOTAL TIME', value: totalDurationStr),
                ],
              ),
            ] else if (type == ActivityType.swim) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    label: 'DISTANCE',
                    value: formatDistance(totalDistanceMeters, unitSystem),
                  ),
                  _StatColumn(label: 'TOTAL LAPS', value: '$totalLaps'),
                  _StatColumn(label: 'TOTAL TIME', value: totalDurationStr),
                ],
              ),
            ] else if (type == ActivityType.yoga ||
                type == ActivityType.pilates) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(label: 'SESSIONS', value: '${activities.length}'),
                  _StatColumn(label: 'MINDFUL TIME', value: totalDurationStr),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (totalDistanceMeters > 0)
                    _StatColumn(
                      label: 'DISTANCE',
                      value: formatDistance(totalDistanceMeters, unitSystem),
                    ),
                  _StatColumn(label: 'TOTAL TIME', value: totalDurationStr),
                  _StatColumn(label: 'WORKOUTS', value: '${activities.length}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.capabilities, this.customMessage});

  final LocationCapabilities capabilities;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacingMd,
          vertical: tokens.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_run,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              customMessage ??
                  "No activities yet - once you've moved, log it above and "
                      'watch your history build.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildDayGroups(
  BuildContext context,
  List<Activity> activities,
  UnitSystem unitSystem,
  AppTokens tokens,
) {
  final groups = _groupByDay(activities);
  final widgets = <Widget>[];

  for (final group in groups) {
    widgets.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
        child: Text(
          group.header,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
    for (final activity in group.activities) {
      widgets.add(
        _ActivityTile(
          key: ValueKey(activity.id),
          activity: activity,
          unitSystem: unitSystem,
        ),
      );
    }
  }

  return widgets;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required super.key,
    required this.activity,
    required this.unitSystem,
  });

  final Activity activity;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final hasDistance = activity.hasDistance;
    final pace = activity.avgPaceSecondsPerKm;
    final summary = [
      if (hasDistance) formatDistance(activity.distanceMeters, unitSystem),
      formatDuration(activity.movingTime),
      if (hasDistance && pace != null) formatPace(pace, unitSystem),
    ].join(' · ');

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacingSm),
      child: ListTile(
        leading: Icon(_iconFor(activity.activityType)),
        title: Text(activity.title),
        subtitle: Text(
          summary,
          style: textTheme.bodyMedium?.tabularFigures,
        ),
        onTap: () => ActivityDetailRouteData(activity.id).go(context),
      ),
    );
  }
}

/// Maps an [ActivityType] to its display icon.
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

class _DayGroup {
  const _DayGroup({required this.header, required this.activities});

  final String header;
  final List<Activity> activities;
}

/// Groups [activities] (already newest-first) by local calendar day,
/// preserving that order, with a relative header for today/yesterday and a
/// `EEEE, MMM d` header otherwise.
List<_DayGroup> _groupByDay(List<Activity> activities) {
  final groups = <_DayGroup>[];
  DateTime? currentDay;
  var currentActivities = <Activity>[];

  void flush() {
    final day = currentDay;
    if (day != null) {
      groups.add(
        _DayGroup(header: _dayHeaderLabel(day), activities: currentActivities),
      );
    }
  }

  for (final activity in activities) {
    final local = activity.startedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (currentDay == null || day != currentDay) {
      flush();
      currentDay = day;
      currentActivities = [];
    }
    currentActivities.add(activity);
  }
  flush();

  return groups;
}

String _dayHeaderLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (day == today) return 'Today';
  if (day == yesterday) return 'Yesterday';
  return DateFormat('EEEE, MMM d').format(day);
}
