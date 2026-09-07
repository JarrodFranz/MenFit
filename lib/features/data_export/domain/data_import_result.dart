import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

/// Sealed hierarchy of results from a data import attempt.
sealed class DataImportResult {
  const DataImportResult();
}

/// The import succeeded.
final class DataImportSuccess extends DataImportResult {
  const DataImportSuccess(this.summary);

  final DataExportSummary summary;
}

/// The user cancelled the import (e.g. dismissed file picker or confirmation).
final class DataImportCancelled extends DataImportResult {
  const DataImportCancelled();
}

/// The import failed. [userMessage] is a safe, user-friendly description.
final class DataImportFailed extends DataImportResult {
  const DataImportFailed(this.userMessage);

  final String userMessage;
}
