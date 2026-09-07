import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';

/// A straight-line track of [count] samples, each [stepDegreesLat] further
/// north and [stepSeconds] later than the last - see
/// `track_analysis_test.dart`'s `_buildTrack` for why a fixed-longitude
/// straight line makes distance an exact, predictable function of sample
/// index.
List<ActivitySample> _track(
  String activityId, {
  required int count,
  required double stepDegreesLat,
  required int stepSeconds,
}) {
  final base = DateTime.utc(2026, 1, 1, 8);
  return [
    for (var i = 0; i < count; i++)
      ActivitySample(
        id: '$activityId-s$i',
        activityId: activityId,
        timestamp: base.add(Duration(seconds: i * stepSeconds)),
        latitude: i * stepDegreesLat,
        longitude: 0,
      ),
  ];
}

Activity _activity({
  required String id,
  required String title,
  required ActivitySource source,
  double distanceMeters = 5000,
  double? elevationGainMeters,
  DateTime? startedAt,
}) {
  final when = startedAt ?? DateTime.utc(2026);
  return Activity(
    id: id,
    activityType: ActivityType.run,
    title: title,
    startedAt: when,
    movingTime: const Duration(minutes: 30),
    elapsedTime: const Duration(minutes: 30),
    distanceMeters: distanceMeters,
    elevationGainMeters: elevationGainMeters,
    source: source,
    createdAt: when,
    updatedAt: when,
  );
}

void main() {
  group('computePersonalRecords', () {
    test('empty inputs produce an empty PersonalRecords', () {
      final result = computePersonalRecords(
        allActivities: const [],
        samplesByActivityId: const {},
      );

      expect(result.bestEfforts, isEmpty);
      expect(result.longestDistance, isNull);
      expect(result.mostElevationGain, isNull);
    });

    test('the fastest activity across all of them wins each effort PR', () {
      final slow = _activity(
        id: 'slow',
        title: 'Slow run',
        source: ActivitySource.recorded,
      );
      final fast = _activity(
        id: 'fast',
        title: 'Fast run',
        source: ActivitySource.recorded,
      );

      final result = computePersonalRecords(
        allActivities: [slow, fast],
        samplesByActivityId: {
          // 2s/step - slower.
          'slow': _track(
            'slow',
            count: 200,
            stepDegreesLat: 0.0001,
            stepSeconds: 2,
          ),
          // 1s/step, same spatial step - twice as fast.
          'fast': _track(
            'fast',
            count: 200,
            stepDegreesLat: 0.0001,
            stepSeconds: 1,
          ),
        },
      );

      final pr1km = result.bestEfforts[1000];
      expect(pr1km, isNotNull);
      expect(pr1km!.activityId, 'fast');
      expect(pr1km.activityTitle, 'Fast run');
    });

    test(
      'a later, even faster activity replaces the previous PR holder',
      () {
        final first = _activity(
          id: 'first',
          title: 'First',
          source: ActivitySource.recorded,
          startedAt: DateTime.utc(2026),
        );
        final second = _activity(
          id: 'second',
          title: 'Second (faster)',
          source: ActivitySource.recorded,
          startedAt: DateTime.utc(2026, 1, 2),
        );

        final result = computePersonalRecords(
          allActivities: [first, second],
          samplesByActivityId: {
            'first': _track(
              'first',
              count: 200,
              stepDegreesLat: 0.0001,
              stepSeconds: 2,
            ),
            'second': _track(
              'second',
              count: 200,
              stepDegreesLat: 0.0001,
              stepSeconds: 1,
            ),
          },
        );

        expect(result.bestEfforts[1000]!.activityId, 'second');
      },
    );

    test(
      'a manually-logged activity competes for longest-distance and '
      'most-elevation-gain but never for a best-effort PR (no samples)',
      () {
        final manual = _activity(
          id: 'manual',
          title: 'Manual long walk',
          source: ActivitySource.manual,
          distanceMeters: 50000,
          elevationGainMeters: 900,
        );
        final recorded = _activity(
          id: 'recorded',
          title: 'Recorded run',
          source: ActivitySource.recorded,
          elevationGainMeters: 50,
        );

        final result = computePersonalRecords(
          allActivities: [manual, recorded],
          samplesByActivityId: {
            'recorded': _track(
              'recorded',
              count: 200,
              stepDegreesLat: 0.0001,
              stepSeconds: 1,
            ),
          },
        );

        expect(result.longestDistance!.activityId, 'manual');
        expect(result.longestDistance!.value, 50000);
        expect(result.mostElevationGain!.activityId, 'manual');
        expect(result.mostElevationGain!.value, 900);
        // The manual activity has no entry in samplesByActivityId, so it
        // cannot contribute a best-effort PR - only "recorded" can.
        expect(result.bestEfforts[1000]!.activityId, 'recorded');
      },
    );

    test(
      'an activity with zero/negative distance never wins longest-distance',
      () {
        final zero = _activity(
          id: 'zero',
          title: 'Zero',
          source: ActivitySource.manual,
          distanceMeters: 0,
        );

        final result = computePersonalRecords(
          allActivities: [zero],
          samplesByActivityId: const {},
        );

        expect(result.longestDistance, isNull);
      },
    );

    test(
      'an activity with no elevationGainMeters recorded is skipped for '
      'that PR rather than treated as a zero-gain contender',
      () {
        final noElevation = _activity(
          id: 'a',
          title: 'No elevation data',
          source: ActivitySource.manual,
        );

        final result = computePersonalRecords(
          allActivities: [noElevation],
          samplesByActivityId: const {},
        );

        expect(result.mostElevationGain, isNull);
      },
    );

    test(
      'on an exact best-effort tie, the earlier startedAt keeps the '
      'record, independent of input order (F3)',
      () {
        final earlier = _activity(
          id: 'earlier',
          title: 'Earlier',
          source: ActivitySource.recorded,
          // `_activity`'s default `startedAt` is `DateTime.utc(2026)`,
          // i.e. 2026-01-01 - the earliest of this pair.
        );
        final later = _activity(
          id: 'later',
          title: 'Later (same pace)',
          source: ActivitySource.recorded,
          startedAt: DateTime.utc(2026, 1, 2),
        );

        final result = computePersonalRecords(
          // `later` listed first - a naive strict `>`/`<` comparison would
          // keep whichever tied activity is iterated first, which would
          // wrongly credit `later` under this ordering.
          allActivities: [later, earlier],
          samplesByActivityId: {
            'later': _track(
              'later',
              count: 200,
              stepDegreesLat: 0.0001,
              stepSeconds: 1,
            ),
            'earlier': _track(
              'earlier',
              count: 200,
              stepDegreesLat: 0.0001,
              stepSeconds: 1,
            ),
          },
        );

        expect(result.bestEfforts[1000]!.activityId, 'earlier');
      },
    );

    test(
      'on an exact longest-distance tie, the earlier startedAt keeps the '
      'record, independent of input order (F3)',
      () {
        final earlier = _activity(
          id: 'earlier',
          title: 'Earlier',
          source: ActivitySource.manual,
          distanceMeters: 10000,
          // `_activity`'s default `startedAt` is `DateTime.utc(2026)`,
          // i.e. 2026-01-01 - the earliest of this pair.
        );
        final later = _activity(
          id: 'later',
          title: 'Later (same distance)',
          source: ActivitySource.manual,
          distanceMeters: 10000,
          startedAt: DateTime.utc(2026, 1, 2),
        );

        final result = computePersonalRecords(
          allActivities: [later, earlier],
          samplesByActivityId: const {},
        );

        expect(result.longestDistance!.activityId, 'earlier');
      },
    );

    test(
      'on an exact most-elevation-gain tie, the earlier startedAt keeps '
      'the record, independent of input order (F3)',
      () {
        final earlier = _activity(
          id: 'earlier',
          title: 'Earlier',
          source: ActivitySource.manual,
          elevationGainMeters: 500,
          // `_activity`'s default `startedAt` is `DateTime.utc(2026)`,
          // i.e. 2026-01-01 - the earliest of this pair.
        );
        final later = _activity(
          id: 'later',
          title: 'Later (same elevation)',
          source: ActivitySource.manual,
          elevationGainMeters: 500,
          startedAt: DateTime.utc(2026, 1, 2),
        );

        final result = computePersonalRecords(
          allActivities: [later, earlier],
          samplesByActivityId: const {},
        );

        expect(result.mostElevationGain!.activityId, 'earlier');
      },
    );
  });
}
