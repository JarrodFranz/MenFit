import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';

part 'recording_session.freezed.dart';

/// A [LocationFix] accepted into a [RecordingSession], paired with whether
/// the session was paused (manually or automatically) *at the moment it was
/// accepted* — see [RecordingSession.addFix]'s ordering note. Maps 1:1 to
/// `ActivitySample.isPaused` at the recording-controller boundary
/// (`presentation/recording/recording_controller.dart`), which is what lets
/// `domain/track_analysis.dart` exclude paused stretches from splits/best
/// efforts while still keeping every point for the route map.
typedef RecordedFix = ({LocationFix fix, bool wasPaused});

/// Lifecycle state of a [RecordingSession].
enum RecordingSessionStatus {
  /// Constructed but [RecordingSession.start] not yet called.
  ready,

  /// Actively recording: distance/moving-time accumulate.
  recording,

  /// Manually paused by the user (see [RecordingSession.pause]). Overrides
  /// auto-pause logic entirely — no auto-pause/auto-resume transitions
  /// happen while manually paused; only [RecordingSession.resume] leaves
  /// this state.
  paused,

  /// Paused automatically because speed has been below the sustained-stop
  /// threshold (see class doc). Distinct from [paused] so presentation code
  /// can show an "auto-paused" indicator distinct from a manual pause.
  autoPaused,

  /// [RecordingSession.finish] has been called. No further fixes are
  /// accepted.
  finished,
}

/// The result of [RecordingSession.finish]: everything needed to build an
/// [Activity] + its `ActivitySample`s, without this pure-domain class
/// knowing about ids or persistence (that's the recording controller's
/// job — see `presentation/recording/recording_controller.dart`).
@freezed
abstract class RecordingSessionResult with _$RecordingSessionResult {
  const factory RecordingSessionResult({
    required ActivityType activityType,

    /// UTC.
    required DateTime startedAt,

    /// UTC.
    required DateTime finishedAt,
    required Duration movingTime,

    /// Wall-clock duration since [RecordingSession.start]. Normally spans
    /// all the way to the [RecordingSession.finish] call (mirroring the
    /// live [RecordingSession.elapsedTime] getter) - but when
    /// [RecordingSession.finish] is called while the session is
    /// [RecordingSessionStatus.autoPaused] (the "forgotten to end" case),
    /// this is trimmed back to the moment movement actually stopped: the
    /// same back-dated boundary already used to close [movingTime]'s span
    /// for that auto-pause (see [RecordingSession._updateAutoPause] /
    /// [RecordingSession.evaluateStaleness]), not the
    /// [RecordingSession.finish] call time. A recording finished an hour
    /// after the runner in fact stopped therefore reports an honest
    /// elapsed duration instead of claiming that hour as active. A manual
    /// [RecordingSession.pause] is a deliberate stop, not a forgotten one -
    /// finishing while manually paused keeps this at the
    /// [RecordingSession.finish] call time, unaffected by this trimming.
    required Duration elapsedTime,
    required double distanceMeters,

    /// Every [LocationFix] accepted into the session (accuracy/implausible-
    /// jump filtered fixes are excluded — see [RecordingSession] class doc),
    /// paired with whether it was accepted while paused (see [RecordedFix]),
    /// in arrival order. Maps 1:1 to `ActivitySample`s at the controller
    /// boundary, which assigns each an id and the new activity's id and
    /// carries `wasPaused` through as `ActivitySample.isPaused`.
    ///
    /// **One exception**: on the forgotten-end path (see [elapsedTime]) the
    /// trailing run of paused-status fixes is dropped — they are stationary
    /// readings of wherever the user stopped, often home, and describe no
    /// part of the workout. See
    /// `RecordingSession._samplesWithoutTrailingPause`.
    required List<RecordedFix> samples,
    double? elevationGainMeters,
  }) = _RecordingSessionResult;
}

/// Pure-Dart GPS recording engine: turns a stream of [LocationFix]es into
/// distance, moving/elapsed time, elevation gain, current pace, and a
/// filtered sample list — with no Flutter or plugin import, so it's
/// deterministically unit-testable via an injected `clock`.
///
/// ## Fix filtering (applied in order; a discarded fix touches no other
/// state — not distance, not samples, not auto-pause detection)
/// 1. **Accuracy**: [LocationFix.horizontalAccuracyMeters] `> 35` is
///    discarded. A fix that doesn't report accuracy at all is *not*
///    discarded — there's nothing to judge it against.
/// 2. **Implausible jump**: the implied speed from the previous *accepted*
///    fix (of any [status], including while paused — a teleport during a
///    pause is still a teleport) must not exceed
///    [_maxPlausibleSpeedMetersPerSecond] for [activityType] (10 m/s for
///    run/walk/hike, 25 m/s for ride). A non-positive time delta from the
///    previous accepted fix is also discarded (out-of-order/duplicate).
///
/// Every fix that survives filtering is kept in the sample list regardless
/// of [status] — a paused/auto-paused fix still marks a real point on the
/// route for the eventual map (wave C3), it just doesn't move the distance
/// counter. Each kept fix is tagged with whether [status] was
/// [RecordingSessionStatus.paused] or [RecordingSessionStatus.autoPaused] at
/// the moment it was accepted (see [RecordedFix]) — this is what lets
/// `domain/track_analysis.dart` exclude paused stretches from splits/best
/// efforts while the route map still shows every point.
///
/// ## Distance & moving time
/// [distanceMeters] only accumulates between consecutive accepted fixes
/// that are *both* seen while [status] is [RecordingSessionStatus.recording]
/// — pausing (manual or auto) breaks the reference point, so resuming never
/// silently adds the pause-gap's distance. [movingTime] is the sum of
/// wall-clock spans spent in [RecordingSessionStatus.recording]; it excludes
/// every paused/autoPaused span. [elapsedTime] is wall-clock since [start],
/// full stop — it does not exclude pauses.
///
/// ## Auto-pause
/// While [status] is [RecordingSessionStatus.recording] and a fix reports
/// [LocationFix.speedMetersPerSecond] (falling back to the implied speed
/// from the previous accepted fix when the device doesn't report one)
/// continuously below 0.5 m/s for more than 5 seconds (measured between fix
/// timestamps), the session transitions to
/// [RecordingSessionStatus.autoPaused]. Any fix reporting/implying speed
/// above 1.0 m/s while auto-paused resumes recording. The gap between these
/// thresholds is deliberate hysteresis against flapping right at the
/// boundary. [RecordingSessionStatus.paused] (manual) suppresses this
/// entire mechanism — see [pause], which (along with [resume]) also clears
/// the low-speed streak so a stretch of low speed observed before a manual
/// pause can never immediately auto-pause a fix received well after resume.
/// When the sustain threshold is crossed, the moving span is closed
/// back-dated to when the low-speed streak actually began (not to the
/// triggering fix's time) so the sustain-detection window itself is never
/// counted as moving time (Strava-style). [evaluateStaleness] drives a
/// second, independent trigger into the same
/// [RecordingSessionStatus.autoPaused] state when fixes stop arriving
/// entirely (see its doc). Both triggers record the back-dated boundary
/// they used in [autoPausedAt], which [RecordingSession.finish] reads to trim
/// [RecordingSessionResult.elapsedTime] for a forgotten-end finish - see
/// that field's doc.
///
/// ## Moving-span time base
/// Every moving-span boundary (span open/close, both manual and automatic)
/// is measured against the injected clock ([DateTime.now] by default, or
/// the test-injected `clock`), never against a [LocationFix.timestamp] —
/// fix timestamps come from the device/GPS chipset and can't be trusted to
/// agree with wall-clock time. Every span contribution is clamped to
/// non-negative before being added to [movingTime].
///
/// ## Elevation
/// [elevationGainMeters] sums only positive elevation deltas between a held
/// reference point and a later accepted fix that both report
/// [LocationFix.elevationMeters], once the two diverge by more than a 2 m
/// noise threshold; it is not gated by [status] (altitude changes are real
/// whether or not the runner is currently moving). The reference is *held*
/// (not moved on every fix) until a qualifying divergence — this is what
/// lets a gradual climb made of many sub-threshold steps still accumulate
/// gain, instead of every step being individually dismissed as noise.
///
/// ## Pace
/// [currentPaceSecondsPerKm] is a rolling window over the last 15 seconds of
/// *moving* distance (i.e. only points that contributed to [distanceMeters]
/// are eligible) — `null` until there are at least two such points in the
/// window or the window's distance/duration is non-positive.
///
/// Two consequences worth knowing before filing "pace stays at --" again:
/// 1. The window is never trimmed below two points, so a fix stream slower
///    than the 15s window still produces a pace (over its two most recent
///    moving points) rather than `null` forever — see [_trimRollingWindow],
///    whose naive form had exactly that defect.
/// 2. A point is only appended for the *second* and later consecutive fixes
///    accepted while [RecordingSessionStatus.recording]; the first one after
///    [start], [resume] or an auto-resume merely re-establishes the distance
///    reference. So pace needs three such fixes to appear, and legitimately
///    stays `null` when every fix arrives to find the session auto-paused —
///    which is what a fix cadence slower than [_staleFixThreshold] produces,
///    since [evaluateStaleness] auto-pauses in each gap. That is not a pace
///    defect: at that cadence the session genuinely does not know the user
///    moved between fixes, and the auto-pause deliberately discards the
///    gap's distance (see "Distance & moving time" above).
class RecordingSession {
  RecordingSession({required this.activityType, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final ActivityType activityType;
  final DateTime Function() _clock;

  static const double _maxAccuracyMeters = 35;
  static const double _autoPauseSpeedThreshold = 0.5;
  static const double _autoResumeSpeedThreshold = 1;
  static const Duration _autoPauseSustainDuration = Duration(seconds: 5);
  static const double _elevationNoiseThresholdMeters = 2;
  static const Duration _paceWindow = Duration(seconds: 15);
  static const Duration _staleFixThreshold = Duration(seconds: 10);

  RecordingSessionStatus _status = RecordingSessionStatus.ready;
  DateTime? _startedAt;
  DateTime? _finishedAt;

  Duration _accumulatedMovingTime = Duration.zero;
  DateTime? _movingSpanStart;

  double _distanceMeters = 0;
  double? _elevationGainMeters;
  double? _lastElevationMeters;

  LocationFix? _lastAcceptedFix;

  /// [_clock] reading captured when [_lastAcceptedFix] was accepted.
  ///
  /// [evaluateStaleness] measures "how long since a fix arrived" against
  /// **this**, never against `_lastAcceptedFix.timestamp`: a fix timestamp
  /// comes from the device/GPS chipset and can't be trusted to agree with
  /// wall-clock time (see the class doc's "Moving-span time base" rule and
  /// the hour-skew regression test in `recording_session_test.dart`). A fix
  /// clock that lags would fire a false auto-pause on a live signal; one
  /// that leads would keep `now.difference(...)` negative forever and never
  /// fire at all — silently disabling forgotten-end detection for exactly
  /// the stalled-GPS case it exists to catch.
  DateTime? _lastAcceptedFixClock;

  LocationFix? _lastRecordingFix;
  DateTime? _lowSpeedSince;

  /// [_clock] reading captured at the same moment [_lowSpeedSince] is first
  /// set (i.e. when the low-speed condition began), kept alongside it so an
  /// eventual auto-pause can close the moving span at the wall-clock time
  /// the stationary period actually started rather than at the clock time
  /// of the fix that finally crosses the sustain threshold (see
  /// [_updateAutoPause] - back-dating the moving-span close, Strava-style).
  DateTime? _lowSpeedSinceClock;

  /// Clock value at which the session most recently transitioned INTO
  /// [RecordingSessionStatus.autoPaused] - the same back-dated boundary
  /// used to close the moving span for that transition (the low-speed
  /// streak's start for [_updateAutoPause], or the staleness-check time for
  /// [evaluateStaleness]). `null` whenever [status] isn't
  /// [RecordingSessionStatus.autoPaused]: cleared on auto-resume back to
  /// [RecordingSessionStatus.recording] and on a manual [pause] that
  /// overrides an in-progress auto-pause. [RecordingSession.finish] reads
  /// this to trim a forgotten-end [RecordingSessionResult.elapsedTime] -
  /// see that field's doc.
  DateTime? _autoPausedAt;

  final List<RecordedFix> _samples = [];
  final List<_DistancePoint> _recentDistancePoints = [];

  /// Current lifecycle state.
  RecordingSessionStatus get status => _status;

  /// The back-dated clock boundary at which the current auto-pause episode
  /// began, or `null` when [status] isn't
  /// [RecordingSessionStatus.autoPaused]. Exposed for presentation code
  /// (`presentation/recording/recording_controller.dart`) that needs an
  /// honest "how long has movement actually been stopped" duration - e.g. a
  /// forgotten-end prompt - rather than the wall-clock time auto-pause was
  /// merely *detected*. See the class doc's Auto-pause section.
  DateTime? get autoPausedAt => _autoPausedAt;

  /// Every accepted fix so far, paired with whether it was accepted while
  /// paused (see [RecordedFix]), in arrival order.
  List<RecordedFix> get samples => List.unmodifiable(_samples);

  /// The most recent [LocationFix] accepted into the session.
  LocationFix? get lastAcceptedFix => _lastAcceptedFix;

  /// Total distance covered while actively recording, in metres. Never
  /// decreases.
  double get distanceMeters => _distanceMeters;

  /// Total accumulated elevation gain in metres (positive deltas above the
  /// noise threshold only), or `null` if no fix has reported elevation yet.
  double? get elevationGainMeters => _elevationGainMeters;

  /// Time spent in [RecordingSessionStatus.recording], live-updating via
  /// [_clock] between fixes (so a UI ticker can poll it every second without
  /// waiting for the next GPS fix).
  Duration get movingTime {
    final spanStart = _movingSpanStart;
    if (spanStart == null) return _accumulatedMovingTime;
    final now = _finishedAt ?? _clock();
    final liveContribution = now.difference(spanStart);
    return _accumulatedMovingTime +
        (liveContribution.isNegative ? Duration.zero : liveContribution);
  }

  /// Wall-clock time since [start], including any paused time. `null` before
  /// [start] is called.
  Duration? get elapsedTime {
    final startedAt = _startedAt;
    if (startedAt == null) return null;
    final now = _finishedAt ?? _clock();
    return now.difference(startedAt);
  }

  /// Rolling pace over the last 15 seconds of moving distance, in seconds
  /// per kilometre. `null` when there isn't enough recent moving data to
  /// derive a meaningful pace.
  double? get currentPaceSecondsPerKm {
    if (_recentDistancePoints.length < 2) return null;
    final first = _recentDistancePoints.first;
    final last = _recentDistancePoints.last;
    final distanceMeters = last.cumulativeMeters - first.cumulativeMeters;
    final seconds =
        last.timestamp.difference(first.timestamp).inMilliseconds / 1000;
    if (distanceMeters <= 0 || seconds <= 0) return null;
    return seconds / (distanceMeters / 1000);
  }

  /// Starts the session. Only legal from [RecordingSessionStatus.ready].
  void start() {
    if (_status != RecordingSessionStatus.ready) {
      throw StateError('Cannot start a session in status $_status.');
    }
    final now = _clock();
    _startedAt = now;
    _status = RecordingSessionStatus.recording;
    _movingSpanStart = now;
  }

  /// Manually pauses the session, overriding any in-progress auto-pause
  /// detection. Only legal from [RecordingSessionStatus.recording] or
  /// [RecordingSessionStatus.autoPaused].
  void pause() {
    if (_status != RecordingSessionStatus.recording &&
        _status != RecordingSessionStatus.autoPaused) {
      throw StateError('Cannot pause a session in status $_status.');
    }
    _closeMovingSpan(_clock());
    _status = RecordingSessionStatus.paused;
    _resetDistanceReference();
    // A manual pause/resume boundary must never let a low-speed streak
    // tracked before the pause auto-pause a fix received well after resume
    // (see class doc's auto-pause hysteresis) - clear it here too, not just
    // in resume(), since a pause->long-gap->resume with no fixes in
    // between must start the low-speed clock fresh either way.
    _lowSpeedSince = null;
    _lowSpeedSinceClock = null;
    // A manual pause overrides an in-progress auto-pause (this method is
    // legal from autoPaused too) - the eventual finish() must treat this as
    // a deliberate stop, not a forgotten one, so the auto-pause boundary is
    // cleared rather than carried into `paused`.
    _autoPausedAt = null;
  }

  /// Resumes a manually paused session. Only legal from
  /// [RecordingSessionStatus.paused].
  void resume() {
    if (_status != RecordingSessionStatus.paused) {
      throw StateError('Cannot resume a session in status $_status.');
    }
    final now = _clock();
    _status = RecordingSessionStatus.recording;
    _movingSpanStart = now;
    _resetDistanceReference();
    _lowSpeedSince = null;
    _lowSpeedSinceClock = null;
    _autoPausedAt = null;
  }

  /// Feeds a new [LocationFix] into the session. See class doc for the full
  /// filtering/accumulation rules. No-ops once [RecordingSession.finish] has been called or
  /// before [start].
  void addFix(LocationFix fix) {
    if (_status == RecordingSessionStatus.ready ||
        _status == RecordingSessionStatus.finished) {
      return;
    }

    final accuracy = fix.horizontalAccuracyMeters;
    if (accuracy != null && accuracy > _maxAccuracyMeters) {
      return;
    }

    double? impliedSpeed;
    final previous = _lastAcceptedFix;
    if (previous != null) {
      final dtSeconds =
          fix.timestamp.difference(previous.timestamp).inMilliseconds / 1000;
      if (dtSeconds <= 0) {
        return;
      }
      final jumpMeters = haversineDistanceMeters(
        previous.latitude,
        previous.longitude,
        fix.latitude,
        fix.longitude,
      );
      impliedSpeed = jumpMeters / dtSeconds;
      if (impliedSpeed > _maxPlausibleSpeedMetersPerSecond(activityType)) {
        return;
      }
    }

    // Accepted. `wasPaused` is captured *before* this fix's own processing
    // below can change [_status] — a fix that triggers a pause/auto-pause
    // or auto-resume transition is itself accepted under the status it
    // arrived to find, not the one it causes (see [RecordedFix] doc).
    final wasPaused =
        _status == RecordingSessionStatus.paused ||
        _status == RecordingSessionStatus.autoPaused;
    _samples.add((fix: fix, wasPaused: wasPaused));
    _lastAcceptedFix = fix;
    _lastAcceptedFixClock = _clock();

    _accumulateElevation(fix);
    if (_status != RecordingSessionStatus.paused) {
      _updateAutoPause(fix, impliedSpeed);
    }
    if (_status == RecordingSessionStatus.recording) {
      _accumulateDistance(fix);
    }
  }

  /// Finishes the session, returning everything needed to persist it as an
  /// [Activity] + samples. Only legal outside [RecordingSessionStatus.ready]
  /// and [RecordingSessionStatus.finished].
  RecordingSessionResult finish() {
    if (_status == RecordingSessionStatus.ready ||
        _status == RecordingSessionStatus.finished) {
      throw StateError('Cannot finish a session in status $_status.');
    }
    final now = _clock();
    final wasAutoPaused = _status == RecordingSessionStatus.autoPaused;
    final autoPausedAt = _autoPausedAt;
    _closeMovingSpan(now);
    _finishedAt = now;
    _status = RecordingSessionStatus.finished;

    // Forgotten-end trim: finishing while still autoPaused ends elapsedTime
    // at the same back-dated boundary already used to close movingTime's
    // span, not at this finish() call - see RecordingSessionResult.
    // elapsedTime's doc. A manual pause is a deliberate stop, not a
    // forgotten one, so it's excluded (wasAutoPaused is false for it).
    final isForgottenEnd = wasAutoPaused && autoPausedAt != null;
    final elapsedEnd = isForgottenEnd ? autoPausedAt : now;

    return RecordingSessionResult(
      activityType: activityType,
      startedAt: _startedAt!,
      finishedAt: now,
      movingTime: _accumulatedMovingTime,
      elapsedTime: elapsedEnd.difference(_startedAt!),
      distanceMeters: _distanceMeters,
      elevationGainMeters: _elevationGainMeters,
      samples: List.unmodifiable(
        isForgottenEnd ? _samplesWithoutTrailingPause() : _samples,
      ),
    );
  }

  /// [_samples] with the trailing run of paused-status fixes removed.
  ///
  /// Data minimisation (`knowledge/engineering/security_and_privacy.md`):
  /// when a run is finished long after the user actually stopped, every fix
  /// after the auto-pause boundary is a stationary reading of wherever they
  /// stopped — frequently their home. An hour of those is potentially
  /// thousands of points establishing not just the location but how long
  /// they stayed there, and none of it describes the workout: they're
  /// already excluded from splits, best efforts, distance and moving time.
  /// Trimming them keeps only what the activity is actually about.
  ///
  /// Only the *trailing* run is dropped, and only on the forgotten-end
  /// path — mid-workout pauses (a road crossing, a coffee stop) keep their
  /// points so the route map stays continuous.
  List<RecordedFix> _samplesWithoutTrailingPause() {
    var end = _samples.length;
    while (end > 0 && _samples[end - 1].wasPaused) {
      end--;
    }
    return _samples.sublist(0, end);
  }

  void _closeMovingSpan(DateTime at) {
    final spanStart = _movingSpanStart;
    if (spanStart == null) return;
    final contribution = at.difference(spanStart);
    _accumulatedMovingTime += contribution.isNegative
        ? Duration.zero
        : contribution;
    _movingSpanStart = null;
  }

  /// Re-evaluates whether the session has gone stale because fixes have
  /// stopped arriving (GPS lost, app backgrounded past what the OS still
  /// delivers, etc.) - a plain [addFix]-driven check can't catch this since
  /// it depends entirely on a fix arriving. Intended to be called from a
  /// UI-side ticker (e.g. once a second) with the current wall-clock time;
  /// a no-op unless [status] is [RecordingSessionStatus.recording] and more
  /// than 10 seconds have passed (by [now]) since the last accepted fix, in
  /// which case it auto-pauses via the same path as the low-speed
  /// auto-pause (see class doc) - moving time stops accruing until a fresh
  /// fix arrives and resumes it (existing auto-pause/auto-resume logic in
  /// [_updateAutoPause] handles that transition once a fix does arrive, no
  /// special-casing needed here).
  void evaluateStaleness(DateTime now) {
    if (_status != RecordingSessionStatus.recording) return;
    // Wall-clock of the last accepted fix, NOT the fix's own timestamp -
    // see [_lastAcceptedFixClock]'s doc for why the distinction is
    // load-bearing.
    final lastFixClock = _lastAcceptedFixClock;
    if (lastFixClock == null) return;
    if (now.difference(lastFixClock) > _staleFixThreshold) {
      _autoPauseAt(now);
    }
  }

  /// Auto-pauses because the fix *stream itself* failed (permission revoked
  /// mid-recording, GPS driver error, adapter throwing) rather than because
  /// fixes merely went quiet.
  ///
  /// Deliberately an **auto**-pause, not a manual [pause]: a dead stream is
  /// exactly the "user has actually stopped and doesn't know it" case the
  /// forgotten-end trim exists for. Routing it through [pause] would clear
  /// [_autoPausedAt], excluding it from [finish]'s trim and suppressing the
  /// "looks like you've stopped" prompt — so a user whose permission was
  /// revoked at kilometre three and who finished hours later would bank all
  /// those dead hours as elapsed time.
  ///
  /// Unlike [evaluateStaleness] this fires immediately and needs no prior
  /// fix: the stream can die before the first one ever arrives. A no-op
  /// unless [status] is [RecordingSessionStatus.recording].
  void markSignalLost(DateTime now) {
    if (_status != RecordingSessionStatus.recording) return;
    _autoPauseAt(now);
  }

  /// The shared auto-pause transition: close the moving span at the
  /// (possibly back-dated) boundary [at], drop into
  /// [RecordingSessionStatus.autoPaused], and record [at] as the boundary
  /// [finish] will trim a forgotten end back to.
  void _autoPauseAt(DateTime at) {
    _closeMovingSpan(at);
    _status = RecordingSessionStatus.autoPaused;
    _resetDistanceReference();
    _lowSpeedSince = null;
    _lowSpeedSinceClock = null;
    _autoPausedAt = at;
  }

  /// Clears the moving-distance reference fix and rolling pace window — used
  /// whenever a pause (manual or auto) starts or ends, so the gap it spans
  /// is never counted as distance and never pollutes the pace window with a
  /// stale pre-pause point.
  void _resetDistanceReference() {
    _lastRecordingFix = null;
    _recentDistancePoints.clear();
  }

  /// Holds [_lastElevationMeters] fixed until [fix]'s elevation diverges
  /// from it by more than [_elevationNoiseThresholdMeters] - moving the
  /// reference on every fix (even by sub-threshold steps) would mean a
  /// gradual climb made of many small steps never banks any gain, since no
  /// individual step-to-step delta ever crosses the threshold. Holding the
  /// reference lets small steps accumulate until the *cumulative* move
  /// crosses the threshold, at which point the (positive-only) delta is
  /// banked and the reference jumps to the current reading.
  void _accumulateElevation(LocationFix fix) {
    final elevation = fix.elevationMeters;
    if (elevation == null) return;
    final reference = _lastElevationMeters;
    if (reference == null) {
      _lastElevationMeters = elevation;
      return;
    }
    final delta = elevation - reference;
    if (delta.abs() > _elevationNoiseThresholdMeters) {
      if (delta > 0) {
        _elevationGainMeters = (_elevationGainMeters ?? 0) + delta;
      }
      _lastElevationMeters = elevation;
    }
    // Otherwise: within the noise threshold of the held reference - the
    // reference does not move.
  }

  void _updateAutoPause(LocationFix fix, double? impliedSpeed) {
    final speed = fix.speedMetersPerSecond ?? impliedSpeed;
    if (speed == null) return;

    if (speed < _autoPauseSpeedThreshold) {
      _lowSpeedSince ??= fix.timestamp;
      _lowSpeedSinceClock ??= _clock();
      if (_status == RecordingSessionStatus.recording &&
          fix.timestamp.difference(_lowSpeedSince!) >
              _autoPauseSustainDuration) {
        // Back-date the moving-span close to the clock time the low-speed
        // streak actually began, not the clock time of this triggering fix
        // - the sustain-detection window itself (>5s of low speed) must not
        // be counted as moving time (Strava-style auto-pause).
        final boundary = _lowSpeedSinceClock ?? _clock();
        _closeMovingSpan(boundary);
        _status = RecordingSessionStatus.autoPaused;
        _resetDistanceReference();
        _autoPausedAt = boundary;
      }
    } else {
      _lowSpeedSince = null;
      _lowSpeedSinceClock = null;
      if (speed > _autoResumeSpeedThreshold &&
          _status == RecordingSessionStatus.autoPaused) {
        _status = RecordingSessionStatus.recording;
        _movingSpanStart = _clock();
        _resetDistanceReference();
        _autoPausedAt = null;
      }
    }
  }

  void _accumulateDistance(LocationFix fix) {
    final reference = _lastRecordingFix;
    if (reference != null) {
      final segmentMeters = haversineDistanceMeters(
        reference.latitude,
        reference.longitude,
        fix.latitude,
        fix.longitude,
      );
      _distanceMeters += segmentMeters;
      _recentDistancePoints.add(
        _DistancePoint(
          timestamp: fix.timestamp,
          cumulativeMeters: _distanceMeters,
        ),
      );
      _trimRollingWindow(fix.timestamp);
    }
    _lastRecordingFix = fix;
  }

  /// Trims the rolling pace window back to roughly the last [_paceWindow]
  /// of moving data - but never below the two points a pace needs.
  ///
  /// A point is dropped only once the point *after* it is itself older than
  /// the cutoff and can therefore become the window's new start. Trimming
  /// on the leading point alone (the obvious formulation) leaves exactly
  /// one point behind whenever consecutive moving fixes are further apart
  /// than [_paceWindow], so [currentPaceSecondsPerKm] can never be anything
  /// but `null` on a sparse fix stream - even while [distanceMeters] and
  /// [movingTime] accumulate correctly from those same points. That is a
  /// real device condition (a low-cadence provider, a 30s-per-fix emulator
  /// feed), not just a test artefact. The cost of the guard is that the
  /// window may start up to one fix-interval before the cutoff; with a
  /// normal ~1Hz stream that is a sub-second overhang.
  void _trimRollingWindow(DateTime latest) {
    final cutoff = latest.subtract(_paceWindow);
    while (_recentDistancePoints.length >= 2 &&
        _recentDistancePoints[1].timestamp.isBefore(cutoff)) {
      _recentDistancePoints.removeAt(0);
    }
  }

  /// Implausible-jump speed ceiling, per activity type (see class doc).
  static double _maxPlausibleSpeedMetersPerSecond(ActivityType type) =>
      switch (type) {
        ActivityType.ride => 25,
        _ => 10,
      };
}

class _DistancePoint {
  const _DistancePoint({
    required this.timestamp,
    required this.cumulativeMeters,
  });

  final DateTime timestamp;
  final double cumulativeMeters;
}
