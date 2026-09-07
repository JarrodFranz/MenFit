import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/strength_session_duration.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';

const List<String> _kStandardExercises = [
  'Barbell Squat',
  'Bench Press',
  'Deadlift',
  'Overhead Shoulder Press',
  'Barbell Row',
  'Pull Up / Lat Pulldown',
  'Push Up',
  'Dumbbell Walking Lunge',
  'Romanian Deadlift (RDL)',
  'Dumbbell Bicep Curl',
  'Tricep Dip / Pushdown',
  'Dumbbell Lateral Raise',
  'Leg Press',
  'Hamstring Leg Curl',
  'Standing Calf Raise',
  'Plank (Core)',
  'Cable Face Pull',
  'Hip Thrust',
];

/// Interactive live workout tracker for Strength training sessions.
///
/// Backed by persistent [strengthTrackerControllerProvider] so state, timers,
/// and exercise sets survive leaving the screen, navigating to other tabs, or
/// switching apps.
class StrengthTrackerScreen extends ConsumerStatefulWidget {
  const StrengthTrackerScreen({super.key});

  @override
  ConsumerState<StrengthTrackerScreen> createState() =>
      _StrengthTrackerScreenState();
}

class _StrengthTrackerScreenState extends ConsumerState<StrengthTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();
    });
  }

  Future<void> _finishWorkout(StrengthTrackerState state) async {
    final startedAt = state.startedAt;
    // A workout left open (phone pocketed, app backgrounded overnight) keeps
    // accruing wall-clock elapsed time with nothing logged into it. Saving
    // that silently is how a three-set session ends up recorded as a
    // six-hour workout, so when the gap is long enough to be ambiguous the
    // user is asked rather than guessed at - see
    // `domain/strength_session_duration.dart`.
    final looksAbandoned =
        startedAt != null &&
        strengthLooksAbandoned(
          startedAt: startedAt,
          now: DateTime.now().toUtc(),
          lastInteractionAt: state.lastInteractionAt,
        );
    final trimmed = startedAt == null
        ? Duration.zero
        : strengthElapsedToLastInteraction(
            startedAt: startedAt,
            lastInteractionAt: state.lastInteractionAt,
          );

    final leftRunningNotice = looksAbandoned
        ? '\n\nNothing has been logged for a while, so this workout may have '
              'been left running. Record the full time, or only the '
              '${formatDuration(trimmed)} up to your last logged set?'
        : '';

    final choice = await showDialog<_FinishChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish Strength Workout?'),
        content: Text(
          'Total Volume: ${state.totalVolumeKg.toStringAsFixed(0)} kg\n'
          'Completed Sets: ${state.totalCompletedSets} sets\n'
          'Duration: ${formatDuration(state.elapsedDuration)}'
          '$leftRunningNotice',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_FinishChoice.keepTraining),
            child: const Text('Keep Training'),
          ),
          if (looksAbandoned)
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_FinishChoice.saveToLastSet),
              child: Text('Save ${formatDuration(trimmed)}'),
            ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_FinishChoice.saveFull),
            child: Text(
              looksAbandoned
                  ? 'Save ${formatDuration(state.elapsedDuration)}'
                  : 'Save Workout',
            ),
          ),
        ],
      ),
    );

    if (choice == null || choice == _FinishChoice.keepTraining || !mounted) {
      return;
    }
    final elapsedOverride = choice == _FinishChoice.saveToLastSet
        ? trimmed
        : null;

    final currentState = ref.read(strengthTrackerControllerProvider);
    final strengthRepo = ref.read(strengthRoutineRepositoryProvider);
    final priorMaxWeights = <String, double>{};
    for (final exercise in currentState.exercises) {
      final best = await strengthRepo.getExerciseAllTimeBestPerformance(
        exercise.name,
      );
      if (best != null) {
        final maxW = best.sets
            .where((s) => s.isCompleted)
            .fold<double>(
              0,
              (max, s) => s.weightKg > max ? s.weightKg : max,
            );
        priorMaxWeights[exercise.name.trim().toLowerCase()] = maxW;
      }
    }

    final exercises = state.exercises;
    final totalVol = state.totalVolumeKg;
    final controller = ref.read(strengthTrackerControllerProvider.notifier);

    final activity = await controller.finishWorkout(
      elapsedOverride: elapsedOverride,
    );

    if (mounted && activity != null) {
      final milestones = const MilestoneEvaluator().evaluateStrengthMilestones(
        newActivity: activity,
        exercises: exercises,
        priorMaxWeights: priorMaxWeights,
      );
      await WorkoutCelebrationDialog.show(
        context,
        activity: activity,
        milestones: milestones,
        primaryMetricLabel: 'Volume',
        primaryMetricValue: '${totalVol.toStringAsFixed(0)} kg',
        onViewDetails: () {
          ActivityDetailRouteData(activity.id).go(context);
        },
        onDone: () {
          Navigator.of(context).maybePop();
        },
      );
    } else if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _showAddExerciseSheet() {
    var searchQuery = '';

    unawaited(
      showAppBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              final filtered = _kStandardExercises
                  .where(
                    (e) => e.toLowerCase().contains(searchQuery.toLowerCase()),
                  )
                  .toList();

              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Exercise',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search or type exercise name...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) {
                            setSheetState(() {
                              searchQuery = val;
                            });
                          },
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              unawaited(
                                ref
                                    .read(
                                      strengthTrackerControllerProvider
                                          .notifier,
                                    )
                                    .addExercise(val.trim()),
                              );
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        if (searchQuery.trim().isNotEmpty &&
                            !_kStandardExercises.any(
                              (e) =>
                                  e.toLowerCase() ==
                                  searchQuery.trim().toLowerCase(),
                            ))
                          ListTile(
                            leading: const Icon(Icons.add_circle_outline),
                            title: Text('Add "${searchQuery.trim()}"'),
                            onTap: () {
                              unawaited(
                                ref
                                    .read(
                                      strengthTrackerControllerProvider
                                          .notifier,
                                    )
                                    .addExercise(searchQuery.trim()),
                              );
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final ex = filtered[index];
                              return ListTile(
                                leading: const Icon(Icons.fitness_center),
                                title: Text(ex),
                                onTap: () {
                                  unawaited(
                                    ref
                                        .read(
                                          strengthTrackerControllerProvider
                                              .notifier,
                                        )
                                        .addExercise(ex),
                                  );
                                  Navigator.of(sheetContext).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showSaveAsRoutineDialog() async {
    final state = ref.read(strengthTrackerControllerProvider);
    if (state.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one exercise before saving as a routine.',
          ),
        ),
      );
      return;
    }

    final textCtrl = TextEditingController(text: state.routineName ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Save as Day Routine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save this workout so you can repeat it or add it to '
              'training cycles.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Routine Name',
                hintText: 'e.g. Upper Body A, Glute Power',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = textCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.of(dialogCtx).pop();
              final controller = ref.read(
                strengthTrackerControllerProvider.notifier,
              );
              await controller.saveAsRoutine(name);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved routine "$name" to library')),
                );
              }
            },
            child: const Text('Save Routine'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDiscardWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text(
          'Are you sure you want to discard this workout? Current sets and '
          'progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(strengthTrackerControllerProvider.notifier).discardWorkout();
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(strengthTrackerControllerProvider);
    final controller = ref.read(strengthTrackerControllerProvider.notifier);

    final isSetRunning = state.isSetRunning;
    final workoutTitle = state.routineName ?? 'Strength Workout';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Minimize and keep workout active',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutTitle,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              formatDuration(state.elapsedDuration),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'save_routine') {
                unawaited(_showSaveAsRoutineDialog());
              } else if (val == 'discard') {
                unawaited(_confirmDiscardWorkout());
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save_routine',
                child: Row(
                  children: [
                    Icon(Icons.bookmark_add_outlined),
                    SizedBox(width: 8),
                    Text('Save as Routine'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'discard',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Discard Workout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Finish'),
            onPressed: () => unawaited(_finishWorkout(state)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: !isSetRunning,
        child: Column(
          children: [
            // Workout Header Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    label: 'VOLUME',
                    value: '${state.totalVolumeKg.toStringAsFixed(0)} kg',
                  ),
                  _buildStatItem(
                    context,
                    label: 'SETS',
                    value: '${state.totalCompletedSets}',
                  ),
                  _buildStatItem(
                    context,
                    label: 'EXERCISES',
                    value: '${state.exercises.length}',
                  ),
                ],
              ),
            ),

            // Rest Timer Banner (when rest timer is active)
            if (state.isRestTimerRunning)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: theme.colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rest: '
                      '${formatDuration(
                        Duration(seconds: state.restSecondsRemaining),
                      )}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => controller.addRestSeconds(30),
                      child: const Text('+30s'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: controller.stopRestTimer,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),

            // Exercise List or Empty State
            if (state.exercises.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ready to Lift?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your exercises to track sets, reps, weights, '
                          'and rest periods.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          onPressed: _showAddExerciseSheet,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.exercises.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.exercises.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 40),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _showAddExerciseSheet,
                        ),
                      );
                    }

                    final exercise = state.exercises[index];
                    return _buildExerciseCard(
                      context,
                      exercise,
                      index,
                      state,
                      controller,
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      // Sticky Bottom Active Set Action Bar
      bottomNavigationBar: isSetRunning
          ? _buildActiveSetBar(context, theme, state, controller)
          : null,
    );
  }

  Widget _buildActiveSetBar(
    BuildContext context,
    ThemeData theme,
    StrengthTrackerState state,
    StrengthTrackerController controller,
  ) {
    final activeSec = state.activeSetElapsedSeconds;
    final exerciseIndex = state.activeExerciseIndex!;
    final setIndex = state.activeSetIndex!;
    final exerciseName = state.exercises[exerciseIndex].name;
    final setNum = setIndex + 1;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$exerciseName · Set $setNum',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDuration(Duration(seconds: activeSec)),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.stop),
                label: const Text('Finish Set'),
                onPressed: () {
                  unawaited(AccessibilityHaptics.heavyImpact(ref));
                  controller.finishActiveSet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    StrengthExercise exercise,
    int exerciseIndex,
    StrengthTrackerState state,
    StrengthTrackerController controller,
  ) {
    final theme = Theme.of(context);

    final historySummary =
        state.historicalWeights[exercise.name.trim().toLowerCase()];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: themedCardShape(context, radius: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (historySummary != null &&
                          historySummary.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 14,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Last: $historySummary',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    unawaited(
                      showAppBottomSheet<void>(
                        context: context,
                        builder: (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Remove Exercise',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                controller.removeExercise(exerciseIndex);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sets Header
            const Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    'SET',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    'KG',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    'REPS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      'TIMER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      'DONE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Set Rows
            ...exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              final isCurrentActive =
                  state.activeExerciseIndex == exerciseIndex &&
                  state.activeSetIndex == setIndex;

              return Container(
                key: ValueKey('exercise-$exerciseIndex-set-$setIndex'),
                color: isCurrentActive
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${set.setNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Weight Field
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        key: ValueKey(
                          'weight-$exerciseIndex-$setIndex-${set.weightKg}',
                        ),
                        initialValue: set.weightKg > 0
                            ? set.weightKg.toStringAsFixed(
                                set.weightKg.truncateToDouble() == set.weightKg
                                    ? 0
                                    : 1,
                              )
                            : '',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onChanged: (val) {
                          final weight = double.tryParse(val) ?? 0.0;
                          controller.updateSet(
                            exerciseIndex,
                            setIndex,
                            weightKg: weight,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Reps Field
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        key: ValueKey(
                          'reps-$exerciseIndex-$setIndex-${set.reps}',
                        ),
                        initialValue: set.reps > 0 ? '${set.reps}' : '',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onChanged: (val) {
                          final reps = int.tryParse(val) ?? 0;
                          controller.updateSet(
                            exerciseIndex,
                            setIndex,
                            reps: reps,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Start/Active Timer Button
                    SizedBox(
                      width: 48,
                      child: isCurrentActive
                          ? IconButton(
                              icon: const Icon(
                                Icons.stop_circle,
                                color: Colors.orange,
                              ),
                              tooltip: 'Finish Set',
                              onPressed: () {
                                unawaited(
                                  AccessibilityHaptics.heavyImpact(ref),
                                );
                                controller.finishActiveSet();
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.play_circle_outline,
                                color: set.isCompleted
                                    ? Colors.grey
                                    : theme.colorScheme.primary,
                              ),
                              tooltip: 'Start Set',
                              onPressed: () {
                                unawaited(
                                  AccessibilityHaptics.mediumImpact(ref),
                                );
                                controller.startActiveSet(
                                  exerciseIndex,
                                  setIndex,
                                );
                              },
                            ),
                    ),
                    // Done Checkbox
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: set.isCompleted,
                        onChanged: (val) {
                          controller.updateSet(
                            exerciseIndex,
                            setIndex,
                            isCompleted: val ?? false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Set'),
              onPressed: () => controller.addSet(exerciseIndex),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the finish dialog came back with. Distinguishing
/// [saveToLastSet] from [saveFull] is what lets a workout that was left
/// running record an honest duration without the app silently choosing one
/// - see `domain/strength_session_duration.dart`.
enum _FinishChoice { keepTraining, saveToLastSet, saveFull }
