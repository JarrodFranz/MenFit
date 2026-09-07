import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_cycle_launcher_sheet.dart';
import 'package:menfit_app/features/activity/presentation/strength/start_strength_cycle.dart';
import 'package:menfit_app/features/activity/presentation/strength/strength_routine_editor_sheet.dart';

/// Custom tools for Strength: Training Cycles & Saved Day Routines.
class StrengthCustomSection extends ConsumerWidget {
  const StrengthCustomSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCycleAsync = ref.watch(activeStrengthCycleProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        activeCycleAsync.when(
          data: (activeCycle) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            if (activeCycle == null) {
              return Card(
                elevation: 0,
                color: isDark
                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : const Color(0xFFFAF2FA),
                shape: themedCardShape(
                  context,
                  radius: 16,
                  side: BorderSide(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : const Color(0xFFEBD1ED),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingMd),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.primary.withValues(alpha: 0.2)
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cached,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No Active Training Cycle',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Start a multi-day cycle for '
                              'progressive overload.',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          unawaited(StrengthCycleLauncherSheet.show(context));
                        },
                        child: const Text('Pick Cycle'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final nextDay = activeCycle.nextRoutine;
            final currentDayNumber = activeCycle.currentDayIndex + 1;
            final totalDays = activeCycle.routines.length;
            return Card(
              elevation: 0,
              color: isDark
                  ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : const Color(0xFFFAF2FA),
              shape: themedCardShape(
                context,
                radius: 16,
                side: BorderSide(
                  color: isDark
                      ? colorScheme.primary.withValues(alpha: 0.4)
                      : const Color(0xFFEBD1ED),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeCycle.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Edit Cycle',
                          onPressed: () => StrengthCycleEditorSheet.show(
                            context,
                            cycle: activeCycle,
                          ),
                        ),
                        Text(
                          'Day $currentDayNumber of $totalDays',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacingSm),
                    Text(
                      'Next Up: ${nextDay?.name ?? "Next Day"} '
                      '(${nextDay?.exercises.length ?? 0} exercises)',
                      style: textTheme.bodyMedium,
                    ),
                    SizedBox(height: tokens.spacingSm),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => startActiveStrengthCycle(
                              ref,
                              context,
                              activeCycle,
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text('Start ${nextDay?.name ?? "Workout"}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: const Text('Edit Day'),
                          onPressed: nextDay != null
                              ? () => StrengthRoutineEditorSheet.show(
                                  context,
                                  routine: nextDay,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        SizedBox(height: tokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  unawaited(StrengthCycleLauncherSheet.show(context));
                },
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Saved Routines'),
              ),
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  unawaited(StrengthCycleLauncherSheet.show(context));
                },
                icon: const Icon(Icons.event_note),
                label: const Text('Training Cycles'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
