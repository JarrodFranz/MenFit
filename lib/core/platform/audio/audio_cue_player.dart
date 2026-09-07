/// Port for the app's short, non-speech audio cues.
///
/// One sound, one job: the chime that marks a boundary she is not looking
/// at the screen for (ADR 014's pose transitions; interval boundaries when
/// the trackers are wired to it). It is deliberately not a general audio
/// API — no volume, no seeking, no queue — because everything this port
/// does not expose is a per-platform behaviour nobody has to reason about.
///
/// Nothing outside `core/platform/audio/` may import a playback plugin
/// (architecture_overview.md rule 4, pinned by
/// `test/core/platform/audio/audioplayers_import_guard_test.dart`). Feature
/// code depends on this interface and gets an implementation from
/// `audioCuePlayerProvider`.
///
/// **A cue must never break a practice.** Every method here is specified to
/// complete normally when the platform cannot play: implementations swallow
/// their failures rather than propagating them, and callers are not expected
/// to try/catch. A missing chime is a degraded cue; a thrown exception on a
/// timer boundary is a lost session.
abstract interface class AudioCuePlayer {
  /// Loads the cue and, where the platform requires it, unlocks playback.
  ///
  /// Call this from the user's **Start tap**, not from a controller's
  /// `build`. Browsers refuse to play audio that no user gesture led to,
  /// and the gesture that counts is the one on the call stack — a preload
  /// issued a second later from a timer is already too late, and the first
  /// real cue is then silently dropped. Preloading also moves the file
  /// decode off the transition path, so the chime starts when the phase
  /// changes rather than tens of milliseconds after it.
  ///
  /// Safe to call more than once.
  Future<void> preload();

  /// Plays the transition chime from its start, cutting off any still-ringing
  /// tail from the previous cue.
  ///
  /// Returns as soon as playback has been *asked for* — it does not wait for
  /// the ~1.6 s clip to finish, because a phase boundary must not block on a
  /// sound.
  Future<void> playTransitionChime();

  /// Releases the underlying player. After this the instance is spent; get a
  /// new one from the provider.
  Future<void> dispose();
}
