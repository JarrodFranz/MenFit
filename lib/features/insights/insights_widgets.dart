/// UI composition surface for the `insights` feature (ADR 007's 2026-08-28
/// amendment, same shape as `features/recaps/recaps_widgets.dart`): the
/// only legal way for another feature (`home` and `progress`, which each
/// mount the discovery section) to reach this feature's designated public
/// widgets. Never import `presentation/` internals directly from outside
/// this feature.
///
/// Exports: the "What your data shows" discovery section, which renders
/// nothing at all when the engine has found no pattern.
library;

export 'package:menfit_app/features/insights/presentation/widgets/insight_discovery_section.dart'
    show InsightDiscoverySection;
