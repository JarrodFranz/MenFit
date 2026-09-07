import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/nutrition/domain/micronutrient_adequacy.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

void main() {
  group('evaluateMicronutrientAdequacy', () {
    test('evaluates empty totals with not listed and zero progress', () {
      final items = evaluateMicronutrientAdequacy(
        totals: NutritionTotals.empty,
      );

      expect(items, hasLength(5));

      final iron = items.firstWhere((i) => i.type == MicronutrientType.iron);
      expect(iron.loggedAmount, isNull);
      expect(iron.dailyReference, 18);
      expect(iron.progress, 0.0);
      expect(iron.isPartial, isFalse);
      expect(iron.formattedLogged, 'Not listed');
      expect(iron.formattedReference, '18 mg');
      expect(iron.hasLoggedValue, isFalse);

      final calcium = items.firstWhere(
        (i) => i.type == MicronutrientType.calcium,
      );
      expect(calcium.dailyReference, 1000);
      expect(calcium.formattedReference, '1000 mg');

      final vitaminD = items.firstWhere(
        (i) => i.type == MicronutrientType.vitaminD,
      );
      expect(vitaminD.dailyReference, 15);
      expect(vitaminD.formattedReference, '15 mcg');
    });

    test('evaluates logged nutrients and computes progress clamped at 1.0', () {
      const totals = NutritionTotals(
        entryCount: 2,
        facts: NutritionFacts(
          ironMg: 9,
          calciumMg: 1200, // exceeds 1000
          vitaminDMcg: 15,
          fiberGrams: 20,
          vitaminCMg: 75,
        ),
        ironIsPartial: true,
      );

      final items = evaluateMicronutrientAdequacy(totals: totals);

      final iron = items.firstWhere((i) => i.type == MicronutrientType.iron);
      expect(iron.loggedAmount, 9);
      expect(iron.progress, closeTo(0.5, 0.001));
      expect(iron.isPartial, isTrue);
      expect(iron.formattedLogged, '9.0 mg');

      final calcium = items.firstWhere(
        (i) => i.type == MicronutrientType.calcium,
      );
      expect(calcium.loggedAmount, 1200);
      expect(calcium.progress, 1.0); // clamped at 1.0
      expect(calcium.isPartial, isFalse);
      expect(calcium.formattedLogged, '1200 mg');
    });

    test('highlights elevated needs during Menstrual phase for Iron', () {
      const totals = NutritionTotals(
        entryCount: 1,
        facts: NutritionFacts(ironMg: 12),
      );

      final menstrualItems = evaluateMicronutrientAdequacy(
        totals: totals,
        cyclePhase: CyclePhase.menstrual,
      );
      final follicularItems = evaluateMicronutrientAdequacy(
        totals: totals,
        cyclePhase: CyclePhase.follicular,
      );

      final mIron = menstrualItems.firstWhere(
        (i) => i.type == MicronutrientType.iron,
      );
      final fIron = follicularItems.firstWhere(
        (i) => i.type == MicronutrientType.iron,
      );

      expect(mIron.statusMessage, contains('Menstrual phase'));
      expect(fIron.statusMessage, contains('18 mg for premenopausal women'));
    });
  });
}
