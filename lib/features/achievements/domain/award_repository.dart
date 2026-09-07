import 'package:menfit_app/features/achievements/domain/badge_award.dart';

/// Persistence for earned badges.
///
/// Small by design: awards are append-only facts. There is no `update`,
/// because an award has nothing that can change, and no single-award
/// `delete`, because a badge is never taken away (see [BadgeAward]'s class
/// doc) — only [deleteAllData], which is the "Delete my data" flow wiping
/// everything at once.
///
/// **Ordering is newest first** on every read: the trophy case leads with
/// what was just earned, and a celebration sheet wants the latest award at
/// the top. Ties within the same millisecond break on `id` descending so
/// two awards recorded in the same batch still come back in a stable order.
///
/// S1-tier data (`knowledge/engineering/security_and_privacy.md`): a badge
/// id and a tier carry no health, cycle or location value in themselves.
/// They are still never logged — the *set* of badges someone has is a
/// fingerprint of her logging habits, which is not something to leave in a
/// crash report.
abstract interface class AwardRepository {
  /// Emits every award, newest first, on every change.
  Stream<List<BadgeAward>> watchAwards();

  /// One-shot fetch of exactly what [watchAwards] emits.
  ///
  /// It exists as its own method rather than as `watchAwards().first` on
  /// purpose — see
  /// `features/activity/domain/activity_repository.dart#getActivities` and
  /// the 2026-09-01 entry in the central `testing-pitfalls.md` for the
  /// widget-test deadlock that pattern causes.
  Future<List<BadgeAward>> getAwards();

  /// Records [award], **idempotently**.
  ///
  /// Awarding the same `(badgeId, tier)` twice is a no-op: the first
  /// award's id and `awardedAt` stand, and the second call changes nothing
  /// and does not throw. Idempotency is enforced by the table's unique
  /// constraint rather than only by a read-then-write, so two concurrent
  /// detector runs cannot both slip an award through
  /// (`core/db/tables/badge_awards.dart`).
  ///
  /// This matters more than it looks: the detector runs on screen-open and
  /// after a workout, so the same crossing is offered to this method
  /// repeatedly, and a duplicate would show up as the same badge
  /// celebrated twice.
  Future<void> recordAward(BadgeAward award);

  /// Records [awards] in one transaction, with [recordAward]'s
  /// idempotency applied to each. Recording an empty list is a no-op.
  Future<void> recordAwards(List<BadgeAward> awards);

  /// Permanently deletes every award on this device (part of the
  /// "Delete my data" flow — see
  /// `features/settings/presentation/settings_screen.dart`).
  Future<void> deleteAllData();
}
