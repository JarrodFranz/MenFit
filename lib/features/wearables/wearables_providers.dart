import 'dart:async';

import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/platform/wearables/watch_companion_adapter.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/wearables/domain/wearable_workout_sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wearables_providers.g.dart';

@Riverpod(keepAlive: true)
WatchCompanionAdapter watchCompanionAdapter(Ref ref) {
  return WatchCompanionAdapter.create();
}

@Riverpod(keepAlive: true)
WearableWorkoutSyncService wearableWorkoutSyncService(Ref ref) {
  return WearableWorkoutSyncService(
    healthAdapter: ref.watch(healthPlatformAdapterProvider),
    watchAdapter: ref.watch(watchCompanionAdapterProvider),
    activityRepository: ref.watch(activityRepositoryProvider),
  );
}

/// State of wearable synchronization and companion connectivity.
class WearablesState {
  const WearablesState({
    required this.isSyncing,
    this.lastResult,
    this.companionInfo,
    this.errorMessage,
  });

  final bool isSyncing;
  final WearableSyncResult? lastResult;
  final WatchCompanionInfo? companionInfo;
  final String? errorMessage;

  WearablesState copyWith({
    bool? isSyncing,
    WearableSyncResult? lastResult,
    WatchCompanionInfo? companionInfo,
    String? errorMessage,
  }) {
    return WearablesState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastResult: lastResult ?? this.lastResult,
      companionInfo: companionInfo ?? this.companionInfo,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class WearablesController extends _$WearablesController {
  @override
  WearablesState build() {
    unawaited(_refreshCompanionInfo());
    return const WearablesState(isSyncing: false);
  }

  Future<void> _refreshCompanionInfo() async {
    final adapter = ref.read(watchCompanionAdapterProvider);
    final info = await adapter.getCompanionInfo();
    state = state.copyWith(companionInfo: info);
  }

  /// Triggers a full sync of external workouts from Garmin / Health Connect
  /// and connected watch companions.
  Future<WearableSyncResult> syncAll({DateTime? since}) async {
    state = state.copyWith(isSyncing: true);
    try {
      final service = ref.read(wearableWorkoutSyncServiceProvider);
      final result = await service.syncAll(since: since);
      await _refreshCompanionInfo();
      state = state.copyWith(
        isSyncing: false,
        lastResult: result,
      );
      return result;
    } on Object catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: e.toString(),
      );
      return WearableSyncResult(
        syncedCount: 0,
        duplicatesSkippedCount: 0,
        syncedAt: DateTime.now().toUtc(),
        errorMessage: e.toString(),
      );
    }
  }
}
