import 'package:drift/drift.dart';

/// A user-built yoga sequence: an ordered list of poses with a hold each,
/// practised with a fixed gap between consecutive poses. See
/// `features/activity/domain/yoga_sequence.dart` for the domain entity.
///
/// **Poses are a JSON blob, not a child table**, exactly as
/// `strength_routines.exercises_json` is. A pose has no identity of its own —
/// it is never queried, aggregated or referenced from anywhere else, it only
/// ever moves with its sequence, and reordering is the commonest edit. A
/// child table would buy a foreign key and an ordering column and cost a join
/// on every read. A row whose [posesJson] cannot be parsed is skipped by the
/// repository rather than crashing the stream.
///
/// **Starters are not rows.** `YogaSequenceStarters.starters` lives in the
/// domain as a constant; this table holds only what the user actually saved,
/// so an empty table honestly means "nothing saved yet". Accepting a starter
/// writes a copy under a fresh id.
///
/// S1-tier data (`knowledge/engineering/security_and_privacy.md`):
/// self-authored training content, not a health measurement — but still hers,
/// so it never enters logs, analytics or a thrown exception's message, and
/// "Delete my data" hard-deletes every row, soft-deleted ones included
/// (`features/activity/domain/yoga_sequence_repository.dart#deleteAllData`).
class YogaSequences extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  /// Serialized JSON list of poses (name, hold, side, cue).
  TextColumn get posesJson => text()();

  /// Gap held *between* consecutive poses, in seconds; never after the last
  /// pose. Zero is a legitimate value (flow straight through).
  IntColumn get transitionSeconds => integer().withDefault(const Constant(5))();

  /// One of `MindfulStyles.yogaStyles`, or null when the user picked none.
  /// Free text rather than an enum column so a label written by a newer app
  /// version round-trips instead of being coerced.
  TextColumn get style => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete.
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
