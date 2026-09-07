import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/domain/water_repository.dart';

/// Drift implementation of [WaterRepository].
class DriftWaterRepository implements WaterRepository {
  DriftWaterRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<int> watchWaterForDay(LocalDate day) {
    final query = _db.select(_db.waterLogs)
      ..where((t) => t.day.equals(day.toIso()));
    return query
        .watch()
        .map((rows) => rows.fold<int>(0, (sum, row) => sum + row.milliliters))
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch daily water intake',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<void> logWater({
    required LocalDate day,
    required int milliliters,
  }) async {
    if (milliliters <= 0) return;
    try {
      await _db
          .into(_db.waterLogs)
          .insert(
            db.WaterLogsCompanion.insert(
              id: EntityId.generate(),
              day: day.toIso(),
              milliliters: milliliters,
              createdAt: DateTime.now().toUtc(),
            ),
          );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to log water intake',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> removeWater({
    required LocalDate day,
    required int milliliters,
  }) async {
    if (milliliters <= 0) return;
    try {
      final entries =
          await (_db.select(_db.waterLogs)
                ..where((t) => t.day.equals(day.toIso()))
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
              .get();

      var remainingToRemove = milliliters;
      for (final entry in entries) {
        if (remainingToRemove <= 0) break;
        if (entry.milliliters <= remainingToRemove) {
          await (_db.delete(
            _db.waterLogs,
          )..where((t) => t.id.equals(entry.id))).go();
          remainingToRemove -= entry.milliliters;
        } else {
          await (_db.update(
            _db.waterLogs,
          )..where((t) => t.id.equals(entry.id))).write(
            db.WaterLogsCompanion(
              milliliters: Value(entry.milliliters - remainingToRemove),
            ),
          );
          remainingToRemove = 0;
        }
      }
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to remove water intake',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetWaterForDay(LocalDate day) async {
    try {
      await (_db.delete(
        _db.waterLogs,
      )..where((t) => t.day.equals(day.toIso()))).go();
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to reset water intake for day',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<LocalDate, int>> getWaterTotalsForRange(
    LocalDate start,
    LocalDate end,
  ) async {
    try {
      final query = _db.select(_db.waterLogs)
        ..where(
          (t) =>
              t.day.isBiggerOrEqualValue(start.toIso()) &
              t.day.isSmallerOrEqualValue(end.toIso()),
        );
      final rows = await query.get();

      final totalsByDay = <String, int>{};
      for (final row in rows) {
        totalsByDay[row.day] = (totalsByDay[row.day] ?? 0) + row.milliliters;
      }

      return {
        for (final entry in totalsByDay.entries)
          LocalDate.parse(entry.key): entry.value,
      };
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to read water intake totals for range',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      // Hard delete - `water_logs` has no soft-delete column (see
      // `core/db/tables/water_logs.dart`), so there is nothing to purge
      // beyond the rows themselves.
      await _db.delete(_db.waterLogs).go();
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to delete water logs',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
