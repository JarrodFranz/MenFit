import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/device_locale.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/settings/presentation/widgets/food_search_region_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Settings row that owns the food-database region (2026-09-03).
///
/// Pumped on its own rather than through `SettingsScreen`, which needs a
/// dozen repositories it has nothing to do with. What matters here is the
/// three-part contract: it shows the region actually in force (including the
/// one inferred from the device that the user never chose), a change
/// persists, and a change is visible immediately.
void main() {
  Future<SharedPreferences> preferences([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  Future<void> pumpTile(
    WidgetTester tester, {
    required SharedPreferences prefs,
    DeviceLocale locale = const DeviceLocale(
      languageCode: 'en',
      countryCode: 'AU',
    ),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          deviceLocaleProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: FoodSearchRegionTile()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the region inferred from the device before the user '
      'has chosen one', (tester) async {
    await pumpTile(tester, prefs: await preferences());

    expect(find.text('Food database region'), findsOneWidget);
    // The default is the whole fix for someone who never opens Settings, so
    // it has to be visible here rather than implied by a blank control.
    expect(find.text('Australia'), findsOneWidget);
  });

  testWidgets('offers Anywhere plus the covered countries, and nothing '
      'else', (tester) async {
    await pumpTile(tester, prefs: await preferences());

    await tester.tap(find.byKey(const Key('foodSearchRegionDropdown')));
    await tester.pumpAndSettle();

    for (final region in FoodSearchRegion.values) {
      expect(find.text(region.label), findsWidgets, reason: region.label);
    }
    // Not a 200-entry list of every country Open Food Facts knows: an empty
    // result from a market with a dozen products reads as the user's
    // mistake (`domain/food_search_region.dart`).
    expect(FoodSearchRegion.values, hasLength(7));
  });

  testWidgets('choosing a region persists it and shows it at once', (
    tester,
  ) async {
    final prefs = await preferences();
    await pumpTile(tester, prefs: prefs);

    await tester.tap(find.byKey(const Key('foodSearchRegionDropdown')));
    await tester.pumpAndSettle();
    // `.last` because the closed button also renders the selected label;
    // the menu entry is the one built second.
    await tester.tap(find.text('New Zealand').last);
    await tester.pumpAndSettle();

    expect(prefs.getString('nutrition_food_search_region'), 'newZealand');
    expect(find.text('New Zealand'), findsOneWidget);
  });

  testWidgets('choosing Anywhere is a real choice that sticks', (tester) async {
    // The one selection that looks like "no preference" but must be stored,
    // or the device default would narrow it back on the next launch.
    final prefs = await preferences();
    await pumpTile(tester, prefs: prefs);

    await tester.tap(find.byKey(const Key('foodSearchRegionDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anywhere').last);
    await tester.pumpAndSettle();

    expect(prefs.getString('nutrition_food_search_region'), 'anywhere');
  });

  testWidgets('a stored choice is what the row shows, not the device', (
    tester,
  ) async {
    await pumpTile(
      tester,
      prefs: await preferences({
        'nutrition_food_search_region': 'unitedKingdom',
      }),
    );

    expect(find.text('United Kingdom'), findsOneWidget);
    expect(find.text('Australia'), findsNothing);
  });
}
