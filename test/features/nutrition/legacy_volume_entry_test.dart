import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';
import 'package:menfit_app/features/nutrition/presentation/log_entry_controller.dart';

/// Millilitres and fluid ounces are no longer **offered**
/// (`domain/quantity_unit.dart`, `knowledge/domain/nutrition.md`: a
/// millilitre is not a mass). Entries logged in them while they were offered
/// still exist, and none of them changed: no migration ran, no row was
/// rewritten, and no total moved.
///
/// So this file is the other half of that decision — the half that is easy
/// to skip and expensive to get wrong. Withdrawing a unit from the picker
/// must not make an existing entry unreadable, unlabelable or uneditable.
void main() {
  final day = LocalDate(2026, 8, 30);
  final now = DateTime.utc(2026, 8, 30, 8);

  /// An entry as it was written when millilitres were on offer: 200 ml of a
  /// food whose serving weighs 50 g, so four servings.
  NutritionEntry legacyEntry({
    QuantityUnit unit = QuantityUnit.millilitre,
    double amount = 200,
  }) {
    return NutritionEntry(
      id: 'entry-legacy-ml',
      day: day,
      meal: MealType.breakfast,
      foodName: 'Semi-skimmed milk',
      quantityServings: (servingsFor(
        amount: amount,
        unit: unit,
        servingGrams: 50,
      ) as ConvertedQuantity).servings,
      quantityAmount: amount,
      quantityUnit: unit,
      servingGrams: 50,
      perServing: const NutritionFacts(
        caloriesKcal: 25,
        proteinGrams: 1.7,
        carbsGrams: 2.4,
        fatGrams: 0.9,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  test('a stored millilitre entry still reads back in millilitres', () {
    final entry = legacyEntry();

    expect(entry.quantityUnit, QuantityUnit.millilitre);
    expect(entry.quantityLabel, '200 ml');
  });

  test('a stored fluid-ounce entry still reads back in fluid ounces', () {
    final entry = legacyEntry(unit: QuantityUnit.fluidOunce, amount: 8);

    expect(entry.quantityLabel, '8 fl oz');
  });

  test('and still contributes exactly the nutrition it always did', () {
    // 200 ml against a 50 g serving is four servings, whatever the picker
    // does or does not offer today. A changed number here would mean a
    // user's history moved under them.
    final entry = legacyEntry();

    expect(entry.quantityServings, 4);
    expect(entry.facts.caloriesKcal, closeTo(100, 1e-9));
    expect(entry.facts.proteinGrams, closeTo(6.8, 1e-9));
  });

  test('reopening one for editing shows it in the unit it was logged in', () {
    // The regression this guards: `availableUnits` no longer contains
    // millilitre, so without `including` the dropdown would be handed a
    // selected value it has no item for — which asserts, and would make
    // every such entry uneditable.
    final entry = legacyEntry();
    final state = LogEntryFormState(
      day: entry.day,
      meal: entry.meal,
      perServing: entry.perServing,
      displayName: entry.displayName,
      servingGrams: entry.servingGrams,
      amount: entry.quantityAmount,
      unit: entry.quantityUnit,
    );

    expect(state.availableUnits, contains(QuantityUnit.millilitre));
    expect(state.unitLabel(QuantityUnit.millilitre), 'millilitre (ml)');
    // Editing it converts against the snapshot, not against anything new.
    expect(state.servings, 4);
  });

  test('a NEW entry for the same food is offered no volume unit', () {
    // The other side of the same state: nothing above re-opens the door.
    final state = LogEntryFormState(
      day: day,
      meal: MealType.breakfast,
      perServing: const NutritionFacts(
        caloriesKcal: 25,
        proteinGrams: 1.7,
        carbsGrams: 2.4,
        fatGrams: 0.9,
      ),
      displayName: 'Semi-skimmed milk',
      servingGrams: 50,
    );

    expect(state.availableUnits, QuantityUnit.offerable);
    expect(state.availableUnits.where((unit) => unit.isVolume), isEmpty);
  });
}
