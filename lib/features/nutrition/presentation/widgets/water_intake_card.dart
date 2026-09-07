import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

/// Card displaying daily water intake progress and quick logging actions.
class WaterIntakeCard extends ConsumerWidget {
  const WaterIntakeCard({
    required this.day,
    this.targetMl = 2000,
    super.key,
  });

  final LocalDate day;
  final int targetMl;

  void _logWater(
    BuildContext context,
    WidgetRef ref, {
    required int amount,
    required int currentMl,
  }) {
    unawaited(
      ref.read(waterRepositoryProvider).logWater(day: day, milliliters: amount),
    );

    final newTotal = currentMl + amount;
    if (currentMl < targetMl && newTotal >= targetMl) {
      unawaited(AccessibilityHaptics.heavyImpact(ref));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0288D1),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hydration Target Hit! 💧 $newTotal ml logged today.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final waterAsync = ref.watch(dayWaterIntakeProvider(day));
    final waterMl = waterAsync.value ?? 0;
    final cups = (waterMl / 250).round();
    final targetCups = (targetMl / 250).round();
    final progress = targetMl > 0 ? (waterMl / targetMl).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.water_drop,
                  color: Color(0xFF0288D1),
                  size: 22,
                ),
                SizedBox(width: tokens.spacingSm),
                // The title yields to the amount: at phone widths (348dp of
                // row on a 420dp surface) title + amount at natural width
                // overflowed by 33dp, found by the Home nutrition-card
                // navigation guard.
                Expanded(
                  child: Text(
                    'Water Intake',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Text(
                  '$waterMl / $targetMl ml',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0288D1),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              '$cups of $targetCups cups logged',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest
                    : const Color(0xFFE0F2FE),
                color: const Color(0xFF0EA5E9),
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('removeWaterButton'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 2,
                      ),
                    ),
                    onPressed: waterMl <= 0
                        ? null
                        : () => unawaited(
                            ref
                                .read(waterRepositoryProvider)
                                .removeWater(day: day, milliliters: 250),
                          ),
                    child: const Text(
                      '-250 ml',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: FilledButton.tonal(
                    key: const Key('addCupWaterButton'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 2,
                      ),
                    ),
                    onPressed: () => _logWater(
                      context,
                      ref,
                      amount: 250,
                      currentMl: waterMl,
                    ),
                    child: const Text(
                      '+1 Cup (250ml)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: FilledButton(
                    key: const Key('addBottleWaterButton'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 2,
                      ),
                    ),
                    onPressed: () => _logWater(
                      context,
                      ref,
                      amount: 500,
                      currentMl: waterMl,
                    ),
                    child: const Text(
                      '+500 ml',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
