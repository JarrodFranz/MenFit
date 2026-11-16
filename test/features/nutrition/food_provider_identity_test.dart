import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_mapper.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_serving_units.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';

void main() {
  test(
    'saved provider identity is source-scoped, retained for edits',
    () async {
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftNutritionRepository(database);
      final now = DateTime.utc(2026, 11, 16);
      final food = Food(
        id: 'saved',
        name: 'Saved oats',
        servingDescription: '1 bowl',
        perServing: const NutritionFacts(caloriesKcal: 200),
        createdAt: now,
        updatedAt: now,
        source: FoodSource.fatSecret,
        providerFoodId: '27365861',
      );
      await repository.saveFood(food);
      final saved = await repository.getFoodByProviderId(
        FoodSource.fatSecret,
        '27365861',
      );
      expect(saved?.id, food.id);
      expect(saved?.providerFoodId, food.providerFoodId);
      expect(saved?.perServing, food.perServing);
      expect(await repository.getFoodByBarcode('27365861'), isNull);
      expect(
        await repository.getFoodByProviderId(
          FoodSource.openFoodFacts,
          '27365861',
        ),
        isNull,
      );
      expect(FoodFormSeed.forEditing(saved!).providerFoodId, '27365861');
      expect(FoodFormSeed.forEditing(saved).barcode, isEmpty);
    },
  );

  test('structured search and detail use the same stated serving', () {
    final record = <String, dynamic>{
      'food_id': '27365861',
      'food_name': 'Oats',
      'servings': {
        'serving': [
          {
            'serving_id': '0',
            'serving_description': '100 g',
            'metric_serving_amount': '100',
            'metric_serving_unit': 'g',
            'calories': '400',
          },
          {
            'serving_id': '22',
            'serving_description': '1 bowl',
            'metric_serving_amount': '40',
            'metric_serving_unit': 'g',
            'calories': '160',
            'protein': '5',
            'carbohydrate': '25',
            'fat': '4',
          },
        ],
      },
    };
    const mapper = FatSecretMapper();
    final summary = mapper.parseSearchHits({
      'foods_search': {
        'results': {'food': record},
      },
    }).single;
    final detail = mapper.parseFoodDetail({'food': record})!;
    expect(summary.providerFoodId, '27365861');
    expect(summary.barcode, isNull);
    expect(detail.barcode, isNull);
    expect(detail.providerFoodId, summary.providerFoodId);
    expect(summary.servingCaloriesKcal, detail.caloriesKcal);
    expect(summary.servingGrams, 40);
    expect(summary.macroBasis, SummaryMacroBasis.per100g);
    expect(summary.caloriesKcal, 400);
    expect(FoodFormSeed.fromProviderFood(detail).barcode, isEmpty);
  });

  test('mass ounces never imply fluid volume even for drinks', () {
    final mass = measureFatSecretServing(
      metricAmount: 8,
      metricUnit: 'oz',
    );
    expect(mass.grams, closeTo(226.796185, 0.000001));
    expect(mass.volumeMl, isNull);
    final volume = measureFatSecretServing(
      metricAmount: 8,
      metricUnit: 'fl oz',
    );
    expect(volume.grams, isNull);
    expect(volume.volumeMl, closeTo(236.5882365, 0.000001));
  });
}
