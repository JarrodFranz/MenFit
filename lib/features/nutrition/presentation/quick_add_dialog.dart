import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/field_error_text.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_controller.dart';

/// Dialog allowing fast manual logging of a generic meal or quick-add entry
/// by entering calories and/or macros directly without creating a catalogue food.
///
/// **"Save to my foods" is off by default**, and stays that way: the whole
/// point of a quick add is that it costs nothing and leaves nothing behind,
/// and a catalogue that silently filled up with "Lunch at cafe" would make
/// the picker worse for everyone who never asked for it. Turned on, the same
/// numbers additionally become a `Food` — source [FoodSource.custom], one
/// serving, no gram weight — and the entry links to it, so the next time it
/// is one tap in the picker's "Recent" list.
class QuickAddDialog extends ConsumerStatefulWidget {
  const QuickAddDialog({
    required this.day,
    required this.meal,
    super.key,
  });

  final LocalDate day;
  final MealType meal;

  static Future<bool?> show(
    BuildContext context, {
    required LocalDate day,
    required MealType meal,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => QuickAddDialog(day: day, meal: meal),
    );
  }

  @override
  ConsumerState<QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends ConsumerState<QuickAddDialog> {
  late MealType _meal;
  final _nameController = TextEditingController(text: 'Quick add');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;
  bool _caloriesManuallyEdited = false;
  bool _saveToMyFoods = false;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _onMacroChanged() {
    if (_caloriesManuallyEdited && _caloriesController.text.isNotEmpty) {
      return;
    }
    final p = parseNutritionNumber(_proteinController.text) ?? 0;
    final c = parseNutritionNumber(_carbsController.text) ?? 0;
    final f = parseNutritionNumber(_fatController.text) ?? 0;

    if (p > 0 || c > 0 || f > 0) {
      final calculatedKcal = (p * 4) + (c * 4) + (f * 9);
      final formatted = calculatedKcal == calculatedKcal.roundToDouble()
          ? calculatedKcal.round().toString()
          : calculatedKcal.toStringAsFixed(1);
      _caloriesController.text = formatted;
      _caloriesManuallyEdited = false;
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Quick add'
        : _nameController.text.trim();

    final p = parseNutritionNumber(_proteinController.text);
    final c = parseNutritionNumber(_carbsController.text);
    final f = parseNutritionNumber(_fatController.text);
    var cal = parseNutritionNumber(_caloriesController.text);

    // If calories is blank but macros are given, calculate calories
    if ((cal == null || cal.isNaN) && (p != null || c != null || f != null)) {
      cal = ((p ?? 0) * 4) + ((c ?? 0) * 4) + ((f ?? 0) * 9);
    }

    if (cal == null || cal.isNaN) {
      setState(() {
        _error = 'Enter calories or at least one macro.';
      });
      return;
    }

    if (cal < 0 ||
        (p != null && p < 0) ||
        (c != null && c < 0) ||
        (f != null && f < 0)) {
      setState(() {
        _error = "Values can't be less than zero.";
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final now = DateTime.now().toUtc();
      final facts = NutritionFacts(
        caloriesKcal: cal,
        proteinGrams: p ?? 0,
        carbsGrams: c ?? 0,
        fatGrams: f ?? 0,
      );
      final repository = ref.read(nutritionRepositoryProvider);

      String? foodId;
      if (_saveToMyFoods) {
        final food = Food(
          id: EntityId.generate(),
          name: name,
          // One serving with no gram weight, because that is all a quick
          // add knows: the numbers describe the portion they ate, not a
          // measurable unit of the food. `QuantityUnit.availableFor` then
          // offers servings only, which is the honest picker for it.
          servingDescription: '1 serving',
          perServing: facts,
          createdAt: now,
          updatedAt: now,
        );
        await repository.saveFood(food);
        foodId = food.id;
      }

      final entry = NutritionEntry(
        id: EntityId.generate(),
        day: widget.day,
        meal: _meal,
        foodId: foodId,
        foodName: name,
        quantityServings: 1,
        quantityAmount: 1,
        // Left unset even when a food was saved: the diary row would
        // otherwise read "1 serving · 1 serving", printing the same fact
        // twice.
        perServing: facts,
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveEntry(entry);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = userMessageFor(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return AlertDialog(
      title: const Text('Quick add generic meal'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<MealType>(
                key: const Key('quickAddMealDropdown'),
                initialValue: _meal,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Meal',
                ),
                items: [
                  for (final value in MealType.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (val) {
                        if (val != null) setState(() => _meal = val);
                      },
              ),
              SizedBox(height: tokens.spacingMd),
              TextFormField(
                key: const Key('quickAddNameField'),
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Item name / description',
                  helperText: "e.g. 'Generic meal' or 'Lunch at cafe'",
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              TextFormField(
                key: const Key('quickAddCaloriesField'),
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Calories (kcal)',
                  helperText: 'Auto-calculated if macros entered',
                ),
                onChanged: (val) {
                  _caloriesManuallyEdited = val.trim().isNotEmpty;
                },
              ),
              SizedBox(height: tokens.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('quickAddProteinField'),
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Protein (g)',
                      ),
                      onChanged: (_) => _onMacroChanged(),
                    ),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: TextFormField(
                      key: const Key('quickAddCarbsField'),
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Carbs (g)',
                      ),
                      onChanged: (_) => _onMacroChanged(),
                    ),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: TextFormField(
                      key: const Key('quickAddFatField'),
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Fat (g)',
                      ),
                      onChanged: (_) => _onMacroChanged(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spacingSm),
              SwitchListTile.adaptive(
                key: const Key('quickAddSaveToFoodsSwitch'),
                value: _saveToMyFoods,
                contentPadding: EdgeInsets.zero,
                title: const Text('Save to my foods'),
                subtitle: const Text(
                  'Keeps these numbers as a food you can log again. Off, '
                  'this stays a one-off.',
                ),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _saveToMyFoods = value),
              ),
              if (_error != null) ...[
                SizedBox(height: tokens.spacingMd),
                FieldErrorText(_error!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('quickAddSaveButton'),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Log meal'),
        ),
      ],
    );
  }
}
