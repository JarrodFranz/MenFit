/// UI composition surface for the `data_export` feature (ADR 007's
/// 2026-08-28 amendment): the only legal way for another feature (in
/// practice `settings`, which mounts the tile) to reach this feature's
/// designated public UI. Never import `presentation/` internals directly
/// from outside this feature.
///
/// The controller belongs here rather than in `data_export_providers.dart`
/// for a mechanical reason as well as a tidy one: the controller imports the
/// providers file for `dataExportServiceProvider`, so re-exporting it from
/// there would run a library cycle through two generated `part` files.
library;

export 'package:menfit_app/features/data_export/domain/data_export_document.dart'
    show DataExportSummary;
export 'package:menfit_app/features/data_export/presentation/data_export_controller.dart'
    show
        DataExportCancelled,
        DataExportController,
        DataExportControllerProvider,
        DataExportFailed,
        DataExportFileSaver,
        DataExportIdle,
        DataExportInProgress,
        DataExportSaved,
        DataExportState,
        dataExportControllerProvider;
export 'package:menfit_app/features/data_export/presentation/data_export_notice_dialog.dart'
    show DataExportChoice, DataExportNoticeDialog;
export 'package:menfit_app/features/data_export/presentation/data_import_controller.dart'
    show
        DataImportAborted,
        DataImportConfirmDialog,
        DataImportController,
        DataImportControllerProvider,
        DataImportError,
        DataImportFilePicker,
        DataImportIdle,
        DataImportInProgress,
        DataImportRestored,
        DataImportState,
        dataImportControllerProvider;
export 'package:menfit_app/features/data_export/presentation/data_import_notice_dialog.dart'
    show DataImportNoticeDialog;
