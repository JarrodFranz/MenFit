import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

/// Persistence-layer target for restoring a whole-app export.
///
/// Kept as an interface so `application/` and `presentation/` do not depend on
/// Drift or SQLite directly (ADR 003 & ADR 007).
abstract interface class DataImportTarget {
  /// The local database's schema version.
  int get schemaVersion;

  /// Restores the [document]'s tables into persistence.
  ///
  /// Replaces existing rows for every table present in the document.
  /// Throws `StorageException` if the write fails.
  Future<DataExportSummary> importDocument(DataExportDocument document);
}
