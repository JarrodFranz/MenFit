import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

void main() {
  group('CyclePredictionEngine', () {
    late CyclePredictionEngine engine;

    setUp(() {
      engine = CyclePredictionEngine();
    });

    test('returns baseline summary when no records exist', () {
      final today = LocalDate(2026, 8, 29);
      final summary = engine.analyze(records: [], today: today);

      expect(summary.medianCycleLength, 28);
      expect(summary.medianPeriodDuration, 5);
      expect(summary.confidence, CycleConfidence.low);
      expect(summary.currentPhase, CyclePhase.none);
      expect(summary.totalLoggedCycles, 0);
    });

    test(
      'calculates rolling median cycle length and duration with regular cycles',
      () {
        final now = DateTime.utc(2026, 8, 29);
        final records = [
          CycleRecord(
            id: '1',
            periodStart: LocalDate(2026, 5, 1),
            periodEnd: LocalDate(2026, 5, 5), // 5 days
            createdAt: now,
            updatedAt: now,
          ),
          CycleRecord(
            id: '2',
            periodStart: LocalDate(2026, 5, 29), // 28 days interval
            periodEnd: LocalDate(2026, 6, 2), // 5 days
            createdAt: now,
            updatedAt: now,
          ),
          CycleRecord(
            id: '3',
            periodStart: LocalDate(2026, 6, 26), // 28 days interval
            periodEnd: LocalDate(2026, 6, 30), // 5 days
            createdAt: now,
            updatedAt: now,
          ),
          CycleRecord(
            id: '4',
            periodStart: LocalDate(2026, 7, 24), // 28 days interval
            periodEnd: LocalDate(2026, 7, 28), // 5 days
            createdAt: now,
            updatedAt: now,
          ),
          CycleRecord(
            id: '5',
            periodStart: LocalDate(2026, 8, 21), // 28 days interval
            periodEnd: LocalDate(2026, 8, 25), // 5 days
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final today = LocalDate(2026, 8, 29); // 8 days after Aug 21
        final summary = engine.analyze(records: records, today: today);

        expect(summary.medianCycleLength, 28);
        expect(summary.medianPeriodDuration, 5);
        expect(summary.totalLoggedCycles, 4);
        expect(summary.confidence, CycleConfidence.high);
        expect(summary.currentCycleDay, 9); // Day 9 of cycle
        expect(summary.currentPhase, CyclePhase.follicular);
        expect(summary.nextPeriodStart, LocalDate(2026, 9, 18));
        expect(summary.daysUntilNextPeriod, 20);
      },
    );

    test('accurately identifies menstrual phase during ongoing period', () {
      final now = DateTime.utc(2026, 8, 29);
      final records = [
        CycleRecord(
          id: '1',
          periodStart: LocalDate(2026, 8, 27),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final today = LocalDate(2026, 8, 29);
      final summary = engine.analyze(records: records, today: today);

      expect(summary.isOngoingPeriod, isTrue);
      expect(summary.currentPhase, CyclePhase.menstrual);
      expect(summary.currentCycleDay, 3);
      expect(summary.confidence, CycleConfidence.low);
    });

    test(
      'getDayStatus distinguishes logged period vs predicted period vs phases',
      () {
        final now = DateTime.utc(2026, 8, 29);
        final records = [
          CycleRecord(
            id: '1',
            periodStart: LocalDate(2026, 8, 1),
            periodEnd: LocalDate(2026, 8, 5),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final today = LocalDate(2026, 8, 29);

        // Aug 3: Logged period
        final loggedDay = engine.getDayStatus(
          date: LocalDate(2026, 8, 3),
          records: records,
          today: today,
        );
        expect(loggedDay.isLoggedPeriod, isTrue);
        expect(loggedDay.isPredictedPeriod, isFalse);
        expect(loggedDay.phase, CyclePhase.menstrual);

        // Aug 15: Estimated Ovulation (Aug 1 + 14 days)
        final ovDay = engine.getDayStatus(
          date: LocalDate(2026, 8, 15),
          records: records,
          today: today,
        );
        expect(ovDay.isLoggedPeriod, isFalse);
        expect(ovDay.isOvulationDay, isTrue);
        expect(ovDay.phase, CyclePhase.ovulatory);

        // Aug 29: Next predicted period start (Aug 1 + 28 days)
        final predictedDay = engine.getDayStatus(
          date: LocalDate(2026, 8, 29),
          records: records,
          today: today,
        );
        expect(predictedDay.isLoggedPeriod, isFalse);
        expect(predictedDay.isPredictedPeriod, isTrue);
        expect(predictedDay.phase, CyclePhase.menstrual);
      },
    );

    test('projects future periods up to requested months ahead', () {
      final now = DateTime.utc(2026, 8, 29);
      final records = [
        CycleRecord(
          id: '1',
          periodStart: LocalDate(2026, 8, 1),
          periodEnd: LocalDate(2026, 8, 5),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final today = LocalDate(2026, 8, 29);
      final predictions = engine.projectFuturePeriods(
        records: records,
        today: today,
        monthsAhead: 3,
      );

      expect(predictions.isNotEmpty, isTrue);
      expect(predictions.first.startDate, LocalDate(2026, 8, 29));
      expect(predictions.first.durationDays, 5);
      expect(predictions[1].startDate, LocalDate(2026, 9, 26));
    });
  });
}
