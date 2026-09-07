import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/event_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_watch_providers.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/history_tiles.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_day_details.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_load_failure.dart';

/// One day of the Wellbeing tab, opened by tapping a day in the calendar:
/// what was checked in, what flare-ups covered it, and whether it was
/// marked as recovery.
///
/// **Read-mostly, and it builds no editors of its own.** Every way out of
/// it is an existing flow: the check-in section opens [CheckinSheet] for
/// this day, a flare row opens `FlareDialog` through the same [FlareTile]
/// the history list uses, and the recovery row is [RecoveryTile] with its
/// own remove-and-undo affordance. A second set of editors would be a
/// second set of validation rules to keep in step.
///
/// Launched from a shell tab, so it opens through [showAppBottomSheet]
/// (`knowledge/architecture/architecture_overview.md`) — that wrapper owns
/// the root navigator and the system nav-bar inset for every sheet.
class WellbeingDaySheet extends ConsumerWidget {
  const WellbeingDaySheet({required this.day, super.key});

  final LocalDate day;

  static Future<void> show(BuildContext context, {required LocalDate day}) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => WellbeingDaySheet(day: day),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isFuture = day.isAfter(LocalDate.today());

    // Nothing is watched for a day that has not happened: there is
    // provably nothing to find, and `isFuture` is fixed for this widget's
    // whole life (the day is final), so the conditional watch is stable.
    final checkinAsync = isFuture
        ? const AsyncValue<DailyCheckin?>.data(null)
        : ref.watch(checkinForDayProvider(day));
    final flaresAsync = isFuture
        ? const AsyncValue<List<FlareEvent>>.data(<FlareEvent>[])
        : ref.watch(flaresOnDayProvider(day));
    final recoveryAsync = isFuture
        ? const AsyncValue<List<RecoveryDayEntry>>.data(<RecoveryDayEntry>[])
        : ref.watch(recoveryDayEntriesProvider);
    final eventsAsync = isFuture
        ? const AsyncValue<List<WellbeingEvent>>.data(<WellbeingEvent>[])
        : ref.watch(eventsOnDayProvider(day));

    final cycleRecords =
        ref.watch(cycleRecordsControllerProvider).value ??
        const <CycleRecord>[];
    final cycleStatus = CyclePredictionEngine().getDayStatus(
      date: day,
      records: cycleRecords,
      today: LocalDate.today(),
    );

    // Same reasoning as the calendar's: for health data, a failed read
    // must not be shown as "nothing logged".
    final failed =
        checkinAsync.hasError ||
        flaresAsync.hasError ||
        recoveryAsync.hasError ||
        eventsAsync.hasError;

    final checkin = checkinAsync.value;
    final flares = flaresAsync.value ?? const <FlareEvent>[];
    final recovery = _recoveryIn(recoveryAsync.value, day);
    final events = eventsAsync.value ?? const <WellbeingEvent>[];

    return Align(
      alignment: Alignment.topCenter,
      // `Align` fills whatever the sheet offers unless told not to, which
      // would make a nearly-empty day open full-screen. `heightFactor: 1`
      // sizes it to the scroll view, which itself shrink-wraps its content
      // up to the sheet's maximum — so a short day is a short sheet and a
      // full one still scrolls.
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            tokens.spacingLg,
            0,
            tokens.spacingLg,
            tokens.spacingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat(
                  'EEEE d MMMM y',
                ).format(DateTime(day.year, day.month, day.day)),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.spacingMd),
              if (isFuture)
                const FutureDayNotice()
              else ...[
                if (failed) ...[
                  const WellbeingLoadFailure(text: "Couldn't load this day."),
                  SizedBox(height: tokens.spacingMd),
                ],
                _CycleSection(day: day, status: cycleStatus),
                SizedBox(height: tokens.spacingLg),
                CheckinSection(day: day, checkin: checkin),
                SizedBox(height: tokens.spacingLg),
                _FlareSection(day: day, flares: flares),
                SizedBox(height: tokens.spacingLg),
                _EventsSection(day: day, events: events),
                SizedBox(height: tokens.spacingLg),
                _RecoverySection(day: day, entry: recovery),
              ],
            ],
          ),
        ),
      ),
    );
  }

  RecoveryDayEntry? _recoveryIn(
    List<RecoveryDayEntry>? entries,
    LocalDate day,
  ) {
    for (final entry in entries ?? const <RecoveryDayEntry>[]) {
      if (entry.day == day) return entry;
    }
    return null;
  }
}

class _FlareSection extends StatelessWidget {
  const _FlareSection({required this.day, required this.flares});

  final LocalDate day;
  final List<FlareEvent> flares;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          label: flares.length > 1 ? 'Flare-ups' : 'Flare-up',
        ),
        SizedBox(height: tokens.spacingSm),
        if (flares.isEmpty)
          const SectionEmptyText('No flare-up logged.')
        else
          for (final flare in flares)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: FlareTile(key: ValueKey(flare.id), flare: flare),
            ),
        // Outside the empty branch: more than one flare can be logged for
        // the same day (`WellbeingRepository.saveFlare`), so a day that
        // already has one must still be able to take another.
        //
        // Both today and past days offer "Log a flare-up", seeded with this
        // day. Days in the future do not (guarded in the outer day sheet).
        if (!day.isAfter(LocalDate.today())) ...[
          SizedBox(height: tokens.spacingSm),
          LogFlareButton(day: day),
        ],
      ],
    );
  }
}

class _RecoverySection extends StatelessWidget {
  const _RecoverySection({required this.day, required this.entry});

  final LocalDate day;
  final RecoveryDayEntry? entry;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final marked = entry;
    // Captured here, at build time: the callback below runs after an
    // await, by which point reading a BuildContext would be unsafe.
    final navigator = Navigator.of(context, rootNavigator: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(label: 'Recovery day'),
        SizedBox(height: tokens.spacingSm),
        if (marked == null) ...[
          const SectionEmptyText('Not marked as a recovery day.'),
          SizedBox(height: tokens.spacingSm),
          // Unlike the flare dialog, `MarkRecoveryDayDialog` can be opened
          // on a chosen day, so this works for any day up to today — and
          // marking an earlier day retroactively is the whole point of
          // that dialog (`mark_recovery_day_dialog.dart`).
          MarkRecoveryDayButton(day: day),
        ] else
          RecoveryTile(
            entry: marked,
            // This sheet covers the root Scaffold's snackbar area, so the
            // removal's Undo would be unreachable while it is open. Same
            // resolution the streak card's Today sheet already reaches for
            // this exact action (`home/presentation/widgets/today_sheet.dart`):
            // the sheet closes and the snackbar lands in the clear.
            onRemoved: () {
              if (navigator.canPop()) navigator.pop();
            },
          ),
      ],
    );
  }
}

class _CycleSection extends StatelessWidget {
  const _CycleSection({required this.day, required this.status});

  final LocalDate day;
  final DayCycleStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isDark = theme.brightness == Brightness.dark;

    final (color, title, desc) = switch (status.phase) {
      CyclePhase.menstrual => (
        tokens.cyclePhaseMenstrual,
        status.cycleDayNumber != null
            ? 'Menstrual Phase · Day ${status.cycleDayNumber}'
            : 'Menstrual Phase',
        status.isLoggedPeriod
            ? 'Logged period day'
            : status.phase.plainDescription,
      ),
      CyclePhase.follicular => (
        tokens.cyclePhaseFollicular,
        status.cycleDayNumber != null
            ? 'Follicular Phase · Day ${status.cycleDayNumber}'
            : 'Follicular Phase',
        status.phase.plainDescription,
      ),
      CyclePhase.ovulatory => (
        tokens.cyclePhaseOvulatory,
        status.cycleDayNumber != null
            ? 'Ovulatory Window · Day ${status.cycleDayNumber}'
            : 'Ovulatory Window',
        status.phase.plainDescription,
      ),
      CyclePhase.luteal => (
        tokens.cyclePhaseLuteal,
        status.cycleDayNumber != null
            ? 'Luteal Phase · Day ${status.cycleDayNumber}'
            : 'Luteal Phase',
        status.phase.plainDescription,
      ),
      _ => (
        theme.colorScheme.outline,
        'Cycle Tracking',
        'No cycle phase calculated for this day.',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(label: 'Cycle context'),
        SizedBox(height: tokens.spacingSm),
        Container(
          padding: EdgeInsets.all(tokens.spacingMd),
          decoration: BoxDecoration(
            color: isDark
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.4 : 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: color, size: 20),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      desc,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection({required this.day, required this.events});

  final LocalDate day;
  final List<WellbeingEvent> events;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    final isFuture = day.isAfter(LocalDate.today());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          label: events.length > 1 ? 'Life events' : 'Life event',
        ),
        SizedBox(height: tokens.spacingSm),
        if (events.isEmpty)
          const SectionEmptyText('No life events logged.')
        else
          for (final event in events)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(
                    _iconForEvent(event.type),
                    color: _colorForEvent(event.type),
                  ),
                  title: Text(
                    event.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: event.notes?.isNotEmpty == true
                      ? Text(event.notes!)
                      : null,
                  trailing: TextButton(
                    onPressed: () => EventDialog.show(
                      context,
                      existing: event,
                      initialDay: day,
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ),
            ),
        if (!isFuture) ...[
          SizedBox(height: tokens.spacingSm),
          OutlinedButton.icon(
            onPressed: () => EventDialog.show(context, initialDay: day),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Log an event'),
          ),
        ],
      ],
    );
  }

  IconData _iconForEvent(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => intimacyGlyph,
    WellbeingEventType.injury => injuryGlyph,
    WellbeingEventType.holiday => holidayGlyph,
    WellbeingEventType.other => otherEventGlyph,
  };

  Color _colorForEvent(WellbeingEventType type) => switch (type) {
    WellbeingEventType.intimacy => intimacyGlyphColor,
    WellbeingEventType.injury => injuryGlyphColor,
    WellbeingEventType.holiday => holidayGlyphColor,
    WellbeingEventType.other => otherEventGlyphColor,
  };
}
