import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/data_export/application/data_export_service.dart';
import 'package:menfit_app/features/data_export/application/data_import_service.dart';
import 'package:menfit_app/features/data_export/data/drift_data_exporter.dart';
import 'package:menfit_app/features/data_export/data/drift_data_importer.dart';
import 'package:menfit_app/features/data_export/domain/data_export_source.dart';
import 'package:menfit_app/features/data_export/domain/data_import_target.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Composition surface for the `data_export` feature (ADR 007).
///
/// The only legal way for another feature (in practice `settings`, which
/// mounts the tile) to reach this feature's persistence: import this file,
/// never `data/` or `presentation/`. Its designated public UI — the notice
/// dialog and the export controller — is exported from
/// `data_export_widgets.dart` instead (ADR 007's 2026-08-28 amendment), and
/// deliberately not from here: `presentation/data_export_controller.dart`
/// imports *this* file for [dataExportServiceProvider], so re-exporting it
/// back out of here would put a library cycle through two `part` files.
///
/// Exports sit above the `part` directive because Dart requires it.
export 'package:menfit_app/features/data_export/domain/data_export_document.dart'
    show DataExportSummary;
export 'package:menfit_app/features/data_export/domain/data_export_result.dart';
export 'package:menfit_app/features/data_export/domain/data_import_result.dart';

part 'data_export_providers.g.dart';

/// Reads the local database for export, typed as the domain interface so
/// nothing above `data/` knows Drift is behind it.
@Riverpod(keepAlive: true)
DataExportSource dataExportSource(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftDataExporter(database);
}

/// Builds the export document from what [dataExportSourceProvider] reads.
///
/// `keepAlive` for the same reason as `activityExportServiceProvider`: it is
/// an app-scoped, stateless service, and an export begun from a screen must
/// not be torn down because that screen went away mid-write.
@Riverpod(keepAlive: true)
DataExportService dataExportService(Ref ref) {
  return DataExportService(source: ref.watch(dataExportSourceProvider));
}

/// Restores the local database from an export, typed as the domain interface.
@Riverpod(keepAlive: true)
DataImportTarget dataImportTarget(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftDataImporter(database);
}

/// Orchestrates backup document parsing and restoration into persistence.
@Riverpod(keepAlive: true)
DataImportService dataImportService(Ref ref) {
  return DataImportService(target: ref.watch(dataImportTargetProvider));
}
