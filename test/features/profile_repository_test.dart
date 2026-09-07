import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

void main() {
  late db.AppDatabase database;
  late DriftProfileRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftProfileRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  UserProfile buildProfile({String? id, DateTime? createdAt}) {
    final now = createdAt ?? DateTime.utc(2026);
    return UserProfile(
      id: id ?? EntityId.generate(),
      displayName: 'Jordan',
      unitSystem: UnitSystem.metric,
      weeklyActivityGoal: 3,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('getProfile returns null before any profile is saved', () async {
    expect(await repository.getProfile(), isNull);
  });

  test('save then watch round-trips the saved profile', () async {
    final profile = buildProfile();

    // emitsThrough (not emitsInOrder([null, ...])): whether the watch
    // query's initial "no profile yet" read lands before or after the
    // write below is a genuine race, not something worth pinning down -
    // what must hold is that the stream eventually reflects the save.
    final expectation = expectLater(
      repository.watchProfile(),
      emitsThrough(
        predicate<UserProfile?>(
          (p) => p != null && p.id == profile.id && p.displayName == 'Jordan',
        ),
      ),
    );

    await repository.saveProfile(profile);
    await expectation;

    final saved = await repository.getProfile();
    expect(saved, isNotNull);
    expect(saved!.id, profile.id);
    expect(saved.unitSystem, UnitSystem.metric);
    expect(saved.weeklyActivityGoal, 3);
  });

  test(
    'saving again with the same id upserts rather than duplicating',
    () async {
      final profile = buildProfile();
      await repository.saveProfile(profile);
      await repository.saveProfile(
        profile.copyWith(displayName: 'Jordan Updated', weeklyActivityGoal: 5),
      );

      final rows = await database.select(database.userProfiles).get();
      expect(rows, hasLength(1));

      final saved = await repository.getProfile();
      expect(saved!.displayName, 'Jordan Updated');
      expect(saved.weeklyActivityGoal, 5);
    },
  );

  test(
    'saveProfile ignores a different createdAt passed on a later call for '
    'the same id - the originally-persisted createdAt always wins',
    () async {
      final original = DateTime.utc(2024);
      final profile = buildProfile(createdAt: original);
      await repository.saveProfile(profile);

      final laterButWrong = DateTime.utc(2030);
      await repository.saveProfile(
        profile.copyWith(
          createdAt: laterButWrong,
          displayName: 'Jordan Updated',
        ),
      );

      final saved = await repository.getProfile();
      expect(saved!.createdAt, original);
      expect(saved.displayName, 'Jordan Updated');
    },
  );

  test('saveProfile always advances updatedAt to now, in UTC', () async {
    final past = DateTime.utc(2020);
    final profile = buildProfile(createdAt: past).copyWith(updatedAt: past);

    final before = DateTime.now().toUtc();
    await repository.saveProfile(profile);
    final after = DateTime.now().toUtc();

    final saved = await repository.getProfile();
    expect(saved!.updatedAt.isUtc, isTrue);
    expect(
      saved.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
      isTrue,
    );
    expect(
      saved.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
      isTrue,
    );
    expect(saved.updatedAt.isAfter(past), isTrue);
    // createdAt is preserved across the update, not overwritten.
    expect(saved.createdAt, past);
  });

  test('weeklyActivityGoal can be cleared back to null', () async {
    final profile = buildProfile();
    await repository.saveProfile(profile);
    await repository.saveProfile(profile.copyWith(weeklyActivityGoal: null));

    final saved = await repository.getProfile();
    expect(saved!.weeklyActivityGoal, isNull);
  });

  test(
    'deleteAllData removes the row and watchProfile emits null',
    () async {
      final profile = buildProfile();
      await repository.saveProfile(profile);
      expect(await repository.getProfile(), isNotNull);

      final expectation = expectLater(
        repository.watchProfile(),
        emitsThrough(isNull),
      );

      await repository.deleteAllData();
      await expectation;

      expect(await repository.getProfile(), isNull);
      final rows = await database.select(database.userProfiles).get();
      expect(rows, isEmpty);
    },
  );

  test(
    'the S1-3 fields round-trip: null, a value, then cleared back to null',
    () async {
      final profile = buildProfile();
      // Starts with none of the new fields set.
      await repository.saveProfile(profile);
      var saved = await repository.getProfile();
      expect(saved!.dateOfBirth, isNull);
      expect(saved.heightCm, isNull);
      expect(saved.weightKg, isNull);
      expect(saved.fitnessGoal, isNull);
      expect(saved.runningExperience, isNull);
      expect(saved.strengthExperience, isNull);
      expect(saved.trainingDays, isEmpty);

      // Set every new field to a value.
      await repository.saveProfile(
        saved.copyWith(
          dateOfBirth: LocalDate(1990, 3, 15),
          heightCm: 170.2,
          weightKg: 65.5,
          fitnessGoal: FitnessGoal.runFurther,
          runningExperience: ExperienceLevel.regular,
          strengthExperience: ExperienceLevel.newTo,
          trainingDays: {Weekday.mon, Weekday.wed, Weekday.fri},
        ),
      );
      saved = await repository.getProfile();
      expect(saved!.dateOfBirth, LocalDate(1990, 3, 15));
      expect(saved.heightCm, 170.2);
      expect(saved.weightKg, 65.5);
      expect(saved.fitnessGoal, FitnessGoal.runFurther);
      expect(saved.runningExperience, ExperienceLevel.regular);
      expect(saved.strengthExperience, ExperienceLevel.newTo);
      expect(saved.trainingDays, {Weekday.mon, Weekday.wed, Weekday.fri});

      // Clear them all back to null (Value(null) upsert semantics - the
      // known drift trap: `insertOnConflictUpdate` leaves an absent
      // companion column untouched, so the mapper must pass explicit
      // `Value(null)` for this to actually take effect).
      await repository.saveProfile(
        saved.copyWith(
          dateOfBirth: null,
          heightCm: null,
          weightKg: null,
          fitnessGoal: null,
          runningExperience: null,
          strengthExperience: null,
          trainingDays: const {},
        ),
      );
      saved = await repository.getProfile();
      expect(saved!.dateOfBirth, isNull);
      expect(saved.heightCm, isNull);
      expect(saved.weightKg, isNull);
      expect(saved.fitnessGoal, isNull);
      expect(saved.runningExperience, isNull);
      expect(saved.strengthExperience, isNull);
      expect(saved.trainingDays, isEmpty);
    },
  );

  test('dateOfBirth round-trips through the underlying ISO string', () async {
    final profile = buildProfile();
    await repository.saveProfile(
      profile.copyWith(dateOfBirth: LocalDate(1985, 12, 25)),
    );

    final row = await database.select(database.userProfiles).getSingle();
    expect(row.dateOfBirth, '1985-12-25');

    final saved = await repository.getProfile();
    expect(saved!.dateOfBirth, LocalDate(1985, 12, 25));
  });

  test('trainingDays round-trips through the underlying CSV column', () async {
    final profile = buildProfile();
    await repository.saveProfile(
      profile.copyWith(trainingDays: {Weekday.sat, Weekday.sun}),
    );

    final row = await database.select(database.userProfiles).getSingle();
    // Order isn't contractually guaranteed by the encoding, but the current
    // implementation preserves Set iteration order for a two-element
    // literal - assert on the decoded set instead of the raw string to stay
    // robust to that.
    expect(row.trainingDays, isNotEmpty);

    final saved = await repository.getProfile();
    expect(saved!.trainingDays, {Weekday.sat, Weekday.sun});
  });

  test('an empty trainingDays set persists as the empty CSV string', () async {
    final profile = buildProfile();
    await repository.saveProfile(profile.copyWith(trainingDays: const {}));

    final row = await database.select(database.userProfiles).getSingle();
    expect(row.trainingDays, '');
  });

  test('wraps a lower-level database error as StorageException', () async {
    // A genuine raw error from the SQL layer (not a contrived one) - the
    // repository must catch it and never let it cross the boundary as-is.
    await database.customStatement('DROP TABLE user_profiles');
    await expectLater(
      repository.getProfile(),
      throwsA(isA<StorageException>()),
    );
  });

  test(
    'a StorageException from saveProfile never interpolates dateOfBirth, '
    'height, or weight values into its message (S2)',
    () async {
      await database.customStatement('DROP TABLE user_profiles');
      final profile = buildProfile().copyWith(
        dateOfBirth: LocalDate(1990, 3, 15),
        heightCm: 170.2,
        weightKg: 65.5,
      );
      try {
        await repository.saveProfile(profile);
        fail('expected a StorageException');
      } on StorageException catch (e) {
        expect(e.message, 'Failed to save user profile');
        expect(e.message, isNot(contains('1990')));
        expect(e.message, isNot(contains('170.2')));
        expect(e.message, isNot(contains('65.5')));
      }
    },
  );
}
