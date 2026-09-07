import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_import_target.dart';

/// Drift implementation of [DataImportTarget].
///
/// Restores tables atomically inside a database transaction.
/// Clears existing rows and inserts backup rows with parameter binding
/// and schema column validation.
class DriftDataImporter implements DataImportTarget {
  const DriftDataImporter(this._db);

  final AppDatabase _db;

  @override
  int get schemaVersion => _db.schemaVersion;

  @override
  Future<DataExportSummary> importDocument(DataExportDocument document) async {
    try {
      return await _db.transaction(() async {
        final knownTables = {
          for (final t in _db.allTables) t.actualTableName: t,
        };

        // 1. Delete rows from tables that are present in the import document.
        // Reverse dependency order: activity_samples must be deleted
        // before activities.
        final tablesToClear =
            document.tables.keys.where(knownTables.containsKey).toList()
              ..sort((a, b) {
                if (a == 'activity_samples' && b == 'activities') return -1;
                if (a == 'activities' && b == 'activity_samples') return 1;
                return 0;
              });

        for (final tableName in tablesToClear) {
          await _db.customStatement('DELETE FROM "$tableName"');
        }

        // 2. Insert rows in forward dependency order: activities must be
        // inserted before activity_samples.
        final tablesToInsert =
            document.tables.keys.where(knownTables.containsKey).toList()
              ..sort((a, b) {
                if (a == 'activities' && b == 'activity_samples') return -1;
                if (a == 'activity_samples' && b == 'activities') return 1;
                return 0;
              });

        var importedTableCount = 0;
        var importedRowCount = 0;

        for (final tableName in tablesToInsert) {
          final tableInfo = knownTables[tableName]!;
          final rows = document.tables[tableName]!;
          if (rows.isEmpty) {
            importedTableCount++;
            continue;
          }

          final validColumns = tableInfo.$columns.map((c) => c.$name).toSet();

          for (final row in rows) {
            final filteredRow = Map<String, Object?>.fromEntries(
              row.entries.where((e) => validColumns.contains(e.key)),
            );
            if (filteredRow.isEmpty) continue;

            final cols = filteredRow.keys.map((k) => '"$k"').join(', ');
            final placeholders = List.filled(
              filteredRow.length,
              '?',
            ).join(', ');
            final values = filteredRow.values.map((v) {
              if (v is bool) return v ? 1 : 0;
              return v;
            }).toList();

            await _db.customStatement(
              'INSERT OR REPLACE INTO "$tableName" ($cols) '
              'VALUES ($placeholders)',
              values,
            );
            importedRowCount++;
          }
          importedTableCount++;
        }

        return DataExportSummary(
          tableCount: importedTableCount,
          rowCount: importedRowCount,
        );
      });
    } on Object catch (error, stackTrace) {
      throw StorageException(
        message: 'Failed to import local data from backup',
        userMessageKey: 'error.importWrite',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
