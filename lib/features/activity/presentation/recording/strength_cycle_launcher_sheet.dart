import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/strength/strength_routine_editor_sheet.dart';

/// Modal bottom sheet allowing users to launch a strength training session:
/// 1. Start or resume an active cycle's next scheduled day.
/// 2. Pick any specific day routine from the active cycle.
/// 3. Start a standalone saved day routine.
/// 4. Start an ad-hoc quick strength workout (clean slate).
/// 5. Create, view, and edit custom cycles and day routines without starting.
class StrengthCycleLauncherSheet extends ConsumerStatefulWidget {
  const StrengthCycleLauncherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => const StrengthCycleLauncherSheet(),
    );
  }

  @override
  ConsumerState<StrengthCycleLauncherSheet> createState() =>
      _StrengthCycleLauncherSheetState();
}

class _StrengthCycleLauncherSheetState
    extends ConsumerState<StrengthCycleLauncherSheet> {
  bool _didSeedStarters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _seedStarterCyclesIfNeeded(),
    );
  }

  Future<void> _seedStarterCyclesIfNeeded() async {
    if (_didSeedStarters || !mounted) return;
    _didSeedStarters = true;
    final repo = ref.read(strengthRoutineRepositoryProvider);
    final cycles = await repo.getCycles();
    if (cycles.isEmpty) {
      for (final starter in StrengthCycleStarters.starterCycles) {
        await repo.saveCycle(starter);
      }
      // Set the first starter cycle as active by default
      if (StrengthCycleStarters.starterCycles.isNotEmpty) {
        await repo.setActiveCycle(
          StrengthCycleStarters.starterCycles.first.id,
        );
      }
    }
  }

  void _startWorkout({
    StrengthDayRoutine? routine,
    String? cycleId,
  }) {
    Navigator.of(context).pop(); // Close launcher sheet
    unawaited(
      ref
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkout(
            routine: routine,
            cycleId: cycleId,
          ),
    );
    unawaited(const StrengthTrackerRouteData().push<void>(context));
  }

  void _resumeWorkout() {
    Navigator.of(context).pop();
    unawaited(const StrengthTrackerRouteData().push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final strengthState = ref.watch(strengthTrackerControllerProvider);

    final cyclesAsync = ref.watch(strengthCyclesProvider);
    final routinesAsync = ref.watch(strengthRoutinesProvider);
    final activeCycleAsync = ref.watch(activeStrengthCycleProvider);

    final cycles = cyclesAsync.value ?? const [];
    final routines = routinesAsync.value ?? const [];
    final activeCycle = activeCycleAsync.value;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Strength Training',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Follow a structured multi-day cycle, load a saved routine, '
                'or start an ad-hoc workout.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // 1. In-progress live workout prompt
              if (strengthState.isActive) ...[
                Container(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                      SizedBox(width: tokens.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout In Progress',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${strengthState.exercises.length} exercises · '
                              '${strengthState.totalCompletedSets} sets '
                              'completed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: _resumeWorkout,
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Active Cycle Hero Card
              if (activeCycle != null && activeCycle.routines.isNotEmpty) ...[
                _buildActiveCycleCard(context, activeCycle),
                const SizedBox(height: 16),
              ],

              // 3. Quick Start Ad-Hoc Workout
              Card(
                shape: themedCardShape(
                  context,
                  radius: tokens.radiusMd,
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: const Text(
                    'Ad-Hoc Quick Workout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Start empty and add exercises freely as you go.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _startWorkout,
                ),
              ),
              const SizedBox(height: 16),

              // 4. Training Cycles List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Training Cycles',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Cycle'),
                    onPressed: () => StrengthCycleEditorSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (cycles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No cycles created yet.'),
                )
              else
                ...cycles.map(
                  (c) => _buildCycleTile(context, c, c.id == activeCycle?.id),
                ),

              const SizedBox(height: 16),

              // 5. Standalone Day Routines List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Saved Day Routines',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Routine'),
                    onPressed: () => StrengthRoutineEditorSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (routines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No saved routines yet. Save any workout or create one '
                    'here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...routines.map((r) => _buildRoutineTile(context, r)),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveCycleCard(BuildContext context, StrengthCycle cycle) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final nextRoutine = cycle.nextRoutine;
    final dayNumber = (cycle.currentDayIndex % cycle.routines.length) + 1;

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ACTIVE CYCLE · ${cycle.name.toUpperCase()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit Cycle Details & Routines',
                onPressed: () =>
                    StrengthCycleEditorSheet.show(context, cycle: cycle),
              ),
              Text(
                '${cycle.totalSessionsCompleted} completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (nextRoutine != null) ...[
            Text(
              nextRoutine.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${nextRoutine.exercises.length} exercises · '
              '~${nextRoutine.estimatedDurationMinutes} min',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text('Start Day $dayNumber: ${nextRoutine.name}'),
              onPressed: () => _startWorkout(
                routine: nextRoutine,
                cycleId: cycle.id,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Or pick a specific day in this cycle:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (var i = 0; i < cycle.routines.length; i++)
                  ActionChip(
                    avatar: Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    label: Text(cycle.routines[i].name),
                    onPressed: () => _startWorkout(
                      routine: cycle.routines[i],
                      cycleId: cycle.id,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCycleTile(
    BuildContext context,
    StrengthCycle cycle,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isActive ? Icons.check_circle : Icons.fitness_center_outlined,
          color: isActive ? theme.colorScheme.primary : null,
        ),
        title: Text(
          cycle.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // "Tap to edit" replaces the trailing edit icon button removed
        // below — the tile's own `onTap` is the only way in now, so the
        // affordance has to be named somewhere a screen reader announces.
        subtitle: Text(
          '${cycle.routines.length} day routines · '
          '${cycle.totalSessionsCompleted} sessions done · Tap to edit',
        ),
        // Only the primary action (Start / Set Active) stays trailing —
        // pairing it with an edit icon button squeezed the title/subtitle
        // into wrapping at 411dp. Editing is still reachable via `onTap`.
        trailing: isActive
            ? FilledButton.tonal(
                onPressed: () {
                  if (cycle.routines.isNotEmpty) {
                    _startWorkout(
                      routine: cycle.nextRoutine ?? cycle.routines.first,
                      cycleId: cycle.id,
                    );
                  }
                },
                child: const Text('Start'),
              )
            : TextButton(
                onPressed: () async {
                  await ref
                      .read(strengthRoutineRepositoryProvider)
                      .setActiveCycle(cycle.id);
                },
                child: const Text('Set Active'),
              ),
        onTap: () => StrengthCycleEditorSheet.show(context, cycle: cycle),
      ),
    );
  }

  Widget _buildRoutineTile(BuildContext context, StrengthDayRoutine routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(
          routine.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // See `_buildCycleTile`: "Tap to edit" replaces the removed
        // trailing edit icon button, which squeezed the title/subtitle.
        subtitle: Text(
          '${routine.exercises.length} exercises · '
          '~${routine.estimatedDurationMinutes} min · Tap to edit',
        ),
        trailing: FilledButton.tonal(
          onPressed: () => _startWorkout(routine: routine),
          child: const Text('Start'),
        ),
        onTap: () => StrengthRoutineEditorSheet.show(context, routine: routine),
      ),
    );
  }
}
