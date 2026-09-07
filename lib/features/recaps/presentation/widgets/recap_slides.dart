import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/presentation/widgets/recap_slide_scaffold.dart';

/// Builds the ordered, non-empty slides for [recap] (Task 1.3,
/// `TASKS_TO_DO.md`): opener → movement → strength → mindful → PR showcase
/// → hydration/fueling → wellbeing → closing affirmation, skipping any
/// slide [CycleRecap] has nothing for — the framing rule is enforced by
/// `domain/recap_builder.dart` leaving those fields `null`/empty, so this
/// only has to check for absence, never decide what counts as one.
///
/// Mindful minutes get a slide of their own rather than only the
/// strength slide's footnote: gating them on tonnage meant a yoga- or
/// Pilates-only period computed the figure and then never showed it to
/// her. The footnote stays where there *is* tonnage, the way the opener
/// and the movement slide already both mention the session count.
List<Widget> buildRecapSlides(CycleRecap recap) {
  return [
    _OpenerSlide(recap: recap),
    if (recap.totalDistanceMeters != null) _MovementSlide(recap: recap),
    if (recap.totalTonnageKg != null) _StrengthSlide(recap: recap),
    if (recap.mindfulMinutes != null) _MindfulSlide(recap: recap),
    if (recap.topPrs.isNotEmpty) _PrShowcaseSlide(recap: recap),
    if (recap.hydrationConsistencyRatio != null ||
        recap.fuelingConsistencyRatio != null)
      _ConsistencySlide(recap: recap),
    if (recap.wellbeingObservation != null) _WellbeingSlide(recap: recap),
    _ClosingSlide(recap: recap),
  ];
}

class _OpenerSlide extends StatelessWidget {
  const _OpenerSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    final activeDays = (recap.consistencyRatio * recap.period.totalDays)
        .round();
    final title = recap.period.kind == RecapPeriodKind.cycleEnd
        ? 'Cycle Summary · ${recap.period.label}'
        : recap.period.label;
    return RecapSlideScaffold(
      icon: Icons.auto_awesome_rounded,
      title: title,
      body: Text(
        recap.sessionCount > 0
            ? 'You showed up $activeDays of ${recap.period.totalDays} days '
                  "this period — let's look back at your movement."
            : "A quiet period, and that's okay too — here's what your "
                  'body logged.',
      ),
    );
  }
}

class _MovementSlide extends StatelessWidget {
  const _MovementSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    final totalKm = (recap.totalDistanceMeters! / 1000).toStringAsFixed(2);
    final byType = recap.distanceByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RecapSlideScaffold(
      icon: Icons.directions_run_rounded,
      title: 'Total distance moved',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RecapBigStat(value: '$totalKm km', label: 'across every session'),
          if (byType.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in byType)
                  _Pill(
                    '${entry.key.label}: '
                    '${(entry.value / 1000).toStringAsFixed(1)} km',
                  ),
              ],
            ),
          ],
        ],
      ),
      footnote: '${recap.sessionCount} sessions logged this period',
    );
  }
}

class _StrengthSlide extends StatelessWidget {
  const _StrengthSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    final tonnage = recap.totalTonnageKg!.toStringAsFixed(0);
    return RecapSlideScaffold(
      icon: Icons.fitness_center_rounded,
      title: 'Strength moved',
      body: RecapBigStat(value: '$tonnage kg', label: 'total tonnage lifted'),
      footnote: recap.mindfulMinutes != null
          ? '${_formatMinutes(recap.mindfulMinutes!)} of mindful movement, too'
          : null,
    );
  }
}

class _MindfulSlide extends StatelessWidget {
  const _MindfulSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    return RecapSlideScaffold(
      // Not `self_improvement_rounded` — that is the wellbeing slide's
      // icon, and two slides in one story must not read as the same one.
      icon: Icons.spa_rounded,
      title: 'Mindful movement',
      body: RecapBigStat(
        value: _formatMinutes(recap.mindfulMinutes!),
        label: 'on the mat this period',
      ),
    );
  }
}

class _PrShowcaseSlide extends StatelessWidget {
  const _PrShowcaseSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return RecapSlideScaffold(
      icon: Icons.emoji_events_rounded,
      title: 'Personal records set',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final pr in recap.topPrs)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: Column(
                children: [
                  Text(
                    pr.valueLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    // `displayPhase`, never `phase`: `CyclePhase.none`
                    // means "unknown", and reading it raw renders the
                    // meaningless "None phase".
                    pr.displayPhase != null
                        ? '${pr.label} · ${pr.displayPhase!.label} phase'
                        : pr.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsistencySlide extends StatelessWidget {
  const _ConsistencySlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return RecapSlideScaffold(
      icon: Icons.water_drop_rounded,
      title: 'Fueling & hydration',
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (recap.hydrationConsistencyRatio != null)
            RecapBigStat(
              value: '${(recap.hydrationConsistencyRatio! * 100).round()}%',
              label: 'hydration goal days',
            ),
          if (recap.hydrationConsistencyRatio != null &&
              recap.fuelingConsistencyRatio != null)
            SizedBox(width: tokens.spacingXl),
          if (recap.fuelingConsistencyRatio != null)
            RecapBigStat(
              value: '${(recap.fuelingConsistencyRatio! * 100).round()}%',
              label: 'protein goal days',
            ),
        ],
      ),
    );
  }
}

class _WellbeingSlide extends StatelessWidget {
  const _WellbeingSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    return RecapSlideScaffold(
      icon: Icons.self_improvement_rounded,
      title: 'A gentle observation',
      body: Text(recap.wellbeingObservation!),
      footnote: 'Based on your own logged check-ins — never a prescription.',
    );
  }
}

class _ClosingSlide extends StatelessWidget {
  const _ClosingSlide({required this.recap});

  final CycleRecap recap;

  @override
  Widget build(BuildContext context) {
    return const RecapSlideScaffold(
      icon: Icons.favorite_rounded,
      title: 'However it looked, you showed up for yourself.',
      body: Text(
        'Save this recap to look back on, or keep moving forward.',
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final remMinutes = minutes % 60;
  return remMinutes > 0 ? '${hours}h ${remMinutes}m' : '${hours}h';
}
