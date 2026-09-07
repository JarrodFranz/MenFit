import 'dart:typed_data';

import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/files/file_saver.dart';
import 'package:menfit_app/features/data_export/application/data_export_service.dart';
import 'package:menfit_app/features/data_export/data_export_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_export_controller.g.dart';

/// Hands the finished export [bytes] to the platform's save dialog,
/// returning where the user chose to put it or `null` if she backed out.
///
/// Injectable so the flow above it is testable without a native dialog —
/// the same seam `features/activity/presentation/activity_export_controller.dart`
/// uses, and deliberately the same shape, so both exports go out through one
/// mechanism: no temp file is written anywhere, on any platform.
typedef DataExportFileSaver = Future<Uri?> Function({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
});

/// Where the export flow has got to. Also the notifier's state, so a screen
/// can show progress while a large database is read and encoded.
sealed class DataExportState {
  const DataExportState();
}

/// Nothing has been asked for yet (or the last result has been shown and
/// acknowledged).
final class DataExportIdle extends DataExportState {
  const DataExportIdle();
}

/// Reading and encoding, or waiting on the save dialog.
final class DataExportInProgress extends DataExportState {
  const DataExportInProgress();
}

/// The file was written to wherever she chose.
final class DataExportSaved extends DataExportState {
  const DataExportSaved({required this.filename, required this.summary});

  final String filename;
  final DataExportSummary summary;
}

/// She dismissed the save dialog. Not an error — she already knows.
final class DataExportCancelled extends DataExportState {
  const DataExportCancelled();
}

/// Something failed. [userMessage] comes from `userMessageFor`, so it is one
/// of a fixed set of sentences and can never contain a table name, a row, or
/// anything else out of her data — an error string reaches SnackBars and,
/// one careless line later, logs (security_and_privacy.md rule 3).
final class DataExportFailed extends DataExportState {
  const DataExportFailed(this.userMessage);

  final String userMessage;
}

/// Wires [DataExportService] (which produces bytes and never touches a file
/// picker) to the platform save dialog.
///
/// Lives here rather than in the settings tile because the branch table
/// below — which result maps to which state — is what
/// `test/features/data_export/data_export_controller_test.dart` pins, and a
/// decision embedded in a widget callback can only be tested through a native
/// dialog that cannot run in a widget test.
///
/// Default `autoDispose`: nothing here outlives the screen that asked —
/// which is why the tile that starts an export `watch`es it rather than
/// only `read`ing the notifier. Without a listener the notifier is torn down
/// between calls, [DataExportInProgress] is published to nobody, and the
/// progress the state exists to show never appears.
@riverpod
class DataExportController extends _$DataExportController {
  @override
  DataExportState build() => const DataExportIdle();

  /// Builds the export and offers it to the user to save.
  ///
  /// [includeCycleAndWellbeing] is the answer she gave the notice dialog and
  /// has no default — a caller has to have asked before it can call this.
  ///
  /// [saver] defaults to the real `file_picker` save dialog; tests pass their
  /// own. `FilePicker.saveFile` is **static** in file_picker 12 (there is no
  /// `FilePicker.platform` instance any more) and returns the saved file's
  /// [Uri], whose scheme varies by platform (`file`, `content`, or `blob` on
  /// web, where passing bytes triggers a browser download); the flow only
  /// cares whether it is null.
  ///
  /// Returns the terminal state as well as publishing it, so the caller can
  /// show a SnackBar without re-reading a notifier that may already have been
  /// disposed with its screen.
  Future<DataExportState> export({
    required bool includeCycleAndWellbeing,
    DataExportFileSaver? saver,
  }) async {
    // A second tap while the first export is still reading is ignored
    // rather than queued: two concurrent reads of the whole database race
    // each other for memory, and two save dialogs is not a thing anyone
    // asked for. The tile disables itself too - this is the backstop for
    // any other caller.
    final current = state;
    if (current is DataExportInProgress) return current;

    if (ref.mounted) state = const DataExportInProgress();
    try {
      final service = ref.read(dataExportServiceProvider);
      final result = await service.export(
        includeCycleAndWellbeing: includeCycleAndWellbeing,
      );

      final DataExportState next;
      switch (result) {
        case DataExported(:final bytes, :final filename, :final summary):
          final save = saver ?? _defaultSave;
          final location = await save(
            fileName: filename,
            // Handed straight through, not copied: `bytes` is already the
            // `Uint8List` the saver wants, and a whole-database export is
            // the one buffer in this app worth not duplicating.
            bytes: bytes,
            mimeType: 'application/json',
          );
          next = location == null
              ? const DataExportCancelled()
              : DataExportSaved(filename: filename, summary: summary);
      }
      if (ref.mounted) state = next;
      return next;
    } on Object catch (error) {
      final next = DataExportFailed(userMessageFor(error));
      if (ref.mounted) state = next;
      return next;
    }
  }
}

Future<Uri?> _defaultSave({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) {
  return saveWithFilePicker(
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
    dialogTitle: 'Save your MenFit data',
  );
}
