# Security & Privacy

*Established at bootstrap, 2026-08-25. This document sets engineering ground rules. It is not legal advice and does not constitute regulatory compliance (GDPR/HIPAA/state privacy laws need dedicated review before launch).*

## Why this is a core architecture concern

This app will hold GPS/location history, body metrics, nutrition, heart rate, and **menstrual/reproductive-health data** — a combination more sensitive than most banking apps. Users' physical safety (live location) and legal safety (reproductive data) can depend on our choices. Privacy failures here are existential for the product.

## Data sensitivity tiers

| Tier | Data | Rules |
|---|---|---|
| **S3 — most sensitive** | Cycle/reproductive data, live location streams | Local-first; never in analytics/logs/crash reports; sync only with separate explicit consent and (for cycle data) end-to-end encryption as the design goal; deletable independently. |
| **S2 — sensitive** | GPS tracks/routes, body weight/metrics, HR, nutrition logs, health-platform data | Never in logs/analytics payloads; explicit permission per source; privacy zones for shared routes; deletable/exportable. |
| **S1 — personal** | Profile, goals, social content, trusted-contact list | Standard auth-protected handling; user-controlled visibility. |
| **S0 — non-personal** | App settings, feature flags, anonymous diagnostics (if any) | Normal handling. |

## Ground rules (all code, all agents)

1. **Data minimisation** — collect only what a feature needs; every new collected field needs a reason.
2. **No secrets in the repo** — no API keys, tokens, signing credentials, or endpoints-with-embedded-credentials in source or committed config. `env/*.json` files are committed and must contain **only non-secret** config (ADR 006); secret-ish keys go in gitignored `env/*.secrets.json` injected by CI, and platform keystores hold signing material.
3. **No sensitive data in logs** — logging utilities must make it hard to log S2/S3 data; never log coordinates, health values, or tokens. Crash reporting (when added) gets scrubbed breadcrumbs only.
4. **Permissions are explicit and just-in-time** — request location/health/camera at the moment of need with an explanation screen; the app functions (degraded) when denied.
5. **Analytics separation** — if analytics is ever added, S2/S3 data never enters it; events are behavioural ("run_completed"), never payload-carrying ("run_completed at lat/lon").
6. **AuthN/AuthZ designed, not bolted on** — authentication strategy gets its own ADR before any backend sync; authorisation checks live server-side when a backend exists.
7. **Deletion & export are features** — account deletion and data export are designed into the data layer from the start (soft-delete + purge pipeline when a backend exists).
8. **Ownership** — the user owns their data. Trusted-contact sharing is revocable at any time; shared live-tracking links expire automatically after the activity ends.
9. **Privacy zones** — before any social/route sharing ships, privacy zones (obfuscate area around home/work) must exist.
10. **Local storage posture** — mobile OS sandbox + OS-level encryption is the baseline; secrets/tokens go in platform secure storage (Keychain/Keystore; Windows DPAPI; web has no secure storage — never persist long-lived secrets in web local storage). Consider SQLCipher for the local DB if threat modeling justifies it (tracked as an open question).

## Threat notes to keep in mind

- **Live tracking links**: must be unguessable (high-entropy token), time-limited, revocable, and served over TLS. A leaked live-tracking link is a physical-safety issue.
- **Route sharing**: repeated routes reveal home address — privacy zones + default-private activities.
- **Cycle data subpoena/extraction risk**: strongest protection is not holding it server-side in readable form at all (local-first, E2E-encrypted sync if synced).
- **Stalker-adjacent misuse**: trusted-contact tracking must be visibly consented, easily paused, and auditable by the user (who watched, when — if technically feasible).

## Open questions (need decisions later)

- SQLCipher / OS-level DB encryption for the local database (revisit at first cycle-data storage implementation).
- E2E encryption design for cycle-data sync (decide with backend ADR).
- Regulatory review scope (GDPR, UK/AUS privacy law, US state laws) before public launch.


## Buddy-challenge sharing surfaces (2026-09-02)

- The PROGRESS CODE is structurally minimal: challenge id, self-chosen
  name, one percentage, as-of date, and a random per-challenge author tag
  - the encode API cannot express more (challenge_codes.dart, byte-level
  privacy test). Raw work, adjusted targets and anything cycle-derived
  never cross devices. The author tag is RNG output, carries nothing about
  her, and exists only so a device can refuse to import its own code back
  over the buddy snapshot.
- CORRECTION (2026-09-02): this section previously recorded, as a
  considered and accepted residual, that the challenge DETAIL screen shows
  raw work beside her percentage. That was wrong to accept, and the
  residual is CLOSED - the raw "so far" line is gone from every challenge
  surface (and `challengeSoFarLine` / `formatDistanceSoFar` are deleted).
  The reasoning that was missing: it is not raw / percent alone. Raw,
  percent, the NOMINAL TARGET and the WINDOW are all four on that screen,
  and together they resolve her PROTECTED-DAY COUNT uniquely -
  `protectedDays = windowDays - round(windowDays x (raw / percent) /
  target)`; 42.3 km + 50% + 100 km + 30 days is exactly 5, i.e. a
  screenshot states when her period was. Her raw distance still lives in
  her activity history, on a screen that says nothing about a challenge.
- THE RULE THAT REPLACED IT (mechanical, not remembered): no challenge
  surface may render her raw work AND her adjusted percentage AND the
  nominal target AND the window. Any three are fine. Swept across the
  list card, the Progress card, the detail screen, both sheets and both
  dialogs by `test/features/challenges/challenge_surfaces_privacy_test.dart`
  with a five-protected-day fixture and a positive control. The percentage
  stays: the pro-rated experience IS the feature, and hiding her own
  standing from her would be the worse app.
- Three forbidden-vocabulary lists now exist BY DESIGN (weight,
  achievements, challenges) guarding different risks: weight bans
  valence/goal language; achievements bans goal/target/completion
  framing; challenges PERMITS goal/target (a challenge is a shared
  target) but bans the entire ranking lexicon (win/lose/ahead/behind/
  beat/vs) and the cycle lexicon. Do not merge them.
- The vocabulary sweeps skip ONE string: the opaque code body itself
  (`challengeCodeTextKey`). base64url of a ~47-byte payload contains a
  three-letter entry like "pms" or "bmi" roughly once in a few hundred
  codes, so sweeping it makes the gate flaky, and a flaky privacy gate is
  a privacy gate that gets deleted. Every label around it is still swept.
- Per-item deletion (rules 7/8) is satisfied for challenges by "Leave this
  challenge" on the detail screen: a hard delete of the row, the buddy's
  chosen name included, behind a confirm dialog that restates no numbers.
  Settings' "Delete my data" remains the all-at-once path; neither
  replaces the other.

## Nutrition-label photos (ADR 012, 2026-09-03)

A photo of food packaging is S2 (nutrition), and a photo taken in someone's
kitchen or a supermarket aisle carries more than the label — which is why
the rule is that it does not survive the call that takes it.

- Capture goes through **one** file, `core/platform/ocr/label_capture.dart`
  (source-scan guard: nothing else in `lib/` may import `image_picker`).
  The OS camera writes into the app's private cache, the file is read by
  the on-device recogniser, and it is deleted in a `finally` — so a throw
  from the recogniser cannot leave it behind. Never copied, never moved to
  the gallery, never persisted, never logged. Tested against the real
  filesystem, including the throwing path.
- **The one way a photo can outlive the call is swept on the next one.**
  Android may destroy `MainActivity` while the OS camera is in front; the
  `pickImage` future then never completes, so the `finally` never runs and
  the JPEG stays in the cache. `captureAndRecognizeLabel` therefore begins
  with `ImagePicker().retrieveLostData()` and **deletes** whatever it
  recovers without recognising it — a stale picture of the last thing she
  photographed is owed nothing but deletion. Android-only; the call throws
  elsewhere and the throw is swallowed, because best-effort cleanup must
  never be why a capture fails to start.
- `requestFullMetadata: false` on iOS, so the plugin does not reach into
  the Photos library for the asset's metadata — which is where the GPS
  coordinates of the shot would come from. We want the pixels, not the
  location of the supermarket.
- Recognition is a native `MethodChannel` call with no network component;
  `google_mlkit_text_recognition` bundles its Latin model, so there is not
  even a first-use download. Recognised text stays in memory and reaches
  the review form; it is not logged either — a nutrition panel plus a
  brand name is a food diary entry before the user has agreed to save one.
- No gallery import path exists. `ImageSource.gallery` reaches the entire
  camera roll and would be a separate decision, not an obvious extension
  of this one.
- The iOS camera permission string had to cover both the barcode scanner
  and this (iOS allows one key). It now claims on-device processing and
  that the photo is discarded; `test/platform/ocr_platform_config_guard_test.dart`
  asserts those words are present, so the promise and the behaviour have to
  change together.

## Export: "Save a copy of your data" (2026-09-04)

Rule 7's export half, next to Settings' "Delete my data". One JSON file,
built on the device, delivered through the OS save dialog
(`FilePicker.saveFile` with bytes, the same mechanism as the per-activity
GPX/TCX export) - **no temp file is written on any platform**, and on web the
bytes become a browser download. Nothing is uploaded and no network call is
made on the path (a `HttpOverrides` that fails any socket is installed over
the exporter test).

- **What is in it.** Every table in `AppDatabase`, read generically from
  `db.allTables` rather than a hand-written list, so a table added later is
  exported the day it exists and cannot be silently forgotten. Rows are
  Drift's own `toJson()` maps with nothing reformatted or derived - epoch-ms
  columns stay epoch ms. Envelope: app, format (`menfit-export`),
  formatVersion, appVersion, `AppDatabase.schemaVersion`, `exportedAt`
  (ISO-8601 UTC), `includesCycleAndWellbeingData`, then `tables`.
- **The S3 opt-in.** `cycle_records`, `daily_checkins`, `flare_events` and
  `recovery_days` are excluded unless she ticks "Include cycle and wellbeing
  data", which is **off by default** - the same four tables, in the same
  grouping, that `DeleteMyDataService` wipes first. A file without them is a
  different object to hand to a coach or a cloud drive, and an opt-out she has
  to notice is not a decision she made. The flag is written into the file, so
  absent-because-she-said-no and absent-because-she-logged-none are
  distinguishable.
- **The generic read is safe because the classification is guarded, not
  because it is careful.** `test/features/data_export/data_export_table_coverage_test.dart`
  holds a hand-maintained inventory: a table that is neither in it nor in
  `cycleAndWellbeingTables` fails by name, so a new table forces a tier
  decision even though the exporter would have included it anyway.
- **Soft-deleted rows are included**, and the notice says so. A row the app
  has stopped showing her is still hers until it is purged; a "copy of your
  data" that quietly omits them is not one.
- **Nothing on this path logs.** Failures wrap to `StorageException` with the
  static message `'Failed to read local data for export'` (no table name, no
  row), and the controller surfaces only `userMessageFor(error)` - a fixed
  sentence, so an underlying error's text (a path, a row) can never reach a
  SnackBar and from there a log.
- The notice dialog is shown **every time**, not remembered like the online-
  lookup one: each export is a separate file going somewhere she picks that
  day, not consent to an ongoing behaviour.

## Native sharing (ADR 011, 2026-09-02)

Every share surface goes through `SharingAdapter` (`core/platform/sharing/`)
only — a guard test asserts `share_plus` is imported nowhere else in `lib/`.
Share text is required to equal the text the same surface's Copy action
would put on the clipboard (tests enforce this), so the native share path
cannot leak anything the clipboard path doesn't already carry. The adapter
never logs share text or platform errors (`ShareOutcome` and thrown
exceptions are handled and mapped to a fallback, not written to any log).
Cycle export deliberately stays clipboard-only rather than gaining a share
button: a share sheet would put her complete period history one tap away
from every installed app, which the clipboard-only path does not (see the
dartdoc on `_showExportDialog`).
