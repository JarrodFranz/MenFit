# Implementation Roadmap

*Scope target: full Strava + MyFitnessPal functional parity, adapted for women — the feature-by-feature inventory with phase mapping and status lives in `feature_parity.md` (confirmed by product owner 2026-08-26).*

*2026-08-27: the product owner's women-first handover specification re-stages remaining work — see `stage1_audit.md` for the audit, the Stage 1 (S1-1…S1-7) sequence now in effect, and the mapping of this document's phases onto the spec's Stages 1–5 (spec Stage 2 ≈ adaptive coaching/plans; Stage 3 ≈ safety + wearables [old phases J/K]; Stage 4 = life-stage modes [new]; Stage 5 ≈ advanced personalisation [old phase M]). Social (old phase L) is explicitly deprioritised by the spec (§27).*

*Created 2026-08-25 at bootstrap completion. Phases are sequential-ish but not sacred — each phase ends with working, tested software. Revisit ordering as product priorities firm up.*

## Deviations from the originally proposed A–J sequence (reasoned)

1. **Auth moved late** (into the backend phase). The app is local-first (ADR 004); auth without a backend is ceremony. Building profile/onboarding *locally* first lets running features ship sooner and keeps the backend decision unhurried.
2. **Cycle tracking moved early** (right after first activities exist). It's the product's differentiator, it's purely local data (privacy-simplest), the named streak-pausing feature depends on it, and having real cycle entities early keeps the data model honest instead of bolting women's health on at the end.
3. **A dedicated local-data phase inserted** before any tracking feature — Drift wiring (ADR 003) is the dependency of everything.
4. **Safety live-tracking is explicitly backend-gated** — contact management UI can be built earlier, but live sharing needs a server; don't pretend otherwise.

## Phases

**A — Foundation & design system polish** *(bootstrap delivered the skeleton)* — **largely shipped 2026-08-26**
✅ Inter variable font bundled with real weight mapping (FontVariation); ✅ AppEnv/log-level wiring. Remaining: core widget library (cards, stat tiles, empty states), l10n scaffolding, app icon pipeline — fold into Phase C as needed.

**B — Local data foundation + profile & onboarding (local, no auth)** — **shipped 2026-08-26**
✅ Drift wired on all four platforms (2.31.0, schema v1, web WASM assets); ✅ UUIDv7/UTC/unit conventions in code (`core/domain`); ✅ sealed AppException + user-message mapping; ✅ local profile (name, units, weekly goal) with repository pattern + serialized updates; ✅ 3-step onboarding with truthful privacy copy; ✅ **Delete-my-data** in settings (wipes profile + prefs, returns to onboarding); ✅ router redirect (onboarding gate); ✅ ADR 007 provider-surface convention; 47 tests green. Independently reviewed; all findings resolved.

**C — Run tracking (mobile) + activity model** — **waves 1–2 shipped 2026-08-26; wave 3 (maps) remaining**
✅ Wave 1: activities/samples schema (v2 migration), manual entry, day-grouped history, detail screens. ✅ Wave 2: LocationAdapter (geolocator 14, ADR 008), pure-Dart RecordingSession engine (accuracy/jump filters, auto-pause with staleness detection and back-dated moving time, elevation hysteresis, rolling pace), full recording UI with permission explainer + save-retry recovery, manifest/plist config + guard tests (incl. absence guards for background-location keys). Independently reviewed; 2 blocking + 6 should-fix findings all resolved. ⬜ Wave 3: flutter_map route rendering on activity detail (+ live recording map later). Exit gate outstanding: on-device recording verification (Android build blocked on this machine — troubleshooting/android_build.md).

**D — Cycle tracking + streaks (signature differentiators)** — **shipped + review-hardened 2026-08-27**
Post-review fixes: per-record cycle delete is now a HARD delete (S3 truth-in-copy; ADR-004 exception documented in code), period backfill with optional end date, date-picker crash fix, midnight-rollover recompute (localDayProvider), LocalDate validation with static error messages, signature-scenario test coverage (paused-today-with-streak; ongoing period through the real chain).
✅ Wave 1: `LocalDate` calendar-day type (DST-safe); cycle_records schema v3; period logging (start/end/edit/delete, overlap validation, ongoing records), streak-pausing toggle (default on), disclaimers, delete-my-data extended to cycle rows (S3-first). ✅ Wave 2: pure streak engine (pause bridging, retroactive recompute, satisfied-takes-precedence, today-pending), derived-only provider over activity+cycle surfaces, home hero streak card with paused state. 264 tests green; symptoms/energy logging + phase estimates deferred to a later D increment (evidence-gating unchanged).

**E — Activity history & analytics** — **shipped + review-hardened 2026-08-27**
✅ Splits with boundary interpolation + relative pace bars (unit-aware, partial-split fairness); ✅ best efforts 1k–marathon (dual two-pointer, brute-force-oracle-tested both directions) + PRs (earliest-wins ties); ✅ Progress screen (`/home/progress`): stat tiles with compact deltas, weekly distance BarChart (fl_chart 1.2.0, nice-step axis, fitted tooltips, semantics summary), PR list; ✅ **segment-aware analytics over pause-tagged samples (schema v4)** — pause gaps contribute zero distance/time, efforts can't span a pause, split sums reconcile with headline stats to machine precision. Deliberately excluded: cycle data on the analytics surface (S3 stays off Progress pending a product decision); history filters + training-load model → later increment. 4-dimension Workflow review; all findings fixed.

**F — Workouts & strength**
Exercise catalogue (seeded, fresh ids — see central testing-pitfalls on seeding ledgers); workout templates vs sessions; set logging UX; progression history; streak integration. 

**G — Nutrition**
Food DB source research task first (Open Food Facts vs USDA vs commercial — licensing is a product decision); logging UX, meals, macros, goals; body metrics + trend-smoothed weight; ED-safe design choices per domain/nutrition.md. Barcode scanning (mobile) optional scope.

**H — Route suggestion (named feature)**
Research task: routing engine (OpenRouteService round-trip vs GraphHopper vs Valhalla) — likely a hosted API + key handling per ADR 006; suggest routes for a km target from a start point; loop/out-and-back prefs; women's-safety route preferences (lit streets) as the differentiator where data allows; save/reuse routes.

**I — Backend, auth & sync**
The big ADR cluster: vendor, auth, sync protocol (outbox per ADR 004), E2E-encryption design for cycle sync, deletion/export pipeline. Migrate local-only accounts. Exit: multi-device sync; cycle data synced only with separate consent + encryption.

**J — Safety: trusted-contact live tracking (named feature)**
Contact management; tokenised live-tracking web links (unguessable, expiring, revocable — threat notes in security_and_privacy.md); post-run check-in notifications. Backend-dependent (hence after I). The web target becomes the watcher surface.

**K — Health platform integrations**
`HealthAdapter` implementations: HealthKit + Health Connect (`health` package); HR into activities; import/export; wearable/Strava import research.

**L — Social & community**
Profiles, sharing (privacy zones FIRST), friends, reactions, challenges (cycle-pause-fair), clubs with moderation. Heavy product + trust/safety design work.

**M — Training intelligence (incl. AI)**
Cycle-aware training recommendations (evidence-gated), plan generation, trend explanations. AI is additive — the app is complete without it.

## Standing tracks (every phase)

Privacy review for new data; cross-platform verification (web + windows locally, iOS needs a Mac); knowledge capture; deferred-work registry maintenance.

## Recommended next task

**Phase A remainder + Phase B start**: bundle the font + build the local data foundation (Drift wiring + profile). It unblocks everything and produces the repository/test patterns all later features copy.
