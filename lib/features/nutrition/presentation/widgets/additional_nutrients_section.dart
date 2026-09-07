import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_form_field.dart';

/// The collapsible "Additional nutrients" half of the food form: the fats
/// breakdown, the carbohydrate breakdown, and the minerals and vitamins.
///
/// Split out of `food_form_screen.dart` because it is two thirds of that
/// file's length and none of its logic.
class AdditionalNutrientsSection extends ConsumerWidget {
  const AdditionalNutrientsSection({required this.seed, super.key});

  final FoodFormSeed? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(foodFormControllerProvider(seed));
    final controller = ref.read(foodFormControllerProvider(seed).notifier);
    final validation = state.validation;

    bool check(String field) => state.lowConfidenceFields.contains(field);

    return KeyedSubtree(
      // Re-keyed on whether a label has been scanned, so the tile is built
      // afresh — and therefore honours `initiallyExpanded` again — the one
      // time its contents change without the user touching it. A scan that
      // fills eight optional nutrients behind a collapsed header is a scan
      // whose result they cannot check, which is the whole review step.
      key: ValueKey('additionalNutrients-${state.labelScanApplied}'),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('additionalNutrientsTile'),
          initiallyExpanded: state.hasAnyOptionalNutrient,
          title: const Text('Additional nutrients (optional)'),
          subtitle: const Text(
            'Fats breakdown, fiber, sugars, sodium, vitamins',
          ),
          childrenPadding: EdgeInsets.zero,
          children: [
            SizedBox(height: tokens.spacingSm),
            Text(
              'Fats Breakdown',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'saturatedFatField',
              label: 'Saturated fat (g, optional)',
              numeric: true,
              value: state.saturatedFat,
              lowConfidence: check(ScanField.saturatedFat),
              errorText: validation?.saturatedFatError,
              onChanged: controller.updateSaturatedFat,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'transFatField',
              label: 'Trans fat (g, optional)',
              numeric: true,
              value: state.transFat,
              lowConfidence: check(ScanField.transFat),
              errorText: validation?.transFatError,
              onChanged: controller.updateTransFat,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'monounsaturatedFatField',
              label: 'Monounsaturated fat (g, optional)',
              numeric: true,
              value: state.monounsaturatedFat,
              errorText: validation?.monounsaturatedFatError,
              onChanged: controller.updateMonounsaturatedFat,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'polyunsaturatedFatField',
              label: 'Polyunsaturated fat (g, optional)',
              numeric: true,
              value: state.polyunsaturatedFat,
              errorText: validation?.polyunsaturatedFatError,
              onChanged: controller.updatePolyunsaturatedFat,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              'Carbohydrates Breakdown',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'fiberField',
              label: 'Dietary fiber (g, optional)',
              numeric: true,
              value: state.fiber,
              lowConfidence: check(ScanField.fiber),
              errorText: validation?.fiberError,
              onChanged: controller.updateFiber,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'sugarsField',
              label: 'Total sugars (g, optional)',
              numeric: true,
              value: state.sugars,
              lowConfidence: check(ScanField.sugars),
              errorText: validation?.sugarsError,
              onChanged: controller.updateSugars,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'addedSugarsField',
              label: 'Added sugars (g, optional)',
              numeric: true,
              value: state.addedSugars,
              lowConfidence: check(ScanField.addedSugars),
              errorText: validation?.addedSugarsError,
              onChanged: controller.updateAddedSugars,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              'Minerals & Vitamins',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'sodiumField',
              label: 'Sodium (mg, optional)',
              numeric: true,
              value: state.sodium,
              lowConfidence: check(ScanField.sodium),
              errorText: validation?.sodiumError,
              onChanged: controller.updateSodium,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'potassiumField',
              label: 'Potassium (mg, optional)',
              numeric: true,
              value: state.potassium,
              lowConfidence: check(ScanField.potassium),
              errorText: validation?.potassiumError,
              onChanged: controller.updatePotassium,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'cholesterolField',
              label: 'Cholesterol (mg, optional)',
              numeric: true,
              value: state.cholesterol,
              lowConfidence: check(ScanField.cholesterol),
              errorText: validation?.cholesterolError,
              onChanged: controller.updateCholesterol,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'ironField',
              label: 'Iron (mg, optional)',
              numeric: true,
              value: state.iron,
              lowConfidence: check(ScanField.iron),
              errorText: validation?.ironError,
              onChanged: controller.updateIron,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'calciumField',
              label: 'Calcium (mg, optional)',
              numeric: true,
              value: state.calcium,
              lowConfidence: check(ScanField.calcium),
              errorText: validation?.calciumError,
              onChanged: controller.updateCalcium,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'vitaminDField',
              label: 'Vitamin D (mcg, optional)',
              numeric: true,
              value: state.vitaminD,
              lowConfidence: check(ScanField.vitaminD),
              errorText: validation?.vitaminDError,
              onChanged: controller.updateVitaminD,
            ),
            SizedBox(height: tokens.spacingSm),
            FoodFormTextField(
              fieldKey: 'vitaminCField',
              label: 'Vitamin C (mg, optional)',
              numeric: true,
              value: state.vitaminC,
              lowConfidence: check(ScanField.vitaminC),
              errorText: validation?.vitaminCError,
              onChanged: controller.updateVitaminC,
            ),
            SizedBox(height: tokens.spacingSm),
          ],
        ),
      ),
    );
  }
}
