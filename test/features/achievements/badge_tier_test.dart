import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

void main() {
  group('ordering', () {
    test('the named tiers rise in order', () {
      expect(BadgeTier.bronze < BadgeTier.silver, isTrue);
      expect(BadgeTier.silver < BadgeTier.gold, isTrue);
      expect(BadgeTier.gold < BadgeTier.platinum, isTrue);
      expect(BadgeTier.platinum < BadgeTier.diamondI, isTrue);
      expect(BadgeTier.diamondI < BadgeTier.diamond(2), isTrue);
    });

    test('next is always defined - the ladder has no top', () {
      var tier = BadgeTier.bronze;
      for (var i = 0; i < 50; i++) {
        final next = tier.next;
        expect(next > tier, isTrue);
        tier = next;
      }
      expect(tier.isDiamond, isTrue);
      expect(tier.diamondLevel, 47);
    });

    test('andBelow lists every tier up to and including this one', () {
      expect(BadgeTier.bronze.andBelow, [BadgeTier.bronze]);
      expect(BadgeTier.diamond(2).andBelow, [
        BadgeTier.bronze,
        BadgeTier.silver,
        BadgeTier.gold,
        BadgeTier.platinum,
        BadgeTier.diamond(1),
        BadgeTier.diamond(2),
      ]);
    });

    test('sorting a shuffled list restores the ladder order', () {
      final shuffled = [
        BadgeTier.diamond(3),
        BadgeTier.bronze,
        BadgeTier.platinum,
        BadgeTier.diamond(1),
        BadgeTier.silver,
      ]..sort();
      expect(shuffled, [
        BadgeTier.bronze,
        BadgeTier.silver,
        BadgeTier.platinum,
        BadgeTier.diamond(1),
        BadgeTier.diamond(3),
      ]);
    });
  });

  group('diamond levels', () {
    test('diamond(1) is the named Diamond tier, not "Diamond I"', () {
      expect(BadgeTier.diamond(1), BadgeTier.diamondI);
      expect(BadgeTier.diamondI.label, 'Diamond');
      expect(BadgeTier.diamondI.diamondLevel, 1);
    });

    test('later levels read as roman numerals', () {
      expect(BadgeTier.diamond(2).label, 'Diamond II');
      expect(BadgeTier.diamond(3).label, 'Diamond III');
      expect(BadgeTier.diamond(4).label, 'Diamond IV');
      expect(BadgeTier.diamond(9).label, 'Diamond IX');
      expect(BadgeTier.diamond(14).label, 'Diamond XIV');
      expect(BadgeTier.diamond(40).label, 'Diamond XL');
    });

    test('the numeral falls back to arabic past the roman range', () {
      expect(BadgeTier.diamond(3999).label, endsWith('MMMCMXCIX'));
      expect(BadgeTier.diamond(4000).label, 'Diamond 4000');
    });

    test('the four lower tiers report diamondLevel 0', () {
      for (final tier in [
        BadgeTier.bronze,
        BadgeTier.silver,
        BadgeTier.gold,
        BadgeTier.platinum,
      ]) {
        expect(tier.isDiamond, isFalse);
        expect(tier.diamondLevel, 0);
      }
    });
  });

  group('storage keys', () {
    test('round-trip through fromStorage', () {
      final tiers = [
        ...BadgeTier.namedTiers,
        BadgeTier.diamond(2),
        BadgeTier.diamond(17),
      ];
      for (final tier in tiers) {
        expect(BadgeTier.fromStorage(tier.toStorage()), tier);
      }
    });

    test('the keys are exactly the shipped strings', () {
      // Pinned literally: these are persisted, so a change here is a
      // migration, not a rename.
      expect(BadgeTier.bronze.toStorage(), 'bronze');
      expect(BadgeTier.silver.toStorage(), 'silver');
      expect(BadgeTier.gold.toStorage(), 'gold');
      expect(BadgeTier.platinum.toStorage(), 'platinum');
      expect(BadgeTier.diamond(1).toStorage(), 'diamond-1');
      expect(BadgeTier.diamond(12).toStorage(), 'diamond-12');
    });

    test('unrecognised keys read as null rather than throwing', () {
      expect(BadgeTier.fromStorage('once'), isNull);
      expect(BadgeTier.fromStorage(''), isNull);
      expect(BadgeTier.fromStorage('diamond-'), isNull);
      expect(BadgeTier.fromStorage('diamond-0'), isNull);
      expect(BadgeTier.fromStorage('diamond-x'), isNull);
      expect(BadgeTier.fromStorage('titanium'), isNull);
    });
  });

  test('equality is by rank, so instances interchange freely', () {
    expect(BadgeTier.diamond(3), BadgeTier.diamond(3));
    expect(BadgeTier.diamond(3).hashCode, BadgeTier.diamond(3).hashCode);
    expect(BadgeTier.diamond(3), isNot(BadgeTier.diamond(4)));
    final duplicated = [BadgeTier.gold, BadgeTier.gold];
    expect(duplicated.toSet(), hasLength(1));
  });
}
