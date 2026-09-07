import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/platform/wakelock/screen_awake_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/data/screen_awake_preference_store.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/platform/audio/fake_audio_cue_player.dart';
import '../../../../core/platform/wakelock/fake_screen_awake.dart';
import '../../fake_activity_repository.dart';

/// Grants permission and never emits a fix — enough for `RecordingController`
/// to get past its permission gate and open a session, which is the only
/// part of it this file is about.
class _FakeLocationAdapter implements LocationAdapter {
  @override
  LocationCapabilities get capabilities =>
      const LocationCapabilities(canRecordActivities: true);

  @override
  Future<LocationPermissionResult> checkPermission() async =>
      LocationPermissionResult.granted;

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      LocationPermissionResult.granted;

  @override
  Stream<LocationFix> fixes() => const Stream.empty();

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();
}

/// Hosts a bare [TrackerScreenAwake] so the helper can be exercised without
/// a tracker around it. `Provider` rather than codegen deliberately: this
/// is a test scaffold, not app wiring.
final _helperProvider = Provider<TrackerScreenAwake>(
  TrackerScreenAwake.new,
);

/// A second, independent helper — two trackers can hold the screen at once.
final _otherHelperProvider = Provider<TrackerScreenAwake>(
  TrackerScreenAwake.new,
);

void main() {
  late FakeScreenAwake screenAwake;
  late FakeActivityRepository repository;
  late SharedPreferences preferences;

  /// Turns the setting off for [type] before any container reads it, so a
  /// tracker starting in that container sees "off" at start time.
  Future<void> disableFor(ActivityType type) =>
      ScreenAwakePreferenceStore(preferences).setEnabled(type, enabled: false);

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        screenAwakeProvider.overrideWithValue(screenAwake),
        activityRepositoryProvider.overrideWithValue(repository),
        audioCuePlayerProvider.overrideWithValue(FakeAudioCuePlayer()),
        locationAdapterProvider.overrideWithValue(_FakeLocationAdapter()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    screenAwake = FakeScreenAwake();
    repository = FakeActivityRepository();
    addTearDown(repository.dispose);
  });

  group('TrackerScreenAwake', () {
    test('takes the lock when the type is switched on', () {
      final container = makeContainer();

      container.read(_helperProvider).acquireFor(ActivityType.run);

      expect(screenAwake.held, isTrue);
      expect(screenAwake.acquireCount, 1);
    });

    test('does nothing at all when the type is switched off', () async {
      await disableFor(ActivityType.run);
      final container = makeContainer();

      container.read(_helperProvider).acquireFor(ActivityType.run);

      expect(screenAwake.held, isFalse);
      expect(screenAwake.acquireCount, 0);
    });

    test('release is idempotent, and safe before any acquire', () {
      final container = makeContainer();
      final helper = container.read(_helperProvider)..release();

      expect(screenAwake.releaseCount, 0);

      helper
        ..acquireFor(ActivityType.run)
        ..release()
        ..release()
        ..release();

      expect(screenAwake.held, isFalse);
      expect(screenAwake.releaseCount, 1);
    });

    test('a repeated acquire does not stack up locks', () {
      final container = makeContainer();
      final helper = container.read(_helperProvider)
        ..acquireFor(ActivityType.run)
        ..acquireFor(ActivityType.run);

      expect(screenAwake.acquireCount, 1);

      helper.release();
      expect(screenAwake.held, isFalse);
    });

    test('following a new type releases nothing that is still wanted', () {
      final container = makeContainer();
      final helper = container.read(_helperProvider)
        ..acquireFor(ActivityType.yoga)
        ..acquireFor(ActivityType.pilates);

      expect(screenAwake.held, isTrue);

      helper.release();
      expect(screenAwake.held, isFalse);
    });
  });

  group('HIIT tracker', () {
    test('start takes the lock, finish gives it back', () async {
      final container = makeContainer();
      final controller = container.read(
        hiitTrackerControllerProvider.notifier,
      )..startWorkoutIfNeeded();

      expect(screenAwake.held, isTrue);

      await controller.finishWorkout();

      expect(screenAwake.held, isFalse);
    });

    test('start takes no lock when HIIT is switched off', () async {
      await disableFor(ActivityType.hiit);
      final container = makeContainer();

      container
          .read(hiitTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();

      expect(screenAwake.held, isFalse);
    });

    test('discard gives the lock back', () {
      final container = makeContainer();
      container.read(hiitTrackerControllerProvider.notifier)
        ..startWorkoutIfNeeded()
        ..discardWorkout();

      expect(screenAwake.held, isFalse);
    });

    test('a failed save still gives the lock back', () async {
      repository.failSaves = true;
      final container = makeContainer();
      final controller = container.read(
        hiitTrackerControllerProvider.notifier,
      )..startWorkoutIfNeeded();

      await expectLater(controller.finishWorkout(), throwsA(isA<Object>()));

      expect(screenAwake.held, isFalse);
    });

    test(
      'switching the setting off mid-workout releases immediately',
      () async {
        final container = makeContainer();
        container
            .read(hiitTrackerControllerProvider.notifier)
            .startWorkoutIfNeeded();
        expect(screenAwake.held, isTrue);

        // She is on the HIIT hub with the workout running behind her.
        await container
            .read(screenAwakePreferenceProvider(ActivityType.hiit).notifier)
            .set(enabled: false);

        expect(screenAwake.held, isFalse);
      },
    );

    test('switching it back on mid-workout takes the lock again', () async {
      await disableFor(ActivityType.hiit);
      final container = makeContainer();
      container
          .read(hiitTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();
      expect(screenAwake.held, isFalse);

      await container
          .read(screenAwakePreferenceProvider(ActivityType.hiit).notifier)
          .set(enabled: true);

      expect(screenAwake.held, isTrue);
    });

    test('a change made while nothing is running takes no lock', () async {
      await disableFor(ActivityType.hiit);
      final container = makeContainer();

      await container
          .read(screenAwakePreferenceProvider(ActivityType.hiit).notifier)
          .set(enabled: true);

      expect(screenAwake.held, isFalse);
    });
  });

  group('Swim tracker', () {
    test('start takes the lock, discard gives it back', () {
      final container = makeContainer();
      container.read(swimTrackerControllerProvider.notifier)
        ..startWorkoutIfNeeded()
        ..discardWorkout();

      expect(screenAwake.acquireCount, 1);
      expect(screenAwake.held, isFalse);
    });

    test('start takes no lock when Swim is switched off', () async {
      await disableFor(ActivityType.swim);
      final container = makeContainer();

      container
          .read(swimTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();

      expect(screenAwake.held, isFalse);
    });

    test('finish gives the lock back', () async {
      final container = makeContainer();
      final controller = container.read(
        swimTrackerControllerProvider.notifier,
      )..startWorkoutIfNeeded();

      await controller.finishWorkout();

      expect(screenAwake.held, isFalse);
    });
  });

  group('Strength tracker', () {
    test('start takes the lock, finish gives it back', () async {
      final container = makeContainer();
      final controller = container.read(
        strengthTrackerControllerProvider.notifier,
      );

      await controller.startWorkout();
      expect(screenAwake.held, isTrue);

      await controller.finishWorkout();
      expect(screenAwake.held, isFalse);
    });

    test('start takes no lock when Strength is switched off', () async {
      await disableFor(ActivityType.strength);
      final container = makeContainer();

      await container
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkout();

      expect(screenAwake.held, isFalse);
    });

    test('the legacy startWorkoutIfNeeded entry point takes it too', () async {
      final container = makeContainer();
      final controller = container.read(
        strengthTrackerControllerProvider.notifier,
      )..startWorkoutIfNeeded();

      // startWorkoutIfNeeded fires startWorkout unawaited.
      await Future<void>.delayed(Duration.zero);
      expect(screenAwake.held, isTrue);

      controller.discardWorkout();
      expect(screenAwake.held, isFalse);
    });
  });

  group('Mindful tracker', () {
    test('start takes the lock for the type it was started with', () {
      final container = makeContainer();
      container
          .read(mindfulTrackerControllerProvider.notifier)
          .startSessionIfNeeded(ActivityType.yoga);

      expect(screenAwake.held, isTrue);
    });

    test(
      'a Pilates session obeys the Pilates switch, not the Yoga one',
      () async {
        await disableFor(ActivityType.pilates);
        final container = makeContainer();

        container
            .read(mindfulTrackerControllerProvider.notifier)
            .startSessionIfNeeded(ActivityType.pilates);

        expect(screenAwake.held, isFalse);
      },
    );

    test('discard gives the lock back', () {
      final container = makeContainer();
      container.read(mindfulTrackerControllerProvider.notifier)
        ..startSessionIfNeeded(ActivityType.yoga)
        ..discardSession();

      expect(screenAwake.held, isFalse);
    });

    test('finish gives the lock back', () async {
      final container = makeContainer();
      final controller = container.read(
        mindfulTrackerControllerProvider.notifier,
      )..startSessionIfNeeded(ActivityType.pilates);

      await controller.finishSession();

      expect(screenAwake.held, isFalse);
    });
  });

  group('GPS recording controller', () {
    test('start takes the lock once the session is open', () async {
      final container = makeContainer();

      await container
          .read(recordingControllerProvider.notifier)
          .start(ActivityType.run);

      expect(screenAwake.held, isTrue);
    });

    test('start takes no lock when that type is switched off', () async {
      await disableFor(ActivityType.walk);
      final container = makeContainer();

      await container
          .read(recordingControllerProvider.notifier)
          .start(ActivityType.walk);

      expect(screenAwake.held, isFalse);
    });

    test('discard gives the lock back', () async {
      final container = makeContainer();
      final controller = container.read(
        recordingControllerProvider.notifier,
      );

      await controller.start(ActivityType.run);
      await controller.discard();

      expect(screenAwake.held, isFalse);
    });

    test('finish gives the lock back even when the save fails', () async {
      repository.failSaves = true;
      final container = makeContainer();
      final controller = container.read(
        recordingControllerProvider.notifier,
      );

      await controller.start(ActivityType.run);
      await controller.finish();

      expect(
        container.read(recordingControllerProvider).lifecycle,
        RecordingLifecycle.saveFailed,
      );
      expect(screenAwake.held, isFalse);
    });
  });

  group('Yoga sequence runner', () {
    YogaSequence sequence() {
      final at = DateTime.utc(2026);
      return YogaSequence(
        id: 'seq-1',
        name: 'Morning flow',
        createdAt: at,
        updatedAt: at,
        poses: const [YogaPose(name: 'Mountain', holdSeconds: 30)],
      );
    }

    test('a sequence obeys the Yoga hub switch', () async {
      await disableFor(ActivityType.yoga);
      final container = makeContainer();

      container
          .read(yogaSequenceRunnerControllerProvider.notifier)
          .start(sequence());

      expect(screenAwake.held, isFalse);
    });

    test('start takes the lock and discard gives it back', () {
      final container = makeContainer();
      container.read(yogaSequenceRunnerControllerProvider.notifier)
        ..start(sequence())
        ..discard();

      expect(screenAwake.acquireCount, 1);
      expect(screenAwake.held, isFalse);
    });

    test('two practices in a row do not stack up locks', () {
      final container = makeContainer();
      final controller =
          container.read(
              yogaSequenceRunnerControllerProvider.notifier,
            )
            ..start(sequence())
            ..start(sequence());

      expect(screenAwake.acquireCount, 1);

      controller.discard();
      expect(screenAwake.held, isFalse);
    });
  });

  group('two trackers at once', () {
    test('one holder releasing leaves the other still holding', () {
      final container = makeContainer();
      final first = container.read(_helperProvider)
        ..acquireFor(ActivityType.run);
      final second = container.read(_otherHelperProvider)
        ..acquireFor(ActivityType.hiit);

      expect(screenAwake.holders, 2);

      // A tracker that releases from both finish() and dispose() is doing
      // the right thing, and must still only count once.
      second
        ..release()
        ..release();

      expect(
        screenAwake.held,
        isTrue,
        reason:
            'the second tracker letting go must not switch the screen off '
            'under the first, which is still running',
      );
      expect(screenAwake.holders, 1);

      first.release();

      expect(screenAwake.held, isFalse);
      expect(screenAwake.holders, 0);
    });

    test(
      'discarding a strength workout leaves a running recording holding',
      () async {
        // The real scenario: a GPS run in progress, she opens the strength
        // hub on top of it (a priority fallthrough by design - see
        // active_workout_summary.dart), starts and then discards.
        final container = makeContainer();
        final recording = container.read(
          recordingControllerProvider.notifier,
        );
        await recording.start(ActivityType.run);
        expect(screenAwake.held, isTrue);

        final strength = container.read(
          strengthTrackerControllerProvider.notifier,
        );
        await strength.startWorkout();
        expect(screenAwake.holders, 2);

        strength.discardWorkout();

        expect(
          screenAwake.held,
          isTrue,
          reason:
              'the run is still recording - its screen must not sleep '
              'because a different tracker finished',
        );
        expect(screenAwake.holders, 1);

        await recording.discard();

        expect(screenAwake.held, isFalse);
      },
    );
  });

  group('disposal', () {
    test('tearing the container down releases every tracker lock', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          screenAwakeProvider.overrideWithValue(screenAwake),
          activityRepositoryProvider.overrideWithValue(repository),
        ],
      );

      container
          .read(hiitTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();
      expect(screenAwake.held, isTrue);

      container.dispose();

      expect(screenAwake.held, isFalse);
    });
  });
}
