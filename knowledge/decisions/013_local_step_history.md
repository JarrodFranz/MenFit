# 013 — Local daily step history

- **Status:** Accepted
- **Date:** 2026-09-03

## Context

Steps have been readable since `health 13.3.2` was adopted (2026-08-29, commit
`9f30b95`) — but only **today's**, and only by asking the platform. Three
consequences forced a decision:

1. **A chart costs one platform call per day.** `HealthPlatformAdapter` had a
   `getRecordsForRange` that looped `getSnapshotForDate` day by day, and each of
   those did a permission check plus a step query plus *two* energy queries. A
   35-day window was ~140 platform-channel round-trips, re-run on every rebuild,
   with nothing cached in between. Nothing ever called it.
2. **Web and Windows can never show history at all.** `health` has a top-level
   `dart:io` import, so it is reached through a conditional export and stubbed
   out on those targets. Without a local copy, a Windows build cannot display
   even the step history her phone already collected — it is not a degraded
   experience, it is a permanently empty screen.
3. **The empty state was being papered over.** The home "At a Glance" steps card
   drew a "Last 7d" tick row while steps were unconnected — the ticks are
   protected/recovery days from the streak engine, but next to a step ring they
   read as *step-goal days* (logged in `knowledge/product/deferred.md` from the
   2026-09-02 screen review). A card with no history to show had reached for a
   row of ticks that looked like one. That is the failure mode this decision
   removes: with real per-day totals there is something honest to draw, and when
   there is not, the screen says so.

## Options considered

- **Query the platform on every read, no storage.** Simplest, but is 1–3 above.
- **Store per-day totals locally (chosen).** One SQL query per chart, history
  survives on every platform, honest empty states.
- **Store raw step samples.** Vastly more rows for no gain: nothing in this app
  asks a question below day granularity, and intra-day samples are the most
  re-identifying shape this data comes in.
- **Derive steps from recorded activities instead.** Already what the app does
  for distance (ADR 008), and deliberately labelled "during tracked activities".
  It is not daily steps and must never be presented as them.

## Decision

Schema **v22** adds `daily_step_totals` — `day` (ISO-8601 text, **primary
key**), `steps`, `source` (nullable), `synced_at` (UTC ms). The steps feature
owns a repository over it (`features/steps/`), and `stepsSyncProvider` fills it
from `HealthPlatformAdapter`.

**`day` is the primary key**, not a UUID `id` with a unique index. Two step
readings for one day are two readings of the same accruing number, not two
facts (contrast `weight_logs`, where a morning and an evening weigh-in are
genuinely two facts and the day column is deliberately non-unique). Making the
day the key gives `insertOnConflictUpdate` its conflict target for free, and it
puts the uniqueness constraint *inside* the `CREATE TABLE` statement — which is
what makes the v22 migration step re-entrant with **zero** changes to the 45
pre-existing `database.migration.onUpgrade(...)` call sites in the migration
tests. A standalone
`createIndex` has no `IF NOT EXISTS` and would have obliged every one of them to
drop the table first (`knowledge/troubleshooting/database_migrations.md`).

**A missing day has no row.** Gaps are never filled with zeroes. A day nothing
was synced for and a day of genuinely zero steps are different statements, and
only the second is a number this app is entitled to make. Zero *is* stored when
the platform reports it.

### The sync

- `syncRecent({days = 35, force = false})` and `syncRange(start, end)`.
- **Throttle: `syncRecent` is a no-op if a sync succeeded less than an hour
  ago**, unless `force: true`. The only row that can change inside an hour is
  today's, and re-reading a month of days to refresh one accruing number is a
  poor trade against battery and Health Connect's rate limits. The throttle
  measures from the last *success*, so a failure never blocks the next attempt.
  `syncRange` is never throttled — an explicit range is always a deliberate ask.
- **Today is re-read on every non-throttled sync**, because the day is still
  accruing; the upsert overwrites rather than accumulating.
- **The window end is clamped to today, and a window starting after today is a
  no-op.** Callers pass calendar windows ("this week", "this month") whose end
  is routinely in the future. A health platform asked for a future interval may
  answer `0` rather than refusing, and storing that would be a claim that she
  took no steps on a day that has not happened — the one thing this ADR forbids
  outright. Clamping in `syncRange` makes it impossible rather than unlikely.
- **The gate is `hasStepsPermission()`, not `hasPermissions()`.** The latter is
  an OR across steps and the two energy types, so a user who granted only
  active energy passes it; gating on it would produce an empty chart that reads
  as "your data is missing" rather than "you have not granted step access".
- The notifier's time source is an injectable `clock` field
  (`@visibleForTesting`, defaulting to `DateTime.now`, passed to
  `LocalDate.today({clock})`). Without it the throttle's *expiry* is untestable
  — a hard-coded `DateTime.now` only ever proves that an immediate second call
  is suppressed, which "the throttle never lets go" would also pass.
- Outcomes are `{synced, noPermission, unsupported, failed}` and are mapped
  honestly. A user who has not granted health access is never told something
  went wrong, and `synced` is never claimed for a window that was not read.

### The ranged platform read

`getRecordsForRange`/`DailyHealthRecord` are replaced by
`getDailyStepTotals`/`DailyStepTotal` — steps only, one permission check for the
whole window, per-day step queries run **sequentially**. A 35-day window is 36
round-trips instead of ~140.

**`health 13.3.2` does offer a single bucketed call, and it is deliberately not
used.** `getHealthIntervalDataFromTypes(..., interval: 86400)` is one native
call on both platforms, but on both the bucketing is a **fixed-duration slicer
anchored at the range start**, not a calendar-day grouping: Android builds an
`AggregateGroupByDurationRequest` with
`timeRangeSlicer = Duration.ofSeconds(interval)`, and iOS an
`HKStatisticsCollectionQuery` whose `intervalComponents` sets `second =
interval`. A DST transition anywhere inside the window therefore shifts every
subsequent bucket an hour off the local calendar day and silently misattributes
the steps either side of it — in a day-by-day chart, exactly the error nobody
would ever notice. Android's aggregate path also reports an internal exception
as `result.success(null)`, which reaches Dart as an empty list indistinguishable
from "she took no steps". Passing real local midnights per day
(`DateTime(y, m, d)` to `DateTime(y, m, d + 1)`, built from calendar fields so
it survives DST) is exact, at one call per day. The single-day snapshot path was
moved onto the same boundary — it used `23:59:59`, which silently dropped the
final second of the day, so today's live card and today's stored row could
disagree over a step taken at 23:59:59.4. **Revisit only if the plugin gains
calendar-aware bucketing**; the count of calls is not the problem worth
trading correctness for.

## Reasons

The stored copy is what makes the feature exist on four platforms rather than
two, turns a chart from ~140 platform calls into one query, and gives every
screen something true to say when there is nothing to show.

## Consequences

### Privacy (S2 — health-platform data)

- **Never logged.** No step value enters a log line, an analytics payload, or an
  exception message: repository exceptions carry static strings, the sync
  swallows platform errors without writing them down (a health platform's error
  text can carry the values themselves), and `DailySteps.toString()`
  deliberately prints only the day.
- **Her toggle is the permission.** Every sync entry point returns without
  touching the adapter while `fitnessDeviceSyncControllerProvider` is off, and
  `stepsAvailabilityProvider` checks the toggle *before* the OS permission — so
  a user who declined at the app level is never prompted at the OS level.
- **Included in "Delete my data"**, hard-deleted alongside the rest of the S2
  tier (`settings_screen.dart`), and named in the confirmation dialog. The
  dialog's promise is bounded and the code says so: the health platform keeps
  its own copy, which only she can delete there.
- **Export is not yet implemented.** S2 data must be exportable as well as
  deletable (`security_and_privacy.md` rule 7); registered in
  `knowledge/product/deferred.md`.

### Schema

`schemaVersion` 21 → 22. The step is a bare `createTable`; **0** existing
`onUpgrade` fixtures changed. Nothing is seeded — no earlier column, table or
preference in this app holds a past day's step count, so any row the migration
invented would be a number nobody measured. The history starts empty and fills
on the next sync, which reads the real window back from the platform.

### iOS can never report read permission — found 2026-09-03

Verified in the plugin source (`ios/.../HealthDataOperations.swift`:
`hasPermission` returns `nil` for `access == 0`): **HealthKit never discloses
READ authorization**, because the answer would itself leak whether the user has
data of that type. `Health.hasPermissions(..., READ)` therefore returns `null`
on iOS forever, however many times the user granted access.

The adapter's `_hasReadPermission` resolves that as `granted ?? Platform.isIOS`
— unknown means *denied* on Android (which answers truthfully, so `null` there
is an anomaly) and *unknown, proceed* on iOS. Two consequences worth stating:

- **This also fixes a pre-existing latent bug.** The old `hasPermissions()`
  OR'd three `?? false` terms, so on iOS it returned `false` unconditionally,
  and `getSnapshotForDate` bailed out before reading anything. The home "At a
  Glance" steps/energy card could therefore never have shown data on iOS. Not
  verifiable from this Windows machine — registered in `platform_notes.md`.
- **Optimism cannot fabricate data.** With read access actually denied,
  `HKStatisticsCollectionQuery` fails, the plugin returns a `STEPS_ERROR`
  `FlutterError`, and `_stepsForDay` maps the throw to `null` — an **omitted**
  day, never a zero. What it costs is that on iOS a denied grant and a
  genuinely empty window are indistinguishable, so the outcome is reported as
  `synced` with nothing written. The platform makes that unavoidable; claiming
  `noPermission` there would be a guess, not honesty.

### API

`stepsAvailabilityProvider` is **synchronous**, returning `StepsAvailability`
directly. The one asynchronous part — `adapter.hasPermissions()` — is split into
`stepsPermissionProvider`, and while it is still resolving availability reads
`permissionNeeded`. That direction is deliberate: a moment of "we need
permission" that resolves itself is harmless, whereas defaulting to `available`
would have the UI ask for step data the app may have no right to.

`defaultDailyStepTarget` (7 500) now has one home, read through
`stepsTargetProvider`; it was previously a bare literal inside the home steps
ring. It is a **display default, not health advice**
(`knowledge/domain/mens_health.md`).

## Rejected alternatives

- **Raw step samples** — more rows, no question they answer, and the most
  re-identifying shape the data comes in.
- **A UUID `id` plus `UNIQUE(day)`** — the same constraint one indirection
  further away, and it would cost an explicit conflict target on every upsert.
- **Zero-filling missing days** — turns "we have not looked" into "she took no
  steps", the same class of mistake `null`-vs-`0` avoids for nutrients (v21).
