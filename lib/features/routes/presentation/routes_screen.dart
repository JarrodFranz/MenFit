import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_screen.g.dart';

/// The saved-routes list for this screen — a thin stream over the
/// repository's non-deleted routes, newest first.
@riverpod
Stream<List<SavedRoute>> routesList(Ref ref) =>
    ref.watch(routeRepositoryProvider).watchRoutes();

/// The saved-routes screen (`/activity/routes`): saved routes (tap for
/// detail) plus the entry point into the suggest flow.
class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final routesAsync = ref.watch(routesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routes')),
      body: SafeArea(
        // Same content-width cap as every other content surface (see
        // `route_suggest_screen.dart`) - without it the list runs
        // edge-to-edge on desktop/web.
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: routesAsync.when(
              data: (routes) => routes.isEmpty
                  ? const _EmptyState()
                  : _RoutesList(routes: routes),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(userMessageFor(error))),
            ),
          ),
        ),
      ),
      // Only shown once there's a list - the empty state carries its own
      // call to action (same convention as `activity_screen.dart`).
      floatingActionButton: (routesAsync.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => const RouteSuggestRouteData().go(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Suggest a route'),
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              'No saved routes yet. Tell us how far you want to go and '
              "we'll suggest some loops.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: tokens.spacingLg),
            FilledButton.icon(
              onPressed: () => const RouteSuggestRouteData().go(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Suggest a route'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutesList extends ConsumerWidget {
  const _RoutesList({required this.routes});

  final List<SavedRoute> routes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        tokens.spacingMd,
        tokens.spacingMd,
        tokens.spacingMd,
        // Extra bottom padding so the last tile isn't hidden behind the
        // FAB.
        tokens.spacingMd + 72,
      ),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          key: ValueKey(route.id),
          margin: EdgeInsets.only(bottom: tokens.spacingSm),
          child: ListTile(
            leading: Icon(_iconFor(route.activityType)),
            title: Text(route.name),
            subtitle: Text(
              formatDistance(route.distanceMeters, unitSystem),
            ),
            onTap: () => RouteDetailRouteData(route.id).go(context),
          ),
        );
      },
    );
  }
}

/// Maps an [ActivityType] to its display icon (duplicated from
/// `activity_screen.dart`'s private helper — cross-feature presentation
/// imports are barred by ADR 007, and domain code can't hold [IconData]).
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
