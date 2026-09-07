/// Port for the app's spoken voice cues (text-to-speech).
///
/// Spoken cues provide real-time audio announcements during workouts
/// (such as kilometer/mile split completions, split pace, elapsed time,
/// and status transitions).
///
/// Following architecture rule 4, nothing outside `core/platform/speech/`
/// may import `package:flutter_tts`. Feature and controller code depends
/// on this interface and obtains an implementation from
/// `speechAdapterProvider`.
///
/// **A voice cue must never break a workout.** Every method here is specified
/// to complete normally when the platform cannot speak or TTS is uninitialized.
/// Implementations swallow native failures and log static warnings rather than
/// throwing exceptions into a running workout session.
abstract interface class SpeechAdapter {
  /// Speaks [text] aloud using the device text-to-speech engine.
  ///
  /// If the platform is currently speaking, calling this should either stop
  /// the previous utterance or queue behind it without throwing.
  Future<void> speak(String text);

  /// Stops any in-progress speech playback immediately.
  Future<void> stop();

  /// Sets the speech rate (between 0.0 and 1.0, where ~0.5 represents a
  /// natural conversational cadence on most mobile TTS engines).
  Future<void> setSpeechRate(double rate);

  /// Sets the speech volume (between 0.0 and 1.0).
  Future<void> setVolume(double volume);

  /// Releases underlying TTS native resources and handlers.
  Future<void> dispose();
}
