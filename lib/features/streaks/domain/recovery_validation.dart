import 'package:menfit_app/core/domain/local_date.dart';

/// Result of validating a recovery day being marked.
///
/// A typed result value, not an exception at this layer — the same
/// convention the rest of the app's `domain/` validators follow.
/// `data/drift_recovery_repository.dart` is the
/// only current caller (there is no dedicated form/controller for marking a
/// recovery day — it's a one-tap action from the streak card or the
/// wellbeing check-in flow's recovery prompt), so it wraps a failing
/// [RecoveryDayValidation] into a thrown `ValidationException` at that
/// boundary rather than surfacing typed per-field state to a form.
class RecoveryDayValidation {
  const RecoveryDayValidation({this.dayError});

  final String? dayError;

  bool get isValid => dayError == null;
}

/// Result of validating an inclusive range of recovery days being marked in
/// one go. Same typed-result convention as [RecoveryDayValidation]; a
/// single [rangeError] rather than per-endpoint fields, because the range
/// picker the UI offers is one control, not two independent ones.
class RecoveryDayRangeValidation {
  const RecoveryDayRangeValidation({this.rangeError});

  final String? rangeError;

  bool get isValid => rangeError == null;
}

/// The greatest number of calendar days one `markRecoveryDays` call may
/// cover, inclusive of both endpoints — a wide, non-judgemental bound in
/// the same spirit as `features/profile/domain/profile_validation.dart`'s
/// height/weight bounds and
/// `features/wellbeing/domain/flare_event.dart`'s `maxFlareRangeDays`. It
/// exists to catch a mis-picked year in a date picker, not to cap how much
/// recovery anyone is allowed.
const int maxRecoveryRangeDays = 90;

// Health-adjacent data: no message here ever interpolates a date (same S3
// rule as `core/domain/local_date.dart`'s `parse`). The day count below is
// a fixed constant, not user data.
const String _futureDayMessage =
    "That hasn't happened yet — pick a day that's today or earlier.";
const String _endBeforeStartMessage =
    "Pick a last day that's on or after the first day.";
const String _rangeTooLongMessage =
    "That's a longer stretch than we can mark in one go — pick up to "
    '$maxRecoveryRangeDays days.';

/// Validates a recovery day being marked: [day] must not be in the future
/// relative to [today] (calendar-day semantics —
/// `knowledge/architecture/data_architecture.md`). There's no other
/// constraint — a recovery day requires no proof
/// (`knowledge/product/terminology.md`'s "Protected Recovery" definition)
/// and can be marked freely in the past or present.
RecoveryDayValidation validateRecoveryDay({
  required LocalDate day,
  required LocalDate today,
}) {
  return RecoveryDayValidation(
    dayError: day.isAfter(today) ? _futureDayMessage : null,
  );
}

/// Validates the inclusive range `[from, to]` being marked as recovery in
/// one action (`domain/recovery_repository.dart#markRecoveryDays`):
///
/// - [to] must be on or after [from].
/// - [to] must not be in the future — this reuses [validateRecoveryDay]'s
///   rule rather than restating it, and checking only the range's last day
///   is sufficient: once [to] is known to be on or after [from], no earlier
///   day in the range can be in the future either.
/// - the inclusive range must be at most [maxRecoveryRangeDays] days long.
///
/// A single-day range (`from == to`) is exactly as valid as the equivalent
/// [validateRecoveryDay] call, so `markRecoveryDay` can be expressed as the
/// degenerate case of `markRecoveryDays` without changing what any existing
/// caller sees.
RecoveryDayRangeValidation validateRecoveryDayRange({
  required LocalDate from,
  required LocalDate to,
  required LocalDate today,
}) {
  if (to.isBefore(from)) {
    return const RecoveryDayRangeValidation(rangeError: _endBeforeStartMessage);
  }
  final lastDay = validateRecoveryDay(day: to, today: today);
  if (!lastDay.isValid) {
    return RecoveryDayRangeValidation(rangeError: lastDay.dayError);
  }
  // Inclusive length: a range whose endpoints are the same day is 1 day.
  if (from.difference(to) + 1 > maxRecoveryRangeDays) {
    return const RecoveryDayRangeValidation(rangeError: _rangeTooLongMessage);
  }
  return const RecoveryDayRangeValidation();
}
