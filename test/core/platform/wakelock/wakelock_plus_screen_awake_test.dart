import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/wakelock/wakelock_plus_screen_awake.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// The platform interface is a transitive dependency of `wakelock_plus`, and
// substituting it is the only way to observe what the adapter asked the
// platform for without a device. Not promoted to a direct dependency for one
// test double.
// ignore: depend_on_referenced_packages
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

/// Records every toggle the adapter asks for, and can be made to fail the
/// way an unsupported device does.
class _FakePlatform extends WakelockPlusPlatformInterface {
  _FakePlatform({this.failEnable = false});

  final bool failEnable;
  final List<bool> toggles = [];

  @override
  Future<void> toggle({required bool enable}) async {
    if (enable && failEnable) throw UnsupportedError('no wakelock here');
    toggles.add(enable);
  }

  @override
  Future<bool> get enabled async => toggles.isNotEmpty && toggles.last;
}

void main() {
  late _FakePlatform platform;
  final original = wakelockPlusPlatformInstance;

  void install(_FakePlatform fake) {
    platform = fake;
    wakelockPlusPlatformInstance = fake;
  }

  setUp(() => install(_FakePlatform()));
  tearDown(() => wakelockPlusPlatformInstance = original);

  test('the first acquire enables, and only the first', () async {
    final lock = WakelockPlusScreenAwake();

    await lock.acquire();
    await lock.acquire();

    expect(platform.toggles, [true]);
  });

  test('the screen stays on until the last holder lets go', () async {
    // The scenario this counting exists for: a GPS recording running while
    // they open another hub on top of it, then discards that one.
    final lock = WakelockPlusScreenAwake();
    await lock.acquire();
    await lock.acquire();

    await lock.release();
    expect(
      platform.toggles,
      [true],
      reason:
          'one holder letting go must not switch the screen off under '
          'the session that is still running',
    );

    await lock.release();
    expect(platform.toggles, [true, false]);
  });

  test('a release with nothing held does nothing at all', () async {
    final lock = WakelockPlusScreenAwake();

    await lock.release();

    expect(platform.toggles, isEmpty);
  });

  test('an unmatched release banks no credit against a later one', () async {
    final lock = WakelockPlusScreenAwake();
    await lock.release();

    await lock.acquire();
    await lock.release();

    expect(platform.toggles, [true, false]);
  });

  test('acquire again after a full release re-enables', () async {
    final lock = WakelockPlusScreenAwake();
    await lock.acquire();
    await lock.release();

    await lock.acquire();

    expect(platform.toggles, [true, false, true]);
  });

  test('a device that cannot enable is retried, not written off', () async {
    // The count alone would look satisfied after the failed first attempt;
    // tracking the platform state separately is what lets the next holder
    // try again.
    install(_FakePlatform(failEnable: true));
    final lock = WakelockPlusScreenAwake();

    await lock.acquire();
    await lock.acquire();

    expect(platform.toggles, isEmpty);
  });

  test('a failed enable leaves nothing to disable', () async {
    install(_FakePlatform(failEnable: true));
    final lock = WakelockPlusScreenAwake();
    await lock.acquire();

    await lock.release();

    expect(platform.toggles, isEmpty);
  });
}
