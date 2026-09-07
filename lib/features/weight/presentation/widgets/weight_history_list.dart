import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/presentation/weight_format.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_log_dialog.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';

/// Every reading in the visible range, **newest first**.
///
/// The domain hands these over oldest-first because that is what a time
/// series wants (`domain/weight_repository.dart`); a history list wants
/// the opposite, and reversing at the presentation boundary is the one
/// place it is right to do so.
class WeightHistoryList extends StatelessWidget {
  const WeightHistoryList({
    required this.logs,
    required this.unitSystem,
    super.key,
  });

  /// Oldest first, as the repository returns them.
  final List<WeightLog> logs;

  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: Theme.of(context).extension<AppTokens>()!.spacingMd,
        ),
        child: Text(
          'Nothing logged in this range.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final newestFirst = logs.reversed.toList(growable: false);
    return Column(
      children: [
        for (final log in newestFirst)
          _WeightHistoryTile(
            key: ValueKey(log.id),
            log: log,
            unitSystem: unitSystem,
          ),
      ],
    );
  }
}

class _WeightHistoryTile extends ConsumerWidget {
  const _WeightHistoryTile({
    required this.log,
    required this.unitSystem,
    super.key,
  });

  final WeightLog log;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final note = log.notes;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        formatWeight(log.weightKg, unitSystem),
        style: textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_longDate(log.day)),
          if (note != null && note.isNotEmpty)
            Text(
              note,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<_WeightRowAction>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Reading options',
        onSelected: (action) => switch (action) {
          _WeightRowAction.edit => _edit(context),
          _WeightRowAction.delete => _confirmDelete(context, ref),
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: _WeightRowAction.edit, child: Text('Edit')),
          PopupMenuItem(value: _WeightRowAction.delete, child: Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    await WeightLogDialog.show(context, unitSystem: unitSystem, existing: log);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // Captured before the first await: after the confirmation dialog
    // closes, this row may already be gone from the tree (a rebuild from
    // another change) and its context unusable.
    final messenger = ScaffoldMessenger.maybeOf(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this reading?'),
        // No number in the body: the confirmation should not make her read
        // the value back one more time on the way out (S2, and
        // `knowledge/domain/womens_health.md`).
        // "permanently", not "for good": the feature's copy gate forbids
        // the word "good" outright (`weight_test_vocabulary.dart`) because
        // "looking good" next to a body weight is exactly what it exists
        // to stop, and a blunt gate is worth more here than the idiom.
        // "Permanently" is also the plainer word for what happens.
        content: const Text(
          'It will be removed from your history permanently — this app '
          'keeps no copy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('weightDeleteConfirmButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(weightRepositoryProvider).deleteLog(log.id);
    } on Object catch (error) {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Reading deleted.')));
  }
}

enum _WeightRowAction { edit, delete }

String _longDate(LocalDate day) =>
    DateFormat('EEE d MMM y').format(DateTime(day.year, day.month, day.day));
