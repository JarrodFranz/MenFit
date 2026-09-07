import 'package:menfit_app/core/platform/wakelock/screen_awake.dart';
import 'package:menfit_app/core/platform/wakelock/wakelock_plus_screen_awake.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'screen_awake_providers.g.dart';

/// The app's single [ScreenAwake].
///
/// No platform branch: `wakelock_plus` has an implementation on all four
/// targets and the adapter degrades to a swallowed failure where it cannot
/// act (see [WakelockPlusScreenAwake]). There is nothing a capability flag
/// would decide here that the adapter does not already handle.
///
/// `keepAlive` because the lock is a piece of process-wide state, not a
/// screen's: one owner for it means one place that can be asked to let go.
/// It is deliberately **not** released on provider disposal — a lock is
/// held by a session that knows when its session ends, and disposing the
/// container is not that moment.
///
/// Tests override it with
/// `test/core/platform/wakelock/fake_screen_awake.dart`, or with
/// `NoopScreenAwake` — no test should ever reach the real plugin.
@Riverpod(keepAlive: true)
ScreenAwake screenAwake(Ref ref) => WakelockPlusScreenAwake();
