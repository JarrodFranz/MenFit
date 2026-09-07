import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'steps_view_controller.freezed.dart';
part 'steps_view_controller.g.dart';

/// The periods the steps screen offers.
///
/// [ProgressPeriod.day] is deliberately absent: a single day's steps is one
/// number, and the ring on the dashboard already shows it. The screen this
/// list feeds exists to show a *shape* over time, which needs at least a
/// week. Reusing [ProgressPeriod] rather than declaring a third range enum
/// keeps `rangeFor`/`previous`/`next`/`formatRange` in one place.
const List<ProgressPeriod> stepsPeriods = [
  ProgressPeriod.week,
  ProgressPeriod.month,
];

@freezed
abstract class StepsViewState with _$StepsViewState {
  const factory StepsViewState({
    required ProgressPeriod period,
    required LocalDate anchor,
  }) = _StepsViewState;
}

@riverpod
class StepsViewController extends _$StepsViewController {
  @override
  StepsViewState build() {
    return StepsViewState(
      period: ProgressPeriod.week,
      anchor: LocalDate.today(),
    );
  }

  /// Ignores [ProgressPeriod.day] — see [stepsPeriods]. Silently, because
  /// the only caller is a segmented button that never offers it; this is a
  /// guard against a future caller, not a user-facing outcome.
  void selectPeriod(ProgressPeriod period) {
    if (!stepsPeriods.contains(period)) return;
    state = state.copyWith(period: period);
  }

  void previous() {
    state = state.copyWith(anchor: state.period.previous(state.anchor));
  }

  void next() {
    final today = LocalDate.today();
    if (state.period.canGoForward(state.anchor, today)) {
      state = state.copyWith(anchor: state.period.next(state.anchor, today));
    }
  }
}
