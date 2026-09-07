import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/platform/speech/speech_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';

import '../../core/platform/audio/fake_audio_cue_player.dart';
import '../../core/platform/speech/fake_speech_adapter.dart';

/// Controllable fake: permission results are scripted per test, and
/// [fixes] is a broadcast stream the test drives directly via [emit] -
/// mirrors the "scripted StreamController" shape called for in the task
/// brief rather than a mocking framework (no mocktail dependency in this
/// project).
class _FakeLocationAdapter implements LocationAdapter {
  LocationPermissionResult checkPermissionResult =
      LocationPermissionResult.granted;
  LocationPermissionResult requestPermissionResult =
      LocationPermissionResult.granted;
  bool fixesCalled = false;
  int fixesCallCount = 0;

  /// When set, [checkPermission] suspends on this completer's future before
  /// resolving - lets a test call `start()` and land mid-permission-await
  /// deterministically, instead of racing a real async gap.
  Completer<void>? checkPermissionGate;

  final _fixController = StreamController<LocationFix>.broadcast();

  @override
  LocationCapabilities get capabilities =>
      const LocationCapabilities(canRecordActivities: true);

  @override
  Future<LocationPermissionResult> checkPermission() async {
    final gate = checkPermissionGate;
    if (gate != null) await gate.future;
    return checkPermissionResult;
  }

  @override
  Future<LocationPermissionResult> requestPermission() async =>
      requestPermissionResult;

  @override
  Stream<LocationFix> fixes() {
    fixesCalled = true;
    fixesCallCount++;
    return _fixController.stream;
  }

  @override
  Future<LocationFix> getCurrentPosition() => throw UnimplementedError();

  void emit(LocationFix fix) => _fixController.add(fix);

  void emitError(Object error) => _fixController.addError(error);

  Future<void> close() => _fixController.close();
}

/// Wraps a real (in-memory) [ActivityRepository] but fails the first
/// [saveRecordedActivity] call, then delegates normally - lets B2's "save
/// failure must not lose the workout" tests drive a real failure/retry
/// cycle while still asserting against real persisted rows afterward.
class _FailOnceActivityRepository implements ActivityRepository {
  _FailOnceActivityRepository(this._delegate);

  final ActivityRepository _delegate;
  int saveActivityCalls = 0;
  bool _shouldFail = true;

  @override
  Stream<List<Activity>> watchActivities() => _delegate.watchActivities();

  @override
  Future<List<Activity>> getActivities() => _delegate.getActivities();

  @override
  Stream<Activity?> watchActivity(String id) => _delegate.watchActivity(id);

  @override
  Future<Activity?> getActivity(String id) => _delegate.getActivity(id);

  @override
  Future<void> saveActivity(Activity activity) =>
      _delegate.saveActivity(activity);

  @override
  Future<void> saveRecordedActivity(
    Activity activity,
    List<ActivitySample> samples,
  ) async {
    saveActivityCalls++;
    if (_shouldFail) {
      _shouldFail = false;
      throw const StorageException(message: 'simulated save failure');
    }
    await _delegate.saveRecordedActivity(activity, samples);
  }

  @override
  Future<void> deleteActivity(String id) => _delegate.deleteActivity(id);

  @override
  Future<void> insertSamples(List<ActivitySample> samples) =>
      _delegate.insertSamples(samples);

  @override
  Stream<List<ActivitySample>> watchSamples(String activityId) =>
      _delegate.watchSamples(activityId);

  @override
  Future<List<ActivitySample>> getSamples(String activityId) =>
      _delegate.getSamples(activityId);

  @override
  Future<Map<String, List<ActivitySample>>> getSamplesForActivities(
    List<String> ids,
  ) => _delegate.getSamplesForActivities(ids);

  @override
  Future<void> deleteAllData() => _delegate.deleteAllData();
}

/// Controllable clock override for [recordingClockProvider] - a mutable
/// `now` field, read by both the `RecordingSession` the controller creates
/// and the forgotten-end ticker comparison, so a test can jump the session's
/// notion of "now" forward by minutes without waiting out real wall-clock
/// time (see `recording_controller.dart`'s `recordingClockProvider` doc).
class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

void main() {
  final base = DateTime.utc(2026);

  late _FakeLocationAdapter locationAdapter;
  late db.AppDatabase database;
  late FakeSpeechAdapter fakeSpeech;
  late FakeAudioCuePlayer fakePlayer;
  late ProviderContainer container;

  setUp(() {
    locationAdapter = _FakeLocationAdapter();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    fakeSpeech = FakeSpeechAdapter();
    fakePlayer = FakeAudioCuePlayer();
    container = ProviderContainer(
      overrides: [
        locationAdapterProvider.overrideWithValue(locationAdapter),
        appDatabaseProvider.overrideWithValue(database),
        speechAdapterProvider.overrideWithValue(fakeSpeech),
        audioCuePlayerProvider.overrideWithValue(fakePlayer),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
    addTearDown(locationAdapter.close);
  });

  RecordingController controller() =>
      container.read(recordingControllerProvider.notifier);

  LocationFix fixAt(Duration offset, {double latitude = 0}) {
    return LocationFix(
      timestamp: base.add(offset),
      latitude: latitude,
      longitude: 0,
      speedMetersPerSecond: 2,
    );
  }

  test(
    'permission denied surfaces an error state and starts no session',
    () async {
      locationAdapter
        ..checkPermissionResult = LocationPermissionResult.denied
        ..requestPermissionResult = LocationPermissionResult.denied;

      await controller().start(ActivityType.run);

      final state = container.read(recordingControllerProvider);
      expect(state.lifecycle, RecordingLifecycle.idle);
      expect(state.permissionResult, LocationPermissionResult.denied);
      expect(locationAdapter.fixesCalled, isFalse);
    },
  );

  test('granted permission: fixes flow into live state', () async {
    await controller().start(ActivityType.run);
    expect(
      container.read(recordingControllerProvider).lifecycle,
      RecordingLifecycle.waitingForSignal,
    );
    expect(locationAdapter.fixesCalled, isTrue);

    locationAdapter.emit(fixAt(Duration.zero));
    await Future<void>.delayed(Duration.zero);
    var state = container.read(recordingControllerProvider);
    expect(state.lifecycle, RecordingLifecycle.recording);
    expect(state.sampleCount, 1);

    // ~11m north, 2s later: well under the 10 m/s run implausible-jump
    // ceiling, so this is accepted and moves the distance counter.
    locationAdapter.emit(fixAt(const Duration(seconds: 2), latitude: 0.0001));
    await Future<void>.delayed(Duration.zero);
    state = container.read(recordingControllerProvider);
    expect(state.sampleCount, 2);
    expect(state.distanceMeters, greaterThan(0));
  });

  test(
    'finish() saves the Activity + samples to Drift with source == recorded',
    () async {
      await controller().start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);
      locationAdapter.emit(fixAt(const Duration(seconds: 2), latitude: 0.0001));
      await Future<void>.delayed(Duration.zero);

      final activityId = await controller().finish();
      expect(activityId, isNotNull);

      final activityRows = await database.select(database.activities).get();
      expect(activityRows, hasLength(1));
      expect(activityRows.single.id, activityId);
      expect(activityRows.single.source, 'recorded');
      expect(activityRows.single.activityType, 'run');

      final sampleRows = await database.select(database.activitySamples).get();
      expect(sampleRows, hasLength(2));
      expect(sampleRows.every((s) => s.activityId == activityId), isTrue);
      // Both fixes were emitted while recording (never paused), so neither
      // sample is tagged paused (F1).
      expect(sampleRows.every((s) => !s.isPaused), isTrue);

      final state = container.read(recordingControllerProvider);
      expect(state.lifecycle, RecordingLifecycle.saved);
      expect(state.savedActivityId, activityId);
    },
  );

  test(
    'a fix received while manually paused is persisted with isPaused true '
    '(F1)',
    () async {
      await controller().start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      controller().pause();
      // ~33m north over 5s (~6.7 m/s) - comfortably under the 10 m/s run
      // implausible-jump ceiling, so this fix is accepted (and tagged
      // paused) rather than silently discarded.
      locationAdapter.emit(
        fixAt(const Duration(seconds: 5), latitude: 0.0003),
      );
      await Future<void>.delayed(Duration.zero);

      final activityId = await controller().finish();
      expect(activityId, isNotNull);

      final sampleRows = await (database.select(
        database.activitySamples,
      )..orderBy([(t) => OrderingTerm.asc(t.timestampMs)])).get();
      expect(sampleRows, hasLength(2));
      expect(sampleRows[0].isPaused, isFalse);
      expect(sampleRows[1].isPaused, isTrue);
    },
  );

  test(
    'start(routeId:) stamps the finished activity with the route link',
    () async {
      await controller().start(ActivityType.run, routeId: 'route-42');
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      final activityId = await controller().finish();
      expect(activityId, isNotNull);

      final row = await database.select(database.activities).getSingle();
      expect(row.routeId, 'route-42');
    },
  );

  test(
    'a plain start() after a routeId recording does not inherit the old '
    'route link (reset clears it)',
    () async {
      await controller().start(ActivityType.run, routeId: 'route-42');
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);
      await controller().finish();

      controller().reset();
      await controller().start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);
      final secondId = await controller().finish();

      final rows = await database.select(database.activities).get();
      final second = rows.singleWhere((r) => r.id == secondId);
      expect(second.routeId, isNull);
    },
  );

  test('discard() saves nothing', () async {
    await controller().start(ActivityType.run);
    locationAdapter.emit(fixAt(Duration.zero));
    await Future<void>.delayed(Duration.zero);

    await controller().discard();

    final activityRows = await database.select(database.activities).get();
    expect(activityRows, isEmpty);
    final sampleRows = await database.select(database.activitySamples).get();
    expect(sampleRows, isEmpty);
    expect(
      container.read(recordingControllerProvider).lifecycle,
      RecordingLifecycle.discarded,
    );
  });

  test(
    'reset() allows a full second recording cycle after a save (B1)',
    () async {
      await controller().start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      final firstId = await controller().finish();
      expect(firstId, isNotNull);
      expect(
        container.read(recordingControllerProvider).lifecycle,
        RecordingLifecycle.saved,
      );

      controller().reset();
      expect(
        container.read(recordingControllerProvider).lifecycle,
        RecordingLifecycle.idle,
      );

      await controller().start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      final secondId = await controller().finish();
      expect(secondId, isNotNull);
      expect(secondId, isNot(firstId));

      final activityRows = await database.select(database.activities).get();
      expect(activityRows, hasLength(2));
    },
  );

  test(
    'stream error AUTO-pauses the session and surfaces an error; finish '
    'still saves (S3)',
    () async {
      await controller().start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      locationAdapter.emitError(Exception('boom'));
      await Future<void>.delayed(Duration.zero);

      final errorState = container.read(recordingControllerProvider);
      expect(
        errorState.lifecycle,
        RecordingLifecycle.autoPaused,
        reason:
            'a dead fix stream is a forgotten-end candidate, not a '
            'deliberate stop - a manual pause here would exclude it from '
            "finish()'s elapsed-time trim",
      );
      expect(errorState.autoPausedSince, isNotNull);
      expect(errorState.error, isNotNull);

      final activityId = await controller().finish();
      expect(activityId, isNotNull);

      final activityRows = await database.select(database.activities).get();
      expect(activityRows, hasLength(1));
    },
  );

  test(
    'a stream error hours before finish() does not bank the dead hours as '
    'elapsed time',
    () async {
      final adapter = _FakeLocationAdapter();
      final testDb = db.AppDatabase.forTesting(NativeDatabase.memory());
      final clock = _FakeClock(base);
      final scoped = ProviderContainer(
        overrides: [
          locationAdapterProvider.overrideWithValue(adapter),
          appDatabaseProvider.overrideWithValue(testDb),
          recordingClockProvider.overrideWithValue(clock.call),
          speechAdapterProvider.overrideWithValue(fakeSpeech),
          audioCuePlayerProvider.overrideWithValue(fakePlayer),
        ],
      );
      addTearDown(scoped.dispose);
      addTearDown(testDb.close);
      addTearDown(adapter.close);

      final ctrl = scoped.read(recordingControllerProvider.notifier);
      await ctrl.start(ActivityType.run);
      adapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      clock.now = base.add(const Duration(minutes: 20));
      adapter.emitError(Exception('permission revoked'));
      await Future<void>.delayed(Duration.zero);

      // The user only notices three hours later.
      clock.now = base.add(const Duration(minutes: 200));
      await ctrl.finish();

      final row = (await testDb.select(testDb.activities).get()).single;
      expect(
        Duration(milliseconds: row.elapsedTimeMs),
        const Duration(minutes: 20),
        reason:
            'elapsed must end at the signal-loss boundary, not at the '
            'finish() call three hours later',
      );
    },
  );

  group('start() re-entrancy (S1)', () {
    test('two immediate start() calls only subscribe to fixes once', () async {
      final first = controller().start(ActivityType.run);
      final second = controller().start(ActivityType.run);
      await Future.wait([first, second]);

      expect(locationAdapter.fixesCallCount, 1);
    });

    test(
      'discard() during the permission await prevents the session from '
      'recording',
      () async {
        locationAdapter.checkPermissionGate = Completer<void>();

        final startFuture = controller().start(ActivityType.run);
        await Future<void>.delayed(Duration.zero);
        expect(
          container.read(recordingControllerProvider).lifecycle,
          RecordingLifecycle.requestingPermission,
        );

        await controller().discard();
        expect(
          container.read(recordingControllerProvider).lifecycle,
          RecordingLifecycle.discarded,
        );

        locationAdapter.checkPermissionGate!.complete();
        await startFuture;

        expect(locationAdapter.fixesCallCount, 0);
        expect(
          container.read(recordingControllerProvider).lifecycle,
          RecordingLifecycle.discarded,
          reason:
              'start() must abort without subscribing once discard() ran '
              'during the permission await',
        );
      },
    );
  });

  group('save failure must not lose the workout (B2)', () {
    /// Each test in this group needs its own container so
    /// `activityRepositoryProvider` can be overridden with a repo that
    /// fails on demand, independent of the plain `container`/`controller()`
    /// set up above (which uses the real always-succeeding repository).
    ({RecordingController controller, _FailOnceActivityRepository repo})
    buildFailingSetup() {
      final repo = _FailOnceActivityRepository(
        DriftActivityRepository(database),
      );
      final failContainer = ProviderContainer(
        overrides: [
          locationAdapterProvider.overrideWithValue(locationAdapter),
          appDatabaseProvider.overrideWithValue(database),
          activityRepositoryProvider.overrideWithValue(repo),
          speechAdapterProvider.overrideWithValue(fakeSpeech),
          audioCuePlayerProvider.overrideWithValue(fakePlayer),
        ],
      );
      addTearDown(failContainer.dispose);
      return (
        controller: failContainer.read(recordingControllerProvider.notifier),
        repo: repo,
      );
    }

    test(
      'finish() failure surfaces saveFailed and keeps the pending result',
      () async {
        final setup = buildFailingSetup();
        await setup.controller.start(ActivityType.run);
        locationAdapter.emit(fixAt(Duration.zero));
        await Future<void>.delayed(Duration.zero);

        final result = await setup.controller.finish();
        expect(result, isNull);
        expect(setup.controller.state.lifecycle, RecordingLifecycle.saveFailed);
        expect(setup.controller.state.error, isNotNull);
        expect(setup.repo.saveActivityCalls, 1);

        final activityRows = await database.select(database.activities).get();
        expect(activityRows, isEmpty);
      },
    );

    test(
      'retrySave() succeeds after a prior failure; activity + samples '
      'persisted exactly once',
      () async {
        final setup = buildFailingSetup();
        await setup.controller.start(ActivityType.run);
        locationAdapter.emit(fixAt(Duration.zero));
        await Future<void>.delayed(Duration.zero);

        final firstResult = await setup.controller.finish();
        expect(firstResult, isNull);
        expect(setup.controller.state.lifecycle, RecordingLifecycle.saveFailed);

        final retryResult = await setup.controller.retrySave();
        expect(retryResult, isNotNull);
        expect(setup.controller.state.lifecycle, RecordingLifecycle.saved);
        expect(setup.controller.state.savedActivityId, retryResult);
        expect(setup.controller.state.error, isNull);
        expect(setup.repo.saveActivityCalls, 2);

        final activityRows = await database.select(database.activities).get();
        expect(activityRows, hasLength(1));
        expect(activityRows.single.id, retryResult);
        final sampleRows = await database
            .select(database.activitySamples)
            .get();
        expect(sampleRows, hasLength(1));
      },
    );

    test('discard() from saveFailed clears the pending result', () async {
      final setup = buildFailingSetup();
      await setup.controller.start(ActivityType.run);
      locationAdapter.emit(fixAt(Duration.zero));
      await Future<void>.delayed(Duration.zero);

      await setup.controller.finish();
      expect(setup.controller.state.lifecycle, RecordingLifecycle.saveFailed);

      await setup.controller.discard();
      expect(setup.controller.state.lifecycle, RecordingLifecycle.discarded);

      final retryAfterDiscard = await setup.controller.retrySave();
      expect(
        retryAfterDiscard,
        isNull,
        reason: 'retrySave() is only legal from saveFailed',
      );

      final activityRows = await database.select(database.activities).get();
      expect(activityRows, isEmpty);
    });

    test(
      'resume() in saveFailed does not throw - the session is already '
      'finished',
      () async {
        final setup = buildFailingSetup();
        await setup.controller.start(ActivityType.run);
        locationAdapter.emit(fixAt(Duration.zero));
        await Future<void>.delayed(Duration.zero);

        await setup.controller.finish();
        expect(setup.controller.state.lifecycle, RecordingLifecycle.saveFailed);

        expect(setup.controller.resume, returnsNormally);
        expect(
          setup.controller.state.lifecycle,
          RecordingLifecycle.saveFailed,
          reason: 'resume() must no-op, not throw, once finished',
        );
      },
    );
  });

  group('forgotten-end prompt (episode tracking)', () {
    /// Each test in this group needs its own container with
    /// [recordingClockProvider] overridden to a controllable fake clock -
    /// independent of the plain `container`/`controller()` set up above
    /// (which uses real wall-clock time), matching the B2 group's
    /// `buildFailingSetup()` pattern.
    late _FakeLocationAdapter fakeAdapter;
    late db.AppDatabase fakeDb;
    late ProviderContainer fakeContainer;
    late _FakeClock fakeClock;

    RecordingController ctrl() =>
        fakeContainer.read(recordingControllerProvider.notifier);

    setUp(() {
      fakeAdapter = _FakeLocationAdapter();
      fakeDb = db.AppDatabase.forTesting(NativeDatabase.memory());
      fakeClock = _FakeClock(base);
      fakeContainer = ProviderContainer(
        overrides: [
          locationAdapterProvider.overrideWithValue(fakeAdapter),
          appDatabaseProvider.overrideWithValue(fakeDb),
          recordingClockProvider.overrideWithValue(fakeClock.call),
          speechAdapterProvider.overrideWithValue(fakeSpeech),
          audioCuePlayerProvider.overrideWithValue(fakePlayer),
        ],
      );
      addTearDown(fakeContainer.dispose);
      addTearDown(fakeDb.close);
      addTearDown(fakeAdapter.close);
    });

    Future<void> pump() => Future<void>.delayed(Duration.zero);

    /// Waits out at least one real tick of the controller's 1s
    /// `Timer.periodic` ticker so `_syncStateFromSession` re-evaluates
    /// `showForgottenEndPrompt` against whatever [fakeClock.now] was just
    /// jumped to - the fake clock controls the simulated "now", but the
    /// ticker itself is still a real timer.
    Future<void> awaitTick() =>
        Future<void>.delayed(const Duration(milliseconds: 1100));

    /// Starts a recording (fixed at lat/lon 0 throughout, so no fix is ever
    /// rejected as an implausible jump) and drives it into an auto-paused
    /// episode via a sustained low-speed streak, advancing [fakeClock.now]
    /// in lockstep with each fix so the session's back-dated auto-pause
    /// boundary (`RecordingSession.autoPausedAt`) lands on a value this
    /// helper can hand back for precise assertions.
    Future<DateTime> enterAutoPauseEpisode(
      RecordingController controller,
    ) async {
      await controller.start(ActivityType.run);
      await pump();

      fakeAdapter.emit(
        LocationFix(
          timestamp: fakeClock.now,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 2,
        ),
      );
      await pump();

      // Low-speed streak starts here - this is the clock value the
      // eventual auto-pause back-dates to.
      fakeClock.now = fakeClock.now.add(const Duration(seconds: 1));
      final boundary = fakeClock.now;
      fakeAdapter.emit(
        LocationFix(
          timestamp: boundary,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 0.2,
        ),
      );
      await pump();

      // 6s sustained -> triggers auto-pause.
      fakeClock.now = fakeClock.now.add(const Duration(seconds: 6));
      fakeAdapter.emit(
        LocationFix(
          timestamp: fakeClock.now,
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 0.2,
        ),
      );
      await pump();

      expect(
        fakeContainer.read(recordingControllerProvider).lifecycle,
        RecordingLifecycle.autoPaused,
      );
      expect(
        fakeContainer.read(recordingControllerProvider).autoPausedSince,
        boundary,
      );
      return boundary;
    }

    test(
      'no prompt at 9m59s into an episode; appears at exactly 10m0s',
      () async {
        final boundary = await enterAutoPauseEpisode(ctrl());

        fakeClock.now = boundary.add(
          const Duration(minutes: 9, seconds: 59),
        );
        await awaitTick();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isFalse,
          reason: '9m59s into the episode - just under the 10m threshold',
        );

        fakeClock.now = boundary.add(const Duration(minutes: 10));
        await awaitTick();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isTrue,
          reason: 'exactly 10m into the episode - threshold reached',
        );
      },
    );

    test(
      'dismissForgottenEndPrompt() suppresses the prompt for the rest of '
      'the episode',
      () async {
        final controller = ctrl();
        final boundary = await enterAutoPauseEpisode(controller);

        fakeClock.now = boundary.add(const Duration(minutes: 10));
        await awaitTick();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isTrue,
        );

        controller.dismissForgottenEndPrompt();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isFalse,
        );

        // Stays hidden for the rest of this same episode, no matter how
        // much more (simulated) time passes.
        fakeClock.now = boundary.add(const Duration(minutes: 40));
        await awaitTick();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isFalse,
        );
      },
    );

    test(
      'movement resume then a fresh auto-pause re-arms a dismissed prompt',
      () async {
        final controller = ctrl();
        final firstBoundary = await enterAutoPauseEpisode(controller);

        fakeClock.now = firstBoundary.add(const Duration(minutes: 10));
        await awaitTick();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isTrue,
        );
        controller.dismissForgottenEndPrompt();

        // Movement resumes - leaves autoPaused.
        fakeClock.now = fakeClock.now.add(const Duration(seconds: 1));
        fakeAdapter.emit(
          LocationFix(
            timestamp: fakeClock.now,
            latitude: 0,
            longitude: 0,
            speedMetersPerSecond: 1.5,
          ),
        );
        await pump();
        expect(
          fakeContainer.read(recordingControllerProvider).lifecycle,
          RecordingLifecycle.recording,
        );
        expect(
          fakeContainer.read(recordingControllerProvider).autoPausedSince,
          isNull,
        );

        // A fresh auto-pause episode begins.
        fakeClock.now = fakeClock.now.add(const Duration(seconds: 1));
        final secondBoundary = fakeClock.now;
        fakeAdapter.emit(
          LocationFix(
            timestamp: secondBoundary,
            latitude: 0,
            longitude: 0,
            speedMetersPerSecond: 0.2,
          ),
        );
        await pump();
        fakeClock.now = fakeClock.now.add(const Duration(seconds: 6));
        fakeAdapter.emit(
          LocationFix(
            timestamp: fakeClock.now,
            latitude: 0,
            longitude: 0,
            speedMetersPerSecond: 0.2,
          ),
        );
        await pump();
        expect(
          fakeContainer.read(recordingControllerProvider).lifecycle,
          RecordingLifecycle.autoPaused,
        );
        expect(
          fakeContainer.read(recordingControllerProvider).autoPausedSince,
          secondBoundary,
        );
        expect(secondBoundary, isNot(firstBoundary));

        fakeClock.now = secondBoundary.add(const Duration(minutes: 10));
        await awaitTick();
        expect(
          fakeContainer
              .read(recordingControllerProvider)
              .showForgottenEndPrompt,
          isTrue,
          reason:
              're-armed: this is a new episode with its own boundary - the '
              'earlier dismissal must not carry over',
        );
      },
    );

    test(
      'finish() from the banner persists the trimmed activity - '
      'elapsedTimeMs equals the auto-pause boundary exactly',
      () async {
        final controller = ctrl();
        final boundary = await enterAutoPauseEpisode(controller);

        // Forgotten for an hour before "Finish" on the banner is tapped.
        fakeClock.now = boundary.add(const Duration(hours: 1));
        final activityId = await controller.finish();
        expect(activityId, isNotNull);

        final row = await fakeDb.select(fakeDb.activities).getSingle();
        expect(
          row.elapsedTimeMs,
          boundary.difference(base).inMilliseconds,
          reason:
              'the persisted elapsedTimeMs must land exactly on the '
              'auto-pause boundary, not on the hour-later finish() call '
              'time',
        );
      },
    );
  });

  group('Audio coaching cues integration', () {
    test(
      'start() announces workout started and preloads audio chime',
      () async {
        await controller().start(ActivityType.run);
        expect(fakePlayer.preloadCount, 1);
        expect(fakeSpeech.spokenUtterances, contains('Workout started.'));
        expect(fakePlayer.chimeCount, 1);
      },
    );

    test('pause() and resume() announce status transitions', () async {
      await controller().start(ActivityType.run);
      fakeSpeech.spokenUtterances.clear();
      fakePlayer.chimeCount = 0;

      controller().pause();
      expect(fakeSpeech.spokenUtterances, contains('Workout paused.'));
      expect(fakePlayer.chimeCount, 1);

      controller().resume();
      expect(fakeSpeech.spokenUtterances, contains('Workout resumed.'));
    });

    test('finish() announces completion summary', () async {
      await controller().start(ActivityType.run);
      fakeSpeech.spokenUtterances.clear();

      final id = await controller().finish();
      expect(id, isNotNull);
      expect(
        fakeSpeech.spokenUtterances.any(
          (u) => u.startsWith('Workout completed.'),
        ),
        isTrue,
      );
    });

    test(
      'toggleAudioMute() mutes audio cues and stops active speech',
      () async {
        await controller().start(ActivityType.run);
        expect(
          container.read(recordingControllerProvider).isAudioMuted,
          isFalse,
        );

        controller().toggleAudioMute();
        expect(
          container.read(recordingControllerProvider).isAudioMuted,
          isTrue,
        );
        expect(fakeSpeech.stopCount, greaterThanOrEqualTo(1));

        fakeSpeech.spokenUtterances.clear();
        controller().pause();
        expect(fakeSpeech.spokenUtterances, isEmpty);

        controller().toggleAudioMute();
        expect(
          container.read(recordingControllerProvider).isAudioMuted,
          isFalse,
        );
        controller().resume();
        expect(fakeSpeech.spokenUtterances, contains('Workout resumed.'));
      },
    );

    test('split distance crossing triggers split announcement', () async {
      await controller().start(ActivityType.run);
      fakeSpeech.spokenUtterances.clear();

      // Emit first fix
      locationAdapter.emit(
        LocationFix(
          timestamp: DateTime.utc(2026),
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 3,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      // Emit fix 1005 metres away (approx 0.00904 degrees latitude)
      locationAdapter.emit(
        LocationFix(
          timestamp: DateTime.utc(2026, 1, 1, 0, 5),
          latitude: 0.00904,
          longitude: 0,
          speedMetersPerSecond: 3,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final state = container.read(recordingControllerProvider);
      expect(state.distanceMeters, greaterThanOrEqualTo(1000));
      expect(
        fakeSpeech.spokenUtterances.any(
          (u) => u.contains('Split 1') && u.contains('kilometer'),
        ),
        isTrue,
      );
    });

    test('finish saves avgHeartRate when provided or sampled', () async {
      await controller().start(ActivityType.run);
      locationAdapter.emit(
        LocationFix(
          timestamp: DateTime.utc(2026),
          latitude: 0,
          longitude: 0,
          speedMetersPerSecond: 3,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final id = await controller().finish(avgHeartRate: 154);
      expect(id, isNotNull);

      final repo = container.read(activityRepositoryProvider);
      final saved = await repo.getActivity(id!);
      expect(saved, isNotNull);
      expect(saved!.avgHeartRate, 154);
    });

    test(
      'first GPS fix records position to routeLastRecordedLocationProvider',
      () async {
        expect(container.read(routeLastRecordedLocationProvider), isNull);

        await controller().start(ActivityType.run);
        locationAdapter.emit(
          LocationFix(
            timestamp: DateTime.utc(2026),
            latitude: -33.8688,
            longitude: 151.2093,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        final recorded = container.read(routeLastRecordedLocationProvider);
        expect(recorded, isNotNull);
        expect(recorded!.latitude, closeTo(-33.8688, 0.0001));
        expect(recorded.longitude, closeTo(151.2093, 0.0001));
      },
    );
  });
}
