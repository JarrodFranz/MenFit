/// A day of the week, Monday through Sunday.
///
/// Shared value type (`core/domain/` per `architecture_overview.md` rule 3):
/// used by `features/profile/domain/user_profile.dart`'s
/// `UserProfile.trainingDays` today, and generically useful to any future
/// feature that needs a weekday concept (schedules, reminders). Deliberately
/// not tied to `DateTime.weekday`'s 1-7 int encoding — an explicit enum
/// reads clearly at call sites and survives a storage-format change without
/// touching every caller.
enum Weekday {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun;

  /// Parses the persisted string form. Returns `null` for any unrecognised
  /// value — unlike most storage-key enums in this codebase, [Weekday] has
  /// no natural "other" catch-all, so callers decoding a CSV list (see
  /// `features/profile/data/drift_profile_repository.dart`) drop unparsable
  /// entries rather than guessing.
  static Weekday? fromStorage(String value) {
    return switch (value) {
      'mon' => Weekday.mon,
      'tue' => Weekday.tue,
      'wed' => Weekday.wed,
      'thu' => Weekday.thu,
      'fri' => Weekday.fri,
      'sat' => Weekday.sat,
      'sun' => Weekday.sun,
      _ => null,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    Weekday.mon => 'mon',
    Weekday.tue => 'tue',
    Weekday.wed => 'wed',
    Weekday.thu => 'thu',
    Weekday.fri => 'fri',
    Weekday.sat => 'sat',
    Weekday.sun => 'sun',
  };

  /// Short display label ('Mon'..'Sun').
  String get label => switch (this) {
    Weekday.mon => 'Mon',
    Weekday.tue => 'Tue',
    Weekday.wed => 'Wed',
    Weekday.thu => 'Thu',
    Weekday.fri => 'Fri',
    Weekday.sat => 'Sat',
    Weekday.sun => 'Sun',
  };
}
