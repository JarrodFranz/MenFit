import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/application/activity_export_service.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_energy.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_controller.dart';
import 'package:menfit_app/features/activity/presentation/activity_export_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/route_map.dart';
import 'package:menfit_app/features/activity/presentation/widgets/splits_section.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_share_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_controller.dart';
import 'package:menfit_app/features/profile/presentation/profile_controller.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';

/// Detail view for a single activity: stats grid, notes, a route map for
/// recorded activities (see `presentation/widgets/route_map.dart`), and
/// edit/delete actions. Reached at `/activity/:id`.
class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({required this.activityId, super.key});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(
      activityDetailControllerProvider(activityId),
    );
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final activity = activityAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: _appBarActions(context, ref, activity),
      ),
      body: SafeArea(
        child: activityAsync.when(
          data: (activity) => activity == null
              ? const Center(child: Text('This activity was deleted.'))
              : _ActivityDetailBody(activity: activity, unitSystem: unitSystem),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(userMessageFor(error))),
        ),
      ),
    );
  }

  /// The four primary actions stay on the bar at every width.
  ///
  /// An earlier revision measured the title and collapsed all four into an
  /// overflow menu on narrow phones, to stop the title being clipped. That
  /// trade was backwards: the title here is the generic word "Activity"
  /// (the activity's real name is headlined in the body), so clipping it
  /// costs almost nothing, while burying share/export/edit/delete costs a
  /// tap on every one of them on the majority of phones — and it silently
  /// broke `activity_flow_test`'s delete path, which is how it was caught.
  /// If the title is ever made dynamic, revisit this decision rather than
  /// re-adding the collapse.
  List<Widget> _appBarActions(
    BuildContext context,
    WidgetRef ref,
    Activity? activity,
  ) {
    return [
      if (activity != null)
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Share Card',
          onPressed: () =>
              unawaited(WorkoutShareDialog.show(context, activity: activity)),
        ),
      if (activity != null)
        PopupMenuButton<ActivityExportFormat>(
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Export',
          onSelected: (format) => unawaited(_export(context, ref, format)),
          itemBuilder: (menuContext) => const [
            PopupMenuItem(
              value: ActivityExportFormat.gpx,
              child: Text('GPX file'),
            ),
            PopupMenuItem(
              value: ActivityExportFormat.tcx,
              child: Text('TCX file'),
            ),
          ],
        ),
      IconButton(
        icon: const Icon(Icons.edit_outlined),
        tooltip: 'Edit',
        onPressed: () => ActivityDetailEditRouteData(activityId).go(context),
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete',
        onPressed: () => _confirmAndDelete(context, ref),
      ),
    ];
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ActivityExportFormat format,
  ) async {
    final outcome = await ref
        .read(activityExportControllerProvider.notifier)
        .export(activityId: activityId, format: format);
    if (!context.mounted) return;

    final text = switch (outcome) {
      ActivityExportCancelled() => null,
      ActivityExportSaved(:final filename) => 'Saved $filename',
      ActivityExportUnavailable(:final message) => message,
      ActivityExportFailed(:final error) => userMessageFor(error),
    };
    if (text == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this activity?'),
        content: const Text(
          'This removes it from your history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(activityDetailControllerProvider(activityId).notifier)
          .delete();
      if (!context.mounted) return;
      const ActivityRouteData().go(context);
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(userMessageFor(error)),
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }
}

class _ActivityDetailBody extends ConsumerWidget {
  const _ActivityDetailBody({required this.activity, required this.unitSystem});

  final Activity activity;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        Text(activity.title, style: textTheme.headlineSmall),
        SizedBox(height: tokens.spacingXs),
        Text(
          DateFormat.yMMMd().add_jm().format(activity.startedAt.toLocal()),
          style: textTheme.bodyMedium,
        ),
        if (activity.routeId != null) ...[
          SizedBox(height: tokens.spacingSm),
          _RouteChip(routeId: activity.routeId!),
        ],
        SizedBox(height: tokens.spacingLg),
        _StatsGrid(activity: activity, unitSystem: unitSystem),
        if (activity.workoutDetails != null) ...[
          SizedBox(height: tokens.spacingLg),
          _WorkoutDetailsSection(
            workoutDetails: activity.workoutDetails!,
            unitSystem: unitSystem,
          ),
        ],
        _EnergyEstimateSection(activity: activity),
        if (activity.notes != null && activity.notes!.isNotEmpty) ...[
          SizedBox(height: tokens.spacingLg),
          Text('Notes', style: textTheme.titleMedium),
          SizedBox(height: tokens.spacingSm),
          Text(activity.notes!, style: textTheme.bodyLarge),
        ],
        if (activity.source == ActivitySource.recorded &&
            (activity.activityType == ActivityType.run ||
                activity.activityType == ActivityType.walk ||
                activity.activityType == ActivityType.hike ||
                activity.activityType == ActivityType.ride ||
                activity.workoutDetails == null)) ...[
          SizedBox(height: tokens.spacingLg),
          Text('Route', style: textTheme.titleMedium),
          SizedBox(height: tokens.spacingSm),
          _RouteSection(activityId: activity.id),
          SizedBox(height: tokens.spacingLg),
          SplitsSection(activityId: activity.id, unitSystem: unitSystem),
        ],
      ],
    );
  }
}

/// Renders structured workout details according to the specific workout type.
class _WorkoutDetailsSection extends StatelessWidget {
  const _WorkoutDetailsSection({
    required this.workoutDetails,
    required this.unitSystem,
  });

  final WorkoutDetails workoutDetails;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return switch (workoutDetails) {
      final StrengthWorkoutDetails details => _buildStrengthDetails(
        context,
        details,
        tokens,
      ),
      final HiitWorkoutDetails details => _buildHiitDetails(
        context,
        details,
        tokens,
      ),
      final MindfulWorkoutDetails details => _buildMindfulDetails(
        context,
        details,
        tokens,
      ),
      final SwimWorkoutDetails details => _buildSwimDetails(
        context,
        details,
        tokens,
      ),
      final WearableWorkoutDetails details => _buildWearableDetails(
        context,
        details,
        tokens,
      ),
      GeneralWorkoutDetails _ => const SizedBox.shrink(),
    };
  }

  Widget _buildWearableDetails(
    BuildContext context,
    WearableWorkoutDetails details,
    AppTokens tokens,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wearable Device Sync', style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            Expanded(
              child: _DetailStatCard(
                label: 'SOURCE',
                value: details.wearableSource,
              ),
            ),
            if (details.cyclePhase != null) ...[
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: _DetailStatCard(
                  label: 'CYCLE PHASE',
                  value: details.cyclePhase!,
                ),
              ),
            ],
            if (details.avgCadence != null) ...[
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: _DetailStatCard(
                  label: 'AVG CADENCE',
                  value: '${details.avgCadence} spm',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStrengthDetails(
    BuildContext context,
    StrengthWorkoutDetails details,
    AppTokens tokens,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Strength Breakdown', style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            Expanded(
              child: _DetailStatCard(
                label: 'TOTAL VOLUME',
                value: '${details.totalVolumeKg.toStringAsFixed(0)} kg',
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: _DetailStatCard(
                label: 'TOTAL SETS',
                value: '${details.totalSets}',
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: _DetailStatCard(
                label: 'TOTAL REPS',
                value: '${details.totalReps}',
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingMd),
        ...details.exercises.map((exercise) {
          return Card(
            margin: EdgeInsets.only(bottom: tokens.spacingSm),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...exercise.sets.map((set) {
                    final weightStr = set.weightKg.toStringAsFixed(
                      set.weightKg.truncateToDouble() == set.weightKg ? 0 : 1,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${set.setNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$weightStr kg × ${set.reps} reps'),
                          const Spacer(),
                          if (set.durationSeconds > 0)
                            Text(
                              '⏱ ${set.durationSeconds}s',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  static Widget _buildHiitDetails(
    BuildContext context,
    HiitWorkoutDetails details,
    AppTokens tokens,
  ) {
    final theme = Theme.of(context);
    final workMin = details.totalWorkTimeSeconds ~/ 60;
    final workSec = details.totalWorkTimeSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interval Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DetailStatCard(
                label: 'ROUNDS',
                value: '${details.completedRounds} / ${details.totalRounds}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailStatCard(
                label: 'WORK:REST',
                value: '${details.workSeconds}s : ${details.restSeconds}s',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailStatCard(
                label: 'TOTAL WORK',
                value: '${workMin}m ${workSec}s',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMindfulDetails(
    BuildContext context,
    MindfulWorkoutDetails details,
    AppTokens tokens,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mindful Details', style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            Expanded(
              // A sequence practice may carry no style / focus area; show
              // an em dash rather than a blank card (same rule as RPE).
              child: _DetailStatCard(
                label: 'STYLE',
                value: details.style.isEmpty ? '—' : details.style,
              ),
            ),
            ...[
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: _DetailStatCard(
                  label: 'FOCUS AREA',
                  value: details.focusArea.isEmpty ? '—' : details.focusArea,
                ),
              ),
            ],
            // An unanswered RPE shows an em dash, never a fabricated
            // number — `MindfulWorkoutDetails.rpe`.
            ...[
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: _DetailStatCard(
                  label: 'RPE EXERTION',
                  value: details.rpe == null ? '—' : '${details.rpe} / 10',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSwimDetails(
    BuildContext context,
    SwimWorkoutDetails details,
    AppTokens tokens,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Swim Breakdown', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            Expanded(
              child: _DetailStatCard(
                label: 'LAPS',
                value: '${details.laps}',
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: _DetailStatCard(
                label: 'POOL LENGTH',
                value: '${details.poolLengthMeters.toStringAsFixed(0)} m',
              ),
            ),
            ...[
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: _DetailStatCard(
                  label: 'STROKE',
                  value: details.stroke,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  const _DetailStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the opt-in workout energy expenditure estimate card, compliant
/// with `knowledge/research/energy_expenditure_estimates.md`.
class _EnergyEstimateSection extends ConsumerWidget {
  const _EnergyEstimateSection({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showEstimates = ref.watch(activityEnergyEstimatesControllerProvider);
    if (!showEstimates) return const SizedBox.shrink();

    final goals = ref.watch(nutritionGoalsControllerProvider).value;
    if (goals?.hideCalorieNumbers == true) return const SizedBox.shrink();

    final profile = ref.watch(profileControllerProvider).value;
    if (profile == null) return const SizedBox.shrink();

    final outcome = estimateActivityEnergy(
      activity: activity,
      profile: profile,
      referenceDate: activity.startedAt,
    );

    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(top: tokens.spacingLg),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated energy used',
                style: textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: tokens.spacingXs),
              switch (outcome) {
                ActivityEnergyEstimate(:final rangeLabel) => Text(
                  rangeLabel,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                NoActivityEnergyBasis(:final reason) => Text(
                  reason,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              },
              SizedBox(height: tokens.spacingXs),
              Text(
                activityEnergyDisclaimer,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Links an activity back to the saved route it followed. Renders nothing
/// while the name loads — or forever, if the route was deleted since (the
/// activity keeps its `routeId`, but there's nothing left to link to).
class _RouteChip extends ConsumerWidget {
  const _RouteChip({required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeByIdProvider(routeId)).value;
    if (route == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: ActionChip(
        avatar: const Icon(Icons.route_outlined, size: 18),
        label: Text('Route: ${route.name}'),
        onPressed: () => RouteDetailRouteData(routeId).go(context),
      ),
    );
  }
}

/// The route-map area of a `recorded` activity's detail screen: a
/// same-height placeholder while samples load, a "No route data" message
/// for a recording with zero GPS points, or the actual [RouteMap].
///
/// All three states render at the same [routeMapHeight] so switching
/// between them (e.g. loading -> data) never shifts the rest of the page.
class _RouteSection extends ConsumerWidget {
  const _RouteSection({required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsync = ref.watch(activitySamplesProvider(activityId));

    return samplesAsync.when(
      data: (samples) => samples.isEmpty
          ? const _RouteMessagePlaceholder(message: 'No route data')
          : RouteMap(samples: samples),
      loading: () => const _RouteMessagePlaceholder(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _RouteMessagePlaceholder(
        message: userMessageFor(error),
      ),
    );
  }
}

/// A fixed-height, same-size-as-[RouteMap] box used for the route section's
/// loading and empty/error states.
class _RouteMessagePlaceholder extends StatelessWidget {
  const _RouteMessagePlaceholder({this.message, this.child});

  final String? message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: routeMapHeight(constraints.maxWidth),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          child:
              child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Text(
                    message ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.activity, required this.unitSystem});

  final Activity activity;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    final isDistanceRelevant =
        activity.distanceMeters > 0 ||
        activity.activityType == ActivityType.run ||
        activity.activityType == ActivityType.walk ||
        activity.activityType == ActivityType.hike ||
        activity.activityType == ActivityType.ride ||
        activity.activityType == ActivityType.swim;

    final stats = <_Stat>[
      if (isDistanceRelevant)
        _Stat('Distance', formatDistance(activity.distanceMeters, unitSystem)),
      _Stat('Moving time', formatDuration(activity.movingTime)),
      if (isDistanceRelevant && (activity.avgPaceSecondsPerKm ?? 0) > 0)
        _Stat('Pace', formatPace(activity.avgPaceSecondsPerKm, unitSystem)),
      if (activity.elapsedTime != activity.movingTime)
        _Stat('Elapsed time', formatDuration(activity.elapsedTime)),
      if (activity.elevationGainMeters != null)
        _Stat(
          'Elevation gain',
          '${activity.elevationGainMeters!.toStringAsFixed(0)} m',
        ),
      if (activity.avgHeartRate != null)
        _Stat('Avg heart rate', '${activity.avgHeartRate} bpm'),
    ];

    return Wrap(
      spacing: tokens.spacingLg,
      runSpacing: tokens.spacingMd,
      children: [
        for (final stat in stats)
          SizedBox(
            width: 140,
            child: _StatTile(key: ValueKey(stat.label), stat: stat),
          ),
      ],
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required super.key, required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(stat.value, style: textTheme.titleLarge?.tabularFigures),
      ],
    );
  }
}

/// One app-bar action, so the same list can be rendered either as icon
/// buttons or as rows in an overflow menu.
