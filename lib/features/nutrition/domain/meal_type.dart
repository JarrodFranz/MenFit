/// Which meal a diary entry belongs to.
///
/// A small, closed vocabulary — same storage/label shape as
/// `features/wellbeing/domain/symptom_type.dart`. User-configurable meals
/// are a later idea (`knowledge/domain/nutrition.md`), deliberately not
/// built now.
///
/// [values]' declaration order is the order meals are shown and totalled
/// in: breakfast, lunch, dinner, snack. Snacks sort last rather than by
/// time of day because a snack has no fixed hour, and because a day's
/// totals read more naturally as "three meals plus whatever else".
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  /// Parses the persisted string form, defaulting to [snack] for any
  /// unrecognised value — the neutral catch-all, in the same spirit as
  /// `SymptomType.other`: an entry with an unreadable meal key still
  /// belongs to the day's totals, and lands somewhere honest rather than
  /// being silently attributed to breakfast.
  static MealType fromStorage(String value) {
    return switch (value) {
      'breakfast' => MealType.breakfast,
      'lunch' => MealType.lunch,
      'dinner' => MealType.dinner,
      _ => MealType.snack,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    MealType.breakfast => 'breakfast',
    MealType.lunch => 'lunch',
    MealType.dinner => 'dinner',
    MealType.snack => 'snack',
  };

  /// Warm, plain-English display label
  /// (`knowledge/product/terminology.md`: "UI copy uses plain, warm
  /// language").
  String get label => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snacks',
  };
}
