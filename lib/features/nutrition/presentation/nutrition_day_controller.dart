import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nutrition_day_controller.g.dart';

/// Which calendar day the diary is showing.
///
/// Starts at today and never moves past it: `validateNutritionEntry` rejects
/// a future day, so offering one would be offering a dead end. Browsing
/// backwards is unbounded — an empty past day is a perfectly good answer.
@riverpod
class SelectedNutritionDay extends _$SelectedNutritionDay {
  @override
  LocalDate build() {
    return ref.watch(localDayProvider).value ?? LocalDate.today();
  }

  /// Selects [day], clamped to today. Silently clamping rather than
  /// rejecting is right here because nothing the user can press asks for a
  /// future day — this only guards a stale in-memory day across midnight.
  void select(LocalDate day) {
    final today = ref.read(localDayProvider).value ?? LocalDate.today();
    state = day.isAfter(today) ? today : day;
  }

  void previousDay() => select(state.addDays(-1));

  void nextDay() => select(state.addDays(1));

  void goToToday() =>
      select(ref.read(localDayProvider).value ?? LocalDate.today());
}
