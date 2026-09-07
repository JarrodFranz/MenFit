import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// One rung of a tiered badge's ladder.
///
/// Five named tiers — Bronze, Silver, Gold, Platinum, Diamond — followed by
/// an **open-ended** run of further Diamond levels (Diamond II, Diamond
/// III, …). The ladder deliberately never tops out: a user who has been
/// with the app for years must always have a next rung, and a badge whose
/// highest tier can be reached and then never moved again stops being a
/// progression ladder the moment they reach it.
///
/// Modelled as a value type over a single integer [rank] rather than an
/// `enum`, because an enum cannot be open-ended. `rank` 0-3 are the four
/// lower named tiers; every `rank >= 4` is a Diamond level, with
/// `diamondLevel == rank - 3`. So `BadgeTier.diamond(1)` **is** the named
/// Diamond tier (label `"Diamond"`, not `"Diamond I"`), and
/// `BadgeTier.diamond(2)` is `"Diamond II"`.
///
/// Ordering is by [rank], so tiers compare and sort naturally, and
/// `tier.next` is always defined.
@immutable
final class BadgeTier implements Comparable<BadgeTier> {
  const BadgeTier._(this.rank);

  /// The Diamond tier at [level] (1-based). `diamond(1)` is the named
  /// Diamond tier itself.
  ///
  /// Not a `const` constructor because it computes; the instances it
  /// returns are still ordinary immutable values.
  factory BadgeTier.diamond(int level) {
    assert(level >= 1, 'Diamond levels are 1-based.');
    return BadgeTier._(_firstDiamondRank + (level - 1));
  }

  /// Parses the persisted key form (see [toStorage]). Returns `null` for
  /// anything unrecognised — including `'once'`, which is a one-off
  /// badge's award key and not a tier at all (see
  /// `domain/badge_award.dart`).
  static BadgeTier? fromStorage(String value) {
    switch (value) {
      case 'bronze':
        return bronze;
      case 'silver':
        return silver;
      case 'gold':
        return gold;
      case 'platinum':
        return platinum;
    }
    if (!value.startsWith(_diamondPrefix)) return null;
    final level = int.tryParse(value.substring(_diamondPrefix.length));
    if (level == null || level < 1) return null;
    return BadgeTier.diamond(level);
  }

  static const int _firstDiamondRank = 4;
  static const String _diamondPrefix = 'diamond-';

  static const BadgeTier bronze = BadgeTier._(0);
  static const BadgeTier silver = BadgeTier._(1);
  static const BadgeTier gold = BadgeTier._(2);
  static const BadgeTier platinum = BadgeTier._(3);

  /// The named Diamond tier — identical to `BadgeTier.diamond(1)`.
  static const BadgeTier diamondI = BadgeTier._(_firstDiamondRank);

  /// The five tiers a `BadgeLadder` gives explicit thresholds for, in
  /// order. Everything above [diamondI] comes from the ladder's diamond
  /// progression rule instead.
  ///
  /// (`BadgeLadder` lives in `domain/badge_definition.dart`.)
  static const List<BadgeTier> namedTiers = [
    bronze,
    silver,
    gold,
    platinum,
    diamondI,
  ];

  /// 0 for Bronze, rising by one per tier, unbounded above.
  final int rank;

  /// Whether this is a Diamond tier of any level.
  bool get isDiamond => rank >= _firstDiamondRank;

  /// 1-based Diamond level, or `0` for the four lower named tiers.
  int get diamondLevel => isDiamond ? rank - (_firstDiamondRank - 1) : 0;

  /// The tier immediately above this one. Always defined — the ladder has
  /// no top.
  BadgeTier get next => BadgeTier._(rank + 1);

  /// Display label: `"Bronze"` … `"Platinum"`, `"Diamond"`, then
  /// `"Diamond II"`, `"Diamond III"`, …
  ///
  /// Falls back to an arabic numeral past 3999, where roman numerals stop
  /// being expressible (and long since stopped being readable).
  String get label {
    switch (rank) {
      case 0:
        return 'Bronze';
      case 1:
        return 'Silver';
      case 2:
        return 'Gold';
      case 3:
        return 'Platinum';
    }
    final level = diamondLevel;
    if (level == 1) return 'Diamond';
    final roman = _toRoman(level);
    return roman == null ? 'Diamond $level' : 'Diamond $roman';
  }

  /// The persisted key form: `'bronze'`, `'silver'`, `'gold'`,
  /// `'platinum'`, `'diamond-1'`, `'diamond-2'`, …
  ///
  /// **Never change these strings.** They are the other half of the
  /// stable-id contract documented on `BadgeDefinition.id`: a stored award
  /// is `(badgeId, tierKey)`, so renaming a key orphans every award at
  /// that tier.
  String toStorage() {
    switch (rank) {
      case 0:
        return 'bronze';
      case 1:
        return 'silver';
      case 2:
        return 'gold';
      case 3:
        return 'platinum';
    }
    return '$_diamondPrefix$diamondLevel';
  }

  /// Every tier from [bronze] up to and including this one, in order.
  List<BadgeTier> get andBelow => [
    for (var r = 0; r <= rank; r++) BadgeTier._(r),
  ];

  @override
  int compareTo(BadgeTier other) => rank.compareTo(other.rank);

  bool operator <(BadgeTier other) => rank < other.rank;

  bool operator <=(BadgeTier other) => rank <= other.rank;

  bool operator >(BadgeTier other) => rank > other.rank;

  bool operator >=(BadgeTier other) => rank >= other.rank;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BadgeTier && other.rank == rank);

  @override
  int get hashCode => rank.hashCode;

  @override
  String toString() => 'BadgeTier(${toStorage()})';
}

const List<(int, String)> _romanNumerals = [
  (1000, 'M'),
  (900, 'CM'),
  (500, 'D'),
  (400, 'CD'),
  (100, 'C'),
  (90, 'XC'),
  (50, 'L'),
  (40, 'XL'),
  (10, 'X'),
  (9, 'IX'),
  (5, 'V'),
  (4, 'IV'),
  (1, 'I'),
];

/// Roman numeral for 1..3999, or `null` outside that range.
String? _toRoman(int value) {
  if (value < 1 || value > 3999) return null;
  final buffer = StringBuffer();
  var remaining = value;
  for (final (amount, symbol) in _romanNumerals) {
    while (remaining >= amount) {
      buffer.write(symbol);
      remaining -= amount;
    }
  }
  return buffer.toString();
}
