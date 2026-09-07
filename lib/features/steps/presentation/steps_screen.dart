import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_view_controller.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_body.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_checking_panel.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

/// The daily-steps history: Week / Month bar chart, range summary, and the
/// day-by-day list. Reached at `/steps` from the home "At a Glance" steps
/// ring, the Progress screen's Daily Steps card, and the Walking hub.
///
/// ## What it refuses to do
///
/// It never fills a gap. A day the platform was never read for has no bar,
/// shows "No data" in the list, and is excluded from the average and the
/// at-target count — which is why both are captioned "of N days with data".
/// The alternative (treating an unsynced day as zero) would quietly report
/// an average they never walked, on a surface whose only job is to tell them
/// what happened.
///
/// ## Availability is a header, not a wall
///
/// Four different reasons produce "no *new* steps", and they are four
/// different sentences: no health platform on this device, sync switched
/// off, permission not granted, and simply nothing recorded yet.
///
/// For the first two the panel is a **header above the history, not a
/// replacement for it**: days a phone synced earlier are real data sitting
/// in the local database, and refusing to draw them on a laptop would lose
/// something the user already has. [StepsAvailability.permissionNeeded] is
/// the exception and stays panel-only — see [StepsBody].
///
/// This class owns the *asking*: the sync on open, the pull-to-refresh, and
/// the debounced fetch for whatever window the user navigates to.
/// [StepsBody] owns the drawing.
class StepsScreen extends ConsumerStatefulWidget {
  const StepsScreen({super.key});

  @override
  ConsumerState<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends ConsumerState<StepsScreen> {
  /// How long the anchor has to stop moving before the window it landed on
  /// is fetched. Three taps on "previous" are one intention, not three, and
  /// the notifier drops a `syncRange` that arrives while another is in
  /// flight — so firing per tap meant the 2nd and 3rd were silently lost
  /// and an older month rendered "30 days have no recorded step count",
  /// a false statement produced entirely by scheduling.
  static const Duration _rangeSettleDelay = Duration(milliseconds: 300);

  /// Set once a permission request has come back refused, so the panel can
  /// say so instead of silently re-offering the same button.
  bool _permissionRefused = false;

  /// Set when the platform never answered the access check in time.
  bool _checkTimedOut = false;

  Timer? _rangeSettleTimer;

  /// A window requested while a sync was already running. The notifier
  /// drops such calls rather than queueing them, so it is re-issued once
  /// [StepsSyncState.syncing] falls back to false.
  ({LocalDate start, LocalDate end})? _pendingRange;

  @override
  void initState() {
    super.initState();
    // After the first frame: the notifier mutates state, and doing that
    // during the build that mounted this screen is the classic
    // "setState during build" fault. Throttling lives in the data track's
    // `syncRecent`, so opening this screen repeatedly is cheap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(stepsSyncProvider.notifier).syncRecent());
    });
  }

  @override
  void dispose() {
    _rangeSettleTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(stepsSyncProvider.notifier).syncRecent(force: true);
  }

  /// Schedules a fetch for the window the user has navigated to, once they
  /// stop navigating.
  void _syncSelectedRange() {
    _rangeSettleTimer?.cancel();
    _rangeSettleTimer = Timer(_rangeSettleDelay, () {
      if (!mounted) return;
      _requestSelectedRange();
    });
  }

  /// Reads the *current* selection (never one captured when the timer was
  /// scheduled) and asks for it, or remembers it if a sync is already in
  /// flight.
  ///
  /// `syncRecent` only covers the recent window, so stepping back a few
  /// months would otherwise show gaps that are an artefact of the sync
  /// window rather than of their data.
  void _requestSelectedRange() {
    final view = ref.read(stepsViewControllerProvider);
    final range = view.period.rangeFor(view.anchor);
    if (ref.read(stepsSyncProvider).syncing) {
      _pendingRange = range;
      return;
    }
    _pendingRange = null;
    unawaited(
      ref.read(stepsSyncProvider.notifier).syncRange(range.start, range.end),
    );
  }

  /// Re-issues the window that was dropped, the moment the sync that
  /// dropped it finishes.
  void _onSyncStateChanged(StepsSyncState? previous, StepsSyncState next) {
    final wasSyncing = previous?.syncing ?? false;
    if (!wasSyncing || next.syncing) return;
    final pending = _pendingRange;
    if (pending == null) return;
    _pendingRange = null;
    unawaited(
      ref
          .read(stepsSyncProvider.notifier)
          .syncRange(pending.start, pending.end),
    );
  }

  Future<void> _requestPermission() async {
    final granted = await ref
        .read(healthSyncProvider.notifier)
        .requestPermissions();
    if (!mounted) return;
    setState(() {
      _permissionRefused = !granted;
      if (granted) _checkTimedOut = false;
    });
    if (granted) {
      // `stepsPermissionProvider` asked the platform once, before the grant;
      // nothing else invalidates it, so without this the screen would keep
      // showing the permission panel after they had just said yes.
      ref.invalidate(stepsPermissionProvider);
      await ref.read(stepsSyncProvider.notifier).syncRecent(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final availability = ref.watch(stepsAvailabilityProvider);
    final syncState = ref.watch(stepsSyncProvider);
    final isAvailable = availability == StepsAvailability.available;

    ref.listen(stepsSyncProvider, _onSyncStateChanged);

    // `stepsAvailabilityProvider` is synchronous, so "still asking the
    // platform" and "the platform said no" both surface as
    // `permissionNeeded`. Only in that one case is the underlying future
    // consulted, to tell them apart — watching it unconditionally would
    // defeat the short-circuit that keeps web/Windows and a switched-off
    // toggle from touching the health platform at all.
    final isChecking =
        availability == StepsAvailability.permissionNeeded &&
        !_checkTimedOut &&
        ref.watch(stepsPermissionProvider).isLoading;

    final scrollView = Align(
      // Pinned to the top: a Center around a shrink-wrapping scroll view
      // floats short content mid-screen (architecture_overview.md).
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(tokens.spacingMd),
          child: isChecking
              ? StepsCheckingPanel(
                  key: const Key('stepsCheckingPanel'),
                  onTimeout: () {
                    if (!mounted) return;
                    setState(() => _checkTimedOut = true);
                  },
                )
              : StepsBody(
                  availability: availability,
                  permissionRefused: _permissionRefused,
                  stillChecking: _checkTimedOut,
                  onRequestPermission: _requestPermission,
                  onRangeChanged: _syncSelectedRange,
                  syncFailed: syncState.lastOutcome == StepsSyncOutcome.failed,
                ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(stepsScreenTitle),
        actions: [
          if (isAvailable)
            IconButton(
              key: const Key('stepsRefreshAction'),
              icon: const Icon(Icons.refresh),
              tooltip: stepsRefreshTooltip,
              onPressed: syncState.syncing ? null : () => unawaited(_refresh()),
            ),
        ],
        bottom: syncState.syncing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: SafeArea(
        child: isAvailable
            ? RefreshIndicator(onRefresh: _refresh, child: scrollView)
            : scrollView,
      ),
    );
  }
}
