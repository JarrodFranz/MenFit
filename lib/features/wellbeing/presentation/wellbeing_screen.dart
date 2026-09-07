import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/event_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/mark_recovery_day_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_watch_providers.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/history_tiles.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_calendar.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';

/// `/wellbeing` — the last 30 days of check-ins, flare-ups, and recovery
/// days, interleaved by day (newest first). Logging a flare-up is this
/// tab's primary action (the floating button); marking recovery days is the
/// app-bar action. Tapping a check-in or flare row re-opens the same
/// sheet/dialog used to log it, pre-filled for editing; a recovery-day row's
/// own "Remove" action is its only interaction (there's no separate edit
/// form for a recovery day's note — re-marking the same day from the app-bar
/// action replaces it, same upsert-by-day convention as
/// `RecoveryRepository.markRecoveryDay`).
///
/// Importing `streaks/streaks_providers.dart` and
/// `streaks/domain/recovery_day_entry.dart` here (and from
/// `widgets/history_tiles.dart`) is ADR-007-legal: the providers file is
/// that feature's composition surface, and domain types are freely
/// importable across features per `architecture_overview.md` rule 2.
class WellbeingScreen extends ConsumerWidget {
  const WellbeingScreen({super.key});

  static const int historyDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();
    final checkinsAsync = ref.watch(recentCheckinsProvider(historyDays));
    final flaresAsync = ref.watch(recentFlaresProvider(historyDays));
    final recoveryDaysAsync = ref.watch(recoveryDayEntriesProvider);
    final eventsAsync = ref.watch(
      eventsForRangeProvider(today.addDays(-(historyDays - 1)), today),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing'),
        actions: [
          IconButton(
            key: const Key('wellbeingLogCheckinAction'),
            icon: const Icon(Icons.edit_note_outlined),
            tooltip: 'Log today’s check-in',
            onPressed: () => CheckinSheet.show(context, day: today),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Log life event',
            onPressed: () => EventDialog.show(context, initialDay: today),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Mark recovery days',
            onPressed: () => MarkRecoveryDayDialog.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => FlareDialog.show(context),
        icon: const Icon(Icons.local_fire_department_outlined),
        label: const Text('Log a flare-up'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: _Body(
              checkinsAsync: checkinsAsync,
              flaresAsync: flaresAsync,
              recoveryDaysAsync: recoveryDaysAsync,
              eventsAsync: eventsAsync,
            ),
          ),
        ),
      ),
    );
  }
}

enum WellbeingRange {
  day1,
  days7,
  days14,
  days30;

  int get days => switch (this) {
    WellbeingRange.day1 => 1,
    WellbeingRange.days7 => 7,
    WellbeingRange.days14 => 14,
    WellbeingRange.days30 => 30,
  };

  String get label => switch (this) {
    WellbeingRange.day1 => '1 Day',
    WellbeingRange.days7 => '7 Days',
    WellbeingRange.days14 => '14 Days',
    WellbeingRange.days30 => '30 Days',
  };
}

class _Body extends StatefulWidget {
  const _Body({
    required this.checkinsAsync,
    required this.flaresAsync,
    required this.recoveryDaysAsync,
    required this.eventsAsync,
  });

  final AsyncValue<List<DailyCheckin>> checkinsAsync;
  final AsyncValue<List<FlareEvent>> flaresAsync;
  final AsyncValue<List<RecoveryDayEntry>> recoveryDaysAsync;
  final AsyncValue<List<WellbeingEvent>> eventsAsync;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  WellbeingRange _selectedRange = WellbeingRange.days7;

  @override
  Widget build(BuildContext context) {
    if (widget.checkinsAsync.isLoading ||
        widget.flaresAsync.isLoading ||
        widget.recoveryDaysAsync.isLoading ||
        widget.eventsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final firstError =
        widget.checkinsAsync.error ??
        widget.flaresAsync.error ??
        widget.recoveryDaysAsync.error ??
        widget.eventsAsync.error;
    if (firstError != null) {
      return Center(child: Text(userMessageFor(firstError)));
    }

    final tokens = Theme.of(context).extension<AppTokens>()!;
    final cutoff = LocalDate.today().addDays(
      -(WellbeingScreen.historyDays - 1),
    );
    final entries = [
      for (final checkin
          in widget.checkinsAsync.value ?? const <DailyCheckin>[])
        if (!checkin.isEmpty) _HistoryEntry.checkin(checkin),
      for (final flare in widget.flaresAsync.value ?? const <FlareEvent>[])
        _HistoryEntry.flare(flare),
      for (final recovery
          in widget.recoveryDaysAsync.value ?? const <RecoveryDayEntry>[])
        if (!recovery.day.isBefore(cutoff)) _HistoryEntry.recovery(recovery),
      for (final event in widget.eventsAsync.value ?? const <WellbeingEvent>[])
        _HistoryEntry.event(event),
    ]..sort((a, b) => b.day.compareTo(a.day));

    final todayCheckin = (widget.checkinsAsync.value ?? const <DailyCheckin>[])
        .where((c) => c.day == LocalDate.today() && !c.isEmpty)
        .firstOrNull;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        // Range Overview (1, 7, 14, 30 days)
        _RangeSummaryCard(
          selectedRange: _selectedRange,
          onRangeChanged: (r) => setState(() => _selectedRange = r),
          checkins: widget.checkinsAsync.value ?? const [],
          flares: widget.flaresAsync.value ?? const [],
          events: widget.eventsAsync.value ?? const [],
        ),
        SizedBox(height: tokens.spacingMd),

        // The month at a glance, above the list it summarises.
        const WellbeingCalendar(),
        SizedBox(height: tokens.spacingMd),
        _LogCheckinButton(existing: todayCheckin),
        SizedBox(height: tokens.spacingMd),
        if (entries.isEmpty)
          const WellbeingEmptyState()
        else
          for (final entry in entries)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: entry.checkin != null
                  ? CheckinTile(checkin: entry.checkin!)
                  : entry.flare != null
                  ? FlareTile(flare: entry.flare!)
                  : entry.recovery != null
                  ? RecoveryTile(entry: entry.recovery!)
                  : _EventHistoryTile(event: entry.event!),
            ),
        SizedBox(height: tokens.spacingLg),
        const WellbeingDisclaimers(),
        SizedBox(height: tokens.spacingXl * 2),
      ],
    );
  }
}

class _RangeSummaryCard extends StatelessWidget {
  const _RangeSummaryCard({
    required this.selectedRange,
    required this.onRangeChanged,
    required this.checkins,
    required this.flares,
    required this.events,
  });

  final WellbeingRange selectedRange;
  final ValueChanged<WellbeingRange> onRangeChanged;
  final List<DailyCheckin> checkins;
  final List<FlareEvent> flares;
  final List<WellbeingEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final today = LocalDate.today();
    final cutoff = today.addDays(-(selectedRange.days - 1));

    final filteredCheckins = checkins
        .where(
          (c) => !c.day.isBefore(cutoff) && !c.day.isAfter(today) && !c.isEmpty,
        )
        .toList();
    final filteredFlares = flares
        .where((f) => !f.day.isBefore(cutoff) && !f.day.isAfter(today))
        .toList();
    final filteredEvents = events
        .where((e) => !e.day.isBefore(cutoff) && !e.day.isAfter(today))
        .toList();

    double? avg(List<int?> scores) {
      final valid = scores.whereType<int>().toList();
      if (valid.isEmpty) return null;
      return valid.fold(0, (a, b) => a + b) / valid.length;
    }

    final avgEnergy = avg(filteredCheckins.map((c) => c.energy).toList());
    final avgSleep = avg(filteredCheckins.map((c) => c.sleep).toList());
    final avgSoreness = avg(
      filteredCheckins.map((c) => c.soreness).toList(),
    );
    final avgPain = avg(filteredCheckins.map((c) => c.pain).toList());
    final avgStress = avg(filteredCheckins.map((c) => c.stress).toList());

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: tokens.spacingSm),
                Text(
                  'Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Center(
              child: SegmentedButton<WellbeingRange>(
                segments: [
                  for (final r in WellbeingRange.values)
                    ButtonSegment(
                      value: r,
                      label: Text(
                        r.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
                selected: {selectedRange},
                onSelectionChanged: (set) => onRangeChanged(set.first),
                showSelectedIcon: false,
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            if (filteredCheckins.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacingSm),
                child: Text(
                  'No check-ins logged in the last '
                  '${selectedRange.label.toLowerCase()}. '
                  'Log today’s check-in to see your trends.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else ...[
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: tokens.spacingSm,
                runSpacing: tokens.spacingSm,
                children: [
                  if (avgEnergy != null)
                    _MetricChip(
                      icon: Icons.bolt,
                      label: 'Energy',
                      value: '${avgEnergy.toStringAsFixed(1)}/5',
                      color: tokens.success,
                    ),
                  if (avgSleep != null)
                    _MetricChip(
                      icon: Icons.bedtime_outlined,
                      label: 'Sleep',
                      value: '${avgSleep.toStringAsFixed(1)}/5',
                      color: theme.colorScheme.primary,
                    ),
                  if (avgSoreness != null)
                    _MetricChip(
                      icon: Icons.fitness_center_outlined,
                      label: 'Soreness',
                      value: '${avgSoreness.toStringAsFixed(1)}/5',
                      color: tokens.intensityModerate,
                    ),
                  if (avgPain != null)
                    _MetricChip(
                      icon: Icons.healing_outlined,
                      label: 'Pain',
                      value: '${avgPain.toStringAsFixed(1)}/5',
                      color: tokens.intensityHard,
                    ),
                  if (avgStress != null)
                    _MetricChip(
                      icon: Icons.psychology_outlined,
                      label: 'Stress',
                      value: '${avgStress.toStringAsFixed(1)}/5',
                      color: tokens.warning,
                    ),
                ],
              ),
              if (filteredFlares.isNotEmpty || filteredEvents.isNotEmpty) ...[
                SizedBox(height: tokens.spacingSm),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                SizedBox(height: tokens.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (filteredFlares.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            flareGlyph,
                            size: 16,
                            color: flareGlyphColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            filteredFlares.length == 1
                                ? '1 flare-up'
                                : '${filteredFlares.length} flare-ups',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    if (filteredEvents.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            otherEventGlyph,
                            size: 16,
                            color: otherEventGlyphColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            filteredEvents.length == 1
                                ? '1 event'
                                : '${filteredEvents.length} events',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventHistoryTile extends StatelessWidget {
  const _EventHistoryTile({required this.event});

  final WellbeingEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _glyphAndColor(event.type);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          event.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: event.notes?.isNotEmpty == true
            ? Text(event.notes!)
            : Text(
                'Logged on ${event.day.day}/${event.day.month}/${event.day.year}',
              ),
        trailing: TextButton(
          onPressed: () => EventDialog.show(
            context,
            existing: event,
            initialDay: event.day,
          ),
          child: const Text('Edit'),
        ),
      ),
    );
  }

  (IconData, Color) _glyphAndColor(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => (intimacyGlyph, intimacyGlyphColor),
    WellbeingEventType.injury => (injuryGlyph, injuryGlyphColor),
    WellbeingEventType.holiday => (holidayGlyph, holidayGlyphColor),
    WellbeingEventType.other => (otherEventGlyph, otherEventGlyphColor),
  };
}

class _LogCheckinButton extends StatelessWidget {
  const _LogCheckinButton({required this.existing});

  final DailyCheckin? existing;

  @override
  Widget build(BuildContext context) {
    final logged = existing != null;
    return FilledButton.tonalIcon(
      key: const Key('wellbeingLogCheckinButton'),
      onPressed: () => CheckinSheet.show(
        context,
        day: LocalDate.today(),
        existing: existing,
      ),
      icon: Icon(logged ? Icons.edit_outlined : Icons.edit_note_outlined),
      label: Text(
        logged ? 'Revisit today’s check-in' : 'Log today’s check-in',
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry.checkin(this.checkin)
    : flare = null,
      recovery = null,
      event = null;
  const _HistoryEntry.flare(this.flare)
    : checkin = null,
      recovery = null,
      event = null;
  const _HistoryEntry.recovery(this.recovery)
    : checkin = null,
      flare = null,
      event = null;
  const _HistoryEntry.event(this.event)
    : checkin = null,
      flare = null,
      recovery = null;

  final DailyCheckin? checkin;
  final FlareEvent? flare;
  final RecoveryDayEntry? recovery;
  final WellbeingEvent? event;

  LocalDate get day =>
      checkin?.day ?? flare?.day ?? recovery?.day ?? event!.day;
}
