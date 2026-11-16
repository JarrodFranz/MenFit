import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/domain/health_reading_validation.dart';
import 'package:menfit_app/features/health/domain/health_readings_repository.dart';

/// Mirrors `DriftKetoneRepository`: validate before write, revalidate on
/// read, and every failure becomes a static-message [StorageException] with
/// no cause, because SQLite errors may carry bound S3 values. Nothing logs.
class DriftHealthReadingsRepository implements HealthReadingsRepository {
  const DriftHealthReadingsRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<BloodPressureReading>> watchBloodPressure({DateTime? since}) {
    final query = _db.select(_db.bloodPressureReadings)
      ..orderBy([
        (t) => OrderingTerm.desc(t.measuredAt),
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (since != null) {
      query.where(
        (t) => t.measuredAt.isBiggerOrEqualValue(since.millisecondsSinceEpoch),
      );
    }
    return query
        .watch()
        .map((rows) => rows.map(_toBloodPressure).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw const StorageException(
            message: 'Failed to read blood pressure readings',
          );
        });
  }

  @override
  Future<void> saveBloodPressure(BloodPressureReading reading) async {
    if (!isValidBloodPressureReading(reading)) {
      throw const ValidationException(
        message: 'Invalid blood pressure reading',
      );
    }
    try {
      await _db.transaction(() async {
        final existing = await (_db.select(
          _db.bloodPressureReadings,
        )..where((t) => t.id.equals(reading.id))).getSingleOrNull();
        final createdAt =
            existing?.createdAt ?? reading.createdAt.millisecondsSinceEpoch;
        await _db
            .into(_db.bloodPressureReadings)
            .insertOnConflictUpdate(
              db.BloodPressureReadingsCompanion.insert(
                id: reading.id,
                day: reading.day.toIso(),
                measuredAt: reading.measuredAt.millisecondsSinceEpoch,
                systolic: reading.systolic,
                diastolic: reading.diastolic,
                pulse: Value(reading.pulse),
                note: Value(reading.note),
                createdAt: createdAt,
                updatedAt: _updatedAt(createdAt),
              ),
            );
      });
    } on Object {
      throw const StorageException(
        message: 'Failed to save blood pressure reading',
      );
    }
  }

  @override
  Future<void> deleteBloodPressure(String id) async {
    try {
      await (_db.delete(
        _db.bloodPressureReadings,
      )..where((t) => t.id.equals(id))).go();
    } on Object {
      throw const StorageException(
        message: 'Failed to delete blood pressure reading',
      );
    }
  }

  @override
  Stream<List<BloodMarkerReading>> watchBloodMarker(
    BloodMarker marker, {
    DateTime? since,
  }) {
    final query = _db.select(_db.bloodMarkerReadings)
      ..where((t) => t.marker.equals(marker.toStorage()))
      ..orderBy([
        (t) => OrderingTerm.desc(t.measuredAt),
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (since != null) {
      query.where(
        (t) => t.measuredAt.isBiggerOrEqualValue(since.millisecondsSinceEpoch),
      );
    }
    return query
        .watch()
        .map((rows) => rows.map(_toBloodMarker).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw const StorageException(
            message: 'Failed to read blood readings',
          );
        });
  }

  @override
  Future<void> saveBloodMarker(BloodMarkerReading reading) async {
    if (!isValidBloodMarkerReading(reading)) {
      throw const ValidationException(message: 'Invalid blood reading');
    }
    try {
      await _db.transaction(() async {
        final existing = await (_db.select(
          _db.bloodMarkerReadings,
        )..where((t) => t.id.equals(reading.id))).getSingleOrNull();
        final createdAt =
            existing?.createdAt ?? reading.createdAt.millisecondsSinceEpoch;
        await _db
            .into(_db.bloodMarkerReadings)
            .insertOnConflictUpdate(
              db.BloodMarkerReadingsCompanion.insert(
                id: reading.id,
                day: reading.day.toIso(),
                measuredAt: reading.measuredAt.millisecondsSinceEpoch,
                marker: reading.marker.toStorage(),
                value: reading.value,
                unit: reading.unit.toStorage(),
                context: Value(reading.context?.toStorage()),
                note: Value(reading.note),
                createdAt: createdAt,
                updatedAt: _updatedAt(createdAt),
              ),
            );
      });
    } on Object {
      throw const StorageException(message: 'Failed to save blood reading');
    }
  }

  @override
  Future<void> deleteBloodMarker(String id) async {
    try {
      await (_db.delete(
        _db.bloodMarkerReadings,
      )..where((t) => t.id.equals(id))).go();
    } on Object {
      throw const StorageException(message: 'Failed to delete blood reading');
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.bloodPressureReadings).go();
        await _db.delete(_db.bloodMarkerReadings).go();
      });
    } on Object {
      throw const StorageException(message: 'Failed to delete health data');
    }
  }

  /// Preserves chronology if the device clock was corrected.
  static int _updatedAt(int createdAt) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return now < createdAt ? createdAt : now;
  }

  static DateTime _utc(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  BloodPressureReading _toBloodPressure(db.BloodPressureReading row) {
    final reading = BloodPressureReading(
      id: row.id,
      day: LocalDate.parse(row.day),
      measuredAt: _utc(row.measuredAt),
      systolic: row.systolic,
      diastolic: row.diastolic,
      pulse: row.pulse,
      note: row.note,
      createdAt: _utc(row.createdAt),
      updatedAt: _utc(row.updatedAt),
    );
    if (!isValidBloodPressureReading(reading)) {
      throw const StorageException(
        message: 'Invalid stored blood pressure reading',
      );
    }
    return reading;
  }

  BloodMarkerReading _toBloodMarker(db.BloodMarkerReading row) {
    final context = row.context;
    final reading = BloodMarkerReading(
      id: row.id,
      day: LocalDate.parse(row.day),
      measuredAt: _utc(row.measuredAt),
      marker: BloodMarker.fromStorage(row.marker),
      value: row.value,
      unit: BloodMarkerUnit.fromStorage(row.unit),
      context: context == null ? null : GlucoseContext.fromStorage(context),
      note: row.note,
      createdAt: _utc(row.createdAt),
      updatedAt: _utc(row.updatedAt),
    );
    if (!isValidBloodMarkerReading(reading)) {
      throw const StorageException(message: 'Invalid stored blood reading');
    }
    return reading;
  }
}
