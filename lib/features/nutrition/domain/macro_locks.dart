import 'package:freezed_annotation/freezed_annotation.dart';

part 'macro_locks.freezed.dart';

/// One of the three macronutrients a daily target can be set for.
///
/// Exists so the lock set, the solver's answer and the form's fields can all
/// name the same macro without passing strings around. Deliberately *not*
/// carrying its kilocalories-per-gram: the Atwater factors live in
/// `domain/macro_targets.dart` beside the rest of the target arithmetic, and
/// duplicating them here would give this codebase two places where "a gram
/// of fat is 9 kcal" could drift apart. `kcalPerGramFor` there maps this
/// enum onto them.
enum MacroNutrient {
  protein,
  carbs,
  fat;

  /// Parses the persisted key. Returns `null` for anything unrecognised —
  /// like `core/domain/weekday.dart`'s `Weekday`, this enum has no natural
  /// "other" value, so a decoder reading a stored set drops what it can't
  /// parse rather than guessing (see [MacroLocks.fromStorage]).
  static MacroNutrient? fromStorage(String value) => switch (value) {
    'protein' => MacroNutrient.protein,
    'carbs' => MacroNutrient.carbs,
    'fat' => MacroNutrient.fat,
    _ => null,
  };

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    MacroNutrient.protein => 'protein',
    MacroNutrient.carbs => 'carbs',
    MacroNutrient.fat => 'fat',
  };

  /// Display label, as the goals form writes it.
  String get label => switch (this) {
    MacroNutrient.protein => 'Protein',
    MacroNutrient.carbs => 'Carbs',
    MacroNutrient.fat => 'Fat',
  };
}

/// Which of the three gram targets the user has pinned to the value she
/// typed.
///
/// A lock says "keep this one where I put it". With two of the three locked
/// and a daily energy figure to work from, the remaining one is determined —
/// `domain/macro_targets.dart`'s solver works it out. With fewer locked
/// nothing is determined, and the app **does not invent a split**: choosing
/// a ratio on the user's behalf would be a nutrition recommendation, which
/// this app does not make (`knowledge/domain/womens_health.md` rule 1).
///
/// **Locks are persisted**, not UI state. "I need protein to stay at 200 g"
/// is a durable intent: when the calorie target moves next month the
/// unlocked macro has to move with it, and a lock that evaporated on reopen
/// would quietly break that promise.
///
/// A value type with no "unset" case: [none] is the starting state and means
/// exactly what it says. Nothing is locked by default.
@freezed
abstract class MacroLocks with _$MacroLocks {
  const factory MacroLocks({
    @Default(false) bool protein,
    @Default(false) bool carbs,
    @Default(false) bool fat,
  }) = _MacroLocks;

  /// Builds a lock set from the macros in [locked].
  factory MacroLocks.of(Iterable<MacroNutrient> locked) {
    final set = locked.toSet();
    return MacroLocks(
      protein: set.contains(MacroNutrient.protein),
      carbs: set.contains(MacroNutrient.carbs),
      fat: set.contains(MacroNutrient.fat),
    );
  }

  /// Decodes the comma-separated storage form (`'protein,fat'`).
  ///
  /// Tolerant on purpose: `null`, `''`, stray whitespace, repeated keys and
  /// keys this version doesn't know all decode to the largest sensible
  /// answer rather than throwing. A row written by a future version that
  /// added a fourth macro must still be readable by this one, and the honest
  /// reading of an unknown key is "not one of the three I can lock".
  factory MacroLocks.fromStorage(String? value) {
    final raw = value;
    if (raw == null || raw.trim().isEmpty) return none;
    return MacroLocks.of(
      raw
          .split(',')
          .map((key) => MacroNutrient.fromStorage(key.trim()))
          .whereType<MacroNutrient>(),
    );
  }

  const MacroLocks._();

  /// Nothing locked — the starting state, and a perfectly valid steady one.
  static const MacroLocks none = MacroLocks();

  /// The persisted string form, always written in [MacroNutrient] order.
  ///
  /// A set has no order of its own, so the encoder imposes one: two equal
  /// lock sets must produce byte-identical storage, or a no-op save would
  /// look like a change to sync (ADR 004) and to anyone diffing a row.
  String toStorage() => locked.map((macro) => macro.toStorage()).join(',');

  /// Whether [macro]'s target is pinned.
  bool isLocked(MacroNutrient macro) => switch (macro) {
    MacroNutrient.protein => protein,
    MacroNutrient.carbs => carbs,
    MacroNutrient.fat => fat,
  };

  /// This set with [macro] locked or unlocked.
  MacroLocks withLock(MacroNutrient macro, {required bool locked}) =>
      switch (macro) {
        MacroNutrient.protein => copyWith(protein: locked),
        MacroNutrient.carbs => copyWith(carbs: locked),
        MacroNutrient.fat => copyWith(fat: locked),
      };

  /// The locked macros, in [MacroNutrient] order.
  List<MacroNutrient> get locked => [
    for (final macro in MacroNutrient.values)
      if (isLocked(macro)) macro,
  ];

  /// The macros left free, in [MacroNutrient] order.
  List<MacroNutrient> get free => [
    for (final macro in MacroNutrient.values)
      if (!isLocked(macro)) macro,
  ];

  /// How many of the three are locked, 0-3.
  int get lockedCount => locked.length;

  /// Whether nothing is locked.
  bool get isEmpty => lockedCount == 0;
}
