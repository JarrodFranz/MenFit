import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/sharing/share_feedback.dart';
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';

/// The app may only say what the platform actually told it.
void main() {
  test('no message claims a share that was never confirmed', () {
    // Windows and the web always land on `unavailable`. "Shared!" there
    // would be a confirmation the user can see is false.
    expect(
      shareOutcomeMessage(ShareOutcome.unavailable),
      shareHandedToSystemMessage,
    );
    expect(
      shareOutcomeMessage(ShareOutcome.unavailable),
      isNot(contains('Shared')),
    );
  });

  test('a dismissed sheet says nothing at all', () {
    expect(shareOutcomeMessage(ShareOutcome.dismissed), isNull);
  });

  test('a clipboard fallback says clipboard, not share', () {
    final message = shareOutcomeMessage(ShareOutcome.fellBackToClipboard)!;
    expect(message, contains('clipboard'));
  });

  test('only a confirmed share is called a share', () {
    expect(shareOutcomeMessage(ShareOutcome.success), shareSharedMessage);
  });

  test('every outcome is covered and every message is listed', () {
    for (final outcome in ShareOutcome.values) {
      final message = shareOutcomeMessage(outcome);
      if (message == null) continue;
      expect(
        shareOutcomeMessages,
        contains(message),
        reason: 'a message the copy gates cannot see is a message that drifts',
      );
    }
  });
}
