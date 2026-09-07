import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity_file_importer.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';

typedef FilePickerHandler = Future<PlatformFile?> Function();

/// Service responsible for picking and importing GPS / Garmin activity files
/// (.gpx, .tcx) into the local database.
class ActivityImportService {
  const ActivityImportService({
    required this.ref,
    this.importer = const ActivityFileImporter(),
  });

  final Ref ref;
  final ActivityFileImporter importer;

  /// Prompts the user to select a GPX or TCX file, parses it, and persists
  /// the activity and GPS samples to [ActivityRepository].
  /// Returns the imported [ImportedActivity], or null if cancelled.
  Future<ImportedActivity?> pickAndImportFile({
    PlatformFile? mockFile,
    FilePickerHandler? customPicker,
  }) async {
    final file =
        mockFile ??
        (customPicker != null
            ? await customPicker()
            : await FilePicker.pickFile(
                type: FileType.custom,
                allowedExtensions: ['gpx', 'tcx'],
              ));

    if (file == null) {
      return null;
    }

    String? content;
    final bytes = await file.readAsBytes();
    if (bytes.isNotEmpty) {
      content = utf8.decode(bytes);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    }

    if (content == null || content.isEmpty) {
      throw const FormatException('Selected file is empty or unreadable.');
    }

    final rawName = file.name;
    final fallbackTitle = rawName.replaceAll(
      RegExp(r'\.(gpx|tcx)$', caseSensitive: false),
      '',
    );

    final imported = importer.parseXmlString(
      content,
      fallbackTitle: fallbackTitle.isNotEmpty ? fallbackTitle : null,
    );

    final repo = ref.read(activityRepositoryProvider);
    await repo.saveRecordedActivity(imported.activity, imported.samples);

    return imported;
  }
}

/// Provider for [ActivityImportService].
final activityImportServiceProvider = Provider<ActivityImportService>((ref) {
  return ActivityImportService(ref: ref);
});
