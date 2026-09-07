import 'dart:typed_data';

import 'package:menfit_app/core/platform/files/file_saver.dart';
import 'package:menfit_app/features/activity/application/activity_export_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_export_controller.g.dart';

/// Hands finished file [bytes] to the platform's save dialog, returning the
/// location the user chose or `null` if they backed out.
///
/// Injectable so the flow above it is testable without a native dialog —
/// the same seam `activity_import_service.dart` uses for picking a file.
typedef ActivityFileSaver = Future<Uri?> Function({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
});

/// What the export flow ended up doing, for the screen to turn into a
/// SnackBar (or, for [ActivityExportCancelled], into nothing).
sealed class ActivityExportOutcome {
  const ActivityExportOutcome();
}

/// The file was written to wherever the user chose.
final class ActivityExportSaved extends ActivityExportOutcome {
  const ActivityExportSaved(this.filename);

  final String filename;
}

/// The user dismissed the save dialog. Not an error, and not something to
/// announce — she already knows she cancelled.
final class ActivityExportCancelled extends ActivityExportOutcome {
  const ActivityExportCancelled();
}

/// The export could not be produced for a reason worth explaining: GPX
/// asked of an activity with no GPS track, or an activity that no longer
/// exists. [message] is user-facing.
final class ActivityExportUnavailable extends ActivityExportOutcome {
  const ActivityExportUnavailable(this.message);

  final String message;
}

/// Something unexpected threw. [error] is passed to `userMessageFor` by
/// the caller rather than turned into a string here.
final class ActivityExportFailed extends ActivityExportOutcome {
  const ActivityExportFailed(this.error);

  final Object error;
}

/// Wires `ActivityExportService` (which produces bytes and never touches a
/// file picker) to the platform save dialog.
///
/// Lives here rather than in the detail screen because the branch table
/// below — which sealed result maps to which outcome — is the decision the
/// test in `test/features/activity/activity_export_controller_test.dart`
/// pins, and a decision embedded in a widget callback can only be tested
/// through a native dialog that cannot run in a widget test.
///
/// Stateless: `build` returns nothing and the notifier exists purely for
/// [export]. Default `autoDispose` — nothing here outlives the screen that
/// invoked it.
@riverpod
class ActivityExportController extends _$ActivityExportController {
  @override
  void build() {}

  /// Renders [activityId] as [format] and offers it to the user to save.
  ///
  /// [saver] defaults to the real `file_picker` save dialog; tests pass
  /// their own. Note `FilePicker.saveFile` is **static** in file_picker 12
  /// (there is no `FilePicker.platform` instance any more) and returns the
  /// saved file's [Uri], whose scheme varies by platform (`file`,
  /// `content`, or `blob` on web) — the flow only cares whether it is
  /// null.
  Future<ActivityExportOutcome> export({
    required String activityId,
    required ActivityExportFormat format,
    ActivityFileSaver? saver,
  }) async {
    try {
      final service = ref.read(activityExportServiceProvider);
      final result = await service.exportActivity(activityId, format: format);

      switch (result) {
        case ActivityNotFoundForExport():
          return const ActivityExportUnavailable(
            'This activity is no longer available to export.',
          );
        case ActivityNotExportableAsGpx(:final reason):
          return ActivityExportUnavailable(reason);
        case ActivityExported(:final bytes, :final filename):
          final save = saver ?? _defaultSave;
          final location = await save(
            fileName: filename,
            bytes: Uint8List.fromList(bytes),
            mimeType: _mimeTypeFor(format),
          );
          if (location == null) return const ActivityExportCancelled();
          return ActivityExportSaved(filename);
      }
    } on Object catch (error) {
      return ActivityExportFailed(error);
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
    dialogTitle: 'Save activity file',
  );
}

String _mimeTypeFor(ActivityExportFormat format) {
  return switch (format) {
    ActivityExportFormat.gpx => 'application/gpx+xml',
    ActivityExportFormat.tcx => 'application/vnd.garmin.tcx+xml',
  };
}
