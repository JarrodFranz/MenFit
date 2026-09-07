import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_inputs.dart';
import 'package:menfit_app/features/achievements/domain/badge_metrics.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

import 'achievement_fixtures.dart';

/// Hand-computed fixtures per category. Every expected number in here was
/// checked against a throwaway `dart run` of the real functions before
/// being written down, not derived from the code by reading it.
void main() {
  final today = LocalDate(2026, 9, 1);

  setUp(resetFixtureIds);

  Map<BadgeMetric, double> metricsFor(BadgeInputs inputs) =>
      computeBadgeMetrics(inputs);

  group('empty history', () {
    test('every metric is zero, and nothing is null', () {
      final metrics = metricsFor(BadgeInputs(today: today));
      expect(metrics.keys.toSet(), BadgeMetric.values.toSet());
      for (final entry in metrics.entries) {
        expect(entry.value, 0, reason: entry.key.name);
      }
    });

    test('no condition is satisfied', () {
      expect(computeBadgeConditions(BadgeInputs(today: today)), isEmpty);
    });
  });

  group('distance metrics', () {
    test('runs and rides are counted separately, other types not at all', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 4, 10),
              distanceMeters: 5000,
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 6, 10),
              distanceMeters: 7500,
            ),
            activityFixture(
              type: ActivityType.ride,
              startedAt: DateTime(2026, 5, 7, 10),
              distanceMeters: 32000,
            ),
            walkFixture(LocalDate(2026, 5, 8), 4000),
          ],
        ),
      );
      expect(metrics[BadgeMetric.lifetimeRunDistanceMetres], 12500);
      expect(metrics[BadgeMetric.lifetimeRideDistanceMetres], 32000);
      expect(metrics[BadgeMetric.lifetimeSessionCount], 4);
    });
  });

  group('strength metrics', () {
    test('only completed sets contribute tonnage', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            strengthFixture(
              startedAt: DateTime(2026, 5, 4, 18),
              completedKg: 400,
              uncompletedKg: 1000,
            ),
            strengthFixture(
              startedAt: DateTime(2026, 5, 6, 18),
              completedKg: 250,
            ),
          ],
        ),
      );
      expect(
        metrics[BadgeMetric.lifetimeStrengthVolumeKg],
        650,
        reason: 'a planned-but-unfinished set is not tonnage she lifted',
      );
      expect(metrics[BadgeMetric.strengthSessionCount], 2);
    });

    test('a strength session with no logged detail still counts as one', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.strength,
              startedAt: DateTime(2026, 5, 4, 18),
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.strengthSessionCount], 1);
      expect(metrics[BadgeMetric.lifetimeStrengthVolumeKg], 0);
    });
  });

  group('mindful minutes', () {
    test(
      'yoga and pilates count, and so does any mindful-detailed session',
      () {
        final metrics = metricsFor(
          BadgeInputs(
            today: today,
            activities: [
              activityFixture(
                type: ActivityType.yoga,
                startedAt: DateTime(2026, 5, 4, 12),
                movingTime: const Duration(minutes: 45),
              ),
              activityFixture(
                type: ActivityType.pilates,
                startedAt: DateTime(2026, 5, 6, 12),
                movingTime: const Duration(minutes: 25),
              ),
              activityFixture(
                type: ActivityType.other,
                startedAt: DateTime(2026, 5, 7, 12),
                movingTime: const Duration(minutes: 20),
                workoutDetails: const MindfulWorkoutDetails(),
              ),
              activityFixture(
                type: ActivityType.run,
                startedAt: DateTime(2026, 5, 8, 12),
                movingTime: const Duration(minutes: 60),
              ),
            ],
          ),
        );
        expect(metrics[BadgeMetric.mindfulMinutes], 90);
      },
    );

    test('part-minutes accumulate rather than truncating per session', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            for (var i = 0; i < 4; i++)
              activityFixture(
                type: ActivityType.yoga,
                startedAt: DateTime(2026, 5, 4 + i, 12),
                movingTime: const Duration(seconds: 30),
              ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.mindfulMinutes], 2);
    });
  });

  group('time-of-day metrics', () {
    test('before 07:00 is early, 20:00 and after is late, noon is neither', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 4, 6, 59),
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 5, 7),
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 6, 12),
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 7, 19, 59),
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 8, 20),
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 9, 23, 30),
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.earlyBirdSessionCount], 1);
      expect(metrics[BadgeMetric.nightOwlSessionCount], 2);
    });
  });

  group('check-ins and water', () {
    test('check-in days are counted once each', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          checkinDays: daysBetween(
            LocalDate(2026, 8, 3),
            LocalDate(2026, 8, 9),
          ),
        ),
      );
      expect(metrics[BadgeMetric.checkinDayCount], 7);
    });

    test('a water day counts at exactly the mark, not below it', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          waterTotalsByDay: {
            LocalDate(2026, 8, 3): badgeWaterTargetMl,
            LocalDate(2026, 8, 4): badgeWaterTargetMl - 1,
            LocalDate(2026, 8, 5): badgeWaterTargetMl + 500,
          },
        ),
      );
      expect(metrics[BadgeMetric.waterTargetDayCount], 2);
    });

    test('an unlogged day is absent, never a zero that could be counted', () {
      final metrics = metricsFor(
        BadgeInputs(today: today),
      );
      expect(metrics[BadgeMetric.waterTargetDayCount], 0);
    });
  });

  group('one-off conditions', () {
    test('firsts fire from a single matching activity', () {
      final conditions = computeBadgeConditions(
        BadgeInputs(
          today: today,
          activities: [
            strengthFixture(
              startedAt: DateTime(2026, 5, 4, 18),
              completedKg: 100,
            ),
            activityFixture(
              type: ActivityType.yoga,
              startedAt: DateTime(2026, 5, 5, 12),
            ),
          ],
        ),
      );
      expect(
        conditions,
        containsAll(<BadgeCondition>[
          BadgeCondition.firstActivityLogged,
          BadgeCondition.firstStrengthSession,
          BadgeCondition.firstMindfulSession,
        ]),
      );
    });

    test('the five-kilometre badge reads the recorded best effort', () {
      expect(
        computeBadgeConditions(
          BadgeInputs(today: today, bestEffortDistancesMetres: <double>{1000}),
        ),
        isNot(contains(BadgeCondition.firstFiveKilometreEffort)),
      );
      expect(
        computeBadgeConditions(
          BadgeInputs(
            today: today,
            bestEffortDistancesMetres: <double>{1000, 5000},
          ),
        ),
        contains(BadgeCondition.firstFiveKilometreEffort),
      );
    });

    test('a full check-in week must be a Monday-to-Sunday one', () {
      // Tue 2026-08-04 .. Mon 2026-08-10: seven consecutive days, but they
      // straddle two calendar weeks, so neither week is complete.
      expect(
        computeBadgeConditions(
          BadgeInputs(
            today: today,
            checkinDays: daysBetween(
              LocalDate(2026, 8, 4),
              LocalDate(2026, 8, 10),
            ),
          ),
        ),
        isNot(contains(BadgeCondition.fullCheckinWeek)),
      );
      // Mon 2026-08-03 .. Sun 2026-08-09.
      expect(
        computeBadgeConditions(
          BadgeInputs(
            today: today,
            checkinDays: daysBetween(
              LocalDate(2026, 8, 3),
              LocalDate(2026, 8, 9),
            ),
          ),
        ),
        contains(BadgeCondition.fullCheckinWeek),
      );
    });

    test('the seasonal turn fires inside the window and not outside it', () {
      Set<BadgeCondition> onDay(int month, int day) => computeBadgeConditions(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, month, day, 10),
            ),
          ],
        ),
      );
      for (final (month, day) in const [(3, 20), (6, 21), (9, 22), (12, 21)]) {
        expect(
          onDay(month, day),
          contains(BadgeCondition.seasonalTurnSession),
          reason: '$month-$day is a turn of the year',
        );
      }
      expect(
        onDay(3, 22),
        isNot(contains(BadgeCondition.seasonalTurnSession)),
      );
      expect(onDay(7, 4), isNot(contains(BadgeCondition.seasonalTurnSession)));
    });

    test('all four seasons needs one session in each quarter', () {
      List<Activity> inMonths(List<int> months) => [
        for (final month in months)
          activityFixture(
            type: ActivityType.run,
            startedAt: DateTime(2026, month, 15, 10),
          ),
      ];
      expect(
        computeBadgeConditions(
          BadgeInputs(today: today, activities: inMonths([1, 4, 7])),
        ),
        isNot(contains(BadgeCondition.everySeasonActive)),
      );
      expect(
        computeBadgeConditions(
          BadgeInputs(today: today, activities: inMonths([1, 4, 7, 10])),
        ),
        contains(BadgeCondition.everySeasonActive),
      );
      // December belongs with January and February, not with November.
      expect(
        computeBadgeConditions(
          BadgeInputs(today: today, activities: inMonths([12, 4, 7, 10])),
        ),
        contains(BadgeCondition.everySeasonActive),
      );
      expect(
        computeBadgeConditions(
          BadgeInputs(today: today, activities: inMonths([12, 1, 2, 4])),
        ),
        isNot(contains(BadgeCondition.everySeasonActive)),
      );
    });

    test('five movement kinds means five distinct types', () {
      List<Activity> ofTypes(List<ActivityType> types) => [
        for (var i = 0; i < types.length; i++)
          activityFixture(
            type: types[i],
            startedAt: DateTime(2026, 5, 4 + i, 10),
          ),
      ];
      expect(
        computeBadgeConditions(
          BadgeInputs(
            today: today,
            activities: ofTypes([
              ActivityType.run,
              ActivityType.run,
              ActivityType.walk,
              ActivityType.ride,
              ActivityType.yoga,
            ]),
          ),
        ),
        isNot(contains(BadgeCondition.fiveMovementKinds)),
      );
      expect(
        computeBadgeConditions(
          BadgeInputs(
            today: today,
            activities: ofTypes([
              ActivityType.run,
              ActivityType.walk,
              ActivityType.ride,
              ActivityType.yoga,
              ActivityType.swim,
            ]),
          ),
        ),
        contains(BadgeCondition.fiveMovementKinds),
      );
    });

    test('a palindrome distance is read in whole metres', () {
      bool palindromeAt(double metres) => computeBadgeConditions(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 4, 10),
              distanceMeters: metres,
            ),
          ],
        ),
      ).contains(BadgeCondition.palindromeDistance);

      expect(palindromeAt(5225), isTrue);
      expect(palindromeAt(5224.6), isTrue, reason: 'rounds to 5225');
      expect(palindromeAt(5226), isFalse);
      expect(palindromeAt(5000), isFalse, reason: 'a trailing zero cannot');
      expect(palindromeAt(707), isTrue);
      expect(palindromeAt(99), isFalse, reason: 'below the minimum distance');
      expect(palindromeAt(0), isFalse);
    });
  });

  group('per-type distance metrics', () {
    test('walks, hikes and rides each accumulate onto their own total', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            walkFixture(LocalDate(2026, 5, 4), 4200),
            walkFixture(LocalDate(2026, 5, 5), 11000),
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 5, 6, 10),
              distanceMeters: 16500,
            ),
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 5, 7, 10),
              distanceMeters: 8000,
            ),
            activityFixture(
              type: ActivityType.ride,
              startedAt: DateTime(2026, 5, 8, 10),
              distanceMeters: 26000,
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 9, 10),
              distanceMeters: 8000,
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.lifetimeWalkDistanceMetres], 15200);
      expect(metrics[BadgeMetric.lifetimeHikeDistanceMetres], 24500);
      expect(metrics[BadgeMetric.lifetimeRideDistanceMetres], 26000);
      expect(
        metrics[BadgeMetric.lifetimeRunDistanceMetres],
        8000,
        reason:
            'the run total must not have collected metres from any '
            'other type',
      );
    });

    test('a swim reads its logged distance, and its laps only when there '
        'is no logged distance to read', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            // Manual entry stores laps × pool length *into* the distance,
            // so counting both would double every hand-logged swim.
            swimFixture(
              startedAt: DateTime(2026, 5, 4, 10),
              laps: 48,
              distanceMeters: 1200,
            ),
            // Laps entered, distance left at zero: 30 × 50 m.
            swimFixture(
              startedAt: DateTime(2026, 5, 5, 10),
              laps: 30,
              poolLengthMeters: 50,
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.lifetimeSwimDistanceMetres], 2700);
    });

    test('a swim with neither a distance nor laps contributes nothing', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.swim,
              startedAt: DateTime(2026, 5, 4, 10),
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.lifetimeSwimDistanceMetres], 0);
      expect(metrics[BadgeMetric.lifetimeSessionCount], 1);
    });
  });

  group('climbing', () {
    test('every way an activity can lack climbing contributes zero, and '
        'none of them breaks the sum', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            // Absent — the normal case, since manual entry has no field.
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 5, 4, 10),
              distanceMeters: 20000,
            ),
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 5, 5, 10),
              distanceMeters: 5000,
              elevationGainMeters: double.nan,
            ),
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 5, 6, 10),
              distanceMeters: 1000,
              elevationGainMeters: double.infinity,
            ),
            walkFixtureWithClimb(LocalDate(2026, 5, 7), -50),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 8, 10),
              elevationGainMeters: 640,
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.lifetimeAscentMetres], 640);
      expect(
        metrics[BadgeMetric.lifetimeHikeDistanceMetres],
        26000,
        reason: 'a session with no climbing still counts its distance',
      );
    });

    test('climbing accumulates across every activity type', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 5, 4, 10),
              elevationGainMeters: 640,
            ),
            activityFixture(
              type: ActivityType.ride,
              startedAt: DateTime(2026, 5, 5, 10),
              elevationGainMeters: 210,
            ),
            walkFixtureWithClimb(LocalDate(2026, 5, 6), 30),
          ],
        ),
      );
      expect(metrics[BadgeMetric.lifetimeAscentMetres], 880);
    });
  });

  group('session-count metrics', () {
    test('an interval session counts by its type or by its details', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            hiitFixture(startedAt: DateTime(2026, 5, 4, 10), totalRounds: 24),
            // Intervals attached to a run are still intervals.
            hiitFixture(
              startedAt: DateTime(2026, 5, 5, 10),
              type: ActivityType.run,
            ),
            // A HIIT-typed session with no detail logged still counts.
            activityFixture(
              type: ActivityType.hiit,
              startedAt: DateTime(2026, 5, 6, 10),
            ),
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 7, 10),
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.hiitSessionCount], 3);
      expect(metrics[BadgeMetric.lifetimeSessionCount], 4);
    });

    test('yoga and pilates count per discipline while still pooling their '
        'minutes, so the two ladders never say the same thing twice', () {
      final metrics = metricsFor(
        BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.yoga,
              startedAt: DateTime(2026, 5, 4, 12),
              movingTime: const Duration(minutes: 75),
            ),
            activityFixture(
              type: ActivityType.yoga,
              startedAt: DateTime(2026, 5, 5, 12),
              movingTime: const Duration(minutes: 40),
            ),
            activityFixture(
              type: ActivityType.pilates,
              startedAt: DateTime(2026, 5, 6, 12),
              movingTime: const Duration(minutes: 45),
            ),
            // Mindful minutes take this one; the per-discipline counts do
            // not, because it is neither yoga nor pilates by type.
            activityFixture(
              type: ActivityType.other,
              startedAt: DateTime(2026, 5, 7, 12),
              movingTime: const Duration(minutes: 20),
              workoutDetails: const MindfulWorkoutDetails(),
            ),
          ],
        ),
      );
      expect(metrics[BadgeMetric.yogaSessionCount], 2);
      expect(metrics[BadgeMetric.pilatesSessionCount], 1);
      expect(metrics[BadgeMetric.mindfulMinutes], 180);
    });
  });

  group('per-type one-off conditions', () {
    Set<BadgeCondition> from(List<Activity> activities) =>
        computeBadgeConditions(
          BadgeInputs(today: today, activities: activities),
        );

    test('one session of a type is enough for the first of that type', () {
      expect(
        from([walkFixture(LocalDate(2026, 5, 4), 0)]),
        contains(BadgeCondition.firstWalkSession),
      );
      expect(
        from([
          activityFixture(
            type: ActivityType.hike,
            startedAt: DateTime(2026, 5, 4, 10),
          ),
        ]),
        contains(BadgeCondition.firstHikeSession),
      );
      expect(
        from([
          activityFixture(
            type: ActivityType.ride,
            startedAt: DateTime(2026, 5, 4, 10),
          ),
        ]),
        contains(BadgeCondition.firstRideSession),
      );
      expect(
        from([
          activityFixture(
            type: ActivityType.swim,
            startedAt: DateTime(2026, 5, 4, 10),
          ),
        ]),
        contains(BadgeCondition.firstSwimSession),
      );
      expect(
        from([
          activityFixture(
            type: ActivityType.hiit,
            startedAt: DateTime(2026, 5, 4, 10),
          ),
        ]),
        contains(BadgeCondition.firstHiitSession),
      );
      // And no type hands out anybody else's first.
      expect(
        from([walkFixture(LocalDate(2026, 5, 4), 20000)]),
        isNot(contains(BadgeCondition.firstHikeSession)),
      );
    });

    test('the single-session distances fire at the mark, not below it', () {
      Set<BadgeCondition> ofType(ActivityType type, double metres) => from([
        activityFixture(
          type: type,
          startedAt: DateTime(2026, 5, 4, 10),
          distanceMeters: metres,
        ),
      ]);

      expect(
        ofType(ActivityType.walk, 10000),
        contains(BadgeCondition.tenKilometreWalk),
      );
      expect(
        ofType(ActivityType.walk, 9999),
        isNot(contains(BadgeCondition.tenKilometreWalk)),
      );
      expect(
        ofType(ActivityType.hike, 15000),
        contains(BadgeCondition.fifteenKilometreHike),
      );
      expect(
        ofType(ActivityType.hike, 14999),
        isNot(contains(BadgeCondition.fifteenKilometreHike)),
      );
      expect(
        ofType(ActivityType.ride, 25000),
        contains(BadgeCondition.twentyFiveKilometreRide),
      );
      expect(
        ofType(ActivityType.ride, 24999),
        isNot(contains(BadgeCondition.twentyFiveKilometreRide)),
      );
      // Two 6 km walks are not one 10 km walk: these are single sessions.
      expect(
        from([
          walkFixture(LocalDate(2026, 5, 4), 6000),
          walkFixture(LocalDate(2026, 5, 5), 6000),
        ]),
        isNot(contains(BadgeCondition.tenKilometreWalk)),
      );
    });

    test('the kilometre swim reads laps when there is no logged distance', () {
      expect(
        from([
          swimFixture(
            startedAt: DateTime(2026, 5, 4, 10),
            laps: 20,
            poolLengthMeters: 50,
          ),
        ]),
        contains(BadgeCondition.oneKilometreSwim),
      );
      expect(
        from([
          swimFixture(startedAt: DateTime(2026, 5, 4, 10), laps: 39),
        ]),
        isNot(contains(BadgeCondition.oneKilometreSwim)),
        reason: '975 m is not a kilometre',
      );
    });

    test('the climb fires at 500 metres in one session, from any type', () {
      expect(
        from([
          activityFixture(
            type: ActivityType.run,
            startedAt: DateTime(2026, 5, 4, 10),
            elevationGainMeters: 500,
          ),
        ]),
        contains(BadgeCondition.fiveHundredMetreClimb),
      );
      expect(
        from([
          activityFixture(
            type: ActivityType.hike,
            startedAt: DateTime(2026, 5, 4, 10),
            elevationGainMeters: 499,
          ),
        ]),
        isNot(contains(BadgeCondition.fiveHundredMetreClimb)),
      );
      // Two 300 m sessions are not one 500 m session, and an activity with
      // no elevation at all simply says nothing.
      expect(
        from([
          activityFixture(
            type: ActivityType.hike,
            startedAt: DateTime(2026, 5, 4, 10),
            elevationGainMeters: 300,
          ),
          activityFixture(
            type: ActivityType.hike,
            startedAt: DateTime(2026, 5, 5, 10),
            elevationGainMeters: 300,
          ),
          activityFixture(
            type: ActivityType.hike,
            startedAt: DateTime(2026, 5, 6, 10),
            distanceMeters: 30000,
          ),
        ]),
        isNot(contains(BadgeCondition.fiveHundredMetreClimb)),
      );
    });

    test('twenty rounds means twenty completed, not twenty planned', () {
      expect(
        from([
          hiitFixture(startedAt: DateTime(2026, 5, 4, 10), totalRounds: 20),
        ]),
        contains(BadgeCondition.twentyIntervalRounds),
      );
      expect(
        from([
          hiitFixture(
            startedAt: DateTime(2026, 5, 4, 10),
            totalRounds: 30,
            completedRounds: 19,
          ),
        ]),
        isNot(contains(BadgeCondition.twentyIntervalRounds)),
        reason: 'thirty planned rounds is not twenty done',
      );
    });

    test('the hour badges belong to the discipline that earned them', () {
      Set<BadgeCondition> ofType(ActivityType type, Duration moving) => from([
        activityFixture(
          type: type,
          startedAt: DateTime(2026, 5, 4, 12),
          movingTime: moving,
        ),
      ]);

      expect(
        ofType(ActivityType.yoga, const Duration(minutes: 60)),
        contains(BadgeCondition.hourLongYogaSession),
      );
      expect(
        ofType(ActivityType.yoga, const Duration(minutes: 59)),
        isNot(contains(BadgeCondition.hourLongYogaSession)),
      );
      expect(
        ofType(ActivityType.pilates, const Duration(minutes: 90)),
        contains(BadgeCondition.hourLongPilatesSession),
      );
      expect(
        ofType(ActivityType.pilates, const Duration(minutes: 90)),
        isNot(contains(BadgeCondition.hourLongYogaSession)),
        reason: 'an hour of pilates is not an hour of yoga',
      );
    });
  });
}
