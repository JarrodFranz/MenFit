import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_editor/yoga_editor_fields.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_editor/yoga_pose_dialog.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_editor/yoga_pose_list.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_sequence_format.dart';

/// Builds or edits one [YogaSequence].
///
/// Opened through [showAppBottomSheet], which owns the keyboard and system
/// navigation-bar insets — this sheet adds none of its own.
class YogaSequenceEditorSheet extends ConsumerStatefulWidget {
  const YogaSequenceEditorSheet({this.sequence, super.key});

  /// The sequence being edited, or null for a new one.
  final YogaSequence? sequence;

  static Future<void> show(
    BuildContext context, {
    YogaSequence? sequence,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => YogaSequenceEditorSheet(sequence: sequence),
    );
  }

  @override
  ConsumerState<YogaSequenceEditorSheet> createState() =>
      _YogaSequenceEditorSheetState();
}

class _YogaSequenceEditorSheetState
    extends ConsumerState<YogaSequenceEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  /// Fixed for the life of the sheet so the live-validated draft below is
  /// not a new entity on every keystroke. An edit keeps the row's id; a new
  /// sequence claims one now and saves under it.
  late final String _id;
  late final DateTime _createdAt;

  late List<YogaPose> _poses;
  late int _transitionSeconds;
  String? _style;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.sequence;
    _nameController = TextEditingController(text: existing?.name ?? '')
      ..addListener(_onTextChanged);
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _id = existing?.id ?? EntityId.generate();
    _createdAt = existing?.createdAt ?? DateTime.now().toUtc();
    _poses = List<YogaPose>.from(existing?.poses ?? const <YogaPose>[]);
    _transitionSeconds =
        existing?.transitionSeconds ?? defaultTransitionSeconds;
    _style = existing?.style;
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onTextChanged)
      ..dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// The name feeds `validateYogaSequence`, so the footer has to rebuild as
  /// it is typed — a `TextField.onChanged` would not fire for a paste from
  /// the platform's own menu.
  void _onTextChanged() => setState(() {});

  /// Built directly rather than through `copyWith`, which cannot clear
  /// `style`: its `style ?? this.style` would silently keep the old label
  /// when she deselects the chip.
  YogaSequence get _draft => YogaSequence(
    id: _id,
    name: _nameController.text.trim(),
    createdAt: _createdAt,
    updatedAt: DateTime.now().toUtc(),
    description: _descriptionController.text.trim(),
    poses: List.unmodifiable(_poses),
    transitionSeconds: _transitionSeconds,
    style: _style,
  );

  Future<void> _addPose() async {
    final pose = await showYogaPoseDialog(context);
    if (pose == null) return;
    setState(() => _poses.add(pose));
  }

  Future<void> _editPose(int index) async {
    final pose = await showYogaPoseDialog(context, existing: _poses[index]);
    if (pose == null) return;
    setState(() => _poses[index] = pose);
  }

  void _removePose(int index) => setState(() => _poses.removeAt(index));

  void _duplicateForOtherSide(int index) {
    final pose = _poses[index];
    if (pose.side == YogaPoseSide.none) return;
    final mirrored = pose.copyWith(
      side: pose.side == YogaPoseSide.left
          ? YogaPoseSide.right
          : YogaPoseSide.left,
    );
    setState(() => _poses.insert(index + 1, mirrored));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      // `onReorderItem` already adjusts newIndex for the removal of the
      // dragged row, unlike the deprecated `onReorder` this replaced.
      final pose = _poses.removeAt(oldIndex);
      _poses.insert(newIndex, pose);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final sequence = _draft;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(yogaSequenceRepositoryProvider).saveSequence(sequence);
    } on Object catch (error) {
      // The sheet stays open on the draft she typed, and Save comes back:
      // latching `_saving` on a failed write would leave the only way out
      // the close button, and everything she entered gone with it.
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(userMessageFor(error))),
      );
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Saved "${sequence.name}"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final isEditing = widget.sequence != null;
    final draft = _draft;
    final problems = validateYogaSequence(draft);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.spacingMd),
          child: Column(
            children: [
              _EditorHeader(
                title: isEditing ? 'Edit sequence' : 'New sequence',
                onClose: () => Navigator.of(sheetContext).pop(),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // The Name field's floating label sits *above* its
                    // border, and the ListView clips at its own top edge:
                    // without this the label is sliced in half on device.
                    SizedBox(height: tokens.spacingSm),
                    TextField(
                      key: const Key('yogaSequenceNameField'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Morning flow',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: tokens.spacingSm),
                    TextField(
                      key: const Key('yogaSequenceDescriptionField'),
                      controller: _descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'What this sequence is for',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: tokens.spacingMd),
                    YogaStylePicker(
                      selected: _style,
                      onChanged: (style) => setState(() => _style = style),
                    ),
                    SizedBox(height: tokens.spacingMd),
                    YogaTransitionPicker(
                      seconds: _transitionSeconds,
                      onChanged: (seconds) =>
                          setState(() => _transitionSeconds = seconds),
                    ),
                    SizedBox(height: tokens.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Poses (${_poses.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: tokens.spacingSm),
                        FilledButton.tonalIcon(
                          key: const Key('yogaAddPoseButton'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add pose'),
                          onPressed: _addPose,
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacingSm),
                    if (_poses.isEmpty)
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(tokens.spacingMd),
                          child: const Text(
                            'No poses yet. Add the first one and give it a '
                            'hold.',
                          ),
                        ),
                      )
                    else
                      YogaPoseList(
                        poses: _poses,
                        onEdit: _editPose,
                        onRemove: _removePose,
                        onDuplicateSide: _duplicateForOtherSide,
                        onReorder: _reorder,
                      ),
                    SizedBox(height: tokens.spacingLg),
                  ],
                ),
              ),
              _EditorFooter(
                totalLabel: formatSequenceClock(draft.totalDuration),
                firstProblem: problems.isEmpty ? null : problems.first,
                onSave: problems.isEmpty && !_saving ? _save : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _EditorFooter extends StatelessWidget {
  const _EditorFooter({
    required this.totalLabel,
    required this.firstProblem,
    required this.onSave,
  });

  final String totalLabel;

  /// Only the first `validateYogaSequence` message is shown: a list of five
  /// complaints under a disabled button reads as a wall, and fixing the
  /// first reveals the next.
  final String? firstProblem;

  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();

    return Padding(
      padding: EdgeInsets.only(
        top: tokens.spacingSm,
        bottom: tokens.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (firstProblem != null) ...[
            Text(
              firstProblem!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total $totalLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              FilledButton.icon(
                key: const Key('yogaSequenceSaveButton'),
                onPressed: onSave,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
