import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';

/// What a calendar day says to a screen reader when **Enhanced Semantics**
/// is on.
///
/// The month grid encodes everything it knows in colour and shape — a
/// solid dot for a logged period, a dotted ring for a predicted one, a
/// small tinted dot for the estimated phase. None of that survives being
/// read out; without this the whole calendar announces as bare numbers,
/// "1", "2", "3", and a user on TalkBack or VoiceOver gets a grid of dates
/// with none of the information the grid exists to carry.
///
/// Copy is held to `knowledge/domain/womens_health.md`: a logged period is
/// stated as fact because the user logged it, and **everything else is
/// named as an estimate and carries the prediction's confidence**, because
/// phase estimation beyond "a period is logged now" is prediction. Nothing
/// here interprets, advises, or implies a medical meaning for a phase.
///
/// Pure and free of Flutter so it can be unit-tested as text, which is the
/// only form it is ever consumed in.
String cycleDaySemanticLabel({
  required DayCycleStatus status,
  required bool isToday,
  required CycleConfidence confidence,
}) {
  final date = _longDate(status.date);
  final day = status.cycleDayNumber;

  final parts = <String>[
    if (isToday) 'Today, $date' else date,
    if (status.isLoggedPeriod) ...[
      'Period logged',
      if (day != null) 'cycle day $day',
    ] else if (status.isPredictedPeriod) ...[
      'Predicted period day, an estimate',
      confidence.spokenLabel,
    ] else if (status.isOvulationDay) ...[
      'Estimated ovulation day',
      confidence.spokenLabel,
    ] else if (status.phase == CyclePhase.none)
      'No cycle data'
    else ...[
      'Estimated ${status.phase.label.toLowerCase()} phase',
      confidence.spokenLabel,
    ],
  ];
  return '${parts.join('. ')}.';
}

String _longDate(LocalDate date) =>
    DateFormat('EEEE d MMMM').format(DateTime(date.year, date.month, date.day));
