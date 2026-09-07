import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';

/// Starts the next day of [cycle] and opens the strength tracker on it.
///
/// Three places offer "start today's workout" — the Home dashboard's
/// `TodaySessionCard`, the Strength Hub's active-cycle card, and the Train
/// tab's primary action — and all three must do the *same two things* in
/// the same order: prime [strengthTrackerControllerProvider] with the
/// routine and the cycle id, then push [StrengthTrackerRouteData]. Pushing
/// the route on its own opens the tracker on whatever session the
/// controller was last left holding, which is how a "start" button ends up
/// resuming yesterday's workout.
///
/// Returns without navigating when the cycle has no next routine (an empty
/// cycle); callers offer "Start a routine" instead in that case.
Future<void> startActiveStrengthCycle(
  WidgetRef ref,
  BuildContext context,
  StrengthCycle cycle,
) async {
  final routine = cycle.nextRoutine;
  if (routine == null) return;
  await ref
      .read(strengthTrackerControllerProvider.notifier)
      .startWorkout(routine: routine, cycleId: cycle.id);
  if (context.mounted) {
    unawaited(const StrengthTrackerRouteData().push<void>(context));
  }
}
