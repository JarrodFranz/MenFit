import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// Which country's products a food-database text search is confined to.
///
/// ## Why this exists
///
/// Open Food Facts is a **global** database with no default locality. A
/// search for "cheese" from Australia was observed (2026-09-03, release
/// build) returning Bulgarian products with Cyrillic names and Cyrillic
/// quantities — records that are perfectly good data and completely useless
/// to the person searching, because they cannot buy them, cannot read them,
/// and cannot check the packet against them.
///
/// The fix is a **country filter on the request**, not a filter on the
/// response. Deliberately not a script or language heuristic over the
/// results: "does this name look like the user's alphabet" is exactly the
/// kind of rule that quietly drops legitimate products — a French brand sold
/// in Australia, a product whose only contributor-entered name is in the
/// language of its manufacturer — and it would still have spent the request.
///
/// ## Why so few countries
///
/// This is not a picker of every country Open Food Facts knows. It is a
/// short list of the markets where the database has enough branded-product
/// coverage to be worth searching *and* where the app's single English
/// locale is the language on the packet, plus [anywhere] for everyone else.
/// A 200-entry dropdown of countries with a dozen products each would
/// present the empty result as the user's mistake. Adding a country here is
/// a product decision — see ADR 010's 2026-09-03 amendment.
enum FoodSearchRegion {
  /// No country filter at all — the pre-2026-09-03 behaviour, kept as an
  /// explicit choice for anyone shopping outside the listed markets. The
  /// language preference still applies, so names come back localised where
  /// the record has them.
  anywhere('Anywhere', null, null),
  australia('Australia', 'en:australia', 'australia'),
  newZealand('New Zealand', 'en:new-zealand', 'new-zealand'),
  unitedKingdom('United Kingdom', 'en:united-kingdom', 'united-kingdom'),
  unitedStates('United States', 'en:united-states', 'united-states'),
  canada('Canada', 'en:canada', 'canada'),
  ireland('Ireland', 'en:ireland', 'ireland');

  const FoodSearchRegion(this.label, this.countryTag, this.countrySlug);

  /// What the user sees in Settings and under the online results.
  final String label;

  /// Open Food Facts' canonical `countries_tags` value, or `null` for
  /// [anywhere]. Always `en:`-prefixed regardless of the user's language:
  /// the prefix is the tag's own taxonomy language, not a display language.
  final String? countryTag;

  /// The same country as the legacy CGI search's `tag_0` spells it — the
  /// tag without its taxonomy prefix. Two spellings because the two search
  /// endpoints take the filter differently, and the difference is transport
  /// detail that belongs beside the values rather than in a `switch` at the
  /// call site.
  final String? countrySlug;

  /// Whether a request built for this region carries a country filter at
  /// all.
  bool get filtersByCountry => countryTag != null;

  /// The region a device in [countryCode] should default to, or `null` when
  /// this app has no entry for that country.
  ///
  /// `null` rather than [anywhere] so callers can tell "they are in a country
  /// we cover" from "we have no entry and are falling back", which are
  /// different facts even though they currently produce the same default.
  static FoodSearchRegion? forCountryCode(String? countryCode) {
    return switch (countryCode?.trim().toUpperCase()) {
      'AU' => australia,
      'NZ' => newZealand,
      // `UK` is not an ISO 3166 code, but it does turn up from platforms and
      // from hand-written config, and treating it as a typo would silently
      // demote a British user to "Anywhere".
      'GB' || 'UK' => unitedKingdom,
      'US' => unitedStates,
      'CA' => canada,
      'IE' => ireland,
      _ => null,
    };
  }

  /// Reads a persisted region back, tolerating anything that is not one of
  /// ours.
  ///
  /// Returns `null` for an unknown or absent value so the caller can fall
  /// back to the device default rather than pinning the user to [anywhere]
  /// — which is what a downgrade, or a region removed from this enum, would
  /// otherwise do permanently.
  static FoodSearchRegion? fromStorageValue(String? value) {
    if (value == null) return null;
    for (final region in values) {
      if (region.name == value) return region;
    }
    return null;
  }

  /// The stable string this region persists as. The enum's own `name`, which
  /// makes reordering safe and renaming a migration.
  String get storageValue => name;
}

/// The language Open Food Facts is asked to answer in when this app has no
/// usable one from the device.
const String defaultFoodSearchLanguage = 'en';

/// Normalises a platform language code into what Open Food Facts' `lc`
/// parameter accepts: a bare, lower-case ISO 639 code.
///
/// Anything else — a script or region suffix (`zh_Hant`, `en-AU`), an empty
/// string, the `und` the platform reports when it does not know — becomes
/// [defaultFoodSearchLanguage]. A malformed `lc` is not rejected by the
/// provider; it simply comes back with no localised name, which looks exactly
/// like the bug this whole change is fixing.
String normaliseFoodSearchLanguage(String? languageCode) {
  final raw = languageCode?.trim().toLowerCase() ?? '';
  final bare = raw.split(RegExp('[_-]')).first;
  if (bare.length < 2 || bare.length > 3) return defaultFoodSearchLanguage;
  if (!RegExp(r'^[a-z]+$').hasMatch(bare)) return defaultFoodSearchLanguage;
  if (bare == 'und') return defaultFoodSearchLanguage;
  return bare;
}

/// Everything a food-database request needs to know about *where and in what
/// language* it is being made.
///
/// One value rather than two parameters because the two always travel
/// together and are meaningless apart: a country filter without a language
/// returns records the user cannot read, and a language without a country
/// returns the wrong shelf.
///
/// It is **not** personal data. It says which supermarket's products to
/// return, not who is asking; a whole country and a language shared by
/// hundreds of millions of people identify nobody. It is still disclosed in
/// the online-lookup notice (`presentation/online_lookup_notice_dialog.dart`)
/// because that dialog's promise is to name everything that goes out, and an
/// unmentioned parameter would make the rest of it less believable.
@immutable
class FoodSearchScope {
  const FoodSearchScope({
    required this.region,
    this.languageCode = defaultFoodSearchLanguage,
  });

  /// The scope a request falls back to when nothing has resolved a
  /// preference — the behaviour this feature had before regions existed.
  static const FoodSearchScope anywhereInEnglish = FoodSearchScope(
    region: FoodSearchRegion.anywhere,
  );

  final FoodSearchRegion region;

  /// Already normalised by [normaliseFoodSearchLanguage] at the point the
  /// scope is built, so nothing downstream has to re-check it.
  final String languageCode;

  @override
  bool operator ==(Object other) =>
      other is FoodSearchScope &&
      other.region == region &&
      other.languageCode == languageCode;

  @override
  int get hashCode => Object.hash(region, languageCode);

  @override
  String toString() => 'FoodSearchScope(${region.name}, $languageCode)';
}
