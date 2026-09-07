import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/domain/fallback_food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

/// A [FoodDataProvider] test double whose every outcome is configured by the
/// test: a fixed [ProviderFood]/list of hits to return, or an [Object] to
/// throw instead. Records every call it receives so a test can assert on
/// exactly what reached it — including the page arguments a fallback search
/// is called with.
class _FakeProvider implements FoodDataProvider {
  _FakeProvider(
    this.name, {
    this.foodSource = FoodSource.openFoodFacts,
    this.supportsTextSearch = true,
  });

  final String name;

  @override
  final FoodSource foodSource;

  @override
  final bool supportsTextSearch;

  @override
  String get attributionName => name;

  @override
  String get attributionUrl => 'https://$name.example';

  @override
  Uri productPageUrl(String barcode) =>
      Uri.parse('https://$name.example/$barcode');

  @override
  FoodDataProvider providerFor(FoodSource source) => this;

  ProviderFood? barcodeResult;
  Object? barcodeError;
  final List<String> barcodeCalls = [];

  List<ProviderFoodSummary> searchResult = const [];
  Object? searchError;
  final List<({String query, int page, int pageSize})> searchCalls = [];

  @override
  Future<ProviderFood?> findByBarcode(
    String barcode, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    barcodeCalls.add(barcode);
    final error = barcodeError;
    // Deliberately rethrown as-is: every value assigned to [barcodeError]
    // in this file is an `AppException`, but the field is typed `Object?`
    // so a test can also exercise an unexpected throw if it ever needs to.
    // ignore: only_throw_errors
    if (error != null) throw error;
    return barcodeResult;
  }

  @override
  Future<List<ProviderFoodSummary>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    searchCalls.add((query: query, page: page, pageSize: pageSize));
    final error = searchError;
    // Same reasoning as [findByBarcode]'s ignore above.
    // ignore: only_throw_errors
    if (error != null) throw error;
    return searchResult;
  }
}

void main() {
  late _FakeProvider primary;
  late _FakeProvider fallback;
  late FallbackFoodDataProvider provider;

  const providerFood = ProviderFood(
    source: FoodSource.fatSecret,
    barcode: '111',
    name: 'Oats',
    servingDescription: '40 g',
    servingBasis: ServingBasis.per100g,
  );

  const fallbackFood = ProviderFood(
    source: FoodSource.openFoodFacts,
    barcode: '111',
    name: 'Oats (OFF)',
    servingDescription: '40 g',
    servingBasis: ServingBasis.per100g,
  );

  setUp(() {
    primary = _FakeProvider('FatSecret', foodSource: FoodSource.fatSecret);
    fallback = _FakeProvider('Open Food Facts');
    provider = FallbackFoodDataProvider(primary: primary, fallback: fallback);
  });

  group('foodSource, attribution and providerFor', () {
    test("foodSource is the primary's", () {
      expect(provider.foodSource, FoodSource.fatSecret);
    });

    test('attributionName names both sources', () {
      expect(provider.attributionName, 'FatSecret and Open Food Facts');
    });

    test("attributionUrl and productPageUrl are the primary's", () {
      expect(provider.attributionUrl, primary.attributionUrl);
      expect(
        provider.productPageUrl('111'),
        primary.productPageUrl('111'),
      );
    });

    test('providerFor resolves to whichever source produced the result', () {
      expect(provider.providerFor(FoodSource.fatSecret), same(primary));
      expect(provider.providerFor(FoodSource.openFoodFacts), same(fallback));
      // A source neither of them produces defaults to the primary.
      expect(provider.providerFor(FoodSource.custom), same(primary));
    });

    test('supportsTextSearch is true if either provider supports it', () {
      expect(provider.supportsTextSearch, isTrue);

      final noSearchPrimary = _FakeProvider('P', supportsTextSearch: false);
      final searchableFallback = _FakeProvider('F');
      expect(
        FallbackFoodDataProvider(
          primary: noSearchPrimary,
          fallback: searchableFallback,
        ).supportsTextSearch,
        isTrue,
      );
      expect(
        FallbackFoodDataProvider(
          primary: noSearchPrimary,
          fallback: _FakeProvider('F', supportsTextSearch: false),
        ).supportsTextSearch,
        isFalse,
      );
    });
  });

  group('findByBarcode', () {
    test(
      'a primary hit is returned, and the fallback is never called',
      () async {
        primary.barcodeResult = providerFood;

        final result = await provider.findByBarcode('111');

        expect(result, same(providerFood));
        expect(result!.source, FoodSource.fatSecret);
        expect(fallback.barcodeCalls, isEmpty);
      },
    );

    test(
      'a primary null falls back, and the fallback hit is returned',
      () async {
        primary.barcodeResult = null;
        fallback.barcodeResult = fallbackFood;

        final result = await provider.findByBarcode('111');

        expect(result, same(fallbackFood));
        expect(result!.source, FoodSource.openFoodFacts);
        expect(primary.barcodeCalls, ['111']);
        expect(fallback.barcodeCalls, ['111']);
      },
    );

    test(
      'a primary NetworkException falls back, and the fallback hit is '
      'returned',
      () async {
        primary.barcodeError = const NetworkException(message: 'down');
        fallback.barcodeResult = fallbackFood;

        final result = await provider.findByBarcode('111');

        expect(result, same(fallbackFood));
      },
    );

    test(
      "both providers throwing NetworkException rethrows the PRIMARY's",
      () async {
        const primaryFailure = NetworkException(message: 'primary down');
        primary.barcodeError = primaryFailure;
        fallback.barcodeError = const NetworkException(message: 'backup down');

        await expectLater(
          provider.findByBarcode('111'),
          throwsA(same(primaryFailure)),
        );
      },
    );

    test(
      'a primary null plus a fallback NetworkException returns null — the '
      'primary already answered authoritatively',
      () async {
        primary.barcodeResult = null;
        fallback.barcodeError = const NetworkException(message: 'down');

        final result = await provider.findByBarcode('111');

        expect(result, isNull);
      },
    );

    test(
      'a ValidationException from the primary propagates without ever '
      'calling the fallback',
      () async {
        const failure = ValidationException(message: 'bad barcode');
        primary.barcodeError = failure;

        await expectLater(
          provider.findByBarcode('111'),
          throwsA(same(failure)),
        );
        expect(fallback.barcodeCalls, isEmpty);
      },
    );
  });

  group('search', () {
    test(
      'a primary result is returned, and the fallback is never called',
      () async {
        primary.searchResult = [
          const ProviderFoodSummary(
            source: FoodSource.fatSecret,
            barcode: '1',
            name: 'A',
          ),
        ];

        final result = await provider.search('oats', page: 2, pageSize: 10);

        expect(result, same(primary.searchResult));
        expect(fallback.searchCalls, isEmpty);
      },
    );

    test(
      'a primary NetworkException falls back with the SAME page arguments',
      () async {
        primary.searchError = const NetworkException(message: 'down');
        fallback.searchResult = [
          const ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            barcode: '2',
            name: 'B',
          ),
        ];

        final result = await provider.search('oats', page: 3, pageSize: 15);

        expect(result, same(fallback.searchResult));
        expect(fallback.searchCalls, [
          (query: 'oats', page: 3, pageSize: 15),
        ]);
      },
    );

    test(
      "both providers throwing NetworkException rethrows the PRIMARY's",
      () async {
        const primaryFailure = NetworkException(message: 'primary down');
        primary.searchError = primaryFailure;
        fallback.searchError = const NetworkException(message: 'backup down');

        await expectLater(
          provider.search('oats'),
          throwsA(same(primaryFailure)),
        );
      },
    );

    test('a primary that does not support text search goes straight to the '
        'fallback', () async {
      final unsupportedPrimary = _FakeProvider(
        'P',
        supportsTextSearch: false,
      );
      final searchableFallback = _FakeProvider('F')
        ..searchResult = [
          const ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            barcode: '3',
            name: 'C',
          ),
        ];
      final composite = FallbackFoodDataProvider(
        primary: unsupportedPrimary,
        fallback: searchableFallback,
      );

      final result = await composite.search('oats');

      expect(result, same(searchableFallback.searchResult));
      expect(unsupportedPrimary.searchCalls, isEmpty);
    });

    test(
      'an EMPTY primary result does NOT fall back — pages must come from '
      'one catalogue',
      () async {
        primary.searchResult = const [];

        final result = await provider.search('oats');

        expect(result, isEmpty);
        expect(fallback.searchCalls, isEmpty);
      },
    );

    test(
      'a ValidationException from the primary propagates without ever '
      'calling the fallback',
      () async {
        const failure = ValidationException(message: 'bad query');
        primary.searchError = failure;

        await expectLater(provider.search('oats'), throwsA(same(failure)));
        expect(fallback.searchCalls, isEmpty);
      },
    );
  });
}
