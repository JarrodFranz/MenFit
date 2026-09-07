import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_overview_controller.freezed.dart';
part 'progress_overview_controller.g.dart';

@freezed
abstract class ProgressOverviewState with _$ProgressOverviewState {
  const factory ProgressOverviewState({
    required ProgressPeriod period,
    required LocalDate anchor,
  }) = _ProgressOverviewState;
}

@riverpod
class ProgressOverviewController extends _$ProgressOverviewController {
  @override
  ProgressOverviewState build() {
    return ProgressOverviewState(
      period: ProgressPeriod.week,
      anchor: LocalDate.today(),
    );
  }

  void selectPeriod(ProgressPeriod period) {
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

  void goToToday() {
    state = state.copyWith(anchor: LocalDate.today());
  }
}
