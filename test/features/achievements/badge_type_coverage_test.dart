import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_inputs.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress_engine.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

import 'achievement_fixtures.dart';

/// Rule 7 of `domain/badge_catalogue.dart`, proved rather than asserted.
///
/// Every [ActivityType] must have at least one tiered ladder and at least
/// two one-off badges that can genuinely fire for it. The word doing the
/// work is *genuinely*: a list of ids anybody could write down proves
/// nothing, so [_claimedCoverage] is only the claim, and the last test in
/// this file puts one ordinary session of each type through the real
/// engine and checks that every badge claimed actually moved.
///
/// This is why a new value on [ActivityType] fails the suite: it will have
/// no entry here, and no amount of editing the entry will pass until the
/// catalogue really covers it.
typedef _Coverage = ({List<String> tiered, List<String> oneOffs});

const Map<ActivityType, _Coverage> _claimedCoverage = {
  ActivityType.run: (
    tiered: ['sessions_logged', 'run_distance', 'elevation_climbed'],
    oneOffs: ['first_activity', 'big_climb_session', 'palindrome_distance'],
  ),
  ActivityType.walk: (
    tiered: ['sessions_logged', 'walk_distance', 'elevation_climbed'],
    oneOffs: [
      'first_activity',
      'first_walk',
      'long_walk',
      'big_climb_session',
    ],
  ),
  ActivityType.hike: (
    tiered: ['sessions_logged', 'hike_distance', 'elevation_climbed'],
    oneOffs: [
      'first_activity',
      'first_hike',
      'long_hike',
      'big_climb_session',
    ],
  ),
  ActivityType.ride: (
    tiered: ['sessions_logged', 'ride_distance', 'elevation_climbed'],
    oneOffs: [
      'first_activity',
      'first_ride',
      'long_ride',
      'big_climb_session',
    ],
  ),
  ActivityType.strength: (
    tiered: ['sessions_logged', 'strength_sessions', 'strength_volume'],
    oneOffs: ['first_activity', 'first_strength_session'],
  ),
  ActivityType.hiit: (
    tiered: ['sessions_logged', 'hiit_sessions'],
    oneOffs: [
      'first_activity',
      'first_hiit_session',
      'twenty_interval_rounds',
    ],
  ),
  ActivityType.yoga: (
    tiered: ['sessions_logged', 'yoga_sessions', 'mindful_minutes'],
    oneOffs: ['first_activity', 'first_mindful_session', 'hour_of_yoga'],
  ),
  ActivityType.pilates: (
    tiered: ['sessions_logged', 'pilates_sessions', 'mindful_minutes'],
    oneOffs: ['first_activity', 'first_mindful_session', 'hour_of_pilates'],
  ),
  ActivityType.swim: (
    tiered: ['sessions_logged', 'swim_distance'],
    oneOffs: ['first_activity', 'first_swim', 'long_swim'],
  ),
  // The catch-all, and the one type with no ladder of its own — by
  // definition, since "other" is whatever the app has no model for. It is
  // covered by the shared badges, which is the honest amount of coverage
  // available for a session the app knows nothing about.
  ActivityType.other: (
    tiered: ['sessions_logged'],
    oneOffs: ['first_activity', 'palindrome_distance'],
  ),
};

/// The badges that are shared rather than specific to one type, so the
/// "a ladder of her own" test can say what it means.
const Set<String> _sharedTieredBadgeIds = {'sessions_logged'};

/// One entirely ordinary session of [type], built to reach the marks
/// claimed for that type and nothing more exotic.
///
/// 12,321 metres is a palindrome distance; 600 metres of climbing clears
/// the climb one-off; the mid-morning hour keeps every session out of the
/// early-bird and night-owl windows so nothing fires by accident.
List<Activity> _sessionFor(ActivityType type) {
  final startedAt = DateTime(2026, 5, 4, 10);
  return switch (type) {
    ActivityType.run => [
      activityFixture(
        type: type,
        startedAt: startedAt,
        distanceMeters: 12321,
        elevationGainMeters: 600,
      ),
    ],
    ActivityType.walk => [
      activityFixture(
        type: type,
        startedAt: startedAt,
        distanceMeters: 12321,
        elevationGainMeters: 600,
      ),
    ],
    ActivityType.hike => [
      activityFixture(
        type: type,
        startedAt: startedAt,
        distanceMeters: 16000,
        elevationGainMeters: 900,
      ),
    ],
    ActivityType.ride => [
      activityFixture(
        type: type,
        startedAt: startedAt,
        distanceMeters: 30000,
        elevationGainMeters: 700,
      ),
    ],
    ActivityType.strength => [
      strengthFixture(startedAt: startedAt, completedKg: 400),
    ],
    ActivityType.hiit => [hiitFixture(startedAt: startedAt, totalRounds: 20)],
    ActivityType.yoga || ActivityType.pilates => [
      activityFixture(
        type: type,
        startedAt: startedAt,
        movingTime: const Duration(minutes: 60),
      ),
    ],
    ActivityType.swim => [
      swimFixture(startedAt: startedAt, laps: 40, distanceMeters: 1000),
    ],
    ActivityType.other => [
      activityFixture(type: type, startedAt: startedAt, distanceMeters: 12321),
    ],
  };
}

void main() {
  setUp(resetFixtureIds);

  group('the coverage claim', () {
    test('names every activity type, so a new one fails here first', () {
      expect(
        _claimedCoverage.keys.toSet(),
        ActivityType.values.toSet(),
        reason:
            'a new ActivityType needs badges of its own (catalogue rule 7) '
            'before it can be added to this map',
      );
    });

    test('names badges that exist, of the kind it claims', () {
      for (final entry in _claimedCoverage.entries) {
        for (final id in entry.value.tiered) {
          final badge = badgeDefinitionFor(id);
          expect(badge, isNotNull, reason: '${entry.key.name} claims $id');
          expect(badge!.kind, BadgeKind.tiered, reason: id);
        }
        for (final id in entry.value.oneOffs) {
          final badge = badgeDefinitionFor(id);
          expect(badge, isNotNull, reason: '${entry.key.name} claims $id');
          expect(badge!.kind, BadgeKind.oneOff, reason: id);
        }
      }
    });

    test('gives every type a ladder and at least two one-offs', () {
      for (final entry in _claimedCoverage.entries) {
        expect(
          entry.value.tiered,
          hasLength(greaterThanOrEqualTo(1)),
          reason: '${entry.key.name} has nothing to progress at',
        );
        expect(
          entry.value.oneOffs.toSet(),
          hasLength(greaterThanOrEqualTo(2)),
          reason: '${entry.key.name} has fewer than two one-offs',
        );
      }
    });

    test('gives every modelled type a ladder of its own, not just the '
        'shared session counter', () {
      for (final entry in _claimedCoverage.entries) {
        if (entry.key == ActivityType.other) continue;
        expect(
          entry.value.tiered.toSet().difference(_sharedTieredBadgeIds),
          isNotEmpty,
          reason:
              '${entry.key.name} would progress only on the badge everybody '
              'progresses on, which is not coverage',
        );
      }
    });
  });

  test('one ordinary session of each type really earns what is claimed', () {
    for (final entry in _claimedCoverage.entries) {
      resetFixtureIds();
      final progress = <String, BadgeProgress>{
        for (final badge in evaluateBadges(
          inputs: BadgeInputs(
            today: LocalDate(2026, 9, 1),
            activities: _sessionFor(entry.key),
          ),
        ))
          badge.definition.id: badge,
      };

      for (final id in entry.value.tiered) {
        expect(
          progress[id]!.value,
          greaterThan(0),
          reason:
              '${entry.key.name}: $id did not move for a session of this '
              'type, so the ladder is not really hers',
        );
      }
      for (final id in entry.value.oneOffs) {
        expect(
          progress[id]!.isEarned,
          isTrue,
          reason:
              '${entry.key.name}: $id did not fire for a session of this '
              'type',
        );
      }
    }
  });
}
