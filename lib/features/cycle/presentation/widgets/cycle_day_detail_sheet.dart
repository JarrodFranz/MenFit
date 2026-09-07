import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/period_entry_controller.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/period_entry_dialog.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_widgets.dart';

/// Interactive bottom sheet opened when a user taps any calendar day.
class CycleDayDetailSheet extends ConsumerWidget {
  const CycleDayDetailSheet({
    required this.date,
    required this.status,
    required this.records,
    super.key,
  });

  final LocalDate date;
  final DayCycleStatus status;
  final List<CycleRecord> records;

  static Future<void> show(
    BuildContext context, {
    required LocalDate date,
    required DayCycleStatus status,
    required List<CycleRecord> records,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CycleDayDetailSheet(
        date: date,
        status: status,
        records: records,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final dt = DateTime(date.year, date.month, date.day);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(dt);
    final today = LocalDate.today();
    final isFuture = date.isAfter(today);

    final matchingRecord = status.associatedRecord;
    final checkin = isFuture
        ? null
        : ref.watch(checkinForDayProvider(date)).value;
    final flares = isFuture
        ? const <FlareEvent>[]
        : ref.watch(flaresOnDayProvider(date)).value ?? const <FlareEvent>[];
    final events = isFuture
        ? const <WellbeingEvent>[]
        : ref.watch(eventsOnDayProvider(date)).value ??
              const <WellbeingEvent>[];

    return SingleChildScrollView(
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
          // Header with Date
          Text(
            formattedDate,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingSm),

          // Status Badge
          _buildStatusBadge(context, tokens),
          SizedBox(height: tokens.spacingMd),

          // Actions
          if (status.isLoggedPeriod && matchingRecord != null) ...[
            // Period is already logged on this day
            FilledButton.icon(
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Edit This Period'),
              onPressed: () async {
                Navigator.of(context).pop();
                await PeriodEntryDialog.show(
                  context,
                  mode: PeriodEntryMode.editPast,
                  record: matchingRecord,
                );
              },
            ),
            if (matchingRecord.isOngoing) ...[
              SizedBox(height: tokens.spacingSm),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('End Period on This Day'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final updated = matchingRecord.copyWith(
                    periodEnd: date,
                    updatedAt: DateTime.now().toUtc(),
                  );
                  await ref.read(cycleRepositoryProvider).saveRecord(updated);
                },
              ),
            ],
            SizedBox(height: tokens.spacingSm),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete Period Log',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await _confirmDelete(context, ref, matchingRecord);
              },
            ),
          ] else if (status.isPredictedPeriod && !isFuture) ...[
            // Predicted period day in past or today -> one-tap confirm
            FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Period on This Day'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final rootContext = Navigator.of(
                  context,
                  rootNavigator: true,
                ).context;
                Navigator.of(context).pop();
                _promptCheckinIfMissing(
                  messenger: messenger,
                  rootContext: rootContext,
                  ref: ref,
                  date: date,
                );
                final now = DateTime.now().toUtc();
                final record = CycleRecord(
                  id: EntityId.generate(),
                  periodStart: date,
                  periodEnd: date.isBefore(today) ? date : null,
                  createdAt: now,
                  updatedAt: now,
                );
                await ref.read(cycleRepositoryProvider).saveRecord(record);
              },
            ),
            SizedBox(height: tokens.spacingSm),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Log Period with Custom Dates'),
              onPressed: () async {
                Navigator.of(context).pop();
                await PeriodEntryDialog.show(
                  context,
                  mode: PeriodEntryMode.logNew,
                );
              },
            ),
          ] else if (!isFuture) ...[
            // Standard past/today day -> log period
            FilledButton.icon(
              icon: const Icon(Icons.favorite, color: Colors.white),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.cyclePhaseMenstrual,
              ),
              label: const Text('Start Period on This Day'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final rootContext = Navigator.of(
                  context,
                  rootNavigator: true,
                ).context;
                Navigator.of(context).pop();
                _promptCheckinIfMissing(
                  messenger: messenger,
                  rootContext: rootContext,
                  ref: ref,
                  date: date,
                );
                final now = DateTime.now().toUtc();
                final record = CycleRecord(
                  id: EntityId.generate(),
                  periodStart: date,
                  createdAt: now,
                  updatedAt: now,
                );
                await ref.read(cycleRepositoryProvider).saveRecord(record);
              },
            ),
            SizedBox(height: tokens.spacingSm),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('Log Completed Period Range'),
              onPressed: () async {
                Navigator.of(context).pop();
                await PeriodEntryDialog.show(
                  context,
                  mode: PeriodEntryMode.logNew,
                );
              },
            ),
          ] else ...[
            // Future date -> Informational only
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: EdgeInsets.all(tokens.spacingMd),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: Text(
                        'This is a future date. When your period arrives, '
                        'tap here to log it.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (!isFuture) ...[
            SizedBox(height: tokens.spacingLg),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            SizedBox(height: tokens.spacingMd),
            Row(
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: tokens.spacingXs),
                Text(
                  'Wellbeing & Events',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),

            // Check-in card / button
            if (checkin != null && !checkin.isEmpty) ...[
              Card(
                margin: EdgeInsets.only(bottom: tokens.spacingSm),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingSm),
                  child: Row(
                    children: [
                      Icon(
                        checkinGlyph,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: tokens.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Check-in Logged',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatCheckinSummary(checkin),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await CheckinSheet.show(
                            context,
                            day: date,
                            existing: checkin,
                          );
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_note),
                label: const Text('Add Wellbeing Check-in'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await CheckinSheet.show(context, day: date);
                },
              ),
              SizedBox(height: tokens.spacingSm),
            ],

            // Flare-ups
            if (flares.isNotEmpty) ...[
              for (final flare in flares)
                Card(
                  margin: EdgeInsets.only(bottom: tokens.spacingSm),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingSm),
                    child: Row(
                      children: [
                        const Icon(
                          flareGlyph,
                          color: flareGlyphColor,
                          size: 20,
                        ),
                        SizedBox(width: tokens.spacingSm),
                        Expanded(
                          child: Text(
                            flare.notes?.isNotEmpty == true
                                ? 'Flare-up: ${flare.notes}'
                                : 'Flare-up logged',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await FlareDialog.show(
                              context,
                              existing: flare,
                              initialDay: date,
                            );
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              OutlinedButton.icon(
                icon: const Icon(flareGlyph),
                label: const Text('Log Flare-up'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FlareDialog.show(context, initialDay: date);
                },
              ),
              SizedBox(height: tokens.spacingSm),
            ],

            // Events
            if (events.isNotEmpty) ...[
              for (final event in events)
                Card(
                  margin: EdgeInsets.only(bottom: tokens.spacingSm),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingSm),
                    child: Row(
                      children: [
                        Icon(
                          _eventIcon(event.type),
                          color: _eventColor(event.type),
                          size: 20,
                        ),
                        SizedBox(width: tokens.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (event.notes?.isNotEmpty == true)
                                Text(
                                  event.notes!,
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await EventDialog.show(
                              context,
                              existing: event,
                              initialDay: date,
                            );
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            OutlinedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Log Life Event'),
              onPressed: () async {
                Navigator.of(context).pop();
                await EventDialog.show(context, initialDay: date);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AppTokens tokens) {
    final theme = Theme.of(context);

    if (status.isLoggedPeriod) {
      final daySuffix = status.cycleDayNumber != null
          ? ' (Day ${status.cycleDayNumber})'
          : '';
      return Container(
        padding: EdgeInsets.all(tokens.spacingMd),
        decoration: BoxDecoration(
          color: tokens.cyclePhaseMenstrual.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.cyclePhaseMenstrual),
        ),
        child: Row(
          children: [
            Icon(Icons.favorite, color: tokens.cyclePhaseMenstrual),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logged Period Day$daySuffix',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.cyclePhaseMenstrual,
                    ),
                  ),
                  Text(
                    status.associatedRecord?.isOngoing ?? false
                        ? 'Ongoing period log'
                        : 'Confirmed period entry',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status.isPredictedPeriod) {
      return Container(
        padding: EdgeInsets.all(tokens.spacingMd),
        decoration: BoxDecoration(
          color: tokens.cyclePhaseMenstrual.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.cyclePhaseMenstrual),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: tokens.cyclePhaseMenstrual),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Predicted Period',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.cyclePhaseMenstrual,
                    ),
                  ),
                  Text(
                    'Estimated based on your cycle median.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Other phases
    final (phaseColor, phaseTitle, phaseDesc) = switch (status.phase) {
      CyclePhase.follicular => (
        tokens.cyclePhaseFollicular,
        'Follicular Phase',
        'Energy begins rising; body prepares an egg.',
      ),
      CyclePhase.ovulatory => (
        tokens.cyclePhaseOvulatory,
        'Ovulatory Window '
            '${status.isOvulationDay ? '(Estimated Ovulation)' : ''}',
        'Peak estrogen and LH surge.',
      ),
      CyclePhase.luteal => (
        tokens.cyclePhaseLuteal,
        'Luteal Phase',
        'Progesterone peak; premenstrual phase.',
      ),
      _ => (
        theme.colorScheme.outline,
        'Between Cycles',
        'Standard non-period tracking day.',
      ),
    };

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: phaseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: phaseColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phaseTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: phaseColor,
                  ),
                ),
                Text(
                  phaseDesc,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CycleRecord record,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this period log?'),
        content: const Text(
          'This will permanently delete this period record from your device. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
              await ref.read(cycleRepositoryProvider).deleteRecord(record.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatCheckinSummary(DailyCheckin c) {
    final parts = <String>[];
    if (c.energy != null) parts.add('Energy: ${c.energy}/5');
    if (c.sleep != null) parts.add('Sleep: ${c.sleep}/5');
    if (c.soreness != null) parts.add('Soreness: ${c.soreness}/5');
    if (c.pain != null) parts.add('Pain: ${c.pain}/5');
    if (c.stress != null) parts.add('Stress: ${c.stress}/5');
    if (parts.isEmpty) return 'Check-in details logged';
    return parts.join(' · ');
  }

  IconData _eventIcon(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => intimacyGlyph,
    WellbeingEventType.injury => injuryGlyph,
    WellbeingEventType.holiday => holidayGlyph,
    WellbeingEventType.other => otherEventGlyph,
  };

  Color _eventColor(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => intimacyGlyphColor,
    WellbeingEventType.injury => injuryGlyphColor,
    WellbeingEventType.holiday => holidayGlyphColor,
    WellbeingEventType.other => otherEventGlyphColor,
  };

  void _promptCheckinIfMissing({
    required ScaffoldMessengerState messenger,
    required BuildContext rootContext,
    required WidgetRef ref,
    required LocalDate date,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(wellbeingRepositoryProvider);
      final checkin = await repo.getCheckinFor(date);
      if ((checkin == null || checkin.isEmpty) && rootContext.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
              'Period logged. Would you like to log your wellbeing check-in?',
            ),
            action: SnackBarAction(
              label: 'Check in',
              onPressed: () {
                if (rootContext.mounted) {
                  unawaited(CheckinSheet.show(rootContext, day: date));
                }
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }
}
