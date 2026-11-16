# Data Architecture

*Initial design 2026-08-25. Fork note (2026-09-07): cycle tracking and the
`CycleRecord` entity were removed at the fork from FemFit (ADR 017); S3 now
means health check-ins, flares, body weight and precise location. Conceptual
— entities are built feature-by-feature, not all at once. Update as schemas
land.*

## Principles

- Drift is the on-device source of truth (ADR 003); offline-first with outbox sync (ADR 004).
- **Every row: UUIDv7 id, client-generated at creation.**
- Syncable tables: `updated_at` (UTC ms), `deleted_at` (soft delete), `sync_status`.
- Timestamps stored UTC; presentation converts. Units stored canonical metric (m, kg, kcal); presentation converts.
- Sensitivity tier (see engineering/security_and_privacy.md) is part of each entity's design; S3 data is never joined-and-stored into other tables — join at query time.

## Likely entities & relationships (conceptual map)

```
UserProfile 1—* Goal
UserProfile 1—* TrustedContact                      (safety feature; S1)
Activity 1—* ActivitySample (track points; S2)       Activity *—1 Route (optional)
Activity 1—* Split (derived, cacheable)
Route (standalone: suggested or extracted; S2)
Workout(template) 1—* WorkoutExercise —* ExerciseSet(template)
YogaSequence 1—* YogaPose (poses are a JSON blob, not a child table; S1)  landed schema v23 as `yoga_sequences`
WorkoutSession(performed) 1—* PerformedSet           WorkoutSession *—1 Workout (optional)
Exercise (catalogue, seeded + user-custom)
Food 1—* NutritionEntry                              NutritionEntry *—1 Meal(slot)
  both carry the same 18 nutrition columns (v21); NutritionEntry's are a log-time snapshot
WeightLog (body weight time series; S3)               landed schema v18 as `weight_logs`
BodyMetric (other body metrics; S3, future)
DailyStepTotal (one row per calendar day, day is the PK; S2)  landed schema v22 as `daily_step_totals`
DailyCheckin / FlareEvent / RecoveryDay (health check-ins, flares, recovery days; S3)
StreakState (derived; stores paused-day facts, minimal reason detail)
HealthMetric (imported HR etc.; S2, future - steps landed at v22, see above)
SocialPost / Comment / Relationship / Challenge      (future, backend-dependent)
```

## Calendar-day semantics (ruled 2026-08-26, for flares + streaks)

Flare/check-in records and streak evaluation operate on **user-local calendar days**, not instants. Day values are stored as ISO-8601 date strings (`YYYY-MM-DD`) captured in the user's local timezone at logging time; they are compared lexically/as dates, never converted through UTC instants (a flare that starts "today" starts today regardless of timezone travel). Instant-based data (activities) maps onto days via the user's local timezone at evaluation time.

## Analytics semantics (ruled 2026-08-27, Phase E review)

GPS samples persist **including** fixes accepted during pause (full honest route for maps) but carry `isPaused` (schema v4). All analytics (splits, best efforts, PRs) are **segment-aware**: paused samples are excluded, distance/time never accumulate across a pause gap, and a best-effort window never spans a pause (no vehicle-during-pause PRs). Consequence: split sums reconcile with the activity's headline `distanceMeters`/`movingTime`, which use the same reset-across-pause rule at record time. PR ties credit the **earliest** record-setter.

## Body weight: profile value vs history (ruled 2026-09-01, schema v18; S3)

`user_profiles.weight_kg` stays the app's **current** weight — several features read it directly (activity energy/MET maths, BMR/TDEE estimates, the progress card). `weight_logs` (v18) is the **history**: multiple rows per day allowed (morning/evening weigh-ins are real; a unique-by-day table would silently discard one), ISO day strings, hard delete with no `deleted_at`/`sync_status` (S3, and ED-sensitive: a deleted weigh-in must actually be gone). Ordering on every read is chronological (oldest first) because the consumers are trend/EMA engines and charts, not history lists.

The relationship is **one-way, profile → log**: the v18 migration seeds one `source = 'profile-migration'` row from the profile's existing weight (dated the migration day — the profile carries no measurement date, and back-dating a series would fabricate measurements), and `ProfileController.updateProfile` writes a further `manual` log whenever the profile weight actually changes. Nothing writes back the other way; smoothing/trend resolution lives above the repository.

## Nutrition columns: foods and nutrition_entries move together (schema v21, 2026-09-03)

Both tables carry the **same eighteen** nutrition columns per serving:
`calories_kcal`, `protein_grams`, `carbs_grams`, `fat_grams` (NOT NULL) and
fourteen nullable ones — `saturated_fat_grams`, `trans_fat_grams`,
`monounsaturated_fat_grams`, `polyunsaturated_fat_grams`, `fiber_grams`,
`sugars_grams`, `added_sugars_grams`, `sodium_mg`, `potassium_mg`,
`cholesterol_mg`, `iron_mg`, `calcium_mg`, `vitamin_d_mcg`, `vitamin_c_mg`.
Canonical metric units, named for the unit they hold. S2 (nutrition logs):
never logged, never in analytics, never in an exception message.

**`null` means unknown, never zero.** Most labels state only some nutrients,
and writing `0` for "not stated" turns a gap in the data into a claim about
the food. Totals honour that: `NutritionFacts.plus` returns `null` only when
*neither* side stated a nutrient, so a sum is a floor rather than a guess,
and `scaled`/the range daily average keep `null` as `null`.

**The two tables have to move together.** `nutrition_entries` snapshots the
food's per-serving facts at log time (so editing or deleting a food never
rewrites history). Giving `foods` a nutrient the entry table lacks would just
move the data loss one step later — the food would keep it, every entry
logged from it would not. v21 added all thirteen optional nutrients to both
tables in one step for exactly that reason. The thirteen were collected and
validated by the food form from S1-5 onwards but had no columns, so
`saveFood` discarded them silently; v21 closed that.

No index on any of them: nothing filters or orders by nutrient, they are read
as part of a row the query already selected.

## Daily steps: a local copy of a fact the platform owns (ruled 2026-09-03, schema v22)

`daily_step_totals` (v22) stores **one row per calendar day** — ISO day string
as the **primary key**, plus `steps`, a nullable platform `source` label, and
`synced_at`. ADR 013 has the full reasoning; the parts that constrain future
work:

- **The day is the key, deliberately unlike `weight_logs`.** Two weigh-ins in a
  day are two facts; two step readings for a day are two readings of the *same*
  accruing number, and the later one supersedes the earlier entirely. So the
  repository upserts by day and today's row is rewritten on every sync.
- **A missing day has no row — gaps are never zero-filled.** "Nothing was
  synced" and "the user took no steps" are different statements and only the second
  is a number this app may make. Zero *is* stored when the platform reports it.
  Same discipline as v21's `null`-means-unknown nutrients.
- **It is a cache, not the source of truth.** The health platform keeps its own
  copy; this table is what lets a chart be one SQL query instead of ~35
  platform-channel calls, and it is the only reason web/Windows can show
  history the phone collected. "Delete my data" hard-deletes it, and the
  confirmation dialog is careful not to promise more than that.
- **No `id`, no `deleted_at`, no `sync_status`** — no backend yet (ADR 004), and
  a soft-deleted step total would mean nothing.
- **No index.** The one-row-per-day uniqueness *is* the primary key, emitted
  inside `CREATE TABLE`, which is what made the v22 step re-entrant with zero
  fixture changes.

## Yoga sequences: poses as a blob, starters as a constant (ruled 2026-09-04, schema v23)

`yoga_sequences` (v23) stores one row per user-built sequence: `id` (UUIDv7),
`name`, `description`, `poses_json`, `transition_seconds`, a nullable `style`,
timestamps and `deleted_at`. The constraints it sets for later work:

- **Poses are a JSON blob, exactly like `strength_routines.exercises_json`.**
  A pose has no identity of its own — never queried, aggregated or referenced
  from elsewhere, only ever moving with its sequence, and reordering is the
  commonest edit. A child table would buy a foreign key and an ordering column
  and cost a join on every read. The price is paid at the boundary: a row whose
  blob will not parse is **skipped** by `DriftYogaSequenceRepository`, not
  thrown from, so one unreadable sequence cannot take the whole list down.
  Nothing about the blob's content is logged — it is text the user typed.
- **A one-sided pose is two entries, not a flag.** `YogaPoseSide` (none/left/
  right) is stored per pose so the runner can time and announce each side
  independently ("Warrior II, left").
- **The transition applies between poses, never after the last one.**
  `totalDuration` = sum of holds + `transitionSeconds × (poseCount − 1)`, and a
  one-pose sequence has no transition at all.
- **Starters are a domain constant, never rows.** `YogaSequenceStarters` holds
  two sequences under fixed ids (`starter-morning-flow`, `starter-wind-down`);
  `watchSequences()` returns stored rows and nothing else, so an empty list
  honestly means "the user has saved nothing". Accepting a starter saves
  `starter.copyAsNew()` — a fresh UUIDv7, their row, theirs to edit or delete. The
  fixed ids exist so the offer can identify what is on screen, never as
  database keys.
- **No index.** Identity is the primary key, emitted inside `CREATE TABLE`,
  which is what made the v23 step re-entrant with zero fixture changes (same
  as v19/v20/v22).
- **S1-tier, but wiped like the rest.** Self-authored training content, not a
  health measurement — still theirs, so "Delete my data" hard-deletes every row,
  soft-deleted ones included.

## Derived vs stored

Splits, PRs, weekly aggregates, streaks are **derived** — recomputable from raw data. Cache them in tables only when profiling demands; when cached, treat as invalidatable, never authoritative.

## Protected-recovery streaks (signature feature — superseded the paused-only model 2026-08-27, S1-2)

The streak engine walks per-day `DayStatus` (completedActivity / protectedRecovery / unscheduled; planned* statuses arrive with Stage 2 plans). **Protected days** are the union of: explicit recovery days (`recovery_days` table — a user-logged fact, the streaks feature's sanctioned data/ layer) and flares with impact "couldn't train". Satisfied beats protected; today-pending never breaks; predictions never protect; everything is a pure retroactive recompute — no streak state is ever stored. Protection reasons are not inferable from the home screen (neutral presentation).

## GPS tracks

`activity_samples` relational table (activity_id FK, t, lat, lon, ele, accuracy, hr…) with batch inserts; downsample for display; keep raw for recompute (PRs, splits). Collapse finished activities to encoded polyline blobs only if profiling shows bloat.

## Sync (when backend arrives — ADR 004)

Outbox drained on foreground/connectivity; per-collection `updated_since` pull cursors; LWW by `updated_at`. S3-tier sync additionally requires separate consent + the E2E-encryption design from the backend ADR.


## MenFit schema v2/v3 (2026-11-16)

The earlier numbered migrations in this document describe the source app;
MenFit shipped its own v1 baseline. v2 adds `ketone_readings`, v3 adds nullable
`foods.provider_food_id` plus the nonunique `(source, provider_food_id)` index.
A fixture captured from shipped v1 verifies forward migration preserves data.

Ketone readings are a separate S3 log with UUIDv7 id, captured local day,
measurement UTC instant, measurement method/result text and creation/update UTC
instants. Multiple readings per day are retained. Numeric text preserves entered
precision and literal LO/HI; urine retains its printed scale. No cross-method
conversion or derived physiology is persisted. No soft-deletion/sync columns
until a real sync design exists.

Food provider identity is separate from the retail barcode. The v3 repair moves
unambiguous old FatSecret ids out of barcode, preserves ambiguous codes, and is
idempotent. The same repair runs after restoring food rows from older backups.
