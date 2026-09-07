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

    /// The user's explicit choice about the cycle overlay, or `null` while
    /// she hasn't made one.
    ///
    /// Tri-state on purpose: the overlay's default is "on, but only for a
    /// user who tracks her cycle"
    /// (`presentation/weight_history_providers.dart#weightHasCycleContext`),
    /// which the controller cannot evaluate without reading cycle data it
    /// has no business reading. Storing `null` lets the widget resolve the
    /// default against that provider while an explicit `false` still wins
    /// over it.
    bool? cycleOverlayVisible,
  }) = _WeightViewState;

  const WeightViewState._();

  /// Whether to draw the overlay, given whether the user has any cycle
  /// data at all.
  bool overlayVisibleWhen({required bool hasCycleData}) =>
      hasCycleData && (cycleOverlayVisible ?? true);
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

  void setCycleOverlayVisible({required bool visible}) {
    state = state.copyWith(cycleOverlayVisible: visible);
  }
}
