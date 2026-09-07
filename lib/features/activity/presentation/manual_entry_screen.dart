import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_controller.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_controller.dart';
import 'package:menfit_app/features/activity/presentation/mindful_style_options.dart';

/// Manual-entry form for logging (or editing) an activity: type, date/time,
/// duration, and type-specific fields (strength exercises, HIIT intervals,
/// mindful style/focus, swim laps/pool length, or GPS distance).
class ManualEntryScreen extends ConsumerWidget {
  const ManualEntryScreen({
    super.key,
    this.editActivityId,
    this.initialType,
  });

  final String? editActivityId;
  final ActivityType? initialType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = editActivityId;
    if (editId != null) {
      final activityAsync = ref.watch(
        fetchActivityProvider(editId),
      );
      return activityAsync.when(
        data: (activity) {
          if (activity == null) {
            return const Scaffold(
              body: Center(child: Text('Activity not found')),
            );
          }
          return _ManualEntryBody(
            editActivity: activity,
            initialType: initialType,
          );
        },
        loading: () => const Scaffold(
          body: Center(child: SizedBox.shrink()),
        ),
        error: (err, _) => const Scaffold(
          body: Center(child: Text('Failed to load activity')),
        ),
      );
    }

    return _ManualEntryBody(
      initialType: initialType,
    );
  }
}

class _ManualEntryBody extends ConsumerStatefulWidget {
  const _ManualEntryBody({
    this.editActivity,
    this.initialType,
  });

  final Activity? editActivity;
  final ActivityType? initialType;

  @override
  ConsumerState<_ManualEntryBody> createState() => _ManualEntryBodyState();
}

class _ManualEntryBodyState extends ConsumerState<_ManualEntryBody> {
  late final TextEditingController _distanceController;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController();
    _titleController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.editActivity != null) {
      unawaited(
        Future.microtask(() {
          if (!mounted) return;
          final unitSystem =
              ref.read(activityUnitSystemProvider).value ?? UnitSystem.metric;
          ref
              .read(manualEntryControllerProvider.notifier)
              .loadForEdit(widget.editActivity!, unitSystem);
        }),
      );
    } else if (widget.initialType != null) {
      unawaited(
        Future.microtask(() {
          if (!mounted) return;
          ref
              .read(manualEntryControllerProvider.notifier)
              .setInitialType(widget.initialType!);
        }),
      );
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncTextControllers(ManualEntryState state) {
    if (_distanceController.text != state.distanceInput) {
      _distanceController.text = state.distanceInput;
    }
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
    }
    if (_notesController.text != state.notes) {
      _notesController.text = state.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final editId = widget.editActivity?.id;
    final state = ref.watch(manualEntryControllerProvider);
    final controller = ref.read(manualEntryControllerProvider.notifier);
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;

    ref.listen(manualEntryControllerProvider, (previous, next) {
      final justSaved = next.didSave && !(previous?.didSave ?? false);
      if (!justSaved) return;
      try {
        if (editId != null) {
          ActivityDetailRouteData(editId).go(context);
        } else {
          const ActivityRouteData().go(context);
        }
      } on Object catch (_) {
        // Fallback in tests where GoRouter is not in the ancestor tree.
      }
    });

    _syncTextControllers(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(editId == null ? 'Log activity' : 'Edit activity'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: ListView(
              padding: EdgeInsets.all(tokens.spacingMd),
              children: [
                // Activity Type selector
                Text('Type', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: tokens.spacingSm),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ActivityType.values.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(width: tokens.spacingSm),
                    itemBuilder: (context, index) {
                      final type = ActivityType.values[index];
                      return ChoiceChip(
                        avatar: Icon(_iconFor(type), size: 18),
                        label: Text(type.label),
                        selected: state.activityType == type,
                        onSelected: (selected) {
                          if (selected) controller.updateActivityType(type);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: tokens.spacingLg),

                // Date & Time
                Text(
                  'Date & Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                _DateTimePicker(
                  value: state.startedAt,
                  errorText: state.dateTimeError,
                  onChanged: controller.updateStartedAt,
                ),
                SizedBox(height: tokens.spacingLg),

                // Duration
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                _DurationInputs(
                  hours: state.hours,
                  minutes: state.minutes,
                  seconds: state.seconds,
                  errorText: state.durationError,
                  onHoursChanged: controller.updateHours,
                  onMinutesChanged: controller.updateMinutes,
                  onSecondsChanged: controller.updateSeconds,
                ),
                SizedBox(height: tokens.spacingLg),

                // Type-Specific Form Sections
                if (state.activityType == ActivityType.strength) ...[
                  _StrengthInputSection(
                    state: state,
                    controller: controller,
                  ),
                  SizedBox(height: tokens.spacingLg),
                ] else if (state.activityType == ActivityType.hiit) ...[
                  _HiitInputSection(
                    state: state,
                    controller: controller,
                  ),
                  SizedBox(height: tokens.spacingLg),
                ] else if (state.activityType == ActivityType.yoga ||
                    state.activityType == ActivityType.pilates) ...[
                  _MindfulInputSection(
                    state: state,
                    controller: controller,
                  ),
                  SizedBox(height: tokens.spacingLg),
                ] else if (state.activityType == ActivityType.swim) ...[
                  _SwimInputSection(
                    state: state,
                    controller: controller,
                  ),
                  SizedBox(height: tokens.spacingLg),
                ] else ...[
                  // Distance sports (Run, Walk, Hike, Ride, Other)
                  _DistanceInputSection(
                    distanceController: _distanceController,
                    state: state,
                    controller: controller,
                    unitSystem: unitSystem,
                  ),
                  SizedBox(height: tokens.spacingLg),
                ],

                // Title (optional)
                Text(
                  'Title (optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'e.g. Morning ${state.activityType.label}',
                  ),
                  onChanged: controller.updateTitle,
                ),
                SizedBox(height: tokens.spacingLg),

                // Notes (optional)
                Text(
                  'Notes (optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'How did it feel? Any highlights or notes...',
                  ),
                  onChanged: controller.updateNotes,
                ),

                if (state.submitError != null) ...[
                  SizedBox(height: tokens.spacingMd),
                  Text(
                    state.submitError!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                SizedBox(height: tokens.spacingLg),

                FilledButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => controller.save(unitSystem),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
                SizedBox(height: tokens.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ActivityType type) => switch (type) {
    ActivityType.run => Icons.directions_run,
    ActivityType.walk => Icons.directions_walk,
    ActivityType.hike => Icons.terrain,
    ActivityType.ride => Icons.directions_bike,
    ActivityType.strength => Icons.fitness_center,
    ActivityType.yoga => Icons.self_improvement,
    ActivityType.hiit => Icons.timer,
    ActivityType.pilates => Icons.accessibility_new,
    ActivityType.swim => Icons.pool,
    ActivityType.other => Icons.sports,
  };
}

/// Distance sports input section (Run, Walk, Hike, Ride).
class _DistanceInputSection extends StatelessWidget {
  const _DistanceInputSection({
    required this.distanceController,
    required this.state,
    required this.controller,
    required this.unitSystem,
  });

  final TextEditingController distanceController;
  final ManualEntryState state;
  final ManualEntryController controller;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final distUnit = unitSystem == UnitSystem.imperial ? 'mi' : 'km';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distance', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        TextField(
          controller: distanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixText: distUnit,
            errorText: state.distanceError,
          ),
          onChanged: controller.updateDistanceInput,
        ),
      ],
    );
  }
}

/// Strength input section: exercises table with sets, reps, and weights.
class _StrengthInputSection extends StatelessWidget {
  const _StrengthInputSection({
    required this.state,
    required this.controller,
  });

  final ManualEntryState state;
  final ManualEntryController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Exercises & Sets',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _promptAddExercise(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Exercise'),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        if (state.strengthExercises.isEmpty)
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: themedCardShape(
              context,
              radius: 12,
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text('No exercises added yet.'),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Add Exercise" to log sets, reps, and weights.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: state.strengthExercises.asMap().entries.map((entry) {
              final eIndex = entry.key;
              final exercise = entry.value;
              return Card(
                elevation: 0,
                margin: EdgeInsets.only(bottom: tokens.spacingSm),
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                shape: themedCardShape(
                  context,
                  radius: 12,
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            tooltip: 'Remove exercise',
                            onPressed: () =>
                                controller.removeStrengthExercise(eIndex),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      // Set rows
                      ...exercise.sets.asMap().entries.map((sEntry) {
                        final sIndex = sEntry.key;
                        final s = sEntry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                'Set ${s.setNumber}:',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 56,
                                child: TextFormField(
                                  initialValue: '${s.reps}',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    suffixText: 'reps',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 6,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final r = int.tryParse(val);
                                    if (r != null) {
                                      controller.updateStrengthSet(
                                        eIndex,
                                        sIndex,
                                        reps: r,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 70,
                                child: TextFormField(
                                  initialValue: s.weightKg.toStringAsFixed(0),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    suffixText: 'kg',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 6,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final w = double.tryParse(val);
                                    if (w != null) {
                                      controller.updateStrengthSet(
                                        eIndex,
                                        sIndex,
                                        weightKg: w,
                                      );
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                tooltip: 'Remove set',
                                onPressed: () => controller.removeStrengthSet(
                                  eIndex,
                                  sIndex,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => controller.addStrengthSet(eIndex),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('+ Add Set'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _promptAddExercise(BuildContext context) {
    final textController = TextEditingController();
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Barbell Squat, Hip Thrust',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    [
                      'Squat',
                      'Bench Press',
                      'Deadlift',
                      'Hip Thrust',
                      'Dumbbell Row',
                      'Overhead Press',
                    ].map((name) {
                      return ActionChip(
                        label: Text(name),
                        onPressed: () {
                          textController.text = name;
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  controller.addStrengthExercise(name);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

/// HIIT input section: work seconds, rest seconds, total rounds.
class _HiitInputSection extends StatelessWidget {
  const _HiitInputSection({
    required this.state,
    required this.controller,
  });

  final ManualEntryState state;
  final ManualEntryController controller;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interval Settings',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('hiit_work_${state.hiitWorkSeconds}'),
                initialValue: '${state.hiitWorkSeconds}',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Work (seconds)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final s = int.tryParse(val);
                  if (s != null) controller.updateHiitWork(s);
                },
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: TextFormField(
                key: ValueKey('hiit_rest_${state.hiitRestSeconds}'),
                initialValue: '${state.hiitRestSeconds}',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rest (seconds)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final s = int.tryParse(val);
                  if (s != null) controller.updateHiitRest(s);
                },
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: TextFormField(
                key: ValueKey('hiit_rounds_${state.hiitTotalRounds}'),
                initialValue: '${state.hiitTotalRounds}',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Rounds',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final r = int.tryParse(val);
                  if (r != null) controller.updateHiitRounds(r);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Mindful input section (Yoga & Pilates): style selector & focus area.
class _MindfulInputSection extends StatelessWidget {
  const _MindfulInputSection({
    required this.state,
    required this.controller,
  });

  final ManualEntryState state;
  final ManualEntryController controller;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final textTheme = Theme.of(context).textTheme;

    final styles = mindfulStyleChoices(state.activityType, state.mindfulStyle);
    final focuses = mindfulFocusAreaChoices(state.mindfulFocusArea);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: styles.map((s) {
            return ChoiceChip(
              label: Text(s),
              selected: state.mindfulStyle == s,
              onSelected: (selected) {
                if (selected) controller.updateMindfulStyle(s);
              },
            );
          }).toList(),
        ),
        SizedBox(height: tokens.spacingLg),
        Text(
          'Focus Area',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: focuses.map((f) {
            return ChoiceChip(
              label: Text(f),
              selected: state.mindfulFocusArea == f,
              onSelected: (selected) {
                if (selected) controller.updateMindfulFocusArea(f);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Swim input section: pool length, laps, stroke type.
class _SwimInputSection extends StatelessWidget {
  const _SwimInputSection({
    required this.state,
    required this.controller,
  });

  final ManualEntryState state;
  final ManualEntryController controller;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final totalDist = (state.swimLaps * state.swimPoolLengthMeters).toInt();
    final strokes = [
      'Freestyle',
      'Breaststroke',
      'Backstroke',
      'Butterfly',
      'Mixed Medley',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pool Setup & Laps',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacingSm),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<double>(
                key: ValueKey('swim_pool_${state.swimPoolLengthMeters}'),
                initialValue: state.swimPoolLengthMeters,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Pool Length',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 25, child: Text('25 meters')),
                  DropdownMenuItem(value: 50, child: Text('50 meters')),
                  DropdownMenuItem(value: 22.86, child: Text('25 yards')),
                ],
                onChanged: (val) {
                  if (val != null) controller.updateSwimPoolLength(val);
                },
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: TextFormField(
                key: ValueKey('swim_laps_${state.swimLaps}'),
                initialValue: '${state.swimLaps}',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Total Laps',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final laps = int.tryParse(val);
                  if (laps != null) controller.updateSwimLaps(laps);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withValues(alpha: 0.4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Calculated Distance:',
                    style: textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '$totalDist meters',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        Text(
          'Primary Stroke',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: strokes.map((s) {
            return ChoiceChip(
              label: Text(s),
              selected: state.swimStroke == s,
              onSelected: (selected) {
                if (selected) controller.updateSwimStroke(s);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final DateTime value;
  final String? errorText;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      child: InkWell(
        onTap: () => _pick(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMMMd().add_jm().format(value)),
            const Icon(Icons.edit_calendar_outlined),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (pickedTime == null || !context.mounted) return;

    onChanged(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }
}

class _DurationInputs extends StatelessWidget {
  const _DurationInputs({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.errorText,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  final int hours;
  final int minutes;
  final int seconds;
  final String? errorText;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _DurationField(
                label: 'h',
                value: hours,
                onChanged: onHoursChanged,
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: _DurationField(
                label: 'm',
                value: minutes,
                onChanged: onMinutesChanged,
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: _DurationField(
                label: 's',
                value: seconds,
                onChanged: onSecondsChanged,
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          SizedBox(height: tokens.spacingXs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _DurationField extends StatefulWidget {
  const _DurationField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<_DurationField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _DurationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.toString() != _controller.text) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (text) {
        final parsed = int.tryParse(text) ?? 0;
        widget.onChanged(parsed);
      },
    );
  }
}
