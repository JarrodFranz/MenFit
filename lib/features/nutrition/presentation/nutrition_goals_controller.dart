import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nutrition_goals_controller.g.dart';

/// Watches the single nutrition-goals row and exposes a merging update.
///
/// Same shape as `ProfileController`, for the same two reasons: every field
/// is optional so an update has to merge rather than replace, and a nullable
/// field needs a `clear*` flag because `null` alone can't say whether the
/// caller meant "leave it" or "unset it".
///
/// Updates are serialised through [_tail] so two controls saved in quick
/// succession (the activity-level chip and the hide-calories switch, say)
/// can't both merge onto the same stale row and clobber each other.
@riverpod
class NutritionGoalsController extends _$NutritionGoalsController {
  Future<void> _tail = Future<void>.value();

  @override
  Stream<NutritionGoals?> build() {
    return ref.watch(nutritionGoalsRepositoryProvider).watchGoals();
  }

  /// Applies the given fields to the saved goals — creating the row if none
  /// exists yet — and persists the result.
  ///
  /// Returns a future that completes (or throws) once *this* update has been
  /// written, independent of anything queued behind it.
  Future<void> updateGoals({
    int? calorieTargetKcal,
    bool clearCalorieTarget = false,
    double? proteinTargetGrams,
    bool clearProteinTarget = false,
    double? carbTargetGrams,
    bool clearCarbTarget = false,
    double? fatTargetGrams,
    bool clearFatTarget = false,
    MacroTargetMode? macroTargetMode,
    double? proteinTargetPercent,
    bool clearProteinPercentTarget = false,
    double? carbTargetPercent,
    bool clearCarbPercentTarget = false,
    double? fatTargetPercent,
    bool clearFatPercentTarget = false,
    // No `clear` flag: [MacroLocks.none] already says "nothing locked", so
    // `null` can only mean "leave the lock set alone".
    MacroLocks? macroLocks,
    ActivityLevel? activityLevel,
    bool clearActivityLevel = false,
    bool? hideCalorieNumbers,
    WeightGoal? weightGoal,
    int? dailyDeficitKcal,
  }) {
    final repository = ref.read(nutritionGoalsRepositoryProvider);
    final operation = _tail.then(
      (_) => _apply(
        repository,
        calorieTargetKcal: calorieTargetKcal,
        clearCalorieTarget: clearCalorieTarget,
        proteinTargetGrams: proteinTargetGrams,
        clearProteinTarget: clearProteinTarget,
        carbTargetGrams: carbTargetGrams,
        clearCarbTarget: clearCarbTarget,
        fatTargetGrams: fatTargetGrams,
        clearFatTarget: clearFatTarget,
        macroTargetMode: macroTargetMode,
        proteinTargetPercent: proteinTargetPercent,
        clearProteinPercentTarget: clearProteinPercentTarget,
        carbTargetPercent: carbTargetPercent,
        clearCarbPercentTarget: clearCarbPercentTarget,
        fatTargetPercent: fatTargetPercent,
        clearFatPercentTarget: clearFatPercentTarget,
        macroLocks: macroLocks,
        activityLevel: activityLevel,
        clearActivityLevel: clearActivityLevel,
        hideCalorieNumbers: hideCalorieNumbers,
        weightGoal: weightGoal,
        dailyDeficitKcal: dailyDeficitKcal,
      ),
    );
    // One failed update must not wedge everything queued behind it; the
    // failure still reaches this call's own caller through `operation`.
    _tail = operation.then<void>((_) {}, onError: (_) {});
    return operation;
  }

  Future<void> _apply(
    NutritionGoalsRepository repository, {
    required int? calorieTargetKcal,
    required bool clearCalorieTarget,
    required double? proteinTargetGrams,
    required bool clearProteinTarget,
    required double? carbTargetGrams,
    required bool clearCarbTarget,
    required double? fatTargetGrams,
    required bool clearFatTarget,
    required MacroTargetMode? macroTargetMode,
    required double? proteinTargetPercent,
    required bool clearProteinPercentTarget,
    required double? carbTargetPercent,
    required bool clearCarbPercentTarget,
    required double? fatTargetPercent,
    required bool clearFatPercentTarget,
    required MacroLocks? macroLocks,
    required ActivityLevel? activityLevel,
    required bool clearActivityLevel,
    required bool? hideCalorieNumbers,
    required WeightGoal? weightGoal,
    required int? dailyDeficitKcal,
  }) async {
    // A fresh read, never `state.value`: the merge base has to reflect
    // whatever the previous queued update just wrote.
    final current = await repository.getGoals();
    final now = DateTime.now().toUtc();

    final next =
        (current ??
                NutritionGoals(
                  id: EntityId.generate(),
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              calorieTargetKcal: clearCalorieTarget
                  ? null
                  : (calorieTargetKcal ?? current?.calorieTargetKcal),
              proteinTargetGrams: clearProteinTarget
                  ? null
                  : (proteinTargetGrams ?? current?.proteinTargetGrams),
              carbTargetGrams: clearCarbTarget
                  ? null
                  : (carbTargetGrams ?? current?.carbTargetGrams),
              fatTargetGrams: clearFatTarget
                  ? null
                  : (fatTargetGrams ?? current?.fatTargetGrams),
              macroTargetMode:
                  macroTargetMode ??
                  current?.macroTargetMode ??
                  MacroTargetMode.grams,
              proteinTargetPercent: clearProteinPercentTarget
                  ? null
                  : (proteinTargetPercent ?? current?.proteinTargetPercent),
              carbTargetPercent: clearCarbPercentTarget
                  ? null
                  : (carbTargetPercent ?? current?.carbTargetPercent),
              fatTargetPercent: clearFatPercentTarget
                  ? null
                  : (fatTargetPercent ?? current?.fatTargetPercent),
              macroLocks: macroLocks ?? current?.macroLocks ?? MacroLocks.none,
              activityLevel: clearActivityLevel
                  ? null
                  : (activityLevel ?? current?.activityLevel),
              hideCalorieNumbers:
                  hideCalorieNumbers ?? current?.hideCalorieNumbers ?? false,
              weightGoal:
                  weightGoal ?? current?.weightGoal ?? WeightGoal.maintain,
              dailyDeficitKcal:
                  dailyDeficitKcal ?? current?.dailyDeficitKcal ?? 0,
              updatedAt: now,
            );

    await repository.saveGoals(next);
  }
}

/// Widest daily energy target this app will store, in kilocalories. A
/// fat-finger guard on a text field, in the same spirit (and with the same
/// copy rules) as `domain/nutrition_validation.dart`'s bounds — not a
/// statement about what anyone's target should be.
const double maxCalorieTargetKcal = 20000;

/// Widest daily target this app will store for any one macro, in grams.
const double maxMacroTargetGrams = 2000;

/// One daily-target field, as the goals form read it.
///
/// A blank field is a *valid* answer meaning "no target" — every target is
/// optional (`domain/nutrition_goals.dart`) — which is why [value] and
/// [error] are both nullable and why the two are not the same thing.
class DailyTargetField {
  const DailyTargetField._({this.value, this.error});

  /// Reads [raw]: blank clears the target, anything non-numeric or out of
  /// [max] comes back with copy that describes what the app can store rather
  /// than judging the number.
  ///
  /// [tooLargeMessage] overrides the over-[max] copy for a field whose bound
  /// isn't a storage limit — a macro *percentage* is capped at 100 because
  /// one share can't be more than the whole day, which is arithmetic rather
  /// than "larger than we can store".
  factory DailyTargetField.read(
    String raw, {
    required double max,
    String tooLargeMessage = _tooLargeMessage,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const DailyTargetField._();

    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return const DailyTargetField._(error: _notANumberMessage);
    }
    if (parsed < 0) return const DailyTargetField._(error: _negativeMessage);
    if (parsed > max) return DailyTargetField._(error: tooLargeMessage);
    return DailyTargetField._(value: parsed);
  }

  /// The number to store, or `null` for "no target".
  final double? value;

  /// Per-field copy, or `null` when the field is fine.
  final String? error;

  bool get isValid => error == null;
}

const String _notANumberMessage = 'Add a number here, or leave it blank.';
const String _negativeMessage = "That can't be less than zero.";
const String _tooLargeMessage =
    "That's larger than we can store as a daily target — worth a second "
    'look?';
