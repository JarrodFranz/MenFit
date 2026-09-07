import 'package:drift/drift.dart';

/// A user-logged life event (e.g. intimacy, injury, holiday, or custom) — see
/// `features/wellbeing/domain/wellbeing_event.dart`.
///
/// [day] is stored as an ISO-8601 date string (`YYYY-MM-DD`), user-local
/// calendar day, consistent with `daily_checkins.dart` and `flare_events.dart`.
///
/// [type] is stored as `'intimacy'`, `'injury'`, `'holiday'`, or `'other'`.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): never logged,
/// hard-deleted, wiped during "Delete My Data".
class WellbeingEvents extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  TextColumn get day => text()();

  /// Persisted as `'intimacy'`, `'injury'`, `'holiday'`, or `'other'`.
  TextColumn get type => text()();

  /// Display title for the event (e.g. "Intimacy", "Sprained Ankle", "Hawaii").
  TextColumn get title => text()();

  /// Whether saved to the user's reusable custom templates.
  BoolColumn get isCustomSaved =>
      boolean().withDefault(const Constant(false))();

  /// Optional free-text notes.
  TextColumn get notes => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live.
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
