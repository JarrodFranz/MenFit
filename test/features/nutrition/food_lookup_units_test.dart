import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/data/online_lookup_notice_store.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What Open Food Facts echoes for the UPC-A `016000275270` printed on a US
/// packet — the twelve digits padded to the thirteen-digit GTIN (measured
/// 2026-08-27, see `domain/barcode.dart`).
const String _echoedUpcA = '0016000275270';

ProviderFood _product({
  String barcode = _echoedUpcA,
  double? caloriesKcal = 372,
  double? proteinGrams,
  double? carbsGrams,
  double? fatGrams,
  double? ironMg,
  FoodSource source = FoodSource.openFoodFacts,
}) {
  return ProviderFood(
    source: source,
    barcode: barcode,
    name: 'Porridge oats',
    servingDescription: '40 g',
    servingBasis: ServingBasis.derivedFromPer100g,
    brand: 'Quaker',
    servingGrams: 40,
    caloriesKcal: caloriesKcal,
    proteinGrams: proteinGrams,
    carbsGrams: carbsGrams,
    fatGrams: fatGrams,
    ironMg: ironMg,
    completeness: 0.4,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatNutritionField', () {
    test('an unstated number is BLANK, never zero', () {
      // The distinction the whole review-before-save flow rests on: a gap
      // in someone else's database must not become a claim about the food.
      expect(formatNutritionField(null), '');
      expect(formatNutritionField(0), '0');
      expect(formatNutritionField(double.nan), '');
    });

    test('whole numbers carry no decimal point', () {
      expect(formatNutritionField(372), '372');
      expect(formatNutritionField(100), '100');
    });

    test('fractions keep at most two places, trailing zeros trimmed', () {
      expect(formatNutritionField(11.6), '11.6');
      expect(formatNutritionField(8.499999), '8.5');
      expect(formatNutritionField(104.16), '104.16');
    });

    test('a tiny nonzero value never seeds a field reading zero', () {
      // The mirror image of the blank-for-null rule above: `0` here would be
      // the user saving a claim that the food contains none of something the
      // database says it contains a little of.
      expect(formatNutritionField(0.001), '0.001');
      // Either side of the two-decimal-places boundary.
      expect(formatNutritionField(0.0049), '0.0049');
      expect(formatNutritionField(0.005), '0.01');
      expect(formatNutritionField(0.00001), '0.00001');
      // Small enough to need exponent form, and still not a zero.
      expect(formatNutritionField(0.0000001), '1.0e-7');
      // Whatever the shape, what comes back out is the value that went in.
      for (final value in [0.001, 0.0049, 0.00001, 0.0000001, 1e-12]) {
        expect(
          double.parse(formatNutritionField(value)),
          isNot(0),
          reason: '$value must not render as zero',
        );
      }
      // A real zero is still a real zero.
      expect(formatNutritionField(0), '0');
    });
  });

  group('per-100 g formatting', () {
    test('an unstated macro reads as a dash, not as 0 g', () {
      expect(
        formatPer100gMacroLine(proteinGrams: 11.6, carbsGrams: 60),
        'P 12 g · C 60 g · F —',
      );
      expect(formatOptionalKcal(null), '—');
      expect(formatOptionalKcal(372), '372 kcal');
    });
  });

  group('FoodFormSeed', () {
    test('seeds blanks for every number the provider did not state', () {
      final seed = FoodFormSeed.fromProviderFood(_product());

      expect(seed.calories, '372');
      expect(seed.protein, '');
      expect(seed.carbs, '');
      expect(seed.fat, '');
      expect(seed.iron, '');
      expect(seed.hasCompleteMacros, isFalse);
    });

    test("carries the provider's echoed barcode, not anything else", () {
      // Providers normalise codes server-side and the saved food has to key
      // on what comes back: what is printed on the packet is
      // `016000275270`, what is stored is the padded thirteen.
      final seed = FoodFormSeed.fromProviderFood(_product());
      expect(seed.barcode, _echoedUpcA);
      expect(seed.barcode, isNot('016000275270'));
      expect(seed.servingBasis, ServingBasis.derivedFromPer100g);
      expect(seed.foundInDatabase, isTrue);
    });

    test(
      "the seed's source is always the RESULT's own source, never a "
      'caller-supplied default',
      () {
        // With a fallback provider live (ADR 016) a single build can answer
        // with either catalogue, so `fromProviderFood` must read `source`
        // off the `ProviderFood` itself rather than defaulting to
        // `openFoodFacts` — a caller-supplied default would mislabel every
        // FatSecret-served result under a build where FatSecret is primary.
        final seed = FoodFormSeed.fromProviderFood(
          _product(source: FoodSource.fatSecret),
        );
        expect(seed.source, FoodSource.fatSecret);
      },
    );

    test('an unknown barcode seeds the code and nothing else', () {
      final seed = FoodFormSeed.forUnknownBarcode('5000112637922');

      expect(seed.barcode, '5000112637922');
      expect(seed.name, isEmpty);
      expect(seed.calories, isEmpty);
      expect(seed.servingBasis, isNull);
      expect(seed.foundInDatabase, isFalse);
    });

    test('is equal by value, so the controller family keys on the food and '
        'not on the scan', () {
      // Freezed equality is what stops a second scan of the same product
      // creating a second controller instance.
      expect(
        FoodFormSeed.fromProviderFood(_product()),
        FoodFormSeed.fromProviderFood(_product()),
      );
      expect(
        FoodFormSeed.forUnknownBarcode('5000112637922'),
        isNot(FoodFormSeed.forUnknownBarcode('96385074')),
      );
    });
  });

  group('grantOnlineLookupConsent', () {
    Future<OnlineLookupNoticeStore> store([
      Map<String, Object> initial = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(initial);
      return OnlineLookupNoticeStore(await SharedPreferences.getInstance());
    }

    test(
      'asks on the first run, and records the answer once accepted',
      () async {
        final subject = await store();
        var asked = 0;

        expect(
          await grantOnlineLookupConsent(subject, () async {
            asked++;
            return true;
          }),
          isTrue,
        );
        expect(asked, 1);
        expect(subject.hasSeenNotice(), isTrue);

        // Second time it neither asks nor blocks.
        expect(
          await grantOnlineLookupConsent(subject, () async {
            asked++;
            return true;
          }),
          isTrue,
        );
        expect(asked, 1);
      },
    );

    test('declining returns false and leaves nothing recorded, so the '
        'explanation is offered again', () async {
      final subject = await store();

      expect(
        await grantOnlineLookupConsent(subject, () async => false),
        isFalse,
      );
      expect(subject.hasSeenNotice(), isFalse);
    });

    test('an already-acknowledged notice is never shown again', () async {
      final subject = await store({
        'nutrition_online_lookup_notice_seen': true,
      });
      var asked = 0;

      expect(
        await grantOnlineLookupConsent(subject, () async {
          asked++;
          return true;
        }),
        isTrue,
      );
      expect(asked, 0);
    });
  });
}
