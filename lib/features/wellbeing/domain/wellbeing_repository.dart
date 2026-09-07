import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';

/// Persistence for daily wellbeing check-ins and flare-up events.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): never
/// logged, never denormalised into other tables — same handling as
/// `features/cycle/domain/cycle_repository.dart`.
abstract interface class WellbeingRepository {
  /// Emits the check-in logged for [day], or `null` if none exists, on
  /// every change.
  Stream<DailyCheckin?> watchCheckinFor(LocalDate day);

  /// One-shot fetch of the check-in logged for [day], or `null` if none exists.
  Future<DailyCheckin?> getCheckinFor(LocalDate day);

  /// Emits every check-in within the [days] days up to and including
  /// [today] (inclusive on both ends), newest day first, on every change.
  Stream<List<DailyCheckin>> watchRecentCheckins(int days, LocalDate today);

  /// Emits every check-in falling in the **inclusive** calendar range
  /// `[from, to]`, oldest day first, on every change.
  ///
  /// The arbitrary-range sibling of [watchRecentCheckins], which can only
  /// look backwards from a given day: a month calendar the user has paged
  /// back to needs a window that neither starts nor ends at today. Ordered
  /// oldest-first (the opposite of [watchRecentCheckins]) because a
  /// calendar reads forwards through a month, where a history list reads
  /// backwards from now.
  Stream<List<DailyCheckin>> watchCheckinsForRange(
    LocalDate from,
    LocalDate to,
  );

  /// One-shot fetch of the same window [watchRecentCheckins] emits: every
  /// check-in within the [days] days up to and including [today]
  /// (inclusive on both ends), newest day first.
  ///
  /// For aggregations that read the window once and then stop (recaps,
  /// insight discovery) — see
  /// `features/activity/domain/activity_repository.dart#getActivities` for
  /// why those must not be written as `watchRecentCheckins(...).first`.
  Future<List<DailyCheckin>> getRecentCheckins(int days, LocalDate today);

  /// Upserts [checkin] **by calendar day**, not by id: saving for a day
  /// that already has a check-in replaces it in place, preserving the
  /// existing row's `id` and `createdAt` (the persisted `updatedAt` is
  /// always stamped to UTC-now). Saving for a day with no existing
  /// check-in inserts a new row, normally using [checkin]'s own
  /// `id`/`createdAt` — **except** (F7 id-relocation guard) when
  /// [checkin]'s `id` already belongs to a *different* day's row, in which
  /// case a fresh id is generated for the new row instead: reusing an id
  /// already owned by another day would silently relocate that other
  /// day's row onto this one rather than creating a genuinely new row.
  /// There is at most one check-in per calendar day.
  Future<void> saveCheckin(DailyCheckin checkin);

  /// Permanently (hard-)deletes the check-in with [id] — not a soft
  /// delete, same S3 reasoning as
  /// `features/cycle/domain/cycle_repository.dart#deleteRecord`.
  Future<void> deleteCheckin(String id);

  /// Emits every flare **overlapping** the [days]-day window ending at
  /// [today] (inclusive on both ends), newest start day first, on every
  /// change.
  ///
  /// Overlap, not start: a multi-day flare that began before the window but
  /// runs into it is part of what happened during that window, so the
  /// history screen must show it. A flare qualifies when it starts on or
  /// before the window's last day *and* its [FlareEvent.lastDay] falls on
  /// or after the window's first day.
  Stream<List<FlareEvent>> watchRecentFlares(int days, LocalDate today);

  /// Emits every flare **overlapping** the inclusive calendar range
  /// `[from, to]`, oldest start day first, on every change.
  ///
  /// Same overlap rule as [watchRecentFlares] (a multi-day flare that began
  /// before the range but runs into it belongs to it), over an arbitrary
  /// range rather than a window ending today — see
  /// [watchCheckinsForRange] for why a month calendar needs that. A flare
  /// overlapping the range may extend outside it; callers that draw
  /// per-day markers read [FlareEvent.days] and ignore the days that fall
  /// outside what they are showing.
  Stream<List<FlareEvent>> watchFlaresForRange(LocalDate from, LocalDate to);

  /// Emits every flare **covering** [day] — one whose inclusive
  /// `[FlareEvent.day, FlareEvent.lastDay]` range contains it, whether or
  /// not it started on it — on every change. Multiple flares can cover the
  /// same day.
  Stream<List<FlareEvent>> watchFlaresOn(LocalDate day);

  /// One-shot fetch of every flare covering [day] (same range semantics as
  /// [watchFlaresOn]). Used where a caller needs today's flares
  /// synchronously-in-effect inside a one-off eligibility check (e.g. the
  /// recovery-prompt flow,
  /// `presentation/recovery_prompt_controller.dart`) rather than
  /// subscribing to [watchFlaresOn] for the lifetime of a widget that has
  /// already finished doing its one decision. Returns an empty list when
  /// nothing covers [day].
  Future<List<FlareEvent>> getFlaresOn(LocalDate day);

  /// Emits the set of calendar days **covered by** at least one logged
  /// flare whose [FlareEvent.impact] is [FlareImpact.unableToTrain] — the
  /// exact source `streaks/domain/streak_assembly.dart`'s protection source
  /// (b) draws from, on every change.
  ///
  /// Multi-day flares are expanded into their individual days here rather
  /// than emitted as ranges: a five-day couldn't-train flare protects all
  /// five days, and the streak engine consumes a flat day set (see
  /// `streaks/domain/streak_assembly.dart`), so expansion belongs on this
  /// side of the boundary. The expansion is capped per flare — see
  /// `domain/flare_event.dart`'s `maxFlareRangeDays`.
  ///
  /// F1: deliberately **unwindowed** (every such day, ever), unlike
  /// [watchRecentFlares]. Flare-based streak protection must never expire —
  /// a user who logged an unable-to-train flare a year ago is still
  /// entitled to that day counting as protected recovery today; a
  /// time-windowed query here would silently un-protect old days the
  /// moment they aged out of the window, contradicting
  /// `knowledge/product/terminology.md`'s "Protected Recovery" being a
  /// permanent, no-proof-required grant. [watchRecentFlares] stays
  /// windowed because its only consumer (the wellbeing history screen)
  /// genuinely only ever needs recent entries. The result set here stays
  /// small in practice — bounded by how many distinct days a user has ever
  /// logged an unable-to-train flare on, not by how many flares exist —
  /// so an unwindowed query is cheap enough not to need pagination.
  Stream<Set<LocalDate>> watchProtectingFlareDays();

  /// Upserts [flare] by id (a plain upsert, unlike [saveCheckin] — multiple
  /// flares per day are allowed, so there's no "day" identity to upsert
  /// against). Preserves the existing row's `createdAt` across an update.
  /// Persists [FlareEvent.endDay] as-is, including `null` for a single-day
  /// flare; callers should have run
  /// `domain/wellbeing_validation.dart#validateFlareEvent` (which owns the
  /// range rules) first.
  Future<void> saveFlare(FlareEvent flare);

  /// Permanently (hard-)deletes the flare with [id].
  Future<void> deleteFlare(String id);

  /// Emits every event logged for [day], on every change.
  Stream<List<WellbeingEvent>> watchEventsOn(LocalDate day);

  /// One-shot fetch of every event logged for [day].
  Future<List<WellbeingEvent>> getEventsOn(LocalDate day);

  /// Emits every event falling in the **inclusive** calendar range
  /// `[from, to]`.
  Stream<List<WellbeingEvent>> watchEventsForRange(
    LocalDate from,
    LocalDate to,
  );

  /// One-shot fetch of every event falling in the range `[from, to]`.
  Future<List<WellbeingEvent>> getEventsForRange(
    LocalDate from,
    LocalDate to,
  );

  /// Upserts [event] by id. Preserves existing createdAt if updating.
  Future<void> saveEvent(WellbeingEvent event);

  /// Permanently hard-deletes the event with [id].
  Future<void> deleteEvent(String id);

  /// Permanently deletes every check-in, flare, and event on this device
  /// (part of the "Delete my data" flow — S3 data is deleted first per
  /// security_and_privacy.md). Transactional across all tables.
  Future<void> deleteAllData();
}
