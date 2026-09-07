import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_sound.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_runner/yoga_runner_active_view.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_runner/yoga_runner_complete_view.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_runner/yoga_runner_prestart_view.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';

/// Runs one saved yoga sequence, pose by pose, with a cue at every
/// boundary (ADR 014).
///
/// Backed by the persistent [yogaSequenceRunnerControllerProvider], so a
/// practice survives leaving this screen and is resumable from the
/// active-workout banner on any tab.
class YogaSequenceRunnerScreen extends ConsumerStatefulWidget {
  const YogaSequenceRunnerScreen({required this.sequenceId, super.key});

  final String sequenceId;

  @override
  ConsumerState<YogaSequenceRunnerScreen> createState() =>
      _YogaSequenceRunnerScreenState();
}

class _YogaSequenceRunnerScreenState
    extends ConsumerState<YogaSequenceRunnerScreen> {
  /// True from the tap on Save until the write settles and the celebration
  /// is done with. It disables Save and the app bar's Finish, so the
  /// practice cannot be written twice by an impatient second tap.
  bool _saving = false;

  /// Fires the boundary cues.
  ///
  /// Driven from a phase *transition* rather than from the countdown, so a
  /// boundary reached by the timer running out and one reached by pressing
  /// skip both fire exactly once. A catch-up after the screen was locked
  /// arrives as a single state change too — the controller snaps across
  /// every missed boundary in one assignment — so a three-minute
  /// suspension produces one chime, not a burst of them for boundaries
  /// nobody heard (ADR 014 §3).
  ///
  /// Pausing and resuming are deliberately not boundaries: she pressed the
  /// button, she knows.
  void _onRunnerChanged(YogaRunnerState? previous, YogaRunnerState next) {
    if (previous == null) return;
    if (previous.phase == YogaRunPhase.paused ||
        next.phase == YogaRunPhase.paused) {
      return;
    }
    if (previous.phase == next.phase &&
        previous.poseIndex == next.poseIndex &&
        previous.sequence?.id == next.sequence?.id) {
      return;
    }

    switch (next.phase) {
      // A pose starting, and the sequence ending, are the two moments she
      // has to feel with her eyes closed.
      case YogaRunPhase.pose:
      case YogaRunPhase.complete:
        unawaited(AccessibilityHaptics.heavyImpact(ref));
      // Moving between poses is a lighter nudge, matching the HIIT
      // tracker's rest convention.
      case YogaRunPhase.transition:
        unawaited(AccessibilityHaptics.mediumImpact(ref));
      // Idle is the runner being cleared, not a boundary.
      case YogaRunPhase.idle:
      case YogaRunPhase.paused:
        return;
    }

    if (!next.soundMuted) {
      unawaited(AccessibilitySound.transitionChime(ref));
    }
  }

  YogaSequenceRunnerController get _controller =>
      ref.read(yogaSequenceRunnerControllerProvider.notifier);

  void _togglePause() {
    final state = ref.read(yogaSequenceRunnerControllerProvider);
    if (state.phase == YogaRunPhase.paused) {
      _controller.resume();
    } else {
      _controller.pause();
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    final state = ref.read(yogaSequenceRunnerControllerProvider);
    if (state.sequence == null) {
      await Navigator.of(context).maybePop();
      return;
    }

    if (state.phase != YogaRunPhase.complete) {
      final choice = await showDialog<_FinishChoice>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Finish practice?'),
          content: const Text(
            'You have not reached the end of the sequence. Save what you '
            'have practised so far, or discard it?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_FinishChoice.keepPractising),
              child: const Text('Keep practising'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_FinishChoice.discard),
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_FinishChoice.save),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (!mounted ||
          choice == null ||
          choice == _FinishChoice.keepPractising) {
        return;
      }
      if (choice == _FinishChoice.discard) {
        _controller.discard();
        await Navigator.of(context).maybePop();
        return;
      }
    }

    await _saveAndCelebrate();
  }

  Future<void> _saveAndCelebrate() async {
    // Synchronous with the tap, before the first await: a second tap that
    // lands in the same frame must find this already true.
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _save();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    final state = ref.read(yogaSequenceRunnerControllerProvider);
    final poseCount = state.poseCount;

    final Activity? activity;
    try {
      activity = await _controller.finish();
    } on Object catch (error) {
      // The practice is untouched by a failed write — same phase, same
      // poses — so the honest thing is to say so and leave her on the
      // Save button rather than popping her out of a session that was
      // never stored.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(error))),
      );
      return;
    }

    if (!mounted) return;
    if (activity == null) {
      await Navigator.of(context).maybePop();
      return;
    }
    // Re-bound so the celebration's callbacks close over a non-nullable
    // local: a variable declared `Activity?` and assigned in a `try` is not
    // promoted inside a closure.
    final saved = activity;

    final milestones = const MilestoneEvaluator().evaluateGenericMilestones(
      newActivity: saved,
      customSubtitle: '$poseCount poses practised 🧘‍♀️',
    );
    await WorkoutCelebrationDialog.show(
      context,
      activity: saved,
      milestones: milestones,
      primaryMetricLabel: 'Poses',
      primaryMetricValue: '$poseCount',
      onViewDetails: () => ActivityDetailRouteData(saved.id).go(context),
      onDone: () => Navigator.of(context).maybePop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(yogaSequenceRunnerControllerProvider, _onRunnerChanged);

    final runner = ref.watch(yogaSequenceRunnerControllerProvider);
    final sequenceAsync = ref.watch(yogaSequenceProvider(widget.sequenceId));
    final soundCues = ref.watch(accessibilityControllerProvider).soundCues;

    // The runner is global: it may be part-way through a *different*
    // sequence than the one this route names, in which case this screen is
    // a pre-start view and the banner still leads back to the other one.
    final isThisSequence =
        runner.sequence?.id == widget.sequenceId &&
        runner.phase != YogaRunPhase.idle;

    final title = isThisSequence
        ? runner.sequence!.name
        : (sequenceAsync.value?.name ?? 'Yoga sequence');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Minimise and keep the practice running',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: [
          if (isThisSequence)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Finish',
              onPressed: _saving ? null : _finish,
            ),
        ],
      ),
      body: SafeArea(
        child: isThisSequence
            ? _runnerBody(
                runner,
                chimeSilenced: runner.soundMuted || !soundCues,
              )
            : _prestartBody(sequenceAsync, runner),
      ),
    );
  }

  Widget _runnerBody(YogaRunnerState runner, {required bool chimeSilenced}) {
    if (runner.phase == YogaRunPhase.complete) {
      return YogaRunnerCompleteView(
        state: runner,
        onSave: _saveAndCelebrate,
        onPractiseAgain: _controller.skipBack,
        saving: _saving,
      );
    }
    return YogaRunnerActiveView(
      state: runner,
      chimeSilenced: chimeSilenced,
      onSkipBack: _controller.skipBack,
      onTogglePause: _togglePause,
      onSkipForward: _controller.skipForward,
      onToggleMute: _controller.toggleMute,
    );
  }

  Widget _prestartBody(
    AsyncValue<YogaSequence?> sequenceAsync,
    YogaRunnerState runner,
  ) {
    return sequenceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const _RunnerMessage(
        message: 'That sequence could not be loaded.',
      ),
      data: (sequence) {
        if (sequence == null) {
          return const _RunnerMessage(
            message: 'This sequence is no longer saved.',
          );
        }
        return YogaRunnerPrestartView(
          sequence: sequence,
          // Started straight from the tap, never from a post-frame
          // callback: the browser only unlocks audio for a gesture still on
          // the call stack (see YogaSequenceRunnerController.start).
          onStart: () => _controller.start(sequence),
          conflict: _conflictWith(runner, sequence),
        );
      },
    );
  }

  /// The other practice loaded in the (single, global) runner, if any.
  ///
  /// `complete` counts as well as the running phases: that practice is
  /// finished but **unsaved**, and starting this one would throw it away
  /// just as silently — the same reason the active-workout banner keeps
  /// offering it.
  YogaRunnerConflict? _conflictWith(
    YogaRunnerState runner,
    YogaSequence sequence,
  ) {
    final running = runner.sequence;
    if (running == null ||
        runner.phase == YogaRunPhase.idle ||
        running.id == widget.sequenceId) {
      return null;
    }

    final runningId = running.id;
    return YogaRunnerConflict(
      name: running.name,
      isComplete: runner.phase == YogaRunPhase.complete,
      onGoBack: () => unawaited(
        YogaSequenceRunnerRouteData(sequenceId: runningId).push<void>(context),
      ),
      onDiscardAndStart: () {
        // Both synchronous, in this order and on the tap's own call stack:
        // `discard` releases the other practice's lock, `start` takes a
        // fresh one and preloads the chime inside the gesture.
        _controller
          ..discard()
          ..start(sequence);
      },
    );
  }
}

class _RunnerMessage extends StatelessWidget {
  const _RunnerMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

enum _FinishChoice { keepPractising, discard, save }
