import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

part 'badge_award.freezed.dart';

/// The `tier_key` stored for a one-off badge, which has no tier.
///
/// A sentinel rather than `NULL` on purpose: SQLite treats two NULLs as
/// distinct inside a UNIQUE constraint, so a nullable tier column would let
/// the same one-off be awarded any number of times and quietly break
/// `AwardRepository.recordAward`'s idempotency. See
/// `core/db/tables/badge_awards.dart`.
const String oneOffAwardTierKey = 'once';

/// The storage key for [tier] — its own key, or [oneOffAwardTierKey] when
/// there is no tier.
String awardTierKey(BadgeTier? tier) => tier?.toStorage() ?? oneOffAwardTierKey;

/// One badge the user has earned, as persisted.
///
/// A tiered badge produces **one award per tier crossed**: reaching Gold
/// leaves a Bronze, a Silver and a Gold award, each with the moment it was
/// reached. A one-off produces exactly one award with a `null` [tier].
///
/// Awards are never revoked. Deleting the activity that earned one does not
/// take the badge away — the moment happened, and un-awarding it would be
/// the app telling her it had changed its mind about something she did.
/// (Deleting *all* data does remove them, along with everything else.)
@freezed
abstract class BadgeAward with _$BadgeAward {
  const factory BadgeAward({
    /// Client-generated UUIDv7.
    required String id,

    /// The catalogue id — see `domain/badge_definition.dart`'s id contract.
    required String badgeId,

    /// UTC.
    required DateTime awardedAt,

    /// `null` for a one-off badge.
    BadgeTier? tier,
  }) = _BadgeAward;

  const BadgeAward._();

  /// The `(badgeId, tierKey)` pair that identifies this award uniquely —
  /// the same pair the database's unique constraint is built on.
  (String, String) get identity => (badgeId, awardTierKey(tier));
}
