import 'package:drift/drift.dart';

/// Manual S3 measurements, hard-deleted.
@TableIndex(
  name: 'idx_blood_pressure_readings_measured_at',
  columns: {#measuredAt},
)
class BloodPressureReadings extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()(); // local date at entry, ISO
  IntColumn get measuredAt => integer()(); // epoch ms, UTC
  IntColumn get systolic => integer()(); // mmHg
  IntColumn get diastolic => integer()(); // mmHg
  IntColumn get pulse => integer().nullable()(); // bpm
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
