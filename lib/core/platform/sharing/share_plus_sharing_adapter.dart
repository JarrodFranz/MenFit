import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';
import 'package:share_plus/share_plus.dart';

/// Runs one share. The seam tests inject in place of
/// `SharePlus.instance.share`, so the mapping can be exercised without a
/// plugin registrant — `SharePlus` itself has no public generative
/// constructor and its `custom` factory needs the platform-interface
/// package, which is not a direct dependency here.
typedef ShareRunner = Future<ShareResult> Function(ShareParams params);

/// The one file in the app allowed to import `share_plus`
/// (`test/core/platform/sharing/share_plus_import_guard_test.dart`).
///
/// Everything platform-shaped about sharing lives here: which platforms
/// report a result, which can attach a file, and what a raw
/// [ShareResultStatus] means. Callers see only [ShareOutcome].
class SharePlusSharingAdapter implements SharingAdapter {
  /// [runShare], [isWeb] and [platform] exist so the mapping can be
  /// tested per-platform without a device; production code constructs it
  /// with no arguments (see `sharing_providers.dart`).
  SharePlusSharingAdapter({
    ShareRunner? runShare,
    this.isWeb = kIsWeb,
    TargetPlatform? platform,
  }) : _runShare = runShare ?? SharePlus.instance.share,
       _platform = platform ?? defaultTargetPlatform;

  final ShareRunner _runShare;

  /// Whether this build runs in a browser. Only ever `kIsWeb` outside
  /// tests, which pass it explicitly to exercise the web mapping.
  final bool isWeb;

  final TargetPlatform _platform;

  /// share_plus only reports the user's action on Android, iOS and
  /// macOS. Windows always returns `unavailable` (its `mailto` fallback
  /// and its `DataTransferManager` path both do), Linux the same, and the
  /// web plugin returns `unavailable` for a successful `navigator.share`
  /// as well as for its download/mailto fallbacks.
  @override
  bool get supportsShareResult =>
      !isWeb &&
      (_platform == TargetPlatform.android ||
          _platform == TargetPlatform.iOS ||
          _platform == TargetPlatform.macOS);

  @override
  bool get supportsFileShare => isWeb || _platform != TargetPlatform.linux;

  @override
  Future<ShareOutcome> shareText(
    String text, {
    Rect? sharePositionOrigin,
    String? subject,
  }) async {
    // The plugin throws ArgumentError on empty text rather than opening
    // an empty sheet; nothing to hand over and nothing to copy either.
    if (text.isEmpty) return ShareOutcome.unavailable;
    return _share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
      clipboardFallback: text,
    );
  }

  @override
  Future<ShareOutcome> shareImage({
    required Uint8List pngBytes,
    required String fileName,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    if (!supportsFileShare) {
      if (text == null || text.isEmpty) return ShareOutcome.unavailable;
      return shareText(text, sharePositionOrigin: sharePositionOrigin);
    }
    return _share(
      ShareParams(
        files: [
          XFile.fromData(pngBytes, name: fileName, mimeType: 'image/png'),
        ],
        // `XFile.fromData`'s own `name` is ignored on every platform but
        // web; this is the parameter that actually names the file.
        fileNameOverrides: [fileName],
        text: (text?.isEmpty ?? true) ? null : text,
        sharePositionOrigin: sharePositionOrigin,
      ),
      clipboardFallback: text,
    );
  }

  /// Runs one share and turns everything it can do — a status, a throw —
  /// into a [ShareOutcome].
  ///
  /// A throw is a real possibility rather than a defensive `catch`:
  /// Windows share fails on some editions (plus_plugins #3687/#3619),
  /// Windows below build 17763 throws `UnimplementedError` for files,
  /// and the web plugin throws when its own fallbacks are exhausted.
  /// Landing the user back with nothing would be the worst of the
  /// options, so the text goes on the clipboard and the caller is told
  /// plainly that that is what happened.
  ///
  /// The error is deliberately not logged: share text can carry S2/S3
  /// data (`knowledge/engineering/security_and_privacy.md`) and platform
  /// exceptions quote their arguments.
  Future<ShareOutcome> _share(
    ShareParams params, {
    required String? clipboardFallback,
  }) async {
    try {
      final result = await _runShare(params);
      return _outcomeFor(result.status);
    } on Object catch (_) {
      return _copyInstead(clipboardFallback);
    }
  }

  ShareOutcome _outcomeFor(ShareResultStatus status) {
    // Trust the flag, not the platform's word: a `success` from a
    // platform that cannot observe the user's action would be a claim we
    // are not entitled to make.
    if (!supportsShareResult) return ShareOutcome.unavailable;
    return switch (status) {
      ShareResultStatus.success => ShareOutcome.success,
      ShareResultStatus.dismissed => ShareOutcome.dismissed,
      ShareResultStatus.unavailable => ShareOutcome.unavailable,
    };
  }

  Future<ShareOutcome> _copyInstead(String? text) async {
    if (text == null || text.isEmpty) return ShareOutcome.unavailable;
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return ShareOutcome.fellBackToClipboard;
    } on Object catch (_) {
      return ShareOutcome.unavailable;
    }
  }
}
