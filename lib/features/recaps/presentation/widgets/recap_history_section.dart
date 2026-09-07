import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';

/// The Progress screen's re-viewable recap history (Task 1.3,
/// `TASKS_TO_DO.md`'s second entry point): every recent completed cycle
/// and calendar month, tap to re-open its story.
///
/// A recap is built on demand when tapped (`recapForPeriodProvider`), not
/// eagerly for the whole list — most of these periods will never be
/// tapped, and each build re-walks that period's activities/water/
/// nutrition/check-ins. A period whose data turns out too sparse to
/// recap (`domain/recap_builder.dart`'s guard) surfaces a plain message
/// instead of silently doing nothing, since here — unlike the automatic
/// trigger — the user explicitly asked to see it. (Months that could
/// *only* answer that are filtered out upstream by
/// `recentRecapPeriodsProvider`; the message remains for a completed cycle
/// that turns out empty.)
class RecapHistorySection extends ConsumerWidget {
  const RecapHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodsAsync = ref.watch(recentRecapPeriodsProvider);
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return periodsAsync.when(
      data: (periods) {
        if (periods.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your Cycle in Motion',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
                for (final period in periods)
                  _RecapHistoryTile(key: ValueKey(period.key), period: period),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      // Silently absent on error too: this is a nice-to-have discovery
      // surface, not a critical one - the Progress screen's other cards
      // already have their own error handling for their own data.
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// One tappable period row.
///
/// Stateful because building the recap behind the tap is genuinely slow
/// (it re-walks that period's whole history —
/// `recaps_providers.dart#recapForPeriod` documents the cost), so the row
/// has to say so while it works and refuse a second tap in the meantime.
/// Same shape as `cycle/presentation/widgets/guided_cycle_import_sheet.dart`'s
/// local busy flag; there is no domain logic here to push down to a
/// controller, only the in-flight state of one row.
class _RecapHistoryTile extends ConsumerStatefulWidget {
  const _RecapHistoryTile({required this.period, super.key});

  final RecapPeriod period;

  @override
  ConsumerState<_RecapHistoryTile> createState() => _RecapHistoryTileState();
}

class _RecapHistoryTileState extends ConsumerState<_RecapHistoryTile> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        widget.period.kind == RecapPeriodKind.cycleEnd
            ? Icons.favorite_rounded
            : Icons.calendar_month_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(widget.period.label),
      trailing: _isOpening
          ? const SizedBox.square(
              // Matched to the chevron it replaces so the row doesn't
              // reflow the instant it's tapped.
              dimension: 24,
              child: Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: 'Opening recap',
                  ),
                ),
              ),
            )
          : const Icon(Icons.chevron_right_rounded),
      // Nulling `onTap` rather than setting `enabled: false`: the row must
      // stop responding, but greying its label out would read as "this
      // recap is unavailable" rather than "hold on".
      onTap: _isOpening ? null : _openRecap,
    );
  }

  Future<void> _openRecap() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);

    final CycleRecap? recap;
    try {
      recap = await ref.read(recapForPeriodProvider(widget.period).future);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isOpening = false);
      // The provider caches its failure, so without this the retry the
      // row now invites would resolve straight back to the same error.
      ref.invalidate(recapForPeriodProvider(widget.period));
      _showMessage(userMessageFor(error));
      return;
    }

    if (!mounted) return;
    setState(() => _isOpening = false);

    if (recap == null) {
      _showMessage(
        "There's not quite enough logged for this period to recap yet.",
      );
      return;
    }

    unawaited(RecapStoryRouteData($extra: recap).push<void>(context));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
  }
}
