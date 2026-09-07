import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/achievements/domain/award_diff.dart';
import 'package:menfit_app/features/achievements/domain/award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';

/// Turns "what the data currently earns" into "what has just been earned",
/// and writes the difference down.
///
/// The one piece of this feature that is neither pure domain nor
/// persistence: it reads the award repository, compares it against the
/// engine's output via `domain/award_diff.dart`, records what is new, and
/// hands back the new awards so a caller can celebrate them. That is
/// exactly the shape `architecture_overview.md` reserves the `application/`
/// layer for — orchestration across a pure engine and a repository, with no
/// rules of its own.
///
/// ## Where this is meant to run
///
/// Two places, once the UI half exists:
///
/// * **On opening the achievements screen** — the catch-all. Anything
///   earned while the app was elsewhere (or on another day, as a week rolls
///   over) is picked up here.
/// * **After a completed workout**, alongside the existing per-workout
///   milestone celebration (`features/activity/domain/milestone_evaluator.dart`).
///   Badges are lifetime and periodic; milestones are about the session
///   just finished. They are two systems and stay two systems — this one
///   simply gets a second chance to notice a crossing at the moment it
///   most likely happened.
///
/// **No trigger is wired here.** Reaching into another feature's flow is
/// the UI half's job; this class only has to be callable from both.
///
/// Running it twice in a row is harmless: the second run finds everything
/// already held and returns an empty list.
class AwardDetector {
  AwardDetector(
    this._repository, {
    DateTime Function()? clock,
    String Function()? generateId,
  }) : _clock = clock ?? DateTime.now,
       _generateId = generateId ?? EntityId.generate;

  final AwardRepository _repository;
  final DateTime Function() _clock;
  final String Function() _generateId;

  /// Records every award [progress] earns that is not already held, and
  /// returns them — newest crossings only, in catalogue order with the
  /// lowest tier of each badge first.
  ///
  /// Returns an empty list when there is nothing new, which is the normal
  /// case on almost every run.
  ///
  /// ## The one honest caveat: read, then write
  ///
  /// The returned list is "what this run found missing and asked to be
  /// recorded", which is not quite the same as "what this run actually
  /// inserted". Between the read and the write another caller — the trophy
  /// case and the post-workout strip both run this, and they can overlap by
  /// a frame — may record the same crossing. Persistence stays correct
  /// either way ([AwardRepository.recordAward] is idempotent on
  /// `(badgeId, tier)`, enforced by a unique constraint), so the worst
  /// outcome is the same badge celebrated twice within one moment, once per
  /// surface.
  ///
  /// Closing the window would mean `recordAwards` reporting which rows were
  /// genuinely new — an insert-returning per award instead of one batch,
  /// and a changed repository signature — which is a real cost for a race
  /// that persists nothing wrong. Documented rather than engineered, on
  /// purpose. If double celebration is ever observed in the wild, that is
  /// the fix.
  Future<List<BadgeAward>> detect(List<BadgeProgress> progress) async {
    final existing = await _repository.getAwards();
    final fresh = newlyEarnedAwards(
      progress: progress,
      existingAwards: existing,
      awardedAt: _clock().toUtc(),
      generateId: _generateId,
    );
    if (fresh.isEmpty) return const [];
    await _repository.recordAwards(fresh);
    return fresh;
  }
}
