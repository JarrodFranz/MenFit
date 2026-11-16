# Frelia improvements and keto tracking — proposed design

Date: 2026-11-16. Status: implementation authorized by owner directions: separate
Keto tab, macros, manual readings and a measurement-type selection. Implementing
on `codex/frelia-ports-keto`.

## Objective

Bring useful Frelia improvements into MenFit while preserving its adult-male,
strength-first identity and excluding menstrual-cycle features. Add keto diet
tracking using the existing food diary. Preserve installed users' data.

## Findings

MenFit HEAD is `18025b4`, following the September fork. Its last recorded full
validation is 3,509 passing tests on September 8; that is historical evidence,
not a test result for today's checkout. Flutter 3.47.2 / Dart 3.13.2 is available.

MenFit already has strength routines, GPS recording, food search, barcode and
label scanning, macro targets, weight history, recovery, achievements, challenges,
and local export/import. Frelia adds substantial new subsystems as well as fixes.
The comparison found 570 versus 983 non-generated Dart files, 423 source files
added in Frelia, and 455 differing shared files after package/brand normalization.
Those counts include import/copy changes and are not counts of new features.

The 1,222 pre-existing modified files in MenFit have no substantive diff under
`git diff --ignore-space-at-eol`; preserve those line-ending changes.

MenFit's database is version 1; Frelia's is version 37. Copying Frelia's migration
chain is inappropriate. Each adopted storage change needs a MenFit migration
from its own installed schema, plus old-backup handling and export/delete tests.

## Approaches

1. **Recommended: selective ports in verified batches.** Start with existing
   feature reliability and nutrition, add keto, then integrate larger features
   independently. This keeps each change reviewable and preserves MenFit rules.
2. **Broad rebase onto current Frelia.** Reapply male identity and remove cycle
   code afterward. This reaches more features at once but risks schema,
   physiology, billing, backend and platform regressions. Not recommended.
3. **Keto only.** Smallest immediate addition, but leaves the requested Frelia
   improvements unaddressed. Not the proposed completion scope.

## Port inventory and order

Source identifiers below refer to commits in the local Frelia repository at
`/home/jarrod/Projects/Claude/Projects/Female running app`. Adapt feature changes;
do not wholesale cherry-pick commits containing identity or cycle work.

| Batch | Improvement | Frelia evidence | Integration constraints |
| --- | --- | --- | --- |
| 1 | Strength reps input, removed-set values, large-text date layout | `e301d89` | Port manual-entry widget and regression tests. |
| 1 | Exclude incidental distance and pace from strength/HIIT/yoga/Pilates | `7df166d` | Domain, repository, wearable mapping, history/detail/hub/share; retain MenFit route fallback to strength. |
| 1 | Request workout exercise/distance permissions on explicit sync | `8c735a8`, `b1961be` | Android manifest, adapter, controller, fakes/tests; no cycle/history import. |
| 1 | Exclude sensitive DB from Android automatic backup/transfer | `e301d89` | Manifest, backup XML and guards; does not remove older external backups. |
| 1 | Explicit life-event choice, deletable saved custom names, duplicate-save prevention | `cb928f5`, `d8cad27`, `67c4f88` | Event dialog/store/providers and deletion flow; preserve recovery semantics. |
| 1 | Privacy cleanup, sensitive-value redaction, responsive/share fixes | `d00d8ed`, `1ff9c81`, `66fd406`, `9f1acbc`, `8ec69ee`, `81dcf94`, `7ab9219`, `77fd43b`, `8b1ed14` | Audit individual fixes against current MenFit; carry actual deletion paths and tests. |
| 1 | Sanitize malformed-import errors | `c63959f` | Static user/error messages; never interpolate input-derived parser messages. |
| 2 | Hide calorie figures while preferences load/fail; resolve percentage targets in consistency/recaps | `9fdac22`, `56fbcb1` | Shared rendering gate and all callers; use resolved target domain APIs. |
| 2 | Food search reliability, provenance, provider-ID/barcode separation, deduplication and serving display | `0f06d40`, `dccd915`, `93d447a`, `8347790`, `ddb16be`, `dab7e8c`, `e424697` | Provider/service/form/repository changes; MenFit migrations for adopted fields; no unreviewed volume-to-mass conversion. |
| 2 | Proxy-only FatSecret authentication and attribution | `dab7e8c`, `e424697` | Remove direct upstream client-secret fallback; retain shared proxy protocol `X-FemFit-Key`; no credentials copied or backend redeployed. |
| 2 | OCR column/%DI/basis/unit reliability | `fca5d04`, `e7eed93` | Parser, form state/merge/fields and label fixtures; exclude billing gates. |
| 2 | Nutrition organization and reliable hydration updates | `47d15e1`, `bb47925`, `e8e582e`, `7031b73`, `532300f`, `5ea8e50`, `9aacab9`, `109de8e` | Separate display/hydration changes from physiology calculations; keep male reference intakes. |
| 2 | Separate Keto tab with macros and manual ketone readings | New MenFit work | Owner-selected scope; design below, including health storage and migration. |
| 3 | GPS quality, paused segments, GPX/TCX import/export, map framing and crash recovery | `bf439b4`, `36ef55b`, `ea9c923`, `07089d1`, `cb652a8`, `0728a0b`, `db6ab50` | Draft storage needs migration/export/deletion; elevation upload separately opt-in (`2b45cc1`). |
| 3 | Themes, achievements organization, about/feedback | `0f06d40`, `39c117c`, `169a558` | Forge remains default; keep MenFit identity and valid contact destinations. |
| 3 | Energy-display correctness and richer insights/recaps | `b0981f0`, `582d3e2`, `9fdac22`, `b246f60`, `109de8e`, `871b1a8`, `8eb1a6a`, `491e80b`, `786a7d7`, `a13eb7d`, `59da59a`, `75036a8`, `6a8e369` | Male evidence review, calorie-hide behavior, snapshot/history migration, remove cycle and paid-gate coupling; never add exercise calories to daily targets. |
| 3 | Portable BLE support and notification fixes | `e5ab7c6`, `14ec9cc`, source ADR 019 | Evaluate existing source dependency decision; native-device validation required. |

These later features remain explicitly inventoried, not silently treated as
ported: adaptive training plans (35 new source files), encrypted backup/restore
(59), home-screen widgets (30 plus native code), live safety relay, progress
photos, and commercial maps/offline packs. Each needs its own bounded integration
design, migrations and platform checks. Frelia's iOS widget extension is not yet
wired/compiled; cloud destinations marked coming soon are not working features.
Subscriptions and Frelia's commercial infrastructure are not needed to unlock
useful MenFit functionality and are excluded from the recommended port.

## Keto: owner-selected scope

The owner selected **a separate Keto tab with macros and manual ketone readings**.
This supersedes the earlier Nutrition-only view. Add Keto after Nutrition:
Home / Train / Nutrition / Keto / Recovery / Settings. Use the existing adaptive
navigation bar/rail and a typed `/keto` shell branch; preserve other branches'
back stacks. Check six destinations at narrow widths and large text rather than
assuming the current five-destination fixture proves the new navigation.

- Reuse the selected nutrition date and existing logged food snapshots.
- Show recorded carbohydrate, protein and fat for that day, with the user's
  existing optional macro targets. Label carbohydrate as **Recorded carbs**.
- Reuse Nutrition goals for entering/changing a personal carbohydrate target;
  do not prefill a prescribed keto target or replace existing targets.
- Resolve targets through `NutritionGoals.macroTargetGramsFor`, including
  percentage-mode targets. Explain an absent energy basis instead of showing a
  zero target. Switching views never changes macro mode or saved values.
- Keep food logging in the existing diary and provide a direct path back to it.
  Browsing earlier days uses their food entries; current goals remain explicitly
  current goals, not a fabricated history of past targets.
- Use neutral intake/target wording, no remaining allowance, failure colour,
  streak punishment, food ranking, ketosis inference or treatment claims.
- Respect hide-calorie settings, text scaling, screen readers and compact/large
  layouts. All four app targets get the same local tracking functionality.
- State briefly that recorded carbs follow each food's source/label and that
  the view does not calculate net carbs or determine ketosis. Include the
  project's informational/not-medical-advice wording.

### Manual ketone readings

Provide Add reading, an ordered reading history, edit and confirmed deletion.
Keep multiple measurements per day, including their actual measurement date
and time. Default the form to now, allow historical entry and preserve the
recorded local calendar day for diary association alongside a UTC instant.
The reading type and unit must be explicit; do not convert between blood,
urine and breath results or infer a type from a bare number.

Owner answered **“have a selection”**: offer Blood (mmol/L), Urine (as printed
on the strip scale), and Breath (ppm) for every reading. Blood/breath accept a
finite non-negative number or the meter's literal LO/HI out-of-range result;
never substitute a number for LO/HI. Urine records the short result exactly as
read, including its printed category/unit (e.g. Trace or 15 mg/dL). Do not
synthesize a universal strip scale. Changing measurement type clears an unsaved
result so one method's value is not silently relabelled as another. No conversions.

New readings are **S3 sensitive health data**. Store locally in a dedicated
Drift table with UUIDv7 identity, measurement date/time, typed reading and UTC
creation/update timestamps. Do not collect extra notes or device identifiers
unless needed for the selected method. Validate entries at form/repository and
import boundaries; reject malformed, non-finite or invalid values without
echoing health data into errors. Technical limits must not be presented as
clinical ranges. Preserve device results that are not plain numbers through an
explicit agreed representation rather than inventing a numeric value.

Use a forward MenFit schema migration that creates the new table without
altering existing diary/goal/history rows. Allocate the next schema version in
the implementation plan, coordinating with the food-provider migration batch.
Include readings in `sensitiveHealthTables`: default exports omit them, while
explicit sensitive exports include them. Existing imports without the new
table must not invent or erase readings; imported readings require validation
before any replacement transaction. Include the table in the early S3 phase
of Delete my data, and support hard deletion of individual readings.

Present measurements as a log, without safe/unsafe colour bands, ketosis
scores, treatment advice or an implication that higher is better. Explain that
the log does not interpret readings or provide alerts and to follow the meter
instructions and clinician's advice. No sensor integration, automatic medical
calculation, new dependency or backend is required. Existing nutrition remains
S2; neither nutrition nor ketone data enters logs or analytics.

### Net-carb alternative

The owner chose manual ketone tracking, not automatic net-carb conversion.

Net carbs require an explicit per-food carbohydrate convention (includes fibre,
excludes fibre, unknown) snapshotted into entries, provider/OCR/manual handling,
missing-fibre behavior and migration of old rows as unknown. A global setting
or subtracting fibre from every logged food is insufficient. Sugar-alcohol
handling would require its own data/evidence decisions. No such arithmetic is
included in this proposal; see the evidence note below.

## Change reach and validation

Keto adds `features/keto/{domain,data,presentation}` and its codegen provider
surface; `core/db/tables/ketone_readings.dart` and a forward migration; typed
router shell branch/destination; and existing nutrition goal/diary navigation.
Reuse `dayNutritionTotalsProvider`, `selectedNutritionDayProvider` and the goals
domain API through the nutrition composition surface. Update generated code,
export sensitivity classification, import validation, delete-service wiring,
fakes, table inventory and shell navigation fixtures together.

Tests must cover reading creation/reopen/edit/delete, same-day measurements,
date/time behavior, invalid reading imports with atomic rollback, sensitive
export opt-in/omission, old backups, whole-app deletion, a real v1 migration,
and six-destination compact/large-text navigation. Macro tests must prove that
opening Keto never changes existing targets or food history.

Each port includes its callers, fakes, fixtures, manifests/config, generated
code when needed, affected exports and deletion coverage. Keep features behind
their current domain/provider boundaries. Prefer source-tested components to
new abstractions. Carry no Frelia health assumptions, identifiers or keys.

Before adopting the newer FatSecret client, verify the configured shared proxy
supports its requested method versions, authentication and response contract
(Frelia uses `food.get.v5`). Test safe behavior when configuration is absent.
Backend deployment is excluded, so a client-only port must retain compatibility
with the actual service; source-unit tests alone do not establish that.

For each integration batch: codegen if affected, formatting, fatal-info analysis,
then a single root-owned Flutter test invocation. No concurrent package tests.
Use a real v1 fixture for migrations and round-trip/old-backup tests for changed
storage. Test empty/partial diaries, user targets, percentage targets, hidden
calories, large text and compact/wide layouts. Independently review important
changes. Native changes additionally need Android release/device checks; iOS
and Windows builds require suitable hosts and must not be claimed on Linux.

## Environment notes

The Windows-only watchdog uses Win32 CIM and machine-wide process matching. It
was inspected but not started on Linux. A read-only MenFit process check was
used; no process was killed. Before long validation runs, use a bounded,
repository-scoped Linux monitor rather than the old destructive matching.

## Execution state

The owner explicitly requested a separate tab and all measurement choices after
reviewing the proposal. Those choices resolve the design questions; proceed
without another permission loop. Integrate and independently review the new
storage and UI. The previous review covered only the earlier macro view.

## Implementation ledger (2026-11-16)

Implemented initial reliability/nutrition batches plus Keto: strength entry and
distance rules; explicit workout authorization; Android private-data backup
exclusions; custom-event choice/name removal/save failure handling; safe import
errors and stricter row envelopes; hidden-calorie rendering; percent targets;
local-day hydration updates; food search/provider identity/serving/attribution;
OCR column and basis corrections. Source identifiers above are an audit inventory,
not a claim that every listed commit or every batch-1/2 UI redesign was copied.

Keto has six-tab navigation, existing diary macros and user targets, selectable
blood/urine/breath measurements, date/time and edit/delete, strict S3 import,
opt-in export and full deletion. MenFit migrates v1 → v2 (readings and day index)
→ v3 (separate food-provider identity with conservative legacy backfill).

Still unported: broader themes/nutrition organization, GPS recording/import and
crash-recovery upgrades, advanced insights/recaps, native BLE/notification changes,
adaptive plans, encrypted backup, home-screen widgets, live safety relay, progress
photos and commercial maps. These are separate integrations; this branch is not
full Frelia feature parity. Menstrual functionality and subscriptions remain
excluded.

Live configured FatSecret proxy check returned HTTP 401: the local configuration
has no proxy key. Mapping is covered by fixtures, but authorized live search is
unverified. No credentials were copied and no backend was deployed.
