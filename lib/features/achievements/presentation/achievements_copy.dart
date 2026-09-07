/// Every user-facing string and number format the trophy case renders, in
/// one file.
///
/// Two reasons it is not scattered through the widgets. The copy here is
/// held to the catalogue's rule 4 — celebration only, never obligation,
/// comparison or shortfall — and a rule that lives in eight widget files is
/// a rule nobody can check; the widget-level vocabulary sweep in
/// `test/features/achievements/achievements_screen_test.dart` reads the
/// rendered tree, and this file is what it is really guarding. And the
/// unit conversion is the presentation half of the engine's contract:
/// `BadgeProgress` speaks canonical units (metres, kilograms, minutes) and
/// says so explicitly, leaving "12 km to Silver" to be assembled here.
///
/// Nothing here ever names a date from cycle data or a value from health
/// data — a badge string is derived from counts only.
library;

import 'package:intl/intl.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

const String achievementsScreenTitle = 'My Achievements';

/// Heading of the entry point card on the Progress screen.
const String achievementsSectionTitle = 'Achievements';

const String achievementsSectionOpenLabel = 'View achievements';

/// The summary header's heading.
const String trophyCaseTitle = 'Your trophy case';

/// Shown in the header, and on the Progress card, when nothing is earned
/// yet.
///
/// The empty state of this screen is the screen: every badge is listed
/// below it at zero, with Bronze as the next rung. So the line says what is
/// true and invites, and carries no suggestion that she is late.
const String trophyCaseEmptyLine =
    'Nothing in the case yet. Every badge below is on offer, and none of '
    'them expire.';

/// Sits under the earned count once there is something in the case.
const String trophyCaseInviteLine =
    'The rest are still on offer, whenever you feel like them.';

/// The unearned marker on a one-off badge.
///
/// Not "locked" and not a checklist: a one-off happens or it does not, and
/// its description already says what it is. This is a label, not an
/// instruction.
const String oneOffPendingLabel = 'Still to come';

const String oneOffEarnedLabel = 'Earned';

/// Title of the celebration when a single badge has just been crossed.
const String newBadgeCelebrationTitle = 'A new badge';

const String newBadgesCelebrationTitle = 'New badges';

/// The affirmation under a small celebration.
const String newBadgeAffirmation = 'Earned, and yours to keep.';

/// The affirmation under the first-run summary celebration.
const String catchUpAffirmation =
    'Everything you had already done, caught up with in one go.';

const String celebrationDismissLabel = 'Wonderful';

/// The first-run flood headline: one celebration standing in for many.
String catchUpCelebrationTitle(int count) =>
    '$count achievements earned from your history so far';

/// `'7 badges earned'`, `'1 badge earned'`, or the empty line.
String earnedCountLine(int count) {
  if (count == 0) return trophyCaseEmptyLine;
  return '$count ${_plural(count, 'badge')} earned';
}

/// `'Highest tier so far: Gold'`.
String highestTierLine(BadgeTier tier) => 'Highest tier so far: ${tier.label}';

/// The hero line of a tiered badge: `'12 km to Silver'`.
///
/// Returns `null` for a one-off, which has no next rung and must not be
/// given a bar that cannot move.
String? remainingToNextLine(BadgeProgress progress) {
  final nextTier = progress.nextTier;
  final remaining = progress.remainingToNext;
  final unit = progress.definition.unit;
  if (nextTier == null || remaining == null || unit == null) return null;
  return '${formatRemainingAmount(remaining, unit)} to ${nextTier.label}';
}

/// The quiet context line under the bar: `'88 km so far'`.
String? currentValueLine(BadgeProgress progress) {
  final unit = progress.definition.unit;
  if (unit == null) return null;
  return '${formatEarnedAmount(progress.value, unit)} so far';
}

/// `'Earned 12 Sep 2026'` — the local calendar day an award was recorded.
String awardedOnLine(DateTime awardedAt) =>
    'Earned ${_dayFormat.format(awardedAt.toLocal())}';

/// How a formatted amount is allowed to be wrong by less than its own
/// precision — which, on a trophy case, is a question about honesty rather
/// than about arithmetic.
///
/// The two directions are **not interchangeable**, and a single shared
/// "round to nearest" would get each of them wrong half the time:
///
/// * An **ask** ("12 km to Silver") may only ever round *up*. Rounding it
///   down promises a rung early: she reads "11 km to Silver", runs 11 km,
///   and the badge does not arrive. Rounding up costs her nothing — the
///   rung lands a few hundred metres sooner than the label implied, which
///   is a small gift and never a broken promise.
/// * A **total** ("88 km so far") may only ever round *down*. Rounding it
///   up credits her with distance she has not run. This app does not
///   inflate what she has done, not even by 400 metres.
enum BadgeAmountRounding {
  /// Round away from zero — for an ask.
  up,

  /// Round towards zero — for something already done.
  down,
}

/// An amount still to go, in the units she reads. Never understated.
String formatRemainingAmount(double value, BadgeMetricUnit unit) =>
    formatBadgeAmount(value, unit, rounding: BadgeAmountRounding.up);

/// An amount already accumulated, in the units she reads. Never overstated.
String formatEarnedAmount(double value, BadgeMetricUnit unit) =>
    formatBadgeAmount(value, unit, rounding: BadgeAmountRounding.down);

/// A canonical-unit amount in the units she actually reads.
///
/// Metres become kilometres and minutes become hours exactly as everywhere
/// else in this app; counts stay counts. Distances and durations carry one
/// decimal below ten and go whole above it — "1,400.0 km" is precision
/// nobody asked for — and [rounding] decides which way that last digit is
/// allowed to move. Prefer [formatRemainingAmount] / [formatEarnedAmount]
/// at call sites: they name the direction, and the direction is the point.
String formatBadgeAmount(
  double value,
  BadgeMetricUnit unit, {
  required BadgeAmountRounding rounding,
}) {
  switch (unit) {
    case BadgeMetricUnit.metres:
      final km = value / 1000;
      if (km < 10) return '${_to1dp(km, rounding)} km';
      return '${_decimal.format(_toWhole(km, rounding))} km';
    case BadgeMetricUnit.kilograms:
      return '${_decimal.format(_toWhole(value, rounding))} kg';
    case BadgeMetricUnit.ascentMetres:
      // Whole metres, never converted: climbing is spoken in metres, and
      // "0.5 km to Silver" on a climb ladder is a number nobody can place.
      return '${_decimal.format(_toWhole(value, rounding))} m';
    case BadgeMetricUnit.minutes:
      if (value < 60) {
        final minutes = _toWhole(value, rounding);
        return '$minutes ${_plural(minutes, 'minute')}';
      }
      final hours = value / 60;
      if (hours == hours.roundToDouble()) {
        final whole = hours.round();
        return '$whole ${_plural(whole, 'hour')}';
      }
      return '${_to1dp(hours, rounding)} hours';
    case BadgeMetricUnit.sessions:
      final count = _toWhole(value, rounding);
      return '$count ${_plural(count, 'session')}';
    case BadgeMetricUnit.days:
      final count = _toWhole(value, rounding);
      return '$count ${_plural(count, 'day')}';
    case BadgeMetricUnit.weeks:
      final count = _toWhole(value, rounding);
      return '$count ${_plural(count, 'week')}';
    case BadgeMetricUnit.months:
      final count = _toWhole(value, rounding);
      return '$count ${_plural(count, 'month')}';
  }
}

/// Screen-reader **label** for a tiered badge's progress bar.
///
/// Deliberately not the bar's `semanticsValue`: a progress-bar semantics
/// node's value is validated as a number or a percentage (see
/// `_semanticsProgressBar` in Flutter's `semantics.dart`), so a sentence
/// there throws for exactly the users who need it most. The bar means
/// nothing read as "0.84", so the sentence goes in the label and the
/// framework's own percentage stays in the value.
///
/// Only a tiered badge has a bar — a one-off gets a chip instead
/// (`presentation/widgets/badge_tile.dart`) — and a tiered badge always has
/// a unit and a next rung, so this reads "Title. 12 km to Silver". The bare
/// title is the fallback for a definition that somehow carries no unit; it
/// deliberately says nothing about earned-or-not, which is the tier label
/// beside the crest's job.
String progressSemanticsLabel(BadgeProgress progress) {
  final title = progress.definition.title;
  final remaining = remainingToNextLine(progress);
  return remaining == null ? title : '$title. $remaining';
}

final DateFormat _dayFormat = DateFormat('d MMM yyyy');
final NumberFormat _decimal = NumberFormat.decimalPattern();

/// One decimal place in [rounding]'s direction, with a trailing `.0`
/// trimmed: `11.6`, `4`, `2.5`.
String _to1dp(double value, BadgeAmountRounding rounding) {
  final tenths = switch (rounding) {
    BadgeAmountRounding.up => (value * 10).ceil(),
    BadgeAmountRounding.down => (value * 10).floor(),
  };
  if (tenths % 10 == 0) return '${tenths ~/ 10}';
  return (tenths / 10).toStringAsFixed(1);
}

int _toWhole(double value, BadgeAmountRounding rounding) => switch (rounding) {
  BadgeAmountRounding.up => value.ceil(),
  BadgeAmountRounding.down => value.floor(),
};

String _plural(int count, String singular) =>
    count == 1 ? singular : '${singular}s';
