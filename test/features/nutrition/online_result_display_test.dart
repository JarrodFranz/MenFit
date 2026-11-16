import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/online_result_display.dart';

void main() {
  ProviderFoodSummary summary({
    String name = 'Iced Shaken Espresso (Venti)',
    String? brand = 'Starbucks',
    String? servingDescription,
    double? servingGrams,
    double? servingVolumeMl,
    double? servingCaloriesKcal,
    double? caloriesKcal,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    SummaryMacroBasis macroBasis = SummaryMacroBasis.per100g,
  }) {
    return ProviderFoodSummary(
      source: FoodSource.fatSecret,
      providerFoodId: 'fs-1',
      name: name,
      brand: brand,
      servingDescription: servingDescription,
      servingGrams: servingGrams,
      servingVolumeMl: servingVolumeMl,
      servingCaloriesKcal: servingCaloriesKcal,
      caloriesKcal: caloriesKcal,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      macroBasis: macroBasis,
    );
  }

  group('resolveOnlineResultDisplay', () {
    test('scales per-100 g figures to a known serving weight', () {
      // The enriched Venti: 680 g / 710 ml, and per-100 g numbers computed
      // from the product's 160 kcal · P 6 · C 25 · F 3.
      final display = resolveOnlineResultDisplay(
        summary(
          servingDescription: '1 serving',
          servingGrams: 680.39,
          servingVolumeMl: 709.76,
          servingCaloriesKcal: 160,
          caloriesKcal: 23.52,
          proteinGrams: 0.88,
          carbsGrams: 3.67,
          fatGrams: 0.44,
        ),
        hideCalorieNumbers: false,
      );

      // Volume wins over mass in the description: it is what the cup says.
      expect(
        display.basisLine,
        equals('Serving: 1 serving (710 ml) · 160 kcal'),
      );
      expect(display.proteinGrams, closeTo(6, 0.05));
      expect(display.carbsGrams, closeTo(25, 0.05));
      expect(display.fatGrams, closeTo(3, 0.05));
      expect(display.macroLine, equals('P 6 g · C 25 g · F 3 g'));
    });

    test('scales per-100 ml figures by the serving volume', () {
      final display = resolveOnlineResultDisplay(
        summary(
          name: 'Coca-Cola Classic',
          brand: 'Coca-Cola',
          servingDescription: '8 fl oz (240 ml)',
          servingVolumeMl: 240,
          servingCaloriesKcal: 100,
          caloriesKcal: 41.67,
          proteinGrams: 0,
          carbsGrams: 10.83,
          fatGrams: 0,
          macroBasis: SummaryMacroBasis.per100ml,
        ),
        hideCalorieNumbers: false,
      );

      expect(
        display.basisLine,
        equals('Serving: 8 fl oz (240 ml) · 100 kcal'),
      );
      expect(display.carbsGrams, closeTo(26, 0.05));
    });

    test('leaves per-serving figures alone', () {
      // A "Per 1 serving" hit that enrichment could not resolve: nothing to
      // scale by, and scaling anyway is the bug this basis exists to stop.
      final display = resolveOnlineResultDisplay(
        summary(
          servingDescription: '1 serving',
          servingCaloriesKcal: 160,
          caloriesKcal: 160,
          proteinGrams: 6,
          carbsGrams: 25,
          fatGrams: 3,
          macroBasis: SummaryMacroBasis.perServing,
        ),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Serving: 1 serving · 160 kcal'));
      expect(display.macroLine, equals('P 6 g · C 25 g · F 3 g'));
    });

    test('names a serving rather than claiming per 100 g when the serving is '
        'unnamed', () {
      // A "Per 1 serving" hit that stated no portion text at all. The
      // figures are per serving and undivided; calling the line "Per 100 g"
      // would be out by servingGrams / 100 with nothing on screen to show
      // it — the exact mislabel SummaryMacroBasis exists to prevent.
      final display = resolveOnlineResultDisplay(
        summary(
          name: 'Trail Mix',
          brand: null,
          caloriesKcal: 90,
          proteinGrams: 5,
          carbsGrams: 10,
          fatGrams: 2,
          macroBasis: SummaryMacroBasis.perServing,
        ),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Serving: 1 serving · 90 kcal'));
      expect(display.macroLine, equals('P 5 g · C 10 g · F 2 g'));

      final hidden = resolveOnlineResultDisplay(
        summary(
          name: 'Trail Mix',
          brand: null,
          caloriesKcal: 90,
          macroBasis: SummaryMacroBasis.perServing,
        ),
        hideCalorieNumbers: true,
      );
      expect(hidden.basisLine, equals('Serving: 1 serving'));
    });

    test('says "per 100 ml" for a per-serving basis whose serving is the '
        '100 ml portion', () {
      // The one description that earns a per-100 line on this basis: the
      // serving *is* 100 ml, so per serving and per 100 ml are the same
      // numbers.
      final display = resolveOnlineResultDisplay(
        summary(
          name: 'Sparkling Water',
          brand: null,
          servingDescription: '100 ml',
          servingVolumeMl: 100,
          servingCaloriesKcal: 42,
          caloriesKcal: 42,
          proteinGrams: 0,
          carbsGrams: 10.6,
          fatGrams: 0.1,
          macroBasis: SummaryMacroBasis.perServing,
        ),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Per 100 ml · 42 kcal'));
      expect(display.carbsGrams, closeTo(10.6, 0.001));
    });

    test('says "per 100 g" when there is no serving size to scale to', () {
      final display = resolveOnlineResultDisplay(
        summary(
          name: 'Rolled Oats',
          brand: 'Quaker',
          servingDescription: '100 g',
          servingGrams: 100,
          caloriesKcal: 389,
          proteinGrams: 16.9,
          carbsGrams: 66.3,
          fatGrams: 6.9,
        ),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Per 100 g · 389 kcal'));
      expect(display.macroLine, equals('P 17 g · C 66 g · F 7 g'));
    });

    test('keeps the named serving in view when it cannot be scaled', () {
      final display = resolveOnlineResultDisplay(
        summary(
          name: 'Oat Milk',
          brand: 'Oatly',
          servingDescription: '250 ml',
          caloriesKcal: 48,
          proteinGrams: 1,
          carbsGrams: 6.5,
          fatGrams: 1.5,
        ),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Per 100 g · 48 kcal (250 ml)'));
      expect(display.proteinGrams, equals(1));
    });

    test('treats "100 ml" as a per-100 basis line', () {
      final display = resolveOnlineResultDisplay(
        summary(
          name: 'Lemonade',
          brand: null,
          servingDescription: '100 ml',
          servingVolumeMl: 100,
          caloriesKcal: 42,
          proteinGrams: 0,
          carbsGrams: 10.6,
          fatGrams: 0.1,
          macroBasis: SummaryMacroBasis.per100ml,
        ),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Per 100 ml · 42 kcal'));
    });

    test('never prints an energy figure when calories are hidden', () {
      final hidden = resolveOnlineResultDisplay(
        summary(
          servingDescription: '1 serving',
          servingVolumeMl: 709.76,
          servingCaloriesKcal: 160,
          caloriesKcal: 160,
          macroBasis: SummaryMacroBasis.perServing,
        ),
        hideCalorieNumbers: true,
      );
      expect(hidden.basisLine, equals('Serving: 1 serving (710 ml)'));

      final hiddenPer100 = resolveOnlineResultDisplay(
        summary(servingDescription: '100 g', caloriesKcal: 389),
        hideCalorieNumbers: true,
      );
      expect(hiddenPer100.basisLine, equals('Per 100 g'));
    });

    test('shows an unstated figure as a dash, never a zero', () {
      final display = resolveOnlineResultDisplay(
        summary(servingDescription: '100 g', servingGrams: 100),
        hideCalorieNumbers: false,
      );

      expect(display.basisLine, equals('Per 100 g · —'));
      expect(display.macroLine, equals('P — · C — · F —'));
    });
  });
}
