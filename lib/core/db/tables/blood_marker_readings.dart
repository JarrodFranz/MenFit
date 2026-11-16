import 'package:drift/drift.dart';

/// Manual S3 blood-test results, hard-deleted. One row per result; the
/// marker column selects the kind so a new marker needs no new table.
@TableIndex(
  name: 'idx_blood_marker_readings_marker_measured_at',
  columns: {#marker, #measuredAt},
)
class BloodMarkerReadings extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();
  IntColumn get measuredAt => integer()();
  TextColumn get marker => text()(); // BloodMarker.toStorage(), e.g. 'glucose'
  RealColumn get value => real()(); // as entered
  TextColumn get unit => text()(); // BloodMarkerUnit.toStorage(), e.g. 'mmol/L'
  TextColumn get context => text().nullable()(); // GlucoseContext.toStorage()
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
