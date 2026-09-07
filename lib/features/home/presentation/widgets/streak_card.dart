import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_sheet.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';

/// Home dashboard hero card surfacing the user's engagement streak — the
/// signature protected-recovery feature made visible
/// (`knowledge/product/product_vision.md`). Watches
/// `features/streaks/streaks_providers.dart#streakResultProvider`
/// directly (a feature's composition surface is exactly what another
/// feature's presentation is allowed to depend on — ADR 007).
///
/// Rendered full-width above the dashboard grid: a leading icon plus an
/// [Expanded] text column, so every state (multi-line protected copy
/// included) lays out safely from compact phone widths up.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final streakAsync = ref.watch(streakResultProvider);

    return Card(
      shape: themedCardShape(context, radius: tokens.radiusMd),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: streakAsync.when(
          data: (result) => _StreakCardContent(result: result),
          // Loading/error both fall back to the same neutral shell rather
          // than surfacing a spinner or error text on the dashboard — a
          // streak card that can't compute yet should look "quiet", not
          // broken (this is a derived, best-effort summary, not a form
          // that needs to report failures to act on).
          loading: () => const _StreakCardShell(),
          error: (error, stackTrace) => const _StreakCardShell(),
        ),
      ),
    );
  }
}

/// Shared row skeleton: tinted leading icon + text column.
class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.icon,
    required this.iconColor,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  /// An optional trailing widget (the protected state's "open the Today
  /// sheet" chevron) — `null` for every other state, which keeps the row
  /// exactly as wide as it was before this affordance existed.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacingSm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        SizedBox(width: tokens.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
        if (trailing != null) ...[SizedBox(width: tokens.spacingSm), trailing!],
      ],
    );
  }
}

class _StreakCardShell extends StatelessWidget {
  const _StreakCardShell();

  @override
  Widget build(BuildContext context) {
    return _StreakRow(
      icon: Icons.local_fire_department,
      iconColor: Theme.of(context).colorScheme.primary,
      children: [
        Text('Streak', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class _StreakCardContent extends StatelessWidget {
  const _StreakCardContent({required this.result});

  final StreakResult result;

  @override
  Widget build(BuildContext context) {
    if (result.todayStatus == DayStatus.protectedRecovery) {
      return _ProtectedStreakCard(result: result);
    }
    return _ActiveStreakCard(result: result);
  }
}

/// Normal (not-protected-today) state: the current streak count, the
/// longest streak, an empty-state invite when there's no streak yet, a
/// restrained affirmation when today is already satisfied, and — only
/// while today is still [DayStatus.unscheduled] — the "make today a
/// recovery day" affordance (RULING §5.9: a direct action alongside the
/// check-in-triggered prompt, not a replacement for it).
class _ActiveStreakCard extends ConsumerWidget {
  const _ActiveStreakCard({required this.result});

  final StreakResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _StreakRow(
      icon: Icons.local_fire_department,
      iconColor: colorScheme.primary,
      children: [
        if (result.currentStreak == 0)
          Text(
            'Log an activity to start your streak',
            style: textTheme.titleSmall,
          )
        else ...[
          // Two lines, not one: "6-day streak" in `headlineSmall` needs
          // more than the ~192dp this row gets on a 320dp phone once the
          // text scales, and a streak count clipped to "6-day str…" is a
          // number the user came to this card to read. It breaks at the
          // space, never mid-word.
          Text(
            '${result.currentStreak}-day streak',
            style: textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)
                .tabularFigures,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Longest: ${result.longestStreak} days',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (result.todaySatisfied) ...[
          SizedBox(height: tokens.spacingXs),
          Text(
            "You've moved today ✓",
            style: textTheme.bodySmall?.copyWith(color: tokens.success),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (result.todayStatus == DayStatus.unscheduled) ...[
          SizedBox(height: tokens.spacingXs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              // Deliberately NOT `shrinkWrap`/`Size.zero`/zero padding, and
              // not gated on the Large Touch Targets preference: those
              // styles shrank this to a 20dp-tall strip, under every
              // platform floor (Material 48, iOS HIG 44) on every device
              // and at every setting. Horizontal padding stays tight so it
              // still reads as an inline link flush with the streak copy
              // above it; the height is the framework minimum.
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.standard,
              ),
              onPressed: () => _markRecoveryDay(context, ref),
              child: const Text('Make today a recovery day'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _markRecoveryDay(BuildContext context, WidgetRef ref) async {
    final today = LocalDate.today();
    try {
      await ref.read(recoveryRepositoryProvider).markRecoveryDay(today);
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Recovery day marked'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Fire-and-forget from the SnackBar action's synchronous
              // callback - any failure surfaces via the repository's normal
              // error path on the next read, same as every other
              // best-effort undo in this codebase.
              unawaited(
                ref.read(recoveryRepositoryProvider).unmarkRecoveryDay(today),
              );
            },
          ),
        ),
      );
  }
}

/// Protected-recovery-today state: [StreakResult.todayStatus] is
/// [DayStatus.protectedRecovery], so today doesn't count against the
/// streak — see `knowledge/domain/womens_health.md`'s "Streak pausing"
/// section and `knowledge/product/terminology.md` ("paused"/"protected",
/// never "frozen"/"excused"/"failed").
///
/// RULING (S1-2, resolving the "shoulder-surfing" product note from
/// `stage1_audit.md`): always renders with a neutral primary tint, never
/// [AppTokens.cyclePhaseMenstrual] — protection is now multi-source
/// (explicit recovery day, flare impact, *or* a logged period day), so a
/// period-coloured card would incorrectly imply the reason on sight, and
/// would leak "this is a period day" to anyone glancing at the user's
/// screen even when the real reason was a flare or a voluntary recovery
/// day. The card is deliberately source-agnostic — it never says *why*
/// today is protected, only that it is.
///
/// RULING (S1-3): tappable, unlike every other streak-card state — tapping
/// opens [TodaySheet], which *does* break down the source(s) by name. This
/// is deliberate and doesn't contradict the ruling above: the always-visible
/// card stays reason-silent-by-default (nothing here changes what a
/// shoulder-surfer sees on a glance), but a user who *deliberately taps*
/// has asked to see why, and answering that on request is exactly the
/// "manage/amend recovery days" affordance this state was missing (there
/// was previously no way to undo an explicit recovery day once its
/// mark/undo snackbar expired). The unprotected state ([_ActiveStreakCard])
/// is deliberately left non-tappable — with nothing protecting today yet,
/// there is nothing to manage.
class _ProtectedStreakCard extends StatelessWidget {
  const _ProtectedStreakCard({required this.result});

  final StreakResult result;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: "Manage today - see what's protecting your streak",
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        onTap: () => TodaySheet.show(context),
        child: _StreakRow(
          icon: Icons.shield_outlined,
          iconColor: colorScheme.primary,
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          children: [
            Text(
              // There's no streak yet to reassure the user about in the
              // zero-count case, so don't claim one - "your 0-day streak is
              // safe" reads as nonsensical/patronising. Only cite a count
              // once there's a real one to protect.
              result.currentStreak == 0
                  ? 'Recovery day'
                  : 'Recovery day — your ${result.currentStreak}-day streak '
                        'is safe',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              "Recovery days don't break your streak.",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
