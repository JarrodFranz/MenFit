import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';
import 'package:menfit_app/features/keto/domain/ketone_repository.dart';
import 'package:menfit_app/features/keto/domain/ketone_validation.dart';

class DriftKetoneRepository implements KetoneRepository {
  const DriftKetoneRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<KetoneReading>> watchReadingsForDay(LocalDate day) {
    return (_db.select(_db.ketoneReadings)
          ..where((t) => t.day.equals(day.toIso()))
          ..orderBy([
            (t) => OrderingTerm.asc(t.measuredAt),
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // SQLite errors may contain bound S3 values; never retain the cause.
          throw const StorageException(message: 'Failed to read ketone logs');
        });
  }

  @override
  Future<void> saveReading(KetoneReading reading) async {
    if (!isValidKetoneReading(reading)) {
      throw const ValidationException(message: 'Invalid ketone reading');
    }
    try {
      await _db.transaction(() async {
        final existing = await (_db.select(
          _db.ketoneReadings,
        )..where((t) => t.id.equals(reading.id))).getSingleOrNull();
        final createdAt =
            existing?.createdAt ?? reading.createdAt.millisecondsSinceEpoch;
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await _db
            .into(_db.ketoneReadings)
            .insertOnConflictUpdate(
              db.KetoneReadingsCompanion.insert(
                id: reading.id,
                day: reading.day.toIso(),
                measuredAt: reading.measuredAt.millisecondsSinceEpoch,
                type: reading.type.toStorage(),
                result: reading.result,
                createdAt: createdAt,
                // Preserve chronology if the device clock was corrected.
                updatedAt: now < createdAt ? createdAt : now,
              ),
            );
      });
    } on Object {
      throw const StorageException(message: 'Failed to save ketone reading');
    }
  }

  @override
  Future<void> deleteReading(String id) async {
    try {
      await (_db.delete(
        _db.ketoneReadings,
      )..where((t) => t.id.equals(id))).go();
    } on Object {
      throw const StorageException(message: 'Failed to delete ketone reading');
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.delete(_db.ketoneReadings).go();
    } on Object {
      throw const StorageException(message: 'Failed to delete ketone data');
    }
  }

  KetoneReading _toEntity(db.KetoneReading row) {
    final reading = KetoneReading(
      id: row.id,
      day: LocalDate.parse(row.day),
      measuredAt: DateTime.fromMillisecondsSinceEpoch(
        row.measuredAt,
        isUtc: true,
      ),
      type: KetoneMeasurementType.fromStorage(row.type),
      result: row.result,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
    if (!isValidKetoneReading(reading)) {
      throw const StorageException(message: 'Invalid stored ketone reading');
    }
    return reading;
  }
}
