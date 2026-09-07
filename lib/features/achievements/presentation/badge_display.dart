/// What the trophy case actually renders: the engine's read of the data,
/// merged with the awards already persisted.
///
/// ## Why this exists
///
/// `domain/badge_progress_engine.dart` answers one question — *what does
/// the data earn today* — and deliberately never consults persistence. That
/// keeps it pure, but it is not the question the screen asks. Awards are
/// **never revoked** (`domain/award_repository.dart`), so a badge they have
/// been awarded must keep showing as held even when the underlying data
/// later evaluates lower.
///
/// It can. The cycle-pausing toggle changes which days count as protected,
/// which changes the pro-rated ask of the walking ladder
/// (`domain/weekly_walking_rule.dart`); deleting an activity lowers a
/// lifetime total. Rendering the engine's answer alone would take their
/// Silver off the tile while the award row still sat in the database and
/// the Progress card still counted it — the case and the card disagreeing
/// about what they own.
///
/// So the merge lives here, in presentation, and the engine stays
/// pure-data. This layer is the only place the two are combined, and
/// [displayedBadgeProgress] is a pure function so the rule is testable
/// without a widget.
library;

import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'badge_display.g.dart';

/// [badgeProgressProvider] with every persisted award folded in — the
/// trophy case's data source.
///
/// Awards are watched, not fetched once: recording a fresh award during
/// detection re-emits and the tile updates with it.
///
/// The awards stream's own loading state is treated as "none yet" rather
/// than awaited, so a case whose progress is ready never waits on a second
/// source to paint. The first emission arrives a frame later and only ever
/// *adds* held rungs.
@riverpod
Future<List<BadgeProgress>> badgeDisplayProgress(Ref ref) async {
  final progress = await ref.watch(badgeProgressProvider.future);
  final awards = ref.watch(badgeAwardsProvider).value ?? const <BadgeAward>[];
  return displayedBadgeProgress(progress: progress, awards: awards);
}

/// [progress] with each badge raised to the highest of what the data earns
/// and what has already been awarded.
///
/// Only ever raises. Where the data is ahead of the awards — the ordinary
/// case, a rung crossed but not yet recorded — the engine's answer stands
/// untouched, and the detector records it moments later.
///
/// For a raised tiered badge:
///
/// * the **tier shown** is the awarded one, with its full ladder beneath it;
/// * the **bar** runs from that tier to the rung above it, so the next rung
///   on offer is always the one above the higher of the two readings (it
///   sits at zero, because the data is behind that rung);
/// * the **value** is left exactly as the engine computed it, so "88 km so
///   far" keeps saying what they have actually logged. The badge they were
///   given is theirs; the number underneath it is not retconned to match.
List<BadgeProgress> displayedBadgeProgress({
  required List<BadgeProgress> progress,
  required List<BadgeAward> awards,
}) {
  if (awards.isEmpty) return progress;

  final heldTiers = <String, BadgeTier>{};
  final heldOneOffs = <String>{};
  for (final award in awards) {
    final tier = award.tier;
    if (tier == null) {
      heldOneOffs.add(award.badgeId);
      continue;
    }
    final held = heldTiers[award.badgeId];
    if (held == null || tier > held) heldTiers[award.badgeId] = tier;
  }

  return [
    for (final badge in progress)
      _raisedToHeld(
        badge,
        heldTier: heldTiers[badge.definition.id],
        heldOneOff: heldOneOffs.contains(badge.definition.id),
      ),
  ];
}

/// The number of badges in the case, from whatever the caller knows.
///
/// **One definition, used by every surface that shows a count:** a badge is
/// in the case when the data earns it *or* an award for it is held. The
/// trophy case header passes the merged list from [displayedBadgeProgress]
/// (which already carries both); the Progress card, which deliberately does
/// not pay for the full history walk, passes the awards alone. Before this
/// existed the two counted different things and could disagree on screen.
///
/// An award whose badge is no longer in the catalogue is not counted — there
/// is no tile for it and no title to name it with, so counting it would
/// leave the header ahead of the case by a badge nobody can point at.
int earnedBadgeCount({
  Iterable<BadgeProgress> progress = const [],
  Iterable<BadgeAward> awards = const [],
}) {
  final earned = <String>{
    for (final badge in progress)
      if (badge.isEarned) badge.definition.id,
    for (final award in awards)
      if (badgeDefinitionFor(award.badgeId) != null) award.badgeId,
  };
  return earned.length;
}

BadgeProgress _raisedToHeld(
  BadgeProgress badge, {
  required BadgeTier? heldTier,
  required bool heldOneOff,
}) {
  final ladder = badge.definition.ladder;

  if (ladder == null) {
    // A one-off: earned is the whole state, and `value` is its 1-or-0
    // restatement (see `BadgeProgress.value`).
    if (!heldOneOff || badge.isEarned) return badge;
    return BadgeProgress(
      definition: badge.definition,
      value: 1,
      isEarned: true,
      progressToNext: 1,
    );
  }

  if (heldTier == null) return badge;
  final dataTier = badge.earnedTier;
  if (dataTier != null && dataTier >= heldTier) return badge;

  final nextTier = heldTier.next;
  final currentThreshold = ladder.thresholdFor(heldTier);
  final nextThreshold = ladder.thresholdFor(nextTier);
  final span = nextThreshold - currentThreshold;
  // Negative whenever the data sits below the awarded rung, which is the
  // whole reason this branch was taken; the clamp reads it as "no progress
  // towards the next rung yet" rather than as a bar running backwards.
  final fraction = span <= 0 ? 0.0 : (badge.value - currentThreshold) / span;

  return BadgeProgress(
    definition: badge.definition,
    value: badge.value,
    isEarned: true,
    earnedTier: heldTier,
    nextTier: nextTier,
    currentThreshold: currentThreshold,
    nextThreshold: nextThreshold,
    remainingToNext: nextThreshold > badge.value
        ? nextThreshold - badge.value
        : 0,
    progressToNext: fraction.clamp(0.0, 1.0),
  );
}
