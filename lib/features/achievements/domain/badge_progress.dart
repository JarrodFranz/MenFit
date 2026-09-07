import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

/// Where the user currently stands on one badge — the three things the
/// achievements screen shows at once: what she has earned, what is on
/// offer, and how far away the next rung is.
///
/// Produced by `domain/badge_progress_engine.dart`. Contains no strings of
/// its own beyond [definition]'s: the copy lives in the catalogue, and the
/// formatting of "12 km to Silver" belongs to presentation, which is why
/// [remainingToNext] is a canonical-unit number and not a sentence.
@immutable
class BadgeProgress {
  const BadgeProgress({
    required this.definition,
    required this.value,
    required this.isEarned,
    this.earnedTier,
    this.nextTier,
    this.currentThreshold,
    this.nextThreshold,
    this.remainingToNext,
    this.progressToNext = 0,
  });

  final BadgeDefinition definition;

  /// The current metric value in the badge's canonical unit
  /// ([BadgeDefinition.unit]). For a one-off badge this is `1` when earned
  /// and `0` otherwise — a one-off has no quantity, and pretending it does
  /// would invite a progress bar that cannot move.
  final double value;

  /// Whether anything at all has been earned: any tier for a tiered badge,
  /// the single award for a one-off.
  final bool isEarned;

  /// The highest tier reached, or `null` when none is yet. Always `null`
  /// for a one-off badge.
  final BadgeTier? earnedTier;

  /// The tier being worked towards. Never `null` for a tiered badge — the
  /// ladder is open-ended, so there is always one. Always `null` for a
  /// one-off.
  final BadgeTier? nextTier;

  /// The metric value [earnedTier] was reached at, or `0` when no tier is
  /// earned yet. `null` for a one-off.
  final double? currentThreshold;

  /// The metric value [nextTier] is reached at. `null` for a one-off.
  final double? nextThreshold;

  /// How much more is needed to reach [nextTier], in canonical units.
  /// Never negative. `null` for a one-off.
  final double? remainingToNext;

  /// Fraction of the way from [currentThreshold] to [nextThreshold], in
  /// `[0, 1]`. `1` for an earned one-off, `0` for an unearned one.
  final double progressToNext;

  /// Every tier earned, lowest first — the full ladder up to and including
  /// [earnedTier]. Empty when nothing is earned, and always empty for a
  /// one-off badge.
  List<BadgeTier> get earnedTiers => earnedTier?.andBelow ?? const [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgeProgress &&
          other.definition == definition &&
          other.value == value &&
          other.isEarned == isEarned &&
          other.earnedTier == earnedTier &&
          other.nextTier == nextTier &&
          other.currentThreshold == currentThreshold &&
          other.nextThreshold == nextThreshold &&
          other.remainingToNext == remainingToNext &&
          other.progressToNext == progressToNext);

  @override
  int get hashCode => Object.hash(
    definition,
    value,
    isEarned,
    earnedTier,
    nextTier,
    currentThreshold,
    nextThreshold,
    remainingToNext,
    progressToNext,
  );

  @override
  String toString() =>
      'BadgeProgress(${definition.id}, value: $value, '
      'earned: ${earnedTier?.toStorage() ?? isEarned}, '
      'next: ${nextTier?.toStorage()})';
}
