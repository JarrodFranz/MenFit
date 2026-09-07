import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/wakelock/screen_awake.dart';
import 'package:menfit_app/core/platform/wakelock/screen_awake_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

/// The wake-lock half of a tracker, in one place.
///
/// Every tracker in this folder has the same three obligations and got them
/// wrong in six different ways before this existed: take the lock when a
/// session starts (but only if the hub's "Keep screen awake" switch is on
/// for that type), let go on *every* exit including `ref.onDispose`, and
/// react while the session is still running if they change their mind on the
/// hub. A lock acquired and not released is a flat battery, so the
/// interesting part is the release, not the acquire.
///
/// ## Two things it is careful about
///
/// **The lock instance is captured at [acquireFor] time.** [release] then
/// touches only the captured object and the subscription — never `ref` —
/// because release runs from `ref.onDispose`, at a point where the
/// container's teardown order is not ours to rely on.
///
/// **The preference is listened to, not read once.** A switch flipped
/// during a workout has to take effect on that workout; polling it at
/// start only would mean the change lands on the *next* session, which
/// reads as the setting being broken.
///
/// Nothing here throws and nothing here logs: the futures are fired and
/// forgotten exactly as `ScreenAwake` intends (a screen that dims is a
/// nuisance, an exception on the Start button is a lost session).
class TrackerScreenAwake {
  TrackerScreenAwake(this._ref);

  final Ref _ref;

  /// The `ScreenAwake` captured on the first [acquireFor]. Kept for the
  /// life of the tracker: it is a process-wide singleton, so re-reading it
  /// would return the same object anyway, and holding it means [release]
  /// needs no `ref`.
  ScreenAwake? _lock;

  /// Whether an unmatched `acquire()` is outstanding.
  ///
  /// Load-bearing, not tidiness: `ScreenAwake` counts holders, so a second
  /// acquire or a double release from *this* tracker would move the shared
  /// count and take the screen lock away from another tracker that is still
  /// running (recording continues underneath the strength hub by design).
  /// This flag is what makes one `TrackerScreenAwake` exactly one holder,
  /// however many times its controller calls in.
  bool _held = false;

  ProviderSubscription<bool>? _preference;

  /// Starts honouring [type]'s preference: takes the lock now if the
  /// setting is on, and keeps following it until [release].
  ///
  /// Safe to call again — a second call replaces the type being followed,
  /// which is what a tracker that can record more than one type (the GPS
  /// recorder, the mindful tracker) needs when a new session starts.
  void acquireFor(ActivityType type) {
    _preference?.close();
    // Read eagerly, while we are demonstrably not inside a life-cycle
    // callback, so the listener below never has to go through `ref`.
    _lock ??= _ref.read(screenAwakeProvider);
    _preference = _ref.listen(
      screenAwakePreferenceProvider(type),
      (_, enabled) {
        if (enabled) {
          _acquire();
        } else {
          _releaseLock();
        }
      },
      fireImmediately: true,
    );
  }

  /// Stops following the preference and lets the screen sleep again.
  ///
  /// Idempotent, and safe from `ref.onDispose`: it reads no provider.
  void release() {
    _preference?.close();
    _preference = null;
    _releaseLock();
  }

  void _acquire() {
    final lock = _lock;
    if (lock == null || _held) return;
    _held = true;
    unawaited(lock.acquire());
  }

  void _releaseLock() {
    final lock = _lock;
    if (lock == null || !_held) return;
    _held = false;
    unawaited(lock.release());
  }
}
