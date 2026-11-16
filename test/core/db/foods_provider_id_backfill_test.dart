import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/foods_provider_id_backfill.dart';

void main() {
  test(
    'separates clear provider ids and preserves ambiguous product codes',
    () {
      expect(
        classifyLegacyFatSecretBarcode('35755'),
        LegacyFatSecretBarcode.providerId,
      );
      expect(
        classifyLegacyFatSecretBarcode('27365861'),
        LegacyFatSecretBarcode.ambiguous,
      );
      expect(
        classifyLegacyFatSecretBarcode('5000112637922'),
        LegacyFatSecretBarcode.barcode,
      );
      expect(
        classifyLegacyFatSecretBarcode('1234567890123'),
        LegacyFatSecretBarcode.ambiguous,
      );
    },
  );

  test('backfill preserves custom rows and is idempotent', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    for (final (id, source, code) in [
      ('id', 'fat_secret', '35755'),
      ('ambiguous', 'fat_secret', '27365861'),
      ('real', 'fat_secret', '5000112637922'),
      ('custom', 'custom', '35755'),
    ]) {
      await db.customStatement(
        'INSERT INTO foods (id, name, serving_description, calories_kcal, '
        'protein_grams, carbs_grams, fat_grams, barcode, source, created_at, '
        'updated_at) VALUES (?, ?, ?, 100, 1, 1, 1, ?, ?, 1000, 1000)',
        [id, 'Food', '1 serving', code, source],
      );
    }
    expect(await backfillFoodsProviderFoodId(db), 2);
    expect(await backfillFoodsProviderFoodId(db), 0);
    final rows = await db.select(db.foods).get();
    final byId = {for (final row in rows) row.id: row};
    expect(byId['id']!.barcode, isNull);
    expect(byId['id']!.providerFoodId, '35755');
    expect(byId['ambiguous']!.barcode, '27365861');
    expect(byId['ambiguous']!.providerFoodId, '27365861');
    expect(byId['real']!.barcode, '5000112637922');
    expect(byId['real']!.providerFoodId, isNull);
    expect(byId['custom']!.barcode, '35755');
    expect(byId['custom']!.providerFoodId, isNull);
  });
}
