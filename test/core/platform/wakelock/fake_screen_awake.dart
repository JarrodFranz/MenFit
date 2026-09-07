import 'package:menfit_app/core/platform/wakelock/screen_awake.dart';

/// Records acquire/release so a tracker's lock lifecycle can be asserted
/// without a plugin — the thing that actually goes wrong with a wakelock is
/// a missing release, and only a counter catches it.
///
/// Counts holders the way `WakelockPlusScreenAwake` does (clamped at zero),
/// so a test that has two trackers running at once sees the same answer from
/// [held] as a device would: the screen stays on until the last one lets go.
class FakeScreenAwake implements ScreenAwake {
  /// Calls to [acquire], however many holders they came from.
  int acquireCount = 0;

  /// Calls to [release], including ones that found nothing to release.
  int releaseCount = 0;

  /// Outstanding holders. Never negative — an unmatched [release] must not
  /// bank credit that swallows a later, matched one.
  int holders = 0;

  /// Whether the screen would currently be held on.
  bool get held => holders > 0;

  @override
  Future<void> acquire() async {
    acquireCount++;
    holders++;
  }

  @override
  Future<void> release() async {
    releaseCount++;
    if (holders > 0) holders--;
  }
}
