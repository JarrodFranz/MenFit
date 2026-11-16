# Frelia ports and Keto implementation plan

> For agentic workers: execute bounded tasks below using the repository's new-feature workflow and independent review. Only root runs Flutter tests and codegen; disjoint implementations may proceed in parallel under CLAUDE.md.

**Goal:** Port relevant Frelia improvements and add a separate Keto tab with macros and selectable manual blood/urine/breath readings.

**Architecture:** Keep existing diary and goals as the macro source. Add a small local Keto feature, a typed shell branch and an S3 readings table; migrate MenFit's existing schema forward. Selectively adapt Frelia changes without cycle, billing or identity coupling.

**Tech Stack:** Existing Flutter/Dart, Riverpod codegen, Drift, freezed and go_router; no new dependency for Keto.

## Task 1 — Keto feature

Files: new `lib/features/keto/{domain,data,presentation}/`, `keto_providers.dart`, `lib/core/db/tables/ketone_readings.dart`; tests under `test/features/keto/`.

- [x] Define `KetoneMeasurementType { blood, urine, breath }` and `KetoneReading` with UUID id, local day, measured UTC instant, method, result text, created/updated UTC timestamps. Numeric results must parse as finite, non-negative numbers; LO/HI stay text. Urine stays a short printable strip result, including its own unit/category. Never calculate a clinical score.
- [x] Write domain tests rejecting negative/non-finite/malformed numeric input and invalid methods, accepting zero/decimals/LO/HI and urine categories. Test measurement switch clears unsaved result.
- [x] Implement typed repository watch/save/delete/deleteAllData, static errors, hard deletion and createdAt preservation. Use the existing weight-repository conventions without its historical S2 doc mistake.
- [x] Build `KetoScreen`: dated macro totals and current user targets, links to diary/goals, chronological ketone list, Add/Edit/Delete dialog with method/date/time selection. Render units per method. Handle loading/errors explicitly, no calorie leakage or invented net carbs.
- [x] Write repository and widget tests for persistence, multiple readings/day, compact/wide layouts, edit/delete, user-selected methods and no calorie/medical classifications.

## Task 2 — Persistence, routing and privacy integration (root)

Files: `lib/core/db/app_database.dart`, `lib/app/router/routes.dart`, data-export domain/importer, settings delete service/providers, relevant DB/export/delete/navigation tests.

- [x] Add `KetoneReadings` to database tables and forward migration:
  ```dart
  if (from < 2) await m.createTable(ketoneReadings);
  ```
  Coordinate later food schema steps separately; preserve v1 data. Record a true v1 SQL fixture before codegen changes.
- [x] Add `/keto` typed shell branch after Nutrition and sixth adaptive destination. Update shipped-list navigation fixtures.
- [x] Add `ketone_readings` to sensitive export classification. Wire required Keto repository into S3-first deletion and every fake/constructor caller.
- [x] Validate imported ketone rows before replacement; malformed data throws a static StorageException and leaves every table unchanged. Omitted ketone table in old backups leaves readings untouched. Honor sensitive export flag on import.
- [x] Test v1→current migration preserving profile/diary, explicit sensitive export round trip, default omission, invalid import rollback and full deletion.

## Task 3 — Existing activity/platform fixes

Files limited to activity/wearables/platform adapters, Android manifest/backup rules and matching tests.

- [x] Adapt Frelia `e301d89` strength input/date/reorder corrections and Android backup exclusion.
- [x] Adapt `7df166d` distance/pace policy across domain, repository, wearable mapping, history/detail/share. Keep MenFit's strength route fallback.
- [x] Adapt `8c735a8` explicit workout permission path with exercise/distance manifest guards. No menstrual interfaces.
- [x] Carry regression tests and document physical-device verification still required.

## Task 4 — Nutrition correctness ports

Files limited to nutrition, its relevant Home/recap rendering callers and matching tests. Root owns shared DB/config integration.

- [x] Adapt `9fdac22` fail-closed calorie visibility across all callers and `56fbcb1` percentage target resolution in consistency/recaps.
- [x] Adapt `7031b73` hydration updates and food-search flicker correction.
- [x] Adapt OCR fixes `fca5d04`/`e7eed93` with fixtures; retain blank/unknown semantics and male content.
- [x] Inspect/adapt provider-ID/barcode separation, finite values, serving and attribution fixes (`ddb16be`, `dab7e8c`, `e424697`). Coordinate exact fields/migration with root before editing DB. Preserve shared proxy contract and do not copy credentials or deploy backend.

## Task 5 — Remaining inspected improvements and review

- [x] Root ports static malformed-import errors (`c63959f`) as part of Task 2.
- [x] Port life-event explicit choice/custom-name deletion/duplicate-save handling (`cb928f5`, `d8cad27`, `67c4f88`) with deletion integration and regressions.
- [x] Compare remaining audit inventory against implemented diff; explicitly track unported larger integrations rather than call the entire parity port complete.
- [x] Independent reviewer first checks requested behavior, then privacy/correctness/platform/data-loss risks; resolve actionable findings.

## Task 6 — Central validation and durable state

- [x] Run `dart run build_runner build` once after workers finish codegen-affecting changes.
- [x] Run `dart format .`, `flutter analyze --fatal-infos`, then one `flutter test` invocation. Fix failures and repeat only affected checks plus the required final suite when justified.
- [x] Build Android release for native changes if signing/toolchain available; report unavailable host/device checks honestly. Never distribute a debug-signed build.
- [x] Update architecture/privacy/evidence notes and handoff/session log with actual implementation, source-port ledger, tests and remaining work. Do not claim all Frelia parity or a deployment without evidence.
