import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence_repository.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_sequence_editor_sheet.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_sequence_format.dart';

/// The Yoga hub's sequences card: the user's saved sequences, a way to
/// practise or edit each, and — on an empty list — the two starters.
///
/// The starters are never rows (`YogaSequenceStarters`' doc): "Add Morning
/// flow" saves `starter.copyAsNew()`, so from that tap on it is her
/// sequence, with her id, editable and deletable without the starter
/// changing.
class YogaSequencesCard extends ConsumerWidget {
  const YogaSequencesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final sequencesAsync = ref.watch(yogaSequencesProvider);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: themedCardShape(
        context,
        radius: 16,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sequences',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Poses with timed holds and a chime between them',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            sequencesAsync.when(
              data: (sequences) => sequences.isEmpty
                  ? const _EmptySequences()
                  : _SequenceList(sequences: sequences),
              // Bounded, and it ends: `yogaSequencesProvider` is a Drift
              // stream, so the first row of data replaces this.
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (error, _) => Text(
                userMessageFor(error),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('yogaNewSequenceButton'),
                icon: const Icon(Icons.add),
                label: const Text('New sequence'),
                onPressed: () =>
                    unawaited(YogaSequenceEditorSheet.show(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySequences extends ConsumerWidget {
  const _EmptySequences();

  Future<void> _addStarter(
    BuildContext context,
    WidgetRef ref,
    YogaSequence starter,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final copy = starter.copyAsNew();
    try {
      await ref.read(yogaSequenceRepositoryProvider).saveSequence(copy);
    } on Object catch (error) {
      // Unguarded, this write fails into nothing at all: the list simply
      // never gains the row and the tap looks ignored.
      messenger.showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Added "${copy.name}"')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No sequences yet. Start from one of ours and change anything you '
          'like, or build your own.',
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            for (final starter in YogaSequenceStarters.starters)
              ActionChip(
                key: ValueKey('yogaStarterChip_${starter.id}'),
                avatar: const Icon(Icons.add, size: 16),
                label: Text('Add ${starter.name}'),
                onPressed: () => unawaited(_addStarter(context, ref, starter)),
              ),
          ],
        ),
      ],
    );
  }
}

class _SequenceList extends StatelessWidget {
  const _SequenceList({required this.sequences});

  final List<YogaSequence> sequences;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();

    return Column(
      children: [
        for (final sequence in sequences)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: _SequenceTile(
              key: ValueKey('yogaSequenceTile_${sequence.id}'),
              sequence: sequence,
            ),
          ),
      ],
    );
  }
}

enum _SequenceAction { edit, delete }

class _SequenceTile extends ConsumerWidget {
  const _SequenceTile({required this.sequence, super.key});

  final YogaSequence sequence;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this sequence?'),
        content: Text('"${sequence.name}" will be removed from your list.'),
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
    if (confirmed != true || !context.mounted) return;

    final repository = ref.read(yogaSequenceRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.deleteSequence(sequence.id);
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${sequence.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          // Re-saving the same entity clears the soft-delete flag
          // (`YogaSequenceRepository.saveSequence`), so Undo restores the
          // row under its original id rather than making a near-copy.
          //
          // A failed Undo is the worst of the three to swallow: she has
          // been told the sequence is deleted and would be left believing
          // she got it back.
          onPressed: () => unawaited(_undoDelete(repository, messenger)),
        ),
      ),
    );
  }

  Future<void> _undoDelete(
    YogaSequenceRepository repository,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      await repository.saveSequence(sequence);
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final style = sequence.style;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sequence.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: tokens.spacingSm,
                        children: [
                          Text(
                            sequenceSummaryLine(sequence),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (style != null && style.isNotEmpty)
                            Text(
                              style,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_SequenceAction>(
                  tooltip: 'More options for ${sequence.name}',
                  onSelected: (action) {
                    switch (action) {
                      case _SequenceAction.edit:
                        unawaited(
                          YogaSequenceEditorSheet.show(
                            context,
                            sequence: sequence,
                          ),
                        );
                      case _SequenceAction.delete:
                        unawaited(_delete(context, ref));
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _SequenceAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _SequenceAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: tokens.spacingXs),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                key: ValueKey('yogaPractiseButton_${sequence.id}'),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Practise'),
                onPressed: () => unawaited(
                  YogaSequenceRunnerRouteData(
                    sequenceId: sequence.id,
                  ).push<void>(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
