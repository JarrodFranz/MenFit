import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

/// Hold lengths offered as one tap. The custom field covers everything else.
const List<int> kHoldPresetSeconds = [15, 30, 45, 60, 90];

/// Adds or edits one pose, resolving to the pose or to null on cancel.
Future<YogaPose?> showYogaPoseDialog(
  BuildContext context, {
  YogaPose? existing,
}) {
  return showDialog<YogaPose>(
    context: context,
    builder: (_) => _YogaPoseDialog(existing: existing),
  );
}

class _YogaPoseDialog extends StatefulWidget {
  const _YogaPoseDialog({this.existing});

  final YogaPose? existing;

  @override
  State<_YogaPoseDialog> createState() => _YogaPoseDialogState();
}

class _YogaPoseDialogState extends State<_YogaPoseDialog> {
  late String _name;
  late int _holdSeconds;
  late YogaPoseSide _side;
  late final TextEditingController _holdController;
  late final TextEditingController _cueController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = existing?.name ?? '';
    _holdSeconds = existing?.holdSeconds ?? defaultPoseHoldSeconds;
    _side = existing?.side ?? YogaPoseSide.none;
    _holdController = TextEditingController(text: '$_holdSeconds');
    _cueController = TextEditingController(text: existing?.cue ?? '');
  }

  @override
  void dispose() {
    _holdController.dispose();
    _cueController.dispose();
    super.dispose();
  }

  void _selectPreset(int seconds) {
    setState(() {
      _holdSeconds = seconds;
      _holdController.text = '$seconds';
    });
  }

  void _onHoldTyped(String raw) {
    final parsed = int.tryParse(raw.trim());
    // A half-typed number ("" or "1") must not snap the field out from
    // under the caret, so the clamp happens once, on save.
    if (parsed != null) setState(() => _holdSeconds = parsed);
  }

  YogaPose _buildPose() => YogaPose(
    name: _name.trim(),
    holdSeconds: _holdSeconds.clamp(minPoseHoldSeconds, maxPoseHoldSeconds),
    side: _side,
    cue: _cueController.text.trim(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit pose' : 'Add pose'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Free text on purpose: `commonPoses` is a convenience list, not
            // a closed set (see its doc), so anything typed is kept.
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _name),
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) return const Iterable<String>.empty();
                return YogaPoseCatalogue.commonPoses.where(
                  (pose) => pose.toLowerCase().contains(query),
                );
              },
              onSelected: (selection) => setState(() => _name = selection),
              fieldViewBuilder:
                  (fieldContext, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      key: const Key('yogaPoseNameField'),
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: !isEditing,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Pose name',
                        hintText: 'e.g. Warrior II',
                      ),
                      onChanged: (value) => setState(() => _name = value),
                      onSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
            ),
            const SizedBox(height: 16),
            Text('Hold', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in kHoldPresetSeconds)
                  ChoiceChip(
                    key: ValueKey('yogaHoldPreset_$preset'),
                    label: Text('${preset}s'),
                    selected: _holdSeconds == preset,
                    onSelected: (_) => _selectPreset(preset),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('yogaPoseHoldField'),
              controller: _holdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Hold (seconds)',
                helperText:
                    'Between $minPoseHoldSeconds and '
                    '$maxPoseHoldSeconds seconds',
                suffixText: 's',
              ),
              onChanged: _onHoldTyped,
            ),
            const SizedBox(height: 16),
            Text('Side', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            // Three segments at 150% text are wider than a dialog on a
            // 320dp phone, and `SegmentedButton` has no wrap of its own —
            // it overflows rather than shrinking. Scrolling keeps every
            // segment reachable at full size.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<YogaPoseSide>(
                segments: const [
                  ButtonSegment(value: YogaPoseSide.none, label: Text('None')),
                  ButtonSegment(value: YogaPoseSide.left, label: Text('Left')),
                  ButtonSegment(
                    value: YogaPoseSide.right,
                    label: Text('Right'),
                  ),
                ],
                selected: {_side},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    setState(() => _side = selection.first);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('yogaPoseCueField'),
              controller: _cueController,
              decoration: const InputDecoration(
                labelText: 'Cue (optional)',
                hintText: 'A reminder to show while you hold it',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _name.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_buildPose()),
          child: const Text('Save pose'),
        ),
      ],
    );
  }
}
