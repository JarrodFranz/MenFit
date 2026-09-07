import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/data_export/data_export_widgets.dart';

/// The Settings row that restores user data from a previously saved
/// `menfit-export-*.json` file.
///
/// Follows ADR 007 by reaching data_export exclusively through its UI
/// composition surface (`data_export_widgets.dart`).
class DataImportTile extends ConsumerWidget {
  const DataImportTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgress =
        ref.watch(dataImportControllerProvider) is DataImportInProgress;

    return ListTile(
      enabled: !inProgress,
      leading: const Icon(Icons.upload_outlined),
      title: const Text('Import data from backup'),
      subtitle: Text(
        inProgress
            ? 'Restoring your backup…'
            : 'Restore your data from a menfit-export file',
      ),
      trailing: inProgress
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: inProgress ? null : () => _import(context, ref),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(dataImportControllerProvider.notifier)
        .importData(
          confirmDialog: (doc) async {
            if (!context.mounted) return false;
            return DataImportNoticeDialog.show(context, doc);
          },
        );

    final message = switch (result) {
      DataImportRestored(:final summary) =>
        'Successfully restored ${summary.rowCount} records across '
            '${summary.tableCount} tables',
      DataImportAborted() => 'Import cancelled',
      DataImportError(:final userMessage) => userMessage,
      DataImportIdle() || DataImportInProgress() => null,
    };
    if (message == null || !context.mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
