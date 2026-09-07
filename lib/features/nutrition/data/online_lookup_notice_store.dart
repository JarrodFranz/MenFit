import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the first-run online-lookup notice has been shown.
///
/// A single device-local boolean, which is exactly what
/// `knowledge/flutter/package_decisions.md` keeps `shared_preferences` for —
/// it is not diary data and it does not belong in the database that "Delete
/// my data" wipes. Same shape and the same raw-value-only discipline as
/// `features/settings/data/settings_repository.dart`.
///
/// Nothing here records *what* was looked up, only that the explanation has
/// been read once.
class OnlineLookupNoticeStore {
  const OnlineLookupNoticeStore(this._preferences);

  final SharedPreferences _preferences;

  static const String _seenKey = 'nutrition_online_lookup_notice_seen';

  /// Whether the user has already read the notice and chosen to go ahead.
  bool hasSeenNotice() => _preferences.getBool(_seenKey) ?? false;

  /// Records that the notice has been read and accepted.
  Future<void> markNoticeSeen() async {
    // SharedPreferences reports platform-level failure by returning `false`
    // rather than throwing, and a raw `false` must not be read as silent
    // success (error_handling.md).
    final ok = await _preferences.setBool(_seenKey, true);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to persist the online lookup notice acknowledgement',
      );
    }
  }

  /// Forgets the acknowledgement, so the notice is shown again next time.
  ///
  /// Called by "Delete my data": a wiped app goes back to onboarding, and a
  /// consent gate that stays satisfied for a device that has been reset is
  /// not consent from whoever is using it next — the first outbound lookup
  /// after a wipe should ask again.
  Future<void> clear() async {
    final ok = await _preferences.remove(_seenKey);
    if (!ok) {
      throw const StorageException(
        message: 'Failed to clear the online lookup notice acknowledgement',
      );
    }
  }
}

/// Gates an outbound lookup on the first-run notice.
///
/// Returns `true` when the request may go out. On a first run it asks
/// [confirm] — which shows the notice — and **returns `false` when the user
/// backs out**, so the caller abandons the lookup entirely. That is what
/// makes this a consent gate rather than a delay: a notice you can only
/// agree to is not consent.
///
/// The acknowledgement is recorded only after the user proceeds, so backing
/// out leaves the notice to be shown again next time.
Future<bool> grantOnlineLookupConsent(
  OnlineLookupNoticeStore store,
  Future<bool> Function() confirm,
) async {
  if (store.hasSeenNotice()) return true;
  if (!await confirm()) return false;
  await store.markNoticeSeen();
  return true;
}
