import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';

/// What the app is entitled to say after a share, in one place.
///
/// The rule these strings exist to keep: **never claim a share happened
/// that the platform did not confirm.** On Windows and on the web the
/// share result is always [ShareOutcome.unavailable] — the content was
/// handed over and that is genuinely all we know — so the message says
/// exactly that rather than "Shared!". A confirmation the user can see is
/// false is worse than no confirmation.
///
/// Every challenge-facing string here is swept by the forbidden-vocabulary
/// gate in `test/features/challenges/challenges_copy_test.dart` via
/// [shareOutcomeMessages], because these snackbars appear on challenge
/// surfaces too.
const String shareSharedMessage = 'Shared.';

const String shareHandedToSystemMessage = 'Handed to the system share.';

const String shareDownloadedMessage = 'Saved to your downloads.';

const String shareCopiedInsteadMessage =
    'Share sheet unavailable — copied to your clipboard instead.';

/// Every message [shareOutcomeMessage] can produce, for the copy gates.
const List<String> shareOutcomeMessages = [
  shareSharedMessage,
  shareHandedToSystemMessage,
  shareDownloadedMessage,
  shareCopiedInsteadMessage,
];

/// The snackbar for [outcome], or `null` when there is nothing honest and
/// useful to say.
///
/// [ShareOutcome.dismissed] returns `null` on purpose: they closed the
/// sheet, they know, and a confirmation of a non-event is noise.
String? shareOutcomeMessage(ShareOutcome outcome) => switch (outcome) {
  ShareOutcome.success => shareSharedMessage,
  ShareOutcome.dismissed => null,
  ShareOutcome.unavailable => shareHandedToSystemMessage,
  ShareOutcome.fellBackToDownload => shareDownloadedMessage,
  ShareOutcome.fellBackToClipboard => shareCopiedInsteadMessage,
};
