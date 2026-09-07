import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

/// Confirmation dialog shown after a backup file is picked and validated,
/// before any local tables are overwritten.
class DataImportNoticeDialog extends StatelessWidget {
  const DataImportNoticeDialog({required this.document, super.key});

  final DataExportDocument document;

  /// Shows the dialog and returns true if the user confirmed the restore,
  /// or false / null if cancelled.
  static Future<bool?> show(
    BuildContext context,
    DataExportDocument document,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DataImportNoticeDialog(document: document),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final exportDate = document.exportedAt.toLocal().toString().substring(
      0,
      16,
    );
    final summary = document.summary;
    final hasHealthCheckins = document.includesSensitiveHealthData;

    return AlertDialog(
      key: const Key('dataImportNoticeDialog'),
      title: const Text('Restore from backup'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This backup file was exported on $exportDate and contains '
                '${summary.tableCount} tables with ${summary.rowCount} '
                'total records.',
                style: textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spacingMd),
              Container(
                padding: EdgeInsets.all(tokens.spacingSm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Total records',
                      value: '${summary.rowCount}',
                    ),
                    SizedBox(height: tokens.spacingXs),
                    _InfoRow(
                      label: 'Health check-ins',
                      value: hasHealthCheckins ? 'Included' : 'Not included',
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              Text(
                'Restoring will replace existing data in the app with the '
                'records from this backup.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('dataImportNoticeCancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('dataImportNoticeConfirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Restore data'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
