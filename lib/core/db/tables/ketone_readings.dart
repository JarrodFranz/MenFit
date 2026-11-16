import 'package:drift/drift.dart';

/// Manual S3 measurements, hard-deleted. No interpretation or shared scale.
@TableIndex(name: 'idx_ketone_readings_day', columns: {#day})
class KetoneReadings extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();
  IntColumn get measuredAt => integer()();
  TextColumn get type => text()();
  TextColumn get result => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
