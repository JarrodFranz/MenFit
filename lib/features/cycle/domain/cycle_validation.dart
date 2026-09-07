import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Result of validating a period being logged or edited.
///
/// A typed result value, not an exception — same convention as
/// `features/onboarding/presentation/onboarding_controller.dart` and
/// `features/activity/presentation/manual_entry_controller.dart`'s
/// `*Error` state fields.
class CycleRecordValidation {
  const CycleRecordValidation({this.startError, this.endError});

  /// Set when [validateCycleRecord]'s [LocalDate] start-date checks fail.
  final String? startError;

  /// Set when the end-date checks fail, *or* when the range overlaps
  /// another logged period — overlap is surfaced against the end field
  /// since it's usually the field the user is still adjusting when the
  /// overlap becomes resolvable.
  final String? endError;

  bool get isValid => startError == null && endError == null;
}

/// Validates a period's start/end against the domain rules (see
/// `knowledge/domain/womens_health.md`, `knowledge/architecture/
/// data_architecture.md`'s calendar-day semantics section):
///
/// - [periodStart] must not be in the future relative to [today].
/// - [periodEnd], when set, must be on or after [periodStart] and must not
///   be in the future.
/// - The resulting range must not overlap any other non-deleted record in
///   [existingRecords] — an ongoing record (`null` end) is treated as
///   covering every day from its start onward with no upper bound for the
///   purpose of this check, since its true end isn't known yet.
///   [excludingId] excludes the record being edited from that check, so
///   re-saving a record against its own prior state never self-rejects.
CycleRecordValidation validateCycleRecord({
  required LocalDate periodStart,
  required LocalDate today,
  required List<CycleRecord> existingRecords,
  LocalDate? periodEnd,
  String? excludingId,
}) {
  String? startError;
  String? endError;

  if (periodStart.isAfter(today)) {
    startError =
        "That hasn't happened yet — pick a start date that's today or "
        'earlier.';
  }

  if (periodEnd != null) {
    if (periodEnd.isBefore(periodStart)) {
      endError = 'The end date must be on or after the start date.';
    } else if (periodEnd.isAfter(today)) {
      endError =
          "That hasn't happened yet — pick an end date that's today or "
          'earlier.';
    }
  }

  if (startError == null && endError == null) {
    final overlaps = existingRecords.any((other) {
      if (other.id == excludingId) return false;
      return _rangesOverlap(
        periodStart,
        periodEnd,
        other.periodStart,
        other.periodEnd,
      );
    });
    if (overlaps) {
      endError =
          "This overlaps with a period you've already logged — adjust the "
          "dates so they don't overlap.";
    }
  }

  return CycleRecordValidation(startError: startError, endError: endError);
}

/// Whether `[aStart, aEnd]` and `[bStart, bEnd]` share any day, where a
/// `null` end means "unbounded going forward" (an ongoing period).
bool _rangesOverlap(
  LocalDate aStart,
  LocalDate? aEnd,
  LocalDate bStart,
  LocalDate? bEnd,
) {
  return _lessOrEqualUnbounded(aStart, bEnd) &&
      _lessOrEqualUnbounded(bStart, aEnd);
}

/// `a <= bound`, treating a `null` bound as positive infinity.
bool _lessOrEqualUnbounded(LocalDate a, LocalDate? bound) {
  return bound == null || !a.isAfter(bound);
}
