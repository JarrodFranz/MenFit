import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/strength/start_strength_cycle.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_card.dart';

/// The first card on Home: what to lift today.
///
/// MenFit is strength-first, so the dashboard opens on the active training
/// cycle rather than on a step count. The card reads
/// [activeStrengthCycleProvider] and does one of two things:
///
/// * no active cycle — says so and sends the user to the Strength hub to
///   pick one ([ExerciseHubRouteData] with `type: 'strength'`);
/// * an active cycle — names it, counts the day the way the Strength Hub
///   counts it, and starts that day's routine.
///
/// The start path is [startActiveStrengthCycle], shared with the Strength
/// Hub and the Train tab so all three prime
/// `strengthTrackerControllerProvider` before pushing
/// [StrengthTrackerRouteData] — pushing the route alone would open the
/// tracker with whatever session was last in the controller.
///
/// Loading renders the card chrome only — a dashboard card that vanishes
/// and reappears makes the whole column jump. **Error renders the no-cycle
/// state**, not an empty card: if the routine repository fails there is
/// still exactly one useful thing to offer, and a card that shows a title
/// over blank space is a dead end the user cannot act on or diagnose.
class TodaySessionCard extends ConsumerWidget {
  const TodaySessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleAsync = ref.watch(activeStrengthCycleProvider);

    return HomeCard(
      icon: Icons.fitness_center,
      title: "Today's session",
      child: cycleAsync.when(
        data: (cycle) =>
            cycle == null ? const _NoCycle() : _ActiveCycle(cycle: cycle),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const _NoCycle(),
      ),
    );
  }
}

/// Nothing running: point at the Strength hub, where cycles are picked.
class _NoCycle extends StatelessWidget {
  const _NoCycle();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('No routine running', style: textTheme.bodyMedium),
        SizedBox(height: tokens.spacingSm),
        FilledButton(
          onPressed: () =>
              const ExerciseHubRouteData(type: 'strength').go(context),
          child: const Text('Start a routine'),
        ),
      ],
    );
  }
}

/// A cycle is active: name it, say which day is next, and start it.
class _ActiveCycle extends ConsumerWidget {
  const _ActiveCycle({required this.cycle});

  final StrengthCycle cycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final nextDay = cycle.nextRoutine;
    final totalDays = cycle.routines.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          cycle.name,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (totalDays > 0)
          Text(
            'Day ${cycle.currentDayIndex % totalDays + 1} of $totalDays',
            style: textTheme.bodySmall,
          ),
        if (nextDay != null)
          Text(
            'Next up: ${nextDay.name}',
            style: textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: tokens.spacingSm),
        FilledButton(
          onPressed: nextDay == null
              ? null
              : () => startActiveStrengthCycle(ref, context, cycle),
          child: const Text('Start workout'),
        ),
      ],
    );
  }
}
