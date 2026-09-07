import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/presentation/strength/start_strength_cycle.dart';

/// The Train tab's action block: one strength primary action, with the GPS
/// and manual-entry launchers demoted underneath it.
///
/// MenFit is strength-first, so the tab's filled button is the lift — the
/// active cycle's next day when there is one, otherwise a trip to the
/// Strength hub to pick a routine. GPS recording stays a visible secondary
/// action rather than the headline it was in the forked-from app, where
/// `Record` was the only [FilledButton] on the screen.
///
/// The secondary pair uses plain [OutlinedButton]s rather than
/// `.icon` variants: an icon button lays its label out in an unflexible
/// row, and "Record GPS activity" overflows a half-width slot at 320dp with
/// 150% text. Without the icon the label wraps instead.
class ActivityPrimaryActions extends ConsumerWidget {
  const ActivityPrimaryActions({required this.capabilities, super.key});

  final LocationCapabilities capabilities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    // Loading and error both collapse to "no cycle" on purpose: while the
    // stream is warming up, or if the routine repository fails, the tab
    // still offers "Start a routine" rather than a dead or missing button.
    final cycle = ref
        .watch(activeStrengthCycleProvider)
        .when(data: (c) => c, loading: () => null, error: (_, _) => null);
    final hasSession = cycle != null && cycle.nextRoutine != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: hasSession
              ? () => startActiveStrengthCycle(ref, context, cycle)
              : () => const ExerciseHubRouteData(type: 'strength').go(context),
          icon: const Icon(Icons.fitness_center),
          label: Text(hasSession ? 'Start workout' : 'Start a routine'),
        ),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            if (capabilities.canRecordActivities) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => const ActivityRecordRouteData().go(context),
                  child: const Text(
                    'Record GPS activity',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => const ActivityLogRouteData().go(context),
                  child: const Text(
                    'Log Previous',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => const ActivityLogRouteData().go(context),
                  child: const Text(
                    'Log activity',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => const ActivityRoutesRouteData().go(context),
                  child: const Text('Routes', textAlign: TextAlign.center),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
