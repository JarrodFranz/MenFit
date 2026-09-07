import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/steps/domain/daily_steps.dart';
import 'package:menfit_app/features/steps/domain/steps_repository.dart';

/// [StepsRepository] backed by the `daily_step_totals` Drift table.
///
/// `app_database.dart` is imported with the `db` prefix throughout, the same
/// convention as `features/weight/data/drift_weight_repository.dart` — the
/// generated row class (`DailyStepTotal`) is one letter away from the
/// platform adapter's own `DailyStepTotal` in
/// `core/platform/health/health_data_snapshot.dart`, and the prefix keeps
/// which is which unambiguous at every use.
///
/// The `watch`/`get` pair shares one query builder, so the stream and the
/// one-shot read can never drift apart in filter or ordering. The one-shot
/// variant exists because `await watchX().first` deadlocks widget tests
/// (central `testing-pitfalls.md`, 2026-09-01), and a second hand-written
/// query would reintroduce exactly the divergence the shared builder avoids.
///
/// The provider for this repository lives in `../steps_providers.dart`
/// (ADR 007), not here.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): no step
/// count or day ever appears in a thrown [AppException]'s `message` — those
/// stay static strings, same as every other repository in this codebase.
class DriftStepsRepository implements StepsRepository {
  const DriftStepsRepository(this._db);

  final db.AppDatabase _db;

  Selectable<db.DailyStepTotal> _rangeQuery(LocalDate start, LocalDate end) {
    // Day strings are ISO-8601 (`YYYY-MM-DD`), so lexical comparison is
    // chronological comparison — the same trick every other day-keyed query
    // in this codebase relies on.
    return _db.select(_db.dailyStepTotals)
      ..where(
        (t) =>
            t.day.isBiggerOrEqualValue(start.toIso()) &
            t.day.isSmallerOrEqualValue(end.toIso()),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.day)]);
  }

  @override
  Stream<List<DailySteps>> watchRange(LocalDate start, LocalDate end) {
    return _rangeQuery(start, end)
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never cross
          // the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch daily step totals for range',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<DailySteps>> getRange(LocalDate start, LocalDate end) async {
    try {
      final rows = await _rangeQuery(start, end).get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read daily step totals for range',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> upsertMany(List<DailySteps> rows) async {
    if (rows.isEmpty) return;
    try {
      await _db.transaction(() async {
        for (final row in rows) {
          // `day` is the table's primary key, so `insertOnConflictUpdate`
          // resolves the conflict by day with no explicit target — which is
          // the whole reason the key is the day rather than a UUID (see
          // `core/db/tables/daily_step_totals.dart`).
          await _db
              .into(_db.dailyStepTotals)
              .insertOnConflictUpdate(
                db.DailyStepTotalsCompanion.insert(
                  day: row.day.toIso(),
                  steps: row.steps,
                  // Explicit `Value(...)` so a re-sync that can no longer
                  // name the source actually clears it: columns absent from
                  // the companion are left untouched on the existing row.
                  source: Value(row.source),
                  syncedAt: row.syncedAt.toUtc().millisecondsSinceEpoch,
                ),
              );
        }
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save daily step totals',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.delete(_db.dailyStepTotals).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete daily step totals',
        cause: e,
        stackTrace: st,
      );
    }
  }

  DailySteps _toEntity(db.DailyStepTotal row) {
    return DailySteps(
      day: LocalDate.parse(row.day),
      steps: row.steps,
      source: row.source,
      syncedAt: DateTime.fromMillisecondsSinceEpoch(row.syncedAt, isUtc: true),
    );
  }
}
