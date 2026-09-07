import 'package:menfit_app/core/platform/wakelock/screen_awake.dart';

/// The [ScreenAwake] used in tests, and wherever holding the screen on is
/// not something to attempt.
///
/// Letting the screen sleep is the platform's normal behaviour, so doing
/// nothing here is a correct outcome rather than a stub awaiting an
/// implementation.
class NoopScreenAwake implements ScreenAwake {
  const NoopScreenAwake();

  @override
  Future<void> acquire() async {}

  @override
  Future<void> release() async {}
}
