/// UI composition surface for the `achievements` feature (ADR 007's
/// 2026-08-28 amendment, same shape as `features/weight/weight_widgets.dart`
/// and `features/insights/insights_widgets.dart`): the only legal way for
/// another feature to reach this feature's designated public widgets. Never
/// import `presentation/` internals directly from outside this feature.
///
/// Exports:
///
/// * the Progress screen's Achievements card — the entry point to the
///   trophy case;
/// * the post-workout badge strip, mounted inside the workout celebration
///   by `features/activity`;
/// * the badge emblem itself, so a badge named anywhere else in the app
///   (the home dashboard's most-recent-badge card) wears the same crest as
///   it does in the trophy case rather than a second, drifting drawing of
///   it. Its own dartdoc carries the rule that goes with it: the emblem
///   never carries meaning alone, so every caller renders the tier's name
///   as text beside it.
///
/// The trophy case screen itself is not exported: nothing mounts it
/// directly, it is reached through the typed route `AchievementsRouteData`
/// in `app/router/routes.dart`.
library;

export 'package:menfit_app/features/achievements/presentation/widgets/achievements_progress_section.dart'
    show AchievementsProgressSection;
export 'package:menfit_app/features/achievements/presentation/widgets/badge_emblem.dart'
    show BadgeEmblem;
export 'package:menfit_app/features/achievements/presentation/widgets/post_workout_badge_strip.dart'
    show PostWorkoutBadgeStrip;
