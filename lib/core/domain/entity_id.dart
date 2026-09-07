import 'package:uuid/uuid.dart';

/// Generates client-side row identifiers.
///
/// Every persisted row (across every Drift table) uses a UUIDv7 id
/// generated at entity-creation time on the client — non-negotiable for
/// offline-first sync (see ADR 004 and `knowledge/decisions/003_local_database.md`).
/// UUIDv7 embeds a millisecond timestamp prefix, so ids generated close in
/// time sort close together, which keeps primary-key index locality sane
/// even though ids are client-generated and unordered relative to a
/// central sequence.
abstract final class EntityId {
  static const Uuid _uuid = Uuid();

  /// Returns a new UUIDv7 string suitable for use as a row's primary key.
  static String generate() => _uuid.v7();
}
