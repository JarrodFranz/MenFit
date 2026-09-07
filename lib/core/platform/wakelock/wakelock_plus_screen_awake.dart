import 'package:flutter/foundation.dart';
import 'package:menfit_app/core/platform/wakelock/screen_awake.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// The one file in the app allowed to import `wakelock_plus`
/// (`test/core/platform/wakelock/wakelock_plus_import_guard_test.dart`).
///
/// `wakelock_plus` needs no permission and no manifest entry on any of the
/// four targets — Android's `FLAG_KEEP_SCREEN_ON` is a window flag rather
/// than a permission, iOS sets `UIApplication.isIdleTimerDisabled`, Windows
/// calls `SetThreadExecutionState`, and the web uses the Screen Wake Lock
/// API. The web one is the only conditional case: it needs a secure context
/// and the browser silently revokes the lock when the tab is hidden, which
/// is why [ScreenAwake] tells callers to re-acquire on resume.
///
/// ## Why it counts holders instead of holding a bool
///
/// The platform lock is a single global, and this app can have **two
/// sessions running at once**: the GPS recorder keeps running while she
/// opens a strength or HIIT hub on top of it (that fallthrough is
/// deliberate — see `active_workout_summary.dart`). Six keep-alive tracker
/// controllers each own a `TrackerScreenAwake`, so with one bool the second
/// tracker to finish would switch the screen lock off underneath a
/// recording that is still going, and a run whose screen sleeps mid-way is
/// exactly the failure this port exists to prevent.
///
/// So [acquire] and [release] are **balanced**, not idempotent: each holder
/// must release exactly as many times as it acquired. The platform is
/// enabled on the 0→1 transition and disabled on 1→0. A stray [release]
/// with nothing held is still safe (the count clamps at zero) — it just
/// cannot borrow another holder's lock.
///
/// Per-holder idempotence is `TrackerScreenAwake`'s job: it tracks its own
/// held flag, so a tracker that releases from both `finish()` and
/// `dispose()` still counts once here.
///
/// [_enabled] is tracked separately from the count rather than inferred
/// from it, so that a failed `enable()` (an unsupported device) is retried
/// by the next holder instead of leaving the count looking satisfied.
///
/// ## Failures are swallowed
///
/// A screen that dims mid-practice is an annoyance; an exception thrown from
/// a start button is a lost session. The debug message is a **static
/// string** — platform exceptions quote their arguments and the app's
/// logging rules do not permit those to reach a log unexamined.
class WakelockPlusScreenAwake implements ScreenAwake {
  WakelockPlusScreenAwake();

  /// How many callers currently want the screen kept on.
  int _holders = 0;

  /// Whether the platform lock is believed to be on.
  bool _enabled = false;

  @override
  Future<void> acquire() async {
    _holders++;
    if (_enabled) return;
    try {
      await WakelockPlus.enable();
      _enabled = true;
    } on Object catch (_) {
      _reportUnavailable();
    }
  }

  @override
  Future<void> release() async {
    // Clamped rather than allowed to go negative: an unmatched release must
    // not bank credit that swallows a later, matched one.
    if (_holders == 0) return;
    _holders--;
    if (_holders > 0 || !_enabled) return;
    // Cleared before the call, not after: if disabling throws, retrying
    // forever on every subsequent release() achieves nothing, and leaving
    // the flag set would block a later acquire() from ever re-enabling.
    _enabled = false;
    try {
      await WakelockPlus.disable();
    } on Object catch (_) {
      _reportUnavailable();
    }
  }

  void _reportUnavailable() {
    if (kDebugMode) {
      debugPrint('ScreenAwake: keep-screen-on unavailable on this device.');
    }
  }
}
