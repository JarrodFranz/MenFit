/// UI composition surface for the `recaps` feature (ADR 007's 2026-08-28
/// amendment, same shape as `features/wellbeing/wellbeing_widgets.dart`):
/// the only legal way for another feature (`home`, mounting the automatic
/// trigger) to reach this feature's designated public widgets. Never
/// import `presentation/` internals directly from outside this feature.
///
/// Exports: the Home dashboard's invisible recap trigger, and the Progress
/// screen's re-viewable recap history section.
library;

export 'package:menfit_app/features/recaps/presentation/widgets/recap_history_section.dart'
    show RecapHistorySection;
export 'package:menfit_app/features/recaps/presentation/widgets/recap_trigger_listener.dart'
    show RecapTriggerListener;
