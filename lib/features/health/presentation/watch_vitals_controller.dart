import 'package:menfit_app/core/platform/health/health_platform_support.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'watch_vitals_controller.g.dart';

/// What the watch vitals card shows. Loading and failure come from the
/// surrounding `AsyncValue`.
enum WatchVitalsStatus { unsupported, needsPermission, empty, data }

class WatchVitalsView {
  const WatchVitalsView(this.status, [this.snapshot]);

  final WatchVitalsStatus status;

  /// Set only for [WatchVitalsStatus.data].
  final HealthVitalsSnapshot? snapshot;

  @override
  String toString() => 'WatchVitalsView($status)';
}

/// Reads watch vitals on demand. State lives in this provider's memory
/// only — nothing is persisted or cached — and is gone when the card that
/// watches it is disposed (autoDispose).
@riverpod
class WatchVitalsController extends _$WatchVitalsController {
  /// Whether this session already showed the platform sheet. HealthKit
  /// cannot say whether access was granted, so an empty read before asking
  /// is shown as "connect", and after asking as "no recent data" — without
  /// this the iOS prompt would come back forever for a user with no watch.
  bool _requested = false;

  @override
  Future<WatchVitalsView> build() => _load();

  /// Reads the platform again.
  Future<void> refresh() async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(_load);
    // autoDispose: the card may be gone by the time the read finishes.
    if (!ref.mounted) return;
    state = next;
  }

  /// Shows the vitals permission sheet, then reads.
  Future<void> connect() async {
    _requested = true;
    state = const AsyncLoading();
    await ref.read(healthPlatformAdapterProvider).requestVitalsPermissions();
    if (!ref.mounted) return;
    final next = await AsyncValue.guard(_load);
    if (!ref.mounted) return;
    state = next;
  }

  Future<WatchVitalsView> _load() async {
    if (!healthPlatformSupported) {
      return const WatchVitalsView(WatchVitalsStatus.unsupported);
    }
    final adapter = ref.read(healthPlatformAdapterProvider);
    // Android without Health Connect installed is unsupported too.
    if (!await adapter.isSupported()) {
      return const WatchVitalsView(WatchVitalsStatus.unsupported);
    }
    final granted = await adapter.hasVitalsPermission();
    if (granted == false) {
      return const WatchVitalsView(WatchVitalsStatus.needsPermission);
    }
    final snapshot = await adapter.getVitals(now: DateTime.now());
    if (snapshot == null) {
      return const WatchVitalsView(WatchVitalsStatus.unsupported);
    }
    if (snapshot.isEmpty) {
      return WatchVitalsView(
        granted == null && !_requested
            ? WatchVitalsStatus.needsPermission
            : WatchVitalsStatus.empty,
      );
    }
    return WatchVitalsView(WatchVitalsStatus.data, snapshot);
  }
}

/// One displayed metric. `detail` carries sleep stages when present.
typedef WatchVitalRow = ({
  String label,
  String value,
  String asOf,
  String? detail,
});

/// Rows for every metric present in [s], in display order. Values only —
/// no ranges or interpretation of any metric.
List<WatchVitalRow> watchVitalRows(HealthVitalsSnapshot s) {
  String asOf(DateTime at) => asOfLabel(at, s.readAt);
  final sleep = s.sleep;
  return [
    if (s.latestHeartRateBpm case final v?)
      (
        label: 'Heart rate',
        value: '${v.round()} bpm',
        asOf: asOf(s.latestHeartRateAt ?? s.readAt),
        detail: null,
      ),
    if (s.restingHeartRateBpm case final v?)
      (
        label: 'Resting heart rate',
        value: '${v.round()} bpm',
        asOf: asOf(s.restingHeartRateAt ?? s.readAt),
        detail: null,
      ),
    if (s.bloodOxygenPercent case final v?)
      (
        label: 'Blood oxygen',
        value: '${v.round()} %',
        asOf: asOf(s.bloodOxygenAt ?? s.readAt),
        detail: null,
      ),
    if (sleep != null)
      (
        label: 'Sleep',
        value: formatSleepDuration(sleep.asleep),
        asOf: asOf(sleep.end),
        detail: _stages(sleep),
      ),
    if (s.hrvMs case final v?)
      (
        label: switch (s.hrvKind) {
          HrvKind.rmssd => 'Heart-rate variability (RMSSD)',
          HrvKind.sdnn => 'Heart-rate variability (SDNN)',
          null => 'Heart-rate variability',
        },
        value: '${v.round()} ms',
        asOf: asOf(s.hrvAt ?? s.readAt),
        detail: null,
      ),
    if (s.respiratoryRate case final v?)
      (
        label: 'Respiratory rate',
        value: '${v.toStringAsFixed(1)} breaths/min',
        asOf: asOf(s.respiratoryRateAt ?? s.readAt),
        detail: null,
      ),
  ];
}

String? _stages(SleepSummary sleep) {
  final parts = [
    if (sleep.deep case final d?) 'Deep ${formatSleepDuration(d)}',
    if (sleep.light case final d?) 'Light ${formatSleepDuration(d)}',
    if (sleep.rem case final d?) 'REM ${formatSleepDuration(d)}',
    if (sleep.awake case final d?) 'Awake ${formatSleepDuration(d)}',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// `7 h 30 min`, `45 min`, `8 h`.
String formatSleepDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h == 0) return '$m min';
  return m == 0 ? '$h h' : '$h h $m min';
}

/// "as of" text for a reading taken at [at], relative to the read time.
String asOfLabel(DateTime at, DateTime readAt) {
  final ago = readAt.difference(at);
  if (ago.inMinutes < 1) return 'as of just now';
  if (ago.inMinutes < 60) return 'as of ${ago.inMinutes} min ago';
  if (ago.inHours < 24) return 'as of ${ago.inHours} h ago';
  final days = ago.inDays;
  return days == 1 ? 'as of 1 day ago' : 'as of $days days ago';
}
