/// The default daily step target, in steps.
///
/// **This is the single source of the number.** It previously lived as a
/// bare `7500` literal inside the home "At a Glance" steps ring
/// (`features/activity/presentation/widgets/fitness_dashboard_cards.dart`);
/// every surface that draws a step goal now reads it from here through
/// `stepsTargetProvider`, so the ring, the steps screen and any future
/// summary cannot disagree about what "on target" means.
///
/// 7 500 is a **display default, not health advice**
/// (`knowledge/domain/mens_health.md`: this app does not set clinical
/// targets). It is a round number the user is expected to be able to change
/// once a per-user target exists; nothing in the app tells her it is a
/// figure she ought to hit.
const int defaultDailyStepTarget = 7500;
