import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/settings/settings_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/custom_event_store.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Store implements CustomWellbeingEventStore {
  bool fail = false;
  bool cleared = false;
  @override
  List<String> savedTitles() => [];
  @override
  Future<void> saveTitle(String title) async {}
  @override
  Future<void> removeTitle(String title) async {}
  @override
  Future<void> clear() async {
    if (fail) throw const StorageException(message: 'Unable to clear names');
    cleared = true;
  }
}

class _Activities extends Mock implements ActivityRepository {}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late _Store store;
  late _Activities activities;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = _Store();
    activities = _Activities();
    when(activities.deleteAllData).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        customWellbeingEventStoreProvider.overrideWithValue(store),
        activityRepositoryProvider.overrideWithValue(activities),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('name preference failure does not prevent database deletion', () async {
    store.fail = true;
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: 'profile',
            displayName: 'Test',
            unitSystem: 'metric',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.ketoneReadings)
        .insert(
          KetoneReadingsCompanion.insert(
            id: 'reading',
            day: '2026-01-01',
            type: 'blood',
            result: '0.5',
            measuredAt: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await expectLater(
      container.read(deleteMyDataServiceProvider).run(),
      throwsA(isA<StorageException>()),
    );
    expect(await db.select(db.ketoneReadings).get(), isEmpty);
    expect(await db.select(db.userProfiles).get(), isEmpty);
  });

  test('names are cleared before a less-sensitive repository fails', () async {
    when(activities.deleteAllData).thenThrow(
      const StorageException(message: 'Unable to clear activities'),
    );
    await expectLater(
      container.read(deleteMyDataServiceProvider).run(),
      throwsA(isA<StorageException>()),
    );
    expect(store.cleared, isTrue);
  });
}
