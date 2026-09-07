import 'package:flutter/foundation.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_export_result.dart';
import 'package:menfit_app/features/data_export/domain/data_export_source.dart';

/// Encodes a built document's JSON map into the file's bytes.
///
/// A seam only so a test can encode synchronously; the app always uses
/// [encodeDataExportInBackground].
typedef DataExportEncoder = Future<Uint8List> Function(
  Map<String, Object?> json,
);

/// The production encoder: JSON + UTF-8 on a background isolate.
///
/// The rows have to be read on this isolate (the database lives here), but
/// the encode does not, and on a database with a year of GPS samples in it
/// that encode is the part long enough to drop frames — a settings screen
/// that freezes for two seconds reads as a crashed app. On the web
/// `compute` runs the function inline, which is correct there: the browser
/// has no second isolate to hand and the alternative is not doing the export.
Future<Uint8List> encodeDataExportInBackground(Map<String, Object?> json) =>
    compute(encodeDataExportJson, json);

/// Turns everything in local persistence into one downloadable file.
///
/// Sequences a [DataExportSource] read into a [DataExportDocument] and hands
/// back bytes — the same division of labour as
/// `features/activity/application/activity_export_service.dart`: it never
/// touches a file picker, a share sheet or `dart:io`, so the whole of "what
/// ends up in the file" is testable without a native dialog. Saving belongs
/// to `presentation/data_export_controller.dart`.
///
/// [clock] exists so the test can pin `exportedAt` (and therefore the
/// filename) rather than assert around `DateTime.now()`.
class DataExportService {
  const DataExportService({
    required this.source,
    this.clock = DateTime.now,
    this.encode = encodeDataExportInBackground,
  });

  final DataExportSource source;
  final DateTime Function() clock;
  final DataExportEncoder encode;

  /// Builds the export. [includeCycleAndWellbeing] carries the user's answer
  /// to the notice dialog's checkbox all the way down to which tables are
  /// read — the flag is never defaulted to true anywhere on this path.
  ///
  /// Throws `StorageException` if the database cannot be read.
  Future<DataExportResult> export({
    required bool includeCycleAndWellbeing,
  }) async {
    final tables = await source.readTables(
      includeCycleAndWellbeing: includeCycleAndWellbeing,
    );

    final document = DataExportDocument(
      schemaVersion: source.schemaVersion,
      exportedAt: clock().toUtc(),
      includesCycleAndWellbeingData: includeCycleAndWellbeing,
      tables: tables,
    );

    return DataExported(
      bytes: await encode(document.toJson()),
      filename: document.suggestedFilename,
      summary: document.summary,
    );
  }
}
