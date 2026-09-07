import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/sharing/share_plus_sharing_adapter.dart';
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';
import 'package:share_plus/share_plus.dart';

/// A scripted stand-in for `SharePlus.instance.share`, so every branch of
/// the mapping can be exercised without a plugin registrant.
class _ScriptedShare {
  _ScriptedShare({this.result, this.throws});

  final ShareResult? result;
  final Object? throws;

  ShareParams? lastParams;
  int calls = 0;

  Future<ShareResult> run(ShareParams params) async {
    calls++;
    lastParams = params;
    final error = throws;
    if (error != null) Error.throwWithStackTrace(error, StackTrace.current);
    return result!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final png = Uint8List.fromList([137, 80, 78, 71, 1, 2, 3]);

  SharePlusSharingAdapter adapterFor(
    _ScriptedShare platform, {
    TargetPlatform target = TargetPlatform.android,
    bool isWeb = false,
  }) => SharePlusSharingAdapter(
    runShare: platform.run,
    platform: target,
    isWeb: isWeb,
  );

  /// Captures whatever reaches the clipboard, since the fallback path
  /// writes there and nothing answers `SystemChannels.platform` in a
  /// unit test.
  String? Function() interceptClipboard() {
    String? captured;
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            captured =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    return () => captured;
  }

  group('capability flags', () {
    test('only Android, iOS and macOS report a share result', () {
      for (final target in TargetPlatform.values) {
        final adapter = SharePlusSharingAdapter(platform: target);
        final expected = const {
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        }.contains(target);
        expect(
          adapter.supportsShareResult,
          expected,
          reason: 'supportsShareResult for $target',
        );
      }
    });

    test('the web never reports a share result, whatever it runs on', () {
      final adapter = SharePlusSharingAdapter(
        platform: TargetPlatform.android,
        isWeb: true,
      );
      expect(adapter.supportsShareResult, isFalse);
    });

    test('Linux is the only platform that cannot attach a file', () {
      for (final target in TargetPlatform.values) {
        final adapter = SharePlusSharingAdapter(platform: target);
        expect(
          adapter.supportsFileShare,
          target != TargetPlatform.linux,
          reason: 'supportsFileShare for $target',
        );
      }
      expect(
        SharePlusSharingAdapter(
          platform: TargetPlatform.linux,
          isWeb: true,
        ).supportsFileShare,
        isTrue,
        reason: 'a browser on Linux shares files through the Web Share API',
      );
    });
  });

  group('ShareResultStatus maps to ShareOutcome', () {
    for (final (status, expected) in const [
      (ShareResultStatus.success, ShareOutcome.success),
      (ShareResultStatus.dismissed, ShareOutcome.dismissed),
      (ShareResultStatus.unavailable, ShareOutcome.unavailable),
    ]) {
      test('$status -> $expected where the platform reports results', () async {
        final platform = _ScriptedShare(
          result: ShareResult('raw', status),
        );
        final outcome = await adapterFor(platform).shareText('hello');
        expect(outcome, expected);
      });
    }

    test(
      'Windows never claims success, even if the plugin returns one',
      () async {
        // Belt and braces: share_plus_windows always returns `unavailable`
        // today, and the adapter must not start claiming a confirmed share
        // if that ever changes without the platform actually knowing.
        final platform = _ScriptedShare(
          result: const ShareResult('raw', ShareResultStatus.success),
        );
        final outcome = await adapterFor(
          platform,
          target: TargetPlatform.windows,
        ).shareText('hello');
        expect(outcome, ShareOutcome.unavailable);
      },
    );

    test('the web never claims success either', () async {
      final platform = _ScriptedShare(
        result: const ShareResult('raw', ShareResultStatus.success),
      );
      final outcome = await adapterFor(platform, isWeb: true).shareText('hi');
      expect(outcome, ShareOutcome.unavailable);
    });
  });

  group('a failing platform share falls back to the clipboard', () {
    test('text lands on the clipboard and says so', () async {
      final clipboard = interceptClipboard();
      final platform = _ScriptedShare(
        throws: PlatformException(code: 'Failed to launch'),
      );

      final outcome = await adapterFor(
        platform,
        target: TargetPlatform.windows,
      ).shareText('a code');

      expect(outcome, ShareOutcome.fellBackToClipboard);
      expect(clipboard(), 'a code');
    });

    test('an image share falls back to its text', () async {
      final clipboard = interceptClipboard();
      final platform = _ScriptedShare(
        throws: UnimplementedError('sharing files needs Windows 10.0.17763'),
      );

      final outcome = await adapterFor(
        platform,
        target: TargetPlatform.windows,
      ).shareImage(pngBytes: png, fileName: 'card.png', text: 'summary');

      expect(outcome, ShareOutcome.fellBackToClipboard);
      expect(clipboard(), 'summary');
    });

    test('an image share with no text has nothing to fall back to', () async {
      final platform = _ScriptedShare(throws: StateError('nope'));

      final outcome = await adapterFor(
        platform,
      ).shareImage(pngBytes: png, fileName: 'card.png');

      expect(outcome, ShareOutcome.unavailable);
    });
  });

  group('what actually reaches share_plus', () {
    test('an image goes as one PNG XFile with an explicit name', () async {
      final platform = _ScriptedShare(
        result: const ShareResult('raw', ShareResultStatus.success),
      );

      await adapterFor(platform).shareImage(
        pngBytes: png,
        fileName: 'menfit-workout-card.png',
        text: 'summary',
        sharePositionOrigin: const Rect.fromLTWH(1, 2, 3, 4),
      );

      final params = platform.lastParams!;
      expect(params.files, hasLength(1));
      expect(params.files!.single.mimeType, 'image/png');
      // `XFile.fromData`'s own name is ignored off the web; this is the
      // parameter that names the file for the receiving app.
      expect(params.fileNameOverrides, ['menfit-workout-card.png']);
      expect(params.text, 'summary');
      expect(params.sharePositionOrigin, const Rect.fromLTWH(1, 2, 3, 4));
      expect(await params.files!.single.readAsBytes(), png);
    });

    test('empty text is not handed over at all', () async {
      final platform = _ScriptedShare(
        result: const ShareResult('raw', ShareResultStatus.success),
      );

      // The plugin throws ArgumentError rather than opening an empty
      // sheet, so the adapter refuses before it gets there.
      expect(
        await adapterFor(platform).shareText(''),
        ShareOutcome.unavailable,
      );
      expect(platform.calls, 0);
    });

    test(
      'an empty text alongside an image is dropped, not sent empty',
      () async {
        final platform = _ScriptedShare(
          result: const ShareResult('raw', ShareResultStatus.success),
        );

        await adapterFor(
          platform,
        ).shareImage(pngBytes: png, fileName: 'card.png', text: '');

        expect(platform.lastParams!.text, isNull);
      },
    );

    test('Linux degrades an image share to its text', () async {
      final platform = _ScriptedShare(
        result: const ShareResult('raw', ShareResultStatus.unavailable),
      );

      final outcome = await adapterFor(
        platform,
        target: TargetPlatform.linux,
      ).shareImage(pngBytes: png, fileName: 'card.png', text: 'summary');

      expect(outcome, ShareOutcome.unavailable);
      expect(platform.lastParams!.files, isNull);
      expect(platform.lastParams!.text, 'summary');
    });
  });
}
