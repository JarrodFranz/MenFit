import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/home/domain/home_recent_award.dart';

BadgeAward _award({
  required String id,
  required DateTime awardedAt,
  BadgeTier? tier,
  String badgeId = 'distance-lifetime',
}) => BadgeAward(
  id: id,
  badgeId: badgeId,
  awardedAt: awardedAt,
  tier: tier,
);

void main() {
  group('mostRecentAward', () {
    test('is null when nothing has been earned', () {
      expect(mostRecentAward(const []), isNull);
    });

    test('picks the latest moment regardless of the list order', () {
      final older = _award(id: 'a', awardedAt: DateTime.utc(2026, 1, 4));
      final newer = _award(id: 'b', awardedAt: DateTime.utc(2026, 8, 5));

      // Oldest-first, i.e. the opposite of what the repository happens to
      // emit today — this must not depend on that ordering.
      expect(mostRecentAward([older, newer])?.id, 'b');
      expect(mostRecentAward([newer, older])?.id, 'b');
    });

    test('a tie at the same instant resolves to the higher tier', () {
      final at = DateTime.utc(2026, 8, 5);
      final silver = _award(
        id: 'silver',
        awardedAt: at,
        tier: BadgeTier.silver,
      );
      final gold = _award(id: 'gold', awardedAt: at, tier: BadgeTier.gold);

      expect(mostRecentAward([silver, gold])?.id, 'gold');
      expect(mostRecentAward([gold, silver])?.id, 'gold');
    });

    test('a tiered award beats an untiered one at the same instant', () {
      final at = DateTime.utc(2026, 8, 5);
      final oneOff = _award(id: 'one-off', awardedAt: at);
      final bronze = _award(
        id: 'bronze',
        awardedAt: at,
        tier: BadgeTier.bronze,
      );

      expect(mostRecentAward([oneOff, bronze])?.id, 'bronze');
      expect(mostRecentAward([bronze, oneOff])?.id, 'bronze');
    });
  });
}
