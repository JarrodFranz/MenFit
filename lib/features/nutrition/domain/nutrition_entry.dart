import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';

part 'nutrition_entry.freezed.dart';

/// One logged item in the food diary: [quantityServings] servings of a
/// food, on [meal], on calendar [day].
///
/// ## Two numbers, one meaning
///
/// [quantityServings] is the canonical multiplier — [facts] and every day
/// and meal total are it times [perServing], whatever unit was used to
/// arrive at it. [quantityAmount] and [quantityUnit] record how the user
/// *expressed* that quantity ("47 g"), and [servingGrams] is the snapshot
/// they were measured against. They exist so the diary can show her back
/// what she entered instead of a serving count she never typed; they change
/// nothing about what the entry contributes.
///
/// The three are kept in step by [NutritionEntry.fromFood] and
/// [withQuantity], the only two places that derive one from the other.
/// Nothing else should set [quantityServings].
///
/// ## [perServing] is a snapshot, not a lookup
///
/// [perServing], [foodName], [foodBrand] and [servingDescription] are
/// copies of the food's values **as they stood when this entry was
/// logged** — not a cached view of the food's current values. Editing the
/// food afterwards (or S1-5 re-fetching a provider-sourced product) changes
/// what you log *next*, and never touches what you already ate. A diary
/// that silently rewrites its own history is a diary the user cannot
/// trust; the same reasoning is spelled out in
/// `core/db/tables/nutrition_entries.dart`.
///
/// [foodId] is therefore only a convenience link for "log this again" — it
/// may point at a food that has since been edited or deleted, and this
/// entry stays complete and displayable either way.
///
/// [day] is a user-local calendar day, the same convention as
/// `features/wellbeing/domain/daily_checkin.dart` (see
/// `knowledge/architecture/data_architecture.md`). Unlike a check-in, many
/// entries share a day.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`: nutrition
/// logs): never logged, never in analytics, never in an exception message.
@freezed
abstract class NutritionEntry with _$NutritionEntry {
  const factory NutritionEntry({
    required String id,
    required LocalDate day,
    required MealType meal,

    /// The food's name at log time — see the class doc's snapshot section.
    required String foodName,

    /// How many servings were eaten. Always greater than zero (see
    /// `domain/nutrition_validation.dart`); fractions are normal.
    required double quantityServings,

    /// The number the user typed, in [quantityUnit] — see the class doc's
    /// "Two numbers" section.
    required double quantityAmount,

    /// The food's per-serving nutrition at log time — see the class doc's
    /// snapshot section.
    required NutritionFacts perServing,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// The `Food.id` this was logged from, when it is still worth linking
    /// back to. Never required, and never trusted to still resolve.
    String? foodId,

    /// The food's brand at log time. `null` when it had none.
    String? foodBrand,

    /// The food's serving description at log time, e.g. `'1 cup (dry)'`.
    String? servingDescription,

    /// The unit [quantityAmount] is in. Defaults to
    /// [QuantityUnit.serving] for the same reason the column does: before
    /// units existed, servings were the only thing an entry could hold.
    /// (It sits down here among the optionals only because a defaulted
    /// parameter may not precede a required one.)
    @Default(QuantityUnit.serving) QuantityUnit quantityUnit,

    /// The food's grams per serving **at log time**, or `null` when it had
    /// The food's grams per serving **at log time**, or `null` when it had
    /// none recorded — see the class doc's snapshot section, which applies
    /// to this field for the same reason it applies to [perServing].
    ///
    /// `null` means weight units are unavailable for this entry, and is
    /// what every entry logged before units existed carries. It is never
    /// re-read from the food to fill the gap: that would measure an old
    /// entry against a weight it was never logged against.
    double? servingGrams,

    /// The food's volume in millilitres per serving **at log time**, or `null`
    /// when it had none recorded.
    double? servingVolumeMl,
  }) = _NutritionEntry;

  const NutritionEntry._();

  /// Builds an entry from [food]: [amount] of [unit], snapshotting
  /// everything this entry needs to stay independent of it afterwards.
  ///
  /// The single place the snapshot is taken, so no caller can accidentally
  /// log an entry that keeps referring back to a mutable food — and, since
  /// units arrived, the single place [quantityServings] is derived, so no
  /// caller can build an entry whose serving count disagrees with the
  /// amount, unit and serving weight sitting next to it.
  ///
  /// Throws an [ArgumentError] when [unit] is a mass and [food] has no
  /// usable serving weight, or when [unit] is a volume and [food] has no
  /// usable serving volume.
  factory NutritionEntry.fromFood({
    required String id,
    required LocalDate day,
    required MealType meal,
    required Food food,
    required double amount,
    required DateTime now,
    QuantityUnit unit = QuantityUnit.serving,
  }) {
    return NutritionEntry(
      id: id,
      day: day,
      meal: meal,
      foodId: food.id,
      foodName: food.name,
      foodBrand: food.brand,
      servingDescription: food.servingDescription,
      quantityServings: _servingsOrThrow(
        amount: amount,
        unit: unit,
        servingGrams: food.servingGrams,
        servingVolumeMl: food.servingVolumeMl,
      ),
      quantityAmount: amount,
      quantityUnit: unit,
      servingGrams: food.servingGrams,
      servingVolumeMl: food.servingVolumeMl,
      perServing: food.perServing,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// This entry re-quantified to [amount] of [unit], measured against the
  /// serving weight/volume it was **logged** with, not the food's current one.
  ///
  /// The edit-an-entry counterpart to [NutritionEntry.fromFood], and the
  /// only other place [quantityServings] is derived — editing through
  /// `copyWith` would let the amount and the serving count drift apart.
  /// Refuses on exactly the same terms.
  NutritionEntry withQuantity({
    required double amount,
    required QuantityUnit unit,
  }) {
    return copyWith(
      quantityServings: _servingsOrThrow(
        amount: amount,
        unit: unit,
        servingGrams: servingGrams,
        servingVolumeMl: servingVolumeMl,
      ),
      quantityAmount: amount,
      quantityUnit: unit,
    );
  }

  /// What this entry actually contributes to the day: [perServing] scaled
  /// by [quantityServings] — the unit it was logged in never enters into
  /// it, which is why 2 servings and 60 g of a 30 g-serving food add
  /// exactly the same nutrition.
  NutritionFacts get facts => perServing.scaled(quantityServings);

  /// What she logged, as she logged it: `'47 g'`, `'1.5 servings'`.
  ///
  /// Lives here rather than in a widget for the same reason [displayName]
  /// does: the diary row and the log dialog must not be able to word the
  /// same fact two ways. [QuantityUnit.shortLabel] supplies the unit;
  /// [QuantityUnit.serving] is the one that pluralises, having a word
  /// rather than a symbol.
  String get quantityLabel {
    // Two decimals at most: 47 g of a 30 g serving is 1.5666… servings, and
    // the reverse trip can land a hair off the number she typed.
    final rounded = double.parse(quantityAmount.toStringAsFixed(2));
    final text = rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toString();
    final label = quantityUnit.shortLabel;
    if (quantityUnit != QuantityUnit.serving) return '$text $label';
    return rounded == 1 ? '$text $label' : '$text ${label}s';
  }

  /// Name plus brand when there is one, from the snapshot — the diary's
  /// display label, which stays correct even after the food it came from
  /// was renamed or deleted.
  String get displayName =>
      foodBrand == null ? foodName : '$foodName · $foodBrand';
}

/// [servingsFor], with the one outcome an entry cannot be built from turned
/// into a loud failure.
///
/// The message names the combination and nothing else: an amount, a food
/// name or a nutrition figure in an exception is an S2 disclosure
/// (`knowledge/engineering/security_and_privacy.md`), and this text can
/// reach a crash log.
double _servingsOrThrow({
  required double amount,
  required QuantityUnit unit,
  required double? servingGrams,
  required double? servingVolumeMl,
}) {
  final conversion = servingsFor(
    amount: amount,
    unit: unit,
    servingGrams: servingGrams,
    servingVolumeMl: servingVolumeMl,
  );
  return switch (conversion) {
    ConvertedQuantity(:final servings) => servings,
    NoServingWeight() => throw ArgumentError.value(
      unit.name,
      'unit',
      'a weight unit needs the food to have a serving weight — '
          'QuantityUnit.availableFor must gate the picker',
    ),
    NoServingVolume() => throw ArgumentError.value(
      unit.name,
      'unit',
      'a volume unit needs the food to have a serving volume — '
          'QuantityUnit.availableFor must gate the picker',
    ),
    // `amountFor`'s result type, which `servingsFor` never returns.
    ConvertedAmount() => throw StateError('servingsFor returned an amount'),
  };
}
