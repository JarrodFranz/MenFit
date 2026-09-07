import 'package:drift/drift.dart';

/// One buddy challenge as this device knows it — see
/// `features/challenges/domain/challenge.dart` for the domain entity and
/// `features/challenges/domain/challenge_codes.dart` for the paste-able
/// text codes that put the same challenge on two devices with no backend
/// between them (ADR 004).
///
/// **One table, with the buddy snapshot embedded, on purpose.** A v1
/// challenge has exactly two participants: the user, whose progress is
/// recomputed live from her own logs and therefore stored nowhere, and one
/// buddy, whose progress is whatever her last pasted progress code said. A
/// separate `challenge_buddy_progress` table would be a strictly 1:1
/// optional child row, replaced wholesale on every import, reachable only
/// through its parent — a join bought with a foreign key and a second
/// query for nothing. The three nullable `buddy_*` columns are null
/// together ("no progress code pasted yet") and non-null together, which
/// the repository is the only writer of.
///
/// **No `@TableIndex`, and no `uniqueKeys` either.** The only uniqueness
/// this table needs is on [id], and [id] is already the primary key: a
/// challenge's id is derived deterministically from the very bytes its
/// code carries (`challenge_codes.dart#challengeBlueprintFrom`), so
/// pasting the same challenge code twice collides on the primary key and
/// the "already joined" path handles it. There is no second query shape to
/// index — the table is read whole, ordered in Dart-free SQL by window
/// start, and it holds a handful of rows. That keeps the v20 migration
/// step a bare `createTable`, which `Migrator.createTable` guards with
/// `IF NOT EXISTS`, so the step is re-entrant with zero fixture drops —
/// the same property `badge_awards` bought with a table-level UNIQUE at
/// v19 (`knowledge/troubleshooting/database_migrations.md`). Adding an
/// index here later means auditing every `onUpgrade` call site in
/// `test/core/db/app_database_test.dart`.
///
/// **No `deleted_at`/`sync_status`**, for the same reason `water_logs`,
/// `weight_logs` and `badge_awards` omit them: there is no backend (ADR
/// 004), and leaving a challenge is a hard delete — a challenge the user
/// removed must actually be gone, not linger as a hidden row carrying her
/// buddy's name.
///
/// ## Sensitivity
///
/// S1: [selfDisplayName] and [buddyDisplayName] are self-chosen names
/// (personal data — wiped by "Delete my data" with everything else), and
/// [buddyProgressPercent] is one number a buddy chose to hand over.
///
/// **Nothing cycle-derived is stored here, and that is structural.** The
/// user's own target is pro-rated by her protected days at read time
/// (`features/challenges/domain/challenge_progress_engine.dart`) and the
/// adjusted figure is never persisted, never encoded, and never shared —
/// see the privacy invariant on `challenge_codes.dart`. A row of this
/// table read by anyone reveals what the challenge asks of *both* people
/// equally, and how far the buddy said she had got. It cannot reveal a
/// protected day.
@DataClassName('ChallengeRow')
class Challenges extends Table {
  /// Deterministically derived from the challenge's own defining bytes
  /// (kind, activity types, target, window, salt) — **not** a UUIDv7,
  /// deliberately, and the one place in this schema that departs from ADR
  /// 004's client-generated-UUID convention. Two devices that never talk
  /// to a server have to agree on this id from the code alone; a locally
  /// generated UUID cannot do that, and shipping one inside the code would
  /// cost 22 characters of a budget meant for a messaging app. See
  /// `features/challenges/domain/challenge_codes.dart`.
  TextColumn get id => text()();

  /// `ChallengeKind`'s storage key — `'total_distance'` or
  /// `'session_count'`.
  TextColumn get kind => text()();

  /// Comma-separated `ActivityType` storage keys, or `''` meaning "any
  /// type counts". Parsed at the repository boundary.
  TextColumn get activityTypes => text()();

  /// The target in the kind's own units: hundreds of metres for
  /// `total_distance`, sessions for `session_count`. See
  /// `features/challenges/domain/challenge.dart`.
  IntColumn get targetUnits => integer()();

  /// ISO-8601 date string (`YYYY-MM-DD`), inclusive first day of the
  /// window. Calendar days, never cycle-relative — a challenge window is a
  /// date range both people can read off a calendar
  /// (`knowledge/architecture/data_architecture.md`'s calendar-day
  /// semantics).
  TextColumn get windowStart => text()();

  /// ISO-8601 date string, inclusive last day of the window.
  TextColumn get windowEnd => text()();

  /// The 32-bit salt mixed into [id], so two challenges created with
  /// identical parameters are still distinct challenges.
  IntColumn get salt => integer()();

  /// The name the user chose to show her buddy for this challenge. S1 —
  /// self-chosen and per-challenge, never her profile name by default.
  TextColumn get selfDisplayName => text()();

  /// `ChallengeOrigin`'s storage key — `'created'` or `'joined'`. Kept
  /// only so the UI can say "you started this" rather than to rank anyone.
  TextColumn get origin => text()();

  /// This device's 32-bit author tag for this challenge, drawn at random
  /// when it was created or joined and stamped into every progress code
  /// exported from here.
  ///
  /// **Local, and deliberately not part of [id].** The two devices in a
  /// challenge hold different tags for the same challenge; a pasted code
  /// carrying *this* tag is this device's own code coming back, and
  /// importing it would overwrite the buddy snapshot with the user's own
  /// figure (`features/challenges/application/challenge_code_service.dart`).
  ///
  /// S1, and only barely: it is random noise with no relationship to her
  /// name, her device or anything she has logged.
  IntColumn get authorTag => integer()();

  /// The buddy's self-chosen name from her last pasted progress code.
  /// Null until one has been pasted; null together with the two columns
  /// below.
  TextColumn get buddyDisplayName => text().nullable()();

  /// The buddy's progress against **her own** privately-adjusted target,
  /// as a percentage. May exceed 100. This is the only number a progress
  /// code carries, and it is deliberately not decomposable into what she
  /// did and what she was asked for.
  RealColumn get buddyProgressPercent => real().nullable()();

  /// ISO-8601 date string — the day the buddy's code was exported for.
  /// The repository never lets an older snapshot replace a newer one
  /// (`features/challenges/application/challenge_code_service.dart`).
  TextColumn get buddyAsOf => text().nullable()();

  /// UTC milliseconds since epoch — when this device first learned about
  /// the challenge (created or joined). Local metadata; not part of [id]
  /// and not carried by any code, because the two devices join at
  /// different moments and the challenge is the same challenge.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
