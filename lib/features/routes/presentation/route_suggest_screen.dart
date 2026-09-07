import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/routes/domain/elevation_format.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_suggestion_service.dart';
import 'package:menfit_app/features/routes/domain/suggested_route.dart';
import 'package:menfit_app/features/routes/presentation/route_suggest_controller.dart';
import 'package:menfit_app/features/routes/presentation/widgets/location_search_dialog.dart';
import 'package:menfit_app/features/routes/presentation/widgets/route_name_dialog.dart';
import 'package:menfit_app/features/routes/presentation/widgets/start_point_dialog.dart';
import 'package:menfit_app/features/routes/presentation/widgets/suggest_map.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

/// The "I want to run X km — show me routes" flow
/// (`/activity/routes/suggest`): distance + type + start point in, up to
/// three round-trip suggestions out, saved only on explicit request.
class RouteSuggestScreen extends ConsumerStatefulWidget {
  const RouteSuggestScreen({
    this.initialActivityType,
    this.initialDistance,
    this.initialStartPoint,
    this.initialStartAddress,
    super.key,
  });

  final ActivityType? initialActivityType;
  final String? initialDistance;
  final GeoPoint? initialStartPoint;
  final String? initialStartAddress;

  @override
  ConsumerState<RouteSuggestScreen> createState() => _RouteSuggestScreenState();
}

class _RouteSuggestScreenState extends ConsumerState<RouteSuggestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(routeSuggestControllerProvider.notifier)
          .initParams(
            activityType: widget.initialActivityType,
            distance: widget.initialDistance,
            startPoint: widget.initialStartPoint,
            startAddress: widget.initialStartAddress,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final configured = ref.watch(routeSuggestionsConfiguredProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Suggest a route')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: configured ? const _SuggestFlow() : const _SetupCard(),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the flow when the build has no OpenRouteService key.
class _SetupCard extends StatelessWidget {
  const _SetupCard();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.all(tokens.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: tokens.spacingMd),
          Text(
            "Route suggestions aren't switched on yet",
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Switching them on is a one-off setup step for whoever set this '
            "app up for you — there's nothing you need to do here. Routes "
            'you have already saved still work as usual.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _SuggestFlow extends ConsumerWidget {
  const _SuggestFlow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(routeSuggestControllerProvider);
    final controller = ref.read(routeSuggestControllerProvider.notifier);
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final capabilities = ref.read(locationAdapterProvider).capabilities;
    final isLoading = state.phase == SuggestPhase.loading;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingLg),
      children: [
        // 1. Activity Type
        Text('Type', style: textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        SegmentedButton<ActivityType>(
          segments: const [
            ButtonSegment(value: ActivityType.run, label: Text('Run')),
            ButtonSegment(value: ActivityType.walk, label: Text('Walk')),
            ButtonSegment(value: ActivityType.hike, label: Text('Hike')),
            ButtonSegment(value: ActivityType.ride, label: Text('Ride')),
          ],
          selected: {state.activityType},
          onSelectionChanged: (selection) =>
              controller.updateActivityType(selection.first),
        ),

        SizedBox(height: tokens.spacingMd),

        // 2. Route Style
        Text('Style', style: textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        SegmentedButton<RouteShapePreference>(
          segments: const [
            ButtonSegment(
              value: RouteShapePreference.loop,
              label: Text('Loop'),
              icon: Icon(Icons.refresh, size: 16),
            ),
            ButtonSegment(
              value: RouteShapePreference.outAndBack,
              label: Text('Out & Back'),
              icon: Icon(Icons.sync_alt, size: 16),
            ),
            ButtonSegment(
              value: RouteShapePreference.any,
              label: Text('Any'),
            ),
          ],
          selected: {state.shapePreference},
          onSelectionChanged: (selection) =>
              controller.updateShapePreference(selection.first),
        ),

        SizedBox(height: tokens.spacingMd),

        // 3. Distance Input
        Text('Distance', style: textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Distance',
            suffixText: unitSystem == UnitSystem.imperial ? 'mi' : 'km',
            border: const OutlineInputBorder(),
            errorText: state.distanceError,
          ),
          onChanged: controller.updateDistanceInput,
        ),

        SizedBox(height: tokens.spacingMd),

        // 4. Starting Point
        Text('Start point', style: textTheme.titleMedium),
        SizedBox(height: tokens.spacingXs),
        Text(
          'Tap the map to drop your start point. Suggested loops start and '
          'end there.',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.spacingXs),
        const _RoutingDisclosure(),
        SizedBox(height: tokens.spacingSm),

        SuggestMap(
          start: state.start,
          startLabel: state.startAddress,
          polyline: state.selected?.points,
          onTap: controller.setStart,
          onMyLocation: capabilities.canGetCurrentPosition
              ? controller.useMyLocation
              : null,
          isLocating: state.isLocating,
        ),

        if (state.startError != null) ...[
          SizedBox(height: tokens.spacingSm),
          _ErrorText(state.startError!),
        ],

        SizedBox(height: tokens.spacingSm),

        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            if (capabilities.canGetCurrentPosition)
              OutlinedButton.icon(
                onPressed: state.isLocating ? null : controller.useMyLocation,
                icon: state.isLocating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  state.isLocating ? 'Locating…' : 'Use my location',
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => _searchLocation(context, ref),
              icon: const Icon(Icons.search),
              label: const Text('Search location'),
            ),
            OutlinedButton.icon(
              onPressed: () => _enterCoordinates(context, ref, state),
              icon: const Icon(Icons.edit_location_alt_outlined),
              label: const Text('Enter coordinates'),
            ),
          ],
        ),

        if (!capabilities.canGetCurrentPosition &&
            capabilities.currentPositionReason != null) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            capabilities.currentPositionReason!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        if (state.locationError != null) ...[
          SizedBox(height: tokens.spacingSm),
          _ErrorText(state.locationError!),
        ],

        SizedBox(height: tokens.spacingLg),

        // Find Routes Action Button
        FilledButton.icon(
          onPressed: isLoading ? null : () => controller.findRoutes(unitSystem),
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.route_outlined),
          label: Text(isLoading ? 'Finding routes…' : 'Find routes'),
        ),

        if (state.phase == SuggestPhase.error && state.error != null) ...[
          SizedBox(height: tokens.spacingLg),
          _ErrorCard(
            message: state.error!,
            onRetry: () => controller.findRoutes(unitSystem),
          ),
        ],

        // 5. Suggestions List
        if (state.phase == SuggestPhase.loaded) ...[
          SizedBox(height: tokens.spacingLg),
          Text('Suggestions', style: textTheme.titleMedium),
          SizedBox(height: tokens.spacingSm),
          for (var i = 0; i < state.suggestions.length; i++)
            _SuggestionCard(
              key: ValueKey('suggestion-$i'),
              index: i,
              suggestion: state.suggestions[i],
              selected: i == state.selectedIndex,
              unitSystem: unitSystem,
              onTap: () => controller.select(i),
            ),
          SizedBox(height: tokens.spacingMd),
          if (state.saveError != null) ...[
            _ErrorText(state.saveError!),
            SizedBox(height: tokens.spacingSm),
          ],
          _SelectionActions(state: state, unitSystem: unitSystem),
        ],
      ],
    );
  }

  Future<void> _searchLocation(BuildContext context, WidgetRef ref) async {
    final state = ref.read(routeSuggestControllerProvider);
    final result = await showLocationSearchDialog(
      context,
      proximity: state.start,
    );
    if (result == null) return;
    ref
        .read(routeSuggestControllerProvider.notifier)
        .selectSearchResult(result);
  }

  Future<void> _enterCoordinates(
    BuildContext context,
    WidgetRef ref,
    RouteSuggestState state,
  ) async {
    final point = await showStartPointDialog(context, initial: state.start);
    if (point == null) return;
    ref.read(routeSuggestControllerProvider.notifier).setStart(point);
  }
}

/// Tells the user, before she picks a start point, that the start point
/// leaves the device.
///
/// ADR 009 commits to this: the suggest flow is the app's first feature
/// that sends location off-device, so the disclosure has to be here, in
/// plain words, at the moment of the choice — not buried in a policy
/// document. Names no vendor (that's ours to swap, not hers to reason
/// about) and states the two facts that actually bound the exposure: only
/// the start point goes, and nothing is kept unless she saves the route.
class _RoutingDisclosure extends StatelessWidget {
  const _RoutingDisclosure();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: tokens.spacingXs),
        Expanded(
          child: Text(
            'To work out the loops, we send your start point — and nothing '
            'else about you — to an online route-planning service. It is '
            "not stored anywhere unless you save one of the routes we're "
            'given.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required super.key,
    required this.index,
    required this.suggestion,
    required this.selected,
    required this.unitSystem,
    required this.onTap,
  });

  final int index;
  final SuggestedRoute suggestion;
  final bool selected;
  final UnitSystem unitSystem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final parts = [
      formatDistance(suggestion.distanceMeters, unitSystem),
      if (suggestion.estimatedDuration != null)
        '~${formatDuration(suggestion.estimatedDuration!)}',
      if (suggestion.ascentMeters != null)
        '↑ ${formatElevation(suggestion.ascentMeters!, unitSystem)}',
    ];

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacingSm),
      shape: themedCardShape(
        context,
        radius: tokens.radiusMd,
        side: selected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        selected: selected,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        ),
        title: Text('Option ${index + 1}'),
        subtitle: Text(parts.join(' · ')),
        onTap: onTap,
      ),
    );
  }
}

class _SelectionActions extends ConsumerWidget {
  const _SelectionActions({required this.state, required this.unitSystem});

  final RouteSuggestState state;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final canRecord = ref
        .read(locationAdapterProvider)
        .capabilities
        .canRecordActivities;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: state.isSaving
                ? null
                : () => _saveWithNameDialog(context, ref),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save route'),
          ),
        ),
        if (canRecord) ...[
          SizedBox(width: tokens.spacingMd),
          Expanded(
            child: FilledButton.icon(
              onPressed: state.isSaving
                  ? null
                  : () => _saveAndStart(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start now'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveWithNameDialog(BuildContext context, WidgetRef ref) async {
    final suggestion = state.selected;
    if (suggestion == null) return;

    final name = await showRouteNameDialog(
      context,
      title: 'Save route',
      initialName: defaultRouteName(suggestion, state.activityType, unitSystem),
    );
    if (name == null || !context.mounted) return;

    final routeId = await ref
        .read(routeSuggestControllerProvider.notifier)
        .saveSelected(name: name, unitSystem: unitSystem);
    if (routeId != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Route saved'),
            duration: Duration(seconds: 3),
          ),
        );
    }
  }

  /// "Start now" = save under the default name, then hand the route to the
  /// record flow (mobile-only; gated by the caller on
  /// `canRecordActivities`).
  Future<void> _saveAndStart(BuildContext context, WidgetRef ref) async {
    final routeId = await ref
        .read(routeSuggestControllerProvider.notifier)
        .saveSelected(name: '', unitSystem: unitSystem);
    if (routeId != null && context.mounted) {
      ActivityRecordRouteData(routeId: routeId).go(context);
    }
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
