import 'package:menfit_app/features/achievements/domain/badge_definition.dart';

/// The tiered half of the badge catalogue — see `domain/badge_catalogue.dart`
/// for the catalogue's rules, and for why this is split across two files.
///
/// ## Why these eleven, and how the numbers were picked
///
/// A tier ladder is only honest on a behaviour the user can **keep**
/// progressing at, so every metric below is a lifetime or per-period
/// accumulation that can only rise. Bounded quantities (how many *kinds* of
/// activity exist, for instance) are one-off badges instead — a ladder that
/// physically cannot continue is not open-ended, whatever the rule says.
///
/// Thresholds are calibrated so that **Bronze arrives within a few weeks**
/// of ordinary use, Gold is a season's worth, Platinum around a year, and
/// **Diamond I takes a year or more** — with the diamond progression
/// carrying it on from there for as long as they keep going. The working
/// cadences behind the numbers are written on each badge.
const List<BadgeDefinition> tieredBadgeDefinitions = [
  // Cadence assumed: a walker logging 15 km across a week. Bronze at 4
  // qualifying weeks (~1 month), Platinum at 52 (a year's worth of weeks,
  // not necessarily consecutive), Diamond I at 104, then a further year of
  // weeks per diamond level. Weeks need not be consecutive — this is a
  // tally, not a streak, so nothing here can ever be "lost".
  BadgeDefinition.tiered(
    id: 'weekly_walking_weeks',
    title: 'Week After Week',
    description:
        'Weeks where your walking added up to 15 km. Weeks holding '
        'protected recovery days ask for proportionally less — resting is '
        'part of it.',
    category: BadgeCategory.consistency,
    metric: BadgeMetric.weeklyWalkingTargetWeeks,
    unit: BadgeMetricUnit.weeks,
    ladder: BadgeLadder(
      bronze: 4,
      silver: 12,
      gold: 26,
      platinum: 52,
      diamond: 104,
      diamondProgression: ArithmeticDiamondProgression(52),
    ),
  ),

  // Cadence assumed: 3 sessions a week (~156/year). Bronze inside a
  // fortnight, Gold at ~8 months, Platinum ~18 months, Diamond I ~3 years.
  // The one badge everybody progresses on whatever they do.
  BadgeDefinition.tiered(
    id: 'sessions_logged',
    title: 'Showing Up',
    description:
        'Every session you have logged, of every kind. This one simply '
        'counts them.',
    category: BadgeCategory.movement,
    metric: BadgeMetric.lifetimeSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 5,
      silver: 25,
      gold: 100,
      platinum: 250,
      diamond: 500,
      diamondProgression: ArithmeticDiamondProgression(250),
    ),
  ),

  // Cadence assumed: 15 km of running a week (~780 km/year). Bronze in a
  // fortnight, Silver ~7 weeks, Gold ~6 months, Platinum ~16 months,
  // Diamond I ~3 years, then ~2 years per diamond level.
  BadgeDefinition.tiered(
    id: 'run_distance',
    title: 'The Road So Far',
    description: 'Every kilometre you have run, added up since your first.',
    category: BadgeCategory.movement,
    metric: BadgeMetric.lifetimeRunDistanceMetres,
    unit: BadgeMetricUnit.metres,
    ladder: BadgeLadder(
      bronze: 25000,
      silver: 100000,
      gold: 400000,
      platinum: 1000000,
      diamond: 2500000,
      diamondProgression: ArithmeticDiamondProgression(1500000),
    ),
  ),

  // Cadence assumed: 50 km of riding a week (~2,600 km/year) — riding
  // covers roughly three times the ground per hour, so every rung sits
  // about three times higher than the running ladder's.
  BadgeDefinition.tiered(
    id: 'ride_distance',
    title: 'Wheels Turning',
    description: 'Every kilometre you have ridden, added up since your first.',
    category: BadgeCategory.cycling,
    metric: BadgeMetric.lifetimeRideDistanceMetres,
    unit: BadgeMetricUnit.metres,
    ladder: BadgeLadder(
      bronze: 50000,
      silver: 250000,
      gold: 1000000,
      platinum: 3000000,
      diamond: 8000000,
      diamondProgression: ArithmeticDiamondProgression(5000000),
    ),
  ),

  // Cadence assumed: ~2,500 kg of completed tonnage per session, twice a
  // week (~260,000 kg/year). Bronze inside a month, Gold ~7 months,
  // Platinum ~14 months, Diamond I ~2 years. Geometric past there: tonnage
  // accumulates multiplicatively as they get stronger and add sessions, so
  // a fixed step would be crossed again within weeks of the last one.
  BadgeDefinition.tiered(
    id: 'strength_volume',
    title: "Everything You've Lifted",
    description:
        'The completed sets of every strength session, added up — reps '
        'times kilograms, session after session.',
    category: BadgeCategory.strength,
    metric: BadgeMetric.lifetimeStrengthVolumeKg,
    unit: BadgeMetricUnit.kilograms,
    ladder: BadgeLadder(
      bronze: 10000,
      silver: 50000,
      gold: 150000,
      platinum: 300000,
      diamond: 500000,
      diamondProgression: GeometricDiamondProgression(2),
    ),
  ),

  // Cadence assumed: 2 strength sessions a week (~104/year). Bronze in ~3
  // weeks, Gold ~9 months, Platinum ~18 months, Diamond I ~3.5 years.
  BadgeDefinition.tiered(
    id: 'strength_sessions',
    title: 'Under the Bar',
    description:
        'Strength sessions logged, whatever the numbers on the bar were '
        'that day.',
    category: BadgeCategory.strength,
    metric: BadgeMetric.strengthSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 5,
      silver: 25,
      gold: 75,
      platinum: 150,
      diamond: 350,
      diamondProgression: ArithmeticDiamondProgression(200),
    ),
  ),

  // Cadence assumed: a check-in on ~5 days a week (~260/year). Bronze in a
  // fortnight, Gold ~5 months, Platinum ~1 year, Diamond I ~2 years.
  BadgeDefinition.tiered(
    id: 'checkin_days',
    title: 'Noticing How You Feel',
    description:
        'Days you took a moment to log a check-in — energy, sleep, '
        'soreness, whatever you felt like saying.',
    category: BadgeCategory.consistency,
    metric: BadgeMetric.checkinDayCount,
    unit: BadgeMetricUnit.days,
    ladder: BadgeLadder(
      bronze: 7,
      silver: 30,
      gold: 100,
      platinum: 250,
      diamond: 500,
      diamondProgression: ArithmeticDiamondProgression(250),
    ),
  ),

  // Same cadence and ladder as the check-in badge: both are "days you did a
  // small thing", and giving them the same shape means neither quietly
  // reads as the more important one.
  BadgeDefinition.tiered(
    id: 'water_days',
    title: 'Well Watered',
    description: 'Days your logged water reached 2 litres.',
    category: BadgeCategory.hydration,
    metric: BadgeMetric.waterTargetDayCount,
    unit: BadgeMetricUnit.days,
    ladder: BadgeLadder(
      bronze: 7,
      silver: 30,
      gold: 100,
      platinum: 250,
      diamond: 500,
      diamondProgression: ArithmeticDiamondProgression(250),
    ),
  ),

  // Cadence assumed: two 45-minute sessions a week (~78 hours/year). Bronze
  // after an hour, Gold ~3 months, Platinum ~8 months, Diamond I ~15
  // months, then ~9 months per diamond level.
  BadgeDefinition.tiered(
    id: 'mindful_minutes',
    title: 'Time on the Mat',
    description:
        'Minutes of yoga, pilates and other mindful movement, added up.',
    category: BadgeCategory.mindfulness,
    metric: BadgeMetric.mindfulMinutes,
    unit: BadgeMetricUnit.minutes,
    ladder: BadgeLadder(
      bronze: 60,
      silver: 300,
      gold: 1200,
      platinum: 3000,
      diamond: 6000,
      diamondProgression: ArithmeticDiamondProgression(3000),
    ),
  ),

  // A pair, deliberately: whichever end of the day is yours, there is a
  // badge for it, and neither is framed as the better one. Diamond I at
  // 365 early starts, then another 365 per level.
  BadgeDefinition.tiered(
    id: 'early_bird_sessions',
    title: 'Before the Kettle',
    description: 'Sessions that started before 7 in the morning.',
    category: BadgeCategory.fun,
    metric: BadgeMetric.earlyBirdSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 3,
      silver: 15,
      gold: 50,
      platinum: 150,
      diamond: 365,
      diamondProgression: ArithmeticDiamondProgression(365),
    ),
  ),

  BadgeDefinition.tiered(
    id: 'night_owl_sessions',
    title: 'After Dark',
    description: 'Sessions that started at 8 in the evening or later.',
    category: BadgeCategory.fun,
    metric: BadgeMetric.nightOwlSessionCount,
    unit: BadgeMetricUnit.sessions,
    ladder: BadgeLadder(
      bronze: 3,
      silver: 15,
      gold: 50,
      platinum: 150,
      diamond: 365,
      diamondProgression: ArithmeticDiamondProgression(365),
    ),
  ),
];
