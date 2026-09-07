import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_emblem.dart';

/// One badge in the trophy case: what she has earned, what it is, and — the
/// hero of the tile — how far the next rung is.
///
/// Earned and unearned differ in weight, never in presence: an unearned
/// badge is muted, but it is fully readable, fully described, and carries
/// the same progress bar. It is an invitation, and an invitation that has
/// been greyed into illegibility is a rejection.
class BadgeTile extends StatefulWidget {
  const BadgeTile({
    required this.progress,
    this.awardedAtByTierKey = const {},
    super.key,
  });

  final BadgeProgress progress;

  /// When each held rung was recorded, keyed by [awardTierKey] — the
  /// one-off sentinel included. Empty when the awards have not loaded yet,
  /// which simply means the expansion shows the ladder without dates.
  final Map<String, DateTime> awardedAtByTierKey;

  @override
  State<BadgeTile> createState() => _BadgeTileState();
}

class _BadgeTileState extends State<BadgeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final progress = widget.progress;
    final definition = progress.definition;
    final canExpand = progress.isEarned;

    final body = Padding(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            progress: progress,
            expanded: _expanded,
            canExpand: canExpand,
          ),
          SizedBox(height: tokens.spacingSm),
          Text(
            definition.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          if (definition.kind == BadgeKind.tiered)
            _NextRung(progress: progress)
          else
            _OneOffState(progress: progress),
          if (_expanded && canExpand) ...[
            SizedBox(height: tokens.spacingSm),
            const Divider(height: 1),
            SizedBox(height: tokens.spacingSm),
            _EarnedLadder(
              progress: progress,
              awardedAtByTierKey: widget.awardedAtByTierKey,
            ),
          ],
        ],
      ),
    );

    return Card(
      key: Key('badgeTile_${definition.id}'),
      margin: EdgeInsets.only(bottom: tokens.spacingSm),
      child: canExpand
          ? InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              onTap: () => setState(() => _expanded = !_expanded),
              child: body,
            )
          : body,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.progress,
    required this.expanded,
    required this.canExpand,
  });

  final BadgeProgress progress;
  final bool expanded;
  final bool canExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final definition = progress.definition;
    final earnedTier = progress.earnedTier;

    return Row(
      children: [
        BadgeEmblem(
          kind: definition.kind,
          tier: earnedTier,
          isEarned: progress.isEarned,
        ),
        SizedBox(width: tokens.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // The tier's NAME, always, beside the crest: the emblem's
              // colour is decoration on top of this label and never a
              // substitute for it (`presentation/badge_tier_style.dart`).
              if (earnedTier != null)
                Text(
                  earnedTier.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        if (canExpand)
          Icon(
            expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// The tiered badge's hero: the bar, the distance to the next rung, and
/// where she stands now.
class _NextRung extends StatelessWidget {
  const _NextRung({required this.progress});

  final BadgeProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final remaining = remainingToNextLine(progress);
    final current = currentValueLine(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          child: LinearProgressIndicator(
            value: progress.progressToNext,
            minHeight: 8,
            // The sentence goes in the LABEL, never in `semanticsValue`:
            // a progress-bar semantics node's value is validated as a
            // number or a percentage (`SemanticsRole.progressBar` in
            // `semantics.dart`), so "12 km to Silver" there throws for
            // every user running a screen reader. Leaving the value unset
            // keeps the framework's own "84%" default.
            semanticsLabel: progressSemanticsLabel(progress),
          ),
        ),
        SizedBox(height: tokens.spacingXs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (remaining != null)
              Flexible(
                child: Text(
                  remaining,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (current != null)
              Flexible(
                child: Text(
                  current,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A one-off has no ladder, so it gets no bar — a progress bar that cannot
/// move is a promise the badge cannot keep. It gets a quiet marker instead.
class _OneOffState extends StatelessWidget {
  const _OneOffState({required this.progress});

  final BadgeProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final earned = progress.isEarned;
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        visualDensity: VisualDensity.compact,
        label: Text(earned ? oneOffEarnedLabel : oneOffPendingLabel),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: earned
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        backgroundColor: earned
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }
}

/// The rungs already held, lowest first, each with the day it was recorded.
class _EarnedLadder extends StatelessWidget {
  const _EarnedLadder({
    required this.progress,
    required this.awardedAtByTierKey,
  });

  final BadgeProgress progress;
  final Map<String, DateTime> awardedAtByTierKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final tiers = progress.earnedTiers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tiers.isEmpty)
          _LadderRow(
            label: oneOffEarnedLabel,
            awardedAt: awardedAtByTierKey[oneOffAwardTierKey],
          )
        else
          for (final tier in tiers)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingXs),
              child: _LadderRow(
                label: tier.label,
                awardedAt: awardedAtByTierKey[awardTierKey(tier)],
              ),
            ),
      ],
    );
  }
}

class _LadderRow extends StatelessWidget {
  const _LadderRow({required this.label, this.awardedAt});

  final String label;
  final DateTime? awardedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final stamp = awardedAt;

    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: tokens.spacingXs),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        if (stamp != null)
          Text(
            awardedOnLine(stamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
