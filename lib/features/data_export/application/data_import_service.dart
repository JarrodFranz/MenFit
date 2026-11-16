import 'package:flutter/foundation.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_import_result.dart';
import 'package:menfit_app/features/data_export/domain/data_import_target.dart';

/// Decodes an export document's bytes into a JSON map.
///
/// Injectable for tests to run synchronously; app uses background isolate.
typedef DataExportDecoder = Future<Map<String, Object?>> Function(
  Uint8List bytes,
);

/// Background decoder: UTF-8 + JSON decode on a background isolate.
Future<Map<String, Object?>> decodeDataExportInBackground(Uint8List bytes) =>
    compute(decodeDataExportJson, bytes);

/// Service orchestrating the validation and restoration of backup documents.
class DataImportService {
  const DataImportService({
    required this.target,
    this.decode = decodeDataExportInBackground,
  });

  final DataImportTarget target;
  final DataExportDecoder decode;

  /// Parses and validates [bytes] into a [DataExportDocument] without
  /// modifying persistence.
  ///
  /// Throws `StorageException` if the file cannot be decoded or is not
  /// a recognized MenFit export.
  Future<DataExportDocument> parseDocument(Uint8List bytes) async {
    try {
      final json = await decode(bytes);
      return DataExportDocument.fromJson(json);
    } on FormatException catch (_, stackTrace) {
      throw StorageException(
        message: 'Invalid export format',
        userMessageKey: 'error.importRead',
        stackTrace: stackTrace,
      );
    } on Object catch (_, stackTrace) {
      throw StorageException(
        message: 'Failed to decode export file',
        userMessageKey: 'error.importRead',
        stackTrace: stackTrace,
      );
    }
  }

  /// Restores [document] into persistence via the [target].
  Future<DataImportResult> restore(DataExportDocument document) async {
    try {
      final summary = await target.importDocument(document);
      return DataImportSuccess(summary);
    } on AppException catch (e) {
      return DataImportFailed(userMessageFor(e));
    } on Object catch (e) {
      return DataImportFailed(userMessageFor(e));
    }
  }
}
