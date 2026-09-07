/// Every user-facing string and number format the buddy-challenge
/// surfaces render, in one file.
///
/// Same reasoning as `features/achievements/presentation/achievements_copy.dart`
/// and `features/weight/presentation/weight_copy.dart`: the rules this
/// copy is held to are strong enough that a rule living in nine widget
/// files is a rule nobody can check. The widget-level vocabulary sweep in
/// `test/features/challenges/challenges_screen_test.dart` reads the
/// rendered tree, and this file is what it is really guarding.
///
/// ## The two rules every string here obeys
///
/// 1. **No ranking exists.** Nothing may say — or imply — that one person
///    is winning, losing, ahead, behind, or being beaten. The domain
///    layer makes a leader *unrepresentable*
///    (`domain/challenge_progress.dart`: participants expose a name, a
///    percentage and "did they reach their own goal", and nothing else), and
///    the copy must not smuggle back in what the model refuses to hold.
///    The two percentages measure different, privately-adjusted targets,
///    so ranking them would not even be arithmetic — but the rule stands
///    regardless of the arithmetic.
/// 2. **Nothing cycle-related appears on any challenge surface, ever.**
///    Not a phase, not a period, not a flare, not a recovery day, and not
///    a number any of those could be read out of. A buddy may well be
///    looking at this screen over their shoulder — that is the whole
///    premise of the feature. [fairnessNote] is the one sentence allowed
///    to acknowledge that targets flex, and it says so without naming
///    what makes them flex.
///
/// Percentages above 100 are rendered matter-of-factly ("112%"): going
/// past your own goal is a thing that happens, and clamping it would
/// quietly delete the best part.
library;

import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';

// ---------------------------------------------------------------------------
// Screen titles and entry points
// ---------------------------------------------------------------------------

const String challengesScreenTitle = 'Buddy challenges';

/// Heading of the entry-point card on the Progress screen. Deliberately
/// the same words as the screen it opens — a card and its destination
/// with two different names is two features as far as the reader is
/// concerned.
const String challengesSectionTitle = challengesScreenTitle;

const String challengesSectionOpenLabel = 'View challenges';

const String startChallengeLabel = 'Start a challenge';

const String joinChallengeLabel = 'Join with a code';

const String activeChallengesHeading = 'On the go';

const String finishedChallengesHeading = 'Finished';

/// The empty state. An invitation and a description — no suggestion that
/// they are late to something, and no second sentence nudging them to act.
const String challengesEmptyLine =
    'Nothing on the go. A challenge is a shared plan with a friend: you '
    'pick something together, and you each aim at your own version of it.';

/// `'2 on the go'`, `'1 on the go'`.
String activeChallengeCountLine(int count) => '$count on the go';

// ---------------------------------------------------------------------------
// Describing a challenge
// ---------------------------------------------------------------------------

/// The headline figure: `'100 km'` or `'12 sessions'`.
String challengeTargetLine(ChallengeBlueprint blueprint) =>
    switch (blueprint.kind) {
      ChallengeKind.totalDistance => formatTargetDistance(
        blueprint.targetUnits,
      ),
      ChallengeKind.sessionCount =>
        '${blueprint.targetUnits} '
            '${_plural(blueprint.targetUnits, 'session')}',
    };

// There is deliberately no "42.3 km so far" line in this file any more,
// and adding one back to a challenge surface needs the argument in
// `knowledge/engineering/security_and_privacy.md` re-opened first. A
// surface showing their raw work *and* their percentage *and* the shared
// target *and* the window states four numbers from which their
// protected-day count follows by arithmetic — see the co-presence rule
// pinned by `test/features/challenges/challenge_surfaces_privacy_test.dart`
// and the class doc on `challenge_detail_screen.dart`. Their raw distance
// belongs where it always was: in their activity history, on a screen that
// says nothing about a challenge.

/// Shown when a challenge counts every activity type.
const String anyActivityLabel = 'Anything you log';

/// `'Run and Walk'`, `'Run, Ride and Swim'`, or [anyActivityLabel].
///
/// Ordered by [codeActivityTypes] rather than by set iteration order, so
/// the same challenge reads identically on both devices.
String challengeActivityLine(Set<ActivityType> activityTypes) {
  if (activityTypes.isEmpty) return anyActivityLabel;
  final labels = [
    for (final type in codeActivityTypes)
      if (activityTypes.contains(type)) type.label,
  ];
  if (labels.length == 1) return labels.single;
  return '${labels.sublist(0, labels.length - 1).join(', ')} and '
      '${labels.last}';
}

/// `'1 Sep – 30 Sep 2026'`, or both years when the window crosses one.
String challengeWindowLine(LocalDate start, LocalDate end) {
  final startText = start.year == end.year
      ? _dayMonth.format(_asDateTime(start))
      : _dayMonthYear.format(_asDateTime(start));
  return '$startText – ${_dayMonthYear.format(_asDateTime(end))}';
}

/// `'1 Sep'` — a single day, for "as of" lines and date-picker rows.
String challengeDayLabel(LocalDate day) => _dayMonth.format(_asDateTime(day));

const String createdOriginLine = 'You started this one';

const String joinedOriginLine = 'You joined this one';

String originLine(ChallengeOrigin origin) => switch (origin) {
  ChallengeOrigin.created => createdOriginLine,
  ChallengeOrigin.joined => joinedOriginLine,
};

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

/// The label for the user's own row. "You", never their display name: the
/// name they chose is for their buddy's screen, not their own.
const String selfLabel = 'You';

/// `'112%'`. Floored, never capped — see the library doc.
String formatPercent(double percent) {
  if (!percent.isFinite) return '0%';
  final whole = percent.floor();
  return '${whole < 0 ? 0 : whole}%';
}

/// `'as of 12 Sep'` — said plainly, because a number from last Tuesday
/// presented as today's would be a small lie in a feature whose whole
/// point is trust.
String buddyAsOfLine(LocalDate asOf) => 'as of ${challengeDayLabel(asOf)}';

/// The buddy's standing on a list card, as a sentence:
/// `'Sam: 48% of their own goal · as of 12 Sep'`.
///
/// A sentence rather than a second progress bar, and that is the whole
/// point of it — see the class doc on
/// `presentation/widgets/challenge_card.dart`. "of their own goal" is
/// carried in the visible text rather than left to the screen reader,
/// because the number beside a bar of the user's own is exactly where a
/// reader supplies the comparison the two figures do not support.
String buddyCardLine(String displayName, double percent, LocalDate asOf) =>
    '$displayName: ${formatPercent(percent)} of their own goal · '
    '${buddyAsOfLine(asOf)}';

String selfProgressSemanticsLabel(double percent) =>
    'You: ${formatPercent(percent)} of your own goal.';

String buddyProgressSemanticsLabel(String displayName, double percent) =>
    '$displayName: ${formatPercent(percent)} of their own goal.';

/// Said about them, alone. There is deliberately no counterpart that
/// mentions both people unless [bothReachedLine] applies.
const String selfReachedLine = 'You reached your goal.';

String buddyReachedLine(String displayName) => '$displayName reached theirs.';

const String bothReachedTitle = 'You both got there';

const String bothReachedLine =
    'You each reached your own goal. That was the whole idea.';

/// The one place the pro-rating is explained, in words and never in
/// numbers.
///
/// It says that each target is personal and that it flexes. It does not
/// say what makes it flex, and it never will: a sentence naming cycles,
/// periods or flares on a screen built to be shown to a friend would
/// hand over exactly the thing `domain/challenge_codes.dart`'s privacy
/// invariant exists to keep on this device.
const String fairnessNote =
    'Each of you measures against your own target, which quietly makes '
    'room for rest days.';

// ---------------------------------------------------------------------------
// Creating
// ---------------------------------------------------------------------------

const String createChallengeTitle = 'Start a challenge';

const String kindFieldLabel = 'What counts';

const String kindDistanceLabel = 'Distance';

const String kindSessionsLabel = 'Sessions';

const String activityTypesFieldLabel = 'Which activities';

const String activityTypesHelper = 'Pick none and anything you log counts.';

const String distanceFieldLabel = 'How far (km)';

const String sessionsFieldLabel = 'How many sessions';

const String windowFieldLabel = 'Dates';

const String windowPickLabel = 'Change';

const String windowPickHelpText = 'Which days does this run over?';

const String displayNameFieldLabel = 'Your name for this challenge';

const String displayNameHelper = 'This is the name your buddy will see.';

const String createSubmitLabel = 'Create and get the code';

const String challengeCreatedTitle = 'Here is your code';

const String challengeCreatedLine =
    'Send it to your buddy. They paste it into Join with a code, and you '
    'are both in the same challenge.';

/// The plain-language half of the privacy invariant, on the screen that
/// hands out a challenge code.
const String challengeCodePrivacyNote =
    'The code describes the challenge itself — what it asks for and which '
    'days it runs. Your name and your numbers are not in it.';

const String copyCodeLabel = 'Copy code';

/// Hands the code to the OS share sheet. A peer of [copyCodeLabel], not a
/// replacement for it: Windows share fails on some editions and desktop
/// Firefox has no Web Share API at all, so both actions are offered
/// side by side and labelled for what they each do (ADR 011).
const String shareCodeLabel = 'Share code';

const String codeCopiedMessage = 'Code copied.';

const String doneLabel = 'Done';

// ---------------------------------------------------------------------------
// Joining
// ---------------------------------------------------------------------------

const String joinChallengeTitle = 'Join with a code';

const String joinCodeFieldLabel = 'Paste the code';

const String joinCodeHelper = 'It starts with FC1.';

const String joinSubmitLabel = 'Join this challenge';

const String joinedMessage = "You're in.";

const String alreadyJoinedMessage =
    'You already have this one — it is on your list.';

/// What a code turned out to describe, shown live under the paste field
/// so they can see they have the right one before they commit.
String joinCodePreviewLine(ChallengeBlueprint blueprint) =>
    '${challengeTargetLine(blueprint)} · '
    '${challengeActivityLine(blueprint.activityTypes)} · '
    '${challengeWindowLine(blueprint.windowStart, blueprint.windowEnd)}';

/// Why a pasted **challenge** code could not be used, in human terms.
///
/// Every branch is honest about whose problem it is and what to do next.
/// None of them says "invalid", "error" or "checksum": someone who was
/// sent a code by a friend has done nothing wrong, and a technical word
/// here would only make them feel they had.
String joinCodeRejectionMessage(CodeRejection rejection) => switch (rejection) {
  CodeRejection.malformed =>
    "That doesn't look like a challenge code yet. Paste the whole "
        'thing, including the part before the dot.',
  CodeRejection.unsupportedVersion =>
    'That code came from a newer version of the app. Update, and it '
        'will open.',
  CodeRejection.wrongCodeKind =>
    'That is a progress code. Ask your buddy for the challenge code '
        'they got when they set it up.',
  CodeRejection.checksumFailed =>
    'That code looks damaged — a character probably went astray on '
        'the way. Ask for it again.',
  CodeRejection.unsupportedContent =>
    'That code mentions something this version of the app does not '
        'know about yet. Update, and it will open.',
};

// ---------------------------------------------------------------------------
// Detail, buddy import and progress export
// ---------------------------------------------------------------------------

const String challengeDetailTitle = 'Challenge';

const String buddySectionHeading = 'Your buddy';

const String buddyEmptyLine =
    'Nothing pasted yet. Whenever they send their progress code, it goes in '
    'here — and a challenge runs just fine without one.';

const String pasteBuddyCodeLabel = 'Paste their latest code';

const String buddyCodeFieldLabel = 'Their progress code';

const String buddyCodeHelper = 'It starts with FP1.';

const String importBuddyCodeLabel = 'Add it';

String buddyImportedMessage(String displayName) =>
    "Updated with $displayName's latest.";

const String buddyNotNewerMessage = 'You already have this one.';

/// Their own progress code, pasted back into their own buddy box.
///
/// Says whose code it is and what to do with it, in that order, and does
/// not call it a mistake: pasting the wrong one of two very similar
/// strings is not a mistake anyone needs telling off for.
const String buddyOwnCodeMessage =
    "That's your own progress code — send it to them, and paste theirs here.";

const String buddyUnknownChallengeMessage =
    'That code belongs to a different challenge. Open that one and paste '
    'it there.';

/// Why a pasted **progress** code could not be used. Identical to
/// [joinCodeRejectionMessage] apart from the one branch whose direction
/// is reversed — here the likely mistake is pasting the challenge code
/// into the progress box.
String progressCodeRejectionMessage(CodeRejection rejection) =>
    switch (rejection) {
      CodeRejection.wrongCodeKind =>
        'That is the challenge code, not a progress code. Ask them for the '
            'one from their own Share my progress button.',
      _ => joinCodeRejectionMessage(rejection),
    };

const String shareProgressLabel = 'Share my progress';

const String progressCodeTitle = 'Your progress code';

const String progressCodeLine =
    'Send this to your buddy so they can see how you are getting on.';

/// The plain-language half of the privacy invariant, on the one screen
/// that hands out something derived from their own data.
///
/// It lists the whole contents of the code, because the whole contents
/// is four things — see `domain/challenge_codes.dart`.
const String progressCodePrivacyNote =
    'The code says which challenge it is for, the name you chose, your '
    'percentage and the date. Nothing else — not your distances, not '
    'your sessions, not your days off.';

// ---------------------------------------------------------------------------
// Leaving a challenge
// ---------------------------------------------------------------------------

/// The way out of one challenge, as opposed to Settings' "Delete my data"
/// which takes everything (privacy rules 7 and 8: what they can put in,
/// they can take out, one item at a time).
const String leaveChallengeLabel = 'Leave this challenge';

const String leaveChallengeTitle = 'Leave this challenge?';

/// What leaving actually does, in the two facts they need before they tap.
///
/// It names the buddy's name as one of the things that goes, because that
/// is the part someone leaving a challenge with someone they no longer
/// want a record of is really asking about. It restates **no numbers** —
/// not the target, not their percentage, not their buddy's: a confirm dialog
/// is not a place to put a scoreline, least of all on the way out.
const String leaveChallengeBody =
    'This challenge leaves this phone permanently, and your buddy’s name '
    'goes with it. They keep their own copy on theirs.';

const String leaveChallengeConfirmLabel = 'Leave';

const String leaveChallengeCancelLabel = 'Keep it';

const String leftChallengeMessage = 'Left the challenge.';

/// Shown when the challenge a screen was holding is no longer there —
/// left from another window, or wiped by "Delete my data" while this
/// screen was open. A sentence and a way back, never a blank page.
const String challengeGoneLine =
    'This challenge is not on this phone any more.';

const String challengeGoneBackLabel = 'Back to your challenges';

// ---------------------------------------------------------------------------
// The shared celebration card
// ---------------------------------------------------------------------------

const String celebrationSheetTitle = 'You both got there 🌟';

const String celebrationCardFormatLabel = 'Card format';

const String celebrationStoryLabel = 'Story (9:16)';

const String celebrationSquareLabel = 'Square (1:1)';

/// Opens the celebration sheet from the detail screen.
const String celebrationOpenLabel = 'See your card';

/// Copies the card's text, inside the sheet.
const String celebrationShareLabel = 'Copy card text';

/// Hands the same card text to the OS share sheet. Text, not the card
/// image: the image carries both names, and the sheet's own copy has
/// always been the thing they send.
const String celebrationSystemShareLabel = 'Share card text';

const String celebrationCopiedMessage = 'Copied, ready to send.';

const String celebrationCardFooter = 'Built for the work · MenFit';

/// `'Alex & Sam'` — two names, joined by an ampersand and nothing that
/// puts one of them first in any sense that means anything. The user's
/// own name leads only because it is their card.
String celebrationNamesLine(String selfDisplayName, String buddyDisplayName) =>
    '$selfDisplayName & $buddyDisplayName';

/// The clipboard text for a shared celebration.
///
/// Both names, one sentence, no ordering between them — the same
/// constraint the on-screen card is under, applied to the surface that
/// actually leaves the phone.
String celebrationShareText({
  required String selfDisplayName,
  required String buddyDisplayName,
  required ChallengeBlueprint blueprint,
}) {
  return '$selfDisplayName and $buddyDisplayName each reached their own '
      'goal — ${challengeTargetLine(blueprint)}, '
      '${challengeActivityLine(blueprint.activityTypes)}, '
      '${challengeWindowLine(blueprint.windowStart, blueprint.windowEnd)}.\n'
      '#MenFit';
}

// ---------------------------------------------------------------------------
// Number formatting
// ---------------------------------------------------------------------------

/// A challenge target (hundreds of metres) as kilometres: `'100 km'`,
/// `'42.2 km'`.
///
/// Exact by construction — the stored unit *is* a tenth of a kilometre,
/// so this conversion never rounds.
String formatTargetDistance(int targetUnits) {
  if (targetUnits % 10 == 0) return '${targetUnits ~/ 10} km';
  return '${(targetUnits / 10).toStringAsFixed(1)} km';
}

/// The number only, for the create screen's text field: `'100'`,
/// `'42.2'`.
String formatTargetDistanceValue(int targetUnits) {
  if (targetUnits % 10 == 0) return '${targetUnits ~/ 10}';
  return (targetUnits / 10).toStringAsFixed(1);
}

/// Kilometres typed by the user as the stored unit (hundreds of metres).
///
/// The one conversion in this feature that can be wrong in a way nobody
/// notices until two people compare targets, so it is pinned by
/// `challenges_copy_test.dart` in both directions.
int distanceUnitsFromKm(double km) => (km * 10).round();

/// Parses a distance field's text into kilometres.
///
/// Returns `null` for empty input and [double.nan] for something typed
/// that is not a number, so the caller can tell "blank" from "not a
/// number" — the same contract and comma-as-decimal tolerance as
/// `features/weight/presentation/weight_format.dart#parseWeightInput`.
double? parseDistanceInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed.replaceAll(',', '.')) ?? double.nan;
}

/// Parses a session-count field's text. Same null/NaN contract as
/// [parseDistanceInput]; a decimal is not a number of sessions, so
/// anything that is not a whole number reads as NaN.
double? parseSessionInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final parsed = int.tryParse(trimmed);
  return parsed?.toDouble() ?? double.nan;
}

final DateFormat _dayMonth = DateFormat('d MMM');
final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');

DateTime _asDateTime(LocalDate day) => DateTime(day.year, day.month, day.day);

String _plural(int count, String singular) =>
    count == 1 ? singular : '${singular}s';
