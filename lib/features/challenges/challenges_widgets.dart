/// UI composition surface for the `challenges` feature (ADR 007's
/// 2026-08-28 amendment, same shape as
/// `features/achievements/achievements_widgets.dart` and
/// `features/weight/weight_widgets.dart`): the only legal way for another
/// feature — here `progress`, which mounts the Buddy challenges card — to
/// reach this feature's designated public widgets. Never import
/// `presentation/` internals directly from outside this feature.
///
/// Exports: the Progress screen's Buddy challenges card. The screens
/// themselves are not exported because nothing mounts them directly —
/// they are reached through the typed routes `ChallengesRouteData`,
/// `CreateChallengeRouteData`, `JoinChallengeRouteData` and
/// `ChallengeDetailRouteData` in `app/router/routes.dart`.
library;

export 'package:menfit_app/features/challenges/presentation/widgets/challenges_progress_section.dart'
    show ChallengesProgressSection;
