import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

/// Persistence for user-built yoga sequences.
///
/// Returns **stored rows only** — `YogaSequenceStarters.starters` is a domain
/// constant and is never merged in here, so an empty stream honestly means
/// "they have saved nothing". The UI offers a starter and saves
/// `starter.copyAsNew()` when they accept.
abstract interface class YogaSequenceRepository {
  /// Live list of non-deleted sequences, most recently updated first.
  ///
  /// A row whose stored pose list cannot be parsed is skipped rather than
  /// crashing the stream.
  Stream<List<YogaSequence>> watchSequences();

  /// One sequence by id, or null when it does not exist, is soft-deleted, or
  /// its stored pose list cannot be parsed.
  Future<YogaSequence?> getSequence(String id);

  /// Inserts or updates [s], clearing any soft-delete flag.
  Future<void> saveSequence(YogaSequence s);

  /// Soft-deletes the sequence with [id]; [watchSequences] stops returning
  /// it.
  Future<void> deleteSequence(String id);

  /// Hard-deletes every sequence on this device — part of the "Delete my
  /// data" flow (`features/settings/presentation/settings_screen.dart`).
  /// Soft-deleted rows go too: a hidden row is not a deleted one.
  Future<void> deleteAllData();
}
