import 'package:menfit_app/core/domain/local_date.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recovery_prompt_dismissal_controller.g.dart';

/// Tracks which calendar days the user has already dismissed the recovery
/// prompt for (`presentation/recovery_prompt_sheet.dart`) — **in-memory,
/// for this app session only, never persisted**. RULING (§5.9): "do not
/// re-prompt the same day after dismissal" is a same-session courtesy, not
/// a permanent preference — a fresh app launch tomorrow (or later today,
/// after a full restart) starts with a clean slate, and nothing here ever
/// touches Drift/SharedPreferences.
///
/// `@Riverpod(keepAlive: true)`: this state must survive across every
/// check-in save for the rest of the session (an autoDispose provider would
/// reset the moment nothing was watching it between check-ins), but its
/// scope is still bounded by the app process - there's no persistence
/// layer backing it, so "keepAlive" here means "for this run of the app,"
/// not "forever."
@Riverpod(keepAlive: true)
class RecoveryPromptDismissalController
    extends _$RecoveryPromptDismissalController {
  @override
  Set<LocalDate> build() => const {};

  /// Whether the recovery prompt has already been dismissed for [day] this
  /// session.
  bool isDismissed(LocalDate day) => state.contains(day);

  /// Records that the recovery prompt was dismissed for [day] - the next
  /// check-in save on the same day won't offer it again this session.
  void dismiss(LocalDate day) => state = {...state, day};
}
