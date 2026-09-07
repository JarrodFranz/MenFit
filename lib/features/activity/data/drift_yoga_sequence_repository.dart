import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence_repository.dart';

/// Drift implementation of [YogaSequenceRepository].
class DriftYogaSequenceRepository implements YogaSequenceRepository {
  const DriftYogaSequenceRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<YogaSequence>> watchSequences() {
    final query = _db.select(_db.yogaSequences)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    return query
        .watch()
        .map(
          (rows) => rows
              .map(_toEntity)
              .whereType<YogaSequence>()
              .toList(growable: false),
        )
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch yoga sequences',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<YogaSequence?> getSequence(String id) async {
    try {
      final row =
          await (_db.select(_db.yogaSequences)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull())
                ..limit(1))
              .getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to get yoga sequence',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveSequence(YogaSequence s) async {
    try {
      await _db
          .into(_db.yogaSequences)
          .insertOnConflictUpdate(
            db.YogaSequencesCompanion(
              id: Value(s.id),
              name: Value(s.name),
              description: Value(s.description),
              posesJson: Value(
                jsonEncode(s.poses.map((p) => p.toJson()).toList()),
              ),
              transitionSeconds: Value(s.transitionSeconds),
              style: Value(s.style),
              createdAt: Value(s.createdAt.toUtc().millisecondsSinceEpoch),
              updatedAt: Value(s.updatedAt.toUtc().millisecondsSinceEpoch),
              deletedAt: const Value(null),
            ),
          );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to save yoga sequence',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteSequence(String id) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.yogaSequences,
      )..where((t) => t.id.equals(id))).write(
        db.YogaSequencesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to delete yoga sequence',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      // Hard delete, soft-deleted rows included: a hidden row is not a
      // deleted one (see `settings_screen.dart`'s "Delete my data" flow).
      await _db.delete(_db.yogaSequences).go();
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to delete yoga sequences',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Maps a row, or returns null when its stored pose list cannot be parsed.
  ///
  /// A malformed blob skips the row rather than throwing: one unreadable
  /// sequence must not take the whole list down with it. Nothing about the
  /// content is logged — the row's own text could contain anything the user
  /// typed.
  static YogaSequence? _toEntity(db.YogaSequence row) {
    final List<YogaPose> poses;
    try {
      final decoded = jsonDecode(row.posesJson);
      if (decoded is! List) return null;
      poses = decoded
          .map((p) => YogaPose.fromJson(p as Map<String, dynamic>))
          .toList();
    } on Object catch (_) {
      return null;
    }

    return YogaSequence(
      id: row.id,
      name: row.name,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
      description: row.description,
      poses: poses,
      transitionSeconds: row.transitionSeconds,
      style: row.style,
    );
  }
}
