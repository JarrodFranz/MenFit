import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';

/// Quick-add water card on the home dashboard.
class WaterQuickAddCard extends ConsumerWidget {
  const WaterQuickAddCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final today = ref.watch(localDayProvider).value ?? LocalDate.today();
    final waterAsync = ref.watch(dayWaterIntakeProvider(today));
    final waterMl = waterAsync.value ?? 0;
    const targetMl = 2000;
    final cups = (waterMl / 250).round();

    return Card(
      // Zero margin and the themed shape so this card sits flush with its
      // neighbours in `HomeCardLayout`, which owns the gaps between cards.
      margin: EdgeInsets.zero,
      shape: themedCardShape(context, radius: tokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        onTap: () {
          ref.read(selectedNutritionDayProvider.notifier).goToToday();
          const NutritionRouteData().go(context);
        },
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacingSm),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF0288D1),
                  size: 24,
                ),
              ),
              SizedBox(width: tokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration Today',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.spacingXs / 2),
                    Text(
                      '$waterMl / $targetMl ml ($cups cups)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                key: const Key('homeQuickAddWaterButton'),
                onPressed: () {
                  final newTotal = waterMl + 250;
                  final justReachedTarget =
                      waterMl < targetMl && newTotal >= targetMl;

                  unawaited(
                    ref
                        .read(waterRepositoryProvider)
                        .logWater(day: today, milliliters: 250),
                  );

                  if (justReachedTarget) {
                    unawaited(AccessibilityHaptics.heavyImpact(ref));
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF0288D1),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                        content: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hydration Target Hit! 💧 '
                                '$newTotal ml logged today.',
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
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text(
                          'Added 1 cup (250 ml) water · $newTotal ml today',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+1 Cup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
