import 'package:drift/drift.dart';

/// Logs of daily water intake (milliliters), captured on a calendar day.
@TableIndex(name: 'idx_water_logs_day', columns: {#day})
class WaterLogs extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  TextColumn get day => text()();

  /// Water volume in milliliters (e.g. 250 for 1 cup / glass).
  IntColumn get milliliters => integer()();

  /// Timestamp when logged (UTC).
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
