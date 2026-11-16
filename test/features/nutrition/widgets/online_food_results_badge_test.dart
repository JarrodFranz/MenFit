import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/online_food_search_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/online_food_results.dart';

void main() {
  Widget buildTestWidget({required List<ProviderFoodSummary> results}) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: OnlineFoodSection(
            supportsTextSearch: true,
            attributionName: 'FatSecret and Open Food Facts',
            attributionUrl: 'https://menfit.app',
            regionLabel: 'Australia',
            state: OnlineFoodSearchState(
              hasSearched: true,
              results: results,
            ),
            hideCalorieNumbers: false,
            busy: false,
            onSearch: () {},
            onLoadMore: () {},
            onPick: (_) {},
            onChangeRegion: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders FatSecret source badge with icon and label', (
    tester,
  ) async {
    const hit = ProviderFoodSummary(
      source: FoodSource.fatSecret,
      providerFoodId: 'fs-1',
      barcode: 'fs-1',
      name: 'Iced Shaken Espresso',
      brand: 'Starbucks',
      servingDescription: '1 serving',
      servingCaloriesKcal: 160,
      caloriesKcal: 160,
      fatGrams: 2.5,
      carbsGrams: 33,
      proteinGrams: 2,
    );

    await tester.pumpWidget(buildTestWidget(results: [hit]));
    await tester.pumpAndSettle();

    expect(find.text('FatSecret'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    // Verifies macros are rendered without dashes (2.5g rounded to 3g)
    expect(find.textContaining('P 2 g · C 33 g · F 3 g'), findsOneWidget);
  });

  testWidgets('renders Open Food Facts source badge with icon and label', (
    tester,
  ) async {
    const hit = ProviderFoodSummary(
      source: FoodSource.openFoodFacts,
      providerFoodId: 'off-1',
      barcode: 'off-1',
      name: 'Oat Milk',
      brand: 'Oatly',
      servingDescription: '250 ml',
      servingCaloriesKcal: 120,
      caloriesKcal: 48,
      fatGrams: 1.5,
      carbsGrams: 6.5,
      proteinGrams: 1,
    );

    await tester.pumpWidget(buildTestWidget(results: [hit]));
    await tester.pumpAndSettle();

    expect(find.text('Open Food Facts'), findsOneWidget);
    expect(find.byIcon(Icons.public_outlined), findsOneWidget);
  });

  testWidgets(
    'renders serving with grams when serving description is 1 serving',
    (tester) async {
      const hit = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        providerFoodId: 'fs-2',
        barcode: 'fs-2',
        name: 'Cooked Rice',
        brand: 'SunRice',
        servingDescription: '1 serving',
        servingGrams: 250,
        servingCaloriesKcal: 325,
        caloriesKcal: 130,
        fatGrams: 1,
        carbsGrams: 70,
        proteinGrams: 6,
      );

      await tester.pumpWidget(buildTestWidget(results: [hit]));
      await tester.pumpAndSettle();

      expect(
        find.text('Serving: 1 serving (250 g) · 325 kcal'),
        findsOneWidget,
      );
    },
  );
}
