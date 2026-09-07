import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';

/// Records what a surface handed to the share sheet, and scripts what
/// came back.
///
/// Lives under `test/` rather than beside the adapter it doubles: no
/// other fake in this project ships inside `lib/`, and a test double in
/// the app binary is a test double that eventually gets wired to a
/// screen.
class FakeSharingAdapter implements SharingAdapter {
  FakeSharingAdapter({
    this.outcome = ShareOutcome.success,
    this.supportsShareResult = true,
    this.supportsFileShare = true,
  });

  /// What every call returns.
  ShareOutcome outcome;

  @override
  bool supportsShareResult;

  @override
  bool supportsFileShare;

  final List<SharedText> textShares = [];
  final List<SharedImage> imageShares = [];

  /// Every share, in order, whichever method made it.
  int get shareCount => textShares.length + imageShares.length;

  @override
  Future<ShareOutcome> shareText(
    String text, {
    Rect? sharePositionOrigin,
    String? subject,
  }) async {
    textShares.add(
      SharedText(
        text: text,
        sharePositionOrigin: sharePositionOrigin,
        subject: subject,
      ),
    );
    return outcome;
  }

  @override
  Future<ShareOutcome> shareImage({
    required Uint8List pngBytes,
    required String fileName,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    imageShares.add(
      SharedImage(
        pngBytes: pngBytes,
        fileName: fileName,
        text: text,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return outcome;
  }
}

class SharedText {
  const SharedText({
    required this.text,
    required this.sharePositionOrigin,
    required this.subject,
  });

  final String text;
  final Rect? sharePositionOrigin;
  final String? subject;
}

class SharedImage {
  const SharedImage({
    required this.pngBytes,
    required this.fileName,
    required this.text,
    required this.sharePositionOrigin,
  });

  final Uint8List pngBytes;
  final String fileName;
  final String? text;
  final Rect? sharePositionOrigin;
}
