import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';

/// [ProfileRepository] backed by the `user_profiles` Drift table.
///
/// The generated Drift row class is also named `UserProfile`, so this file
/// imports `app_database.dart` with the `db` prefix throughout to keep it
/// distinct from the freezed domain entity of the same name.
///
/// Single-profile semantics: [watchProfile]/[getProfile] always resolve to
/// the earliest-created, non-deleted row (`ORDER BY created_at ASC, id ASC
/// LIMIT 1` - the secondary `id` ordering only matters for the
/// pathological case of two rows sharing a `createdAt` millisecond, and
/// makes that case deterministic instead of storage-order-dependent);
/// [saveProfile] upserts by primary key.
///
/// The provider for this repository lives in `../profile_providers.dart`
/// (ADR 007), not here - `data/` may not expose the composition surface
/// other features are allowed to depend on.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`):
/// [UserProfile.dateOfBirth]/[UserProfile.heightCm]/[UserProfile.weightKg]
/// never appear in a thrown [AppException]'s `message` — those stay static
/// strings, same convention as every other repository in this codebase.
class DriftProfileRepository implements ProfileRepository {
  const DriftProfileRepository(this._db);

  final db.AppDatabase _db;

  Selectable<db.UserProfile> _primaryProfileQuery() {
    return _db.select(_db.userProfiles)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.id),
      ])
      ..limit(1);
  }

  @override
  Stream<UserProfile?> watchProfile() {
    return _primaryProfileQuery()
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch user profile',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final row = await _primaryProfileQuery().getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to read user profile',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Read-then-write so `createdAt` is preserved across an update
        // regardless of what the caller passed in - this repository stays
        // safe even if a caller ever merges from a stale base (see
        // `presentation/profile_controller.dart` and
        // `features/onboarding/presentation/onboarding_controller.dart`
        // for the two callers that also read-first for the same reason).
        final existing = await (_db.select(
          _db.userProfiles,
        )..where((t) => t.id.equals(profile.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            profile.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.userProfiles)
            .insertOnConflictUpdate(
              db.UserProfilesCompanion.insert(
                id: profile.id,
                displayName: profile.displayName,
                unitSystem: profile.unitSystem.toStorage(),
                // Explicit Value(...) so clearing a field back to null is
                // actually applied - insertOnConflictUpdate leaves columns
                // absent from the companion untouched on the existing row.
                weeklyActivityGoal: Value(profile.weeklyActivityGoal),
                dateOfBirth: Value(profile.dateOfBirth?.toIso()),
                heightCm: Value(profile.heightCm),
                weightKg: Value(profile.weightKg),
                fitnessGoal: Value(
                  _fitnessGoalsToStorage(profile),
                ),
                runningExperience: Value(
                  profile.runningExperience?.toStorage(),
                ),
                strengthExperience: Value(
                  profile.strengthExperience?.toStorage(),
                ),
                trainingDays: Value(_weekdaysToCsv(profile.trainingDays)),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save user profile',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.userProfiles).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete user profile data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  UserProfile _toEntity(db.UserProfile row) {
    return UserProfile(
      id: row.id,
      displayName: row.displayName,
      unitSystem: UnitSystem.fromStorage(row.unitSystem),
      weeklyActivityGoal: row.weeklyActivityGoal,
      dateOfBirth: row.dateOfBirth == null
          ? null
          : LocalDate.parse(row.dateOfBirth!),
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      fitnessGoal: _fitnessGoalsFromCsv(row.fitnessGoal).firstOrNull,
      fitnessGoals: _fitnessGoalsFromCsv(row.fitnessGoal),
      runningExperience: ExperienceLevel.fromStorage(row.runningExperience),
      strengthExperience: ExperienceLevel.fromStorage(row.strengthExperience),
      trainingDays: _weekdaysFromCsv(row.trainingDays),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
  }
}

/// Encodes [days] as the comma-separated storage form used by
/// `user_profiles.training_days` — same CSV convention as
/// `features/wellbeing/data/drift_wellbeing_repository.dart`'s
/// `_symptomsToCsv`.
String _weekdaysToCsv(Set<Weekday> days) {
  return days.map((d) => d.toStorage()).join(',');
}

/// Decodes the comma-separated storage form back into [Weekday]s. `''`
/// decodes to an empty set. Unlike `symptomsFromCsv`, an unparsable entry is
/// silently dropped rather than mapped to a catch-all - [Weekday] has no
/// "other" value (see `Weekday.fromStorage`'s doc).
Set<Weekday> _weekdaysFromCsv(String csv) {
  if (csv.isEmpty) return const {};
  return csv.split(',').map(Weekday.fromStorage).whereType<Weekday>().toSet();
}

/// Resolves the storage value for `user_profiles.fitness_goal`:
/// multiple goals are encoded as CSV; a single goal as its single key;
/// clearing the goal (null) yields null.
String? _fitnessGoalsToStorage(UserProfile profile) {
  if (profile.fitnessGoals.length > 1) {
    return _fitnessGoalsToCsv(profile.fitnessGoals);
  }
  if (profile.fitnessGoal != null) {
    return profile.fitnessGoal!.toStorage();
  }
  return null;
}

/// Encodes [goals] as a comma-separated string for
/// `user_profiles.fitness_goal`.
String? _fitnessGoalsToCsv(Set<FitnessGoal> goals) {
  if (goals.isEmpty) return null;
  return goals.map((g) => g.toStorage()).join(',');
}

/// Decodes comma-separated string back into [FitnessGoal]s.
Set<FitnessGoal> _fitnessGoalsFromCsv(String? csv) {
  if (csv == null || csv.isEmpty) return const {};
  return csv
      .split(',')
      .map(FitnessGoal.fromStorage)
      .whereType<FitnessGoal>()
      .toSet();
}
