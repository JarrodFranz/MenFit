# Feature Ideas Backlog

*Unscheduled product ideas. Promotion into the roadmap is a product decision.
Rewritten 2026-09-07 at the fork from FemFit (ADR 017): the "named by product
owner" and women's-health sections below described features removed in the
fork (cycle tracking, cycle-phase training) and have been replaced. The
engineering "shipped rules" sections further down describe invariants of
code that still exists and are kept, edited only to remove language and
mechanisms specific to the removed cycle feature.*

## Named by product owner (high priority)

- **Flare-protected streak pausing** — fitness streaks pause automatically
  while the user has a logged flare with "couldn't train" impact, or an
  explicit recovery day (opt-in logging drives it).
- **Trusted-contact live tracking** — a list of contacts who can watch the
  user's live location during a run/exercise session; likely a tokenised web
  link so watchers don't need the app.
- **Route suggestion by distance** — given a km target (and start point),
  suggest sensible running routes.
- **Estimated 1RM per exercise** — derive an estimated one-rep max from
  logged sets (Epley/Brzycki) and surface it on the exercise history.
- **Bulk / cut / maintain calorie targets** — a named-goal wrapper over the
  existing calorie-target machinery, instead of a bare number.

## Running / activity

- Audio cues (pace/splits) during runs; interval workout guidance.
- Route difficulty/elevation preview; surface type; lit-streets preference for night safety.
- Weather-aware run suggestions; heat/hydration warnings.
- Auto-pause; treadmill (non-GPS) mode.

## Strength / recovery

- Estimated 1RM trend per exercise, correlated with logged sets.
- Flare-aware training recommendations (lighter session suggestion after a
  logged flare) — **requires evidence review + disclaimers before
  implementation**, per `knowledge/domain/mens_health.md`.
- Symptom logging (energy, sleep, soreness) correlated with performance.

## Nutrition

- Barcode scanning; recipe builder.
- Photo logging (nutrition-label OCR) — evaluated 2026-09-03 (ADR 012,
  proposed, awaiting product owner go/no-go on adoption).
- Bulk/cut/maintain calorie-target presets (evidence-gated per `domain/nutrition.md`).

## Social & safety

- Clubs/groups with strong moderation controls.
- Post-run auto check-in ("I'm home safe") notifications to trusted contacts.
- Ghost-mode / privacy zones around home & work for shared activities (widely regarded as table stakes — Strava heatmap incidents are the cautionary tale).
- Challenges that account for flare-protected recovery days fairly.

## Platform

- Home-screen widgets; watch companion apps; wearable import (Garmin/Fitbit/Apple Watch); Strava import.
- AI insights layer (trend explanations, plan generation) — additive only, per product constraint.

## Recap and insights engine shipped rules (2026-09-01, recorded so nobody re-derives them from code)

- **Recap sparse-data guard is kind-dependent**: month recap ⇒ ≥3 sessions
  inside that month — a single stale record from an unrelated feature must
  never produce a hollow monthly interruption. One recap per app sitting;
  the runner-up waits for the next Home mount.
- **Insights are descriptive-by-construction**: the domain result type has no
  string fields, so causal/prescriptive/population claims are unrepresentable.
  Gates (static const, non-bypassable): ≥10 paired observations, ≥4 per arm,
  relative difference ≥10% AND Cliff's δ ≥0.33 (higher for any
  multiple-comparison-corrected split). Below threshold an insight does not
  exist.

## Weight history shipped rules (2026-09-01, Tasks 2.1/2.2 — recorded so nobody re-derives them)

- **Trend default is the 7-day rolling median, not EMA** — an EMA absorbs a
  single-day fluid or measurement spike into the "true trend" line, which is
  exactly the misreading the chart exists to prevent. A median with >=5
  points cannot be moved by one outlier. Consistent with the insights
  engine's median-over-mean stance. EMA exists as a documented option and
  restarts after gaps longer than the window.
- **The engine never fabricates a reading**: gaps are not interpolated, trend
  values require >=3 real readings in the trailing calendar window, and below
  5 logged days there is no trend line at all (raw dots only).
- **No valence anywhere**: direction is rising/falling/steady/undetermined,
  net-change numbers are computed but deliberately not rendered, and the
  forbidden-vocabulary list (gain/loss/progress/goal/target/should/healthy
  weight) is enforced by test over all copy.
- **Deletion is hard** (no soft-delete column on weight_logs — S2/ED-sensitive
  precedent shared with water_logs); the delete dialog does not restate the
  number.
- **Multiple weigh-ins per day are stored un-collapsed**; latest-per-day is a
  trend-layer concern. Domain ordering is oldest-first (time series), UI may
  reverse.

## Achievements shipped rules (2026-09-01, Task 1.8 domain half)

- Tiers only on unbounded progressable metrics; ladders are open-ended by
  rule (arithmetic steps for counts/distances, geometric for tonnage) so
  nobody ever tops out. Bronze->Diamond then Diamond II, III...
- Badge ids are PERMANENT once shipped (awards key on them). Awards are
  one row per (badgeId, tierKey) crossing and are NEVER revoked, even when
  the data that earned them is deleted.
- Weekly-consistency ladders pro-rate the ask to the non-protected days:
  `activeDays = 7 - protectedDays`, protection counting regardless of
  whether the user also trained that day, and ALL distance/reps logged in the
  week count towards the pro-rated figure. A fully-protected week counts
  unconditionally, even with nothing logged. Tally, never a streak - a quiet
  month costs nothing already earned.
  - CORRECTION (2026-09-01 review): an earlier draft deducted only
    protected days the user had NOT trained on. That made training on a
    protected day strictly worse than resting - 1 km on a protected day
    turned an unconditional week into a 2,142.9 m ask. The binding rule is
    only "a protected week never voids a tier week"; the not-deducted
    refinement was an error. Invariant to keep: adding activity can never
    un-qualify a week.
- Excluded on principle, permanently: any weight/appearance badge
  (gamified weigh-ins), nutrition-adherence badges (compliance
  scoreboard), streak-length badges (double-counts the streak engine and
  turns a broken streak into a lost badge).
- No back-dated awards at migration: the detector awards on the next
  visit, dated honestly to then.
- "Is this day protected" now has ONE decision source:
  streaks/domain/streak_assembly.dart#assembleProtectedDays, exposed via
  protectedDaysProvider - consume it, never re-derive.

## Buddy challenges shipped rules (2026-09-01, Task 1.7 domain half)

- PRIVACY INVARIANT: a progress code carries exactly four things - challenge
  id, self-chosen display name, one percentage, as-of date. Never raw
  work, never the adjusted target; each side pro-rates privately, only the
  ratio crosses. Enforced structurally (encode API cannot express more) and
  byte-level tested.
- NO LOSER IS EXPRESSIBLE: participants expose displayName/percent/
  reachedGoal only; no leader, no ordering, no delta. Both-reached-goal is
  the celebrated outcome. (Percentages measure different private targets -
  ranking them would be meaningless anyway.)
- Fairness = the corrected weekly-training rule transplanted: protection
  only lowers the ask; activity anywhere in the window always counts; a
  fully protected window reads 100%.
- Codes: versioned (FC1/FP1) + CRC-16; unknown versions/bits rejected
  whole, never partly honoured; activity-type bit order frozen append-only
  (pinned by test). Challenge id = base64url of the 12 defining bytes
  (documented departure from UUIDv7 - both devices derive the same id from
  the code alone; duplicate join = PK collision).
- Excluded from v1, registered not forgotten: water/check-in challenge
  kinds (compliance-scoreboard risk), overlapping personal-schedule windows
  (participants' training weeks do not align), QR generation (needs a
  package evaluation).

### Tracker duration rule (shipped 2026-09-02)

A tracker must never silently record wall clock across an idle gap. Strength,
swim and mindful stamp `lastInteractionAt` on real logged
work only - never from the ticker - and when the gap since the last
interaction exceeds the tracker's idle threshold the Finish dialog explains
it and offers BOTH durations (trimmed to last interaction / full wall clock).
The app asks; it does not trim on its own, because "left running" and
"trained without logging until the end" are indistinguishable without
evidence. GPS recording is the exception that CAN trim against evidence:
auto-pause after 10s without a fix, and distance across a silence is never
drawn as a straight line.

## Daily steps screen shipped rules (2026-09-03, `/steps` UI half)

- **A day with no row is never drawn as a number.** No bar in the chart (the
  x-slot stays so a week still reads as seven columns), "No data" in the daily
  list, a hollow ring on the home card's 7-day strip — never a zero, never an
  interpolation, never a tick. A *recorded* zero is a real bar and a real value;
  the two facts are kept apart in the type (`StepsDayView.steps` is nullable).
- **Averages and the at-target count are taken over days WITH data only**, and
  the caption says so ("of N days with data"). Dividing by calendar days would
  turn every unsynced day into a silent zero and report an average the user
  never walked.
- **Four availability states, four different sentences** — no health platform
  on this device / sync toggle off / permission not granted / nothing recorded
  yet. Only the last is an empty chart; the other three explain themselves and
  offer the one action that helps (none at all for the unsupported case, since
  offering a button would imply one could help).
- **The 7-day strip on the home "At a Glance" card used to be fake** — indices
  0-3 always ticked and 4-5 always grey, on every install, forever; only today
  reflected data. `StepsWeekStrip` replaced it and
  `test/features/steps/steps_week_strip_test.dart` is the regression guard.
- **7 500 is a display default, not health advice**, and it has exactly one
  definition (`features/steps/domain/steps_target.dart` via
  `stepsTargetProvider`). The ring, its strip and the steps screen read the
  same number; nothing in the app tells the user it is a figure they ought to hit.
- **Copy carries no verdict.** "Days at target" is a count, never a judgement;
  the screen has no praise and no scolding for either side of the line.
- **Reuses `ProgressPeriod`** (week/month, `rangeFor`/`previous`/`next`/
  `formatRange`) rather than a third range enum; Day is hidden because one
  day's steps is a single number the dashboard ring already shows. The current
  `ProgressPeriod` range is clamped to today, so days that have not happened
  yet are not counted as missing data.
- Panel-above-history (2026-09-03 follow-up): on `unsupportedPlatform` and `syncOff` the explanatory panel
  is a header and any history a phone synced earlier still renders beneath it with copy that says so;
  `permissionNeeded` stays panel-only (a chart under a question reads as its answer). A "Checking step
  access…" state covers the permission lookup so a permitted device never flashes the prompt.

## Recovery calendar shipped rules (`features/wellbeing`, 2026-09-03)

- **Glyphs, never colour alone.** Each day cell draws up to three distinct
  icons — check-in (`Icons.self_improvement`), flare-up
  (`Icons.local_fire_department`), recovery day (`Icons.shield`) — and they are
  the *same* icons the history cards use, single-sourced in
  `features/wellbeing/presentation/widgets/wellbeing_glyphs.dart`. Colour only
  ever accompanies a glyph. A legend under the grid names all three; without
  it the markers are three unexplained symbols.
- **Forward navigation stops at the current month** (`MonthCalendar.latestMonth`),
  button *and* swipe — nothing can be logged on a month that has not happened.
  Future days inside the current month still render (they are part of the month)
  but carry no markers, and their day sheet says the day hasn't happened yet and
  offers nothing: every logging flow in the feature is bounded at today, so an
  action there would only lead to a rejected save.
- **The grid is queried over its own CELL span, not the calendar month**
  (`monthCalendarGridRange`), and leading/trailing neighbouring-month cells are
  marked like any other day. A flare running 30 Sep - 2 Oct is drawn by both
  months' grids; gating markers on "is this day in the displayed month" made the
  grid disagree with the sheet those same cells open, and made a trailing day
  announce "nothing logged" over a day that had records. Dimmed day numbers are
  what keep the borrowed cells readable as another month's.
- **The day sheet builds no editors.** Check-in hands off to `CheckinSheet` for
  that day, a flare row reuses `FlareTile` (which opens `FlareDialog` to edit),
  and the recovery row is `RecoveryTile` with its existing remove-and-undo. A
  second set of editors would be a second set of validation rules to keep in
  step. The check-in sheet is stacked *over* the day sheet rather than replacing
  it, so the day underneath is already showing the new answers when it pops.
- **"Log a flare-up" is offered only on today**, because `FlareDialog` has no
  entry point that opens on a chosen day (its family key is the flare being
  edited). Offering it on a past day would log against the wrong date. Giving
  `FlareController` an initial-day parameter is the follow-up that would remove
  the asymmetry. It sits *outside* the section's empty case: multiple flares per
  day are allowed, so a day that already has one must still be able to take
  another.
- **"Mark as a recovery day" IS offered on any day up to today**, because
  `MarkRecoveryDayDialog` can be opened on a chosen day — it now takes an
  `initialDay` so the user does not have to re-find in a picker the date they
  just tapped. Retroactive marking is that dialog's whole purpose, and the
  date stays fully editable with `lastDate: today` still bounding it.
- **Removing a recovery day from the day sheet closes the sheet.** Not
  cosmetic: `RecoveryTile` raises its undo snackbar on the root
  `ScaffoldMessenger`, which paints it in the root `Scaffold` — *underneath* a
  bottom sheet. With the sheet open, Undo is covered and a tap on it silently
  lands on the sheet (`tester.tap` only warns when the hit test finds a
  different widget, so this failed as an unrestored row rather than an error).
  The tile takes an optional `onRemoved` and the sheet passes "close me"; the
  history list passes nothing and is unchanged. **Any future sheet that
  raises a snackbar with an action has this problem.**
- **A failed read is never drawn as an absence.** `.value ?? []` on S3 health
  data would turn a `StorageException` into "nothing logged" — a claim about
  the user's records made from data the app never read. On `hasError` the
  calendar shows "Couldn't load this month." beside the grid and the sheet
  "Couldn't load this day.", both alongside the content rather than replacing
  it: the dates are still right and still tappable, only the markers are
  unknown.
- **The check-in sheet's heading names the day it is saving against**
  (`checkinSheetTitle`): "How are you feeling today?" for today, "How were you
  feeling on Wednesday 12 August?" otherwise. It was hard-coded to the present
  tense while today's card was the only way in.
- **The calendar legend reuses the cards' words on purpose**, which means the
  legend and a history card can show the same text at once. Legend items carry
  stable keys (`wellbeingLegendFlare` etc.) and flow tests that mean "the card"
  scope to `FlareTile`/`RecoveryTile` rather than the legend being renamed —
  renaming it to "Flare-up logged" would not have helped, since the finders that
  collided use `textContaining`.
- **A stored-but-blank check-in is not a marked day** (`DailyCheckin.isEmpty`) —
  the grid, the sheet's check-in section and the history list all agree on that.
- **Copy carries no verdict.** Empty sections state a fact ("No check-in
  logged."), never a prompt about a day that got away; unanswered scores are
  omitted rather than shown as a dash, because a question the user chose to
  skip is not a gap in the record. The disclaimer footer is unchanged.

## Activity tab shipped rules (2026-09-03)

- **Hubs first.** The Activity tab's top section is "Exercise Hubs": one tile
  per `ActivityType`, and a tile opens that type's hub (`/activity/hub/:type`)
  directly - no intermediate options sheet, because every launcher that sheet
  offered (live tracker, route suggestion, manual entry) already lives in the
  hub. Record and Log Previous sit under the tiles as a fixed pair, and there
  is **no floating Record button** - it duplicated the button one row above and
  covered the At a Glance cards.

## Home dashboard shipped rules (2026-09-03, redesign)

- **Home is today's essentials, nothing else.** Six cards, in this order:
  steps (ring + real 7-day strip), water, nutrition today (energy + the
  three macros), this week's volume, the most recent badge, and a plain
  "Today" summary. Everything on it is either a number the user opens the
  app to glance at or a one-tap way into the screen that owns it.
- **A nav-bar destination is never duplicated as a tile.** Each secondary
  route through a tile that duplicated the nav bar or a card was removed:
  each was a second, worse route to a place the nav bar or a card already
  reaches. Adding a tile back is a product decision, not a layout one.
- **Two things above the cards are not cards and stay:** the streak banner
  (which reports today's protection and, when today *is* protected, opens
  the Today sheet) and the check-in prompt (which removes itself once
  today's check-in is logged or dismissed).
- **The dashboard names no health detail.** The streak banner has been
  deliberately reason-silent since the streak engine's protected-recovery
  rework (protection is multi-source, and naming the source on an
  always-visible surface both implies a reason on sight and leaks it to a
  shoulder-surfer). The "Today" card therefore counts **explicit recovery
  days only** - never a flare detail, never a training-load inference - and
  no health vocabulary appears anywhere on Home. A widget test asserts this.
- **`hideCalorieNumbers` removes the energy line entirely** from the
  nutrition card - not blanked, not greyed, not dashed. Macros stay. Copy is
  "N of M kcal" / "N g of M g"; there is no "remaining", no "over", and the
  bars clamp at full.
- **One definition per number.** The steps ring card lives in
  `features/steps` and is mounted by both Home and Activity; the week's
  volume comes from `progress`' `weeklySummariesProvider`; the energy target
  comes from the diary's `dayCalorieTargetProvider` (which owns the "the
  user's own target, else the estimate with the BMR floor" rule). Home
  re-derives none of them.
- **Layout:** one column on a phone, two alternating columns from the medium
  window size class up - two `Column`s, never a `GridView`, because a grid
  needs one aspect ratio for cards of six different heights and that is
  exactly what overflowed the old dashboard grid at large text sizes.

## Yoga sequences shipped rules (2026-09-04, ADR 014)

- **The Yoga hub leads with sequences, not styles.** Order on
  `ActivityType.yoga` only: a "Sequences" card
  (`presentation/hub/yoga_sequences_card.dart`, subtitle *"Poses with timed
  holds and a chime between them"*), then the style card. Pilates keeps the
  style card alone — a Pilates sequence is a `type` column away and is not
  built.
- **Every sequence in the list is one the user saved.** `watchSequences()`
  returns stored rows only. The two starters (`YogaSequenceStarters`) are
  domain constants with fixed ids that are *never persisted*: the empty
  state offers "Add Morning flow" / "Add Wind down", which save
  `starter.copyAsNew()` — a fresh id, the user's row, editable and deletable
  without the starter moving. A starter id reaching the database is a bug.
- **Each row: name, `N poses · mm:ss`, style if set, a "Practise" button
  into the runner, and an overflow menu (Edit / Delete).** Delete confirms,
  then offers Undo, and Undo *re-saves the same entity* — soft delete means
  the original id comes back, not a near-copy. "New sequence" is always
  present, empty list or not.
- **Style vocabulary has exactly one home.** `MindfulStyles` (domain) feeds
  the tracker chips, the hub's style card (all 7 yoga / 5 pilates), and the
  editor's style picker. The chip label *is* the string passed to
  `setStyle`, so the tracker arrives pre-selected;
  `mindful_styles_source_of_truth_test.dart` fails on any style literal
  outside that file. The per-style copy map in `mindful_custom_section.dart`
  is allowed to name them because its key set is asserted equal to the
  source of truth. **Still outstanding:** `manual_entry_screen.dart` holds
  its own `['Vinyasa Flow', 'Restorative Yin', …]` literal — it shares no
  label with `MindfulStyles`, so the guard does not catch it.
- **The hub no longer invents a focus.** With no history the tile reads
  "Most practised style — " rather than "Primary Focus: Flow" (which was
  neither a style the user had logged nor one the tracker offers).
- **Copy rules, same as nutrition:** describe the practice, never its effect
  on a body. No "burn", "tone", "detox", "releases", no therapeutic or
  benefit claims anywhere in style copy, pose names, cues or starter
  descriptions — `knowledge/domain/mens_health.md` gates any health claim
  on evidence and none of this copy would clear it.

## Keep screen awake shipped rules (2026-09-04)

- **Every tracker keeps the screen awake while it runs**, not just the yoga
  sequence runner: GPS recording, HIIT, swim, strength, mindful
  (yoga/pilates) and the sequence runner. The `ScreenAwake` port
  (`core/platform/wakelock/`) stays the only thing that touches a wakelock
  plugin; the six controllers share
  `activity/presentation/recording/tracker_screen_awake.dart` rather than
  hand-rolling six acquire/release pairs.
- **One switch per exercise hub, not one global setting.** "Keep screen
  awake", subtitle *"While a &lt;Type&gt; workout is running"* (Yoga:
  *"While a Yoga session or sequence is running"* — the Flow Timer and a
  saved sequence obey the same switch). It sits between the quick-action
  buttons and the type-specific tools. The tradeoff genuinely differs by
  activity: a mat practice wants the screen on, a two-hour ride with the
  phone in a pocket does not.
- **Default is ON for every type**, and a type with nothing stored reads as
  ON. No default is ever written at first read — a stored value means the
  user chose.
- **It is a device preference, not user data.** `shared_preferences`, key
  `screen_awake_<type>`; **not** wiped by Delete-my-data and **not** in a
  data export. Rationale in
  `features/activity/domain/screen_awake_preference.dart`.
- **A change lands on a workout that is already running.** The helper
  listens to the preference rather than reading it once at start, so
  flipping the switch on the hub while a session is going acquires or
  releases immediately. Reading it only at start would look broken.
- **The release is the part that matters.** Every exit releases: finish
  (success *and* a failed save), discard, reset, and `ref.onDispose`. The
  lock instance is captured at acquire time so teardown never goes back
  through `ref`. The one deliberate exception is the sequence runner's
  failed save *mid-practice*: the countdown carries on, so the lock stays.
