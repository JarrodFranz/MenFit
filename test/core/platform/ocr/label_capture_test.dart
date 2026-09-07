import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/ocr/label_capture.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';

import 'fake_ocr_adapter.dart';

/// The privacy contract of the capture flow, tested against the real
/// filesystem.
///
/// A fake picker stands in for the camera, but the file it hands back is a
/// real one and the deletion under test is the real `File.delete` from
/// `ocr_platform_io.dart` — mocking the deleter would test that the code
/// calls a function, which is not the thing anyone needs to be sure of. The
/// thing anyone needs to be sure of is that no photo of someone's kitchen
/// is left in the app cache.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('menfit_label_capture');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File writePhoto() {
    final file = File('${tempDir.path}${Platform.pathSeparator}label.jpg')
      ..writeAsBytesSync(const [0xFF, 0xD8, 0xFF, 0xE0]);
    return file;
  }

  test('recognises the captured photo and then deletes it', () async {
    final photo = writePhoto();
    final adapter = FakeOcrAdapter(result: singleLineOcrResult('Per 100 g'));
    final service = LabelCaptureService(
      adapter: adapter,
      pickPhoto: () async => photo.path,
    );

    final result = await service.captureAndRecognizeLabel();

    expect(result?.fullText, 'Per 100 g');
    expect(adapter.recognized.single, isA<OcrImageFile>());
    expect((adapter.recognized.single as OcrImageFile).path, photo.path);
    expect(
      photo.existsSync(),
      isFalse,
      reason: 'the captured photo must not outlive the recognition',
    );
  });

  test('deletes the photo even when recognition throws', () async {
    // The path that actually matters. A `catch` in the caller would not
    // save the file from being left behind; only the `finally` does.
    final photo = writePhoto();
    final service = LabelCaptureService(
      adapter: FakeOcrAdapter(throwOnRecognize: StateError('recogniser died')),
      pickPhoto: () async => photo.path,
    );

    await expectLater(
      service.captureAndRecognizeLabel(),
      throwsA(isA<StateError>()),
    );

    expect(
      photo.existsSync(),
      isFalse,
      reason: 'a failed recognition must not leave the photo on disk',
    );
  });

  test('returns null and touches nothing when the user cancels', () async {
    final adapter = FakeOcrAdapter();
    final service = LabelCaptureService(
      adapter: adapter,
      pickPhoto: () async => null,
    );

    expect(await service.captureAndRecognizeLabel(), isNull);
    expect(adapter.recognized, isEmpty);
  });

  test('treats an empty path as a cancellation', () async {
    final adapter = FakeOcrAdapter();
    final service = LabelCaptureService(
      adapter: adapter,
      pickPhoto: () async => '',
    );

    expect(await service.captureAndRecognizeLabel(), isNull);
    expect(adapter.recognized, isEmpty);
  });

  test('a picker failure propagates rather than looking like a cancel', () {
    // Denied camera permission arrives as a throw from the picker. Mapping
    // it to null would leave the user tapping a button that appears to do
    // nothing at all.
    final service = LabelCaptureService(
      adapter: FakeOcrAdapter(),
      pickPhoto: () async => throw StateError('camera_access_denied'),
    );

    expect(
      service.captureAndRecognizeLabel(),
      throwsA(isA<StateError>()),
    );
  });

  test('an already-deleted photo does not turn into a second failure', () {
    // Best-effort deletion: if the OS reclaimed the cache file first, the
    // recognition result still stands.
    final photo = writePhoto()..deleteSync();
    final service = LabelCaptureService(
      adapter: FakeOcrAdapter(result: singleLineOcrResult('Energy')),
      pickPhoto: () async => photo.path,
    );

    expect(
      service.captureAndRecognizeLabel(),
      completion(
        isA<OcrResult>().having((r) => r.fullText, 'fullText', 'Energy'),
      ),
    );
  });

  group('photos abandoned by a killed activity', () {
    // Android may destroy MainActivity while the OS camera is in front.
    // The `pickImage` future this process was waiting on then never
    // completes, so the `finally` that deletes the capture never runs and
    // the JPEG sits in the app cache indefinitely. `retrieveLostData` is
    // the only way to learn it exists (ADR 012, security_and_privacy S2).
    test('a recovered photo is deleted and never recognised', () async {
      final abandoned = writePhoto();
      final fresh = File(
        '${tempDir.path}${Platform.pathSeparator}fresh.jpg',
      )..writeAsBytesSync(const [0xFF, 0xD8]);
      final adapter = FakeOcrAdapter(result: singleLineOcrResult('Energy'));
      final service = LabelCaptureService(
        adapter: adapter,
        sweepLostPhotos: () async => [abandoned.path],
        pickPhoto: () async => fresh.path,
      );

      final result = await service.captureAndRecognizeLabel();

      expect(abandoned.existsSync(), isFalse);
      // Deleted, not read. The user is asking to scan a label *now*;
      // silently recognising whatever she photographed last time would be
      // both wrong and a surprise.
      expect(adapter.recognized, hasLength(1));
      expect((adapter.recognized.single as OcrImageFile).path, fresh.path);
      expect(result?.fullText, 'Energy');
      expect(fresh.existsSync(), isFalse);
    });

    test('several recovered photos are all deleted', () async {
      final first = writePhoto();
      final second = File(
        '${tempDir.path}${Platform.pathSeparator}second.jpg',
      )..writeAsBytesSync(const [0xFF, 0xD8]);
      final service = LabelCaptureService(
        adapter: FakeOcrAdapter(),
        sweepLostPhotos: () async => [first.path, second.path],
        pickPhoto: () async => null,
      );

      final result = await service.captureAndRecognizeLabel();

      // The user cancelled this time; the sweep still ran.
      expect(result, isNull);
      expect(first.existsSync(), isFalse);
      expect(second.existsSync(), isFalse);
    });

    test(
      'nothing to recover is the ordinary case and changes nothing',
      () async {
        final photo = writePhoto();
        final service = LabelCaptureService(
          adapter: FakeOcrAdapter(result: singleLineOcrResult('Protein')),
          sweepLostPhotos: () async => const [],
          pickPhoto: () async => photo.path,
        );

        final result = await service.captureAndRecognizeLabel();

        expect(result?.fullText, 'Protein');
        expect(photo.existsSync(), isFalse);
      },
    );
  });

  test('an unsupported adapter still gets the photo deleted', () async {
    final photo = writePhoto();
    final service = LabelCaptureService(
      adapter: FakeOcrAdapter(
        isSupported: false,
        result: const OcrResult.unsupported(),
      ),
      pickPhoto: () async => photo.path,
    );

    final result = await service.captureAndRecognizeLabel();

    expect(result?.isUnsupported, isTrue);
    expect(photo.existsSync(), isFalse);
  });
}
