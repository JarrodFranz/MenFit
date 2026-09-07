import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/settings/presentation/settings_controller.dart';

/// Card displaying live fitness device steps.
///
/// It used to carry a second tile showing the profile's `weightKg` under
/// the heading "Weight". That tile is gone: `WeightProgressSection`
/// (`features/weight`) sits a few rows below on the same screen under the
/// same heading, and showed a different number — the profile column versus
/// the latest weight-history row — so the Progress screen answered "what
/// do I weigh?" twice, in two places, with two answers. The history is the
/// authoritative one, and the profile writes through to it
/// (`features/profile/presentation/profile_controller.dart`).
class ProgressFutureIntegrationCards extends ConsumerWidget {
  const ProgressFutureIntegrationCards({this.anchor, super.key});

  final LocalDate? anchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final isSyncEnabled = ref.watch(fitnessDeviceSyncControllerProvider);
    final healthState = ref.watch(healthSyncProvider);
    final selectedDate = anchor ?? LocalDate.today();
    final isToday = selectedDate == LocalDate.today();
    final dateSnapshotAsync = isToday
        ? null
        : ref.watch(dateHealthSnapshotProvider(selectedDate));
    final snapshot = isToday
        ? healthState.latestSnapshot
        : dateSnapshotAsync?.value;
    final stepsCount = snapshot?.steps;

    final stepsStr = isSyncEnabled
        ? (stepsCount != null
              ? NumberFormat.decimalPattern().format(stepsCount)
              : (dateSnapshotAsync?.isLoading == true ? '...' : '0'))
        : 'Connect';

    final stepsSubtitle = isSyncEnabled
        ? (healthState.isSyncing || (dateSnapshotAsync?.isLoading == true)
              ? 'Syncing...'
              : (snapshot?.source ?? 'Health Connect'))
        : 'Fitness device';

    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              // Opens the daily-steps history. It used to request health
              // permissions (sync off) or re-sync today (sync on) from
              // here - a tap whose effect depended on invisible state and
              // that produced no visible change either way. Both jobs moved
              // into `/steps`, which can explain what it is asking for and
              // show the result.
              onTap: () =>
                  unawaited(const StepsRouteData().push<void>(context)),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Steps',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (healthState.isSyncing)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.tertiary,
                            ),
                          )
                        else
                          Icon(
                            Icons.directions_walk_outlined,
                            size: 18,
                            color: colorScheme.tertiary,
                          ),
                      ],
                    ),
                    SizedBox(height: tokens.spacingSm),
                    Text(
                      stepsStr,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stepsSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
