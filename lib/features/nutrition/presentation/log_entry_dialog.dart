import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/log_entry_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// Logs a food into a meal, or edits/deletes an entry already logged.
///
/// Opened two ways: from the food picker with a [food] (plus the [day] and
/// [meal] the picker was opened for), or from the diary with an [existing]
/// entry. All the field logic lives in [LogEntryController]; this stays a
/// plain [ConsumerWidget], same shape as `wellbeing`'s `FlareDialog`.
///
/// [show] completes with `true` once something was written, so the picker
/// can close itself behind a successful log rather than leaving the user on
/// a search screen they're finished with.
class LogEntryDialog extends ConsumerWidget {
  const LogEntryDialog({
    required this.day,
    required this.meal,
    this.food,
    this.existing,
    super.key,
  });

  final LocalDate day;
  final MealType meal;
  final Food? food;
  final NutritionEntry? existing;

  static Future<bool?> show(
    BuildContext context, {
    required LocalDate day,
    required MealType meal,
    Food? food,
    NutritionEntry? existing,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => LogEntryDialog(
        day: day,
        meal: meal,
        food: food,
        existing: existing,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final provider = logEntryControllerProvider(existing, food, day, meal);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final hideCalories =
        ref.watch(nutritionGoalsProvider).value?.hideCalorieNumbers ?? false;
    final isEditing = existing != null;

    ref.listen(provider, (previous, next) {
      final justFinished =
          (next.didSave && !(previous?.didSave ?? false)) ||
          (next.didDelete && !(previous?.didDelete ?? false));
      if (justFinished && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    });

    return AlertDialog(
      title: Text(isEditing ? 'Edit this entry' : 'Add to your day'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (state.servingDescription != null) ...[
                SizedBox(height: tokens.spacingXs),
                Text(
                  'One serving is ${state.servingDescription}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              SizedBox(height: tokens.spacingMd),
              DropdownButtonFormField<MealType>(
                initialValue: state.meal,
                // Same reason as `flare_dialog.dart`'s category dropdown:
                // without this the menu sizes to its widest item rather
                // than the dialog's width.
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Meal',
                ),
                items: [
                  for (final value in MealType.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: state.isSubmitting
                    ? null
                    : (value) {
                        if (value != null) controller.setMeal(value);
                      },
              ),
              SizedBox(height: tokens.spacingMd),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      key: const Key('quantityField'),
                      initialValue: formatNutritionField(state.amount),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Amount',
                        errorText: state.quantityError,
                      ),
                      onChanged: controller.updateQuantity,
                    ),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<QuantityUnit>(
                      key: const Key('quantityUnitField'),
                      initialValue: state.unit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Unit',
                      ),
                      // Exactly the units this food can convert — for a food
                      // with no recorded serving weight that is one entry
                      // long, which is a picker with nothing to choose
                      // rather than a picker offering grams that would fail.
                      items: [
                        for (final value in state.availableUnits)
                          DropdownMenuItem(
                            value: value,
                            child: Text(state.unitLabel(value)),
                          ),
                      ],
                      onChanged: state.isSubmitting
                          ? null
                          : (value) {
                              if (value != null) controller.setUnit(value);
                            },
                    ),
                  ),
                ],
              ),
              if (!state.canLogByWeight) ...[
                SizedBox(height: tokens.spacingXs),
                Text(
                  _noServingWeightNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (state.dayError != null) FieldErrorText(state.dayError!),
              SizedBox(height: tokens.spacingMd),
              _Preview(
                facts: controller.preview,
                hideCalorieNumbers: hideCalories,
              ),
              if (food != null) ...[
                SizedBox(height: tokens.spacingSm),
                Center(
                  child: TextButton.icon(
                    key: const Key('editFoodDetailsButton'),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit food details & macros'),
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final currentContext = context;
                            final currentFood = food!;
                            // One supported way to open the form on an
                            // existing food: it carries the id (so this is
                            // an update, not a twin), the provenance, and
                            // every optional nutrient the save would
                            // otherwise erase.
                            final seed = FoodFormSeed.forEditing(currentFood);
                            Navigator.of(currentContext).pop();
                            if (!currentContext.mounted) return;
                            final updated = await NutritionNewFoodRouteData(
                              $extra: seed,
                            ).push<Food>(currentContext);
                            if (currentContext.mounted) {
                              await LogEntryDialog.show(
                                currentContext,
                                day: day,
                                meal: meal,
                                food: updated ?? currentFood,
                              );
                            }
                          },
                  ),
                ),
              ],
              if (state.submitError != null) ...[
                SizedBox(height: tokens.spacingMd),
                FieldErrorText(state.submitError!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: state.isSubmitting
                ? null
                : () => unawaited(controller.delete()),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: state.isSubmitting
              ? null
              : () => unawaited(controller.save()),
          child: state.isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

/// What the chosen quantity works out to, shown before anything is written.
class _Preview extends StatelessWidget {
  const _Preview({required this.facts, required this.hideCalorieNumbers});

  final NutritionFacts facts;
  final bool hideCalorieNumbers;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final iron = facts.ironMg;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This adds',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingXs),
          if (!hideCalorieNumbers)
            Text(
              formatKcal(facts.caloriesKcal),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          Text(formatMacroLine(facts)),
          Text(
            iron == null
                ? 'Iron: not listed for this food'
                : 'Iron ${formatIronMg(iron)}',
          ),
        ],
      ),
    );
  }
}

/// Why the unit picker has only "serving" in it, and what would change that.
///
/// States a fact about the *food's record* and offers the thing that would
/// unlock the feature. Nothing here is about the user or about eating
/// (`knowledge/domain/nutrition.md`'s copy stance), and it appears once,
/// under the field it explains, rather than as an error.
const String _noServingWeightNote =
    "This food doesn't have a gram weight or volume per serving yet. "
    'Adding one lets you log it by weight or volume.';
