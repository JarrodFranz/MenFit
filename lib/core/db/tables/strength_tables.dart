import 'package:drift/drift.dart';

/// Drift table for user-created and standard single-day strength workout
/// routines.
class StrengthRoutines extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  /// Serialized JSON list of strength exercise templates.
  TextColumn get exercisesJson => text()();

  IntColumn get estimatedDurationMinutes =>
      integer().withDefault(const Constant(45))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete.
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift table for multi-day strength training cycles / mesocycle programs.
class StrengthCycles extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  /// Serialized JSON list of day routines.
  TextColumn get routinesJson => text()();

  /// Pointer to the active routine index in the cycle (0 -> 1 -> ...).
  IntColumn get currentDayIndex => integer().withDefault(const Constant(0))();

  IntColumn get totalSessionsCompleted =>
      integer().withDefault(const Constant(0))();

  RealColumn get totalVolumeLiftedKg => real().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  /// UTC milliseconds since epoch.
  IntColumn get startedAt => integer().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get lastCompletedAt => integer().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete.
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
