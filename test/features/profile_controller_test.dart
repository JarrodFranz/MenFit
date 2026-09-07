import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/presentation/profile_controller.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_repository.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';

class _FakeProfileRepository implements ProfileRepository {
  UserProfile? profile;
  final List<UserProfile> saved = [];
  final _controller = StreamController<UserProfile?>.broadcast();

  @override
  Stream<UserProfile?> watchProfile() async* {
    yield profile;
    yield* _controller.stream;
  }

  void emit(UserProfile? value) {
    profile = value;
    _controller.add(value);
  }

  @override
  Future<UserProfile?> getProfile() async => profile;

  @override
  Future<void> saveProfile(UserProfile value) async {
    saved.add(value);
    emit(value);
  }

  @override
  Future<void> deleteAllData() async {
    saved.clear();
    emit(null);
  }

  Future<void> close() => _controller.close();
}

/// Stands in for the real weight repository so the controller's
/// profile -> weight-history write-through can be observed without a
/// database. Everything but [saveLog] is unreachable from this controller.
class _FakeWeightRepository implements WeightRepository {
  final List<WeightLog> saved = [];

  /// Makes the next [saveLog] throw the way the Drift repository does when
  /// the write fails (`data/drift_weight_repository.dart` wraps everything
  /// into a [StorageException]).
  bool failNextSave = false;

  @override
  Future<void> saveLog(WeightLog log) async {
    if (failNextSave) {
      failNextSave = false;
      throw const StorageException(message: 'Failed to save weight log');
    }
    saved.add(log);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unexpected ${invocation.memberName}');
}

void main() {
  late _FakeProfileRepository repository;
  late _FakeWeightRepository weightRepository;
  late ProviderContainer container;

  UserProfile existingProfile() => UserProfile(
    id: 'id-1',
    displayName: 'Jordan',
    unitSystem: UnitSystem.metric,
    weeklyActivityGoal: 3,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  setUp(() {
    repository = _FakeProfileRepository();
    weightRepository = _FakeWeightRepository();
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        // Overridden, not merely available: the real provider would build a
        // Drift database against the filesystem inside a unit test.
        weightRepositoryProvider.overrideWithValue(weightRepository),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.close);

    // profileControllerProvider is a StreamNotifier (default autoDispose):
    // without an active listener it can be torn down mid-flight on its
    // very first (pending) emission, surfacing as "disposed during loading
    // state". A no-op listen keeps it alive for the container's lifetime,
    // matching how a watching widget would keep it alive in the real app.
    container.listen(profileControllerProvider, (previous, next) {});
  });

  test(
    'build watches the repository and starts with the current profile',
    () async {
      final value = await container.read(profileControllerProvider.future);
      expect(value, isNull);
    },
  );

  test('updateProfile creates a profile when none exists yet', () async {
    await container.read(profileControllerProvider.future);

    await container
        .read(profileControllerProvider.notifier)
        .updateProfile(displayName: 'Jordan', unitSystem: UnitSystem.imperial);

    expect(repository.saved, hasLength(1));
    final created = repository.saved.single;
    expect(created.displayName, 'Jordan');
    expect(created.unitSystem, UnitSystem.imperial);
    expect(created.id, isNotEmpty);
  });

  test(
    'updateProfile merges fields onto the existing profile without '
    'clobbering unspecified ones',
    () async {
      repository.emit(existingProfile());
      await container.read(profileControllerProvider.future);

      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(unitSystem: UnitSystem.imperial);

      final updated = repository.saved.single;
      expect(updated.id, 'id-1');
      expect(updated.displayName, 'Jordan'); // unchanged
      expect(updated.unitSystem, UnitSystem.imperial); // changed
      expect(updated.weeklyActivityGoal, 3); // unchanged
    },
  );

  test('updateProfile(clearWeeklyActivityGoal: true) nulls the goal', () async {
    repository.emit(existingProfile());
    await container.read(profileControllerProvider.future);

    await container
        .read(profileControllerProvider.notifier)
        .updateProfile(clearWeeklyActivityGoal: true);

    expect(repository.saved.single.weeklyActivityGoal, isNull);
  });

  test(
    'updateProfile(weeklyActivityGoal: x) is dropped by '
    'clearWeeklyActivityGoal when both are passed',
    () async {
      repository.emit(existingProfile());
      await container.read(profileControllerProvider.future);

      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(weeklyActivityGoal: 5, clearWeeklyActivityGoal: true);

      expect(repository.saved.single.weeklyActivityGoal, isNull);
    },
  );

  test(
    'updateProfile sets the S1-3 fields onto an existing profile without '
    'clobbering unspecified ones',
    () async {
      repository.emit(existingProfile());
      await container.read(profileControllerProvider.future);

      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(
            dateOfBirth: LocalDate(1990, 3, 15),
            heightCm: 170.2,
            weightKg: 65.5,
            fitnessGoal: FitnessGoal.getStronger,
            runningExperience: ExperienceLevel.occasional,
            strengthExperience: ExperienceLevel.experienced,
            trainingDays: {Weekday.tue, Weekday.thu},
          );

      final updated = repository.saved.single;
      expect(updated.id, 'id-1');
      expect(updated.displayName, 'Jordan'); // unchanged
      expect(updated.dateOfBirth, LocalDate(1990, 3, 15));
      expect(updated.heightCm, 170.2);
      expect(updated.weightKg, 65.5);
      expect(updated.fitnessGoal, FitnessGoal.getStronger);
      expect(updated.runningExperience, ExperienceLevel.occasional);
      expect(updated.strengthExperience, ExperienceLevel.experienced);
      expect(updated.trainingDays, {Weekday.tue, Weekday.thu});
    },
  );

  test(
    'the clear* flags unset the matching S1-3 field back to null',
    () async {
      repository.emit(
        existingProfile().copyWith(
          dateOfBirth: LocalDate(1990, 3, 15),
          heightCm: 170.2,
          weightKg: 65.5,
          fitnessGoal: FitnessGoal.getStronger,
          runningExperience: ExperienceLevel.occasional,
          strengthExperience: ExperienceLevel.experienced,
        ),
      );
      await container.read(profileControllerProvider.future);

      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(
            clearDateOfBirth: true,
            clearHeightCm: true,
            clearWeightKg: true,
            clearFitnessGoal: true,
            clearRunningExperience: true,
            clearStrengthExperience: true,
          );

      final updated = repository.saved.single;
      expect(updated.dateOfBirth, isNull);
      expect(updated.heightCm, isNull);
      expect(updated.weightKg, isNull);
      expect(updated.fitnessGoal, isNull);
      expect(updated.runningExperience, isNull);
      expect(updated.strengthExperience, isNull);
    },
  );

  test(
    'passing a value alongside its clear flag is dropped by the clear flag, '
    'same as clearWeeklyActivityGoal',
    () async {
      repository.emit(existingProfile());
      await container.read(profileControllerProvider.future);

      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(heightCm: 170, clearHeightCm: true);

      expect(repository.saved.single.heightCm, isNull);
    },
  );

  test(
    'trainingDays needs no clear flag - passing an empty set clears it, '
    'passing null leaves it unchanged',
    () async {
      repository.emit(
        existingProfile().copyWith(trainingDays: {Weekday.mon}),
      );
      await container.read(profileControllerProvider.future);

      // null (the default when omitted) leaves it unchanged.
      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(displayName: 'Alex');
      expect(repository.saved.single.trainingDays, {Weekday.mon});

      // An explicit empty set clears it.
      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(trainingDays: const {});
      expect(repository.saved.last.trainingDays, isEmpty);
    },
  );

  test(
    'two rapid updates to different fields, issued before either is '
    'awaited, both persist (regression: the merge base for the second '
    'update must be read fresh after the first is done, not captured '
    'when the caller fired)',
    () async {
      repository.emit(existingProfile());
      await container.read(profileControllerProvider.future);

      final notifier = container.read(profileControllerProvider.notifier);

      // Both calls are in flight before either is awaited - genuinely
      // contested, not just sequential.
      final first = notifier.updateProfile(displayName: 'Alex');
      final second = notifier.updateProfile(weeklyActivityGoal: 7);
      await Future.wait([first, second]);

      final finalProfile = repository.profile!;
      expect(finalProfile.displayName, 'Alex');
      expect(finalProfile.weeklyActivityGoal, 7);
      expect(finalProfile.unitSystem, UnitSystem.metric); // untouched
      expect(repository.saved, hasLength(2));
    },
  );

  group('weight write-through (task 2.1)', () {
    test('a new weight is recorded in the weight history', () async {
      repository.emit(existingProfile());
      await container.read(profileControllerProvider.future);

      await container
          .read(profileControllerProvider.notifier)
          .updateProfile(weightKg: 65.5);

      expect(weightRepository.saved, hasLength(1));
      final logged = weightRepository.saved.single;
      expect(logged.weightKg, 65.5);
      expect(logged.day, LocalDate.today());
      expect(
        logged.source,
        WeightLogSource.manual,
        reason: 'they typed this number themselves, via the profile field',
      );
    });

    test('a changed weight is recorded as a further point', () async {
      repository.emit(existingProfile().copyWith(weightKg: 65.5));
      await container.read(profileControllerProvider.future);

      final notifier = container.read(profileControllerProvider.notifier);
      await notifier.updateProfile(weightKg: 65);
      await notifier.updateProfile(weightKg: 64.6);

      expect(weightRepository.saved.map((e) => e.weightKg), [65, 64.6]);
      expect(
        weightRepository.saved.map((e) => e.id).toSet(),
        hasLength(2),
        reason: 'each point is its own row, not an overwrite',
      );
    });

    test(
      're-saving the same weight records nothing - a duplicate point would '
      'flatten a trend line without their having weighed in again',
      () async {
        repository.emit(existingProfile().copyWith(weightKg: 65.5));
        await container.read(profileControllerProvider.future);

        await container
            .read(profileControllerProvider.notifier)
            .updateProfile(weightKg: 65.5);

        expect(weightRepository.saved, isEmpty);
      },
    );

    test(
      'updating an unrelated field records nothing, even though the profile '
      'still carries a weight',
      () async {
        repository.emit(existingProfile().copyWith(weightKg: 65.5));
        await container.read(profileControllerProvider.future);

        await container
            .read(profileControllerProvider.notifier)
            .updateProfile(displayName: 'Alex');

        expect(weightRepository.saved, isEmpty);
      },
    );

    test(
      'clearing the weight records nothing - a removal is not a measurement',
      () async {
        repository.emit(existingProfile().copyWith(weightKg: 65.5));
        await container.read(profileControllerProvider.future);

        await container
            .read(profileControllerProvider.notifier)
            .updateProfile(clearWeightKg: true);

        expect(repository.saved.single.weightKg, isNull);
        expect(weightRepository.saved, isEmpty);
      },
    );

    test(
      'a failed history write does not fail the profile save that succeeded',
      () async {
        // The write-through runs *after* the profile row is persisted, so
        // letting its StorageException out would report a save that landed
        // as a save that failed, and invite them to redo an edit that is
        // already stored. The lost point self-heals on their next weight
        // edit; the authoritative profile row is correct either way.
        weightRepository.failNextSave = true;

        await expectLater(
          container
              .read(profileControllerProvider.notifier)
              .updateProfile(weightKg: 65.5),
          completes,
        );

        expect(repository.saved.single.weightKg, 65.5);
        expect(weightRepository.saved, isEmpty);
      },
    );
  });
}
