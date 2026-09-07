import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';

void main() {
  group('FoodSource storage keys', () {
    // Storage keys are a persistence contract: rows written by earlier
    // versions must keep reading back as the same value, and a future sync
    // backend (ADR 004) relies on this marker to tell ODbL-licensed
    // provider rows from user-authored ones. Renaming a key silently
    // reclassifies every existing row.
    test('every value round-trips through storage', () {
      for (final source in FoodSource.values) {
        expect(
          FoodSource.fromStorage(source.toStorage()),
          source,
          reason: '${source.name} must survive a write/read cycle',
        );
      }
    });

    test('the keys are the exact persisted strings', () {
      expect(FoodSource.custom.toStorage(), 'custom');
      expect(FoodSource.provider.toStorage(), 'provider');
      expect(FoodSource.openFoodFacts.toStorage(), 'open_food_facts');
    });

    test('an unknown key reads as custom', () {
      // Every row written before S1-5 is a hand-entered food, so custom is
      // the safe reading - and a key from a newer build must not throw on
      // an older one.
      expect(FoodSource.fromStorage('open_food_facts_v2'), FoodSource.custom);
      expect(FoodSource.fromStorage(''), FoodSource.custom);
      expect(FoodSource.fromStorage('openFoodFacts'), FoodSource.custom);
    });
  });
}
