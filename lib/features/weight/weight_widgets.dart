/// UI composition surface for the `weight` feature (ADR 007's 2026-08-28
/// amendment, same shape as `features/insights/insights_widgets.dart` and
/// `features/recaps/recaps_widgets.dart`): the only legal way for another
/// feature — here `progress`, which mounts the Weight card — to reach this
/// feature's designated public widgets. Never import `presentation/`
/// internals directly from outside this feature.
///
/// Exports: the Progress screen's Weight section. The full weight screen
/// is not exported because nothing mounts it directly — it is reached
/// through the typed route `WeightRouteData` in `app/router/routes.dart`.
library;

export 'package:menfit_app/features/weight/presentation/widgets/weight_progress_section.dart'
    show WeightProgressSection;
