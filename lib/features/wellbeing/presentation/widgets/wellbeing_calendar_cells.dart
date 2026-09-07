import 'package:flutter/material.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';

// The day cell and the legend `widgets/wellbeing_calendar.dart` draws,
// split out to keep that file to the calendar's own composition and data
// wiring (`coding_standards.md`'s ~300-line rule).

/// One day's drawing: the date, and beneath it a marker for each of the
/// things that can be logged on it.
class WellbeingDayCell extends StatelessWidget {
  const WellbeingDayCell({
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.isToday,
    required this.hasCheckin,
    required this.hasFlare,
    required this.isRecoveryDay,
    this.events = const [],
    super.key,
  });

  /// Marker glyphs are drawn at this size at 100% text scale.
  static const double markerSize = 10;

  final int dayNumber;
  final bool isCurrentMonth;
  final bool isToday;
  final bool hasCheckin;
  final bool hasFlare;
  final bool isRecoveryDay;
  final List<WellbeingEventType> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textColor = isCurrentMonth
        ? colorScheme.onSurface
        : colorScheme.outline.withValues(alpha: 0.4);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      // A seven-column grid gets narrow fast, and the cell carries a number
      // *and* up to three glyphs. Scaling the whole stack down is the one
      // response that keeps every marker visible at 320dp/150% instead of
      // dropping one or overflowing (same instinct as the numeric stat
      // values in `knowledge/engineering/accessibility.md`).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$dayNumber',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCheckin)
                    Icon(
                      checkinGlyph,
                      size: markerSize,
                      color: colorScheme.primary,
                    ),
                  if (hasFlare)
                    const Icon(
                      flareGlyph,
                      size: markerSize,
                      color: flareGlyphColor,
                    ),
                  if (isRecoveryDay)
                    const Icon(
                      recoveryGlyph,
                      size: markerSize,
                      color: recoveryGlyphColor,
                    ),
                  for (final event in events)
                    Icon(
                      switch (event) {
                        WellbeingEventType.intimacy => intimacyGlyph,
                        WellbeingEventType.injury => injuryGlyph,
                        WellbeingEventType.holiday => holidayGlyph,
                        WellbeingEventType.other => otherEventGlyph,
                      },
                      size: markerSize,
                      color: switch (event) {
                        WellbeingEventType.intimacy => intimacyGlyphColor,
                        WellbeingEventType.injury => injuryGlyphColor,
                        WellbeingEventType.holiday => holidayGlyphColor,
                        WellbeingEventType.other => otherEventGlyphColor,
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Names each glyph the grid can draw. Without it the markers are
/// unexplained symbols; with it the grid is self-describing.
class WellbeingCalendarLegend extends StatelessWidget {
  const WellbeingCalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(
          key: const Key('wellbeingLegendCheckin'),
          icon: checkinGlyph,
          color: theme.colorScheme.primary,
          label: 'Check-in',
        ),
        const _LegendItem(
          key: Key('wellbeingLegendFlare'),
          icon: flareGlyph,
          color: flareGlyphColor,
          label: 'Flare-up',
        ),
        const _LegendItem(
          key: Key('wellbeingLegendRecovery'),
          icon: recoveryGlyph,
          color: recoveryGlyphColor,
          label: 'Recovery day',
        ),
        const _LegendItem(
          key: Key('wellbeingLegendIntimacy'),
          icon: intimacyGlyph,
          color: intimacyGlyphColor,
          label: 'Intimacy',
        ),
        const _LegendItem(
          key: Key('wellbeingLegendInjury'),
          icon: injuryGlyph,
          color: injuryGlyphColor,
          label: 'Injury',
        ),
        const _LegendItem(
          key: Key('wellbeingLegendHoliday'),
          icon: holidayGlyph,
          color: holidayGlyphColor,
          label: 'Holiday',
        ),
      ],
    );
  }
}

/// One glyph and the word for it.
///
/// The labels deliberately reuse the history cards' vocabulary — the whole
/// point of the shared glyph set is that a symbol means one thing across
/// the tab — which does mean the legend and a card can carry the same
/// words at once. Each item therefore carries a stable [Key] so a test that
/// means "the flare-up CARD" can say so; see the scoped finders in
/// `test/features/flare_flow_test.dart` and
/// `test/features/recovery_management_flow_test.dart`.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
