import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/utils/text_measure.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/session_duration.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';

/// Mindful session tracker tailored for Yoga and Pilates.
///
/// Backed by persistent [mindfulTrackerControllerProvider] so timers and
/// session parameters remain active and accessible when navigating through
/// other tabs.
class MindfulTrackerScreen extends ConsumerStatefulWidget {
  const MindfulTrackerScreen({
    super.key,
    this.initialType = ActivityType.yoga,
  });

  final ActivityType initialType;

  @override
  ConsumerState<MindfulTrackerScreen> createState() =>
      _MindfulTrackerScreenState();
}

class _MindfulTrackerScreenState extends ConsumerState<MindfulTrackerScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(mindfulTrackerControllerProvider.notifier)
          .startSessionIfNeeded(widget.initialType);
      final notes = ref.read(mindfulTrackerControllerProvider).notes;
      if (notes.isNotEmpty) {
        _notesController.text = notes;
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  Future<void> _finishSession() async {
    // Read state (including lastInteractionAt) BEFORE the trim-on-finish
    // setNotes call below, which would otherwise stamp "just now" onto a
    // session that may genuinely have been left running - see the abandoned
    // check that follows.
    final state = ref.read(mindfulTrackerControllerProvider);
    final style = state.style;
    final typeLabel = state.activityType.label;
    final startedAt = state.startedAt;

    // A session left open (phone set down for a long hold, app
    // backgrounded) keeps accruing wall-clock elapsed time with no
    // style/focus/RPE/notes change logged into it. Saving that silently
    // would misrecord the duration, so once the gap is long enough to be
    // ambiguous the user is asked rather than guessed at - see
    // `domain/session_duration.dart`.
    final looksAbandoned =
        startedAt != null &&
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: DateTime.now().toUtc(),
          idleThreshold: mindfulIdleThreshold,
          lastInteractionAt: state.lastInteractionAt,
        );

    Duration? elapsedOverride;
    if (looksAbandoned) {
      final trimmed = elapsedToLastInteraction(
        startedAt: startedAt,
        lastInteractionAt: state.lastInteractionAt,
      );

      final choice = await showDialog<_MindfulFinishChoice>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Finish $typeLabel Session?'),
          content: Text(
            'Nothing has been logged for a while, so this session may have '
            'been left running. Record the full time, or only the '
            '${formatDuration(trimmed)} up to your last logged change?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_MindfulFinishChoice.keepPractising),
              child: const Text('Keep Practising'),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_MindfulFinishChoice.saveToLastInteraction),
              child: Text('Save ${formatDuration(trimmed)}'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_MindfulFinishChoice.saveFull),
              child: Text('Save ${formatDuration(state.elapsedDuration)}'),
            ),
          ],
        ),
      );

      if (choice == null ||
          choice == _MindfulFinishChoice.keepPractising ||
          !mounted) {
        return;
      }
      elapsedOverride = choice == _MindfulFinishChoice.saveToLastInteraction
          ? trimmed
          : null;
    }

    final controller = ref.read(mindfulTrackerControllerProvider.notifier)
      ..setNotes(_notesController.text.trim());

    final activity = await controller.finishSession(
      elapsedOverride: elapsedOverride,
    );

    if (mounted && activity != null) {
      final milestones = const MilestoneEvaluator().evaluateGenericMilestones(
        newActivity: activity,
        customSubtitle: '$style $typeLabel session completed 🧘‍♀️',
      );
      await WorkoutCelebrationDialog.show(
        context,
        activity: activity,
        milestones: milestones,
        primaryMetricLabel: 'Style',
        primaryMetricValue: style,
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

  /// Whether the app bar can show a labelled Finish button and still fit
  /// its title on one line.
  ///
  /// Measured against the real title string at the current text scale — a
  /// width breakpoint would be right at 100% and wrong at 130%, which is
  /// exactly the setting the clip showed up at.
  static const double _backButtonWidth = 56;

  /// `NavigationToolbar`'s default gap between the leading widget and the
  /// title (`AppBar.titleSpacing`).
  static const double _titleSpacing = 16;

  /// A `TextButton.icon` holding a check and the word "Finish": 16dp of
  /// padding either side, an 18dp icon, an 8dp gap and the label. Rounded
  /// up, because being one pixel optimistic here clips the title.
  static const double _labelledFinishWidth = 116;

  bool _finishActionFitsLabelled(BuildContext context, String typeLabel) {
    final titleWidth = measuredTextWidth(
      context,
      '$typeLabel Session',
      style:
          Theme.of(context).appBarTheme.titleTextStyle ??
          Theme.of(context).textTheme.titleLarge,
    );
    final available =
        MediaQuery.sizeOf(context).width -
        _backButtonWidth -
        _titleSpacing -
        titleWidth;
    return available >= _labelledFinishWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(mindfulTrackerControllerProvider);
    final controller = ref.read(mindfulTrackerControllerProvider.notifier);

    final availableStyles = MindfulStyles.stylesFor(state.activityType);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Minimize and keep session active',
          onPressed: () {
            controller.setNotes(_notesController.text.trim());
            Navigator.of(context).maybePop();
          },
        ),
        title: Text('${state.activityType.label} Session'),
        actions: [
          // A labelled "Finish" button costs ~100dp, which left "Yoga
          // Session" clipped on a 320dp phone at *default* text size. The
          // label is dropped only when the title cannot otherwise be read;
          // the tooltip and the semantics label keep naming the action
          // either way.
          if (_finishActionFitsLabelled(context, state.activityType.label))
            TextButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Finish'),
              onPressed: _finishSession,
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Finish',
              onPressed: _finishSession,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Big Calm Timer Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    state.activityType == ActivityType.pilates
                        ? Icons.accessibility_new
                        : Icons.self_improvement,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDuration(state.elapsedDuration.inSeconds),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mindful Duration',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Style Selector
            Text(
              'Session Style',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableStyles.map((style) {
                final isSelected = state.style == style;
                return ChoiceChip(
                  label: Text(style),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.setStyle(style);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Focus Area Selector
            Text(
              'Focus Area',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MindfulStyles.focusAreas.map((area) {
                final isSelected = state.focusArea == area;
                return ChoiceChip(
                  label: Text(area),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.setFocusArea(area);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // RPE Perceived Exertion
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perceived Exertion (RPE)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.rpe == null ? 'Not rated' : '${state.rpe} / 10',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            // The slider starts unrated: its thumb rests at the mid-point
            // so there is somewhere to drag from, but nothing is stored
            // until they actually move it. An unanswered RPE must reach
            // storage as null — `MindfulWorkoutDetails.rpe`.
            Slider(
              value: (state.rpe ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: state.rpe == null ? 'Not rated' : '${state.rpe}',
              onChanged: (val) => controller.setRpe(val.round()),
            ),

            const SizedBox(height: 16),

            // Session Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Session Notes / Poses Focused On',
                hintText:
                    'How did this session feel? '
                    'E.g., deep hip releases, core alignment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.setNotes,
            ),
          ],
        ),
      ),
    );
  }
}

enum _MindfulFinishChoice { keepPractising, saveToLastInteraction, saveFull }
