import 'dart:async';

import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/domain/recovery_repository.dart';
import 'package:menfit_app/features/streaks/domain/recovery_validation.dart';

/// [RecoveryRepository] backed by the `recovery_days` Drift table.
///
/// The generated Drift row class for that table is also named
/// `RecoveryDay`, so this file imports `app_database.dart` with the `db`
/// prefix throughout — same convention as
/// `features/cycle/data/drift_cycle_repository.dart`.
///
/// The provider for this repository lives in `../streaks_providers.dart`
/// (ADR 007), not here.
///
/// Unlike [RecoveryRepository.markRecoveryDay]'s callers elsewhere in the
/// codebase (which build a full domain entity with a client-generated id
/// before calling `saveX`), this repository's interface takes only a
/// [LocalDate] — there's no dedicated form/controller for marking a
/// recovery day, so id generation happens here instead.
class DriftRecoveryRepository implements RecoveryRepository {
  DriftRecoveryRepository(this._db);

  final db.AppDatabase _db;

  Selectable<db.RecoveryDay> _activeQuery() {
    return _db.select(_db.recoveryDays)..where((t) => t.deletedAt.isNull());
  }

  @override
  Stream<Set<LocalDate>> watchRecoveryDays() {
    return _activeQuery()
        .watch()
        .map((rows) => rows.map((row) => LocalDate.parse(row.day)).toSet())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch recovery days',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Stream<List<RecoveryDayEntry>> watchRecoveryDayEntries() {
    final query = _db.select(_db.recoveryDays)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.day)]);
    return query
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => RecoveryDayEntry(
                  day: LocalDate.parse(row.day),
                  note: row.note,
                ),
              )
              .toList(),
        )
        .handleError((Object error, StackTrace stackTrace) {
          // Same "raw platform exception must never cross the repository
          // boundary" reasoning as [watchRecoveryDays] above.
          throw StorageException(
            message: 'Failed to watch recovery days',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<void> markRecoveryDay(LocalDate day, {String? note}) {
    // The degenerate single-day range - no separate upsert path to keep in
    // sync (see `domain/recovery_repository.dart`'s dartdoc). A one-day
    // range validates identically to `validateRecoveryDay`, so existing
    // callers see exactly the same ValidationException message as before.
    return markRecoveryDays(day, day, note: note);
  }

  @override
  Future<void> markRecoveryDays(
    LocalDate from,
    LocalDate to, {
    String? note,
  }) async {
    final validation = validateRecoveryDayRange(
      from: from,
      to: to,
      today: LocalDate.today(),
    );
    if (!validation.isValid) {
      throw ValidationException(message: validation.rangeError!);
    }

    final now = DateTime.now().toUtc();
    try {
      // One transaction for the whole range: a failure part-way through
      // rolls back every day, never leaving a half-marked stretch.
      await _db.transaction(() async {
        for (var day = from; !day.isAfter(to); day = day.addDays(1)) {
          await _upsertRecoveryDay(day, note: note, now: now);
        }
      });
    } catch (e, st) {
      // S3-adjacent: static message only, never the day values.
      throw StorageException(
        message: 'Failed to save recovery day',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Upserts one day's recovery record BY DAY, not by id (see
  /// `domain/recovery_repository.dart`'s dartdoc) — the existing row's
  /// id/createdAt survive a re-mark of a day that was already marked.
  /// Callers run this inside a transaction they own.
  Future<void> _upsertRecoveryDay(
    LocalDate day, {
    required String? note,
    required DateTime now,
  }) async {
    final existing = await (_db.select(
      _db.recoveryDays,
    )..where((t) => t.day.equals(day.toIso()))).getSingleOrNull();
    final id = existing?.id ?? EntityId.generate();
    final createdAtMillis = existing?.createdAt ?? now.millisecondsSinceEpoch;

    await _db
        .into(_db.recoveryDays)
        .insertOnConflictUpdate(
          db.RecoveryDaysCompanion.insert(
            id: id,
            day: day.toIso(),
            note: Value(note),
            createdAt: createdAtMillis,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<void> unmarkRecoveryDay(LocalDate day) => unmarkRecoveryDays(day, day);

  @override
  Future<void> unmarkRecoveryDays(LocalDate from, LocalDate to) async {
    // Hard delete, not soft - same reasoning as
    // `DriftCycleRepository.deleteRecord` for this health-adjacent data
    // class: this app has no multi-device sync yet, so ADR 004's
    // soft-delete convention (which exists to support sync tombstones)
    // doesn't apply, and a "deleted" recovery day that's still forensically
    // recoverable on-device contradicts the "Undo" affordance's implicit
    // promise that un-marking actually removes the record.
    try {
      await _db.transaction(() async {
        // `day` is zero-padded ISO-8601, so SQLite's lexicographic BETWEEN
        // is exactly a chronological inclusive range. An inverted range
        // matches nothing, which is the documented no-op.
        await (_db.delete(_db.recoveryDays)..where(
              (t) =>
                  t.day.isBiggerOrEqualValue(from.toIso()) &
                  t.day.isSmallerOrEqualValue(to.toIso()),
            ))
            .go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to remove recovery day',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.recoveryDays).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete recovery day data',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
