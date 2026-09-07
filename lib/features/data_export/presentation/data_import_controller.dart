import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/data_export/data_export_providers.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_import_controller.g.dart';

/// Seam for picking file bytes, injectable for testing without native dialog.
typedef DataImportFilePicker = Future<Uint8List?> Function();

/// Seam for showing confirmation dialog, injectable for testing.
typedef DataImportConfirmDialog = Future<bool?> Function(
  DataExportDocument document,
);

/// States of the data import flow.
sealed class DataImportState {
  const DataImportState();
}

/// No import currently running.
final class DataImportIdle extends DataImportState {
  const DataImportIdle();
}

/// Reading, decoding, or restoring database rows.
final class DataImportInProgress extends DataImportState {
  const DataImportInProgress();
}

/// Backup restored successfully.
final class DataImportRestored extends DataImportState {
  const DataImportRestored({required this.summary});

  final DataExportSummary summary;
}

/// User cancelled the file picker or confirmation dialog.
final class DataImportAborted extends DataImportState {
  const DataImportAborted();
}

/// Import failed. [userMessage] is a safe, user-friendly description.
final class DataImportError extends DataImportState {
  const DataImportError(this.userMessage);

  final String userMessage;
}

/// Coordinates file picking, document parsing, user confirmation, and
/// database restoration.
@riverpod
class DataImportController extends _$DataImportController {
  @override
  DataImportState build() => const DataImportIdle();

  /// Prompts the user to pick a backup file, validates it, asks for
  /// confirmation, and restores the database.
  Future<DataImportState> importData({
    required DataImportConfirmDialog confirmDialog,
    DataImportFilePicker? filePicker,
  }) async {
    final current = state;
    if (current is DataImportInProgress) return current;

    if (ref.mounted) state = const DataImportInProgress();
    try {
      final picker = filePicker ?? _pickFileWithFilePicker;
      final bytes = await picker();
      if (bytes == null || bytes.isEmpty) {
        if (ref.mounted) state = const DataImportAborted();
        return const DataImportAborted();
      }

      final service = ref.read(dataImportServiceProvider);
      final document = await service.parseDocument(bytes);

      final confirmed = await confirmDialog(document);
      if (confirmed != true) {
        if (ref.mounted) state = const DataImportAborted();
        return const DataImportAborted();
      }

      final result = await service.restore(document);
      final next = switch (result) {
        DataImportSuccess(:final summary) => DataImportRestored(
          summary: summary,
        ),
        DataImportCancelled() => const DataImportAborted(),
        DataImportFailed(:final userMessage) => DataImportError(userMessage),
      };

      if (ref.mounted) state = next;
      return next;
    } on Object catch (error) {
      final next = DataImportError(userMessageFor(error));
      if (ref.mounted) state = next;
      return next;
    }
  }
}

Future<Uint8List?> _pickFileWithFilePicker() async {
  final result = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (result == null) return null;
  return result.readAsBytes();
}
