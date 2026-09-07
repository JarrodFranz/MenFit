import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_week_strip.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

/// Today's steps against the target, as a ring, over the real seven-day
/// consistency strip.
///
/// Lifted out of `features/activity/presentation/widgets/
/// fitness_dashboard_cards.dart` (where it was a private
/// `_StepsRingCard`) so the home dashboard can mount the same card rather
/// than grow a second, drifting copy of it. Exported through
/// `features/steps/steps_widgets.dart`; nothing outside this feature may
/// reach this file directly (ADR 007).
///
/// Self-contained on purpose: every caller wants the same three answers
/// (is fitness-device sync on, what did the platform last report, what is
/// the target), so reading them here is what stops two dashboards
/// disagreeing about the same number.
///
/// Tapping it opens the full daily history at `/steps` **whatever the sync
/// state** - the screen explains "no health platform", "sync off" and
/// "permission needed" far better than a card half a phone wide can, so the
/// card never swallows the tap to run a sync of its own.
class StepsRingCard extends ConsumerStatefulWidget {
  const StepsRingCard({super.key});

  @override
  ConsumerState<StepsRingCard> createState() => _StepsRingCardState();
}

class _StepsRingCardState extends ConsumerState<StepsRingCard> {
  @override
  void initState() {
    super.initState();
    // The only other caller of `syncRecent` is the steps screen, so without
    // this a fresh, permitted install shows seven hollow "no data" rings on
    // the app's most-viewed card until the user happens to open `/steps`.
    // Syncing here is safe on both counts that matter: the notifier returns
    // immediately while the fitness-device sync toggle is off (their stated
    // preference), and a successful sync throttles the next one for an
    // hour, so mounting this card repeatedly costs nothing.
    //
    // Post-frame, because the notifier mutates state and doing that during
    // the build that mounted this widget is the "setState during build"
    // fault.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(stepsSyncProvider.notifier).syncRecent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isSyncEnabled = ref.watch(fitnessDeviceSyncControllerProvider);
    // Today's live count, or null when no snapshot has been read yet.
    // Nullable rather than defaulted to zero: the week strip must be able
    // to tell "they have walked nothing yet today" from "nothing has been
    // read", and a `0` passed for the second is exactly the fabrication
    // this card was fixed to stop making.
    final steps = ref.watch(healthSyncProvider).latestSnapshot?.steps;
    final targetSteps = ref.watch(stepsTargetProvider);

    final stepsToday = steps ?? 0;
    final progress = targetSteps > 0
        ? (stepsToday / targetSteps).clamp(0.0, 1.0)
        : 0.0;
    final stepsFormatted = NumberFormat.decimalPattern().format(stepsToday);
    final targetFormatted = NumberFormat.decimalPattern().format(targetSteps);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: 'Steps, open daily history',
        // A container, not a merge: the ring's number and the strip's
        // per-day markers stay their own nodes underneath, so the card
        // announces what tapping it does without hiding what it shows.
        container: true,
        child: InkWell(
          onTap: () => unawaited(const StepsRouteData().push<void>(context)),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Steps',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        // One line: unlike its two-word neighbours, a second
                        // line for a single word would be spent breaking it
                        // in half.
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: isSyncEnabled ? progress : 0.0,
                          strokeWidth: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: progress >= 1.0
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.85),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            // `--`, not `0`: with no snapshot read yet
                            // there is no count, and the week strip below
                            // already says "no data" for the same day. The
                            // two must not disagree.
                            isSyncEnabled && steps != null
                                ? stepsFormatted
                                : '--',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isSyncEnabled ? targetFormatted : 'Connect',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 10),
                StepsWeekStrip(todaySteps: isSyncEnabled ? steps : null),
                const SizedBox(height: 2),
                Text(
                  'Last 7d',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
