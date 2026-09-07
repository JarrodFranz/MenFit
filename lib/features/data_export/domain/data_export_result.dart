import 'dart:typed_data';

import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

/// Result of building a whole-app export.
///
/// Sealed rather than a bare record, following
/// `features/activity/application/activity_export_service.dart`: expected
/// outcomes are values here, and only genuine *failures* (a database that
/// will not read) are thrown, as `knowledge/engineering/error_handling.md`
/// requires. Today there is exactly one outcome — the export always builds,
/// even from an empty database — and the hierarchy exists so that the next
/// one ("nothing logged yet", "a table could not be read") arrives as another
/// value and forces every caller's switch to be updated, rather than as an
/// exception nobody catches.
sealed class DataExportResult {
  const DataExportResult();
}

/// The file was built. [bytes] is its UTF-8 content; saving it is the
/// caller's job (see `presentation/data_export_controller.dart`) — nothing in
/// the application layer touches a file picker or `dart:io`.
///
/// Typed `Uint8List` rather than `List<int>` so the save dialog, which needs
/// exactly that, can be handed these bytes without copying a buffer that may
/// be tens of megabytes.
final class DataExported extends DataExportResult {
  const DataExported({
    required this.bytes,
    required this.filename,
    required this.summary,
  });

  final Uint8List bytes;
  final String filename;
  final DataExportSummary summary;
}
