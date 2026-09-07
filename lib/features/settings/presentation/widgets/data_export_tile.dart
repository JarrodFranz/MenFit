import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/data_export/data_export_widgets.dart';

/// The Settings row that saves a copy of everything she has logged as a file
/// — the "export" half of security_and_privacy.md rule 7 ("deletion & export
/// are features"), sitting beside the "Delete my data" flow that is the other
/// half.
///
/// Its own file rather than another hundred lines inside `settings_screen`,
/// which is already long and is the file every settings change touches — the
/// same reasoning as `food_search_region_tile.dart`.
///
/// It reaches the `data_export` feature only through its UI composition
/// surface (`data_export_widgets.dart`), which is the whole of what ADR 007
/// permits one feature to know about another's presentation layer.
///
/// The notice comes first and gates everything: no bytes are read out of the
/// database until she has said yes and said whether cycle and wellbeing data
/// is in it.
class DataExportTile extends ConsumerWidget {
  const DataExportTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `watch`, not `read`: the controller is autoDispose, so without a
    // listener it would be torn down the moment `_export` returned from its
    // `read` and nothing would ever render `DataExportInProgress`. Watching
    // keeps it alive for as long as this tile is on screen, which is
    // exactly the life of an export started from it.
    final inProgress =
        ref.watch(dataExportControllerProvider) is DataExportInProgress;

    return ListTile(
      enabled: !inProgress,
      leading: const Icon(Icons.download_outlined),
      title: const Text('Export my data'),
      // Honest about what it does: the notice dialog is where "everything
      // you've logged" gets spelled out, including the cycle/wellbeing
      // opt-in this tile cannot promise either way.
      subtitle: Text(
        inProgress
            ? 'Preparing your file…'
            : "Save a copy of what you've logged as a file",
      ),
      trailing: inProgress
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: inProgress ? null : () => _export(context, ref),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final choice = await DataExportNoticeDialog.show(context);
    if (choice == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(dataExportControllerProvider.notifier)
        .export(
          includeCycleAndWellbeing: choice.includeCycleAndWellbeing,
        );

    final message = switch (result) {
      DataExportSaved(:final filename) => 'Saved $filename',
      DataExportCancelled() => 'Export cancelled',
      DataExportFailed(:final userMessage) => userMessage,
      // Not terminal states: `export` only ever returns one of the three
      // above. Listed so a state added later has to be considered here.
      DataExportIdle() || DataExportInProgress() => null,
    };
    if (message == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
  }
}
