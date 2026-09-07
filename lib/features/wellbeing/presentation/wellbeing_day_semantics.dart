import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';

/// What one wellbeing-calendar day says to a screen reader.
///
/// The grid encodes what is logged as three small glyphs. None of that
/// survives being read out, so a day carrying anything has to say so in
/// words.
///
/// Two properties of this label are deliberate:
///
/// - It is **not** gated behind the Enhanced Semantics preference. It is at
///   most three short clauses, and only days that actually carry something
///   get one at all (see [wellbeingDaySemanticLabel] returning `null`), so
///   there is no verbosity to protect anyone from.
/// - Everything it states is a **fact the user logged**, never an
///   estimate, so nothing here is hedged or carries a confidence — and
///   nothing interprets what was logged.
///
/// Pure and free of Flutter so it can be unit-tested as text, which is the
/// only form it is ever consumed in.
///
/// Returns `null` for a day with nothing on it, which leaves the cell
/// announcing its bare day number — the same thing a sighted user sees.
String? wellbeingDaySemanticLabel({
  required LocalDate date,
  required bool isToday,
  required bool hasCheckin,
  required bool hasFlare,
  required bool isRecoveryDay,
}) {
  final logged = hasCheckin || hasFlare || isRecoveryDay;
  if (!logged && !isToday) return null;

  final formatted = _longDate(date);
  final parts = <String>[
    if (isToday) 'Today, $formatted' else formatted,
    if (hasCheckin) 'check-in logged',
    if (hasFlare) 'flare-up',
    if (isRecoveryDay) 'recovery day',
    // Only ever reached for today (a bare past day returns null above, and
    // nothing can be logged on a future one), so the cell a user lands on
    // first still describes itself. Never phrased as something missed.
    if (!logged) 'nothing logged',
  ];
  return '${parts.join(', ')}.';
}

String _longDate(LocalDate date) =>
    DateFormat('EEEE d MMMM').format(DateTime(date.year, date.month, date.day));
