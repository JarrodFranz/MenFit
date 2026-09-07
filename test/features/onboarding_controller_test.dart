import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/onboarding/data/onboarding_repository.dart';
import 'package:menfit_app/features/onboarding/onboarding_providers.dart';
import 'package:menfit_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Always succeeds - lets a test isolate a failure to the onboarding side
/// of [OnboardingController.finish] without also depending on Drift.
class _FakeProfileRepository implements ProfileRepository {
  UserProfile? profile;
  final List<UserProfile> saved = [];

  @override
  Stream<UserProfile?> watchProfile() => Stream.value(profile);

  @override
  Future<UserProfile?> getProfile() async => profile;

  @override
  Future<void> saveProfile(UserProfile value) async {
    saved.add(value);
    profile = value;
  }

  @override
  Future<void> deleteAllData() async {
    saved.clear();
    profile = null;
  }
}

/// A real [OnboardingRepository] (so a genuinely successful call persists
/// through [SharedPreferences]) whose [markComplete] throws on its first
/// invocation and succeeds from the second onward - simulates a call that
/// fails partway (e.g. a transient write failure) and is then retried.
class _FailsOnceOnboardingRepository extends OnboardingRepository {
  // Can't forward via `super.preferences`: the super constructor's own
  // parameter name is the private `_preferences`, which this (different)
  // library can't reference.
  // ignore: use_super_parameters
  _FailsOnceOnboardingRepository(SharedPreferences preferences)
    : super(preferences);

  int markCompleteCalls = 0;

  @override
  Future<void> markComplete() async {
    markCompleteCalls++;
    if (markCompleteCalls == 1) {
      throw const StorageException(message: 'simulated transient failure');
    }
    return super.markComplete();
  }
}

void main() {
  test(
    'finish(): saveProfile succeeds but markComplete throws - the error is '
    'surfaced on state.submitError and isSubmitting ends false',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final profileRepository = _FakeProfileRepository();
      final onboardingRepository = _FailsOnceOnboardingRepository(prefs);

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profileRepository),
          onboardingRepositoryProvider.overrideWithValue(
            onboardingRepository,
          ),
        ],
      );
      addTearDown(container.dispose);
      // onboardingControllerProvider is default-autoDispose: a bare `read`
      // doesn't keep it alive across the awaits below. A no-op listener
      // keeps it alive for the container's lifetime, matching how a
      // watching widget would in the real app (see
      // profile_controller_test.dart for the same pattern).
      container.listen(onboardingControllerProvider, (previous, next) {});

      final notifier = container.read(onboardingControllerProvider.notifier);
      // ignore: cascade_invocations - a cascade here can't be awaited.
      notifier.updateDisplayName('Jordan');

      await notifier.finish();

      final state = container.read(onboardingControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.submitError, isNotNull);
      expect(
        container.read(onboardingStatusProvider),
        isFalse,
        reason: 'onboarding must not read as complete after a failed finish',
      );

      // The profile save itself did succeed before the failure.
      expect(profileRepository.saved, hasLength(1));
    },
  );

  test(
    'finish(): retrying after a failed first attempt reuses the same '
    'profile row instead of creating a second one',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final onboardingRepository = _FailsOnceOnboardingRepository(prefs);
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final profileRepository = DriftProfileRepository(database);

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profileRepository),
          onboardingRepositoryProvider.overrideWithValue(
            onboardingRepository,
          ),
        ],
      );
      addTearDown(container.dispose);
      // onboardingControllerProvider is default-autoDispose: a bare `read`
      // doesn't keep it alive across the awaits below. A no-op listener
      // keeps it alive for the container's lifetime, matching how a
      // watching widget would in the real app (see
      // profile_controller_test.dart for the same pattern).
      container.listen(onboardingControllerProvider, (previous, next) {});

      final notifier = container.read(onboardingControllerProvider.notifier);
      // ignore: cascade_invocations - a cascade here can't be awaited.
      notifier.updateDisplayName('Jordan');

      // First attempt: profile save succeeds, markComplete throws.
      await notifier.finish();
      expect(
        container.read(onboardingControllerProvider).submitError,
        isNotNull,
      );
      final rowsAfterFirst = await database.select(database.userProfiles).get();
      expect(rowsAfterFirst, hasLength(1));
      final firstId = rowsAfterFirst.single.id;
      final firstCreatedAt = rowsAfterFirst.single.createdAt;

      // Second attempt: markComplete now succeeds.
      await notifier.finish();
      final state = container.read(onboardingControllerProvider);
      expect(state.submitError, isNull);
      expect(state.isSubmitting, isFalse);
      expect(container.read(onboardingStatusProvider), isTrue);

      final rowsAfterSecond = await database
          .select(database.userProfiles)
          .get();
      expect(rowsAfterSecond, hasLength(1));
      expect(rowsAfterSecond.single.id, firstId);
      expect(rowsAfterSecond.single.createdAt, firstCreatedAt);
    },
  );
}
