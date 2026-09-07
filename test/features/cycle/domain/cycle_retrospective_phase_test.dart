import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Retrospective phase resolution: days inside a **completed** logged cycle
/// (between two consecutive logged period starts) get an estimated phase
/// instead of [CyclePhase.none].
///
/// Before this, `getDayStatus` only anchored on the most recent logged
/// start, so every day of a finished cycle resolved to `none` — which made
/// cycle-end recaps unable to put phase context on a PR ("your 5 km best
/// effort, in your follicular phase") for exactly the cycles that feature
/// exists to describe, and starved the cycle-phase insight evaluator of
/// paired observations.
///
/// Everything asserted here past a logged bleed day is an **estimate**
/// (`knowledge/domain/womens_health.md`) — the tests pin the model, not a
/// physiological claim, and the model is phase labelling for training
/// context, never a fertility or ovulation-timing signal.
void main() {
  final now = DateTime.utc(2026, 6);

  CycleRecord record(
    String id,
    LocalDate start, {
    LocalDate? end,
  }) => CycleRecord(
    id: id,
    periodStart: start,
    periodEnd: end,
    createdAt: now,
    updatedAt: now,
  );

  /// 1 June – 5 June bleed, then the next period starts 29 June: one
  /// completed 28-day cycle, which is also the engine's default predicted
  /// length. Both records carry an end so no record reads as "ongoing"
  /// (an ongoing record is treated as bleeding through to `today`).
  List<CycleRecord> completedCycle() => [
    record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
    record('b', LocalDate(2026, 6, 29), end: LocalDate(2026, 7, 3)),
  ];

  final today = LocalDate(2026, 7, 15);
  final engine = CyclePredictionEngine();

  CyclePhase phaseOn(LocalDate date, List<CycleRecord> records) =>
      engine.getDayStatus(date: date, records: records, today: today).phase;

  group('retrospective phasing of a completed cycle', () {
    test('logged bleed days stay logged facts, not estimates', () {
      final records = completedCycle();

      for (var day = 1; day <= 5; day++) {
        final status = engine.getDayStatus(
          date: LocalDate(2026, 6, day),
          records: records,
          today: today,
        );
        expect(status.isLoggedPeriod, isTrue, reason: 'June $day');
        expect(status.isPredictedPeriod, isFalse, reason: 'June $day');
        expect(status.phase, CyclePhase.menstrual, reason: 'June $day');
        expect(status.cycleDayNumber, day, reason: 'June $day');
        expect(status.associatedRecord?.id, 'a', reason: 'June $day');
      }
    });

    test('no day after the logged period end is estimated as menstrual', () {
      final records = completedCycle();

      for (var day = 6; day <= 28; day++) {
        expect(
          phaseOn(LocalDate(2026, 6, day), records),
          isNot(CyclePhase.menstrual),
          reason: 'June $day is outside the logged bleed days',
        );
      }
    });

    test('phases are anchored backwards from the next logged start', () {
      final records = completedCycle();

      // The pivot sits `nominalLutealLength` days before the next logged
      // start (29 June - 14 = 15 June), so the post-pivot stretch — the
      // physiologically stable end of the cycle — is 15–28 June. The
      // engine's existing convention widens the pivot into a 3-day
      // ovulatory band (pivot -1 to pivot +1) and calls everything after
      // it luteal, so that stretch reads 14–16 June ovulatory, 17–28 June
      // luteal.
      for (var day = 6; day <= 13; day++) {
        expect(
          phaseOn(LocalDate(2026, 6, day), records),
          CyclePhase.follicular,
          reason: 'June $day',
        );
      }
      for (var day = 14; day <= 16; day++) {
        expect(
          phaseOn(LocalDate(2026, 6, day), records),
          CyclePhase.ovulatory,
          reason: 'June $day',
        );
      }
      for (var day = 17; day <= 28; day++) {
        expect(
          phaseOn(LocalDate(2026, 6, day), records),
          CyclePhase.luteal,
          reason: 'June $day',
        );
      }
    });

    test('the estimated ovulation day is 14 days before the next start', () {
      final records = completedCycle();

      final flagged = [
        for (var day = 6; day <= 28; day++)
          if (engine
              .getDayStatus(
                date: LocalDate(2026, 6, day),
                records: records,
                today: today,
              )
              .isOvulationDay)
            day,
      ];

      expect(flagged, [15]);
      expect(LocalDate(2026, 6, 15).addDays(14), LocalDate(2026, 6, 29));
    });

    test('cycle day numbers count from the completed cycle start', () {
      final records = completedCycle();

      for (var day = 6; day <= 28; day++) {
        final status = engine.getDayStatus(
          date: LocalDate(2026, 6, day),
          records: records,
          today: today,
        );
        expect(status.cycleDayNumber, day, reason: 'June $day');
        expect(status.isLoggedPeriod, isFalse, reason: 'June $day');
        // A retrospective phase is an estimate about a past day, never a
        // claim that a period was predicted there.
        expect(status.isPredictedPeriod, isFalse, reason: 'June $day');
      }
    });

    test('a longer completed cycle stretches the follicular phase, not the '
        'luteal one', () {
      // 1 June -> 6 July is a 35-day cycle. The pivot still lands 14 days
      // before the next start (22 June), so the extra week is absorbed
      // before ovulation.
      final records = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 7, 6), end: LocalDate(2026, 7, 10)),
      ];

      expect(phaseOn(LocalDate(2026, 6, 20), records), CyclePhase.follicular);
      expect(phaseOn(LocalDate(2026, 6, 22), records), CyclePhase.ovulatory);
      expect(phaseOn(LocalDate(2026, 6, 24), records), CyclePhase.luteal);
      expect(phaseOn(LocalDate(2026, 7, 5), records), CyclePhase.luteal);
    });
  });

  group('the retrospective and forward models agree', () {
    test('a completed cycle whose length equals the predicted length phases '
        'identically to the current cycle', () {
      // Same first record either way. With only that record the engine
      // falls back to its 28-day default and phases forward from it; with
      // the 29 June start added, the cycle is completed at exactly 28 days
      // and is phased retrospectively. The two must not disagree, or a
      // recap would tell a different story about a day than the calendar
      // did while that day was the present.
      final forwardOnly = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
      ];
      final completed = completedCycle();

      expect(
        engine.analyze(records: completed, today: today).medianCycleLength,
        28,
        reason: 'the completed cycle must match the predicted length',
      );

      for (var day = 6; day <= 28; day++) {
        final date = LocalDate(2026, 6, day);
        final forward = engine.getDayStatus(
          date: date,
          records: forwardOnly,
          today: today,
        );
        final retro = engine.getDayStatus(
          date: date,
          records: completed,
          today: today,
        );

        expect(retro.phase, forward.phase, reason: 'June $day phase');
        expect(
          retro.cycleDayNumber,
          forward.cycleDayNumber,
          reason: 'June $day cycle day',
        );
        expect(
          retro.isOvulationDay,
          forward.isOvulationDay,
          reason: 'June $day ovulation flag',
        );
        expect(retro.isLoggedPeriod, forward.isLoggedPeriod);
        expect(retro.isPredictedPeriod, forward.isPredictedPeriod);
      }
    });
  });

  group('implausible gaps are not phased', () {
    test('a gap shorter than the minimum cycle length yields phases only for '
        'logged period days', () {
      // 1 June and 11 June starts: 10 days apart, below
      // `minPlausibleCycleLength`. A corrected or duplicated log, not a
      // cycle — so nothing between the two is estimated.
      final records = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 6, 11), end: LocalDate(2026, 6, 15)),
      ];

      expect(phaseOn(LocalDate(2026, 6, 3), records), CyclePhase.menstrual);
      expect(phaseOn(LocalDate(2026, 6, 13), records), CyclePhase.menstrual);
      for (var day = 6; day <= 10; day++) {
        expect(
          phaseOn(LocalDate(2026, 6, day), records),
          CyclePhase.none,
          reason: 'June $day sits in a sub-cycle gap',
        );
      }
    });

    test('a gap longer than the maximum cycle length yields phases only for '
        'logged period days', () {
      // 1 June 2026 to 1 January 2027 is 214 days: the user stopped
      // logging, so the months in between are unknown, not luteal.
      final records = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2027, 1, 1), end: LocalDate(2027, 1, 5)),
      ];
      final laterToday = LocalDate(2027, 2, 1);

      CyclePhase phase(LocalDate date) => engine
          .getDayStatus(date: date, records: records, today: laterToday)
          .phase;

      expect(phase(LocalDate(2026, 6, 3)), CyclePhase.menstrual);
      expect(phase(LocalDate(2027, 1, 3)), CyclePhase.menstrual);
      expect(phase(LocalDate(2026, 6, 20)), CyclePhase.none);
      expect(phase(LocalDate(2026, 8, 1)), CyclePhase.none);
      expect(phase(LocalDate(2026, 12, 20)), CyclePhase.none);
    });

    test('the boundary lengths themselves are inclusive', () {
      // 15 days is the shortest interval the engine treats as a cycle, and
      // 90 the longest; both edges phase, one day outside either does not.
      final shortest = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 6, 16), end: LocalDate(2026, 6, 20)),
      ];
      final tooShort = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 6, 15), end: LocalDate(2026, 6, 19)),
      ];
      final longest = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 8, 30), end: LocalDate(2026, 9, 3)),
      ];
      final tooLong = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 8, 31), end: LocalDate(2026, 9, 4)),
      ];

      expect(LocalDate(2026, 6, 1).difference(LocalDate(2026, 6, 16)), 15);
      expect(LocalDate(2026, 6, 1).difference(LocalDate(2026, 8, 30)), 90);

      expect(phaseOn(LocalDate(2026, 6, 10), shortest), isNot(CyclePhase.none));
      expect(phaseOn(LocalDate(2026, 6, 10), tooShort), CyclePhase.none);
      expect(phaseOn(LocalDate(2026, 6, 10), longest), isNot(CyclePhase.none));
      expect(phaseOn(LocalDate(2026, 6, 10), tooLong), CyclePhase.none);
    });
  });

  group('days outside any completed cycle', () {
    test('days before the first logged period start stay unknown', () {
      final records = completedCycle();

      for (final date in [
        LocalDate(2026, 5, 31),
        LocalDate(2026, 5, 20),
        LocalDate(2026, 4, 1),
        LocalDate(2025, 12, 25),
      ]) {
        final status = engine.getDayStatus(
          date: date,
          records: records,
          today: today,
        );
        expect(status.phase, CyclePhase.none, reason: date.toIso());
        expect(status.cycleDayNumber, isNull, reason: date.toIso());
        expect(status.isOvulationDay, isFalse, reason: date.toIso());
      }
    });

    test('an empty record list still yields no phase anywhere', () {
      final status = engine.getDayStatus(
        date: LocalDate(2026, 6, 12),
        records: const [],
        today: today,
      );
      expect(status.phase, CyclePhase.none);
    });
  });

  group('current-cycle behaviour is unchanged', () {
    // Regression pin: adding a completed cycle before the current one must
    // not shift a single day of the cycle the user is actually in.
    test('an ongoing period still reads as a logged period day', () {
      final records = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 6, 29)),
      ];
      final duringPeriod = LocalDate(2026, 7, 1);

      final status = engine.getDayStatus(
        date: duringPeriod,
        records: records,
        today: duringPeriod,
      );
      expect(status.isLoggedPeriod, isTrue);
      expect(status.phase, CyclePhase.menstrual);
      expect(status.cycleDayNumber, 3);
      expect(status.associatedRecord?.id, 'b');
    });

    test('days in the current cycle phase from the most recent start, with '
        'or without an earlier completed cycle', () {
      final withHistory = completedCycle();
      final withoutHistory = [
        record('b', LocalDate(2026, 6, 29), end: LocalDate(2026, 7, 3)),
      ];

      // 4 July to 26 July: after the most recent logged period, before the
      // next predicted one.
      for (var day = 4; day <= 26; day++) {
        final date = LocalDate(2026, 7, day);
        final withStatus = engine.getDayStatus(
          date: date,
          records: withHistory,
          today: today,
        );
        final withoutStatus = engine.getDayStatus(
          date: date,
          records: withoutHistory,
          today: today,
        );

        expect(withStatus.phase, withoutStatus.phase, reason: 'July $day');
        expect(
          withStatus.cycleDayNumber,
          withoutStatus.cycleDayNumber,
          reason: 'July $day',
        );
        expect(
          withStatus.isOvulationDay,
          withoutStatus.isOvulationDay,
          reason: 'July $day',
        );
      }
    });

    test('the next predicted period is still reported as predicted', () {
      final records = completedCycle();

      final status = engine.getDayStatus(
        date: LocalDate(2026, 7, 27),
        records: records,
        today: today,
      );
      expect(status.isPredictedPeriod, isTrue);
      expect(status.isLoggedPeriod, isFalse);
      expect(status.phase, CyclePhase.menstrual);
    });
  });

  group('recap-shaped case (review finding C1 repro)', () {
    // The exact fixture from `test/features/recaps/recap_phase_map_test.dart`:
    // a completed June cycle with the next period still ongoing. Both the
    // recap and insight providers skip `CyclePhase.none`, so a non-none
    // phase here is all they need to start carrying phase context —
    // neither provider changes.
    final recapRecords = [
      record('cycle-a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
      record('cycle-b', LocalDate(2026, 6, 29)),
    ];

    test('a mid-cycle day in a completed cycle carries a phase', () {
      final status = engine.getDayStatus(
        date: LocalDate(2026, 6, 12),
        records: recapRecords,
        today: today,
      );

      expect(status.phase, isNot(CyclePhase.none));
      expect(status.phase, CyclePhase.follicular);
      expect(status.cycleDayNumber, 12);
    });

    test('a late-cycle PR day in a completed cycle carries a phase', () {
      final status = engine.getDayStatus(
        date: LocalDate(2026, 6, 20),
        records: recapRecords,
        today: today,
      );

      expect(status.phase, isNot(CyclePhase.none));
      expect(status.phase, CyclePhase.luteal);
    });

    test('every day of the completed cycle now carries a phase', () {
      // The insight evaluator needs paired observations across phases; a
      // completed cycle previously contributed only its 5 logged bleed
      // days.
      final phases = <CyclePhase>{};
      for (var day = 1; day <= 28; day++) {
        final phase = engine
            .getDayStatus(
              date: LocalDate(2026, 6, day),
              records: recapRecords,
              today: today,
            )
            .phase;
        expect(phase, isNot(CyclePhase.none), reason: 'June $day');
        phases.add(phase);
      }
      expect(phases, {
        CyclePhase.menstrual,
        CyclePhase.follicular,
        CyclePhase.ovulatory,
        CyclePhase.luteal,
      });
    });
  });
}
