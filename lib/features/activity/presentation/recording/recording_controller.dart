import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_player.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/location/location_adapter.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/core/platform/location/location_providers.dart';
import 'package:menfit_app/core/platform/speech/speech_adapter.dart';
import 'package:menfit_app/core/platform/speech/speech_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_cue_engine.dart';
import 'package:menfit_app/features/activity/domain/recording_session.dart';
import 'package:menfit_app/features/activity/presentation/recording/audio_coaching_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:menfit_app/features/wearables/ble_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recording_controller.freezed.dart';
part 'recording_controller.g.dart';

/// UI-facing phase of an in-progress (or not-yet-started) recording.
///
/// A superset of [RecordingSessionStatus]: [idle]/[requestingPermission]/
/// [waitingForSignal]/[saving]/[saveFailed]/[saved]/[discarded] are
/// controller-only phases with no equivalent in the pure domain session;
/// [recording]/[paused]/[autoPaused] mirror the session's own status once it
/// exists.
enum RecordingLifecycle {
  /// Pre-start view; no session exists yet.
  idle,

  /// [RecordingController.start] is checking/requesting location
  /// permission.
  requestingPermission,

  /// Permission granted, session started, but no GPS fix has arrived yet.
  waitingForSignal,
  recording,
  paused,
  autoPaused,

  /// [RecordingController.finish] is persisting the activity.
  saving,

  /// The session finished (no further fixes are accepted, resume is
  /// impossible) but persisting it failed — [RecordingControllerState.error]
  /// carries the message and the built activity/samples are held so
  /// [RecordingController.retrySave] can retry without re-recording.
  saveFailed,

  /// Persisted successfully — [RecordingControllerState.savedActivityId]
  /// carries the new activity's id for the screen to navigate to.
  saved,

  /// [RecordingController.discard] was called — nothing was persisted.
  discarded,
}

/// Live state of an in-progress recording, watched by `record_screen.dart`.
@freezed
abstract class RecordingControllerState with _$RecordingControllerState {
  const factory RecordingControllerState({
    @Default(RecordingLifecycle.idle) RecordingLifecycle lifecycle,
    ActivityType? activityType,
    @Default(Duration.zero) Duration elapsedTime,
    @Default(Duration.zero) Duration movingTime,
    @Default(0) double distanceMeters,
    double? elevationGainMeters,
    double? currentPaceSecondsPerKm,
    @Default(0) int sampleCount,

    /// The back-dated clock boundary the current auto-pause episode began
    /// at (mirrors [RecordingSession.autoPausedAt]) - `null` whenever
    /// [lifecycle] isn't [RecordingLifecycle.autoPaused]. Kept as its own
    /// state field (rather than left for the screen to derive) so
    /// [RecordingController]'s ticker can compare it against "now" once a
    /// second without the screen needing its own timer.
    DateTime? autoPausedSince,

    /// Whether `record_screen.dart` should show the "Looks like you've
    /// stopped" forgotten-end prompt: true once [autoPausedSince] is at
    /// least 10 minutes in the past and
    /// [RecordingController.dismissForgottenEndPrompt] hasn't been called
    /// for the current auto-pause episode. Re-evaluated on
    /// [RecordingController]'s existing 1s ticker - see
    /// [RecordingController._syncStateFromSession].
    @Default(false) bool showForgottenEndPrompt,

    /// Set when permission was checked/requested and came back anything
    /// other than granted — lets the screen show a specific CTA (e.g. "Open
    /// Settings" for [LocationPermissionResult.deniedForever]).
    LocationPermissionResult? permissionResult,

    /// Already-resolved user-facing message (via `userMessageFor`) for a
    /// failure — never a raw exception, per `error_handling.md`'s
    /// values-not-exceptions convention for expected UI-surfaced failures.
    String? error,
    String? savedActivityId,
    String? routeId,
    LocationFix? latestFix,
    @Default([]) List<LocationFix> trackPoints,
    double? currentElevationMeters,
    double? currentSpeedMps,
    @Default(false) bool isAudioMuted,
  }) = _RecordingControllerState;
}

/// Wall-clock source for [RecordingController]: both the [RecordingSession]
/// it creates and its forgotten-end ticker comparison
/// ([RecordingController._syncStateFromSession]) read "now" through this
/// rather than calling [DateTime.now] directly, so a test can override it
/// with a controllable fake clock and jump forward by minutes instead of
/// waiting out real wall-clock time (see `recording_controller_test.dart`).
/// Defaults to real wall-clock time, so production behaviour is unchanged.
@Riverpod(keepAlive: true)
DateTime Function() recordingClock(Ref ref) => DateTime.now;

/// Orchestrates a GPS recording end to end: permission flow ->
/// [RecordingSession] feeding -> persistence.
///
/// `keepAlive: true` deliberately — a recording must survive the user
/// navigating away from `record_screen.dart` (e.g. checking another tab
/// mid-run); only [finish] or [discard] end it. This mirrors why the
/// Android foreground-service notification exists at all (ADR 008): the
/// recording is a long-lived background operation, not screen-scoped state.
@Riverpod(keepAlive: true)
class RecordingController extends _$RecordingController {
  RecordingSession? _session;
  StreamSubscription<LocationFix>? _fixSubscription;
  Timer? _ticker;
  bool _hasReceivedFirstFix = false;
  int _startEpoch = 0;
  AudioCueEngine? _audioCueEngine;
  RecordingSessionStatus _lastSessionStatus = RecordingSessionStatus.ready;
  SpeechAdapter? _speechAdapter;
  AudioCuePlayer? _audioCuePlayer;

  SpeechAdapter get _speech {
    final adapter = _speechAdapter;
    if (adapter != null) return adapter;
    final created = ref.read(speechAdapterProvider);
    _speechAdapter = created;
    return created;
  }

  AudioCuePlayer get _chimePlayer {
    final player = _audioCuePlayer;
    if (player != null) return player;
    final created = ref.read(audioCuePlayerProvider);
    _audioCuePlayer = created;
    return created;
  }

  /// The screen lock, honouring the hub switch of whichever type is being
  /// recorded (Run, Walk, Hike and Ride each have their own) — including a
  /// change made mid-recording.
  late final TrackerScreenAwake _screenAwake = TrackerScreenAwake(ref);

  /// Set by [finish], cleared once [_persist] succeeds or [discard]/[reset]
  /// runs. Non-null exactly when there's a finished-but-not-yet-saved (or
  /// save-failed-and-retryable) recording — the id/activity/samples are
  /// built once in [finish] and reused verbatim by [retrySave] so a retry
  /// never mints a second activity id for the same recording.
  Activity? _pendingActivity;
  List<ActivitySample>? _pendingSamples;

  /// The saved route being followed, when this recording was started from
  /// one (`/activity/record?route-id=...`). Captured in [start] and stamped
  /// onto the finished [Activity] in [finish]; cleared by
  /// [discard]/[reset].
  String? _routeId;

  /// Collected heart rate measurements in BPM during the active recording,
  /// used to compute [Activity.avgHeartRate] when finished.
  final List<int> _heartRateSamples = [];

  /// How long an auto-pause episode must last before
  /// [RecordingControllerState.showForgottenEndPrompt] goes true.
  static const Duration _forgottenEndThreshold = Duration(minutes: 10);

  /// Per-episode dismissal for the forgotten-end prompt, set by
  /// [dismissForgottenEndPrompt] and re-armed by [_syncStateFromSession]
  /// whenever a new auto-pause episode begins (or the session leaves
  /// auto-pause) - see that method.
  bool _forgottenEndDismissed = false;

  DateTime _now() => ref.read(recordingClockProvider)();

  @override
  RecordingControllerState build() {
    ref.onDispose(_cleanup);
    return const RecordingControllerState();
  }

  /// Checks/requests location permission, then starts a new
  /// [RecordingSession] of [type] and subscribes to live fixes. Safe to
  /// call again after a failed attempt (e.g. permission was denied, then
  /// granted via OS settings).
  ///
  /// A no-op unless the controller is in [RecordingLifecycle.idle],
  /// [RecordingLifecycle.saved], or [RecordingLifecycle.discarded] — a
  /// second call while already starting/recording/saving is ignored rather
  /// than clobbering the in-progress session, and re-entering from
  /// `saved`/`discarded` auto-[reset]s first so re-opening the record route
  /// always starts clean. An `_startEpoch` token is bumped on every legal
  /// entry so a superseded call (or a [discard] that lands mid-permission-
  /// wait) aborts after its next `await` instead of racing to subscribe.
  Future<void> start(ActivityType type, {String? routeId}) async {
    final lifecycle = state.lifecycle;
    if (lifecycle != RecordingLifecycle.idle &&
        lifecycle != RecordingLifecycle.saved &&
        lifecycle != RecordingLifecycle.discarded) {
      return;
    }
    if (lifecycle != RecordingLifecycle.idle) {
      reset();
    }
    _routeId = routeId;

    final epoch = ++_startEpoch;
    bool superseded() =>
        _startEpoch != epoch || state.lifecycle == RecordingLifecycle.discarded;

    state = state.copyWith(
      lifecycle: RecordingLifecycle.requestingPermission,
      activityType: type,
      routeId: routeId,
      permissionResult: null,
      error: null,
      savedActivityId: null,
    );

    final locationAdapter = ref.read(locationAdapterProvider);
    try {
      var permission = await locationAdapter.checkPermission();
      if (superseded()) return;
      if (permission != LocationPermissionResult.granted) {
        permission = await locationAdapter.requestPermission();
        if (superseded()) return;
      }
      if (permission != LocationPermissionResult.granted) {
        state = state.copyWith(
          lifecycle: RecordingLifecycle.idle,
          permissionResult: permission,
        );
        return;
      }
    } on Object catch (error) {
      if (_startEpoch != epoch) return;
      state = state.copyWith(
        lifecycle: RecordingLifecycle.idle,
        error: userMessageFor(error),
      );
      return;
    }

    if (superseded()) return;

    final session = RecordingSession(activityType: type, clock: _now)..start();
    _session = session;
    _hasReceivedFirstFix = false;
    _lastSessionStatus = RecordingSessionStatus.ready;

    var coachingSettings = const AudioCoachingSettings();
    try {
      coachingSettings = ref.read(audioCoachingControllerProvider);
    } on Object catch (_) {
      // Safe fallback when settings provider is uninitialized in test mocks
    }
    _audioCueEngine = AudioCueEngine(
      settings: coachingSettings,
      unitSystem: coachingSettings.unitSystem,
    );

    // Preload transition chime for responsive playback
    unawaited(_chimePlayer.preload());

    // Evaluate workout start cue
    final startCue = _audioCueEngine?.evaluateStatusChange(
      previousStatus: RecordingSessionStatus.ready,
      newStatus: RecordingSessionStatus.recording,
    );
    _triggerAudioCue(startCue);
    _lastSessionStatus = RecordingSessionStatus.recording;

    // Acquired here rather than at the top of start(): a permission denial
    // returns above without ever having taken a lock.
    _screenAwake.acquireFor(type);

    state = state.copyWith(lifecycle: RecordingLifecycle.waitingForSignal);

    _fixSubscription = locationAdapter.fixes().listen(
      (fix) {
        if (!_hasReceivedFirstFix) {
          _hasReceivedFirstFix = true;
          try {
            unawaited(
              ref
                  .read(routeLastRecordedLocationProvider.notifier)
                  .record(
                    GeoPoint(latitude: fix.latitude, longitude: fix.longitude),
                  ),
            );
          } on Object catch (_) {
            // Best-effort cache; failures should not interrupt recording.
          }
        }
        session.addFix(fix);
        _syncStateFromSession();
      },
      onError: (Object error) {
        // AUTO-pause semantics, not manual: a dead fix stream (permission
        // revoked mid-run, driver error) is the archetypal "stopped without
        // pressing End" case. `pause()` would clear the session's
        // back-dated auto-pause boundary, excluding this from finish()'s
        // forgotten-end trim and suppressing the prompt - so a revoked
        // permission at kilometre three would bank every dead hour after it
        // as elapsed time. `markSignalLost` is itself status-guarded, so no
        // StateError can escape the stream's error zone.
        state = state.copyWith(error: userMessageFor(error));
        session.markSignalLost(_now().toUtc());
        _syncStateFromSession();
      },
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _session?.evaluateStaleness(_now().toUtc());
      _sampleHeartRate();
      _syncStateFromSession();
    });
  }

  void _sampleHeartRate() {
    if (state.lifecycle != RecordingLifecycle.recording) return;
    final hr = ref.read(currentLiveHeartRateProvider);
    if (hr != null && hr > 0) {
      _heartRateSamples.add(hr);
    }
  }

  /// Manually pauses the current recording. A no-op if there's no session
  /// or the session isn't in a pausable status (recording/autoPaused) —
  /// never lets the session's own [StateError] escape, since this is called
  /// both from user interaction and from the fix stream's `onError` zone.
  void pause() {
    final session = _session;
    if (session == null) return;
    if (session.status != RecordingSessionStatus.recording &&
        session.status != RecordingSessionStatus.autoPaused) {
      return;
    }
    session.pause();
    _syncStateFromSession();
  }

  /// Resumes a manually paused recording. A no-op if there's no session or
  /// the session isn't currently manually paused.
  void resume() {
    final session = _session;
    if (session == null) return;
    if (session.status != RecordingSessionStatus.paused) return;
    session.resume();
    _syncStateFromSession();
  }

  /// Dismisses [RecordingControllerState.showForgottenEndPrompt] for the
  /// CURRENT auto-pause episode only - if movement resumes and then stops
  /// again, a fresh episode begins and the prompt is eligible again (see
  /// [_syncStateFromSession]). A no-op if there's no session or it isn't
  /// currently auto-paused.
  void dismissForgottenEndPrompt() {
    if (state.autoPausedSince == null) return;
    _forgottenEndDismissed = true;
    state = state.copyWith(showForgottenEndPrompt: false);
  }

  /// Finishes the recording: stops feeding it fixes, then attempts to
  /// persist it as an [Activity] (`source: recorded`) plus its
  /// `ActivitySample`s. Returns the new activity's id on success, or `null`
  /// if there's no session or persistence fails (with
  /// [RecordingControllerState.error] set and the lifecycle moved to
  /// [RecordingLifecycle.saveFailed] — the built activity/samples are kept
  /// so [retrySave] can retry without losing the recorded workout).
  Future<String?> finish({int? avgHeartRate}) async {
    final session = _session;
    if (session == null) return null;

    final result = session.finish();
    await _stopFixSubscription();
    _session = null;

    final finishCue = _audioCueEngine?.onSessionFinished(
      distanceMeters: result.distanceMeters,
      movingTime: result.movingTime,
    );
    _triggerAudioCue(finishCue);
    _audioCueEngine = null;
    _lastSessionStatus = RecordingSessionStatus.ready;

    final computedAvgHr =
        avgHeartRate ??
        (_heartRateSamples.isNotEmpty
            ? (_heartRateSamples.reduce((a, b) => a + b) /
                      _heartRateSamples.length)
                  .round()
            : null);

    final now = DateTime.now().toUtc();
    final activityId = EntityId.generate();
    _pendingActivity = Activity(
      id: activityId,
      activityType: result.activityType,
      title: _defaultTitle(result.activityType, result.startedAt),
      startedAt: result.startedAt,
      movingTime: result.movingTime,
      elapsedTime: result.elapsedTime,
      distanceMeters: result.distanceMeters,
      elevationGainMeters: result.elevationGainMeters,
      avgHeartRate: computedAvgHr,
      source: ActivitySource.recorded,
      routeId: _routeId,
      createdAt: now,
      updatedAt: now,
    );
    _pendingSamples = [
      for (final recorded in result.samples)
        ActivitySample(
          id: EntityId.generate(),
          activityId: activityId,
          timestamp: recorded.fix.timestamp,
          latitude: recorded.fix.latitude,
          longitude: recorded.fix.longitude,
          elevationMeters: recorded.fix.elevationMeters,
          horizontalAccuracyMeters: recorded.fix.horizontalAccuracyMeters,
          isPaused: recorded.wasPaused,
        ),
    ];

    return _persist();
  }

  /// Retries persisting a recording that finished but failed to save. Only
  /// legal from [RecordingLifecycle.saveFailed]; a no-op (returning `null`)
  /// otherwise.
  Future<String?> retrySave() async {
    if (state.lifecycle != RecordingLifecycle.saveFailed) return null;
    return _persist();
  }

  /// Persists [_pendingActivity]/[_pendingSamples] (set by [finish]). On
  /// success, moves to [RecordingLifecycle.saved] and clears the pending
  /// fields. On failure, moves to [RecordingLifecycle.saveFailed] with
  /// [RecordingControllerState.error] set and leaves the pending fields
  /// intact so [retrySave] can try again — the workout itself is never
  /// lost to a save failure.
  Future<String?> _persist() async {
    final activity = _pendingActivity;
    if (activity == null) return null;
    final samples = _pendingSamples ?? const <ActivitySample>[];

    // The recording itself ended in finish() (the fix subscription and the
    // ticker are already stopped), so the lock goes here rather than on
    // each of the success/failure branches below — including the retrySave
    // path, which routes through this same method.
    _screenAwake.release();

    state = state.copyWith(
      lifecycle: RecordingLifecycle.saving,
      error: null,
      autoPausedSince: null,
      showForgottenEndPrompt: false,
    );
    try {
      final repository = ref.read(activityRepositoryProvider);
      // One atomic write, not saveActivity-then-insertSamples: a process
      // death between two separate commits would strand a recorded
      // activity with no GPS track and nothing left in memory to retry
      // with (see `ActivityRepository.saveRecordedActivity`).
      await repository.saveRecordedActivity(activity, samples);

      state = state.copyWith(
        lifecycle: RecordingLifecycle.saved,
        savedActivityId: activity.id,
        error: null,
      );
      _pendingActivity = null;
      _pendingSamples = null;
      return activity.id;
    } on Object catch (error) {
      state = state.copyWith(
        lifecycle: RecordingLifecycle.saveFailed,
        error: userMessageFor(error),
      );
      return null;
    }
  }

  /// Discards the current recording (or a finished-but-unsaved one sitting
  /// in [RecordingLifecycle.saveFailed]) without persisting anything.
  Future<void> discard() async {
    await _stopFixSubscription();
    _screenAwake.release();
    _session = null;
    _pendingActivity = null;
    _pendingSamples = null;
    _routeId = null;
    _heartRateSamples.clear();
    _forgottenEndDismissed = false;
    _audioCueEngine = null;
    _lastSessionStatus = RecordingSessionStatus.ready;
    unawaited(_speechAdapter?.stop());
    state = state.copyWith(
      lifecycle: RecordingLifecycle.discarded,
      error: null,
      autoPausedSince: null,
      showForgottenEndPrompt: false,
    );
  }

  /// Restores the controller to a fresh [RecordingControllerState] so a new
  /// recording can start. Only legal from [RecordingLifecycle.saved],
  /// [RecordingLifecycle.discarded], or [RecordingLifecycle.idle] (a no-op
  /// otherwise) — those are the only states where the subscription/ticker
  /// are already guaranteed stopped and nothing is left pending, though
  /// [_stopFixSubscription] is still called defensively.
  void reset() {
    final lifecycle = state.lifecycle;
    if (lifecycle != RecordingLifecycle.saved &&
        lifecycle != RecordingLifecycle.discarded &&
        lifecycle != RecordingLifecycle.idle) {
      return;
    }
    unawaited(_stopFixSubscription());
    _screenAwake.release();
    _session = null;
    _pendingActivity = null;
    _pendingSamples = null;
    _routeId = null;
    _heartRateSamples.clear();
    _hasReceivedFirstFix = false;
    _forgottenEndDismissed = false;
    _audioCueEngine = null;
    _lastSessionStatus = RecordingSessionStatus.ready;
    unawaited(_speechAdapter?.stop());
    state = const RecordingControllerState();
  }

  /// Toggles mute for audio coaching cues during the active workout.
  void toggleAudioMute() {
    state = state.copyWith(isAudioMuted: !state.isAudioMuted);
    if (state.isAudioMuted) {
      unawaited(_speechAdapter?.stop());
    }
  }

  void _triggerAudioCue(AudioCueEvent? cue) {
    if (cue == null || state.isAudioMuted) return;
    final settings = ref.read(audioCoachingControllerProvider);
    if (!settings.enabled) return;

    if (cue.playChime &&
        (settings.cueMode == AudioCueMode.voiceAndChime ||
            settings.cueMode == AudioCueMode.chimeOnly)) {
      unawaited(_chimePlayer.playTransitionChime());
    }

    if (settings.cueMode == AudioCueMode.voiceAndChime ||
        settings.cueMode == AudioCueMode.voiceOnly) {
      unawaited(_speech.setSpeechRate(settings.speechRate));
      unawaited(_speech.setVolume(settings.volume));
      unawaited(_speech.speak(cue.spokenText));
    }
  }

  void _syncStateFromSession() {
    final session = _session;
    if (session == null) return;

    if (session.status != _lastSessionStatus) {
      final statusCue = _audioCueEngine?.evaluateStatusChange(
        previousStatus: _lastSessionStatus,
        newStatus: session.status,
      );
      _triggerAudioCue(statusCue);
      _lastSessionStatus = session.status;
    }

    final distanceCues = _audioCueEngine?.evaluateDistanceUpdate(
      distanceMeters: session.distanceMeters,
      movingTime: session.movingTime,
      currentPaceSecondsPerKm: session.currentPaceSecondsPerKm,
    );
    distanceCues?.forEach(_triggerAudioCue);

    final lifecycle = switch (session.status) {
      // Unreachable in practice - `_session` is only ever assigned in
      // start(), immediately after `..start()` has already moved it off
      // `ready`. Kept so the switch stays exhaustive over the enum rather
      // than needing a default that would swallow a genuinely new status.
      RecordingSessionStatus.ready => RecordingLifecycle.waitingForSignal,
      RecordingSessionStatus.recording =>
        _hasReceivedFirstFix
            ? RecordingLifecycle.recording
            : RecordingLifecycle.waitingForSignal,
      RecordingSessionStatus.paused => RecordingLifecycle.paused,
      RecordingSessionStatus.autoPaused => RecordingLifecycle.autoPaused,
      RecordingSessionStatus.finished => RecordingLifecycle.saving,
    };

    // Re-arm the forgotten-end dismissal whenever a *new* auto-pause
    // episode begins (a fresh, distinct back-dated boundary from the one
    // the dismissal was recorded against) or the session has left
    // auto-pause entirely - a dismissal from a previous episode must never
    // suppress the prompt for a later one (see [dismissForgottenEndPrompt]).
    final autoPausedAt = session.autoPausedAt;
    if (autoPausedAt != state.autoPausedSince) {
      _forgottenEndDismissed = false;
    }
    final showForgottenEndPrompt =
        autoPausedAt != null &&
        !_forgottenEndDismissed &&
        _now().difference(autoPausedAt) >= _forgottenEndThreshold;

    final lastFix = session.lastAcceptedFix;
    final trackPoints = [
      for (final sample in session.samples) sample.fix,
    ];

    state = state.copyWith(
      lifecycle: lifecycle,
      routeId: _routeId,
      elapsedTime: session.elapsedTime ?? Duration.zero,
      movingTime: session.movingTime,
      distanceMeters: session.distanceMeters,
      elevationGainMeters: session.elevationGainMeters,
      currentPaceSecondsPerKm: session.currentPaceSecondsPerKm,
      sampleCount: session.samples.length,
      autoPausedSince: autoPausedAt,
      showForgottenEndPrompt: showForgottenEndPrompt,
      latestFix: lastFix,
      trackPoints: trackPoints,
      currentElevationMeters: lastFix?.elevationMeters,
      currentSpeedMps: lastFix?.speedMetersPerSecond,
    );
  }

  Future<void> _stopFixSubscription() async {
    _ticker?.cancel();
    _ticker = null;
    await _fixSubscription?.cancel();
    _fixSubscription = null;
  }

  void _cleanup() {
    _ticker?.cancel();
    unawaited(_fixSubscription?.cancel());
    _screenAwake.release();
    _heartRateSamples.clear();
    _audioCueEngine = null;
    _lastSessionStatus = RecordingSessionStatus.ready;
    unawaited(_speechAdapter?.stop());
  }
}

/// Builds a default title like "Morning Run" from the activity's type and
/// UTC start time, converted to local for the time-of-day bucket. Mirrors
/// `manual_entry_controller.dart`'s `_defaultTitle` (kept as a small local
/// duplicate rather than a shared helper — the two forms differ slightly in
/// input, and no shared `presentation/` utility module exists yet).
String _defaultTitle(ActivityType type, DateTime startedAtUtc) {
  final hour = startedAtUtc.toLocal().hour;
  final timeOfDay = switch (hour) {
    >= 5 && < 12 => 'Morning',
    >= 12 && < 17 => 'Afternoon',
    >= 17 && < 21 => 'Evening',
    _ => 'Night',
  };
  return '$timeOfDay ${type.label}';
}
