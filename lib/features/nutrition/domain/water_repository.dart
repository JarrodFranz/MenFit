import 'package:menfit_app/core/domain/local_date.dart';

/// Contract for daily hydration and water intake tracking.
abstract class WaterRepository {
  /// Watches the total water intake in milliliters for [day].
  Stream<int> watchWaterForDay(LocalDate day);

  /// Logs [milliliters] of water intake for [day].
  Future<void> logWater({
    required LocalDate day,
    required int milliliters,
  });

  /// Removes up to [milliliters] of logged water for [day].
  Future<void> removeWater({
    required LocalDate day,
    required int milliliters,
  });

  /// Resets all logged water for [day].
  Future<void> resetWaterForDay(LocalDate day);

  /// One-shot fetch of total milliliters logged per day within [start] and
  /// [end] inclusive.
  ///
  /// A day with **no** logged water is omitted from the map entirely,
  /// never present with a manufactured `0` entry — the same "absence over
  /// a zero" discipline as `domain/nutrition_facts.dart`'s `ironMg`. This
  /// is what lets a caller (e.g.
  /// `features/recaps/domain/recap_builder.dart`'s hydration-consistency
  /// score) tell "never logged that day" apart from "logged, and it came
  /// to zero" — the latter can't actually happen (`logWater` no-ops for
  /// non-positive milliliters) but the map shape stays honest regardless.
  Future<Map<LocalDate, int>> getWaterTotalsForRange(
    LocalDate start,
    LocalDate end,
  );

  /// Hard-deletes every logged water entry on this device — part of the
  /// "Delete my data" flow
  /// (`features/settings/presentation/settings_screen.dart`). There is no
  /// soft-delete column on `water_logs` to leave a row hiding in (see
  /// `core/db/tables/water_logs.dart`).
  Future<void> deleteAllData();
}
