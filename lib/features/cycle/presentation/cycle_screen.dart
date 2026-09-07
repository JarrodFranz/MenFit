import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/import_export/cycle_exporter.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';
import 'package:menfit_app/features/cycle/presentation/period_entry_controller.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_calendar_view.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_history_list.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_info_modal.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_settings_faq_modal.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/guided_cycle_import_sheet.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/period_entry_dialog.dart';

enum _CycleMenuAction {
  importHealth,
  importFiles,
  exportData,
  settingsFaqs,
}

/// The Cycle tab: monthly calendar, rolling-median predictions, confidence
/// scoring, plain-language guides, modular importers, and period tracking.
class CycleScreen extends ConsumerWidget {
  const CycleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final recordsAsync = ref.watch(cycleRecordsControllerProvider);
    final records = recordsAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Cycle Guide & How It Works',
            onPressed: () async {
              await CycleInfoModal.show(context);
            },
          ),
          PopupMenuButton<_CycleMenuAction>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Cycle Options',
            onSelected: (action) async {
              await _handleMenuAction(context, ref, action, records);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _CycleMenuAction.importHealth,
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Sync from Health Connect / Apple Health'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _CycleMenuAction.importFiles,
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Import from CSV or JSON'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _CycleMenuAction.exportData,
                child: Row(
                  children: [
                    Icon(Icons.file_upload_outlined, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Export Your Data'),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _CycleMenuAction.settingsFaqs,
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Settings and FAQs'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: recordsAsync.when(
              data: (dataRecords) => _CycleBody(
                records: dataRecords,
                enhancedSemantics: ref
                    .watch(accessibilityControllerProvider)
                    .enhancedSemantics,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userMessageFor(error),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.spacingMd),
                      OutlinedButton.icon(
                        key: const Key('cycleRetryButton'),
                        onPressed: () =>
                            ref.invalidate(cycleRecordsControllerProvider),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    _CycleMenuAction action,
    List<CycleRecord> records,
  ) async {
    switch (action) {
      case _CycleMenuAction.importHealth:
      case _CycleMenuAction.importFiles:
        await GuidedCycleImportSheet.show(context, existingRecords: records);
      case _CycleMenuAction.exportData:
        await _showExportDialog(context, records);
      case _CycleMenuAction.settingsFaqs:
        await CycleSettingsFaqModal.show(context);
    }
  }

  /// Deliberately clipboard-only, with no OS share sheet beside it
  /// (unlike the four sharing surfaces in ADR 011).
  ///
  /// This is a data-export path, not a sharing one: the payload is her
  /// complete period history, S3 data under
  /// `knowledge/engineering/security_and_privacy.md`. The clipboard hands
  /// it to exactly one app she then chooses herself, in one deliberate
  /// paste; a share sheet puts every installed app one tap from the whole
  /// record, on the screen where a mis-tap costs the most. If a genuine
  /// "send my data to my clinician" flow is ever wanted it needs its own
  /// design, not a button added here.
  Future<void> _showExportDialog(
    BuildContext context,
    List<CycleRecord> records,
  ) async {
    final theme = Theme.of(context);
    const exporter = CycleDataExporter();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Cycle Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export ${records.length} logged '
              '${records.length == 1 ? 'period' : 'periods'} from your device.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Copy as CSV Spreadsheet'),
              onPressed: () async {
                final csv = exporter.exportToCsv(records);
                await Clipboard.setData(ClipboardData(text: csv));
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Cycle data copied to clipboard as CSV!'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                }
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.code),
              label: const Text('Copy as JSON'),
              onPressed: () async {
                final json = exporter.exportToJson(records);
                await Clipboard.setData(ClipboardData(text: json));
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cycle data copied to clipboard as JSON!',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

enum CycleCalendarSubTab {
  cycles,
  cyclesAndWellbeing,
}

class _CycleBody extends StatefulWidget {
  const _CycleBody({required this.records, required this.enhancedSemantics});

  final List<CycleRecord> records;
  final bool enhancedSemantics;

  @override
  State<_CycleBody> createState() => _CycleBodyState();
}

class _CycleBodyState extends State<_CycleBody> {
  CycleCalendarSubTab _selectedSubTab = CycleCalendarSubTab.cycles;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();
    final predictionEngine = CyclePredictionEngine();
    final summary = predictionEngine.analyze(
      records: widget.records,
      today: today,
    );

    final ongoing = widget.records.where((r) => r.isOngoing).firstOrNull;
    final history = widget.records.where((r) => !r.isOngoing).toList();

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        // Summary & Prediction Card
        _CycleSummaryCard(summary: summary, ongoingRecord: ongoing),
        SizedBox(height: tokens.spacingSm),

        // Primary Actions under Summary Card
        _PrimaryActionsRow(ongoingRecord: ongoing),
        SizedBox(height: tokens.spacingMd),

        // Sub-tabs: Cycles vs Cycles & Wellbeing
        SegmentedButton<CycleCalendarSubTab>(
          segments: const [
            ButtonSegment(
              value: CycleCalendarSubTab.cycles,
              label: Text('Cycles'),
              icon: Icon(Icons.calendar_today_outlined, size: 18),
            ),
            ButtonSegment(
              value: CycleCalendarSubTab.cyclesAndWellbeing,
              label: Text('Cycles & Wellbeing'),
              icon: Icon(Icons.favorite_outline, size: 18),
            ),
          ],
          selected: {_selectedSubTab},
          onSelectionChanged: (newSelection) {
            setState(() {
              _selectedSubTab = newSelection.first;
            });
          },
        ),
        SizedBox(height: tokens.spacingMd),

        // Monthly Interactive Calendar
        CycleCalendarView(
          records: widget.records,
          predictionEngine: predictionEngine,
          confidence: summary.confidence,
          enhancedSemantics: widget.enhancedSemantics,
          showWellbeingOverlay:
              _selectedSubTab == CycleCalendarSubTab.cyclesAndWellbeing,
        ),
        SizedBox(height: tokens.spacingLg),

        // Past Logged Cycles History
        if (history.isNotEmpty) ...[
          CycleHistoryList(records: history),
          SizedBox(height: tokens.spacingLg),
        ],

        const _Disclaimers(),
      ],
    );
  }
}

class _CycleSummaryCard extends StatelessWidget {
  const _CycleSummaryCard({
    required this.summary,
    required this.ongoingRecord,
  });

  final CyclePredictionSummary summary;
  final CycleRecord? ongoingRecord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final ongoing = ongoingRecord;
    final isDark = theme.brightness == Brightness.dark;

    final (
      phaseColor,
      phaseBgColor,
      phaseBorderColor,
      phaseTitle,
    ) = switch (summary.currentPhase) {
      CyclePhase.menstrual => (
        tokens.cyclePhaseMenstrual,
        isDark
            ? tokens.cyclePhaseMenstrual.withValues(alpha: 0.18)
            : const Color(0xFFFFF0F4),
        isDark
            ? tokens.cyclePhaseMenstrual.withValues(alpha: 0.35)
            : const Color(0xFFFBD1DC),
        ongoing != null
            ? 'Period · Day ${summary.currentCycleDay ?? 1}'
            : 'Menstrual Phase',
      ),
      CyclePhase.follicular => (
        tokens.cyclePhaseFollicular,
        isDark
            ? tokens.cyclePhaseFollicular.withValues(alpha: 0.18)
            : const Color(0xFFFFF8EE),
        isDark
            ? tokens.cyclePhaseFollicular.withValues(alpha: 0.35)
            : const Color(0xFFFDE1BD),
        'Follicular Phase · Day ${summary.currentCycleDay ?? 1}',
      ),
      CyclePhase.ovulatory => (
        tokens.cyclePhaseOvulatory,
        isDark
            ? tokens.cyclePhaseOvulatory.withValues(alpha: 0.18)
            : const Color(0xFFF0FDF8),
        isDark
            ? tokens.cyclePhaseOvulatory.withValues(alpha: 0.35)
            : const Color(0xFFB4EFE0),
        'Ovulatory Window · Day ${summary.currentCycleDay ?? 14}',
      ),
      CyclePhase.luteal => (
        tokens.cyclePhaseLuteal,
        isDark
            ? tokens.cyclePhaseLuteal.withValues(alpha: 0.18)
            : const Color(0xFFFAF2FB),
        isDark
            ? tokens.cyclePhaseLuteal.withValues(alpha: 0.35)
            : const Color(0xFFEBD1ED),
        'Luteal Phase · Day ${summary.currentCycleDay ?? 20}',
      ),
      _ => (
        theme.colorScheme.primary,
        isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.18)
            : const Color(0xFFFAF2FB),
        isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.35)
            : const Color(0xFFEBD1ED),
        'Cycle Tracking',
      ),
    };

    return Material(
      color: phaseBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: phaseBorderColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? phaseColor.withValues(alpha: 0.25)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: phaseColor.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Icon(
                    summary.isOngoingPeriod
                        ? Icons.favorite
                        : Icons.self_improvement,
                    color: phaseColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phaseTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                        ),
                      ),
                      Text(
                        summary.currentPhase.plainDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            Divider(
              height: tokens.spacingMd,
              color: phaseBorderColor,
            ),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.only(
                  top: tokens.spacingXs,
                  bottom: tokens.spacingXs,
                ),
                dense: true,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Estimates & Medians',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildConfidenceBadge(
                      summary.confidence,
                      theme,
                      tokens,
                      isDark,
                    ),
                  ],
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT ESTIMATED PERIOD',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatNextPeriod(summary),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spacingXs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rolling median: ${summary.medianCycleLength}d cycle · '
                      '${summary.medianPeriodDuration}d period '
                      '(${summary.totalLoggedCycles} '
                      '${summary.totalLoggedCycles == 1 ? 'cycle' : 'cycles'} '
                      'recorded)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(
    CycleConfidence confidence,
    ThemeData theme,
    AppTokens tokens,
    bool isDark,
  ) {
    final color = _confidenceColor(confidence, theme);
    return Container(
      key: const Key('cycleConfidenceBadge'),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            confidence.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNextPeriod(CyclePredictionSummary summary) {
    if (summary.isOngoingPeriod) {
      return 'Period is currently ongoing';
    }
    if (summary.nextPeriodStart != null) {
      final days = summary.daysUntilNextPeriod;
      final start = summary.nextPeriodStart!;
      final dt = DateTime(start.year, start.month, start.day);
      final formatted = DateFormat.MMMd().format(dt);
      return 'In $days ${days == 1 ? 'day' : 'days'} (~$formatted)';
    }
    return 'Log more periods for predictions';
  }

  Color _confidenceColor(CycleConfidence confidence, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return switch (confidence) {
      CycleConfidence.high =>
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B8755),
      CycleConfidence.moderate =>
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      CycleConfidence.low => theme.colorScheme.primary,
    };
  }
}

class _PrimaryActionsRow extends StatelessWidget {
  const _PrimaryActionsRow({required this.ongoingRecord});

  final CycleRecord? ongoingRecord;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final ongoing = ongoingRecord;

    return Row(
      children: [
        // Start or End Period Button
        Expanded(
          child: ongoing == null
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.cyclePhaseMenstrual,
                  ),
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text('Start Period'),
                  onPressed: () => PeriodEntryDialog.show(
                    context,
                    mode: PeriodEntryMode.logNew,
                  ),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.cyclePhaseMenstrual,
                  ),
                  icon: const Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.white,
                  ),
                  label: const Text('End Period'),
                  onPressed: () => PeriodEntryDialog.show(
                    context,
                    mode: PeriodEntryMode.endOngoing,
                    record: ongoing,
                  ),
                ),
        ),
        SizedBox(width: tokens.spacingSm),

        // Add Past Period Button
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.history),
            label: const Text('Add Past Period'),
            onPressed: () => PeriodEntryDialog.show(
              context,
              mode: PeriodEntryMode.logNew,
            ),
          ),
        ),
      ],
    );
  }
}

class _Disclaimers extends StatelessWidget {
  const _Disclaimers();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Text(
          'Cycle predictions and phase estimates are for informational '
          'lifestyle planning only, not medical advice.',
          textAlign: TextAlign.center,
          style: style,
        ),
        SizedBox(height: tokens.spacingXs),
        Text(
          'Your reproductive data is stored locally and securely on '
          'this device.',
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}
