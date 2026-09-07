/// UI composition surface for the `nutrition` feature (ADR 007's 2026-08-28
/// amendment): the only legal way for another feature to reach this
/// feature's designated public widgets/display helpers. Never import
/// `presentation/` internals directly from outside this feature.
///
/// First (and so far only) export: the diary's display-formatting helpers,
/// needed by the home dashboard's macros card and the progress dashboard's
/// nutrition card so they render figures the same way the diary does.
library;

export 'presentation/nutrition_format.dart';
