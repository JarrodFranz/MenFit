/// How the last step sync attempt ended.
///
/// Mapped honestly: [failed] is never used to paper over a missing
/// permission, and [synced] is never reported for a window that wrote
/// nothing because the platform refused it. The UI says different things for
/// each of these, and a user who has simply not granted permission must not
/// be told something went wrong.
enum StepsSyncOutcome {
  /// The window was read and written. It may legitimately have contained no
  /// days (a platform with nothing recorded in that range).
  synced,

  /// The health platform is present but has not granted read access to
  /// steps. Nothing was written.
  noPermission,

  /// There is no health platform on this device (web, Windows, or an
  /// Android device with no Health Connect). Nothing was written.
  unsupported,

  /// The platform threw. Nothing partial is claimed and nothing is
  /// rethrown — a background sync must never take the app down.
  failed,
}

/// Whether step syncing can happen at all right now, and if not, why.
///
/// The four values are ordered by what the user would have to do about them,
/// most fundamental first: nothing can be done about [unsupportedPlatform],
/// [syncOff] is a switch in Settings, [permissionNeeded] is an OS prompt,
/// and [available] needs nothing. The UI shows a different, honest empty
/// state for each rather than one generic "no data".
enum StepsAvailability {
  /// No health platform exists on this device (web, Windows, desktop). Step
  /// history may still be *shown* here if a phone synced some — this only
  /// says nothing new can be read on this device.
  unsupportedPlatform,

  /// The user's fitness-device sync toggle is off. Her stated preference is
  /// that this app does not read her health platform, and it is honoured
  /// before any permission is even checked.
  syncOff,

  /// Sync is on and the platform exists, but read access to steps has not
  /// been granted.
  permissionNeeded,

  /// Steps can be read now.
  available,
}

/// State of the steps sync notifier.
///
/// S2: carries no step values — only whether a sync is running, when the
/// last one succeeded, and how the last attempt ended.
class StepsSyncState {
  const StepsSyncState({
    this.syncing = false,
    this.lastSyncedAt,
    this.lastOutcome,
  });

  /// True while a sync is in flight. A second sync started during the first
  /// is a no-op rather than a queued duplicate.
  final bool syncing;

  /// UTC instant of the last **successful** sync, or null if none has ever
  /// succeeded. This is what the throttle in
  /// `StepsSync.syncRecent` measures against, so a failed
  /// attempt never blocks the next one.
  final DateTime? lastSyncedAt;

  /// How the most recent attempt ended, or null before the first attempt.
  final StepsSyncOutcome? lastOutcome;

  StepsSyncState copyWith({
    bool? syncing,
    DateTime? lastSyncedAt,
    StepsSyncOutcome? lastOutcome,
  }) {
    return StepsSyncState(
      syncing: syncing ?? this.syncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastOutcome: lastOutcome ?? this.lastOutcome,
    );
  }

  @override
  // Immutable in substance; `package:meta` is unavailable in domain/ (see
  // `daily_steps.dart`).
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    return other is StepsSyncState &&
        other.syncing == syncing &&
        other.lastSyncedAt == lastSyncedAt &&
        other.lastOutcome == lastOutcome;
  }

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(syncing, lastSyncedAt, lastOutcome);

  @override
  String toString() =>
      'StepsSyncState(syncing: $syncing, lastOutcome: $lastOutcome)';
}
