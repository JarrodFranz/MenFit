import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'log_entry_controller.freezed.dart';
part 'log_entry_controller.g.dart';

/// In-progress state of the log-a-food dialog.
///
/// [perServing] and [servingGrams] are held here rather than re-read from
/// the food on every keystroke: for an edit they are the entry's own
/// **snapshot**, which is what the entry must keep
/// (`domain/nutrition_entry.dart`), and for a new log they are the food's
/// definition as it stood when the dialog opened.
///
/// [amount] and [unit] are what the user is typing and picking; the serving
/// count everything else is computed from is [servings], derived rather than
/// stored so the two can never fall out of step mid-edit.
@freezed
abstract class LogEntryFormState with _$LogEntryFormState {
  const factory LogEntryFormState({
    required LocalDate day,
    required MealType meal,
    required NutritionFacts perServing,
    required String displayName,
    String? servingDescription,

    /// The food's grams per serving — the entry's snapshot when editing.
    /// `null` means weight units are unavailable here, which [availableUnits]
    /// turns into a one-entry picker.
    double? servingGrams,

    /// The food's millilitres per serving — the entry's snapshot when editing.
    /// `null` when volume units are not configured.
    double? servingVolumeMl,

    /// `null` once the field has been cleared or typed into with something
    /// that isn't a number — [validateNutritionEntry] turns that into the
    /// "add a number" message rather than this guessing one.
    @Default(1) double? amount,
    @Default(QuantityUnit.serving) QuantityUnit unit,
    String? quantityError,
    String? dayError,
    @Default(false) bool isSubmitting,
    String? submitError,

    /// Flips to `true` once [LogEntryController.save] persists — same
    /// convention as `CheckinFormState.didSave`.
    @Default(false) bool didSave,
    @Default(false) bool didDelete,
  }) = _LogEntryFormState;

  const LogEntryFormState._();

  /// The units this food can actually be logged in. One entry long when neither
  /// serving weight nor volume was recorded — see [QuantityUnit.availableFor]
  /// for why that beats offering grams or ml that cannot convert.
  ///
  /// [unit] is passed as `including` so an entry logged in millilitres back
  /// when those were offered still reopens in the unit it was logged in,
  /// rather than handing the dropdown a value it has no item for.
  List<QuantityUnit> get availableUnits => QuantityUnit.availableFor(
    servingGrams,
    servingVolumeMl: servingVolumeMl,
    including: unit,
  );

  /// Whether the picker has a real choice in it, which is also the condition
  /// under which the dialog explains what a gram weight or volume would unlock.
  bool get canLogByWeight => availableUnits.length > 1;

  /// [amount] of [unit] as a serving count, or `null` when there is no
  /// number yet. The single derivation the preview, the validation and the
  /// saved entry all read, so none of them can disagree.
  double? get servings {
    final typed = amount;
    if (typed == null) return null;
    final conversion = servingsFor(
      amount: typed,
      unit: unit,
      servingGrams: servingGrams,
      servingVolumeMl: servingVolumeMl,
    );
    return conversion is ConvertedQuantity ? conversion.servings : null;
  }

  /// Human-readable label for a unit in dropdowns, appending serving portion
  /// or gram/volume amounts in brackets when available.
  String unitLabel(QuantityUnit unit) {
    if (unit == QuantityUnit.serving) {
      if (servingGrams != null &&
          servingGrams! > 0 &&
          servingVolumeMl != null &&
          servingVolumeMl! > 0) {
        final g = servingGrams! == servingGrams!.roundToDouble()
            ? servingGrams!.round().toString()
            : servingGrams!.toString();
        final ml = servingVolumeMl! == servingVolumeMl!.roundToDouble()
            ? servingVolumeMl!.round().toString()
            : servingVolumeMl!.toString();
        return 'Serving ($g g, $ml ml)';
      } else if (servingVolumeMl != null && servingVolumeMl! > 0) {
        final ml = servingVolumeMl! == servingVolumeMl!.roundToDouble()
            ? servingVolumeMl!.round().toString()
            : servingVolumeMl!.toString();
        return 'Serving ($ml ml)';
      } else if (servingGrams != null && servingGrams! > 0) {
        final g = servingGrams! == servingGrams!.roundToDouble()
            ? servingGrams!.round().toString()
            : servingGrams!.toString();
        return 'Serving ($g g)';
      } else if (servingDescription != null &&
          servingDescription!.trim().isNotEmpty) {
        return 'Serving (${servingDescription!.trim()})';
      }
      return 'Serving';
    }
    return switch (unit) {
      QuantityUnit.gram => 'gram (g)',
      QuantityUnit.millilitre => 'millilitre (ml)',
      QuantityUnit.ounce => 'ounce (oz)',
      QuantityUnit.fluidOunce => 'fluid ounce (fl oz)',
      QuantityUnit.kilogram => 'kilogram (kg)',
      QuantityUnit.pound => 'pound (lb)',
      _ => unit.label,
    };
  }
}

/// Drives the log-a-food dialog (`presentation/log_entry_dialog.dart`).
///
/// A **family** keyed by what the dialog was opened with, the same
/// family-derives-initial-state shape as `FlareController`:
///
/// - [existing] non-null → editing that diary entry ([food] is ignored).
/// - [existing] null and [food] non-null → logging a new entry for [day]
///   into [meal].
///
/// Exactly one of the two is expected; a call with neither can't build an
/// entry and [save] reports that rather than throwing.
@riverpod
class LogEntryController extends _$LogEntryController {
  @override
  LogEntryFormState build(
    NutritionEntry? existing,
    Food? food,
    LocalDate day,
    MealType meal,
  ) {
    if (existing != null) {
      // Reopening in the unit it was logged in is the entire reason those
      // columns exist: an entry entered as 47 g must not come back as
      // 1.57 servings for her to edit. `amountFor` refuses when the entry
      // carries no serving-weight snapshot (every pre-v13 row, and any food
      // that never had a weight), and the honest fallback there is servings
      // — the serving count is the one number such an entry does hold.
      final reopened = amountFor(
        servings: existing.quantityServings,
        unit: existing.quantityUnit,
        servingGrams: existing.servingGrams,
        servingVolumeMl: existing.servingVolumeMl,
      );
      return LogEntryFormState(
        day: existing.day,
        meal: existing.meal,
        perServing: existing.perServing,
        displayName: existing.displayName,
        servingDescription: existing.servingDescription,
        servingGrams: existing.servingGrams,
        servingVolumeMl: existing.servingVolumeMl,
        amount: reopened is ConvertedAmount
            ? reopened.amount
            : existing.quantityServings,
        unit: reopened is ConvertedAmount
            ? existing.quantityUnit
            : QuantityUnit.serving,
      );
    }
    return LogEntryFormState(
      day: day,
      meal: meal,
      perServing: food?.perServing ?? NutritionFacts.zero,
      displayName: food?.displayName ?? '',
      servingDescription: food?.servingDescription,
      servingGrams: food?.servingGrams,
      servingVolumeMl: food?.servingVolumeMl,
    );
  }

  bool get isEditing => existing != null;

  /// What the entry would contribute at the quantity currently typed —
  /// the "before you commit" figure the dialog shows. Scaled by the
  /// *converted* serving count, so switching the unit moves the preview,
  /// and by the domain's own scaling so it can't disagree with what gets
  /// saved.
  NutritionFacts get preview => state.perServing.scaled(state.servings ?? 0);

  void setMeal(MealType value) => state = state.copyWith(meal: value);

  /// Takes the raw field text so the dialog stays free of parsing. A comma
  /// is accepted as a decimal separator — plenty of keyboards produce one,
  /// and rejecting it would look like the app refusing a valid number.
  void updateQuantity(String raw) {
    state = state.copyWith(
      amount: double.tryParse(raw.trim().replaceAll(',', '.')),
      quantityError: null,
    );
  }

  /// Switches the unit, **keeping the number already typed**. Retyping 47
  /// after tapping "gram" would be a small insult to someone holding a
  /// scale; the preview below the field is what shows her the change.
  void setUnit(QuantityUnit value) {
    state = state.copyWith(unit: value, quantityError: null);
  }

  /// Validates and persists. Returns `true` only when a row was written.
  Future<bool> save() async {
    final validation = validateNutritionEntry(
      day: state.day,
      today: LocalDate.today(),
      // The bounds apply to the converted serving count, so one set of
      // limits covers every unit; the typed amount is checked only for
      // being a positive, finite number (`nutrition_validation.dart`).
      quantityServings: state.servings,
      quantityAmount: state.amount,
    );
    if (!validation.isValid) {
      state = state.copyWith(
        dayError: validation.dayError,
        quantityError: validation.quantityError,
      );
      return false;
    }

    final source = existing;
    final definition = food;
    if (source == null && definition == null) {
      state = state.copyWith(submitError: _nothingToLogMessage);
      return false;
    }

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final now = DateTime.now().toUtc();
      final amount = state.amount!;
      final repo = ref.read(nutritionRepositoryProvider);

      if (source == null && definition != null) {
        final existingFood = await repo.getFood(definition.id);
        if (existingFood == null) {
          await repo.saveFood(definition);
        }
      }

      // Both branches derive the serving count inside the domain
      // (`NutritionEntry.fromFood`/`withQuantity`), never here: a
      // `copyWith(quantityServings:)` in a controller is exactly how an
      // entry's amount and its multiplier come to disagree.
      final entry = source == null
          ? NutritionEntry.fromFood(
              id: EntityId.generate(),
              day: state.day,
              meal: state.meal,
              food: definition!,
              amount: amount,
              unit: state.unit,
              now: now,
            )
          : source
                .withQuantity(amount: amount, unit: state.unit)
                .copyWith(meal: state.meal, updatedAt: now);
      await repo.saveEntry(entry);
      state = state.copyWith(didSave: true, isSubmitting: false);
      return true;
    } on Object catch (error) {
      // S2: `userMessageFor` maps to fixed copy — no food name, quantity or
      // nutrition value can reach the message.
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return false;
    }
  }

  /// Deletes the entry being edited. A no-op when logging a new one.
  Future<bool> delete() async {
    final source = existing;
    if (source == null) return false;

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      await ref.read(nutritionRepositoryProvider).deleteEntry(source.id);
      state = state.copyWith(didDelete: true, isSubmitting: false);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return false;
    }
  }
}

/// Shown only if the dialog was somehow opened with neither an entry to edit
/// nor a food to log — a programming error, worded for a person anyway.
const String _nothingToLogMessage =
    "We've lost track of which food this was. Close this and pick it again.";
