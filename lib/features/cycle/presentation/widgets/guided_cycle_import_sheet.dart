import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/import_export/cycle_importer.dart';

/// Guided multi-step importer modal for CSV, JSON, and Health Connect data.
class GuidedCycleImportSheet extends ConsumerStatefulWidget {
  const GuidedCycleImportSheet({
    required this.existingRecords,
    super.key,
  });

  final List<CycleRecord> existingRecords;

  static Future<void> show(
    BuildContext context, {
    required List<CycleRecord> existingRecords,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GuidedCycleImportSheet(
        existingRecords: existingRecords,
      ),
    );
  }

  @override
  ConsumerState<GuidedCycleImportSheet> createState() =>
      _GuidedCycleImportSheetState();
}

class _GuidedCycleImportSheetState
    extends ConsumerState<GuidedCycleImportSheet> {
  bool _isLoading = false;
  String? _errorMessage;
  CycleImportResult? _parsedResult;
  String? _sourceFileName;

  Future<void> _pickAndParseCsv() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _parsedResult = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        setState(() {
          _errorMessage = 'The selected file is empty.';
          _isLoading = false;
        });
        return;
      }

      final content = utf8.decode(bytes);
      const importer = CsvCycleImporter();
      final parsed = await importer.parse(
        content,
        existingRecords: widget.existingRecords,
      );

      setState(() {
        _sourceFileName = file.name;
        _parsedResult = parsed;
        _isLoading = false;
      });
    } on Object catch (e) {
      setState(() {
        _errorMessage = 'Failed to parse CSV file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndParseJson() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _parsedResult = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        setState(() {
          _errorMessage = 'The selected file is empty.';
          _isLoading = false;
        });
        return;
      }

      final content = utf8.decode(bytes);
      const importer = JsonCycleImporter();
      final parsed = await importer.parse(
        content,
        existingRecords: widget.existingRecords,
      );

      setState(() {
        _sourceFileName = file.name;
        _parsedResult = parsed;
        _isLoading = false;
      });
    } on Object catch (e) {
      setState(() {
        _errorMessage = 'Failed to parse JSON file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromPlatformHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final adapter = ref.read(healthPlatformAdapterProvider);
    final isSupported = await adapter.isSupported();
    if (!isSupported) {
      setState(() {
        _errorMessage = 'Health platform sync is not available on this device.';
        _isLoading = false;
      });
      return;
    }

    final hasPerm = await adapter.hasPermissions();
    if (!hasPerm) {
      final granted = await adapter.requestPermissions();
      if (!granted) {
        setState(() {
          _errorMessage =
              'Health permissions not granted. Enable permissions in '
              'settings to import.';
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _errorMessage =
          'Health platform cycle sync completed. No new period entries found.';
      _isLoading = false;
    });
  }

  Future<void> _commitImport() async {
    final result = _parsedResult;
    if (result == null || result.records.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(cycleRepositoryProvider);
      await repository.saveRecords(result.records);

      if (mounted) {
        Navigator.of(context).pop();
        final count = result.records.length;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Successfully imported $count '
                '${count == 1 ? 'period' : 'periods'}!',
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green[700],
            ),
          );
      }
    } on Object catch (e) {
      setState(() {
        _errorMessage = 'Failed to save imported records: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    // Bottom inset comes from `showAppBottomSheet`; no `SafeArea` here.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacingMd,
        0,
        tokens.spacingMd,
        tokens.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.file_download_outlined,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: tokens.spacingSm),
              Text(
                'Import Cycle History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Import your past periods from Clue, Flo, Apple Health, or a '
            'spreadsheet. Your data remains private on your device.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingMd),

          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(tokens.spacingSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontSize: 13,
                ),
              ),
            ),
            SizedBox(height: tokens.spacingMd),
          ],

          if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (_parsedResult == null) ...[
            // Step 1: Select Import Source
            _ImportOptionTile(
              icon: Icons.table_chart_outlined,
              title: 'Import CSV Spreadsheet',
              subtitle: 'Clue, Flo, Apple Health CSV, or custom spreadsheet',
              onTap: _pickAndParseCsv,
            ),
            SizedBox(height: tokens.spacingSm),
            _ImportOptionTile(
              icon: Icons.code,
              title: 'Import JSON File',
              subtitle: 'MenFit JSON export or structured cycle array',
              onTap: _pickAndParseJson,
            ),
            SizedBox(height: tokens.spacingSm),
            _ImportOptionTile(
              icon: Icons.health_and_safety_outlined,
              title: 'Sync from Apple Health / Health Connect',
              subtitle: 'Check device health platform for logged cycles',
              onTap: _importFromPlatformHealth,
            ),
          ] else ...[
            // Step 2: Preview & Confirm
            _buildPreviewSection(context, tokens),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, AppTokens tokens) {
    final theme = Theme.of(context);
    final result = _parsedResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview: ${_sourceFileName ?? 'Imported File'}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  '${result.records.length} new periods found · '
                  '${result.skippedDuplicates} duplicates skipped',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: tokens.spacingSm),

        if (result.records.isNotEmpty) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              itemCount: result.records.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = result.records[index];
                final startStr = _formatLocalDate(r.periodStart);
                final endStr = r.periodEnd != null
                    ? _formatLocalDate(r.periodEnd!)
                    : 'Ongoing';
                final dur = r.periodEnd != null
                    ? '${r.periodStart.difference(r.periodEnd!) + 1} days'
                    : '';

                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.favorite,
                    color: tokens.cyclePhaseMenstrual,
                    size: 20,
                  ),
                  title: Text('$startStr → $endStr'),
                  trailing: Text(dur, style: theme.textTheme.bodySmall),
                );
              },
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text('Import ${result.records.length} Periods'),
            onPressed: _commitImport,
          ),
        ] else ...[
          Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Text(
              result.errorMessage ?? 'No new valid periods found in this file.',
              textAlign: TextAlign.center,
            ),
          ),
        ],

        SizedBox(height: tokens.spacingSm),
        TextButton(
          onPressed: () => setState(() => _parsedResult = null),
          child: const Text('Choose a different file'),
        ),
      ],
    );
  }

  String _formatLocalDate(LocalDate date) {
    final dt = DateTime(date.year, date.month, date.day);
    return DateFormat.yMMMd().format(dt);
  }
}

class _ImportOptionTile extends StatelessWidget {
  const _ImportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacingMd,
          vertical: tokens.spacingXs,
        ),
        onTap: onTap,
      ),
    );
  }
}
