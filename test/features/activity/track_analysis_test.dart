import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';

/// Builds a straight-line (fixed longitude, increasing latitude) track of
/// [count] samples, so segment distance only ever depends on the latitude
/// step (`haversineDistanceMeters` with `dLon == 0` reduces to `R * dLat`
/// exactly - see `geo_math_test.dart`'s "0.001 degree of latitude is
/// ~111.19m" case) - this makes cumulative distance an exact, easily
/// predicted function of sample index regardless of timing, which is what
/// lets the tests below assert precise expected split/effort values instead
/// of just loose bounds.
///
/// [stepDurationFor] gives the wall-clock gap before sample `i + 1`
/// (`segmentIndex` `i`, `0`-based) - varying it per segment is how the
/// negative-split and fast-middle-segment tracks below encode a pace change
/// without changing the (uniform) spatial step.
List<ActivitySample> _buildTrack({
  required int count,
  required double stepDegreesLat,
  required Duration Function(int segmentIndex) stepDurationFor,
  DateTime? start,
  double? Function(int index)? elevationFor,
}) {
  final base = start ?? DateTime.utc(2026, 1, 1, 8);
  var time = base;
  final samples = <ActivitySample>[
    ActivitySample(
      id: 's0',
      activityId: 'a',
      timestamp: time,
      latitude: 0,
      longitude: 0,
      elevationMeters: elevationFor?.call(0),
    ),
  ];
  for (var i = 1; i < count; i++) {
    time = time.add(stepDurationFor(i - 1));
    samples.add(
      ActivitySample(
        id: 's$i',
        activityId: 'a',
        timestamp: time,
        latitude: i * stepDegreesLat,
        longitude: 0,
        elevationMeters: elevationFor?.call(i),
      ),
    );
  }
  return samples;
}

/// Builds a straight-line track (see [_buildTrack]) from consecutive
/// [phases], each contributing `steps` new samples at its own
/// `stepDegreesLat`/`stepDuration`/`isPaused` tag - used by the F2
/// (pause-aware analytics) tests below to build tracks with a mix of
/// paused and non-paused stretches. The very first sample (the track's
/// single starting point, before any phase's steps) is never paused.
List<ActivitySample> _phasedTrack(
  List<
    ({int steps, double stepDegreesLat, Duration stepDuration, bool isPaused})
  >
  phases,
) {
  var time = DateTime.utc(2026, 1, 1, 8);
  var lat = 0.0;
  var index = 0;
  final samples = <ActivitySample>[
    ActivitySample(
      id: 's0',
      activityId: 'a',
      timestamp: time,
      latitude: lat,
      longitude: 0,
    ),
  ];
  for (final phase in phases) {
    for (var i = 0; i < phase.steps; i++) {
      index++;
      time = time.add(phase.stepDuration);
      lat += phase.stepDegreesLat;
      samples.add(
        ActivitySample(
          id: 's$index',
          activityId: 'a',
          timestamp: time,
          latitude: lat,
          longitude: 0,
          isPaused: phase.isPaused,
        ),
      );
    }
  }
  return samples;
}

void main() {
  // A straight-line track's per-step distance depends only on the latitude
  // step (see `_buildTrack` doc) - computed once via the real
  // `haversineDistanceMeters` (already independently covered by
  // `geo_math_test.dart`) rather than hand-derived, so a change to Earth's
  // assumed radius there can't silently desync these expectations.
  final stepMeters = haversineDistanceMeters(0, 0, 0.0001, 0);

  group('computeSplits', () {
    test('empty samples returns no splits', () {
      expect(computeSplits(const []), isEmpty);
    });

    test('a single sample returns no splits', () {
      final samples = [
        ActivitySample(
          id: 's0',
          activityId: 'a',
          timestamp: DateTime.utc(2026),
          latitude: 0,
          longitude: 0,
        ),
      ];
      expect(computeSplits(samples), isEmpty);
    });

    test(
      'constant speed: every split (incl. the trailing partial) has the '
      'same exact pace, with boundaries interpolated rather than snapped '
      'to a sample timestamp',
      () {
        // 320 samples, 1s apart, each stepMeters further north: total
        // distance ~= 319 * stepMeters (~3547m) - three full 1 km splits
        // plus a >= 50 m trailing partial.
        final samples = _buildTrack(
          count: 320,
          stepDegreesLat: 0.0001,
          stepDurationFor: (_) => const Duration(seconds: 1),
        );
        final totalDistance = 319 * stepMeters;
        final speedMetersPerSecond = stepMeters; // stepDuration == 1s.
        final expectedPace = 1000 / speedMetersPerSecond;

        final splits = computeSplits(samples);

        expect(splits, hasLength(4));
        expect(splits.map((s) => s.index).toList(), [1, 2, 3, 4]);
        for (final split in splits.take(3)) {
          expect(split.distanceMeters, closeTo(1000, 1e-6));
        }
        final remaining = totalDistance - 3000;
        expect(splits.last.distanceMeters, closeTo(remaining, 1e-6));

        // If a boundary crossing were wrongly snapped to the nearest
        // sample's timestamp instead of interpolated, every split's pace
        // would drift from this exact analytic value by roughly
        // (1 sample period / split duration) - about 1%, which the tight
        // tolerance below would catch.
        for (final split in splits) {
          expect(split.paceSecondsPerKm, closeTo(expectedPace, 1e-3));
        }
      },
    );

    test(
      'negative split: a track that speeds up partway through produces '
      'strictly decreasing split paces',
      () {
        // Phase A: 105 samples (104 segments), 2s apart -> slow.
        // Phase B: 89 more segments, 1s apart, same spatial step -> 2x as
        // fast. Distance only depends on sample index (uniform spatial
        // step throughout), so split boundaries land at predictable
        // indices regardless of the timing kink.
        const phaseASegments = 104;
        final samples = _buildTrack(
          count: phaseASegments + 1 + 89,
          stepDegreesLat: 0.0001,
          stepDurationFor: (segmentIndex) => segmentIndex < phaseASegments
              ? const Duration(seconds: 2)
              : const Duration(seconds: 1),
        );

        final splits = computeSplits(samples);

        // Split 1 (0-1000m) falls entirely within phase A (which covers
        // 0..104*stepMeters =~ 1156m) - its pace must equal phase A's exact
        // analytic pace.
        final phaseAPace = 2 * 1000 / stepMeters;
        expect(splits[0].paceSecondsPerKm, closeTo(phaseAPace, 1e-2));

        // The trailing partial split falls entirely within phase B (which
        // starts at ~1156m) - its pace must equal phase B's exact analytic
        // pace, i.e. exactly half of phase A's.
        final phaseBPace = 1000 / stepMeters;
        expect(splits.last.paceSecondsPerKm, closeTo(phaseBPace, 1e-2));

        // Every split in between is strictly faster than the one before -
        // a clean negative-split pattern - because each subsequent split
        // contains a strictly larger share of the fast phase.
        for (var i = 1; i < splits.length; i++) {
          expect(
            splits[i].paceSecondsPerKm,
            lessThan(splits[i - 1].paceSecondsPerKm),
          );
        }
      },
    );

    test(
      'a trailing partial split of at least 50m is included, with pace '
      'computed from its actual (shorter) distance',
      () {
        // 61 samples of stepMeters (~11.12m) each, 1s apart: total
        // distance ~= 60 * 11.1195 =~ 667.2m -> one full split's worth
        // isn't even reached, so the whole track is itself one "trailing"
        // partial >= 50m.
        final samples = _buildTrack(
          count: 61,
          stepDegreesLat: 0.0001,
          stepDurationFor: (_) => const Duration(seconds: 1),
        );
        final totalDistance = 60 * stepMeters;
        expect(totalDistance, greaterThanOrEqualTo(50));
        expect(totalDistance, lessThan(1000));

        final splits = computeSplits(samples);

        expect(splits, hasLength(1));
        expect(splits.single.index, 1);
        expect(splits.single.distanceMeters, closeTo(totalDistance, 1e-6));
        expect(
          splits.single.paceSecondsPerKm,
          closeTo(1000 / stepMeters, 1e-3),
        );
      },
    );

    test('a trailing remainder under 50m is dropped as a noise sliver', () {
      // 4 samples of stepMeters (~11.12m) each: total distance ~= 33.4m,
      // under the 50m inclusion threshold.
      final samples = _buildTrack(
        count: 4,
        stepDegreesLat: 0.0001,
        stepDurationFor: (_) => const Duration(seconds: 1),
      );
      expect(3 * stepMeters, lessThan(50));

      expect(computeSplits(samples), isEmpty);
    });

    test('elevationDeltaMeters is end-minus-start when both are present', () {
      final samples = _buildTrack(
        count: 61,
        stepDegreesLat: 0.0001,
        stepDurationFor: (_) => const Duration(seconds: 1),
        elevationFor: (i) => 100 + i * 0.5,
      );

      final splits = computeSplits(samples);

      expect(splits.single.elevationDeltaMeters, isNotNull);
      expect(splits.single.elevationDeltaMeters, closeTo(30, 0.5));
    });

    test('elevationDeltaMeters is null when elevation data is absent', () {
      final samples = _buildTrack(
        count: 61,
        stepDegreesLat: 0.0001,
        stepDurationFor: (_) => const Duration(seconds: 1),
      );

      final splits = computeSplits(samples);

      expect(splits.single.elevationDeltaMeters, isNull);
    });

    test('mile splits use 1609.344m instead of 1000m', () {
      final samples = _buildTrack(
        count: 320,
        stepDegreesLat: 0.0001,
        stepDurationFor: (_) => const Duration(seconds: 1),
      );

      final splits = computeSplits(samples, splitMeters: 1609.344);

      expect(splits, isNotEmpty);
      for (final split in splits.take(splits.length - 1)) {
        expect(split.distanceMeters, closeTo(1609.344, 1e-6));
      }
    });

    test(
      'a mid-track paused stretch is excluded from both distance and '
      'duration - a split may span the pause, but its duration only counts '
      'in-segment (moving) time (F2)',
      () {
        const segmentSteps = 89;
        final samples = _phasedTrack([
          (
            steps: segmentSteps,
            stepDegreesLat: 0.0001,
            stepDuration: const Duration(seconds: 1),
            isPaused: false,
          ),
          // A "tram" stretch marked paused: moves ~200m over 54 real
          // seconds. If this distance/time leaked in, split 1's boundary
          // would land inside this stretch instead of just past it, and
          // its duration would include a chunk of these 54s.
          (
            steps: 18,
            stepDegreesLat: 0.0001,
            stepDuration: const Duration(seconds: 3),
            isPaused: true,
          ),
          (
            steps: segmentSteps,
            stepDegreesLat: 0.0001,
            stepDuration: const Duration(seconds: 1),
            isPaused: false,
          ),
        ]);
        expect(18 * stepMeters, closeTo(200, 5));

        final segmentDistance = segmentSteps * stepMeters;
        expect(segmentDistance, lessThan(1000));
        expect(segmentDistance + stepMeters, greaterThan(1000));

        final splits = computeSplits(samples);
        expect(splits, hasLength(2));

        // Split 1's 1000m boundary falls a fraction of the way into
        // segment B's very first leg - entirely past segment A, entirely
        // ignoring the paused stretch in between.
        final fraction = (1000 - segmentDistance) / stepMeters;
        final expectedSplit1Seconds = segmentSteps + fraction;
        expect(splits[0].distanceMeters, closeTo(1000, 1e-6));
        expect(
          splits[0].duration.inMicroseconds / Duration.microsecondsPerSecond,
          closeTo(expectedSplit1Seconds, 1e-6),
        );

        // Split 2 (trailing partial) covers the rest of segment B.
        //
        // Segment B has one fewer *leg* than segment A despite both phases
        // adding `segmentSteps` new samples: segment A also has the
        // track's very first sample (`s0`, seeded before any phase runs)
        // as an extra leg endpoint, but segment B's first sample IS the
        // first new sample its own phase adds - there's no equivalent
        // "seed" sample carried over across the paused break (segments
        // never share an endpoint - see `_cleanedSegments`'s doc). So
        // segment B's own distance/duration is `(segmentSteps - 1)`
        // legs' worth, not `segmentSteps`.
        final segmentBDistance = (segmentSteps - 1) * stepMeters;
        final totalMovingDistance = segmentDistance + segmentBDistance;
        final expectedSplit2Distance = totalMovingDistance - 1000;
        const totalMovingSeconds = segmentSteps + (segmentSteps - 1);
        final expectedSplit2Seconds =
            totalMovingSeconds - expectedSplit1Seconds;
        expect(
          splits[1].distanceMeters,
          closeTo(expectedSplit2Distance, 1e-6),
        );
        expect(
          splits[1].duration.inMicroseconds / Duration.microsecondsPerSecond,
          closeTo(expectedSplit2Seconds, 1e-6),
        );

        // Reconciliation: the splits' totals equal the sum of the two real
        // segments alone - the paused stretch's ~200m and 54s contribute
        // nothing at all (see `track_analysis.dart`'s "reconciliation
        // goal" doc).
        final totalSplitDistance = splits.fold<double>(
          0,
          (sum, s) => sum + s.distanceMeters,
        );
        final totalSplitSeconds = splits.fold<double>(
          0,
          (sum, s) =>
              sum + s.duration.inMicroseconds / Duration.microsecondsPerSecond,
        );
        expect(totalSplitDistance, closeTo(totalMovingDistance, 1e-6));
        expect(totalSplitSeconds, closeTo(totalMovingSeconds, 1e-6));
      },
    );

    test(
      'skips out-of-order/duplicate timestamps rather than producing a '
      'nonsensical split - computeSplits shares the exact same defense as '
      'bestEffortFor (see library doc)',
      () {
        final base = DateTime.utc(2026, 1, 1, 8);
        final samples = [
          ActivitySample(
            id: 's0',
            activityId: 'a',
            timestamp: base,
            latitude: 0,
            longitude: 0,
          ),
          ActivitySample(
            id: 's1',
            activityId: 'a',
            timestamp: base.add(const Duration(seconds: 10)),
            latitude: 0.001,
            longitude: 0,
          ),
          // Duplicate/out-of-order: same timestamp as s1 - dropped.
          ActivitySample(
            id: 's1-dup',
            activityId: 'a',
            timestamp: base.add(const Duration(seconds: 10)),
            latitude: 0.0011,
            longitude: 0,
          ),
          ActivitySample(
            id: 's2',
            activityId: 'a',
            timestamp: base.add(const Duration(seconds: 20)),
            latitude: 0.002,
            longitude: 0,
          ),
        ];

        final totalDistance = haversineDistanceMeters(0, 0, 0.002, 0);
        expect(totalDistance, greaterThanOrEqualTo(50));
        expect(totalDistance, lessThan(1000));

        final splits = computeSplits(samples);

        expect(splits, hasLength(1));
        expect(splits.single.distanceMeters, closeTo(totalDistance, 1e-6));
        expect(splits.single.duration, const Duration(seconds: 20));
      },
    );

    test(
      'elevationDeltaMeters on a FULL split (not just a trailing partial) '
      'is exactly interpolated at the boundary',
      () {
        final samples = _buildTrack(
          count: 250,
          stepDegreesLat: 0.0001,
          stepDurationFor: (_) => const Duration(seconds: 1),
          elevationFor: (i) => 100 + i * 0.5,
        );

        final splits = computeSplits(samples);
        expect(splits.length, greaterThanOrEqualTo(2));

        // Elevation is exactly affine in cumulative distance here (uniform
        // per-step distance and per-step elevation gain), so the
        // interpolated elevation at any boundary - regardless of which
        // sample pair straddles it - is exactly
        // `100 + (distance / stepMeters) * 0.5`.
        final expectedDelta = (1000 / stepMeters) * 0.5;
        expect(splits[0].elevationDeltaMeters, closeTo(expectedDelta, 1e-6));
      },
    );
  });

  group('bestEffortFor', () {
    test('fewer than two samples returns null', () {
      expect(bestEffortFor(const [], 1000), isNull);
      final single = [
        ActivitySample(
          id: 's0',
          activityId: 'a',
          timestamp: DateTime.utc(2026),
          latitude: 0,
          longitude: 0,
        ),
      ];
      expect(bestEffortFor(single, 1000), isNull);
    });

    test('target distance longer than the track returns null', () {
      final samples = _buildTrack(
        count: 10,
        stepDegreesLat: 0.0001,
        stepDurationFor: (_) => const Duration(seconds: 1),
      );
      final total = 9 * stepMeters;

      expect(bestEffortFor(samples, total + 1), isNull);
    });

    test('constant speed: any window of the target distance is exact', () {
      final samples = _buildTrack(
        count: 200,
        stepDegreesLat: 0.0001,
        stepDurationFor: (_) => const Duration(seconds: 1),
      );
      final speed = stepMeters; // metres per second.

      final effort = bestEffortFor(samples, 1000);

      expect(effort, isNotNull);
      expect(effort!.targetMeters, 1000);
      expect(
        effort.duration.inMicroseconds / Duration.microsecondsPerSecond,
        closeTo(1000 / speed, 1e-3),
      );
      expect(effort.paceSecondsPerKm, closeTo(1000 / speed, 1e-3));
    });

    test(
      'finds a fast segment in the middle of the track, not just a prefix '
      'from the start - contested against a naive prefix-only calculation',
      () {
        // Phase 1 (slow, 2s/step): comfortably more than 1000m so it can't
        // be "used up" by the fast window below.
        // Phase 2 (fast, 1s/step, i.e. 2x phase 1's speed): exactly enough
        // segments to fit a full 1000m window with a little room to spare
        // on both sides, so the true best 1000m effort sits entirely
        // inside it.
        // Phase 3 (slow again, 2s/step): proves the scan doesn't just stop
        // once it finds *a* window - the true minimum must still win over
        // whatever a prefix/suffix-only search would report.
        final phase1Segments = (1200 / stepMeters).ceil();
        final phase2Segments = (1000 / stepMeters).ceil() + 4;
        final phase3Segments = (1200 / stepMeters).ceil();
        final totalSegments = phase1Segments + phase2Segments + phase3Segments;

        final samples = _buildTrack(
          count: totalSegments + 1,
          stepDegreesLat: 0.0001,
          stepDurationFor: (segmentIndex) {
            if (segmentIndex < phase1Segments) {
              return const Duration(seconds: 2);
            }
            if (segmentIndex < phase1Segments + phase2Segments) {
              return const Duration(seconds: 1);
            }
            return const Duration(seconds: 2);
          },
        );

        final effort = bestEffortFor(samples, 1000);
        expect(effort, isNotNull);

        final fastSpeed = stepMeters; // 1s/step.
        final expectedFastDurationSeconds = 1000 / fastSpeed;
        final effortSeconds =
            effort!.duration.inMicroseconds / Duration.microsecondsPerSecond;
        expect(effortSeconds, closeTo(expectedFastDurationSeconds, 1e-2));

        // It must have found a window that starts after phase 1 - not the
        // slow prefix from the very beginning of the track.
        final phase1Distance = phase1Segments * stepMeters;
        expect(effort.startOffsetMeters, greaterThan(phase1Distance - 1));

        // A naive "first target metres from the start" implementation
        // would report roughly phase 1's slow pace (2s/step, i.e. exactly
        // double the true fastest window's duration) instead.
        final naivePrefixDurationSeconds = 2 * expectedFastDurationSeconds;
        expect(
          effortSeconds,
          lessThan(naivePrefixDurationSeconds * 0.6),
        );
      },
    );

    test(
      'skips out-of-order/duplicate timestamps rather than producing a '
      'nonsensical (e.g. negative) duration',
      () {
        final base = DateTime.utc(2026, 1, 1, 8);
        final samples = [
          ActivitySample(
            id: 's0',
            activityId: 'a',
            timestamp: base,
            latitude: 0,
            longitude: 0,
          ),
          ActivitySample(
            id: 's1',
            activityId: 'a',
            timestamp: base.add(const Duration(seconds: 10)),
            latitude: 0.001,
            longitude: 0,
          ),
          // Duplicate/out-of-order: same or earlier timestamp than s1.
          ActivitySample(
            id: 's1-dup',
            activityId: 'a',
            timestamp: base.add(const Duration(seconds: 10)),
            latitude: 0.0011,
            longitude: 0,
          ),
          ActivitySample(
            id: 's2',
            activityId: 'a',
            timestamp: base.add(const Duration(seconds: 20)),
            latitude: 0.002,
            longitude: 0,
          ),
        ];

        final total = haversineDistanceMeters(0, 0, 0.002, 0);
        final effort = bestEffortFor(samples, total);

        expect(effort, isNotNull);
        expect(effort!.duration.isNegative, isFalse);
        expect(effort.duration, const Duration(seconds: 20));
      },
    );

    test(
      'brute-force cross-check on a small, hand-built irregular track',
      () {
        // Hardcoded (not random) irregular segment lat-steps and time
        // deltas, so speed genuinely varies segment-to-segment.
        const latSteps = [0.0003, 0.0001, 0.0006, 0.0002, 0.0004];
        const timeStepsSeconds = [4, 1, 7, 2, 3];
        final base = DateTime.utc(2026, 1, 1, 8);

        var lat = 0.0;
        var time = base;
        final samples = <ActivitySample>[
          ActivitySample(
            id: 's0',
            activityId: 'a',
            timestamp: time,
            latitude: lat,
            longitude: 0,
          ),
        ];
        for (var i = 0; i < latSteps.length; i++) {
          lat += latSteps[i];
          time = time.add(Duration(seconds: timeStepsSeconds[i]));
          samples.add(
            ActivitySample(
              id: 's${i + 1}',
              activityId: 'a',
              timestamp: time,
              latitude: lat,
              longitude: 0,
            ),
          );
        }

        // Total track distance is ~178m (sum of the lat steps above,
        // converted via the same exact dLon==0 identity used throughout
        // this file) - comfortably more than the target below, leaving
        // real room for the scan to choose among multiple candidate
        // windows.
        const targetMeters = 100.0;
        final effort = bestEffortFor(samples, targetMeters);
        expect(effort, isNotNull);

        final bruteForce = _fineBruteForceBestEffort(samples, targetMeters);
        final effortSeconds =
            effort!.duration.inMicroseconds / Duration.microsecondsPerSecond;
        final bruteForceSeconds =
            bruteForce.inMicroseconds / Duration.microsecondsPerSecond;

        // The exact two-sweep implementation must never do worse than a
        // fine-grained (but approximate) numerical scan, and shouldn't beat
        // it by more than the scan's own resolution error.
        expect(effortSeconds, lessThanOrEqualTo(bruteForceSeconds + 0.05));
        expect(effortSeconds, closeTo(bruteForceSeconds, 0.5));
      },
    );

    test(
      'brute-force cross-check on a mirrored hand-built track (fast start, '
      'slow finish - the reverse pace shape of the irregular track above) '
      'so both two-pointer sweeps are load-bearing',
      () {
        // Exactly the arrays from the irregular-track test above, reversed
        // element-for-element.
        const latSteps = [0.0004, 0.0002, 0.0006, 0.0001, 0.0003];
        const timeStepsSeconds = [3, 2, 7, 1, 4];
        final base = DateTime.utc(2026, 1, 1, 8);

        var lat = 0.0;
        var time = base;
        final samples = <ActivitySample>[
          ActivitySample(
            id: 's0',
            activityId: 'a',
            timestamp: time,
            latitude: lat,
            longitude: 0,
          ),
        ];
        for (var i = 0; i < latSteps.length; i++) {
          lat += latSteps[i];
          time = time.add(Duration(seconds: timeStepsSeconds[i]));
          samples.add(
            ActivitySample(
              id: 's${i + 1}',
              activityId: 'a',
              timestamp: time,
              latitude: lat,
              longitude: 0,
            ),
          );
        }

        const targetMeters = 100.0;
        final effort = bestEffortFor(samples, targetMeters);
        expect(effort, isNotNull);

        final bruteForce = _fineBruteForceBestEffort(samples, targetMeters);
        final effortSeconds =
            effort!.duration.inMicroseconds / Duration.microsecondsPerSecond;
        final bruteForceSeconds =
            bruteForce.inMicroseconds / Duration.microsecondsPerSecond;

        expect(effortSeconds, lessThanOrEqualTo(bruteForceSeconds + 0.05));
        expect(effortSeconds, closeTo(bruteForceSeconds, 0.5));
      },
    );

    test(
      'a best-effort window can never span a pause - a fast "tram" stretch '
      'marked paused can never win a PR, even though it alone covers the '
      'target distance far faster than any legitimate segment (F2)',
      () {
        const targetMeters = 1000.0;
        // A: real recording, comfortably short of the target on its own.
        const aSteps = 55;
        // A "tram" stretch, marked paused: covers *more* than the target
        // distance in a fraction of the time either real segment takes -
        // if this were wrongly treated as eligible, it would win easily.
        const pausedSteps = 95;
        // C: real recording - the only segment that legitimately reaches
        // the target on its own.
        const cSteps = 95;
        final samples = _phasedTrack([
          (
            steps: aSteps,
            stepDegreesLat: 0.0001,
            stepDuration: const Duration(seconds: 5),
            isPaused: false,
          ),
          (
            steps: pausedSteps,
            stepDegreesLat: 0.0001,
            stepDuration: const Duration(milliseconds: 100),
            isPaused: true,
          ),
          (
            steps: cSteps,
            stepDegreesLat: 0.0001,
            stepDuration: const Duration(seconds: 1),
            isPaused: false,
          ),
        ]);

        expect(aSteps * stepMeters, lessThan(targetMeters));
        expect(pausedSteps * stepMeters, greaterThan(targetMeters));
        expect(cSteps * stepMeters, greaterThan(targetMeters));

        final effort = bestEffortFor(samples, targetMeters);
        expect(effort, isNotNull);

        // The only legitimate winner is a window inside segment C, at its
        // exact analytic pace (1s/step).
        final expectedSeconds = targetMeters / stepMeters;
        final actualSeconds =
            effort!.duration.inMicroseconds / Duration.microsecondsPerSecond;
        expect(actualSeconds, closeTo(expectedSeconds, 1e-2));

        // The paused stretch's pace (0.1s/step) would produce a ~10x
        // faster "effort" if it were wrongly included - guard against that
        // leaking through rather than just checking the exact value above.
        final illegalSeconds = targetMeters / stepMeters * 0.1;
        expect(actualSeconds, greaterThan(illegalSeconds * 3));
      },
    );
  });
}

/// Independent (from `bestEffortFor`'s two-pointer sweeps), deliberately
/// un-optimised cross-check: densely samples candidate window start
/// positions across the whole track and interpolates both that window's
/// start and end time, taking the minimum duration found. Not exact (it
/// only checks [resolution] candidate positions, not the true continuum),
/// but with a fine enough resolution it lands extremely close to the true
/// minimum - close enough to catch an indexing/off-by-one bug in the
/// production two-pointer sweeps without sharing any code with them.
Duration _fineBruteForceBestEffort(
  List<ActivitySample> samples,
  double targetMeters, {
  int resolution = 5000,
}) {
  final times = <DateTime>[samples.first.timestamp];
  final distances = <double>[0];
  for (var i = 1; i < samples.length; i++) {
    final prev = samples[i - 1];
    final cur = samples[i];
    distances.add(
      distances.last +
          haversineDistanceMeters(
            prev.latitude,
            prev.longitude,
            cur.latitude,
            cur.longitude,
          ),
    );
    times.add(cur.timestamp);
  }
  final total = distances.last;

  DateTime timeAtDistance(double target) {
    if (target <= 0) return times.first;
    if (target >= total) return times.last;
    var idx = 0;
    while (idx < distances.length - 1 && distances[idx + 1] < target) {
      idx++;
    }
    final segStart = distances[idx];
    final segEnd = distances[idx + 1];
    final segSpan = segEnd - segStart;
    final fraction = segSpan > 0 ? (target - segStart) / segSpan : 0.0;
    final t0 = times[idx];
    final t1 = times[idx + 1];
    return t0.add(
      Duration(
        microseconds: (t1.difference(t0).inMicroseconds * fraction).round(),
      ),
    );
  }

  Duration? best;
  final maxStart = total - targetMeters;
  for (var k = 0; k <= resolution; k++) {
    final startDistance = maxStart * k / resolution;
    final startTime = timeAtDistance(startDistance);
    final endTime = timeAtDistance(startDistance + targetMeters);
    final duration = endTime.difference(startTime);
    if (best == null || duration < best) best = duration;
  }
  return best!;
}
