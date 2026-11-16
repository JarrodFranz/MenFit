import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/nutrition_row_mappers.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_repository.dart';

/// [NutritionRepository] backed by the `foods` and `nutrition_entries`
/// Drift tables.
///
/// The generated Drift row classes for those tables are also named `Food`
/// and `NutritionEntry`, so this file imports `app_database.dart` with the
/// `db` prefix throughout to keep them distinct from the freezed domain
/// entities of the same name (same convention as
/// `features/wellbeing/data/drift_wellbeing_repository.dart`).
///
/// The provider for this repository lives in `../nutrition_providers.dart`
/// (ADR 007), not here.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): no food
/// name, quantity, or nutrition value ever appears in a thrown
/// [AppException]'s `message` — those stay static strings, same as every
/// other repository in this codebase.
class DriftNutritionRepository implements NutritionRepository {
  DriftNutritionRepository(this._db);

  final db.AppDatabase _db;

  SimpleSelectStatement<db.$FoodsTable, db.Food> _liveFoodsQuery() {
    return _db.select(_db.foods)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
  }

  @override
  Stream<List<Food>> watchFoods() {
    return _liveFoodsQuery()
        .watch()
        .map((rows) => rows.map(foodToEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never cross
          // the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch foods',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  /// Matching happens in Dart rather than in SQL, deliberately. SQL `LIKE`
  /// would need the query's `%`/`_` escaped (and an `ESCAPE` clause drift
  /// doesn't emit) or a food legitimately named "70% dark" turns into a
  /// wildcard search, and SQLite's `LIKE` only case-folds ASCII, so
  /// accented names would match inconsistently. The catalogue this filters
  /// is the user's own hand-entered list — small enough that correctness
  /// wins outright. S1-5's cached provider products are what will make this
  /// a real query, and that is the change that should write one.
  @override
  Future<List<Food>> searchFoods(String query, {int limit = 50}) async {
    try {
      final rows = await _liveFoodsQuery().get();
      final foods = rows.map(foodToEntity);
      final needle = query.trim().toLowerCase();
      final matches = needle.isEmpty
          ? foods
          : foods.where(
              (food) =>
                  food.name.toLowerCase().contains(needle) ||
                  (food.brand?.toLowerCase().contains(needle) ?? false),
            );
      return matches.take(limit).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to search foods',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// One row per live food that has at least one entry pointing at it,
  /// carrying [aggregate] as its ordering key.
  ///
  /// An inner join collapses the two rules the callers need into the query
  /// itself: an entry with no `foodId` (quick-add) contributes no row, and a
  /// soft-deleted food is filtered out before the grouping, so a food the
  /// user removed can never resurface through their own history.
  JoinedSelectStatement<HasResultSet, dynamic> _loggedFoodsQuery({
    required Expression<Object> aggregate,
    required int limit,
    Expression<bool>? extraFilter,
  }) {
    final foodIsLive = _db.foods.deletedAt.isNull();
    return _db.select(_db.foods).join([
        innerJoin(
          _db.nutritionEntries,
          _db.nutritionEntries.foodId.equalsExp(_db.foods.id),
        ),
      ])
      ..addColumns([aggregate])
      ..where(extraFilter == null ? foodIsLive : foodIsLive & extraFilter)
      ..groupBy([_db.foods.id])
      ..orderBy([OrderingTerm.desc(aggregate)])
      ..limit(limit);
  }

  List<Food> _joinedFoods(List<TypedResult> rows) {
    return rows.map((row) => foodToEntity(row.readTable(_db.foods))).toList();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _recentFoodsQuery(int limit) {
    return _loggedFoodsQuery(
      aggregate: _db.nutritionEntries.createdAt.max(),
      limit: limit,
    );
  }

  @override
  Future<List<Food>> getRecentFoods({int limit = 20}) async {
    try {
      return _joinedFoods(await _recentFoodsQuery(limit).get());
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read recent foods',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Drift's `watch()` tracks every table the statement touches, so this
  /// re-emits on a change to `foods` **or** `nutrition_entries` — which is
  /// the whole reason the picker can use it instead of a future it would
  /// have to remember to invalidate.
  @override
  Stream<List<Food>> watchRecentFoods({int limit = 20}) {
    return _recentFoodsQuery(limit).watch().map(_joinedFoods).handleError((
      Object error,
      StackTrace stackTrace,
    ) {
      throw StorageException(
        message: 'Failed to watch recent foods',
        cause: error,
        stackTrace: stackTrace,
      );
    });
  }

  @override
  Future<List<Food>> getFrequentFoods({int limit = 20, int days = 30}) async {
    final cutoff = DateTime.now()
        .toUtc()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    try {
      final rows = await _loggedFoodsQuery(
        aggregate: _db.nutritionEntries.id.count(),
        limit: limit,
        extraFilter: _db.nutritionEntries.createdAt.isBiggerOrEqualValue(
          cutoff,
        ),
      ).get();
      return _joinedFoods(rows);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read frequent foods',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<Food?> getFood(String id) async {
    try {
      final row =
          await (_db.select(_db.foods)..where(
                (t) => t.id.equals(id) & t.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      return row == null ? null : foodToEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read food',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Indexed on `barcode` (`idx_foods_barcode`), so this stays a point
  /// lookup however large the catalogue grows — which matters because it
  /// runs on the hot path of every scan, ahead of any network call.
  ///
  /// The ordering picks the winner when several live rows share a code; see
  /// the interface's dartdoc for why the most recently updated one is the
  /// right answer.
  @override
  Future<Food?> getFoodByBarcode(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) return null;
    try {
      final row =
          await (_db.select(_db.foods)
                ..where((t) => t.barcode.equals(code) & t.deletedAt.isNull())
                ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
                ..limit(1))
              .getSingleOrNull();
      return row == null ? null : foodToEntity(row);
    } catch (e, st) {
      // Static message: a barcode is S2 data and never reaches a message
      // (`domain/barcode.dart`'s copy rules).
      throw StorageException(
        message: 'Failed to read food by barcode',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Indexed on `(source, provider_food_id)`
  /// (`idx_foods_provider_food_id`, schema v35).
  @override
  Future<Food?> getFoodByProviderId(
    FoodSource source,
    String providerFoodId,
  ) async {
    final id = providerFoodId.trim();
    if (id.isEmpty) return null;
    try {
      final row =
          await (_db.select(_db.foods)
                ..where(
                  (t) =>
                      t.source.equals(source.toStorage()) &
                      t.providerFoodId.equals(id) &
                      t.deletedAt.isNull(),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
                ..limit(1))
              .getSingleOrNull();
      return row == null ? null : foodToEntity(row);
    } catch (e, st) {
      // Static message: a provider id names a product she is about to eat
      // (S2), exactly as a barcode does.
      throw StorageException(
        message: 'Failed to read food by provider id',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveFood(Food food) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Read-then-write so `createdAt` survives an edit regardless of
        // what the caller passed in - same pattern as
        // `DriftProfileRepository.saveProfile`.
        final existing = await (_db.select(
          _db.foods,
        )..where((t) => t.id.equals(food.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            food.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.foods)
            .insertOnConflictUpdate(
              db.FoodsCompanion.insert(
                id: food.id,
                name: food.name,
                // Explicit Value(...) so clearing a field back to null is
                // actually applied - insertOnConflictUpdate leaves columns
                // absent from the companion untouched on the existing row.
                brand: Value(food.brand),
                servingDescription: food.servingDescription,
                servingGrams: Value(food.servingGrams),
                servingVolumeMl: Value(food.servingVolumeMl),
                caloriesKcal: food.perServing.caloriesKcal,
                proteinGrams: food.perServing.proteinGrams,
                carbsGrams: food.perServing.carbsGrams,
                fatGrams: food.perServing.fatGrams,
                ironMg: Value(food.perServing.ironMg),
                // Every optional nutrient is written explicitly. `null`
                // survives as `null` (unknown), never coalesced to 0 - see
                // `domain/nutrition_facts.dart`.
                saturatedFatGrams: Value(food.perServing.saturatedFatGrams),
                transFatGrams: Value(food.perServing.transFatGrams),
                monounsaturatedFatGrams: Value(
                  food.perServing.monounsaturatedFatGrams,
                ),
                polyunsaturatedFatGrams: Value(
                  food.perServing.polyunsaturatedFatGrams,
                ),
                fiberGrams: Value(food.perServing.fiberGrams),
                sugarsGrams: Value(food.perServing.sugarsGrams),
                addedSugarsGrams: Value(food.perServing.addedSugarsGrams),
                sodiumMg: Value(food.perServing.sodiumMg),
                potassiumMg: Value(food.perServing.potassiumMg),
                cholesterolMg: Value(food.perServing.cholesterolMg),
                calciumMg: Value(food.perServing.calciumMg),
                vitaminDMcg: Value(food.perServing.vitaminDMcg),
                vitaminCMg: Value(food.perServing.vitaminCMg),
                barcode: Value(food.barcode),
                source: Value(food.source.toStorage()),
                providerFoodId: Value(food.providerFoodId),
                // Re-saving a soft-deleted food restores it: an edit is an
                // intent to use the food, and leaving `deleted_at` set
                // would silently swallow the save.
                deletedAt: const Value(null),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save food',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteFood(String id) async {
    // Soft delete - see `domain/nutrition_repository.dart#deleteFood` for
    // why this one, unlike `deleteEntry`, keeps the row.
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      await (_db.update(_db.foods)..where((t) => t.id.equals(id))).write(
        db.FoodsCompanion(
          deletedAt: Value(nowMillis),
          updatedAt: Value(nowMillis),
        ),
      );
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete food',
        cause: e,
        stackTrace: st,
      );
    }
  }

  SimpleSelectStatement<db.$NutritionEntriesTable, db.NutritionEntry>
  _entriesForQuery(LocalDate day) {
    return _db.select(_db.nutritionEntries)
      ..where((t) => t.day.equals(day.toIso()))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
  }

  SimpleSelectStatement<db.$NutritionEntriesTable, db.NutritionEntry>
  _entriesForRangeQuery(LocalDate start, LocalDate end) {
    return _db.select(_db.nutritionEntries)
      ..where(
        (t) =>
            t.day.isBiggerOrEqualValue(start.toIso()) &
            t.day.isSmallerOrEqualValue(end.toIso()),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.day),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
  }

  @override
  Stream<List<NutritionEntry>> watchEntriesFor(LocalDate day) {
    return _entriesForQuery(day).watch().map(_entriesToEntities).handleError((
      Object error,
      StackTrace stackTrace,
    ) {
      throw StorageException(
        message: 'Failed to watch nutrition entries',
        cause: error,
        stackTrace: stackTrace,
      );
    });
  }

  @override
  Future<List<NutritionEntry>> getEntriesFor(LocalDate day) async {
    try {
      return _entriesToEntities(await _entriesForQuery(day).get());
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read nutrition entries',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<List<NutritionEntry>> watchEntriesForRange(
    LocalDate start,
    LocalDate end,
  ) {
    return _entriesForRangeQuery(start, end)
        .watch()
        .map(_entriesToEntities)
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch nutrition entries for range',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<NutritionEntry>> getEntriesForRange(
    LocalDate start,
    LocalDate end,
  ) async {
    try {
      return _entriesToEntities(
        await _entriesForRangeQuery(start, end).get(),
      );
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read nutrition entries for range',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveEntry(NutritionEntry entry) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        final existing = await (_db.select(
          _db.nutritionEntries,
        )..where((t) => t.id.equals(entry.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            entry.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.nutritionEntries)
            .insertOnConflictUpdate(
              db.NutritionEntriesCompanion.insert(
                id: entry.id,
                day: entry.day.toIso(),
                meal: entry.meal.toStorage(),
                foodId: Value(entry.foodId),
                foodName: entry.foodName,
                foodBrand: Value(entry.foodBrand),
                servingDescription: Value(entry.servingDescription),
                quantityServings: entry.quantityServings,
                quantityAmount: Value(entry.quantityAmount),
                quantityUnit: Value(entry.quantityUnit.toStorage()),
                // Part of the snapshot, not a lookup: the weight/volume the amount
                // above was measured against at log time.
                servingGrams: Value(entry.servingGrams),
                servingVolumeMl: Value(entry.servingVolumeMl),
                // Written exactly as given: the snapshot is never refreshed
                // from the referenced food (see the interface's dartdoc).
                caloriesKcal: entry.perServing.caloriesKcal,
                proteinGrams: entry.perServing.proteinGrams,
                carbsGrams: entry.perServing.carbsGrams,
                fatGrams: entry.perServing.fatGrams,
                ironMg: Value(entry.perServing.ironMg),
                saturatedFatGrams: Value(entry.perServing.saturatedFatGrams),
                transFatGrams: Value(entry.perServing.transFatGrams),
                monounsaturatedFatGrams: Value(
                  entry.perServing.monounsaturatedFatGrams,
                ),
                polyunsaturatedFatGrams: Value(
                  entry.perServing.polyunsaturatedFatGrams,
                ),
                fiberGrams: Value(entry.perServing.fiberGrams),
                sugarsGrams: Value(entry.perServing.sugarsGrams),
                addedSugarsGrams: Value(entry.perServing.addedSugarsGrams),
                sodiumMg: Value(entry.perServing.sodiumMg),
                potassiumMg: Value(entry.perServing.potassiumMg),
                cholesterolMg: Value(entry.perServing.cholesterolMg),
                calciumMg: Value(entry.perServing.calciumMg),
                vitaminDMcg: Value(entry.perServing.vitaminDMcg),
                vitaminCMg: Value(entry.perServing.vitaminCMg),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save nutrition entry',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    // Hard delete - see `domain/nutrition_repository.dart#deleteEntry`.
    try {
      await (_db.delete(
        _db.nutritionEntries,
      )..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete nutrition entry',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        // Entries first: they reference foods (by plain id, no FK, but the
        // ordering keeps the intermediate state coherent for anything
        // watching).
        await _db.delete(_db.nutritionEntries).go();
        await _db.delete(_db.foods).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete nutrition data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Maps rows (already ordered by `createdAt`) into entities grouped by
  /// meal, in [MealType.values] order.
  ///
  /// The meal ordering is applied here rather than in SQL because the
  /// meal's *storage* form is a string, so `ORDER BY meal` would sort
  /// alphabetically (breakfast, dinner, lunch, snack) instead of by the
  /// order meals actually happen. A day's entries are few, so grouping in
  /// Dart is cheaper than teaching SQL the enum's order — and unlike
  /// `List.sort`, which is not stable, this preserves logging order
  /// within each meal exactly.
  List<NutritionEntry> _entriesToEntities(List<db.NutritionEntry> rows) {
    final entities = rows.map(entryToEntity).toList();
    return [
      for (final meal in MealType.values)
        ...entities.where((entry) => entry.meal == meal),
    ];
  }
}
