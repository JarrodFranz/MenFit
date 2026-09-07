import 'dart:async';

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_providers.g.dart';

/// Provider for the platform health adapter (can be overridden in widget/unit tests).
@Riverpod(keepAlive: true)
HealthPlatformAdapter healthPlatformAdapter(Ref ref) {
  return HealthPlatformAdapter.create();
}

/// State for the health platform synchronization and permission management.
class HealthSyncState {
  const HealthSyncState({
    required this.isSupported,
    required this.hasPermissions,
    required this.isSyncing,
    this.latestSnapshot,
    this.errorMessage,
  });

  final bool isSupported;
  final bool hasPermissions;
  final bool isSyncing;
  final HealthDataSnapshot? latestSnapshot;
  final String? errorMessage;

  HealthSyncState copyWith({
    bool? isSupported,
    bool? hasPermissions,
    bool? isSyncing,
    HealthDataSnapshot? latestSnapshot,
    String? errorMessage,
  }) {
    return HealthSyncState(
      isSupported: isSupported ?? this.isSupported,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      isSyncing: isSyncing ?? this.isSyncing,
      latestSnapshot: latestSnapshot ?? this.latestSnapshot,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier controlling health synchronization, permission requests,
/// and live device data.
@Riverpod(keepAlive: true)
class HealthSync extends _$HealthSync {
  late HealthPlatformAdapter _adapter;

  @override
  HealthSyncState build() {
    _adapter = ref.watch(healthPlatformAdapterProvider);
    unawaited(_init());
    return const HealthSyncState(
      isSupported: false,
      hasPermissions: false,
      isSyncing: false,
    );
  }

  Future<void> _init() async {
    final supported = await _adapter.isSupported();
    final hasPerm = supported && await _adapter.hasPermissions();
    state = state.copyWith(
      isSupported: supported,
      hasPermissions: hasPerm,
    );
    if (hasPerm) {
      await syncToday();
    }
  }

  /// Requests permission from the user for Health Connect / HealthKit.
  Future<bool> requestPermissions() async {
    state = state.copyWith(isSyncing: true);
    try {
      final granted = await _adapter.requestPermissions();
      state = state.copyWith(
        hasPermissions: granted,
        isSyncing: false,
      );
      if (granted) {
        await syncToday();
      }
      return granted;
    } on Object catch (_) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Unable to connect to health platform.',
      );
      return false;
    }
  }

  /// Syncs data for today's date from the connected health platform.
  Future<void> syncToday() async {
    state = state.copyWith(isSyncing: true);
    try {
      final today = LocalDate.today();
      final snapshot = await _adapter.getSnapshotForDate(today);
      state = state.copyWith(
        isSyncing: false,
        latestSnapshot: snapshot ?? HealthDataSnapshot.empty(today),
      );
    } on Object catch (_) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync failed: could not read device steps.',
      );
    }
  }
}

/// Fetches health data snapshot for a specific date.
@riverpod
Future<HealthDataSnapshot?> dateHealthSnapshot(
  Ref ref,
  LocalDate date,
) async {
  final adapter = ref.watch(healthPlatformAdapterProvider);
  return adapter.getSnapshotForDate(date);
}
