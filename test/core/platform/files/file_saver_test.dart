import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/files/file_saver.dart';

void main() {
  group('FileSaver', () {
    test('conforms to expected functional signature', () async {
      var called = false;
      String? recordedFileName;
      Uint8List? recordedBytes;
      String? recordedMimeType;
      String? recordedDialogTitle;

      Future<Uri?> customSaver({
        required String fileName,
        required Uint8List bytes,
        required String mimeType,
        String? dialogTitle,
      }) async {
        called = true;
        recordedFileName = fileName;
        recordedBytes = bytes;
        recordedMimeType = mimeType;
        recordedDialogTitle = dialogTitle;
        return Uri.parse('file:///saved/$fileName');
      }

      expect(customSaver, isA<FileSaver>());
      final result = await customSaver(
        fileName: 'test.json',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'application/json',
        dialogTitle: 'Custom Title',
      );

      expect(called, isTrue);
      expect(recordedFileName, 'test.json');
      expect(recordedBytes, Uint8List.fromList([1, 2, 3]));
      expect(recordedMimeType, 'application/json');
      expect(recordedDialogTitle, 'Custom Title');
      expect(result, Uri.parse('file:///saved/test.json'));
    });
  });
}
