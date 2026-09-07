import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_view_controller.freezed.dart';
part 'weight_view_controller.g.dart';

/// What the weight screen is currently showing. UI state only — no
/// numbers, no readings, nothing derived from the user's data.
@freezed
abstract class WeightViewState with _$WeightViewState {
  const factory WeightViewState({
    @Default(WeightRange.threeMonths) WeightRange range,
    @Default(WeightSeriesMode.readingsAndTrend) WeightSeriesMode seriesMode,
  }) = _WeightViewState;

  const WeightViewState._();
}

/// Holds the weight screen's view state. No domain rules live here — the
/// smoothing is in `domain/weight_trend.dart` and the window arithmetic in
/// `domain/weight_range.dart`.
///
/// Defaults to [WeightRange.threeMonths]: long enough that a 7-day trend
/// line has something to say and that two or three cycles are visible for
/// context, short enough that individual readings are still separable.
@riverpod
class WeightViewController extends _$WeightViewController {
  @override
  WeightViewState build() => const WeightViewState();

  void selectRange(WeightRange range) {
    state = state.copyWith(range: range);
  }

  void selectSeriesMode(WeightSeriesMode mode) {
    state = state.copyWith(seriesMode: mode);
  }
}
