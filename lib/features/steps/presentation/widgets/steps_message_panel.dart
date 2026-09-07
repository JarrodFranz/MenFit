import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// The panel the steps screen shows instead of a chart when there is
/// nothing honest to plot: unsupported platform, sync off, or permission
/// not granted.
///
/// One widget for all three so the three states cannot drift into three
/// different layouts; the copy that distinguishes them lives in
/// `steps_copy.dart`. [actionLabel]/[onAction] are omitted for the
/// unsupported case — there is no button that would help, and offering one
/// would imply otherwise.
class StepsMessagePanel extends StatelessWidget {
  const StepsMessagePanel({
    required this.icon,
    required this.title,
    required this.body,
    this.footnote,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  /// An extra line under the action, e.g. the outcome of a refused
  /// permission request.
  final String? footnote;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final actionLabel = this.actionLabel;
    final footnote = this.footnote;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: tokens.spacingMd),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  key: const Key('stepsMessagePanelAction'),
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ),
            ],
            if (footnote != null) ...[
              SizedBox(height: tokens.spacingSm),
              Text(
                footnote,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
