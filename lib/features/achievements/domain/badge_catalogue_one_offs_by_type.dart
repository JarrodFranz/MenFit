/// The per-activity-type half of the one-off catalogue — see
/// `domain/badge_catalogue.dart` for the rules, and
/// `domain/badge_catalogue_one_offs.dart` for the eleven that came first.
///
/// The original one-offs marked firsts for the two disciplines that had
/// dedicated tracking (strength, mindful movement) and then ran on
/// curiosities that any activity could satisfy. That left a woman whose
/// sport is walking, hiking, riding, intervals or swimming with no *first*
/// of her own to mark — the moment that most deserves marking, missing for
/// most of the app's activity types.
///
/// So each of those five types gets its first, and one further milestone
/// it can genuinely reach: a distance in a single outing, or a session
/// made deliberately long. Two rules held throughout:
///
/// * **A single session, never a total.** Totals are what the ladders are
///   for, and a one-off that is secretly a small ladder is the worst of
///   both.
/// * **Reachable without a phone strapped to her.** Every mark here except
///   the climb badge is computable from a hand-logged session, because
///   most sessions are hand-logged. The climb one-off is the deliberate
///   exception (`domain/badge_metrics.dart#ascentOf`), and it is nobody's
///   only second badge — every type it applies to has another.
///
/// Yoga and pilates keep sharing First Stillness rather than being given
/// a first each: their first mindful session genuinely is one moment, and
/// splitting it in two would have made the shared badge a lie. They get an
/// hour-long-session badge apiece instead.
library;

import 'package:menfit_app/features/achievements/domain/badge_definition.dart';

const List<BadgeDefinition> perTypeOneOffBadgeDefinitions = [
  BadgeDefinition.oneOff(
    id: 'first_walk',
    title: 'Out the Door',
    description: 'Your first logged walk.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.firstWalkSession,
  ),

  BadgeDefinition.oneOff(
    id: 'long_walk',
    title: 'The Long Way Round',
    description: 'A single walk that reached 10 kilometres.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.tenKilometreWalk,
  ),

  BadgeDefinition.oneOff(
    id: 'first_hike',
    title: 'First Trail',
    description: 'Your first logged hike.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.firstHikeSession,
  ),

  BadgeDefinition.oneOff(
    id: 'long_hike',
    title: 'Fifteen on the Trail',
    description: 'A single hike that reached 15 kilometres.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.fifteenKilometreHike,
  ),

  // Any activity type, not just hikes: a hilly ride or a run up the same
  // hill is the same 500 metres, and the badge would be an odd thing to
  // withhold on the grounds that she called it something else.
  BadgeDefinition.oneOff(
    id: 'big_climb_session',
    title: 'Five Hundred Up',
    description: 'A single session with 500 metres of climbing recorded in it.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.fiveHundredMetreClimb,
  ),

  BadgeDefinition.oneOff(
    id: 'first_ride',
    title: 'First Ride Out',
    description: 'Your first logged ride.',
    category: BadgeCategory.cycling,
    condition: BadgeCondition.firstRideSession,
  ),

  BadgeDefinition.oneOff(
    id: 'long_ride',
    title: 'Twenty-Five Kilometres',
    description: 'A single ride that reached 25 kilometres.',
    category: BadgeCategory.cycling,
    condition: BadgeCondition.twentyFiveKilometreRide,
  ),

  BadgeDefinition.oneOff(
    id: 'first_hiit_session',
    title: 'First Intervals',
    description: 'Your first logged interval session.',
    category: BadgeCategory.intervals,
    condition: BadgeCondition.firstHiitSession,
  ),

  // Twenty rounds rather than "all the rounds you planned": a session
  // created by hand stores its planned rounds as its completed ones, so
  // "finished what she started" would fire on every hand-logged session
  // and mean nothing. A round count is a thing she chose either way.
  BadgeDefinition.oneOff(
    id: 'twenty_interval_rounds',
    title: 'Twenty Rounds',
    description: 'An interval session with twenty rounds completed in it.',
    category: BadgeCategory.intervals,
    condition: BadgeCondition.twentyIntervalRounds,
  ),

  BadgeDefinition.oneOff(
    id: 'first_swim',
    title: 'First Length',
    description: 'Your first logged swim.',
    category: BadgeCategory.swimming,
    condition: BadgeCondition.firstSwimSession,
  ),

  BadgeDefinition.oneOff(
    id: 'long_swim',
    title: 'A Kilometre in the Water',
    description: 'A single swim that reached 1,000 metres.',
    category: BadgeCategory.swimming,
    condition: BadgeCondition.oneKilometreSwim,
  ),

  BadgeDefinition.oneOff(
    id: 'hour_of_yoga',
    title: 'An Hour of Yoga',
    description: 'A single yoga session that ran for an hour.',
    category: BadgeCategory.mindfulness,
    condition: BadgeCondition.hourLongYogaSession,
  ),

  BadgeDefinition.oneOff(
    id: 'hour_of_pilates',
    title: 'An Hour of Pilates',
    description: 'A single pilates session that ran for an hour.',
    category: BadgeCategory.mindfulness,
    condition: BadgeCondition.hourLongPilatesSession,
  ),
];
