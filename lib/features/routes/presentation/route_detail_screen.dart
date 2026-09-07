import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/routes/domain/elevation_format.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/presentation/widgets/route_name_dialog.dart';
import 'package:menfit_app/features/routes/presentation/widgets/route_offline_card.dart';
import 'package:menfit_app/features/routes/presentation/widgets/route_polyline_map.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

/// Detail view for a saved route (`/activity/routes/:routeId`): map,
/// stats, start-an-activity, rename, delete.
class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({required this.routeId, super.key});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final routeAsync = ref.watch(routeByIdProvider(routeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: routeAsync.value == null
                ? null
                : () => _rename(context, ref, routeAsync.value!),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmAndDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        // Same content-width cap as every other content surface (see
        // `route_suggest_screen.dart`) - without it the map and stats run
        // edge-to-edge on desktop/web.
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: routeAsync.when(
              data: (route) => route == null
                  ? const Center(child: Text('This route was deleted.'))
                  : _RouteDetailBody(route: route),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(userMessageFor(error))),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    SavedRoute route,
  ) async {
    final name = await showRouteNameDialog(
      context,
      title: 'Rename route',
      initialName: route.name,
    );
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == route.name) return;

    try {
      await ref
          .read(routeRepositoryProvider)
          .saveRoute(route.copyWith(name: trimmed));
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

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this route?'),
        content: const Text(
          'This removes it from your saved routes. Activities you recorded '
          'along it are kept.',
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
      await ref.read(routeRepositoryProvider).deleteRoute(routeId);
      if (!context.mounted) return;
      const ActivityRoutesRouteData().go(context);
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

class _RouteDetailBody extends ConsumerWidget {
  const _RouteDetailBody({required this.route});

  final SavedRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    // Capabilities don't change at runtime - a plain `read`, not `watch`.
    final capabilities = ref.read(locationAdapterProvider).capabilities;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        Text(route.name, style: textTheme.headlineSmall),
        SizedBox(height: tokens.spacingLg),
        if (route.points.isNotEmpty) RoutePolylineMap(points: route.points),
        SizedBox(height: tokens.spacingLg),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Distance',
                value: formatDistance(route.distanceMeters, unitSystem),
              ),
            ),
            if (route.estimatedDuration != null)
              Expanded(
                child: _Stat(
                  label: 'Est. time',
                  value: formatDuration(route.estimatedDuration!),
                ),
              ),
            if (route.ascentMeters != null)
              Expanded(
                child: _Stat(
                  label: 'Ascent',
                  value: formatElevation(route.ascentMeters!, unitSystem),
                ),
              ),
          ],
        ),
        SizedBox(height: tokens.spacingLg),
        RouteOfflineCard(route: route),
        SizedBox(height: tokens.spacingXl),
        if (capabilities.canRecordActivities)
          FilledButton.icon(
            onPressed: () =>
                ActivityRecordRouteData(routeId: route.id).go(context),
            icon: const Icon(Icons.play_arrow),
            label: Text('Start ${route.activityType.label.toLowerCase()}'),
          )
        else if (capabilities.reason != null)
          Text(
            capabilities.reason!,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: textTheme.titleLarge?.tabularFigures),
      ],
    );
  }
}
