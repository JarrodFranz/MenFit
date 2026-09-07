import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/domain/data_export_source.dart';
import 'package:menfit_app/features/data_export/domain/data_export_tables.dart';

/// Drift-backed [DataExportSource].
///
/// **It iterates `db.allTables` rather than naming tables.** That is the
/// whole design: a table added six months from now is exported the day it
/// exists, because nobody has to remember to come back here. The failure mode
/// of the obvious alternative — a hand-written list of `db.select(db.foo)`
/// calls — is silent and permanent: an export that has quietly stopped being
/// a copy of her data, discovered only by someone comparing a file against a
/// database. `features/settings/application/delete_my_data_service.dart` runs
/// the same risk on the deletion side and answers it with a test that seeds
/// every table; export answers it in the code itself.
///
/// The one place a decision is still required is the S3 opt-in, and that is
/// deliberately an explicit *exclusion* set
/// (`domain/data_export_tables.dart`) rather than an inclusion list: a new
/// table is included by default, which is the safe direction to be wrong in
/// for an export (a missing table loses data; an unexpected table is data she
/// already owns, from the app she already installed). The tier decision is
/// forced anyway by
/// `test/features/data_export/data_export_table_coverage_test.dart`.
class DriftDataExporter implements DataExportSource {
  const DriftDataExporter(this._db);

  final AppDatabase _db;

  @override
  int get schemaVersion => _db.schemaVersion;

  @override
  Future<Map<String, List<Map<String, Object?>>>> readTables({
    required bool includeSensitiveHealth,
  }) async {
    try {
      final exported = <String, List<Map<String, Object?>>>{};
      for (final table in _db.allTables) {
        final name = table.actualTableName;
        final isOptIn = sensitiveHealthTables.contains(name);
        if (isOptIn && !includeSensitiveHealth) {
          continue;
        }
        // A raw `SELECT *`, not the generated data class: the export is
        // keyed by the real SQL column names and carries exactly what SQLite
        // stores (epoch ints stay ints, booleans stay 0/1, JSON-blob columns
        // stay strings). `DataClass.toJson()` would rename every key to its
        // Dart field name and reformat DateTime columns - a different, less
        // faithful document. The table name comes from Drift itself, so it
        // can never be a user string.
        final rows = await _db
            .customSelect('SELECT * FROM "$name"', readsFrom: {table})
            .get();
        exported[name] = [
          for (final row in rows) Map<String, Object?>.from(row.data),
        ];
      }
      return exported;
    } on Object catch (error, stackTrace) {
      // Static message, no table name and no row content: an exception
      // message can reach a log, and this one is built while holding
      // health and location data (security_and_privacy.md rule 3).
      throw StorageException(
        message: 'Failed to read local data for export',
        // Its own key rather than the default `error.storage`: nothing was
        // saved and nothing was changed, and the copy behind this key says
        // so (`core/errors/error_messages.dart`).
        userMessageKey: 'error.exportRead',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
