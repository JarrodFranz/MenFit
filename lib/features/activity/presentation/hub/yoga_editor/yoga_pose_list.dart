import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

/// The editor's ordered pose list: drag to reorder, tap to edit, mirror a
/// one-sided pose, remove.
///
/// `shrinkWrap` + `NeverScrollableScrollPhysics` because it sits inside the
/// sheet's own scroll view — the sheet scrolls, this does not.
class YogaPoseList extends StatelessWidget {
  const YogaPoseList({
    required this.poses,
    required this.onEdit,
    required this.onRemove,
    required this.onDuplicateSide,
    required this.onReorder,
    super.key,
  });

  final List<YogaPose> poses;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  /// Adds the same pose on the other side, immediately after this one — a
  /// one-sided pose is practically always done twice.
  final ValueChanged<int> onDuplicateSide;

  /// Receives the index the pose should end up at, already adjusted for
  /// its own removal (`onReorderItem`, not the deprecated `onReorder`).
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: poses.length,
      onReorderItem: onReorder,
      itemBuilder: (context, index) {
        final pose = poses[index];
        return _YogaPoseRow(
          // Position is part of the key: two identical poses (a left and a
          // right of the same name would otherwise collide) must stay
          // distinguishable to the reorder animation.
          key: ValueKey('yogaPoseRow_${index}_${pose.displayName}'),
          index: index,
          pose: pose,
          onEdit: () => onEdit(index),
          onRemove: () => onRemove(index),
          onDuplicateSide: () => onDuplicateSide(index),
        );
      },
    );
  }
}

class _YogaPoseRow extends StatelessWidget {
  const _YogaPoseRow({
    required this.index,
    required this.pose,
    required this.onEdit,
    required this.onRemove,
    required this.onDuplicateSide,
    super.key,
  });

  final int index;
  final YogaPose pose;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onDuplicateSide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final hasSide = pose.side != YogaPoseSide.none;

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacingSm),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacingSm,
            vertical: tokens.spacingXs,
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Semantics(
                  label: 'Reorder ${pose.displayName}',
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.drag_handle),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pose.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${pose.holdSeconds}s hold',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasSide)
                IconButton(
                  icon: const Icon(Icons.flip, size: 20),
                  tooltip: 'Duplicate ${pose.displayName} for the other side',
                  onPressed: onDuplicateSide,
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Remove ${pose.displayName}',
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
