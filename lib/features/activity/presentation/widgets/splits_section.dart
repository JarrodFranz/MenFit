// `Split` is a `Curve` subclass in `flutter/animation` - hidden since this
// file's `Split` (`domain/track_analysis.dart`) would otherwise be
// ambiguous.
import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';
import 'package:menfit_app/features/activity/presentation/activity_detail_controller.dart';

/// Mile length in metres, derived from [UnitConversions] rather than a
/// duplicated literal (same approach as `domain/pace_format.dart`'s
/// `_kmPerMile`) - the split length used for imperial-unit split display.
final double _mileMeters = UnitConversions.miToKm(1) * 1000;

/// Splits for a `recorded` activity's detail screen: a "Splits" heading plus
/// one row per [Split] (`domain/track_analysis.dart`), split length
/// respecting [unitSystem] (1 km for metric, 1 mile for imperial). Renders
/// nothing at all - no heading, no placeholder - while samples are loading,
/// on error, or when the track is too short to produce any split (this
/// section, unlike the route map, has no "not available yet" state worth
/// showing; a manual activity never reaches this widget at all, since it's
/// only built for `recorded` activities by `activity_detail_screen.dart`).
///
/// Extracted out of `activity_detail_screen.dart` (F5) along with its two
/// private helper widgets below, both to keep that screen file under the
/// project's ~300-line splitting instinct and because the fairness fix
/// below (only full splits compete for "fastest") is naturally scoped to
/// this file rather than the screen that merely hosts it.
class SplitsSection extends ConsumerWidget {
  const SplitsSection({
    required this.activityId,
    required this.unitSystem,
    super.key,
  });

  final String activityId;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsync = ref.watch(activitySamplesProvider(activityId));

    return samplesAsync.when(
      data: (samples) {
        final splitMeters = unitSystem == UnitSystem.imperial
            ? _mileMeters
            : 1000.0;
        final splits = computeSplits(samples, splitMeters: splitMeters);
        if (splits.isEmpty) return const SizedBox.shrink();
        return _SplitsList(
          splits: splits,
          unitSystem: unitSystem,
          splitMeters: splitMeters,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

/// Whether [splits][index] is the trailing partial split (see
/// `computeSplits`' doc - the remainder after the last full [splitMeters]
/// interval, included only when it's at least 50 m). It is the *only*
/// split that can ever be shorter than [splitMeters], and only ever the
/// last one. A small floating-point tolerance absorbs the interpolated-
/// boundary arithmetic in `computeSplits` landing a hair under the exact
/// split length.
bool _isPartialSplit(List<Split> splits, int index, double splitMeters) =>
    index == splits.length - 1 &&
    splits[index].distanceMeters < splitMeters - 1e-6;

/// For [splits] (as returned by `computeSplits(..., splitMeters:
/// splitMeters)`), returns - in the same order - whether each split should
/// render as the "fastest" (highlighted) row.
///
/// Only a FULL split ever competes: a short trailing partial split is easy
/// to run artificially fast (a sprint finish over 200m looks deceptively
/// quick next to full-length splits) and would otherwise unfairly win, or
/// unfairly compress every other split's bar against an unrepresentative
/// baseline (see [SplitsSection]'s F5 doc). On an exact pace tie among the
/// full splits, only the *first* tied split is flagged - never every tied
/// row.
///
/// Degenerate fallback: a track shorter than one full split produces a
/// single partial split and nothing else - with no full split to judge
/// against, every split (i.e. just that lone partial) is treated as its
/// own baseline, so something is still highlighted.
///
/// A public top-level function (rather than folded inline into
/// `_SplitsList`'s build method) so this fairness logic is unit-testable
/// directly against hand-built [Split] values, independent of GPS geometry
/// and its floating-point noise (see `splits_section_test.dart`).
List<bool> splitHighlightFlags(List<Split> splits, double splitMeters) {
  final fullIndexes = [
    for (var i = 0; i < splits.length; i++)
      if (!_isPartialSplit(splits, i, splitMeters)) i,
  ];
  final referenceIndexes = fullIndexes.isNotEmpty
      ? fullIndexes
      : List.generate(splits.length, (i) => i);

  final fastestPace = referenceIndexes.isEmpty
      ? null
      : referenceIndexes
            .map((i) => splits[i].paceSecondsPerKm)
            .reduce((a, b) => a < b ? a : b);

  var highlightAssigned = false;
  return [
    for (var i = 0; i < splits.length; i++)
      _flagAndConsume(
        matches:
            fastestPace != null &&
            referenceIndexes.contains(i) &&
            !highlightAssigned &&
            splits[i].paceSecondsPerKm == fastestPace,
        onMatch: () => highlightAssigned = true,
      ),
  ];
}

bool _flagAndConsume({
  required bool matches,
  required void Function() onMatch,
}) {
  if (matches) onMatch();
  return matches;
}

class _SplitsList extends StatelessWidget {
  const _SplitsList({
    required this.splits,
    required this.unitSystem,
    required this.splitMeters,
  });

  final List<Split> splits;
  final UnitSystem unitSystem;

  /// The `splitMeters` [computeSplits] was called with - needed here (not
  /// just by the caller) to tell a genuine full split apart from the
  /// trailing partial one (see [splitHighlightFlags]).
  final double splitMeters;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    final highlightFlags = splitHighlightFlags(splits, splitMeters);
    final highlightedIndex = highlightFlags.indexOf(true);
    final fastestPace = highlightedIndex == -1
        ? null
        : splits[highlightedIndex].paceSecondsPerKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Splits', style: textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        for (var i = 0; i < splits.length; i++)
          _buildRow(
            splits[i],
            isFastest: highlightFlags[i],
            // Every bar (full or partial) is scaled against the fastest
            // FULL split's pace, capped at 1.0 - a fast partial's bar
            // never overflows past a full width even though it may be
            // faster than the baseline it's compared to.
            barFraction: fastestPace == null
                ? 1.0
                : (fastestPace / splits[i].paceSecondsPerKm).clamp(0.0, 1.0),
            tokens: tokens,
          ),
      ],
    );
  }

  Widget _buildRow(
    Split split, {
    required bool isFastest,
    required double barFraction,
    required AppTokens tokens,
  }) {
    return Padding(
      key: ValueKey('split-${split.index}'),
      padding: EdgeInsets.only(bottom: tokens.spacingXs),
      child: _SplitRow(
        split: split,
        unitSystem: unitSystem,
        isFastest: isFastest,
        barFraction: barFraction,
      ),
    );
  }
}

/// One split's row: index, distance, a bar sized relative to the fastest
/// *full* split in the list (see [splitHighlightFlags] - that split's
/// bar always fills the available width, and a trailing partial split's bar
/// is scaled against the same baseline, capped at 1.0 rather than allowed
/// to overflow). The fastest full split's row gets a subtle highlight
/// background; a partial split never does, even if it happens to be faster
/// than every full split.
class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.split,
    required this.unitSystem,
    required this.isFastest,
    required this.barFraction,
  });

  final Split split;
  final UnitSystem unitSystem;
  final bool isFastest;
  final double barFraction;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingSm,
        vertical: tokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isFastest ? colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('${split.index}', style: textTheme.bodyMedium),
          ),
          SizedBox(width: tokens.spacingSm),
          SizedBox(
            width: 64,
            child: Text(
              formatDistance(split.distanceMeters, unitSystem),
              style: textTheme.bodySmall,
            ),
          ),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 8,
                  width: constraints.maxWidth * barFraction,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.spacingSm),
          Text(
            formatPace(split.paceSecondsPerKm, unitSystem),
            style: textTheme.bodyMedium?.tabularFigures,
          ),
        ],
      ),
    );
  }
}
