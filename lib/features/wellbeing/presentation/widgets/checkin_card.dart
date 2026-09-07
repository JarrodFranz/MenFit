import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_watch_providers.dart';

/// Notifier tracking user dismissal of today's check-in prompt.
class DismissedCheckinDayNotifier extends Notifier<LocalDate?> {
  @override
  LocalDate? build() => null;

  void dismissToday() => state = LocalDate.today();
}

final dismissedCheckinDayProvider =
    NotifierProvider<DismissedCheckinDayNotifier, LocalDate?>(
      DismissedCheckinDayNotifier.new,
    );

/// Home dashboard check-in card — the entry point into the daily wellbeing
/// check-in (`knowledge/product/terminology.md`'s "Check-in" definition:
/// fast, optional). Slotted under `home/presentation/widgets/streak_card.dart`
/// in `home_screen.dart`.
///
/// Automatically disappears once today's check-in is logged, or when dismissed.
class CheckinCard extends ConsumerWidget {
  const CheckinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();
    final dismissedDay = ref.watch(dismissedCheckinDayProvider);
    final checkinAsync = ref.watch(checkinForDayProvider(today));
    final flaresAsync = ref.watch(flaresOnDayProvider(today));

    if (dismissedDay == today) {
      return const SizedBox.shrink();
    }

    final checkin = checkinAsync.value;
    final hasCheckin = checkin != null && !checkin.isEmpty;

    if (hasCheckin) {
      // Disappears from the home dashboard once logged
      return const SizedBox.shrink();
    }

    return Card(
      shape: themedCardShape(context, radius: tokens.radiusMd),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: checkinAsync.when(
          data: (checkin) => _CheckinCardContent(
            day: today,
            checkin: checkin,
            flares: flaresAsync.value ?? const [],
            onDismiss: () =>
                ref.read(dismissedCheckinDayProvider.notifier).dismissToday(),
          ),
          loading: () => const _CheckinCardShell(),
          error: (error, stackTrace) => const _CheckinCardShell(),
        ),
      ),
    );
  }
}

class _CheckinCardShell extends StatelessWidget {
  const _CheckinCardShell();

  @override
  Widget build(BuildContext context) {
    return _CheckinRow(
      icon: Icons.self_improvement_outlined,
      children: [
        Text(
          'How are you feeling today?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _CheckinRow extends StatelessWidget {
  const _CheckinRow({required this.icon, required this.children});

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spacingSm),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        SizedBox(width: tokens.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _CheckinCardContent extends StatelessWidget {
  const _CheckinCardContent({
    required this.day,
    required this.checkin,
    required this.flares,
    this.onDismiss,
  });

  final LocalDate day;
  final DailyCheckin? checkin;
  final List<FlareEvent> flares;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final hasCheckin = checkin != null && !checkin!.isEmpty;

    return _CheckinRow(
      icon: Icons.self_improvement_outlined,
      children: [
        if (!hasCheckin) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Dismiss',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDismiss,
                ),
            ],
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            'Takes a few seconds — totally optional.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
        ] else ...[
          Text(
            _summaryFor(checkin!),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: tokens.spacingSm),
        ],
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!hasCheckin)
              FilledButton(
                onPressed: () => CheckinSheet.show(context, day: day),
                child: const Text('Check in'),
              )
            else
              OutlinedButton(
                onPressed: () =>
                    CheckinSheet.show(context, day: day, existing: checkin),
                child: const Text('Edit'),
              ),
            // Shown whenever a flare is logged today, whether or not
            // today's check-in has been filled in - a flare can be logged
            // on its own via the check-in sheet's "Log a flare-up" button
            // without ever saving the (still-empty) check-in itself.
            if (flares.isNotEmpty)
              ActionChip(
                avatar: Icon(
                  Icons.local_fire_department_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  flares.length == 1
                      ? 'Flare-up logged'
                      : '${flares.length} flare-ups logged',
                ),
                onPressed: () =>
                    FlareDialog.show(context, existing: flares.first),
              ),
          ],
        ),
        SizedBox(height: tokens.spacingXs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => const WellbeingRouteData().go(context),
            child: const Text('History'),
          ),
        ),
      ],
    );
  }

  /// e.g. `'Energy 4 · Sleep 3 · 2 symptoms'` — only present fields, with
  /// correct singular/plural for the symptom count.
  String _summaryFor(DailyCheckin checkin) {
    final parts = <String>[
      if (checkin.energy != null) 'Energy ${checkin.energy}',
      if (checkin.sleep != null) 'Sleep ${checkin.sleep}',
      if (checkin.soreness != null) 'Soreness ${checkin.soreness}',
      if (checkin.stress != null) 'Stress ${checkin.stress}',
      if (checkin.pain != null) 'Pain ${checkin.pain}',
      if (checkin.symptoms.isNotEmpty)
        if (checkin.symptoms.length == 1)
          '1 symptom'
        else
          '${checkin.symptoms.length} symptoms',
    ];
    if (parts.isEmpty) return "You've checked in today";
    return parts.join(' · ');
  }
}
