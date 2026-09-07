/// Per-activity-type rule for whether a running session holds the screen on.
///
/// ## What it is
///
/// One boolean per `ActivityType`, chosen on that type's exercise hub and
/// honoured by whichever tracker records that type. Every tracker in the
/// app keeps the screen awake by default — a phone face-down on a mat, or
/// in an armband, that locks mid-session hides the state *and* suspends the
/// isolate the countdown runs on. The setting exists because the tradeoff
/// is not the same for every activity: a 45-minute yoga practice wants the
/// screen on, a two-hour ride with the phone in a pocket wants it off, and
/// only they know which is which.
///
/// **The default is ON for every type**, and a type with nothing stored
/// reads as ON — see [screenAwakeDefaultEnabled]. Writing a default at
/// first read would be indistinguishable from a choice they made.
///
/// ## Why this is not user data
///
/// It is a **device preference**, like the food-search region: it describes
/// this phone's behaviour, not anything about them. Two consequences, both
/// deliberate:
///
/// * it lives in `shared_preferences`, **not** in the database, so
///   "Delete my data" does not wipe it — deleting a diary should not turn
///   the screen timeout back on mid-training-block;
/// * it is **not** included in a data export. There is nothing about them in
///   it, and an export that carries device settings invites them being
///   restored onto a phone they were never chosen for.
///
/// It is also not health data at any tier, so nothing here needs the
/// handling rules in `knowledge/engineering/security_and_privacy.md`
/// beyond the ordinary "log nothing you do not need to".
library;

/// What an activity type with nothing stored reads as.
///
/// The single source of the default: the store falls back to it and the
/// hub switch renders from the store, so there is no second place for the
/// two to disagree.
const bool screenAwakeDefaultEnabled = true;
