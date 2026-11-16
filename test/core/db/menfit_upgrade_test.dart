import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';

void main() {
  test(
    'shipped v1 upgrades without losing profile, diary or targets',
    () async {
      final database = AppDatabase.forTesting(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute(
              File('test/fixtures/database/menfit_v1.sql').readAsStringSync(),
            );
            expect(
              sqlite.select('PRAGMA user_version').single.values.single,
              1,
            );
            sqlite.execute('''
            INSERT INTO user_profiles
              (id,display_name,unit_system,created_at,updated_at)
              VALUES ('profile','Jordan','metric',1,1);
            INSERT INTO nutrition_entries
              (id,day,meal,food_name,quantity_servings,calories_kcal,
               protein_grams,carbs_grams,fat_grams,created_at,updated_at)
              VALUES ('entry','2026-09-01','breakfast','Eggs',2,80,6,1,5,1,1);
            INSERT INTO nutrition_goals
              (id,carb_target_grams,created_at,updated_at)
              VALUES ('goals',35,1,1);
            INSERT INTO foods
              (id,name,serving_description,calories_kcal,protein_grams,
               carbs_grams,fat_grams,source,barcode,created_at,updated_at)
              VALUES ('food','Eggs','1 egg',80,6,1,5,'fat_secret','123',1,1);
          ''');
          },
        ),
      );
      addTearDown(database.close);

      expect(
        (await database.select(database.userProfiles).getSingle()).displayName,
        'Jordan',
      );
      final entry = await database
          .select(database.nutritionEntries)
          .getSingle();
      expect(entry.foodName, 'Eggs');
      expect(entry.quantityServings, 2);
      expect(entry.carbsGrams, 1);
      expect(
        (await database.select(database.nutritionGoals).getSingle())
            .carbTargetGrams,
        35,
      );
      expect(await database.select(database.ketoneReadings).get(), isEmpty);
      final food = await database.select(database.foods).getSingle();
      expect(food.name, 'Eggs');
      expect(food.providerFoodId, '123');
      expect(food.barcode, isNull);
      expect(
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        database.schemaVersion,
      );
      final indexes = await database
          .customSelect('PRAGMA index_list(foods)')
          .get();
      expect(
        indexes.map((row) => row.read<String>('name')),
        contains('idx_foods_provider_food_id'),
      );
      final ketoneIndexes = await database
          .customSelect('PRAGMA index_list(ketone_readings)')
          .get();
      expect(
        ketoneIndexes.map((row) => row.read<String>('name')),
        contains('idx_ketone_readings_day'),
      );
      expect(
        await database.select(database.bloodPressureReadings).get(),
        isEmpty,
      );
      expect(
        await database.select(database.bloodMarkerReadings).get(),
        isEmpty,
      );
      for (final (table, index) in [
        ('blood_pressure_readings', 'idx_blood_pressure_readings_measured_at'),
        (
          'blood_marker_readings',
          'idx_blood_marker_readings_marker_measured_at',
        ),
      ]) {
        final healthIndexes = await database
            .customSelect('PRAGMA index_list($table)')
            .get();
        expect(
          healthIndexes.map((row) => row.read<String>('name')),
          contains(index),
        );
      }
    },
  );
}
