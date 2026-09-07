import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';
import 'package:menfit_app/features/cycle/presentation/period_entry_controller.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/period_entry_dialog.dart';

/// The list of past (already-ended) periods, each editable and deletable.
///
/// [records] must already be filtered to non-ongoing records, newest first
/// (the same ordering `CycleRecordsController` emits).
class CycleHistoryList extends StatelessWidget {
  const CycleHistoryList({required this.records, super.key});

  final List<CycleRecord> records;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        for (final record in records)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: _HistoryTile(record: record),
          ),
      ],
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.record});

  final CycleRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(_formatRange(record.periodStart, record.periodEnd!)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => PeriodEntryDialog.show(
                context,
                mode: PeriodEntryMode.editPast,
                record: record,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _confirmAndDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this period?'),
        content: const Text(
          "This removes it from your history. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(cycleRecordsControllerProvider.notifier)
        .deleteRecord(record.id);
  }
}

/// Formats a period range like "12–16 Aug · 5 days" (a single-day period
/// like "16 Aug · 1 day").
String _formatRange(LocalDate start, LocalDate end) {
  final dayCount = start.difference(end) + 1;
  final dayLabel = dayCount == 1 ? '1 day' : '$dayCount days';
  if (start == end) {
    return '${_formatDay(start)} · $dayLabel';
  }
  return '${_formatDay(start)}–${_formatDay(end)} · $dayLabel';
}

String _formatDay(LocalDate date) {
  return DateFormat('d MMM').format(DateTime(date.year, date.month, date.day));
}
