import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';

/// Whether today's logged wellbeing data is "significant" enough to
/// warrant offering the recovery-decision prompt (§5.9 of the product
/// handover spec, positively framed — see
/// `presentation/recovery_prompt_sheet.dart`).
///
/// Deliberately a pure function taking already-loaded values rather than
/// reading providers itself, so it's unit-testable without Riverpod (same
/// reasoning as `features/streaks/domain/streak_assembly.dart`).
///
/// True when any of:
/// - [DailyCheckin.pain] is 4 or 5 ("high pain" - pain is stored 1-5, higher
///   is worse, see `daily_checkin.dart`),
/// - [DailyCheckin.energy] is 1 or 2 ("low energy" - energy is stored 1-5,
///   higher is better),
/// - any of [todaysFlares] has an [FlareEvent.impact] other than
///   [FlareImpact.none] (i.e. [FlareImpact.reducedTraining] or
///   [FlareImpact.unableToTrain] both count here - note this is
///   deliberately *broader* than `streak_assembly.dart`'s protection rule,
///   which only auto-protects on [FlareImpact.unableToTrain]: *offering*
///   the recovery choice for a lesser impact is still worth surfacing, even
///   though it won't auto-protect until the user actually accepts it).
///
/// A `null` [checkin] (nothing logged yet) never triggers this on its own -
/// only [todaysFlares] can.
bool hasSignificantSymptoms(
  DailyCheckin? checkin,
  List<FlareEvent> todaysFlares,
) {
  if (checkin != null) {
    final pain = checkin.pain;
    if (pain != null && pain >= 4) return true;

    final energy = checkin.energy;
    if (energy != null && energy <= 2) return true;
  }

  return todaysFlares.any((flare) => flare.impact != FlareImpact.none);
}

/// The typed outcome of [evaluateRecoveryPromptEligibility] — F2
/// (review-recommended): a plain `bool` couldn't distinguish *why* the
/// prompt isn't warranted, which made the widget-level bugs this replaces
/// (offering it for a past-day edit; missing a flare-only trigger) hard to
/// even write a regression test against. Only [offer] means "show the
/// prompt" — every other value is a distinct reason not to.
enum RecoveryPromptDecision {
  /// The prompt should be shown.
  offer,

  /// [DailyCheckin.day]/the day being evaluated isn't today. Past-day
  /// edits (e.g. from the wellbeing history screen) never prompt — the
  /// prompt is about a same-day training decision, not a retroactive one.
  notToday,

  /// Today's [DayStatus] is already something other than
  /// [DayStatus.unscheduled] (already active, or already protected) —
  /// nothing left to offer.
  alreadyCovered,

  /// The user already dismissed the prompt once this session for this day
  /// (`presentation/recovery_prompt_dismissal_controller.dart`).
  alreadyDismissed,

  /// Nothing significant enough was logged today
  /// ([hasSignificantSymptoms] is `false`).
  notSignificant,
}

/// Decides whether the §5.9 recovery-decision prompt should be offered for
/// a just-saved check-in — the single source of truth for the whole
/// eligibility check, replacing the logic that used to live inline in
/// `presentation/checkin_sheet.dart`'s `_maybeOfferRecoveryDay` (F2).
///
/// Deliberately a pure function taking already-loaded values (same
/// reasoning as [hasSignificantSymptoms] and
/// `features/streaks/domain/streak_assembly.dart`): every input the
/// decision depends on is a plain parameter, so the full matrix is
/// unit-testable without Riverpod, Drift, or a widget tree. The actual
/// data-fetching (today's flares, today's [DayStatus], dismissal state)
/// lives in `presentation/recovery_prompt_controller.dart`'s
/// `RecoveryPromptController` — the async, repository-touching orchestration
/// this function's callers need but this function itself must never do.
///
/// Checks run in this order, each one a distinct short-circuit
/// ([RecoveryPromptDecision] documents why):
/// 1. [isToday] — false for any past-day edit.
/// 2. [todayStatus] — must be [DayStatus.unscheduled].
/// 3. [alreadyDismissed] — this session, for this day.
/// 4. [hasSignificantSymptoms] on ([checkin], [todaysFlares]).
RecoveryPromptDecision evaluateRecoveryPromptEligibility({
  required DailyCheckin? checkin,
  required List<FlareEvent> todaysFlares,
  required DayStatus todayStatus,
  required bool alreadyDismissed,
  required bool isToday,
}) {
  if (!isToday) return RecoveryPromptDecision.notToday;
  if (todayStatus != DayStatus.unscheduled) {
    return RecoveryPromptDecision.alreadyCovered;
  }
  if (alreadyDismissed) return RecoveryPromptDecision.alreadyDismissed;
  if (!hasSignificantSymptoms(checkin, todaysFlares)) {
    return RecoveryPromptDecision.notSignificant;
  }
  return RecoveryPromptDecision.offer;
}
