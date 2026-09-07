import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cycle_records_controller.g.dart';

/// Watches every non-deleted [CycleRecord], newest period-start first (same
/// shape as `features/activity/presentation/activity_list_controller.dart`'s
/// `ActivityListController`).
@riverpod
class CycleRecordsController extends _$CycleRecordsController {
  @override
  Stream<List<CycleRecord>> build() {
    final repository = ref.watch(cycleRepositoryProvider);
    return repository.watchRecords();
  }

  /// Soft-deletes the record with [id].
  Future<void> deleteRecord(String id) async {
    final repository = ref.read(cycleRepositoryProvider);
    await repository.deleteRecord(id);
  }
}

/// Watches whether streak pausing during a logged period is enabled.
@riverpod
class StreakPausingController extends _$StreakPausingController {
  @override
  Stream<bool> build() {
    final repository = ref.watch(cycleRepositoryProvider);
    return repository.watchStreakPausingEnabled();
  }

  /// Persists the streak-pausing preference.
  Future<void> setEnabled({required bool enabled}) async {
    final repository = ref.read(cycleRepositoryProvider);
    await repository.setStreakPausingEnabled(enabled: enabled);
  }
}
