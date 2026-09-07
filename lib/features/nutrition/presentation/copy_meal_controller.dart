import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'copy_meal_controller.g.dart';

/// The meals that have something to copy into [day] from the day before it.
///
/// A stream over the previous day's entries, so the affordance appears and
/// disappears as that day changes underneath the diary rather than as a
/// snapshot taken when the screen was built.
///
/// **Never for a day in the future.** The diary refuses future days outright
/// (`domain/nutrition_validation.dart`) and the day selector is capped at
/// today, so this is belt and braces — but "copy yesterday into tomorrow" is
/// a meaningless offer and the guard costs one comparison.
@riverpod
Stream<Set<MealType>> copyableMeals(Ref ref, LocalDate day) {
  if (day.isAfter(LocalDate.today())) {
    return Stream.value(const <MealType>{});
  }
  return ref
      .watch(nutritionRepositoryProvider)
      .watchEntriesFor(day.addDays(-1))
      .map((entries) => {for (final entry in entries) entry.meal});
}

/// Copies one meal forward from the day before [day].
///
/// ## Why this copies rather than re-logs
///
/// Each source entry is duplicated **as it stands** — its own snapshot of
/// the food's name, brand, serving description, per-serving nutrition and
/// serving weight, plus the exact amount and unit they typed. The referenced
/// food is deliberately never re-read: an entry's snapshot is the record of
/// what they ate (`domain/nutrition_entry.dart`), and "the same breakfast as
/// yesterday" means the same numbers, not today's corrected definition of
/// them. It follows that a source entry whose food has since been edited,
/// or deleted, or which never had one at all (a quick add), copies across
/// perfectly well.
///
/// Only the identity fields move: a fresh id, the new [day], and fresh
/// timestamps. Yesterday's rows are read and never written.
///
/// [state] is whether a copy is in flight, per (day, meal), so the button
/// can be disabled while it runs and a double tap cannot log the meal twice.
@riverpod
class CopyMealController extends _$CopyMealController {
  @override
  bool build(LocalDate day, MealType meal) => false;

  /// Copies every entry logged for [meal] on the day before [day] into
  /// [day], and returns how many were copied.
  ///
  /// Returns `0` — writing nothing — when the previous day has nothing for
  /// this meal. The UI does not offer the action in that case
  /// ([copyableMealsProvider]), so `0` is the safety net rather than the
  /// expected path.
  Future<int> copyFromPreviousDay() async {
    if (state) return 0;
    state = true;
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final previousDay = await repository.getEntriesFor(day.addDays(-1));
      final source = [
        for (final entry in previousDay)
          if (entry.meal == meal) entry,
      ];
      if (source.isEmpty) return 0;

      final now = DateTime.now().toUtc();
      for (var i = 0; i < source.length; i++) {
        await repository.saveEntry(
          source[i].copyWith(
            id: EntityId.generate(),
            day: day,
            // A millisecond apart, in source order: entries within a meal
            // are ordered by `createdAt`, and one shared timestamp would
            // leave the copied order up to SQLite.
            createdAt: now.add(Duration(milliseconds: i)),
            updatedAt: now,
          ),
        );
      }
      return source.length;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
