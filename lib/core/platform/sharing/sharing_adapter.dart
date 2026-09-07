import 'dart:typed_data';
import 'dart:ui' show Rect;

/// What actually happened when a share was handed to the platform.
///
/// Deliberately not a boolean: on Windows and on the web the OS tells us
/// nothing about what the user did with the sheet, and a `bool` there
/// would either lie ("Shared!") or throw away the distinction between
/// "the sheet opened" and "there is no sheet". Presentation code is
/// expected to switch on this and only claim what the value actually
/// asserts (see `shareOutcomeMessage` in `share_feedback.dart`).
enum ShareOutcome {
  /// The user picked a share target. Only ever returned where
  /// [SharingAdapter.supportsShareResult] is `true` (Android, iOS,
  /// macOS) — everywhere else the platform does not report it.
  success,

  /// The user dismissed the share sheet without picking anything.
  dismissed,

  /// The content was handed to the platform and the platform does not
  /// report what became of it. This is the normal, non-error outcome on
  /// Windows and on the web — it must never be described to the user as
  /// a completed share, and never as a failure either.
  unavailable,

  /// Web only: no Web Share API (desktop Firefox), so the browser
  /// downloaded the file instead of opening a share sheet.
  ///
  /// Nothing returns this today: `share_plus`'s web plugin reports the
  /// download fallback and a real Web Share success with the same
  /// [ShareOutcome.unavailable] status, so the adapter cannot tell them
  /// apart honestly. It stays in the contract because the distinction is
  /// real and a future web-specific adapter can assert it — and because
  /// a fake can script it, which is how the UI branch is tested.
  fellBackToDownload,

  /// The platform share failed or is not available at all, and the
  /// adapter put the text on the clipboard instead so the user is not
  /// left with nothing. Reported honestly ("copied instead"), never as a
  /// share.
  fellBackToClipboard,
}

/// Port for the OS share sheet.
///
/// Nothing outside `core/platform/sharing/` may import `share_plus`
/// (architecture_overview.md rule 4, pinned by
/// `test/core/platform/sharing/share_plus_import_guard_test.dart`). Feature
/// code depends on this interface and gets the real implementation from
/// `sharingAdapterProvider`.
///
/// Copy-to-clipboard is **not** this port's job and is not a fallback for
/// it: every surface that offers Share also offers an equally visible
/// Copy, because Windows share has edition-specific failures and desktop
/// Firefox has no Web Share API at all (ADR 011).
abstract interface class SharingAdapter {
  /// Whether this platform reports what the user did with the share
  /// sheet. `false` on Windows, Linux and the web — where it is `false`,
  /// [ShareOutcome.success] is never returned and the UI must not claim
  /// a share completed.
  bool get supportsShareResult;

  /// Whether this platform can share a file at all. `false` on Linux
  /// (share_plus shares text via `mailto` there and cannot attach), in
  /// which case [shareImage] degrades to sharing its `text`.
  ///
  /// Windows below build 17763 also cannot share files; that cannot be
  /// detected from Dart, so it surfaces as a failed share which becomes
  /// [ShareOutcome.fellBackToClipboard].
  bool get supportsFileShare;

  /// Opens the platform share sheet for [text].
  ///
  /// [sharePositionOrigin] is the global rect of the widget the user
  /// tapped — required on iPad and macOS, where the sheet is a popover
  /// that anchors to it; ignored elsewhere.
  ///
  /// [subject] populates the email subject where the platform has one
  /// (Android's `EXTRA_SUBJECT`, the `mailto` fallback on Windows and
  /// Linux). It must never carry anything the body does not already say.
  Future<ShareOutcome> shareText(
    String text, {
    Rect? sharePositionOrigin,
    String? subject,
  });

  /// Opens the platform share sheet for a PNG image, optionally with
  /// [text] alongside it.
  ///
  /// [pngBytes] are shared from memory (the plugin writes a temp file in
  /// the app cache on mobile). [fileName] is what the receiving app sees
  /// — no user data belongs in it.
  Future<ShareOutcome> shareImage({
    required Uint8List pngBytes,
    required String fileName,
    String? text,
    Rect? sharePositionOrigin,
  });
}
