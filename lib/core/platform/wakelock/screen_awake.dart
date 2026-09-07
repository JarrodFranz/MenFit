/// Port for holding the screen on while a timed session runs.
///
/// Nothing outside `core/platform/wakelock/` may import a wakelock plugin
/// (architecture_overview.md rule 4, pinned by
/// `test/core/platform/wakelock/wakelock_plus_import_guard_test.dart`).
///
/// ## Why this is a shared seam, not a yoga detail
///
/// It arrived with ADR 014's sequence runner, which needs it most obviously
/// — a 45-minute practice with the phone face-up on the mat and no touches
/// between poses — but every tracker in this app has the same problem: HIIT,
/// swim, strength, mindful and GPS recording all run a foreground timer and
/// all let the screen lock, which on top of hiding the state also suspends
/// the Dart isolate the timer runs on.
///
/// **All six are now wired up**, through
/// `features/activity/presentation/recording/tracker_screen_awake.dart` —
/// one helper rather than six hand-rolled acquire/release pairs, because
/// each tracker has its own start/pause/finish/discard lifecycle to get the
/// release right on and a lock that is acquired and not released is a flat
/// battery. Whether a tracker takes the lock at all is the user's, per
/// activity type: `features/activity/domain/screen_awake_preference.dart`,
/// switched on each exercise hub, on by default.
///
/// ## Contract
///
/// [acquire] and [release] are **reference counted**, not idempotent: the
/// platform lock is one global and this app can have two sessions running
/// at once (the GPS recorder keeps going while she opens another hub on top
/// of it), so an implementation counts holders and only lets the screen
/// sleep once the last one has let go. Each holder must therefore release
/// exactly as many times as it acquired — a holder that releases twice
/// would otherwise switch the screen off underneath somebody else's
/// running session.
///
/// Callers are not expected to do that bookkeeping by hand:
/// `features/activity/presentation/recording/tracker_screen_awake.dart`
/// tracks a per-holder held flag, so a controller that calls `release()` in
/// both `finish()` and `dispose()` is still doing the right thing. A
/// [release] with nothing held anywhere is safe and does nothing.
///
/// Like the audio cue seam, failures are swallowed: a screen that dims is a
/// nuisance, an exception on the start button is a lost session.
abstract interface class ScreenAwake {
  /// Asks the platform to keep the screen on.
  ///
  /// On the web this needs a secure context (HTTPS, or localhost) and the
  /// browser drops the lock whenever the tab is hidden — it is not restored
  /// when she comes back, so a web caller has to re-[acquire] on resume.
  Future<void> acquire();

  /// Lets the screen sleep normally again. Safe to call when nothing was
  /// acquired.
  Future<void> release();
}
