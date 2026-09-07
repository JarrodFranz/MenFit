import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/onboarding/onboarding_providers.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_trigger_evaluator.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recap_trigger_controller.g.dart';

/// Decides whether a monthly recap (`TASKS_TO_DO.md` Task 1.3) is due and
/// ready to present, and exposes the action to mark it shown once it has
/// been.
///
/// Watched from `presentation/widgets/recap_trigger_listener.dart`, which
/// `home/presentation/home_screen.dart` mounts through this feature's UI
/// composition surface (`recaps_widgets.dart`, ADR 007's amendment) — this
/// controller itself stays a `presentation/` internal, never imported by
/// another feature directly.
///
/// Default `autoDispose` (no `keepAlive`): the app keeps every shell
/// branch's navigator mounted offstage in an `IndexedStack`
/// (`activity_providers.dart#personalRecords`'s dartdoc documents the same
/// reality for a different provider), so this stays alive for as long as
/// Home does without needing to opt out of disposal — there's no
/// app-scoped reason for it to outlive that.
@riverpod
class RecapTriggerController extends _$RecapTriggerController {
  @override
  Future<MonthRecap?> build() async {
    // Must never fire during onboarding: the same completion flag the
    // router's redirect uses (`app/router/router.dart`) — Home is
    // unreachable until this is `true`, so this is a defence-in-depth
    // guard against an out-of-order build, not the only thing preventing
    // it from firing there.
    final onboardingComplete = ref.watch(onboardingStatusProvider);
    if (!onboardingComplete) return null;

    final showAutomaticRecaps = ref.watch(
      showAutomaticRecapsControllerProvider,
    );
    if (!showAutomaticRecaps) return null;

    final markerStore = ref.watch(recapMarkerStoreProvider);

    final due = evaluateRecapDue(
      today: LocalDate.today(),
      lastShownMonthKey: markerStore.getLastShownMonthKey(),
    );

    final period = switch (due) {
      MonthEndDue(:final period) => period,
      NothingDue() => null,
    };
    if (period == null) return null;

    // `RecapBuilder`'s sparse-data guard can still say "nothing worth
    // showing" for a nominally-due period - that is deliberately *not*
    // treated as shown here. Only [markShown] writes the marker, and it's
    // only called once the caller has actually presented a non-null
    // recap, so a sparse period is retried on the next check rather than
    // silently forgotten forever.
    return ref.watch(recapForPeriodProvider(period).future);
  }

  /// Marks the currently pending recap as shown, so it never surfaces
  /// again. Call this only once the caller has actually navigated to the
  /// story screen for it (see `RecapTriggerListener`) — never
  /// speculatively.
  Future<void> markShown() async {
    final recap = state.value;
    if (recap == null) return;

    final markerStore = ref.read(recapMarkerStoreProvider);
    await markerStore.markMonthShown(recap.period.key);

    ref.invalidateSelf();
  }
}
