import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/streaks/domain/today_protection_sources.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';

/// The streak card's "Today" management sheet — opened only by a
/// deliberate tap on the protected-recovery card state (see
/// `streak_card.dart`'s `_ProtectedStreakCard` dartdoc for why the
/// always-visible card itself stays reason-silent by design). Lists every
/// currently-active protection source for today
/// (`streaks/domain/today_protection_sources.dart`'s
/// [TodayProtectionSources] — multiple sources can be active
/// simultaneously) with a warm, source-specific explanation and, where
/// there's something to do about it, an action.
///
/// Watches [todayProtectionSourcesProvider] **live**, not a one-time
/// snapshot: removing the explicit recovery day while a flare still
/// protects today updates the sheet in place (the explicit-source card
/// disappears, the flare card stays) rather than leaving stale "you marked
/// this" copy behind, and never implies the streak is now at risk when
/// another source still protects it. If removing a source leaves nothing
/// protecting today, the sheet closes itself instead of showing an
/// increasingly-irrelevant "manage today" screen for a day that's no
/// longer protected — the card behind it (already live via the same
/// underlying data) reflects the unprotected state on its own.
class TodaySheet extends ConsumerWidget {
  const TodaySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TodaySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final sourcesAsync = ref.watch(todayProtectionSourcesProvider);

    ref.listen(todayProtectionSourcesProvider, (previous, next) {
      final value = next.value;
      final navigator = Navigator.of(context);
      if (value != null && !value.hasAnySource && navigator.canPop()) {
        navigator.pop();
      }
    });

    // Bottom inset comes from `showAppBottomSheet`; no `SafeArea` here.
    return Padding(
      padding: EdgeInsets.all(tokens.spacingLg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.spacingXs),
            Text(
              "Here's what's protecting your streak today.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            sourcesAsync.when(
              data: (sources) => _SourcesList(sources: sources),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Text(userMessageFor(error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcesList extends StatelessWidget {
  const _SourcesList({required this.sources});

  final TodayProtectionSources sources;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    if (!sources.hasAnySource) {
      // Not normally reachable (the sheet only opens from the protected
      // card state, and it closes itself once nothing protects today - see
      // TodaySheet's dartdoc) - kept as a graceful fallback for the brief
      // window between a source dropping out and the listener above
      // popping the sheet.
      return const Text("Today isn't protected by anything right now.");
    }

    final tiles = <Widget>[
      if (sources.hasExplicitRecoveryDay)
        _ExplicitRecoverySourceTile(note: sources.recoveryNote),
      if (sources.hasProtectingFlare) const _FlareSourceTile(),
      if (sources.isPeriodProtected) const _PeriodSourceTile(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) SizedBox(height: tokens.spacingSm),
          tiles[i],
        ],
      ],
    );
  }
}

/// Shared card shape for a single protection source: an icon, a warm
/// explanation, and an optional action.
class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.action,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            SizedBox(width: tokens.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  if (subtitle != null) ...[
                    SizedBox(height: tokens.spacingXs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  SizedBox(height: tokens.spacingXs),
                  Align(alignment: Alignment.centerLeft, child: action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The explicit-recovery-day source — the one source this sheet can
/// actually undo. "Remove recovery day" hard-deletes today's recovery
/// record via `RecoveryRepository.unmarkRecoveryDay`, same mechanics as the
/// streak card's own mark/undo affordance, with a matching undo snackbar
/// that re-marks the day (preserving [note], since a hard delete would
/// otherwise lose it).
class _ExplicitRecoverySourceTile extends ConsumerWidget {
  const _ExplicitRecoverySourceTile({required this.note});

  final String? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNote = note != null && note!.trim().isNotEmpty;
    return _SourceCard(
      icon: Icons.shield_outlined,
      title: 'You marked today as a recovery day',
      subtitle: hasNote ? note : null,
      action: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => _remove(context, ref),
        child: const Text('Remove recovery day'),
      ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final today = LocalDate.today();
    final previousNote = note;
    // Captured SYNCHRONOUSLY, before any await: removing the last
    // protection source makes the sheet auto-pop (see TodaySheet's
    // listener), unmounting this tile - after that, `ref` and `context`
    // are dead. The root container and messenger outlive the sheet, so
    // the snackbar and its Undo action must go through them instead
    // (same capture-before-unmount pattern as checkin_sheet.dart).
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await container.read(recoveryRepositoryProvider).unmarkRecoveryDay(today);
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Recovery day removed'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Fire-and-forget, same convention as the streak card's own
              // undo action - a failure surfaces via the repository's normal
              // error path on the next read.
              unawaited(
                container
                    .read(recoveryRepositoryProvider)
                    .markRecoveryDay(today, note: previousNote),
              );
            },
          ),
        ),
      );
  }
}

/// The protecting-flare source — read-only here; flares are amended from
/// the wellbeing history screen, not this sheet.
class _FlareSourceTile extends StatelessWidget {
  const _FlareSourceTile();

  @override
  Widget build(BuildContext context) {
    return _SourceCard(
      icon: Icons.local_fire_department_outlined,
      title: 'You logged a flare-up today',
      action: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          const WellbeingRouteData().go(context);
        },
        child: const Text('View in Wellbeing'),
      ),
    );
  }
}

/// The period-day source — only shown when both the streak-pausing
/// preference is on AND today itself falls within a logged period
/// (`streaks/domain/today_protection_sources.dart`).
class _PeriodSourceTile extends StatelessWidget {
  const _PeriodSourceTile();

  @override
  Widget build(BuildContext context) {
    return _SourceCard(
      icon: Icons.favorite_outline,
      title: 'Period day — counted as recovery (your setting)',
      action: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          const CycleRouteData().go(context);
        },
        child: const Text('Cycle settings'),
      ),
    );
  }
}
