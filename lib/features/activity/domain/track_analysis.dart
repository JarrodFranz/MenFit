/// Pure analytics over a recorded activity's `ActivitySample` track: splits
/// and best-effort windows.
///
/// `ActivitySample`s are already accuracy/implausible-jump filtered at
/// record time (see `recording_session.dart` class doc) - these functions
/// trust their input and do no further GPS-quality filtering themselves.
/// They only defend against out-of-order/duplicate timestamps, since that
/// can't happen during a single live recording but could in principle
/// appear in stored data. Both [computeSplits] and [bestEffortFor] apply
/// this defense identically, via the shared [_cleanedSegments] helper.
///
/// ## Pause-aware analytics (F2)
/// `ActivitySample.isPaused` (schema v4) marks a sample accepted while the
/// recording was paused (manually or automatically) - see
/// `recording_session.dart`'s `RecordedFix`. This file defines a
/// **segment** as a maximal run of consecutive non-paused samples. Paused
/// samples are excluded from analytics entirely (neither function ever
/// treats one as a segment endpoint or interpolation boundary) - they
/// remain in the DB purely for the route map (`presentation/widgets/
/// route_map.dart`), which draws every sample regardless of `isPaused`.
///
/// [computeSplits] accumulates distance and time only *within* a segment -
/// the gap between the last sample of one segment and the first sample of
/// the next contributes no distance and no time, full stop. A split can
/// still span a pause (its distance range may start in one segment and
/// finish in a later one); its duration is simply the sum of the in-segment
/// time it actually took. [bestEffortFor] is stricter: a best-effort window
/// is scanned *within a single segment only* - it can never span a pause,
/// so (for example) a fast tram ride taken during a paused stretch can
/// never mint a personal record.
///
/// **Reconciliation goal**: because both functions reset (contribute
/// nothing) across a pause exactly where `RecordingSession` itself resets
/// its own distance/moving-time reference on pause/resume (see
/// `recording_session.dart`'s "Distance & moving time" doc), the sum of
/// [computeSplits]' split distances is meant to equal the stored
/// `Activity.distanceMeters` for the same track, and the sum of split
/// durations is meant to equal `Activity.movingTime` - both computed by
/// `RecordingSession` under the same "nothing crosses a pause" rule. (A
/// discarded partial split under 50 m, or floating-point rounding, can
/// still cause a hair's-width difference in practice.)
///
/// **Old data**: every `ActivitySample` persisted before schema v4 has
/// `isPaused == false` (the migration's backfill default - see
/// `core/db/tables/activity_samples.dart`), so a pre-v4 track is always one
/// single segment end to end and both functions behave exactly as they did
/// before pause-awareness existed.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';

part 'track_analysis.freezed.dart';

/// One completed distance interval of a track (e.g. one kilometre), as
/// produced by [computeSplits].
@freezed
abstract class Split with _$Split {
  const factory Split({
    /// 1-based position among the activity's splits.
    required int index,

    /// The distance this split covers, in metres. Equal to the
    /// `splitMeters` argument [computeSplits] was called with, except for a
    /// trailing partial split, whose [distanceMeters] is whatever remained.
    required double distanceMeters,

    /// Time to cover [distanceMeters] while actually moving - a split that
    /// spans a paused stretch (see library doc) excludes the paused time
    /// entirely, the same way `RecordingSession.movingTime` does. Boundary
    /// crossings within a segment are linearly interpolated between the two
    /// straddling samples (never snapped to a sample timestamp).
    required Duration duration,

    /// Average pace over this split, seconds per kilometre. Always
    /// well-defined since [distanceMeters] is always positive for any
    /// [Split] this file produces.
    required double paceSecondsPerKm,

    /// End elevation minus start elevation of this split, in metres.
    /// `null` when either boundary sample lacks elevation data.
    double? elevationDeltaMeters,
  }) = _Split;
}

/// The fastest contiguous window of a track covering at least
/// [BestEffort.targetMeters], as produced by [bestEffortFor].
@freezed
abstract class BestEffort with _$BestEffort {
  const factory BestEffort({
    /// The distance this effort was scanned for, in metres.
    required double targetMeters,

    /// Minimal time to cover [targetMeters] anywhere in a single segment of
    /// the track (see library doc - a window never spans a pause).
    required Duration duration,

    /// Average pace over the window, seconds per kilometre.
    required double paceSecondsPerKm,

    /// How far into the activity (cumulative *moving* track distance, in
    /// metres - paused stretches add nothing) this window begins.
    required double startOffsetMeters,
  }) = _BestEffort;
}

/// Standard race distances, in metres, that best-effort scanning and
/// personal-records tracking (`personal_records.dart`) check by default.
const List<double> standardEffortDistances = [
  1000,
  5000,
  10000,
  21097.5,
  42195,
];

/// Human-readable display name for a [standardEffortDistances] entry.
/// Falls back to a plain `"NNNN m"` label for any other distance (best
/// effort scanning is not restricted to the standard list).
///
/// Not `const`: a `double`-keyed const map is rejected by the analyzer
/// (`double` overrides `==`/`hashCode`, so it can't be used as a constant
/// map key) - `final` gives the same effective "build once" behaviour for
/// a top-level literal.
final Map<double, String> standardEffortDistanceNames = {
  1000: '1 km',
  5000: '5 km',
  10000: '10 km',
  21097.5: 'Half marathon',
  42195: 'Marathon',
};

/// Splits a track into [splitMeters]-long intervals (1 km by default; pass
/// `1609.344` for mile splits - see `core/domain/units.dart`).
///
/// Walks each segment (see library doc) accumulating haversine distance
/// between consecutive same-segment points; nothing is accumulated across a
/// segment boundary (a pause). Whenever a split boundary falls inside a
/// segment's leg, the crossing time (and, when both endpoints report
/// elevation, the crossing elevation) is linearly interpolated by
/// fractional distance along that leg - it is never snapped to either
/// sample's timestamp, since a GPS ping arriving a couple of seconds either
/// side of the true boundary would otherwise skew every split's pace. A
/// split may span a pause; its [Split.duration] is the sum of only the
/// in-segment time it covers.
///
/// A trailing partial split (whatever distance remains after the last full
/// [splitMeters] interval) is included only when it covers at least 50 m;
/// shorter remainders are dropped as noise slivers rather than reported as
/// a wildly-paced sub-split. Returns an empty list for fewer than two
/// (non-paused, distinct-timestamp) samples across the whole track (no
/// distance can be accumulated) or for a track shorter than 50 m.
List<Split> computeSplits(
  List<ActivitySample> samples, {
  double splitMeters = 1000,
}) {
  if (samples.length < 2) return [];

  final segments = _cleanedSegments(samples);

  double? splitStartElevation;
  for (final segment in segments) {
    if (segment.isNotEmpty) {
      splitStartElevation = segment.first.elevationMeters;
      break;
    }
  }

  final splits = <Split>[];
  var cumulativeDistance = 0.0;
  var cumulativeMovingDuration = Duration.zero;
  var splitStartDistance = 0.0;
  var splitStartDuration = Duration.zero;
  var nextBoundary = splitMeters;
  var splitIndex = 1;
  ActivitySample? lastSeenSample;

  for (final segment in segments) {
    for (var i = 1; i < segment.length; i++) {
      final prev = segment[i - 1];
      final cur = segment[i];
      lastSeenSample = cur;
      final legMeters = haversineDistanceMeters(
        prev.latitude,
        prev.longitude,
        cur.latitude,
        cur.longitude,
      );
      final legDuration = cur.timestamp.difference(prev.timestamp);
      final segmentStart = cumulativeDistance;
      final segmentEnd = cumulativeDistance + legMeters;

      while (nextBoundary <= segmentEnd && legMeters > 0) {
        final fraction = (nextBoundary - segmentStart) / legMeters;
        final movingDurationAtBoundary =
            cumulativeMovingDuration + _scaleDuration(legDuration, fraction);
        final boundaryElevation = _interpolateElevation(prev, cur, fraction);

        final distance = nextBoundary - splitStartDistance;
        final duration = movingDurationAtBoundary - splitStartDuration;
        splits.add(
          Split(
            index: splitIndex,
            distanceMeters: distance,
            duration: duration,
            paceSecondsPerKm: _paceSecondsPerKm(duration, distance),
            elevationDeltaMeters: _elevationDelta(
              splitStartElevation,
              boundaryElevation,
            ),
          ),
        );

        splitIndex++;
        splitStartDistance = nextBoundary;
        splitStartDuration = movingDurationAtBoundary;
        splitStartElevation = boundaryElevation;
        nextBoundary += splitMeters;
      }

      cumulativeDistance = segmentEnd;
      cumulativeMovingDuration += legDuration;
    }
  }

  final remainingMeters = cumulativeDistance - splitStartDistance;
  if (remainingMeters >= 50) {
    final duration = cumulativeMovingDuration - splitStartDuration;
    splits.add(
      Split(
        index: splitIndex,
        distanceMeters: remainingMeters,
        duration: duration,
        paceSecondsPerKm: _paceSecondsPerKm(duration, remainingMeters),
        elevationDeltaMeters: _elevationDelta(
          splitStartElevation,
          lastSeenSample?.elevationMeters,
        ),
      ),
    );
  }

  return splits;
}

/// Finds the fastest contiguous window of a *single segment* (see library
/// doc) covering at least [targetMeters], or `null` when no segment's own
/// distance reaches [targetMeters] (in particular, `null` for a track whose
/// total distance would be long enough only by summing across a pause - a
/// window may never span one).
///
/// Implemented as two linear (`O(samples.length)`) sweeps per segment, each
/// a two-pointer scan over that segment's own cumulative-distance points
/// (the global best is then the fastest result across every segment):
/// - Sweep 1 anchors the window's *start* at each recorded point in turn
///   and interpolates the *end* within whichever leg first reaches
///   `start + targetMeters`.
/// - Sweep 2 anchors the *end* at each recorded point and interpolates the
///   *start* within whichever leg first drops to `end - targetMeters`.
///
/// Both sweeps are needed for correctness: because distance-vs-time is
/// piecewise linear between samples, the true fastest window's duration is
/// affine in its start position within any single pair of legs, so the
/// minimum can only occur where at least one edge lands exactly on a
/// recorded sample - but that sample could be the window's start *or* its
/// end. Sweep 1 alone (naively taking the best window that starts at each
/// sample) can miss a fast window whose true minimum is realised with the
/// end pinned to a sample and the start falling inside a leg.
///
/// Out-of-order or duplicate timestamps are defended against by discarding
/// any sample whose timestamp does not strictly advance past the previous
/// *accepted* sample before building the cumulative-distance points used
/// above (the same [_cleanedSegments] helper [computeSplits] uses).
BestEffort? bestEffortFor(List<ActivitySample> samples, double targetMeters) {
  final segments = _cleanedSegments(samples);

  _Candidate? best;
  var runningOffset = 0.0;
  for (final segment in segments) {
    final points = _pointsFor(segment, baseOffset: runningOffset);
    if (points.isNotEmpty) runningOffset = points.last.distance;

    final candidate = _bestEffortInPoints(points, targetMeters);
    if (candidate != null &&
        (best == null || candidate.duration < best.duration)) {
      best = candidate;
    }
  }

  if (best == null) return null;
  return BestEffort(
    targetMeters: targetMeters,
    duration: best.duration,
    paceSecondsPerKm: _paceSecondsPerKm(best.duration, targetMeters),
    startOffsetMeters: best.startOffsetMeters,
  );
}

/// The dual-sweep scan itself (see [bestEffortFor] doc), scoped to a single
/// segment's own [points] - a window is never allowed to reach outside this
/// list, which is what keeps it from ever spanning a pause.
_Candidate? _bestEffortInPoints(List<_TrackPoint> points, double targetMeters) {
  if (points.length < 2) return null;
  if (points.last.distance - points.first.distance < targetMeters) {
    return null;
  }

  _Candidate? best;

  // Sweep 1: start anchored at each point, end interpolated.
  var endIndex = 0;
  for (var startIndex = 0; startIndex < points.length; startIndex++) {
    final targetDistance = points[startIndex].distance + targetMeters;
    if (endIndex < startIndex) endIndex = startIndex;
    while (endIndex < points.length - 1 &&
        points[endIndex].distance < targetDistance) {
      endIndex++;
    }
    if (points[endIndex].distance < targetDistance) break;

    final endTime = _interpolateTime(points, endIndex, targetDistance);
    final duration = endTime.difference(points[startIndex].time);
    best = _bestOf(best, _Candidate(duration, points[startIndex].distance));
  }

  // Sweep 2: end anchored at each point, start interpolated.
  var startIndex = 0;
  for (endIndex = 0; endIndex < points.length; endIndex++) {
    final targetDistance = points[endIndex].distance - targetMeters;
    if (targetDistance < points.first.distance) continue;
    while (startIndex < points.length - 1 &&
        points[startIndex + 1].distance < targetDistance) {
      startIndex++;
    }

    final DateTime startTime;
    final double startOffset;
    if (points[startIndex].distance >= targetDistance ||
        startIndex + 1 >= points.length) {
      startTime = points[startIndex].time;
      startOffset = points[startIndex].distance;
    } else {
      startTime = _interpolateTime(points, startIndex + 1, targetDistance);
      startOffset = targetDistance;
    }

    final duration = points[endIndex].time.difference(startTime);
    best = _bestOf(best, _Candidate(duration, startOffset));
  }

  return best;
}

class _Candidate {
  const _Candidate(this.duration, this.startOffsetMeters);
  final Duration duration;
  final double startOffsetMeters;
}

_Candidate _bestOf(_Candidate? current, _Candidate candidate) {
  if (current == null || candidate.duration < current.duration) {
    return candidate;
  }
  return current;
}

/// A track point with its cumulative distance-so-far, used by
/// [bestEffortFor].
class _TrackPoint {
  const _TrackPoint({required this.time, required this.distance});
  final DateTime time;
  final double distance;
}

/// Splits [samples] into maximal contiguous runs of non-paused samples
/// ("segments" - see library doc), after first discarding any sample whose
/// timestamp does not strictly advance past the previous *accepted* sample
/// (defends against out-of-order/duplicate timestamps). Shared by
/// [computeSplits] and [bestEffortFor] so both apply exactly the same
/// cleaning - previously only [bestEffortFor] did, which made this file's
/// own doc claim false for [computeSplits].
///
/// A paused sample is dropped entirely: it is never a segment's endpoint
/// and never used for interpolation, matching "paused samples are excluded
/// from analytics entirely" (library doc). A run of one non-paused sample
/// with paused (or track-boundary) neighbours on both sides becomes its own
/// one-sample segment - it contributes no leg (nothing to interpolate
/// between), but is not an error.
List<List<ActivitySample>> _cleanedSegments(List<ActivitySample> samples) {
  final segments = <List<ActivitySample>>[];
  ActivitySample? previousAccepted;
  var startingNewSegment = true;

  for (final sample in samples) {
    if (previousAccepted != null &&
        !sample.timestamp.isAfter(previousAccepted.timestamp)) {
      continue;
    }
    previousAccepted = sample;

    if (sample.isPaused) {
      startingNewSegment = true;
      continue;
    }
    if (startingNewSegment) {
      segments.add(<ActivitySample>[]);
      startingNewSegment = false;
    }
    segments.last.add(sample);
  }

  return segments;
}

/// Builds cumulative-distance points for a single segment's samples,
/// continuing the running distance total from [baseOffset] (the overall
/// moving distance accumulated by every earlier segment) rather than
/// restarting at zero - this is what makes [BestEffort.startOffsetMeters]
/// reflect the activity's overall moving-distance offset rather than an
/// offset relative to whichever segment happened to contain the winning
/// window.
List<_TrackPoint> _pointsFor(
  List<ActivitySample> segment, {
  required double baseOffset,
}) {
  if (segment.isEmpty) return const [];

  var cumulative = baseOffset;
  final points = <_TrackPoint>[
    _TrackPoint(time: segment.first.timestamp, distance: cumulative),
  ];
  for (var i = 1; i < segment.length; i++) {
    final prev = segment[i - 1];
    final cur = segment[i];
    cumulative += haversineDistanceMeters(
      prev.latitude,
      prev.longitude,
      cur.latitude,
      cur.longitude,
    );
    points.add(_TrackPoint(time: cur.timestamp, distance: cumulative));
  }
  return points;
}

/// Interpolates the time at which cumulative distance reaches
/// [targetDistance], within the segment ending at `points[endIndex]`.
DateTime _interpolateTime(
  List<_TrackPoint> points,
  int endIndex,
  double targetDistance,
) {
  if (endIndex == 0) return points[0].time;
  final start = points[endIndex - 1];
  final end = points[endIndex];
  final segmentDistance = end.distance - start.distance;
  if (segmentDistance <= 0) return end.time;
  final fraction = (targetDistance - start.distance) / segmentDistance;
  return start.time.add(
    _scaleDuration(end.time.difference(start.time), fraction),
  );
}

/// Scales [duration] by [fraction], clamped to `[0, 1]` to absorb
/// floating-point overshoot right at a segment boundary.
Duration _scaleDuration(Duration duration, double fraction) {
  final clamped = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0);
  return Duration(microseconds: (duration.inMicroseconds * clamped).round());
}

/// Linearly interpolates elevation by [fraction] between [prev] and [cur],
/// or `null` if either lacks elevation data.
double? _interpolateElevation(
  ActivitySample prev,
  ActivitySample cur,
  double fraction,
) {
  final prevElevation = prev.elevationMeters;
  final curElevation = cur.elevationMeters;
  if (prevElevation == null || curElevation == null) return null;
  return prevElevation + (curElevation - prevElevation) * fraction;
}

double? _elevationDelta(double? start, double? end) {
  if (start == null || end == null) return null;
  return end - start;
}

/// Average pace, seconds per kilometre, for covering [distanceMeters] in
/// [duration]. [distanceMeters] must be positive - callers only ever pass a
/// split/effort distance that already is.
double _paceSecondsPerKm(Duration duration, double distanceMeters) {
  final km = distanceMeters / 1000;
  final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
  return seconds / km;
}
