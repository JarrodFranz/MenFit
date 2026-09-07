import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_emblem.dart';

/// How many freshly-crossed badges are celebrated one by one before the
/// dialog collapses into a single "caught up" summary.
///
/// The first detector run on an established install can legitimately return
/// twenty awards at once (`domain/award_diff.dart` explains why: every
/// crossed rung is awarded, not only the highest). Twenty celebrations in a
/// row is not twenty times the joy — it is a modal queue they have to dismiss
/// one at a time, and it would make the app's first badge moment an
/// annoyance.
const int badgeCelebrationFloodThreshold = 3;

/// A resolved award: the persisted fact plus the catalogue entry it names.
@immutable
class CelebratedBadge {
  const CelebratedBadge({required this.award, required this.definition});

  final BadgeAward award;
  final BadgeDefinition definition;
}

/// Resolves [awards] against the catalogue, dropping any whose badge is no
/// longer defined.
///
/// An award for an unknown id is not an error — `badge_catalogue.dart`'s
/// rule 1 anticipates it — but it is not something to celebrate either,
/// because there is no title to celebrate it *with*.
List<CelebratedBadge> resolveCelebratedBadges(List<BadgeAward> awards) {
  return [
    for (final award in awards)
      if (badgeDefinitionFor(award.badgeId) case final definition?)
        CelebratedBadge(award: award, definition: definition),
  ];
}

/// The celebration for badges that have just been crossed.
///
/// Shares its shape — gradient crest, headline, affirmation, one filled
/// button — with
/// `features/activity/presentation/widgets/workout_celebration_dialog.dart`,
/// and its crest with every other badge surface via [BadgeEmblem]. It is a
/// separate dialog rather than a reuse of that one because it celebrates a
/// different thing: that one is about the session just finished, this one
/// about a lifetime total crossing a line.
class BadgeCelebrationDialog extends ConsumerStatefulWidget {
  const BadgeCelebrationDialog({required this.badges, super.key});

  /// The badges to celebrate. An empty list renders nothing at all rather
  /// than throwing — [show] already declines to open a celebration with
  /// nothing in it, and the widget is public, so it must survive being
  /// built with one directly instead of blowing up inside `reduce`.
  final List<CelebratedBadge> badges;

  /// Shows the celebration for [awards], or does nothing when there is
  /// nothing left to celebrate after resolving them.
  static Future<void> show(
    BuildContext context, {
    required List<BadgeAward> awards,
  }) {
    final badges = resolveCelebratedBadges(awards);
    if (badges.isEmpty) return Future<void>.value();
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => BadgeCelebrationDialog(badges: badges),
    );
  }

  @override
  ConsumerState<BadgeCelebrationDialog> createState() =>
      _BadgeCelebrationDialogState();
}

class _BadgeCelebrationDialogState extends ConsumerState<BadgeCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    final preferences = ref.read(accessibilityControllerProvider);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    if (preferences.reduceMotion) {
      _animController.value = 1;
    } else {
      _animController.forward();
    }
    unawaited(AccessibilityHaptics.mediumImpact(ref));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badges = widget.badges;
    // See [BadgeCelebrationDialog.badges]: nothing to celebrate is a
    // no-op, never a `reduce` on an empty list.
    if (badges.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isFlood = badges.length > badgeCelebrationFloodThreshold;
    // The crest at the top wears the highest rung in the batch, so a run
    // that reached Gold does not lead with its Bronze.
    final headline = badges.reduce((best, badge) {
      final bestTier = best.award.tier;
      final tier = badge.award.tier;
      if (tier == null) return best;
      if (bestTier == null || tier > bestTier) return badge;
      return best;
    });
    final title = switch (badges.length) {
      1 => newBadgeCelebrationTitle,
      _ when isFlood => catchUpCelebrationTitle(badges.length),
      _ => newBadgesCelebrationTitle,
    };

    return ScaleTransition(
      scale: _scale,
      child: Dialog(
        key: const Key('badgeCelebrationDialog'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacingLg,
          vertical: tokens.spacingXl,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeEmblem(
                kind: headline.definition.kind,
                tier: headline.award.tier,
                isEarned: true,
                size: 72,
              ),
              SizedBox(height: tokens.spacingMd),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spacingXs),
              Text(
                isFlood ? catchUpAffirmation : newBadgeAffirmation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spacingLg),
              // Every badge is listed either way — a summary that hides
              // what it summarises is worse than the queue it replaced.
              // The flood form is simply the compact one.
              for (final badge in badges)
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacingSm),
                  child: BadgeCelebrationRow(badge: badge, compact: isFlood),
                ),
              SizedBox(height: tokens.spacingSm),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(celebrationDismissLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One badge inside a celebration — the crest, the badge's name and, for a
/// tiered badge, the rung just reached.
class BadgeCelebrationRow extends StatelessWidget {
  const BadgeCelebrationRow({
    required this.badge,
    this.compact = false,
    super.key,
  });

  final CelebratedBadge badge;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;
    final tier = badge.award.tier;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingMd,
        vertical: compact ? tokens.spacingXs : tokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          BadgeEmblem(
            kind: badge.definition.kind,
            tier: tier,
            isEarned: true,
            size: compact ? 24 : 36,
          ),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Text(
              badge.definition.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (tier != null)
            Text(
              tier.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
