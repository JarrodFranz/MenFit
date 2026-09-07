import 'package:flutter_test/flutter_test.dart';
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
      expect(iron.dailyReference, 8);
      expect(iron.progress, 0.0);
      expect(iron.isPartial, isFalse);
      expect(iron.formattedLogged, 'Not listed');
      expect(iron.formattedReference, '8 mg');
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

      final fiber = items.firstWhere(
        (i) => i.type == MicronutrientType.fiber,
      );
      expect(fiber.dailyReference, 38);
      expect(fiber.formattedReference, '38 g');

      final vitaminC = items.firstWhere(
        (i) => i.type == MicronutrientType.vitaminC,
      );
      expect(vitaminC.dailyReference, 90);
      expect(vitaminC.formattedReference, '90 mg');
    });

    test('evaluates logged nutrients and computes progress clamped at 1.0', () {
      const totals = NutritionTotals(
        entryCount: 2,
        facts: NutritionFacts(
          ironMg: 4,
          calciumMg: 1200, // exceeds 1000
          vitaminDMcg: 15,
          fiberGrams: 20,
          vitaminCMg: 75,
        ),
        ironIsPartial: true,
      );

      final items = evaluateMicronutrientAdequacy(totals: totals);

      final iron = items.firstWhere((i) => i.type == MicronutrientType.iron);
      expect(iron.loggedAmount, 4);
      expect(iron.progress, closeTo(0.5, 0.001));
      expect(iron.isPartial, isTrue);
      expect(iron.formattedLogged, '4.0 mg');

      final calcium = items.firstWhere(
        (i) => i.type == MicronutrientType.calcium,
      );
      expect(calcium.loggedAmount, 1200);
      expect(calcium.progress, 1.0); // clamped at 1.0
      expect(calcium.isPartial, isFalse);
      expect(calcium.formattedLogged, '1200 mg');
    });
  });
}
