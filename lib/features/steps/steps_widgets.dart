/// UI composition surface for the `steps` feature (ADR 007's 2026-08-28
/// amendment, same shape as `features/weight/weight_widgets.dart` and
/// `features/achievements/achievements_widgets.dart`): the only legal way
/// for another feature to reach this feature's designated public widgets.
/// Never import `presentation/` internals directly from outside this
/// feature.
///
/// Exports:
///
/// * the steps ring card - today against the target over the seven-day
///   consistency strip - mounted by both `features/home` and
///   `features/activity`. It lived as a private widget inside
///   `features/activity` until `home` needed the same card; one definition
///   is what stops the two dashboards disagreeing about the same number;
/// * the seven-day consistency strip on its own, for callers that want the
///   strip without the ring.
///
/// The steps screen itself is not exported: nothing mounts it directly, it
/// is reached through the typed route `StepsRouteData` in
/// `app/router/routes.dart`.
library;

export 'package:menfit_app/features/steps/presentation/widgets/steps_ring_card.dart'
    show StepsRingCard;
export 'package:menfit_app/features/steps/presentation/widgets/steps_week_strip.dart'
    show StepsWeekStrip;
