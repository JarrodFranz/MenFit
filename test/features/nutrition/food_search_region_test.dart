import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/device_locale.dart';
import 'package:menfit_app/features/nutrition/data/food_search_region_store.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The region/language preference behind the 2026-09-03 fix: a search from
/// Australia was returning Bulgarian products, because Open Food Facts is
/// global and unlocalised unless the request says otherwise.
///
/// The default matters more than the setting does. Nobody would have gone
/// looking for a "food database region" control they did not know existed,
/// and the symptom ("why is this in Cyrillic?") does not point at one — so
/// the fix has to be right for a user who never opens Settings.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> preferences([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  /// [locale] is required rather than defaulted: every test here turns on
  /// which device it is pretending to be, and a hidden default would make
  /// half of them read as if it did not matter.
  ProviderContainer containerWith({
    required SharedPreferences prefs,
    required DeviceLocale locale,
  }) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceLocaleProvider.overrideWithValue(locale),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('FoodSearchRegion.forCountryCode', () {
    test('maps the countries this app covers', () {
      expect(FoodSearchRegion.forCountryCode('AU'), FoodSearchRegion.australia);
      expect(
        FoodSearchRegion.forCountryCode('NZ'),
        FoodSearchRegion.newZealand,
      );
      expect(
        FoodSearchRegion.forCountryCode('GB'),
        FoodSearchRegion.unitedKingdom,
      );
      expect(
        FoodSearchRegion.forCountryCode('US'),
        FoodSearchRegion.unitedStates,
      );
      expect(FoodSearchRegion.forCountryCode('CA'), FoodSearchRegion.canada);
      expect(FoodSearchRegion.forCountryCode('IE'), FoodSearchRegion.ireland);
    });

    test('is case-insensitive and tolerates the non-ISO "UK"', () {
      expect(
        FoodSearchRegion.forCountryCode('au'),
        FoodSearchRegion.australia,
      );
      // Not an ISO 3166 code, but it turns up from platforms and from
      // hand-written config; treating it as a typo would quietly demote a
      // British user to "Anywhere".
      expect(
        FoodSearchRegion.forCountryCode('UK'),
        FoodSearchRegion.unitedKingdom,
      );
    });

    test('a country we do not cover, and no country at all, are null', () {
      // `null` rather than `anywhere` so the caller can tell "covered" from
      // "falling back", even though both currently end up searching
      // everywhere.
      expect(FoodSearchRegion.forCountryCode('BG'), isNull);
      expect(FoodSearchRegion.forCountryCode(null), isNull);
      expect(FoodSearchRegion.forCountryCode(''), isNull);
    });

    test('only "Anywhere" leaves the country filter off', () {
      for (final region in FoodSearchRegion.values) {
        expect(
          region.filtersByCountry,
          region != FoodSearchRegion.anywhere,
          reason: region.name,
        );
      }
    });
  });

  group('normaliseFoodSearchLanguage', () {
    test('passes a bare language through, lower-cased', () {
      expect(normaliseFoodSearchLanguage('en'), 'en');
      expect(normaliseFoodSearchLanguage('DE'), 'de');
      expect(normaliseFoodSearchLanguage('bg'), 'bg');
    });

    test('strips script and region suffixes', () {
      // `lc` wants a bare code; `zh_Hant` comes back with no localised name
      // at all, which looks exactly like the bug being fixed.
      expect(normaliseFoodSearchLanguage('en_AU'), 'en');
      expect(normaliseFoodSearchLanguage('zh-Hant'), 'zh');
    });

    test('anything unusable becomes English rather than being sent', () {
      expect(normaliseFoodSearchLanguage(null), 'en');
      expect(normaliseFoodSearchLanguage(''), 'en');
      expect(normaliseFoodSearchLanguage('  '), 'en');
      expect(normaliseFoodSearchLanguage('und'), 'en');
      expect(normaliseFoodSearchLanguage('e'), 'en');
      expect(normaliseFoodSearchLanguage('english'), 'en');
      expect(normaliseFoodSearchLanguage('e2'), 'en');
    });
  });

  group('FoodSearchRegionStore', () {
    test('round-trips a choice', () async {
      final store = FoodSearchRegionStore(await preferences());

      expect(store.readRegion(), isNull);
      await store.setRegion(FoodSearchRegion.newZealand);

      expect(store.readRegion(), FoodSearchRegion.newZealand);
    });

    test('"Anywhere" is a real stored choice, not an absent one', () async {
      final store = FoodSearchRegionStore(await preferences());
      await store.setRegion(FoodSearchRegion.anywhere);

      expect(store.readRegion(), FoodSearchRegion.anywhere);
    });

    test('a value this build does not know is read as no choice', () async {
      // A downgrade, or a region dropped from the enum. Falling back to the
      // device default beats pinning the user to "Anywhere" for good.
      final store = FoodSearchRegionStore(
        await preferences({'nutrition_food_search_region': 'atlantis'}),
      );

      expect(store.readRegion(), isNull);
    });
  });

  group('foodSearchRegionControllerProvider', () {
    test('defaults to the device country when this app covers it', () async {
      final container = containerWith(
        prefs: await preferences(),
        locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
      );

      expect(
        container.read(foodSearchRegionControllerProvider),
        FoodSearchRegion.australia,
      );
    });

    test(
      'defaults to Anywhere for a country this app does not cover',
      () async {
        final container = containerWith(
          prefs: await preferences(),
          locale: const DeviceLocale(languageCode: 'bg', countryCode: 'BG'),
        );

        expect(
          container.read(foodSearchRegionControllerProvider),
          FoodSearchRegion.anywhere,
        );
      },
    );

    test('defaults to Anywhere when the platform reports no country', () async {
      final container = containerWith(
        prefs: await preferences(),
        locale: const DeviceLocale(languageCode: 'en'),
      );

      expect(
        container.read(foodSearchRegionControllerProvider),
        FoodSearchRegion.anywhere,
      );
    });

    test('a stored choice beats the device, including a choice of '
        'Anywhere', () async {
      final container = containerWith(
        prefs: await preferences({
          'nutrition_food_search_region': 'anywhere',
        }),
        locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
      );

      // They deliberately widened it; the device must not keep narrowing it
      // back on every launch.
      expect(
        container.read(foodSearchRegionControllerProvider),
        FoodSearchRegion.anywhere,
      );
    });

    test('setRegion shows and persists the new value', () async {
      final prefs = await preferences();
      final container = containerWith(
        prefs: prefs,
        locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
      );

      await container
          .read(foodSearchRegionControllerProvider.notifier)
          .setRegion(FoodSearchRegion.ireland);

      expect(
        container.read(foodSearchRegionControllerProvider),
        FoodSearchRegion.ireland,
      );
      expect(
        prefs.getString('nutrition_food_search_region'),
        'ireland',
        reason: 'the enum name is the stored value',
      );

      // And a fresh container reads it back, which is the half that proves
      // it survives a restart rather than only a rebuild.
      final restarted = containerWith(
        prefs: prefs,
        locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
      );
      expect(
        restarted.read(foodSearchRegionControllerProvider),
        FoodSearchRegion.ireland,
      );
    });
  });

  group('foodSearchScopeProvider', () {
    test('combines the chosen region with the device language', () async {
      final container = containerWith(
        prefs: await preferences({
          'nutrition_food_search_region': 'unitedKingdom',
        }),
        locale: const DeviceLocale(languageCode: 'de', countryCode: 'AT'),
      );

      // The two are genuinely independent: a German speaker shopping in
      // Britain wants British products with German names where records
      // have them.
      expect(
        container.read(foodSearchScopeProvider),
        const FoodSearchScope(
          region: FoodSearchRegion.unitedKingdom,
          languageCode: 'de',
        ),
      );
    });

    test('normalises the platform language before it can reach the '
        'wire', () async {
      final container = containerWith(
        prefs: await preferences(),
        locale: const DeviceLocale(languageCode: 'en_AU', countryCode: 'AU'),
      );

      expect(container.read(foodSearchScopeProvider).languageCode, 'en');
    });

    test('follows a region change', () async {
      final container = containerWith(
        prefs: await preferences(),
        locale: const DeviceLocale(languageCode: 'en', countryCode: 'AU'),
      );
      expect(
        container.read(foodSearchScopeProvider).region,
        FoodSearchRegion.australia,
      );

      await container
          .read(foodSearchRegionControllerProvider.notifier)
          .setRegion(FoodSearchRegion.anywhere);

      expect(
        container.read(foodSearchScopeProvider).region,
        FoodSearchRegion.anywhere,
      );
    });

    test('the default scope constant is the pre-region behaviour', () {
      expect(
        FoodSearchScope.anywhereInEnglish.region,
        FoodSearchRegion.anywhere,
      );
      expect(FoodSearchScope.anywhereInEnglish.languageCode, 'en');
    });
  });
}
