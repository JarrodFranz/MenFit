import 'package:menfit_app/features/achievements/domain/badge_definition.dart';

/// The one-off half of the badge catalogue — see `domain/badge_catalogue.dart`
/// for the catalogue's rules.
///
/// Every condition here is decided from data the app **already stores**.
/// Nothing in this list motivates collecting anything new, and nothing
/// reaches for an outside service; the ideas that would have are listed,
/// with their reasons, in `domain/badge_catalogue.dart`.
///
/// One-offs are firsts and curiosities. A first is a real moment and
/// deserves marking; a curiosity (a palindrome distance, a session on the
/// solstice) is luck rather than effort, which is exactly why it is fun and
/// exactly why it has no ladder — nobody should be able to grind at it.
const List<BadgeDefinition> oneOffBadgeDefinitions = [
  BadgeDefinition.oneOff(
    id: 'first_activity',
    title: 'First One Logged',
    description:
        'Your very first session in the app. Everything else counts from '
        'here.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.firstActivityLogged,
  ),

  BadgeDefinition.oneOff(
    id: 'first_five_k_effort',
    title: 'Five Kilometres',
    description:
        'A recorded session with a five-kilometre stretch inside it, timed '
        'end to end.',
    category: BadgeCategory.movement,
    condition: BadgeCondition.firstFiveKilometreEffort,
  ),

  BadgeDefinition.oneOff(
    id: 'first_strength_session',
    title: 'First Lift',
    description: 'Your first logged strength session.',
    category: BadgeCategory.strength,
    condition: BadgeCondition.firstStrengthSession,
  ),

  BadgeDefinition.oneOff(
    id: 'first_mindful_session',
    title: 'First Stillness',
    description: 'Your first logged yoga, pilates or mindful session.',
    category: BadgeCategory.mindfulness,
    condition: BadgeCondition.firstMindfulSession,
  ),

  BadgeDefinition.oneOff(
    id: 'first_water_day',
    title: 'Two Litres',
    description: 'A day your logged water reached 2 litres.',
    category: BadgeCategory.hydration,
    condition: BadgeCondition.firstWaterTargetDay,
  ),

  BadgeDefinition.oneOff(
    id: 'full_checkin_week',
    title: 'Seven for Seven',
    description:
        'A Monday-to-Sunday week with a check-in logged on each of its '
        'seven days.',
    category: BadgeCategory.consistency,
    condition: BadgeCondition.fullCheckinWeek,
  ),

  BadgeDefinition.oneOff(
    id: 'seasonal_turn_session',
    title: 'Turn of the Season',
    description:
        'A session on a solstice or an equinox — one of the four days the '
        'year pivots on.',
    category: BadgeCategory.fun,
    condition: BadgeCondition.seasonalTurnSession,
  ),

  BadgeDefinition.oneOff(
    id: 'every_season_active',
    title: 'Round the Year',
    description:
        'Sessions logged in all four seasons — whichever way round they '
        'come where you live.',
    category: BadgeCategory.fun,
    condition: BadgeCondition.everySeasonActive,
  ),

  BadgeDefinition.oneOff(
    id: 'five_movement_kinds',
    title: 'Five Ways to Move',
    description:
        'Five different kinds of activity logged. Variety, entirely for '
        'its own sake.',
    category: BadgeCategory.fun,
    condition: BadgeCondition.fiveMovementKinds,
  ),

  BadgeDefinition.oneOff(
    id: 'palindrome_distance',
    title: 'Same Both Ways',
    description:
        'A session whose distance in metres reads the same forwards and '
        'backwards. Pure chance, and worth a badge for it.',
    category: BadgeCategory.fun,
    condition: BadgeCondition.palindromeDistance,
  ),
];
