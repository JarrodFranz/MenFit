import 'package:image_picker/image_picker.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/ocr_platform.dart';

/// Takes one photo and returns its path, or `null` if the user backed out.
///
/// The seam tests inject in place of the real camera; production code uses
/// [LabelCaptureService.pickFromCamera].
typedef LabelPhotoPicker = Future<String?> Function();

/// Returns the paths of captures abandoned by a previous, killed run.
///
/// The seam tests inject in place of `image_picker`'s lost-data recovery;
/// production code uses [LabelCaptureService.lostCapturePaths].
typedef LabelLostPhotoSweeper = Future<List<String>> Function();

/// Photograph a nutrition label, recognise it, and throw the photo away.
///
/// The one file in the app allowed to import `image_picker` (pinned by
/// `test/core/platform/ocr/ocr_import_guard_test.dart`). Generic mechanism,
/// named for its only caller.
///
/// ## The photo does not survive this call
///
/// `ImageSource.camera` hands the OS camera app a destination in this app's
/// **cache** directory and gives back the path. It is not written to the
/// photo library, no copy is made, nothing is logged, and it is unlinked in
/// a `finally` so that a throw from the recogniser cannot leave it behind
/// (security_and_privacy.md, S2 — nutrition data; ADR 012 — "no photo,
/// crop, or extracted text may leave the phone").
///
/// Two smaller decisions serve the same rule and should not be "improved"
/// away:
///
/// - `requestFullMetadata: false` — on iOS this stops the plugin reaching
///   into the Photos library for the asset's metadata, which is where the
///   GPS coordinates of the shot would come from. We want the pixels, not
///   the location of the supermarket.
/// - no `maxWidth` / `maxHeight` / `imageQuality` — resizing costs
///   recognition accuracy on the small print of a nutrition panel, and the
///   Android plugin implements it by writing a *second, scaled* file while
///   leaving the original in place. One file in, one file deleted.
final class LabelCaptureService {
  LabelCaptureService({
    required this.adapter,
    LabelPhotoPicker? pickPhoto,
    LabelLostPhotoSweeper? sweepLostPhotos,
  }) : _pickPhoto = pickPhoto ?? pickFromCamera,
       _sweepLostPhotos = sweepLostPhotos ?? lostCapturePaths;

  final OcrAdapter adapter;
  final LabelPhotoPicker _pickPhoto;
  final LabelLostPhotoSweeper _sweepLostPhotos;

  /// Opens the OS camera and returns the captured file's path.
  static Future<String?> pickFromCamera() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      requestFullMetadata: false,
    );
    return photo?.path;
  }

  /// Paths of captures left behind when Android destroyed the activity
  /// while the OS camera was in front.
  ///
  /// Android is entitled to kill `MainActivity` under memory pressure while
  /// another app is showing. When it does, the `pickImage` future this
  /// process was waiting on **never completes** — so the `finally` that
  /// deletes the photo never runs, and the JPEG stays in the app cache
  /// indefinitely. `image_picker` exists on the other side of that with
  /// `retrieveLostData`, which is the only way to learn the file was ever
  /// written.
  ///
  /// Android-only: the platform interface throws `UnimplementedError` on
  /// iOS, and there is nothing to recover there because iOS does not kill a
  /// foreground app this way. The throw is swallowed rather than guarded on
  /// a platform check — this is best-effort cleanup that must never be the
  /// reason a capture fails to start — and nothing about it is logged,
  /// because the exception quotes the path of a photo of someone's food.
  static Future<List<String>> lostCapturePaths() async {
    try {
      final lost = await ImagePicker().retrieveLostData();
      if (lost.isEmpty) return const [];
      return <String>[
        if (lost.file != null) lost.file!.path,
        for (final file in lost.files ?? const <XFile>[])
          if (file.path != lost.file?.path) file.path,
      ];
    } on Object catch (_) {
      // See the doc comment: platform-unsupported or a recovery that
      // failed. Either way there is nothing to do and nothing to say.
      return const [];
    }
  }

  /// Captures a label and recognises it, returning `null` when the user
  /// cancelled the camera.
  ///
  /// Safe to call straight from a tap handler. Callers must still gate the
  /// affordance on `textRecognitionSupported`; on a platform without
  /// recognition this returns [OcrResult.unsupported] rather than throwing,
  /// after pointlessly opening a camera.
  ///
  /// Throws whatever the camera throws — `PlatformException`
  /// (`camera_access_denied`) most of the time. That is deliberate: a
  /// denied permission is not a cancellation, and returning `null` for both
  /// would leave the user tapping a button that appears to do nothing. The
  /// caller decides what to say.
  Future<OcrResult?> captureAndRecognizeLabel() async {
    // Sweep first, and **delete rather than recognise**. A photo recovered
    // here is the leftover of a capture this process never saw finish; the
    // user is standing in front of a form asking to scan a label now, and
    // silently reading a stale picture of whatever she photographed last
    // time would be both wrong and a surprise. The only thing owed to that
    // file is that it stops existing.
    for (final lost in await _sweepLostPhotos()) {
      await deleteCapturedFile(lost);
    }

    final path = await _pickPhoto();
    if (path == null || path.isEmpty) return null;
    try {
      return await adapter.recognize(OcrImage.file(path));
    } finally {
      await deleteCapturedFile(path);
    }
  }
}
