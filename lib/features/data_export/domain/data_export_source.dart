/// Reads every stored table out of local persistence as plain JSON maps.
///
/// The domain interface behind `data/drift_data_exporter.dart`, so nothing
/// above `data/` knows Drift is what answers (ADR 007). Kept deliberately
/// dumb — it reads rows, it does not decide what an export file looks like;
/// that is `domain/data_export_document.dart`'s job.
abstract interface class DataExportSource {
  /// The local database's schema version, recorded in the export file so a
  /// reader knows which column shapes the rows have.
  int get schemaVersion;

  /// Every table, keyed by SQL table name, each row a JSON-safe map.
  ///
  /// Tables in `domain/data_export_tables.dart`'s `sensitiveHealthTables`
  /// are read only when [includeSensitiveHealth] is true; every other table
  /// is always read, including ones added after this was written.
  ///
  /// Soft-deleted rows (a non-null `deleted_at`) are included. They are still
  /// hers, and a copy of her data that quietly omits the parts the app has
  /// stopped showing her is not a copy of her data.
  ///
  /// Throws `StorageException` if the database cannot be read.
  Future<Map<String, List<Map<String, Object?>>>> readTables({
    required bool includeSensitiveHealth,
  });
}
