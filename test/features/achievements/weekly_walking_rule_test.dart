import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/achievements/domain/weekly_walking_rule.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

import 'achievement_fixtures.dart';

/// The cycle-aware fairness rule, which is the one piece of this feature a
/// wrong answer would actually hurt someone with: a period week that voided
/// a consistency week would be the app punishing a rest it exists to
/// protect.
///
/// Anchor dates throughout: **today is Tue 2026-09-01**, so
/// * the current (unjudged) week is Mon 2026-08-31 .. Sun 2026-09-06,
/// * the last completed week is Mon 2026-08-24 .. Sun 2026-08-30,
/// * and the week before it is Mon 2026-08-17 .. Sun 2026-08-23.
void main() {
  final today = LocalDate(2026, 9, 1);
  final weekStart = LocalDate(2026, 8, 17);

  setUp(resetFixtureIds);

  int countWith({
    List<Activity> activities = const [],
    Set<LocalDate> protectedDays = const {},
  }) {
    return countWeeklyWalkingTargetWeeks(
      activities: activities,
      protectedDays: protectedDays,
      today: today,
    );
  }

  group('weeklyWalkingWeekQualifies', () {
    test('the full mark counts, exactly at the boundary', () {
      expect(
        weeklyWalkingWeekQualifies(walkedMetres: 15000, protectedDays: 0),
        isTrue,
      );
      expect(
        weeklyWalkingWeekQualifies(walkedMetres: 14999, protectedDays: 0),
        isFalse,
      );
    });

    test('protected days pro-rate the ask', () {
      // 5 protected days leaves 2 active: 15000 * 2/7 = 4285.714...
      expect(
        weeklyWalkingWeekQualifies(walkedMetres: 4285.72, protectedDays: 5),
        isTrue,
      );
      expect(
        weeklyWalkingWeekQualifies(walkedMetres: 4285.71, protectedDays: 5),
        isFalse,
      );
    });

    test('a fully protected week counts with nothing walked at all', () {
      expect(
        weeklyWalkingWeekQualifies(walkedMetres: 0, protectedDays: 7),
        isTrue,
        reason: 'there were no days to walk on, so nothing was fallen short',
      );
    });

    test('walking more never un-qualifies a week', () {
      for (var protected = 0; protected <= 7; protected++) {
        var qualifiedAt = double.infinity;
        for (var metres = 0.0; metres <= 15000; metres += 250) {
          final qualifies = weeklyWalkingWeekQualifies(
            walkedMetres: metres,
            protectedDays: protected,
          );
          if (qualifies) {
            qualifiedAt = metres < qualifiedAt ? metres : qualifiedAt;
          }
          expect(
            qualifies || metres < qualifiedAt,
            isTrue,
            reason:
                'walking ${metres}m with $protected protected days un-did a '
                'week that already counted at ${qualifiedAt}m',
          );
        }
      }
    });

    test('the pro-rated ask falls monotonically as protection rises', () {
      double? previous;
      for (var protected = 0; protected <= 6; protected++) {
        // The smallest distance that still qualifies, found by bisection on
        // the rule itself rather than by re-deriving the formula here.
        var low = 0.0;
        var high = 15000.0;
        for (var i = 0; i < 60; i++) {
          final mid = (low + high) / 2;
          if (weeklyWalkingWeekQualifies(
            walkedMetres: mid,
            protectedDays: protected,
          )) {
            high = mid;
          } else {
            low = mid;
          }
        }
        if (previous != null) expect(high, lessThan(previous));
        previous = high;
      }
    });
  });

  group('countWeeklyWalkingTargetWeeks', () {
    test('no data at all is zero weeks, not an error', () {
      expect(countWith(), 0);
    });

    test('a full week of walking counts once', () {
      expect(
        countWith(
          activities: [
            walkFixture(weekStart, 9000),
            walkFixture(weekStart.addDays(3), 6000),
          ],
        ),
        1,
      );
    });

    test('one metre short does not count', () {
      expect(countWith(activities: [walkFixture(weekStart, 14999)]), 0);
    });

    test('hikes count towards the same mark as walks', () {
      expect(
        countWith(
          activities: [
            walkFixture(weekStart, 7500),
            activityFixture(
              type: ActivityType.hike,
              startedAt: DateTime(2026, 8, 19, 10),
              distanceMeters: 7500,
            ),
          ],
        ),
        1,
      );
    });

    test('runs and rides do not count towards a walking week', () {
      expect(
        countWith(
          activities: [
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 8, 18, 10),
              distanceMeters: 20000,
            ),
            activityFixture(
              type: ActivityType.ride,
              startedAt: DateTime(2026, 8, 19, 10),
              distanceMeters: 40000,
            ),
          ],
        ),
        0,
      );
    });

    test('a five-day period week counts on the pro-rated ask', () {
      // Mon-Fri protected; 4.3 km walked on the Saturday. 15 * 2/7 = 4.29.
      expect(
        countWith(
          activities: [walkFixture(weekStart.addDays(5), 4300)],
          protectedDays: daysBetween(weekStart, weekStart.addDays(4)),
        ),
        1,
        reason: 'a period week must never void a week of this ladder',
      );
    });

    test('the same week with less than the pro-rated ask does not count', () {
      expect(
        countWith(
          activities: [walkFixture(weekStart.addDays(5), 4200)],
          protectedDays: daysBetween(weekStart, weekStart.addDays(4)),
        ),
        0,
      );
    });

    test('a week protected end to end counts with nothing logged', () {
      expect(
        countWith(protectedDays: daysBetween(weekStart, weekStart.addDays(6))),
        1,
      );
    });

    test('the five-day ask is the same wherever in the week she walked', () {
      // 15 km * 2/7 = 4285.7 m, whether the walk lands on a protected day,
      // on a free day, or is split across both. The ask depends only on how
      // many days were hers to use.
      final protectedDays = daysBetween(weekStart, weekStart.addDays(4));
      expect(
        countWith(
          activities: [walkFixture(weekStart, 4300)],
          protectedDays: protectedDays,
        ),
        1,
        reason: 'a walk on a protected day must not raise her own ask',
      );
      expect(
        countWith(
          activities: [walkFixture(weekStart.addDays(5), 4300)],
          protectedDays: protectedDays,
        ),
        1,
      );
      expect(
        countWith(
          activities: [
            walkFixture(weekStart, 2200),
            walkFixture(weekStart.addDays(6), 2200),
          ],
          protectedDays: protectedDays,
        ),
        1,
        reason: 'every metre walked in the week counts towards the ask',
      );
    });

    test('a walk on a protected day can only ever help', () {
      final protectedDays = daysBetween(weekStart, weekStart.addDays(4));
      // Before the correction this was the cliff: the week counted with
      // nothing logged at 7 protected days, and one kilometre on a
      // protected day pushed the ask up to 2,142.9 m.
      final allProtected = daysBetween(weekStart, weekStart.addDays(6));
      expect(countWith(protectedDays: allProtected), 1);
      expect(
        countWith(
          activities: [walkFixture(weekStart, 1000)],
          protectedDays: allProtected,
        ),
        1,
        reason: 'walking 1 km on a flare day must never cost her the week',
      );
      expect(
        countWith(
          activities: [walkFixture(weekStart, 4300)],
          protectedDays: protectedDays,
        ),
        1,
      );
    });

    test('a corrupt distance neither counts nor voids the week', () {
      // NaN would make every `>=` comparison false and silently swallow a
      // week she had actually walked (`badge_metrics.dart#_clean`).
      expect(
        countWith(
          activities: [
            walkFixture(weekStart, double.nan),
            walkFixture(weekStart.addDays(1), 15000),
          ],
        ),
        1,
        reason: 'a NaN row must not poison the week total',
      );
      expect(
        countWith(activities: [walkFixture(weekStart, double.nan)]),
        0,
      );
      expect(
        countWith(
          activities: [
            walkFixture(weekStart, -5000),
            walkFixture(weekStart.addDays(1), 15000),
          ],
        ),
        1,
        reason: 'a negative row must not subtract from what she walked',
      );
    });

    test('the in-progress week is never judged', () {
      expect(
        countWith(
          activities: [walkFixture(LocalDate(2026, 8, 31), 30000)],
        ),
        0,
        reason: 'an unfinished week is not a week she fell short in',
      );
    });

    test('the just-completed week is judged', () {
      expect(
        countWith(activities: [walkFixture(LocalDate(2026, 8, 24), 15000)]),
        1,
      );
    });

    test('weeks need not be consecutive - this is a tally, not a streak', () {
      expect(
        countWith(
          activities: [
            walkFixture(LocalDate(2026, 6, 1), 15000),
            // eleven quiet weeks
            walkFixture(LocalDate(2026, 8, 24), 15000),
          ],
        ),
        2,
      );
    });

    test('protected days outside any walking week still bound the walk', () {
      // Protection alone, in a week with nothing else, is only enough when
      // the whole week is protected.
      expect(
        countWith(protectedDays: {LocalDate(2026, 8, 18)}),
        0,
      );
    });
  });
}
