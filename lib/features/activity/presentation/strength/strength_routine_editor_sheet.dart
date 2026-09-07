import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';

/// Modal sheet for creating, editing, and configuring a [StrengthDayRoutine]
/// with its exercise templates, sets, reps, and target weights without starting
/// a workout.
class StrengthRoutineEditorSheet extends ConsumerStatefulWidget {
  const StrengthRoutineEditorSheet({
    this.routine,
    super.key,
  });

  final StrengthDayRoutine? routine;

  static Future<void> show(
    BuildContext context, {
    StrengthDayRoutine? routine,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => StrengthRoutineEditorSheet(routine: routine),
    );
  }

  @override
  ConsumerState<StrengthRoutineEditorSheet> createState() =>
      _StrengthRoutineEditorSheetState();
}

class _StrengthRoutineEditorSheetState
    extends ConsumerState<StrengthRoutineEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late List<StrengthExerciseTemplate> _exercises;
  int _estimatedDurationMinutes = 45;

  @override
  void initState() {
    super.initState();
    final r = widget.routine;
    _nameController = TextEditingController(text: r?.name ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _exercises = r != null ? List.from(r.exercises) : [];
    _estimatedDurationMinutes = r?.estimatedDurationMinutes ?? 45;

    if (_exercises.isEmpty && r == null) {
      _exercises = [
        const StrengthExerciseTemplate(
          name: 'Barbell Squat',
          targetWeightKg: 40,
        ),
        const StrengthExerciseTemplate(
          name: 'Bench Press',
          targetWeightKg: 30,
        ),
        const StrengthExerciseTemplate(
          name: 'Bent-Over Row',
          targetWeightKg: 25,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  StrengthDayRoutine _buildRoutine() {
    final now = DateTime.now().toUtc();
    return StrengthDayRoutine(
      id:
          widget.routine?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim().isEmpty
          ? 'New Routine'
          : _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      exercises: List.unmodifiable(_exercises),
      estimatedDurationMinutes: _estimatedDurationMinutes,
      createdAt: widget.routine?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _saveRoutine() async {
    final routine = _buildRoutine();
    await ref.read(strengthRoutineRepositoryProvider).saveRoutine(routine);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${routine.name}"')),
      );
    }
  }

  Future<void> _deleteRoutine() async {
    final r = widget.routine;
    if (r == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Routine?'),
        content: Text('Are you sure you want to delete "${r.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(strengthRoutineRepositoryProvider).deleteRoutine(r.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${r.name}"')),
        );
      }
    }
  }

  void _startWorkout() {
    final routine = _buildRoutine();
    Navigator.of(context).pop();
    unawaited(
      ref
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkout(routine: routine),
    );
    unawaited(const StrengthTrackerRouteData().push<void>(context));
  }

  void _showAddOrEditExerciseDialog([int? editIndex]) {
    final existing = editIndex != null ? _exercises[editIndex] : null;
    final nameCtrl = TextEditingController(
      text: existing?.name ?? '',
    );
    var sets = existing?.targetSets ?? 3;
    var reps = existing?.targetReps ?? 10;
    final weightCtrl = TextEditingController(
      text: existing != null && existing.targetWeightKg > 0
          ? existing.targetWeightKg.toString()
          : '20',
    );
    var restSeconds = existing?.targetRestSeconds ?? 60;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(existing == null ? 'Add Exercise' : 'Edit Exercise'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      hintText: 'e.g. Dumbbell RDL, Lat Pulldown',
                    ),
                    autofocus: existing == null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sets', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: sets > 1
                                      ? () => setDialogState(() => sets--)
                                      : null,
                                ),
                                Text(
                                  '$sets',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: sets < 20
                                      ? () => setDialogState(() => sets++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Reps',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: reps > 1
                                      ? () => setDialogState(() => reps--)
                                      : null,
                                ),
                                Text(
                                  '$reps',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: reps < 100
                                      ? () => setDialogState(() => reps++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Target Weight (kg)',
                            suffixText: 'kg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: restSeconds,
                          decoration: const InputDecoration(
                            labelText: 'Rest Timer',
                          ),
                          items: const [
                            DropdownMenuItem(value: 30, child: Text('30s')),
                            DropdownMenuItem(value: 45, child: Text('45s')),
                            DropdownMenuItem(value: 60, child: Text('60s')),
                            DropdownMenuItem(value: 90, child: Text('90s')),
                            DropdownMenuItem(value: 120, child: Text('2 min')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => restSeconds = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  final weight = double.tryParse(weightCtrl.text.trim()) ?? 0.0;
                  final template = StrengthExerciseTemplate(
                    name: name,
                    targetSets: sets,
                    targetReps: reps,
                    targetWeightKg: weight,
                    targetRestSeconds: restSeconds,
                  );
                  setState(() {
                    if (editIndex != null) {
                      _exercises[editIndex] = template;
                    } else {
                      _exercises.add(template);
                    }
                  });
                  Navigator.of(dialogCtx).pop();
                },
                child: const Text('Save Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final isEditing = widget.routine != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scrollController) {
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
                      isEditing ? 'Edit Day Routine' : 'New Day Routine',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Routine Name',
                  hintText: 'e.g. Upper Body Power, Lower Hypertrophy',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description / Focus (Optional)',
                  hintText: 'e.g. Quad emphasis, posterior chain focus',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Exercises (${_exercises.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Exercise'),
                    onPressed: _showAddOrEditExerciseDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_exercises.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingMd),
                    child: const Center(
                      child: Text(
                        'No exercises added yet. '
                        'Tap "Add Exercise" above.',
                      ),
                    ),
                  ),
                )
              else
                ..._exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ex = entry.value;
                  final wtStr = ex.targetWeightKg > 0
                      ? ' @ ${ex.targetWeightKg} kg'
                      : '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        ex.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${ex.targetSets} sets × ${ex.targetReps} reps'
                        '$wtStr · ${ex.targetRestSeconds}s rest',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Edit Exercise',
                            onPressed: () =>
                                _showAddOrEditExerciseDialog(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Remove',
                            onPressed: () {
                              setState(() => _exercises.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (isEditing) ...[
                    IconButton.filledTonal(
                      icon: Icon(
                        Icons.delete_forever,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete Routine',
                      onPressed: _deleteRoutine,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveRoutine,
                      icon: const Icon(Icons.check),
                      label: const Text('Save Routine'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _startWorkout,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Workout Now'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

/// Modal sheet for creating, editing, and managing a [StrengthCycle] with its
/// day routines.
class StrengthCycleEditorSheet extends ConsumerStatefulWidget {
  const StrengthCycleEditorSheet({
    this.cycle,
    super.key,
  });

  final StrengthCycle? cycle;

  static Future<void> show(
    BuildContext context, {
    StrengthCycle? cycle,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => StrengthCycleEditorSheet(cycle: cycle),
    );
  }

  @override
  ConsumerState<StrengthCycleEditorSheet> createState() =>
      _StrengthCycleEditorSheetState();
}

class _StrengthCycleEditorSheetState
    extends ConsumerState<StrengthCycleEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late List<StrengthDayRoutine> _routines;
  late bool _isActive;
  int _currentDayIndex = 0;
  int _totalSessionsCompleted = 0;

  @override
  void initState() {
    super.initState();
    final c = widget.cycle;
    _nameController = TextEditingController(text: c?.name ?? '');
    _goalController = TextEditingController(text: c?.description ?? '');
    _routines = c != null ? List.from(c.routines) : [];
    _isActive = c?.isActive ?? false;
    _currentDayIndex = c?.currentDayIndex ?? 0;
    _totalSessionsCompleted = c?.totalSessionsCompleted ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  StrengthCycle _buildCycle() {
    final now = DateTime.now().toUtc();
    return StrengthCycle(
      id: widget.cycle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim().isEmpty
          ? 'New Training Cycle'
          : _nameController.text.trim(),
      description: _goalController.text.trim(),
      routines: List.unmodifiable(_routines),
      isActive: _isActive,
      currentDayIndex: _currentDayIndex,
      totalSessionsCompleted: _totalSessionsCompleted,
      createdAt: widget.cycle?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _saveCycle() async {
    final cycle = _buildCycle();
    final repo = ref.read(strengthRoutineRepositoryProvider);
    await repo.saveCycle(cycle);
    if (_isActive) {
      await repo.setActiveCycle(cycle.id);
    }
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${cycle.name}"')),
      );
    }
  }

  Future<void> _deleteCycle() async {
    final c = widget.cycle;
    if (c == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Cycle?'),
        content: Text('Are you sure you want to delete "${c.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(strengthRoutineRepositoryProvider).deleteCycle(c.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${c.name}"')),
        );
      }
    }
  }

  void _showAddRoutineToCycleDialog() {
    final routinesAsync = ref.read(strengthRoutinesProvider);
    final savedRoutines = routinesAsync.value ?? [];

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Add Day Routine to Cycle'),
          content: SizedBox(
            width: double.maxFinite,
            child: savedRoutines.isEmpty
                ? const Text('No saved routines available. Create one first!')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: savedRoutines.length,
                    itemBuilder: (ctx, idx) {
                      final r = savedRoutines[idx];
                      return ListTile(
                        title: Text(r.name),
                        subtitle: Text('${r.exercises.length} exercises'),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          setState(() => _routines.add(r));
                          Navigator.of(dialogCtx).pop();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                unawaited(StrengthRoutineEditorSheet.show(context));
              },
              child: const Text('Create New Routine'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final isEditing = widget.cycle != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scrollController) {
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
                      isEditing ? 'Edit Training Cycle' : 'New Training Cycle',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Cycle Name',
                  hintText: 'e.g. 4-Week Strength Mesocycle',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(
                  labelText: 'Goal & Progression Notes (Optional)',
                  hintText: 'e.g. Add 2.5kg each week, focus on squat depth',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Active Cycle'),
                subtitle: const Text('Tracks progression and next up days'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Day Routines in Cycle (${_routines.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Day'),
                    onPressed: _showAddRoutineToCycleDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_routines.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingMd),
                    child: const Center(
                      child: Text(
                        'No days in this cycle yet. Tap "Add Day" above.',
                      ),
                    ),
                  ),
                )
              else
                ..._routines.asMap().entries.map((entry) {
                  final index = entry.key;
                  final routine = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        'Day ${index + 1}: ${routine.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${routine.exercises.length} exercises'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Edit Routine',
                            onPressed: () {
                              unawaited(
                                StrengthRoutineEditorSheet.show(
                                  context,
                                  routine: routine,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Remove from Cycle',
                            onPressed: () {
                              setState(() => _routines.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (isEditing) ...[
                    IconButton.filledTonal(
                      icon: Icon(
                        Icons.delete_forever,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete Cycle',
                      onPressed: _deleteCycle,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveCycle,
                      icon: const Icon(Icons.check),
                      label: const Text('Save Cycle'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
