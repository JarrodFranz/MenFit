import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_repository.dart';

/// [NutritionGoalsRepository] backed by the `nutrition_goals` Drift table.
///
/// The generated Drift row class for that table is named `NutritionGoal`
/// (singular) while the freezed domain entity is `NutritionGoals`, so this
/// file uses the `db` prefix throughout rather than relying on that one
/// letter to keep them apart.
///
/// Single-row semantics, the same shape as
/// `features/profile/data/drift_profile_repository.dart`: reads resolve to
/// the earliest-created live row (`ORDER BY created_at ASC, id ASC LIMIT 1`
/// — the secondary `id` ordering only matters if two rows ever shared a
/// `createdAt` millisecond, and makes that case deterministic rather than
/// storage-order-dependent); [saveGoals] upserts by primary key.
///
/// The provider for this repository lives in `../nutrition_providers.dart`
/// (ADR 007), not here.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): no
/// target value ever appears in a thrown [AppException]'s `message`.
class DriftNutritionGoalsRepository implements NutritionGoalsRepository {
  const DriftNutritionGoalsRepository(this._db);

  final db.AppDatabase _db;

  Selectable<db.NutritionGoal> _primaryGoalsQuery() {
    return _db.select(_db.nutritionGoals)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.id),
      ])
      ..limit(1);
  }

  @override
  Stream<NutritionGoals?> watchGoals() {
    return _primaryGoalsQuery()
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never cross
          // the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch nutrition goals',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<NutritionGoals?> getGoals() async {
    try {
      final row = await _primaryGoalsQuery().getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read nutrition goals',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveGoals(NutritionGoals goals) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Read-then-write so `createdAt` survives an update regardless of
        // what the caller passed in.
        final existing = await (_db.select(
          _db.nutritionGoals,
        )..where((t) => t.id.equals(goals.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            goals.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.nutritionGoals)
            .insertOnConflictUpdate(
              db.NutritionGoalsCompanion.insert(
                id: goals.id,
                // Explicit Value(...) on every nullable column so clearing a
                // target back to "not set" is actually applied -
                // insertOnConflictUpdate leaves columns absent from the
                // companion untouched on the existing row.
                calorieTargetKcal: Value(goals.calorieTargetKcal),
                proteinTargetGrams: Value(goals.proteinTargetGrams),
                carbTargetGrams: Value(goals.carbTargetGrams),
                fatTargetGrams: Value(goals.fatTargetGrams),
                macroTargetMode: Value(goals.macroTargetMode.toStorage()),
                proteinTargetPercent: Value(goals.proteinTargetPercent),
                carbTargetPercent: Value(goals.carbTargetPercent),
                fatTargetPercent: Value(goals.fatTargetPercent),
                macroLocks: Value(goals.macroLocks.toStorage()),
                hideCalorieNumbers: Value(goals.hideCalorieNumbers),
                activityLevel: Value(goals.activityLevel?.toStorage()),
                weightGoal: Value(goals.weightGoal.toStorage()),
                dailyDeficitKcal: Value(goals.dailyDeficitKcal),
                deletedAt: const Value(null),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save nutrition goals',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.nutritionGoals).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete nutrition goals',
        cause: e,
        stackTrace: st,
      );
    }
  }

  NutritionGoals _toEntity(db.NutritionGoal row) {
    return NutritionGoals(
      id: row.id,
      calorieTargetKcal: row.calorieTargetKcal,
      proteinTargetGrams: row.proteinTargetGrams,
      carbTargetGrams: row.carbTargetGrams,
      fatTargetGrams: row.fatTargetGrams,
      macroTargetMode: MacroTargetMode.fromStorage(row.macroTargetMode),
      proteinTargetPercent: row.proteinTargetPercent,
      carbTargetPercent: row.carbTargetPercent,
      fatTargetPercent: row.fatTargetPercent,
      macroLocks: MacroLocks.fromStorage(row.macroLocks),
      hideCalorieNumbers: row.hideCalorieNumbers,
      activityLevel: ActivityLevel.fromStorage(row.activityLevel),
      weightGoal: WeightGoal.fromStorage(row.weightGoal),
      dailyDeficitKcal: row.dailyDeficitKcal,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
  }
}
