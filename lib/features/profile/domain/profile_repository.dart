import 'package:menfit_app/features/profile/domain/user_profile.dart';

/// Persistence for the local user's profile.
///
/// Single-profile semantics: this device holds at most one profile row.
/// [watchProfile]/[getProfile] resolve deterministically to the
/// earliest-created, non-deleted row so behaviour stays well-defined even
/// if more than one row is ever present.
abstract interface class ProfileRepository {
  /// Emits the current profile, or `null` before onboarding creates one,
  /// and again on every subsequent change.
  Stream<UserProfile?> watchProfile();

  /// Reads the current profile once.
  Future<UserProfile?> getProfile();

  /// Upserts [profile] by id. Always stamps the persisted `updatedAt` to
  /// UTC-now, regardless of the value carried on [profile]. The persisted
  /// `createdAt` is always the value of the first-ever save for that id -
  /// a later call with a different [UserProfile.createdAt] does not move
  /// it, so callers never need to read-before-write themselves.
  Future<void> saveProfile(UserProfile profile);

  /// Permanently deletes all profile data held on this device.
  ///
  /// This is a genuine hard delete, not the soft-delete-and-sync-later
  /// pattern used elsewhere (ADR 004): it exists specifically to make the
  /// onboarding privacy promise ("you can delete your data at any time")
  /// true, and there is nothing to preserve for an outbox once the user
  /// has asked for local data to be gone.
  Future<void> deleteAllData();
}
