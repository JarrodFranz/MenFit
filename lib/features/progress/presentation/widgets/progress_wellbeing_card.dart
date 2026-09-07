import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';

/// Wellbeing and streak consistency card for the Progress dashboard.
class ProgressWellbeingCard extends StatelessWidget {
  const ProgressWellbeingCard({
    required this.streak,
    required this.checkins,
    required this.flares,
    required this.period,
    required this.anchor,
    super.key,
  });

  final StreakResult streak;
  final List<DailyCheckin> checkins;
  final List<FlareEvent> flares;
  final ProgressPeriod period;
  final LocalDate anchor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final range = period.rangeFor(anchor);

    final periodCheckins = checkins.where((c) {
      return !c.day.isBefore(range.start) && !c.day.isAfter(range.end);
    }).toList();

    final periodFlares = flares.where((f) {
      return !f.lastDay.isBefore(range.start) && !f.day.isAfter(range.end);
    }).toList();

    double? avgEnergy;
    double? avgSleep;
    final energyScores = periodCheckins
        .map((c) => c.energy)
        .whereType<int>()
        .toList();
    if (energyScores.isNotEmpty) {
      avgEnergy = energyScores.reduce((a, b) => a + b) / energyScores.length;
    }
    final sleepScores = periodCheckins
        .map((c) => c.sleep)
        .whereType<int>()
        .toList();
    if (sleepScores.isNotEmpty) {
      avgSleep = sleepScores.reduce((a, b) => a + b) / sleepScores.length;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The title is `Expanded` rather than sized by its own text:
            // "Wellbeing & Consistency" is 23 characters of `titleMedium`
            // bold, which overflowed a 320dp card to the right by 59px the
            // moment the text scaled. Given room to wrap it costs a line
            // instead.
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Wellbeing & Consistency',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Icon(
                  Icons.favorite_outline,
                  color: colorScheme.error,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            // Deliberately the default cross-axis alignment. `stretch` would
            // read better once one tile's label wraps to two lines, but a
            // stretched `Row` inside this scrolling column is given an
            // unbounded height to stretch into and throws
            // "BoxConstraints forces an infinite height" — it needs an
            // `IntrinsicHeight` wrapper, which is a change worth making
            // only with a test run to confirm it.
            Row(
              children: [
                Expanded(
                  child: _WellbeingStatTile(
                    label: 'Current Streak',
                    value: streak.currentStreak == 1
                        ? '1 day'
                        : '${streak.currentStreak} days',
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orangeAccent,
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: _WellbeingStatTile(
                    label: 'Check-ins',
                    value: '${periodCheckins.length}',
                    icon: Icons.checklist_outlined,
                    iconColor: colorScheme.primary,
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: _WellbeingStatTile(
                    label: 'Flare-ups',
                    value: '${periodFlares.length}',
                    icon: Icons.healing_outlined,
                    iconColor: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            if (avgEnergy != null || avgSleep != null) ...[
              SizedBox(height: tokens.spacingMd),
              Row(
                children: [
                  if (avgEnergy != null)
                    Expanded(
                      child: Text(
                        'Avg Energy: ${avgEnergy.toStringAsFixed(1)} / 5',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (avgSleep != null)
                    Expanded(
                      child: Text(
                        'Avg Sleep: ${avgSleep.toStringAsFixed(1)} / 5',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WellbeingStatTile extends StatelessWidget {
  const _WellbeingStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  // Two lines, because a third of a 320dp card is ~80dp and
                  // "Current Streak" cannot be read as "Current…".
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
