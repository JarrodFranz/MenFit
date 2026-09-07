import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_repository.dart';

/// [WeightRepository] backed by the `weight_logs` Drift table.
///
/// The generated Drift row class for that table is also named `WeightLog`,
/// so this file imports `app_database.dart` with the `db` prefix throughout
/// to keep it distinct from the freezed domain entity of the same name
/// (same convention as `features/profile/data/drift_profile_repository.dart`
/// and `features/wellbeing/data/drift_wellbeing_repository.dart`).
///
/// Every `watch`/`get` pair shares one query builder, so the stream and the
/// one-shot read can never drift apart in filter or ordering — the reason
/// the one-shot variants exist at all is that
/// `await watchX().first` deadlocks widget tests (central
/// `testing-pitfalls.md`, 2026-09-01), and a second hand-written query
/// would reintroduce the divergence risk the pattern is meant to avoid.
///
/// The provider for this repository lives in `../weight_providers.dart`
/// (ADR 007), not here.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): no
/// weight value, note, or day ever appears in a thrown [AppException]'s
/// `message` — those stay static strings, same as every other repository
/// in this codebase.
class DriftWeightRepository implements WeightRepository {
  const DriftWeightRepository(this._db);

  final db.AppDatabase _db;

  /// Chronological ordering, applied to every list query here — see
  /// `domain/weight_repository.dart`'s class doc for why oldest-first, and
  /// why `createdAt`/`id` break the ties within a day.
  List<OrderClauseGenerator<db.$WeightLogsTable>> get _chronological => [
    (t) => OrderingTerm.asc(t.day),
    (t) => OrderingTerm.asc(t.createdAt),
    (t) => OrderingTerm.asc(t.id),
  ];

  Selectable<db.WeightLog> _rangeQuery(LocalDate start, LocalDate end) {
    // Day strings are ISO-8601 (`YYYY-MM-DD`), so lexical comparison is
    // chronological comparison — the same trick every other day-keyed
    // query in this codebase relies on.
    return _db.select(_db.weightLogs)
      ..where(
        (t) =>
            t.day.isBiggerOrEqualValue(start.toIso()) &
            t.day.isSmallerOrEqualValue(end.toIso()),
      )
      ..orderBy(_chronological);
  }

  Selectable<db.WeightLog> _recentQuery(int days, LocalDate today) {
    final windowStart = today.addDays(-(days - 1));
    return _rangeQuery(windowStart, today);
  }

  Selectable<db.WeightLog> _latestQuery() {
    return _db.select(_db.weightLogs)
      ..orderBy([
        (t) => OrderingTerm.desc(t.day),
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1);
  }

  @override
  Stream<List<WeightLog>> watchLogsForRange(LocalDate start, LocalDate end) {
    return _rangeQuery(start, end)
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch weight logs for range',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<WeightLog>> getLogsForRange(
    LocalDate start,
    LocalDate end,
  ) async {
    try {
      final rows = await _rangeQuery(start, end).get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read weight logs for range',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<List<WeightLog>> watchRecentLogs(int days, LocalDate today) {
    return _recentQuery(days, today)
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch recent weight logs',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<WeightLog>> getRecentLogs(int days, LocalDate today) async {
    try {
      final rows = await _recentQuery(days, today).get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read recent weight logs',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<WeightLog?> watchLatestLog() {
    return _latestQuery()
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch latest weight log',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<WeightLog?> getLatestLog() async {
    try {
      final row = await _latestQuery().getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read latest weight log',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveLog(WeightLog log) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Read-then-write so `createdAt` survives an update regardless of
        // what the caller passed in - same contract (and same reasoning)
        // as `DriftProfileRepository.saveProfile`.
        final existing = await (_db.select(
          _db.weightLogs,
        )..where((t) => t.id.equals(log.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ?? log.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.weightLogs)
            .insertOnConflictUpdate(
              db.WeightLogsCompanion.insert(
                id: log.id,
                day: log.day.toIso(),
                weightKg: log.weightKg,
                // Explicit Value(...) so clearing the note back to null is
                // actually applied - insertOnConflictUpdate leaves columns
                // absent from the companion untouched on the existing row.
                notes: Value(log.notes),
                source: Value(log.source.toStorage()),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save weight log',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    try {
      await (_db.delete(_db.weightLogs)..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete weight log',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.delete(_db.weightLogs).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete weight data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  WeightLog _toEntity(db.WeightLog row) {
    return WeightLog(
      id: row.id,
      day: LocalDate.parse(row.day),
      weightKg: row.weightKg,
      notes: row.notes,
      source: WeightLogSource.fromStorage(row.source),
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
