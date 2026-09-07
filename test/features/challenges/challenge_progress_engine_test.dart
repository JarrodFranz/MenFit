import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress_engine.dart';

import 'challenge_fixtures.dart';

void main() {
  group('raw value', () {
    test('distance sums only the chosen types inside the window', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: [
          activityOn(LocalDate(2026, 9, 1), distanceMeters: 5000),
          activityOn(LocalDate(2026, 9, 30), distanceMeters: 4000),
          // Wrong type.
          activityOn(
            LocalDate(2026, 9, 10),
            type: ActivityType.ride,
            distanceMeters: 40000,
          ),
          // Outside the window on both sides.
          activityOn(LocalDate(2026, 8, 31), distanceMeters: 9000),
          activityOn(LocalDate(2026, 10, 1), distanceMeters: 9000),
        ],
        protectedDays: const {},
      );

      expect(progress.rawValue, 9000);
    });

    test('the window boundaries are inclusive at both ends', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: [
          activityOn(LocalDate(2026, 9, 1), distanceMeters: 1000, hour: 0),
          activityOn(LocalDate(2026, 9, 30), distanceMeters: 1000, hour: 23),
        ],
        protectedDays: const {},
      );

      expect(progress.rawValue, 2000);
    });

    test('an empty type set counts every type', () {
      final progress = computeSelfProgress(
        challenge: sessionBlueprint(activityTypes: const {}),
        activities: [
          activityOn(LocalDate(2026, 9, 1)),
          activityOn(LocalDate(2026, 9, 2), type: ActivityType.yoga),
          activityOn(LocalDate(2026, 9, 3), type: ActivityType.swim),
        ],
        protectedDays: const {},
      );

      expect(progress.rawValue, 3);
    });

    test('session count counts sessions, not distance', () {
      final progress = computeSelfProgress(
        challenge: sessionBlueprint(),
        activities: [
          activityOn(
            LocalDate(2026, 9, 1),
            type: ActivityType.strength,
            distanceMeters: 0,
          ),
          activityOn(
            LocalDate(2026, 9, 1),
            type: ActivityType.strength,
            distanceMeters: 0,
            hour: 18,
          ),
        ],
        protectedDays: const {},
      );

      expect(
        progress.rawValue,
        2,
        reason: 'two sessions on one day are two sessions',
      );
    });

    test('a corrupt distance cannot poison the total', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: [
          activityOn(LocalDate(2026, 9, 1), distanceMeters: 5000),
          activityOn(LocalDate(2026, 9, 2), distanceMeters: double.nan),
          activityOn(LocalDate(2026, 9, 3), distanceMeters: -1000),
        ],
        protectedDays: const {},
      );

      expect(progress.rawValue, 5000);
    });

    test('an empty log inside a real window is zero, not an error', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: const [],
        protectedDays: const {},
      );

      expect(progress.rawValue, 0);
      expect(progress.percent, 0);
      expect(progress.reachedGoal, isFalse);
    });
  });

  group('pro-ration (hand-computed)', () {
    test('no protected days: the ask is the nominal target', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(), // 100 km across 30 days
        activities: [activityOn(LocalDate(2026, 9, 4), distanceMeters: 25000)],
        protectedDays: const {},
      );

      expect(progress.windowDays, 30);
      expect(progress.nominalTarget, 100000);
      expect(progress.adjustedTarget, 100000);
      expect(progress.percent, 25);
    });

    test('a five-day period week lowers the ask to 25/30 of it', () {
      // 100 km x 25/30 = 83,333.33 m. They ran 25 km, so 30%.
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: [activityOn(LocalDate(2026, 9, 12), distanceMeters: 25000)],
        protectedDays: daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9)),
      );

      expect(progress.protectedDaysInWindow, 5);
      expect(progress.adjustedTarget, closeTo(83333.33, 0.01));
      expect(progress.percent, closeTo(30, 0.001));
    });

    test('a session challenge pro-rates the same way', () {
      // 12 sessions x 24/30 = 9.6. They logged 6, so 62.5%.
      final progress = computeSelfProgress(
        challenge: sessionBlueprint(),
        activities: [
          for (var day = 15; day < 21; day++)
            activityOn(LocalDate(2026, 9, day), type: ActivityType.strength),
        ],
        protectedDays: daysFrom(LocalDate(2026, 9, 1), LocalDate(2026, 9, 6)),
      );

      expect(progress.protectedDaysInWindow, 6);
      expect(progress.adjustedTarget, closeTo(9.6, 1e-9));
      expect(progress.percent, closeTo(62.5, 1e-9));
    });

    test('protected days outside the window are ignored', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: const [],
        protectedDays: {
          ...daysFrom(LocalDate(2026, 8, 20), LocalDate(2026, 8, 31)),
          ...daysFrom(LocalDate(2026, 10, 1), LocalDate(2026, 10, 5)),
        },
      );

      expect(progress.protectedDaysInWindow, 0);
      expect(progress.adjustedTarget, 100000);
    });

    test('a fully protected window asks for nothing, even with nothing '
        'logged', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: const [],
        protectedDays: daysFrom(septemberStart, septemberEnd),
      );

      expect(progress.protectedDaysInWindow, 30);
      expect(progress.adjustedTarget, 0);
      expect(
        progress.percent,
        100,
        reason:
            'there were no days to train on, so there is nothing to fall '
            'short of - the same unconditional rule as the weekly walking '
            'ladder',
      );
      expect(progress.reachedGoal, isTrue);
    });

    test('a one-day window is a valid window', () {
      final oneDay = distanceBlueprint(
        targetUnits: 50, // 5 km
        windowStart: LocalDate(2026, 9, 7),
        windowEnd: LocalDate(2026, 9, 7),
      );

      final done = computeSelfProgress(
        challenge: oneDay,
        activities: [activityOn(LocalDate(2026, 9, 7), distanceMeters: 5000)],
        protectedDays: const {},
      );
      expect(done.windowDays, 1);
      expect(done.percent, 100);

      final protectedDay = computeSelfProgress(
        challenge: oneDay,
        activities: const [],
        protectedDays: {LocalDate(2026, 9, 7)},
      );
      expect(protectedDay.adjustedTarget, 0);
      expect(protectedDay.percent, 100);
    });

    test('progress past the goal is reported, not capped', () {
      final progress = computeSelfProgress(
        challenge: distanceBlueprint(),
        activities: [
          activityOn(LocalDate(2026, 9, 4), distanceMeters: 140000),
        ],
        protectedDays: const {},
      );

      expect(progress.percent, 140);
      expect(progress.reachedGoal, isTrue);
    });
  });

  group('invariants', () {
    // The two rules that make this fair, stated as properties rather than
    // as examples - the same rigour `weekly_walking_rule_test.dart` applies
    // to the ladder this pro-ration is modelled on.

    test('adding an activity can never lower the percentage', () {
      final blueprint = distanceBlueprint();
      final protectedDays = daysFrom(
        LocalDate(2026, 9, 5),
        LocalDate(2026, 9, 9),
      );

      final activities = <Activity>[];
      var previous = computeSelfProgress(
        challenge: blueprint,
        activities: activities,
        protectedDays: protectedDays,
      ).percent;

      for (var day = 1; day <= 30; day++) {
        activities.add(
          activityOn(LocalDate(2026, 9, day), distanceMeters: 4000),
        );
        final current = computeSelfProgress(
          challenge: blueprint,
          activities: activities,
          protectedDays: protectedDays,
        ).percent;
        expect(
          current,
          greaterThanOrEqualTo(previous),
          reason: 'adding day $day lowered their progress',
        );
        previous = current;
      }
    });

    test('training on a protected day helps exactly as much as any other', () {
      // The correction the walking ladder had to make, transplanted: an
      // earlier draft of that rule deducted only protected days they had
      // *not* trained on, which made moving on a flare day strictly worse
      // than resting.
      final blueprint = distanceBlueprint();
      final protectedDays = daysFrom(
        LocalDate(2026, 9, 5),
        LocalDate(2026, 9, 9),
      );

      final rested = computeSelfProgress(
        challenge: blueprint,
        activities: [activityOn(LocalDate(2026, 9, 12), distanceMeters: 10000)],
        protectedDays: protectedDays,
      );
      final trainedThrough = computeSelfProgress(
        challenge: blueprint,
        activities: [
          activityOn(LocalDate(2026, 9, 12), distanceMeters: 10000),
          activityOn(LocalDate(2026, 9, 7), distanceMeters: 3000),
        ],
        protectedDays: protectedDays,
      );

      expect(trainedThrough.adjustedTarget, rested.adjustedTarget);
      expect(trainedThrough.percent, greaterThan(rested.percent));
    });

    test('marking a day protected can never raise the ask', () {
      final blueprint = distanceBlueprint();
      final protectedDays = <LocalDate>{};
      var previous = computeSelfProgress(
        challenge: blueprint,
        activities: const [],
        protectedDays: protectedDays,
      ).adjustedTarget;

      for (var day = 1; day <= 30; day++) {
        protectedDays.add(LocalDate(2026, 9, day));
        final current = computeSelfProgress(
          challenge: blueprint,
          activities: const [],
          protectedDays: protectedDays,
        ).adjustedTarget;
        expect(
          current,
          lessThanOrEqualTo(previous),
          reason: 'protecting day $day raised their target',
        );
        previous = current;
      }
      expect(previous, 0);
    });

    test('the adjusted target never exceeds the nominal one', () {
      for (var protectedCount = 0; protectedCount <= 30; protectedCount++) {
        final progress = computeSelfProgress(
          challenge: distanceBlueprint(),
          activities: const [],
          protectedDays: {
            for (var day = 1; day <= protectedCount; day++)
              LocalDate(2026, 9, day),
          },
        );
        expect(
          progress.adjustedTarget,
          lessThanOrEqualTo(progress.nominalTarget),
        );
      }
    });

    test('the nominal target is identical on both devices', () {
      // Both participants hold the same blueprint, so the shared ask is
      // the same number for both - only each person's private adjustment
      // differs, and it never crosses the gap.
      final blueprint = distanceBlueprint();

      final mine = computeSelfProgress(
        challenge: blueprint,
        activities: const [],
        protectedDays: daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9)),
      );
      final theirs = computeSelfProgress(
        challenge: blueprint,
        activities: const [],
        protectedDays: const {},
      );

      expect(mine.nominalTarget, theirs.nominalTarget);
      expect(mine.adjustedTarget, isNot(theirs.adjustedTarget));
    });
  });
}
