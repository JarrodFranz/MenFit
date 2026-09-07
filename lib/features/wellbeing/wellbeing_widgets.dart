/// UI composition surface for the `wellbeing` feature (ADR 007's
/// 2026-08-28 amendment): the only legal way for another feature (in
/// practice, `home`, which composes dashboard cards) to reach this
/// feature's designated public widgets. Never import `presentation/`
/// internals directly from outside this feature.
///
/// First (and so far only) export: the home dashboard's check-in card.
library;

export 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart'
    show CheckinSheet;
export 'package:menfit_app/features/wellbeing/presentation/event_dialog.dart'
    show EventDialog;
export 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart'
    show FlareDialog;
export 'package:menfit_app/features/wellbeing/presentation/widgets/checkin_card.dart'
    show CheckinCard;
export 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';
