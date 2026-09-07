import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/home/domain/home_today_overview.dart';
import 'package:menfit_app/features/home/presentation/home_overview_controller.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_card.dart';

/// The dashboard's closing card: three plain statements about today.
///
/// Reports only — it is the one card with no destination, because each of
/// the three facts already has a card or a prompt above it that owns the
/// action.
///
/// **No cycle phase appears here.** The reasoning is in
/// `domain/home_today_overview.dart`; in short, the recovery banner on this
/// same screen is deliberately reason-silent, and naming a phase in the
/// card underneath it would undo that ruling.
class TodayOverviewCard extends ConsumerWidget {
  const TodayOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(homeTodayOverviewProvider).value;

    return HomeCard(
      icon: Icons.today_outlined,
      title: 'Today at a glance',
      child: overview == null
          ? const _OverviewLoading()
          : _OverviewRows(overview: overview),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Checking today',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _OverviewRows extends StatelessWidget {
  const _OverviewRows({required this.overview});

  final HomeTodayOverview overview;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _OverviewRow(
          label: 'Check-in',
          value: overview.checkinLogged ? 'Logged' : 'Not yet',
        ),
        SizedBox(height: tokens.spacingXs),
        // "Recovery", not "Recovery day": the streak banner above already
        // says "Recovery day" when today is protected, and two identical
        // labels on one screen read as a duplicate (and break exact-text
        // finders in the recovery flow tests).
        _OverviewRow(
          label: 'Recovery',
          value: overview.isRecoveryDay ? 'Marked' : 'Not marked',
        ),
        SizedBox(height: tokens.spacingXs),
        _OverviewRow(
          label: 'Workouts',
          value: '${overview.workoutsToday}',
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      // Merged so the pair is announced as one statement ("Check-in,
      // Logged") rather than as two unrelated fragments.
      container: true,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
            ),
          ),
          SizedBox(width: tokens.spacingXs),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
