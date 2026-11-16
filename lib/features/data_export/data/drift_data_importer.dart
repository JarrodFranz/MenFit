import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/foods_provider_id_backfill.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_import_target.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart' as keto;
import 'package:menfit_app/features/keto/domain/ketone_validation.dart';

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
      _validateKetoneRows(document);
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

        if (document.tables.containsKey('foods')) {
          await backfillFoodsProviderFoodId(_db);
        }
        // Raw SQL writes must notify already-mounted diary/Keto streams.
        _db.markTablesUpdated({
          for (final name in tablesToInsert) knownTables[name]!,
        });
        return DataExportSummary(
          tableCount: importedTableCount,
          rowCount: importedRowCount,
        );
      });
    } on Object catch (_, stackTrace) {
      throw StorageException(
        message: 'Failed to import local data from backup',
        userMessageKey: 'error.importWrite',
        stackTrace: stackTrace,
      );
    }
  }

  void _validateKetoneRows(DataExportDocument document) {
    final rows = document.tables['ketone_readings'];
    if (rows == null) return;
    if (!document.includesSensitiveHealthData) {
      throw const FormatException(
        'Sensitive table requires explicit inclusion.',
      );
    }
    final ids = <String>{};
    for (final row in rows) {
      if (row['id'] is! String ||
          row['day'] is! String ||
          row['type'] is! String ||
          row['result'] is! String ||
          row['measured_at'] is! int ||
          row['created_at'] is! int ||
          row['updated_at'] is! int) {
        throw const FormatException('Invalid ketone row.');
      }
      final reading = keto.KetoneReading(
        id: row['id']! as String,
        day: LocalDate.parse(row['day']! as String),
        type: keto.KetoneMeasurementType.fromStorage(row['type']! as String),
        result: row['result']! as String,
        measuredAt: DateTime.fromMillisecondsSinceEpoch(
          row['measured_at']! as int,
          isUtc: true,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at']! as int,
          isUtc: true,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row['updated_at']! as int,
          isUtc: true,
        ),
      );
      if (!isValidKetoneReading(reading) || !ids.add(reading.id)) {
        throw const FormatException('Invalid ketone row.');
      }
    }
  }
}
