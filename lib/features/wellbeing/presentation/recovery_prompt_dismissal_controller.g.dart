// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_prompt_dismissal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks which calendar days the user has already dismissed the recovery
/// prompt for (`presentation/recovery_prompt_sheet.dart`) — **in-memory,
/// for this app session only, never persisted**. RULING (§5.9): "do not
/// re-prompt the same day after dismissal" is a same-session courtesy, not
/// a permanent preference — a fresh app launch tomorrow (or later today,
/// after a full restart) starts with a clean slate, and nothing here ever
/// touches Drift/SharedPreferences.
///
/// `@Riverpod(keepAlive: true)`: this state must survive across every
/// check-in save for the rest of the session (an autoDispose provider would
/// reset the moment nothing was watching it between check-ins), but its
/// scope is still bounded by the app process - there's no persistence
/// layer backing it, so "keepAlive" here means "for this run of the app,"
/// not "forever."

@ProviderFor(RecoveryPromptDismissalController)
final recoveryPromptDismissalControllerProvider =
    RecoveryPromptDismissalControllerProvider._();

/// Tracks which calendar days the user has already dismissed the recovery
/// prompt for (`presentation/recovery_prompt_sheet.dart`) — **in-memory,
/// for this app session only, never persisted**. RULING (§5.9): "do not
/// re-prompt the same day after dismissal" is a same-session courtesy, not
/// a permanent preference — a fresh app launch tomorrow (or later today,
/// after a full restart) starts with a clean slate, and nothing here ever
/// touches Drift/SharedPreferences.
///
/// `@Riverpod(keepAlive: true)`: this state must survive across every
/// check-in save for the rest of the session (an autoDispose provider would
/// reset the moment nothing was watching it between check-ins), but its
/// scope is still bounded by the app process - there's no persistence
/// layer backing it, so "keepAlive" here means "for this run of the app,"
/// not "forever."
final class RecoveryPromptDismissalControllerProvider
    extends
        $NotifierProvider<RecoveryPromptDismissalController, Set<LocalDate>> {
  /// Tracks which calendar days the user has already dismissed the recovery
  /// prompt for (`presentation/recovery_prompt_sheet.dart`) — **in-memory,
  /// for this app session only, never persisted**. RULING (§5.9): "do not
  /// re-prompt the same day after dismissal" is a same-session courtesy, not
  /// a permanent preference — a fresh app launch tomorrow (or later today,
  /// after a full restart) starts with a clean slate, and nothing here ever
  /// touches Drift/SharedPreferences.
  ///
  /// `@Riverpod(keepAlive: true)`: this state must survive across every
  /// check-in save for the rest of the session (an autoDispose provider would
  /// reset the moment nothing was watching it between check-ins), but its
  /// scope is still bounded by the app process - there's no persistence
  /// layer backing it, so "keepAlive" here means "for this run of the app,"
  /// not "forever."
  RecoveryPromptDismissalControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recoveryPromptDismissalControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$recoveryPromptDismissalControllerHash();

  @$internal
  @override
  RecoveryPromptDismissalController create() =>
      RecoveryPromptDismissalController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<LocalDate> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<LocalDate>>(value),
    );
  }
}

String _$recoveryPromptDismissalControllerHash() =>
    r'ea951daa2d7ece88dcdcbcc0978e6946ca9f17c0';

/// Tracks which calendar days the user has already dismissed the recovery
/// prompt for (`presentation/recovery_prompt_sheet.dart`) — **in-memory,
/// for this app session only, never persisted**. RULING (§5.9): "do not
/// re-prompt the same day after dismissal" is a same-session courtesy, not
/// a permanent preference — a fresh app launch tomorrow (or later today,
/// after a full restart) starts with a clean slate, and nothing here ever
/// touches Drift/SharedPreferences.
///
/// `@Riverpod(keepAlive: true)`: this state must survive across every
/// check-in save for the rest of the session (an autoDispose provider would
/// reset the moment nothing was watching it between check-ins), but its
/// scope is still bounded by the app process - there's no persistence
/// layer backing it, so "keepAlive" here means "for this run of the app,"
/// not "forever."

abstract class _$RecoveryPromptDismissalController
    extends $Notifier<Set<LocalDate>> {
  Set<LocalDate> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<LocalDate>, Set<LocalDate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<LocalDate>, Set<LocalDate>>,
              Set<LocalDate>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
