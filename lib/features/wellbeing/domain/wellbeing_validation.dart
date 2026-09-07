import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';

/// Result of validating a daily check-in being logged or edited.
///
/// A typed result value, not an exception — same convention as
/// `features/streaks/domain/recovery_validation.dart`'s
/// `RecoveryDayValidation`.
class CheckinValidation {
  const CheckinValidation({
    this.dayError,
    this.energyError,
    this.sleepError,
    this.sorenessError,
    this.stressError,
    this.painError,
  });

  final String? dayError;
  final String? energyError;
  final String? sleepError;
  final String? sorenessError;
  final String? stressError;
  final String? painError;

  bool get isValid =>
      dayError == null &&
      energyError == null &&
      sleepError == null &&
      sorenessError == null &&
      stressError == null &&
      painError == null;
}

const String _outOfRangeMessage = 'Pick a value from 0 to 5.';

/// Validates a daily check-in's fields:
///
/// - [day] must not be in the future relative to [today] (calendar-day
///   semantics — `knowledge/architecture/data_architecture.md`).
/// - Each score, when present, must be within 0-5 inclusive. The check-in
///   UI offers 0-5 as selectable segments, so this mainly guards
///   against a caller constructing an out-of-range value directly (e.g.
///   `DailyCheckin` built outside the dialog, or a future data-import
///   path).
///
/// All scores are optional — a check-in with every score `null` and no
/// symptoms is valid to *validate* (it's `DailyCheckin.isEmpty` that the
/// controller uses to skip actually saving it as a no-op, not this
/// function — see `presentation/checkin_controller.dart`).
CheckinValidation validateDailyCheckin({
  required LocalDate day,
  required LocalDate today,
  int? energy,
  int? sleep,
  int? soreness,
  int? stress,
  int? pain,
}) {
  return CheckinValidation(
    dayError: day.isAfter(today) ? _futureDayMessage : null,
    energyError: _scoreError(energy),
    sleepError: _scoreError(sleep),
    sorenessError: _scoreError(soreness),
    stressError: _scoreError(stress),
    painError: _scoreError(pain),
  );
}

String? _scoreError(int? value) {
  if (value == null) return null;
  return (value >= 0 && value <= 5) ? null : _outOfRangeMessage;
}

/// Result of validating a flare-up being logged or edited.
class FlareValidation {
  const FlareValidation({
    this.dayError,
    this.endDayError,
    this.severityError,
    this.impactError,
  });

  final String? dayError;

  /// Set when the flare's optional end day doesn't form a usable range with
  /// its start day — see [validateFlareEvent].
  final String? endDayError;
  final String? severityError;
  final String? impactError;

  bool get isValid =>
      dayError == null &&
      endDayError == null &&
      severityError == null &&
      impactError == null;
}

// S3: no message in this file ever interpolates a date. A flare day is
// health data and a validation message can reach a log or a crash report —
// same rule, and the same reasoning, as `core/domain/local_date.dart`'s
// `parse`. The day count in `_rangeTooLongMessage` is a fixed constant, not
// user data.
const String _futureDayMessage =
    "That hasn't happened yet — pick a day that's today or earlier.";
const String _endBeforeStartMessage =
    "Pick an end day that's on or after the first day.";
const String _rangeTooLongMessage =
    "That's a longer stretch than we can log in one go — pick up to "
    '$maxFlareRangeDays days.';

/// Validates a flare-up's required fields:
///
/// - [day] must not be in the future relative to [today].
/// - [endDay], when given (a multi-day flare — `null` means the flare
///   covers [day] only), must be on or after [day], must not be in the
///   future relative to [today], and must not put the inclusive range over
///   [maxFlareRangeDays] days. That upper bound is a wide, non-judgemental
///   sanity check on a date picker, not a claim about how long a flare-up
///   can last — see [maxFlareRangeDays]'s own dartdoc.
/// - [severity] and [impact] are required (unlike a check-in, a flare log
///   is a deliberate act, not a fast optional tap-through — see
///   `knowledge/product/terminology.md`'s "Flare" definition). Symptoms,
///   category, and notes stay optional — no diagnosis is ever required
///   (`knowledge/product/stage1_audit.md` §5.2).
FlareValidation validateFlareEvent({
  required LocalDate day,
  required LocalDate today,
  LocalDate? endDay,
  FlareSeverity? severity,
  FlareImpact? impact,
}) {
  return FlareValidation(
    dayError: day.isAfter(today) ? _futureDayMessage : null,
    endDayError: _rangeError(from: day, to: endDay, today: today),
    severityError: severity == null ? 'Pick how severe this was.' : null,
    impactError: impact == null
        ? 'Pick how this affected your training.'
        : null,
  );
}

/// The inclusive-range rule behind [FlareValidation.endDayError]. Returns
/// `null` when [to] is `null` (a single-day flare — nothing to range-check)
/// or the range is usable.
String? _rangeError({
  required LocalDate from,
  required LocalDate? to,
  required LocalDate today,
}) {
  if (to == null) return null;
  if (to.isBefore(from)) return _endBeforeStartMessage;
  // Only the range's last day can be in the future once it's known to be
  // on or after the first day.
  if (to.isAfter(today)) return _futureDayMessage;
  // Inclusive length: a range whose endpoints are the same day is 1 day.
  if (from.difference(to) + 1 > maxFlareRangeDays) {
    return _rangeTooLongMessage;
  }
  return null;
}
