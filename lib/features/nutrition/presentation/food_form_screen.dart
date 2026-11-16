import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/additional_nutrients_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/duplicate_barcode_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_barcode_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_data_attribution.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_form_field.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_label_scan_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/provider_food_notes.dart';

/// `/nutrition/add/food` — describe a food once so it can be logged again,
/// and the review-before-save step for a food from the food database or
/// from a photographed nutrition label.
const String foodNotFoundOnlineCopy =
    "We couldn't find this food online. You can add it from the packet — "
    "it'll be in your foods next time, and we won't need to look it up again.";

class FoodFormScreen extends ConsumerWidget {
  const FoodFormScreen({this.seed, super.key});

  /// Pre-fill from a food-database lookup, or `null` for a blank form.
  final FoodFormSeed? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(foodFormControllerProvider(seed));
    final controller = ref.read(foodFormControllerProvider(seed).notifier);
    final validation = state.validation;
    final currentSeed = seed;

    // Fields read their text from the **state**, not from the seed: a label
    // scan fills blanks after the form is already on screen, and a field
    // wired to the immutable seed would keep showing the blank.
    bool check(String field) => state.lowConfidenceFields.contains(field);

    return Scaffold(
      appBar: AppBar(title: Text(_title(currentSeed))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: ListView(
              padding: EdgeInsets.all(tokens.spacingMd),
              children: [
                if (currentSeed != null) ...[
                  _SeedIntro(seed: currentSeed),
                  SizedBox(height: tokens.spacingMd),
                ],
                FoodFormTextField(
                  fieldKey: 'foodNameField',
                  label: 'Name',
                  value: currentSeed?.name,
                  errorText: validation?.nameError,
                  onChanged: controller.updateName,
                ),
                SizedBox(height: tokens.spacingMd),
                FoodFormTextField(
                  fieldKey: 'foodBrandField',
                  label: 'Brand (optional)',
                  value: currentSeed?.brand,
                  onChanged: controller.updateBrand,
                ),
                SizedBox(height: tokens.spacingLg),
                FoodBarcodeSection(seed: currentSeed),
                SizedBox(height: tokens.spacingLg),
                // Above the numbers it fills, and above the basis it sets.
                FoodLabelScanSection(seed: currentSeed),
                SizedBox(height: tokens.spacingLg),
                Text(
                  'Amount & Nutrition Basis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                SegmentedButton<FoodBasisMode>(
                  key: const Key('basisModeSegmentedButton'),
                  segments: const [
                    ButtonSegment(
                      value: FoodBasisMode.serving,
                      label: Text('Serving'),
                      icon: Icon(Icons.restaurant_outlined),
                    ),
                    ButtonSegment(
                      value: FoodBasisMode.perReference,
                      label: Text('Per Reference (e.g. 100g)'),
                      icon: Icon(Icons.scale_outlined),
                    ),
                  ],
                  selected: {state.basisMode},
                  onSelectionChanged: (selected) {
                    controller.updateBasisMode(selected.first);
                  },
                ),
                SizedBox(height: tokens.spacingMd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: FoodFormTextField(
                        fieldKey: 'basisAmountField',
                        label: 'Amount',
                        value: state.basisAmount,
                        numeric: true,
                        errorText: validation?.servingGramsError,
                        onChanged: controller.updateBasisAmount,
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        key: const Key('basisUnitField'),
                        initialValue: state.basisUnit,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Unit',
                        ),
                        items: [
                          if (state.basisMode == FoodBasisMode.serving)
                            const DropdownMenuItem(
                              value: 'serving',
                              child: Text('serving'),
                            ),
                          const DropdownMenuItem(
                            value: 'g',
                            child: Text('g'),
                          ),
                          const DropdownMenuItem(
                            value: 'ml',
                            child: Text('ml'),
                          ),
                          const DropdownMenuItem(
                            value: 'oz',
                            child: Text('oz'),
                          ),
                          const DropdownMenuItem(
                            value: 'fl oz',
                            child: Text('fl oz'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.updateBasisUnit(val);
                        },
                      ),
                    ),
                  ],
                ),
                if (state.basisMode == FoodBasisMode.serving &&
                    state.basisUnit == 'serving') ...[
                  SizedBox(height: tokens.spacingSm),
                  FoodFormTextField(
                    fieldKey: 'servingDescriptionField',
                    label: 'Portion description (optional)',
                    helperText: "e.g. '1 cup' or '2 slices'",
                    value: state.servingDescription,
                    onChanged: controller.updateServingDescription,
                  ),
                  SizedBox(height: tokens.spacingSm),
                  FoodFormTextField(
                    fieldKey: 'servingGramsField',
                    label: 'Grams per serving (optional)',
                    numeric: true,
                    value: state.servingGrams,
                    errorText: validation?.servingGramsError,
                    onChanged: controller.updateServingGrams,
                  ),
                  SizedBox(height: tokens.spacingSm),
                  FoodFormTextField(
                    fieldKey: 'servingVolumeMlField',
                    label: 'Volume per serving in ml (optional)',
                    numeric: true,
                    value: state.servingVolumeMl,
                    errorText: validation?.servingVolumeMlError,
                    onChanged: controller.updateServingVolumeMl,
                  ),
                ] else if (state.basisMode == FoodBasisMode.serving &&
                    (state.basisUnit == 'g' || state.basisUnit == 'oz')) ...[
                  SizedBox(height: tokens.spacingSm),
                  FoodFormTextField(
                    fieldKey: 'servingVolumeMlField',
                    label: 'Volume in ml (optional)',
                    numeric: true,
                    value: state.servingVolumeMl,
                    errorText: validation?.servingVolumeMlError,
                    onChanged: controller.updateServingVolumeMl,
                  ),
                ] else if (state.basisMode == FoodBasisMode.serving &&
                    (state.basisUnit == 'ml' ||
                        state.basisUnit == 'fl oz')) ...[
                  SizedBox(height: tokens.spacingSm),
                  FoodFormTextField(
                    fieldKey: 'servingGramsField',
                    label: 'Weight in grams (optional)',
                    numeric: true,
                    value: state.servingGrams,
                    errorText: validation?.servingGramsError,
                    onChanged: controller.updateServingGrams,
                  ),
                ],
                SizedBox(height: tokens.spacingLg),
                Text(
                  'Per Serving / Basis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                FoodFormTextField(
                  fieldKey: 'caloriesField',
                  label: 'Calories (kcal)',
                  numeric: true,
                  value: state.calories,
                  lowConfidence: check(ScanField.calories),
                  errorText: validation?.caloriesError,
                  onChanged: controller.updateCalories,
                ),
                SizedBox(height: tokens.spacingMd),
                FoodFormTextField(
                  fieldKey: 'proteinField',
                  label: 'Protein (g)',
                  numeric: true,
                  value: state.protein,
                  lowConfidence: check(ScanField.protein),
                  errorText: validation?.proteinError,
                  onChanged: controller.updateProtein,
                ),
                SizedBox(height: tokens.spacingMd),
                FoodFormTextField(
                  fieldKey: 'carbsField',
                  label: 'Carbs (g)',
                  numeric: true,
                  value: state.carbs,
                  lowConfidence: check(ScanField.carbs),
                  errorText: validation?.carbsError,
                  onChanged: controller.updateCarbs,
                ),
                SizedBox(height: tokens.spacingMd),
                FoodFormTextField(
                  fieldKey: 'fatField',
                  label: 'Fat (g)',
                  numeric: true,
                  value: state.fat,
                  lowConfidence: check(ScanField.fat),
                  errorText: validation?.fatError,
                  onChanged: controller.updateFat,
                ),
                SizedBox(height: tokens.spacingMd),
                AdditionalNutrientsSection(seed: currentSeed),
                if (state.submitError != null) ...[
                  SizedBox(height: tokens.spacingMd),
                  FieldErrorText(state.submitError!),
                ],
                SizedBox(height: tokens.spacingLg),
                FilledButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _save(context, ref),
                  child: const Text('Save food'),
                ),
                if (currentSeed != null && currentSeed.foundInDatabase)
                  _Attribution(seed: currentSeed),
                SizedBox(height: tokens.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Saves, and — when the barcode already belongs to a food in the
  /// catalogue — asks which food they meant before anything is written.
  ///
  /// The decision that there *is* a collision belongs to the controller; this
  /// only renders the choice and acts on the answer.
  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final controller = ref.read(foodFormControllerProvider(seed).notifier);

    final food = await controller.save();
    if (food != null) {
      navigator.pop(food);
      return;
    }

    final existing = ref
        .read(foodFormControllerProvider(seed))
        .duplicateBarcodeMatch;
    if (existing == null || !context.mounted) return;

    final isEditingExistingFood = seed?.existingFoodId != null;
    final choice = await DuplicateBarcodeDialog.show(
      context,
      existing,
      isEditingExistingFood: isEditingExistingFood,
    );
    switch (choice) {
      case null:
      case DuplicateBarcodeChoice.keepEditing:
        controller.dismissDuplicateBarcode();
      case DuplicateBarcodeChoice.useExisting:
        // Pops the food they already have, which is what every caller of this
        // screen does with a saved food anyway — so "use the one I have"
        // continues into the log dialog exactly like a fresh save would.
        //
        // Never reachable on the edit path: the dialog doesn't offer this
        // choice there (`widgets/duplicate_barcode_dialog.dart`) because
        // popping the OTHER food would silently discard the edits they made
        // to this one.
        controller.dismissDuplicateBarcode();
        navigator.pop(existing);
      case DuplicateBarcodeChoice.saveAnyway:
        final saved = await controller.save(allowDuplicateBarcode: true);
        if (saved != null) navigator.pop(saved);
    }
  }
}

String _title(FoodFormSeed? seed) {
  if (seed == null) return 'New food';
  if (seed.name.isNotEmpty && seed.hasCompleteMacros) {
    return 'Edit food details';
  }
  return seed.foundInDatabase ? 'Check these details' : 'Add this food';
}

class _SeedIntro extends ConsumerWidget {
  const _SeedIntro({required this.seed});

  final FoodFormSeed seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (seed.foundInDatabase) return ProviderFoodNotes(seed: seed);
    if (seed.name.isNotEmpty && seed.hasCompleteMacros) {
      return const SizedBox.shrink();
    }

    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Text(
        foodNotFoundOnlineCopy,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Attribution extends ConsumerWidget {
  const _Attribution({required this.seed});

  final FoodFormSeed seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref
        .watch(foodDataProviderProvider)
        .providerFor(seed.source);
    return FoodDataAttribution(
      name: provider.attributionName,
      url: provider.productPageUrl(seed.barcode).toString(),
    );
  }
}
