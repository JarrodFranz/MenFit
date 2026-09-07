/// The per-activity-type half of the tiered catalogue — see
/// `domain/badge_catalogue.dart` for the rules all badges are held to, and
/// `domain/badge_catalogue_tiered.dart` for the twelve ladders that came
/// first and for the threshold philosophy these follow.
///
/// ## Why a second tiered file
///
/// The original twelve were the app-wide ladders: total sessions, total
/// running, tonnage, minutes on the mat. They left whole activity types
/// with no ladder of their own — a woman who walks and swims and does
/// nothing else progressed on exactly one badge. These seven give every
/// `ActivityType` a ladder that is about *her* sport rather than about
/// sport in general. They are additions only: nothing in the first file
/// moved, and no shipped id, metric or threshold changed (rule 1).
///
/// ## The cadences behind the numbers
///
/// Same calibration as the first file — **Bronze within a few weeks** of
/// ordinary practice, Gold about a season and a bit, Platinum around a
/// year, **Diamond I a year or more past that**, and the diamond rule
/// carrying on from there. What differs per badge is the assumed cadence,
/// because "ordinary" is a different number for a swimmer than for a
/// walker; each cadence and its arithmetic is written above its ladder.
library;

import 'package:menfit_app/features/achievements/domain/badge_definition.dart';

const List<BadgeDefinition> perTypeTieredBadgeDefinitions = [
  // Cadence assumed: 20 km of walking a week (~1,040 km/year), a little
  // above the 15 km the weekly-consistency badge asks for, because a
  // walker keeping a lifetime total is usually walking more than the bar.
  // Bronze 50 km = 2.5 weeks; Silver 200 km = 10 weeks (~2 months); Gold
  // 600 km = 30 weeks (~7 months); Platinum 1,200 km = 60 weeks (~14
  // months); Diamond I 3,000 km = 150 weeks (~2.9 years), then 2,000 km
  // (~1.9 years) per diamond level.
  BadgeDefinition.tiered(
    id: 'walk_distance',
    title: 'One Foot in Front',
    description: 'Every kilometre you have walked, added up since your first.',
    category: BadgeCategory.movement,
    metric: BadgeMetric.lifetimeWalkDistanceMetres,
    unit: BadgeMetricUnit.metres,
    ladder: BadgeLadder(
      bronze: 50000,
      silver: 200000,
      gold: 600000,
      platinum: 1200000,
      diamond: 3000000,
      diamondProgression: ArithmeticDiamondProgression(2000000),
    ),
  ),

  // Cadence assumed: three hikes a month of 10 km each (~360 km/year).
  // Hiking is lumpy — a fortnight of nothing then a whole Saturday — so
  // the ladder is built on a monthly rhythm rather than a weekly one.
  // Bronze 25 km = under a month; Silver 100 km = 3.3 months; Gold 250 km
  // = 8.3 months; Platinum 450 km = 15 months; Diamond I 1,100 km = 36.7
  // months (~3 years), then 750 km (~2.1 years) per diamond level.
  //
  // Distance rather than ascent on purpose: manual entry has no elevation
  // field today, so a hiker who logs by hand records metres walked and
  // nothing else. Her ladder had to be the one she can always move. The
  // climbing ladder below is the bonus, never the substitute.
  BadgeDefinition.tiered(
    id: 'hike_distance',
    title: 'Out on the Trails',
    description: 'Every kilometre you have hiked, added up since your first.',
    category: BadgeCategory.movement,
    metric: BadgeMetric.lifetimeHikeDistanceMetres,
    unit: BadgeMetricUnit.metres,
    ladder: BadgeLadder(
      bronze: 25000,
      silver: 100000,
      gold: 250000,
      platinum: 450000,
      diamond: 1100000,
      diamondProgression: ArithmeticDiamondProgression(750000),
    ),
  ),

  // Cadence assumed: three recorded sessions a week carrying 150 m of
  // climbing each (~450 m/week, ~23,400 m/year). Bronze 1,000 m = ~2
  // weeks; Silver 5,000 m = ~11 weeks; Gold 15,000 m = ~33 weeks (~7.7
  // months); Platinum 30,000 m = ~67 weeks (~15 months); Diamond I
  // 75,000 m = ~167 weeks (~3.2 years), then 50,000 m (~2.1 years) per
  // level.
  //
  // The one ladder here that can sit at zero indefinitely through no
  // fault of the user: climbing is written by GPS recording and by file
  // import, and a hand-logged session has none
  // (`domain/badge_metrics.dart#ascentOf`). That is survivable only
  // because every activity type it could apply to already has a ladder of
  // its own — this is the extra one for the days she took the hills, not
  // anybody's only route to a tier.
  BadgeDefinition.tiered(
    id: 'elevation_climbed',
    title: 'Everything Uphill',
    description: 'Every metre of climbing your sessions have recorded.',
    category: BadgeCategory.movement,
    metric: BadgeMetric.lifetimeAscentMetres,
    unit: BadgeMetricUnit.ascentMetres,
    ladder: BadgeLadder(
      bronze: 1000,
      silver: 5000,
      gold: 15000,
      platinum: 30000,
      diamond: 75000,
      diamondProgression: ArithmeticDiamondProgression(50000),
    ),
  ),

  // Cadence assumed: two swims a week of 1 km each (~104 km/year). Bronze
  // 5 km = 2.5 weeks; Silver 25 km = 12.5 weeks (~3 months); Gold 60 km =
  // 30 weeks (~7 months); Platinum 120 km = 60 weeks (~14 months);
  // Diamond I 300 km = 150 weeks (~2.9 years), then 200 km (~1.9 years)
  // per diamond level.
  BadgeDefinition.tiered(
    id: 'swim_distance',
    title: 'Length by Length',
    description: 'Every metre you have swum, added up since your first.',
    category: BadgeCategory.swimming,
    metric: BadgeMetric.lifetimeSwimDistanceMetres,
    unit: BadgeMetricUnit.metres,
    ladder: BadgeLadder(
      bronze: 5000,
      silver: 25000,
      gold: 60000,
      platinum: 120000,
      diamond: 300000,
      diamondProgression: ArithmeticDiamondProgression(200000),
    ),
  ),

  // Cadence assumed: two sessions a week (~104/year) — the shape Under the
  // Bar uses, calibrated a little gentler because a count ladder that
  // takes eighteen months to reach Platinum reads as a wall on a badge
  // most people meet in their first fortnight. Bronze 5 = 2.5 weeks;
  // Silver 20 = 10 weeks; Gold 60 = 30 weeks (~7 months); Platinum 120 =
  // 60 weeks (~14 months); Diamond I 260 = 130 weeks (~2.5 years), then
  // 150 sessions (~1.4 years) per diamond level.
  //
  // The same ladder serves all three session-count badges below. That is
  // deliberate and has precedent: the check-in and water ladders share
  // theirs so neither quietly reads as the more important one, and the
  // same reasoning applies with more force here — no ladder in this app
  // is going to declare intervals worth more than pilates.
  BadgeDefinition.tiered(
    id: 'hiit_sessions',
    title: 'Round After Round',
    description:
        'Interval sessions logged, whatever the rounds looked like that '
        'day.',
    category: BadgeCategory.intervals,
    metric: BadgeMetric.hiitSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 5,
      silver: 20,
      gold: 60,
      platinum: 120,
      diamond: 260,
      diamondProgression: ArithmeticDiamondProgression(150),
    ),
  ),

  // Sessions, not minutes: Time on the Mat already counts yoga and pilates
  // minutes together, and a second ladder over the same quantity would be
  // the same badge twice. Counting sessions per discipline instead means
  // a woman who does both progresses on three distinct things, and a woman
  // who does one of them has a ladder that is hers.
  BadgeDefinition.tiered(
    id: 'yoga_sessions',
    title: 'Breath by Breath',
    description: 'Yoga sessions logged, one practice at a time.',
    category: BadgeCategory.mindfulness,
    metric: BadgeMetric.yogaSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 5,
      silver: 20,
      gold: 60,
      platinum: 120,
      diamond: 260,
      diamondProgression: ArithmeticDiamondProgression(150),
    ),
  ),

  BadgeDefinition.tiered(
    id: 'pilates_sessions',
    title: 'Control and Precision',
    description: 'Pilates sessions logged, one at a time.',
    category: BadgeCategory.mindfulness,
    metric: BadgeMetric.pilatesSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 5,
      silver: 20,
      gold: 60,
      platinum: 120,
      diamond: 260,
      diamondProgression: ArithmeticDiamondProgression(150),
    ),
  ),
];
