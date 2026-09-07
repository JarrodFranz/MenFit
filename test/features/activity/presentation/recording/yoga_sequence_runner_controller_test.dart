import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/wakelock/screen_awake_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';

import '../../../../core/platform/audio/fake_audio_cue_player.dart';
import '../../../../core/platform/wakelock/fake_screen_awake.dart';
import '../../fake_activity_repository.dart';

/// The runner's phase machine, driven by an injected clock.
///
/// Every assertion here is about time the app did *not* observe: a tick
/// that arrives late, a screen locked for three minutes, a pause the user
/// walked away from. Those are the cases a real-clock test cannot reach —
/// which is why `YogaSequenceRunnerController.clock` exists at all.
void main() {
  late FakeActivityRepository repository;
  late FakeAudioCuePlayer player;
  late FakeScreenAwake screenAwake;
  late ProviderContainer container;
  late DateTime now;

  YogaSequence sequenceOf({
    required List<YogaPose> poses,
    int transitionSeconds = 5,
    String name = 'Morning flow',
    String? style = 'Vinyasa',
  }) {
    final at = DateTime.utc(2026);
    return YogaSequence(
      id: 'seq-1',
      name: name,
      createdAt: at,
      updatedAt: at,
      poses: poses,
      transitionSeconds: transitionSeconds,
      style: style,
    );
  }

  YogaSequenceRunnerController controller() =>
      container.read(yogaSequenceRunnerControllerProvider.notifier);

  YogaRunnerState state() =>
      container.read(yogaSequenceRunnerControllerProvider);

  /// Moves the injected clock forward and runs the tick the real ticker
  /// would have run.
  void elapse(int seconds) {
    now = now.add(Duration(seconds: seconds));
    controller().tick();
  }

  setUp(() {
    repository = FakeActivityRepository();
    player = FakeAudioCuePlayer();
    screenAwake = FakeScreenAwake();
    now = DateTime.utc(2026, 9, 4, 7);

    container = ProviderContainer(
      overrides: [
        activityRepositoryProvider.overrideWithValue(repository),
        audioCuePlayerProvider.overrideWithValue(player),
        screenAwakeProvider.overrideWithValue(screenAwake),
      ],
    );
    // Set before any start(), so no phase is ever anchored to the real
    // clock.
    controller().clock = () => now;
    addTearDown(() async {
      controller().discard();
      container.dispose();
      await repository.dispose();
    });
  });

  group('phase progression', () {
    test('runs pose, transition, pose and then completes', () {
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 10),
            YogaPose(name: 'Tree', holdSeconds: 10),
          ],
        ),
      );

      expect(state().phase, YogaRunPhase.pose);
      expect(state().poseIndex, 0);
      expect(state().phaseRemaining, const Duration(seconds: 10));
      expect(state().currentPose?.name, 'Mountain');

      elapse(10);
      expect(state().phase, YogaRunPhase.transition);
      // The index still names the pose that ended; the one being moved
      // into is `nextPose`.
      expect(state().poseIndex, 0);
      expect(state().nextPose?.name, 'Tree');
      expect(state().phaseRemaining, const Duration(seconds: 5));

      elapse(5);
      expect(state().phase, YogaRunPhase.pose);
      expect(state().poseIndex, 1);

      elapse(10);
      expect(state().phase, YogaRunPhase.complete);
      expect(state().isActive, isFalse);
    });

    test('never adds a transition after the last pose', () {
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 10),
            YogaPose(name: 'Tree', holdSeconds: 10),
          ],
        ),
      );

      elapse(10); // -> transition
      elapse(5); // -> pose 2
      elapse(10);

      expect(state().phase, YogaRunPhase.complete);
    });

    test('a single-pose sequence has no transition at all', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Corpse Pose', holdSeconds: 30)],
        ),
      );

      elapse(30);

      expect(state().phase, YogaRunPhase.complete);
    });

    test('a zero-second transition goes straight to the next pose', () {
      controller().start(
        sequenceOf(
          transitionSeconds: 0,
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 10),
            YogaPose(name: 'Tree', holdSeconds: 10),
          ],
        ),
      );

      elapse(10);

      expect(state().phase, YogaRunPhase.pose);
      expect(state().poseIndex, 1);
    });

    test('a tick that crosses one boundary is not a catch-up', () {
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 10),
            YogaPose(name: 'Tree', holdSeconds: 10),
          ],
        ),
      );

      elapse(10);

      expect(state().catchUpOccurred, isFalse);
    });
  });

  group('catch-up after the isolate was suspended', () {
    // pose0 0-60, gap 60-70, pose1 70-130, gap 130-140, pose2 140-200.
    YogaSequence fourMinutes() => sequenceOf(
      transitionSeconds: 10,
      poses: const [
        YogaPose(name: 'Mountain', holdSeconds: 60),
        YogaPose(name: 'Tree', holdSeconds: 60),
        YogaPose(name: 'Warrior II', holdSeconds: 60),
        YogaPose(name: 'Corpse Pose', holdSeconds: 60),
      ],
    );

    test('a three-minute jump lands on the pose the schedule says', () {
      controller().start(fourMinutes());

      elapse(180);

      expect(state().phase, YogaRunPhase.pose);
      expect(state().poseIndex, 2);
      expect(state().currentPose?.name, 'Warrior II');
      expect(state().phaseRemaining, const Duration(seconds: 20));
    });

    test('marks the jump so the screen emits one cue, not five', () {
      controller().start(fourMinutes());

      elapse(180);

      expect(state().catchUpOccurred, isTrue);
    });

    test('clears the mark on the next ordinary tick', () {
      controller().start(fourMinutes());

      elapse(180);
      elapse(1);

      expect(state().catchUpOccurred, isFalse);
    });

    test('credits the poses that elapsed, and not the gaps between them', () {
      controller().start(fourMinutes());

      elapse(180);

      // 60 + 60 held in full and 40 s into the third; the two 10 s gaps
      // are elapsed time but not practice.
      expect(state().practisedTime, const Duration(seconds: 160));
      expect(state().elapsedTime, const Duration(seconds: 180));
    });
  });

  group('pause and resume', () {
    test('pause stores the remainder and stops the countdown', () {
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 60),
            YogaPose(name: 'Tree', holdSeconds: 60),
          ],
        ),
      );

      now = now.add(const Duration(seconds: 20));
      controller().pause();

      expect(state().phase, YogaRunPhase.paused);
      expect(state().pausedPhase, YogaRunPhase.pose);
      expect(state().pausedRemaining, const Duration(seconds: 40));
      expect(state().isActive, isTrue);

      // Time passing while paused must not advance the sequence.
      elapse(600);
      expect(state().phase, YogaRunPhase.paused);
      expect(state().pausedRemaining, const Duration(seconds: 40));
    });

    test('resume re-anchors the phase to now', () {
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 60),
            YogaPose(name: 'Tree', holdSeconds: 60),
          ],
        ),
      );

      now = now.add(const Duration(seconds: 20));
      controller().pause();
      now = now.add(const Duration(seconds: 600));
      controller().resume();

      expect(state().phase, YogaRunPhase.pose);
      expect(state().phaseRemaining, const Duration(seconds: 40));

      elapse(39);
      expect(state().phase, YogaRunPhase.pose);
      elapse(1);
      expect(state().phase, YogaRunPhase.transition);
    });

    test('practised time excludes the pause', () {
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 60),
            YogaPose(name: 'Tree', holdSeconds: 60),
          ],
        ),
      );

      elapse(20);
      controller().pause();
      elapse(600);
      controller().resume();
      elapse(10);

      expect(state().practisedTime, const Duration(seconds: 30));
      expect(state().elapsedTime, const Duration(seconds: 630));
    });
  });

  group('skipping', () {
    YogaSequence threePoses() => sequenceOf(
      poses: const [
        YogaPose(name: 'Mountain', holdSeconds: 60),
        YogaPose(name: 'Warrior II', holdSeconds: 60, side: YogaPoseSide.left),
        YogaPose(name: 'Tree', holdSeconds: 60),
      ],
    );

    test('skip forward ends the pose now and moves on', () {
      controller().start(threePoses());

      elapse(15);
      controller().skipForward();

      expect(state().phase, YogaRunPhase.transition);
      expect(state().phaseRemaining, const Duration(seconds: 5));

      controller().skipForward();
      expect(state().phase, YogaRunPhase.pose);
      expect(state().poseIndex, 1);
    });

    test('the remainder of a skipped pose is not practised time', () {
      controller().start(threePoses());

      elapse(15);
      controller().skipForward();

      expect(state().practisedTime, const Duration(seconds: 15));
    });

    test('skipping past the last pose completes the sequence', () {
      controller().start(threePoses());

      controller()
        ..skipForward() // transition
        ..skipForward() // pose 2
        ..skipForward() // transition
        ..skipForward() // pose 3
        ..skipForward();

      expect(state().phase, YogaRunPhase.complete);
    });

    test('skip back from a transition returns to the top of the pose', () {
      controller().start(threePoses());

      elapse(30);
      controller()
        ..skipForward() // -> transition after pose 1
        ..skipBack();

      expect(state().phase, YogaRunPhase.pose);
      expect(state().poseIndex, 0);
      expect(state().phaseRemaining, const Duration(seconds: 60));
    });

    test('skip back from a pose returns to the previous one', () {
      controller().start(threePoses());

      elapse(60); // -> transition
      elapse(5); // -> pose 2
      controller().skipBack();

      expect(state().poseIndex, 0);
      expect(state().currentPose?.name, 'Mountain');
    });

    test(
      'skip back on the first pose restarts it rather than under-running',
      () {
        controller().start(threePoses());

        elapse(30);
        controller().skipBack();

        expect(state().poseIndex, 0);
        expect(state().phaseRemaining, const Duration(seconds: 60));
      },
    );

    test('a skip taken while paused lands on the new phase, still paused', () {
      controller().start(threePoses());

      elapse(30);
      controller()
        ..pause()
        ..skipForward();

      expect(state().phase, YogaRunPhase.paused);
      expect(state().pausedPhase, YogaRunPhase.transition);
    });
  });

  group('the screen lock and the chime', () {
    test('start acquires the lock and preloads the chime', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );

      expect(screenAwake.acquireCount, 1);
      expect(screenAwake.held, isTrue);
      // Preloaded from the Start call itself: a browser only unlocks audio
      // for a gesture still on the call stack.
      expect(player.preloadCount, 1);
    });

    test('finish releases the lock', () async {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      elapse(10);
      await controller().finish();

      expect(screenAwake.releaseCount, 1);
      expect(screenAwake.held, isFalse);
    });

    test('discard releases the lock', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      controller().discard();

      expect(screenAwake.held, isFalse);
      expect(state().phase, YogaRunPhase.idle);
    });

    test('mute is a session toggle that survives the practice ending', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );

      expect(state().soundMuted, isFalse);
      controller().toggleMute();
      expect(state().soundMuted, isTrue);

      controller().discard();
      expect(state().soundMuted, isTrue);
    });

    test('an empty sequence is not startable', () {
      controller().start(sequenceOf(poses: const []));

      expect(state().phase, YogaRunPhase.idle);
      expect(screenAwake.acquireCount, 0);
    });
  });

  group('finish', () {
    test('finishing early records only the poses reached', () async {
      controller().start(
        sequenceOf(
          transitionSeconds: 10,
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 60),
            YogaPose(name: 'Tree', holdSeconds: 60),
            YogaPose(name: 'Tree Pose', holdSeconds: 60),
          ],
        ),
      );

      elapse(65); // pose 1 held in full, now inside the transition to pose 2
      await controller().finish();

      final details =
          repository.saved.single.workoutDetails! as MindfulWorkoutDetails;
      // The transition counts the pose it just left, not the one ahead.
      expect(details.poses, ['Mountain']);
    });

    test('saves a yoga activity carrying the pose names and no RPE', () async {
      controller().start(
        sequenceOf(
          transitionSeconds: 10,
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 60),
            YogaPose(
              name: 'Warrior II',
              holdSeconds: 60,
              side: YogaPoseSide.left,
            ),
          ],
        ),
      );

      elapse(130); // both poses held in full, plus the 10 s gap
      final activity = await controller().finish();

      expect(activity, isNotNull);
      expect(repository.saved, hasLength(1));
      final saved = repository.saved.single;
      expect(saved.activityType, ActivityType.yoga);
      expect(saved.title, 'Morning flow');
      expect(saved.source, ActivitySource.recorded);
      // Holds only for moving time; the gap is elapsed but not practised.
      expect(saved.movingTime, const Duration(seconds: 120));
      expect(saved.elapsedTime, const Duration(seconds: 130));

      final details = saved.workoutDetails! as MindfulWorkoutDetails;
      expect(details.poses, ['Mountain', 'Warrior II, left']);
      expect(details.style, 'Vinyasa');
      // Never asked, so never stored — see MindfulWorkoutDetails.rpe.
      expect(details.rpe, isNull);
    });

    test('clears the runner so the banner stops offering it', () async {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      elapse(10);
      await controller().finish();

      expect(state().phase, YogaRunPhase.idle);
      expect(state().sequence, isNull);
      expect(state().isActive, isFalse);
    });

    test('invents no style for a sequence that has none', () async {
      controller().start(
        sequenceOf(
          style: null,
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      elapse(10);
      await controller().finish();

      final details =
          repository.saved.single.workoutDetails! as MindfulWorkoutDetails;
      expect(details.style, isEmpty);
      expect(details.focusArea, isEmpty);
    });

    test('saves nothing when no practice was started', () async {
      final activity = await controller().finish();

      expect(activity, isNull);
      expect(repository.saved, isEmpty);
    });

    test(
      'a failed write leaves the practice saveable, and retry works',
      () async {
        repository.failSaves = true;
        controller().start(
          sequenceOf(
            poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
          ),
        );
        elapse(10);
        expect(state().phase, YogaRunPhase.complete);

        await expectLater(controller().finish(), throwsA(isA<Exception>()));

        // Nothing was stored, and nothing was thrown away either: the
        // practice is still on screen, still complete, still theirs to save.
        expect(repository.saved, isEmpty);
        expect(state().phase, YogaRunPhase.complete);
        expect(state().sequence, isNotNull);
        expect(state().practisedTime, const Duration(seconds: 10));
        // The one thing that IS given up: the wakelock. The practice is
        // over either way, and an unreleased lock is a flat battery.
        expect(screenAwake.held, isFalse);

        repository.failSaves = false;
        final activity = await controller().finish();

        expect(activity, isNotNull);
        expect(repository.saved, hasLength(1));
        expect(repository.saved.single.movingTime, const Duration(seconds: 10));
        expect(state().phase, YogaRunPhase.idle);
        expect(screenAwake.held, isFalse);
      },
    );

    test('a failed write mid-practice keeps the countdown running', () async {
      repository.failSaves = true;
      controller().start(
        sequenceOf(
          poses: const [
            YogaPose(name: 'Mountain', holdSeconds: 60),
            YogaPose(name: 'Tree', holdSeconds: 60),
          ],
        ),
      );
      elapse(10);

      await expectLater(controller().finish(), throwsA(isA<Exception>()));

      expect(state().phase, YogaRunPhase.pose);
      expect(controller().isTicking, isTrue);
      // Still on the mat, so the screen still stays awake.
      expect(screenAwake.held, isTrue);
    });

    test('two overlapping finishes save one activity', () async {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      elapse(10);

      final results = await Future.wait([
        controller().finish(),
        controller().finish(),
      ]);

      expect(repository.saveAttempts, 1);
      expect(repository.saved, hasLength(1));
      expect(results.whereType<Activity>(), hasLength(1));
    });
  });

  group('the ticker', () {
    test('stops when the sequence completes and restarts on skipBack', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      expect(controller().isTicking, isTrue);

      elapse(10);
      expect(state().phase, YogaRunPhase.complete);
      // Complete has no `phaseEndsAt`; every further tick would wake the
      // isolate to do nothing while the Save screen sits there.
      expect(controller().isTicking, isFalse);

      controller().skipBack();
      expect(state().phase, YogaRunPhase.pose);
      expect(controller().isTicking, isTrue);
      // Still on the mat, so the screen still stays awake.
      expect(screenAwake.held, isTrue);
    });

    test('stops when skipping past the last pose, not only on the clock', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 600)],
        ),
      );

      controller().skipForward();

      expect(state().phase, YogaRunPhase.complete);
      expect(controller().isTicking, isFalse);
    });

    test('finish stops it', () async {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 600)],
        ),
      );
      await controller().finish();

      expect(controller().isTicking, isFalse);
    });
  });

  group('starting a second sequence', () {
    test('leaves exactly one screen lock outstanding, not two', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      controller().start(
        sequenceOf(
          name: 'Wind down',
          poses: const [YogaPose(name: "Child's Pose", holdSeconds: 20)],
        ),
      );

      // One acquire, still held: `TrackerScreenAwake` keeps the lock it
      // already has across a restart rather than releasing and re-taking
      // it. What matters is that a second `start()` cannot leave a lock
      // outstanding that nothing will ever release - so discarding gives
      // it back, once.
      expect(screenAwake.acquireCount, 1);
      expect(screenAwake.held, isTrue);

      controller().discard();

      expect(screenAwake.held, isFalse);
      expect(screenAwake.releaseCount, 1);
    });

    test('replaces the practice rather than layering on it', () {
      controller().start(
        sequenceOf(
          poses: const [YogaPose(name: 'Mountain', holdSeconds: 10)],
        ),
      );
      elapse(5);
      controller().start(
        sequenceOf(
          name: 'Wind down',
          poses: const [YogaPose(name: "Child's Pose", holdSeconds: 20)],
        ),
      );

      expect(state().sequence?.name, 'Wind down');
      expect(state().poseIndex, 0);
      expect(state().practisedTime, Duration.zero);
      expect(state().phaseRemaining, const Duration(seconds: 20));
    });
  });
}
