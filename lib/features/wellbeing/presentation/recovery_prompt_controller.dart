import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/recovery_prompt.dart';
import 'package:menfit_app/features/wellbeing/presentation/recovery_prompt_dismissal_controller.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';

/// Orchestrates the §5.9 recovery-decision prompt's eligibility check for
/// `presentation/checkin_sheet.dart` (F2, extracted out of the widget) —
/// fetches the live inputs `domain/recovery_prompt.dart#evaluateRecoveryPromptEligibility`
/// needs and hands the actual yes/no decision to that pure function, then
/// exposes the two follow-up actions (accept/dismiss) the sheet calls
/// based on the user's answer.
///
/// A plain class, not a `@riverpod` provider: its job runs exactly once
/// per check-in save, imperatively, from `checkin_sheet.dart`'s
/// post-`Navigator.pop()` async flow — there's no ongoing state for a
/// widget to `ref.watch`, so a codegen'd provider would add ceremony
/// without buying anything. It's handed a [ProviderContainer] rather than
/// a `Ref`/`WidgetRef` because the caller's own `context`/`ref` may
/// already be disposed by the time [evaluate] resolves (same "capture a
/// container across the async gap, not `ref`" reasoning `checkin_sheet.dart`
/// already documents for itself).
class RecoveryPromptController {
  const RecoveryPromptController(this._container);

  final ProviderContainer _container;

  /// Evaluates whether the prompt should be offered for the just-saved
  /// [checkin] on [day]. [isToday] is the caller's own notion of "is this
  /// today" (typically `day == LocalDate.today()`), passed through rather
  /// than recomputed here so a caller that already has a fixed "today" in
  /// hand (e.g. for a test) doesn't race a fresh [LocalDate.today] read
  /// against its own.
  Future<RecoveryPromptDecision> evaluate({
    required LocalDate day,
    required DailyCheckin checkin,
    required bool isToday,
  }) async {
    // F2: past-day edits never prompt - short-circuit before touching any
    // repository, since none of the rest of this data is needed for that
    // answer.
    if (!isToday) return RecoveryPromptDecision.notToday;

    final alreadyDismissed = _container
        .read(recoveryPromptDismissalControllerProvider)
        .contains(day);

    final streak = _container.read(streakResultProvider).value;
    final todayStatus = streak?.todayStatus ?? DayStatus.unscheduled;

    // F2: fetch today's flares fresh from the repository (a one-shot
    // future, not `flaresOnDayProvider(day).value` read cold) - that
    // provider's cached `.value` is only populated once something has
    // actually subscribed to it; reading it cold before anything has
    // silently treats "nobody's watching yet" the same as "no flares
    // logged," which is exactly why a flare logged with no check-in
    // scores at all used to fail to trigger this prompt.
    final todaysFlares = await _container
        .read(wellbeingRepositoryProvider)
        .getFlaresOn(day);

    return evaluateRecoveryPromptEligibility(
      checkin: checkin,
      todaysFlares: todaysFlares,
      todayStatus: todayStatus,
      alreadyDismissed: alreadyDismissed,
      isToday: isToday,
    );
  }

  /// Marks [day] as a protected recovery day — called after the user
  /// accepts the prompt ("Make it a recovery day").
  Future<void> acceptRecoveryDay(LocalDate day) {
    return _container.read(recoveryRepositoryProvider).markRecoveryDay(day);
  }

  /// Records that the prompt was dismissed for [day] this session — called
  /// after "Keep training", or any other non-acceptance dismissal (e.g. a
  /// scrim tap). Session-only, never persisted — see
  /// `RecoveryPromptDismissalController`'s dartdoc.
  void dismiss(LocalDate day) {
    _container
        .read(recoveryPromptDismissalControllerProvider.notifier)
        .dismiss(day);
  }
}
