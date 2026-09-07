import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/month_calendar.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_day_semantics.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_day_detail_sheet.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/dotted_circle_painter.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_widgets.dart';

/// Monthly cycle calendar with swipe & arrow navigation, jump-to-today,
/// distinct solid (logged) vs dotted (predicted) days, tap-to-log sheet,
/// and optional wellbeing overlay.
class CycleCalendarView extends ConsumerStatefulWidget {
  const CycleCalendarView({
    required this.records,
    required this.predictionEngine,
    required this.confidence,
    this.enhancedSemantics = false,
    this.showWellbeingOverlay = false,
    super.key,
  });

  final List<CycleRecord> records;
  final CyclePredictionEngine predictionEngine;

  /// Confidence in the estimates this calendar draws.
  final CycleConfidence confidence;

  final bool enhancedSemantics;

  /// Whether wellbeing check-in, flare, and event icons overlay calendar days.
  final bool showWellbeingOverlay;

  @override
  ConsumerState<CycleCalendarView> createState() => _CycleCalendarViewState();
}

class _CycleCalendarViewState extends ConsumerState<CycleCalendarView> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  DayCycleStatus _statusFor(LocalDate date, LocalDate today) {
    return widget.predictionEngine.getDayStatus(
      date: date,
      records: widget.records,
      today: today,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final today = LocalDate.today();

    final showWellbeing = widget.showWellbeingOverlay;
    var checkinDays = const <LocalDate>{};
    var flareDays = const <LocalDate>{};
    var eventsByDay = const <LocalDate, List<WellbeingEventType>>{};

    if (showWellbeing) {
      final (first: from, last: to) = monthCalendarGridRange(_displayedMonth);
      final checkins =
          ref.watch(checkinsForRangeProvider(from, to)).value ??
          const <DailyCheckin>[];
      final flares =
          ref.watch(flaresForRangeProvider(from, to)).value ??
          const <FlareEvent>[];
      final events =
          ref.watch(eventsForRangeProvider(from, to)).value ??
          const <WellbeingEvent>[];

      checkinDays = {
        for (final c in checkins)
          if (!c.isEmpty) c.day,
      };
      flareDays = {
        for (final f in flares) ...f.days,
      };
      final mappedEvents = <LocalDate, List<WellbeingEventType>>{};
      for (final e in events) {
        mappedEvents.putIfAbsent(e.day, () => []).add(e.type);
      }
      eventsByDay = mappedEvents;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          children: [
            MonthCalendar(
              month: _displayedMonth,
              today: today,
              onMonthChanged: (month) =>
                  setState(() => _displayedMonth = month),
              onDayTap: (date) async {
                await CycleDayDetailSheet.show(
                  context,
                  date: date,
                  status: _statusFor(date, today),
                  records: widget.records,
                );
              },
              cellBuilder: (day) {
                final status = _statusFor(day.date, today);
                return MonthCalendarCell(
                  semanticsLabel: widget.enhancedSemantics
                      ? cycleDaySemanticLabel(
                          status: status,
                          isToday: day.isToday,
                          confidence: widget.confidence,
                        )
                      : null,
                  child: _DayGridCell(
                    dayNumber: day.date.day,
                    isCurrentMonth: day.isCurrentMonth,
                    isToday: day.isToday,
                    status: status,
                    tokens: tokens,
                    showWellbeingOverlay: showWellbeing,
                    hasCheckin: checkinDays.contains(day.date),
                    hasFlare: flareDays.contains(day.date),
                    events: eventsByDay[day.date] ?? const [],
                  ),
                );
              },
            ),

            SizedBox(height: tokens.spacingMd),
            const Divider(height: 1),
            SizedBox(height: tokens.spacingSm),

            // Visual Legend
            _buildLegend(context, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, AppTokens tokens) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        // Logged Period (Solid circle)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: tokens.cyclePhaseMenstrual,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text('Logged period', style: theme.textTheme.bodySmall),
          ],
        ),

        // Predicted Period (Dotted circle)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(10, 10),
              painter: DottedCirclePainter(
                color: tokens.cyclePhaseMenstrual,
                fillColor: tokens.cyclePhaseMenstrual.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: 5),
            Text('Predicted period', style: theme.textTheme.bodySmall),
          ],
        ),

        // Follicular (Horizontal pill/dash marker)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 3,
              decoration: BoxDecoration(
                color: tokens.cyclePhaseFollicular,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 5),
            Text('Follicular', style: theme.textTheme.bodySmall),
          ],
        ),

        // Ovulation Window (Diamond marker)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: tokens.cyclePhaseOvulatory,
                  borderRadius: BorderRadius.circular(0.8),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text('Ovulation', style: theme.textTheme.bodySmall),
          ],
        ),

        // Luteal Phase (Double-dot marker)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: tokens.cyclePhaseLuteal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: tokens.cyclePhaseLuteal,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 5),
            Text('Luteal', style: theme.textTheme.bodySmall),
          ],
        ),

        if (widget.showWellbeingOverlay) ...[
          // Check-in (small dot)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text('Check-in', style: theme.textTheme.bodySmall),
            ],
          ),
          // Flare-up
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(flareGlyph, size: 10, color: flareGlyphColor),
              const SizedBox(width: 5),
              Text('Flare-up', style: theme.textTheme.bodySmall),
            ],
          ),
          // Intimacy
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(intimacyGlyph, size: 10, color: intimacyGlyphColor),
              const SizedBox(width: 5),
              Text('Intimacy', style: theme.textTheme.bodySmall),
            ],
          ),
          // Injury
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(injuryGlyph, size: 10, color: injuryGlyphColor),
              const SizedBox(width: 5),
              Text('Injury', style: theme.textTheme.bodySmall),
            ],
          ),
          // Holiday
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(holidayGlyph, size: 10, color: holidayGlyphColor),
              const SizedBox(width: 5),
              Text('Holiday', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ],
    );
  }
}

/// One day's drawing inside a [MonthCalendar] cell.
class _DayGridCell extends StatelessWidget {
  const _DayGridCell({
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.isToday,
    required this.status,
    required this.tokens,
    this.showWellbeingOverlay = false,
    this.hasCheckin = false,
    this.hasFlare = false,
    this.events = const [],
  });

  final int dayNumber;
  final bool isCurrentMonth;
  final bool isToday;
  final DayCycleStatus status;
  final AppTokens tokens;
  final bool showWellbeingOverlay;
  final bool hasCheckin;
  final bool hasFlare;
  final List<WellbeingEventType> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textColor = isCurrentMonth
        ? (status.isLoggedPeriod ? Colors.white : theme.colorScheme.onSurface)
        : theme.colorScheme.outline.withValues(alpha: 0.4);

    final content = Center(
      child: Text(
        '$dayNumber',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: (isToday || status.isLoggedPeriod)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );

    Widget baseWidget;

    // 1. Logged Period: Solid badge
    if (status.isLoggedPeriod) {
      baseWidget = Container(
        decoration: BoxDecoration(
          color: tokens.cyclePhaseMenstrual,
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: theme.colorScheme.onSurface, width: 2)
              : null,
        ),
        child: content,
      );
    } else if (status.isPredictedPeriod) {
      // 2. Predicted Period: Light tinted + Dotted border
      baseWidget = CustomPaint(
        painter: DottedCirclePainter(
          color: tokens.cyclePhaseMenstrual,
          fillColor: tokens.cyclePhaseMenstrual.withValues(alpha: 0.18),
          isToday: isToday,
          todayBorderColor: theme.colorScheme.primary,
        ),
        child: content,
      );
    } else {
      // 3. Other Phases or Normal Day
      baseWidget = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            content,
            if (isCurrentMonth && status.isOvulationDay)
              Positioned(
                bottom: 3,
                child: Transform.rotate(
                  angle: 0.785398,
                  child: Container(
                    key: const Key('cycleCalendarOvulationMarker'),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: tokens.cyclePhaseOvulatory,
                      borderRadius: BorderRadius.circular(0.8),
                    ),
                  ),
                ),
              )
            else if (isCurrentMonth && status.phase == CyclePhase.ovulatory)
              Positioned(
                bottom: 3,
                child: Transform.rotate(
                  angle: 0.785398,
                  child: Container(
                    key: const Key(
                      'cycleCalendarOvulatoryWindowMarker',
                    ),
                    width: 3.5,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: tokens.cyclePhaseOvulatory.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(0.6),
                    ),
                  ),
                ),
              )
            else if (isCurrentMonth && status.phase == CyclePhase.follicular)
              Positioned(
                bottom: 3,
                child: Container(
                  key: const Key('cycleCalendarFollicularMarker'),
                  width: 7,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: tokens.cyclePhaseFollicular,
                    borderRadius: BorderRadius.circular(1.25),
                  ),
                ),
              )
            else if (isCurrentMonth && status.phase == CyclePhase.luteal)
              Positioned(
                bottom: 3,
                child: Row(
                  key: const Key('cycleCalendarLutealMarker'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: tokens.cyclePhaseLuteal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: tokens.cyclePhaseLuteal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    if (!showWellbeingOverlay || (!hasCheckin && !hasFlare && events.isEmpty)) {
      return baseWidget;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        baseWidget,
        Positioned(
          top: 2,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasCheckin)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: status.isLoggedPeriod
                        ? Colors.white
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              if (hasFlare)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.5),
                  child: Icon(
                    flareGlyph,
                    size: 8,
                    color: flareGlyphColor,
                  ),
                ),
              for (final event in events)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.5),
                  child: Icon(
                    switch (event) {
                      WellbeingEventType.intimacy => intimacyGlyph,
                      WellbeingEventType.injury => injuryGlyph,
                      WellbeingEventType.holiday => holidayGlyph,
                      WellbeingEventType.other => otherEventGlyph,
                    },
                    size: 8,
                    color: switch (event) {
                      WellbeingEventType.intimacy => intimacyGlyphColor,
                      WellbeingEventType.injury => injuryGlyphColor,
                      WellbeingEventType.holiday => holidayGlyphColor,
                      WellbeingEventType.other => otherEventGlyphColor,
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
