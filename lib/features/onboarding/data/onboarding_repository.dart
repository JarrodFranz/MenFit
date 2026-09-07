import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the one-time onboarding flow has been completed on
/// this device, using [SharedPreferences].
///
/// Only knows how to read/write the raw flag - no business logic and no
/// widget/provider concerns live here, matching
/// `features/settings/data/settings_repository.dart`.
class OnboardingRepository {
  const OnboardingRepository(this._preferences);

  final SharedPreferences _preferences;

  static const String _completeKey = 'onboarding_complete';

  /// Whether onboarding has been completed on this device.
  bool get isComplete => _preferences.getBool(_completeKey) ?? false;

  /// Marks onboarding as completed.
  Future<void> markComplete() async {
    // SharedPreferences read/write methods return `false` (rather than
    // throwing) on platform-level failure - a raw `false` must not be
    // treated as silent success (see error_handling.md: a failure must
    // never cross a repository boundary unreported).
    final ok = await _preferences.setBool(_completeKey, true);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist onboarding completion',
      );
    }
  }

  /// Clears the onboarding-complete flag, e.g. after a full local data
  /// wipe (see `features/settings/presentation/settings_screen.dart`).
  Future<void> markIncomplete() async {
    final ok = await _preferences.remove(_completeKey);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to reset onboarding completion',
      );
    }
  }
}
