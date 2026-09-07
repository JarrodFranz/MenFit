import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// `CyclePredictionEngine.phaseRange` — the one-pass window equivalent of
/// calling `getDayStatus` for every day.
///
/// It exists because the weight chart's cycle overlay needs a phase per day
/// across a plotted span, and doing that a day at a time re-sorted the
/// records and re-ran `analyze` plus `projectFuturePeriods` on every
/// iteration. The point of these tests is that the cheap version answers
/// *identically* — anything else would be a second phase model, which is
/// exactly what this codebase avoids having.
///
/// Everything past a logged bleed day is an **estimate**
/// (`knowledge/domain/womens_health.md`); these tests pin the model, not a
/// physiological claim.
void main() {
  final now = DateTime.utc(2026, 6);
  final today = LocalDate(2026, 7, 15);
  final engine = CyclePredictionEngine();

  CycleRecord record(String id, LocalDate start, {LocalDate? end}) =>
      CycleRecord(
        id: id,
        periodStart: start,
        periodEnd: end,
        createdAt: now,
        updatedAt: now,
      );

  /// 1–5 June bleed, next period 29 June: one completed 28-day cycle.
  List<CycleRecord> completedCycle() => [
    record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
    record('b', LocalDate(2026, 6, 29), end: LocalDate(2026, 7, 3)),
  ];

  /// What a caller looping `getDayStatus` would have built.
  Map<LocalDate, CyclePhase> dayByDay({
    required LocalDate start,
    required LocalDate end,
    required List<CycleRecord> records,
  }) {
    final phases = <LocalDate, CyclePhase>{};
    for (var day = start; !day.isAfter(end); day = day.addDays(1)) {
      final phase = engine
          .getDayStatus(date: day, records: records, today: today)
          .phase;
      if (phase != CyclePhase.none) phases[day] = phase;
    }
    return phases;
  }

  group('agrees with getDayStatus', () {
    test('across a completed cycle', () {
      final records = completedCycle();
      final start = LocalDate(2026, 6, 1);
      final end = LocalDate(2026, 6, 28);

      expect(
        engine.phaseRange(
          start: start,
          end: end,
          records: records,
          today: today,
        ),
        dayByDay(start: start, end: end, records: records),
      );
    });

    test('across a window straddling logged, current and future days', () {
      final records = completedCycle();
      // Reaches from before the first logged start well past today, so the
      // window crosses every resolution branch the engine has.
      final start = LocalDate(2026, 5, 20);
      final end = LocalDate(2026, 8, 20);

      expect(
        engine.phaseRange(
          start: start,
          end: end,
          records: records,
          today: today,
        ),
        dayByDay(start: start, end: end, records: records),
      );
    });

    test('with an ongoing period', () {
      final records = [
        record('a', LocalDate(2026, 6, 1), end: LocalDate(2026, 6, 5)),
        record('b', LocalDate(2026, 7, 13)),
      ];
      final start = LocalDate(2026, 7, 1);
      final end = LocalDate(2026, 7, 20);

      expect(
        engine.phaseRange(
          start: start,
          end: end,
          records: records,
          today: today,
        ),
        dayByDay(start: start, end: end, records: records),
      );
    });
  });

  group('window handling', () {
    test('is inclusive on both ends', () {
      final phases = engine.phaseRange(
        start: LocalDate(2026, 6, 1),
        end: LocalDate(2026, 6, 5),
        records: completedCycle(),
        today: today,
      );

      expect(phases.keys, hasLength(5));
      expect(phases[LocalDate(2026, 6, 1)], CyclePhase.menstrual);
      expect(phases[LocalDate(2026, 6, 5)], CyclePhase.menstrual);
    });

    test('a single-day window returns that one day', () {
      final day = LocalDate(2026, 6, 2);

      expect(
        engine.phaseRange(
          start: day,
          end: day,
          records: completedCycle(),
          today: today,
        ),
        {day: CyclePhase.menstrual},
      );
    });

    test('an inverted window yields nothing rather than throwing', () {
      expect(
        engine.phaseRange(
          start: LocalDate(2026, 6, 10),
          end: LocalDate(2026, 6, 1),
          records: completedCycle(),
          today: today,
        ),
        isEmpty,
      );
    });
  });

  group('unknown days', () {
    test('are absent from the map, never CyclePhase.none', () {
      // Before the earliest logged start nothing is known, so those days
      // must not appear at all — an absent key is how this codebase spells
      // unknown, and a stored `none` would read as a fifth phase.
      final phases = engine.phaseRange(
        start: LocalDate(2026, 5, 1),
        end: LocalDate(2026, 6, 5),
        records: completedCycle(),
        today: today,
      );

      expect(phases.values, isNot(contains(CyclePhase.none)));
      expect(phases.containsKey(LocalDate(2026, 5, 1)), isFalse);
      expect(phases.containsKey(LocalDate(2026, 6, 1)), isTrue);
    });

    test('an empty record list phases nothing at all', () {
      expect(
        engine.phaseRange(
          start: LocalDate(2026, 6, 1),
          end: LocalDate(2026, 6, 30),
          records: const [],
          today: today,
        ),
        // With no records the engine projects sample predictions from
        // today, none of which reach back into June.
        isEmpty,
      );
    });
  });
}
