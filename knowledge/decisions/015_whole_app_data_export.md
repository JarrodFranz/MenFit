# 015 — Whole-app data export as one JSON file, saved where she chooses

- **Status:** Accepted (2026-09-04; implemented in the same round)
- **Date:** 2026-09-04

## Context

`knowledge/engineering/security_and_privacy.md` rule 7 says deletion **and**
export are features designed into the data layer. Deletion existed ("Delete my
data", now covering every table — see the every-table guard test). Export did
not: the only surfaces were per-activity GPX/TCX (`ActivityExportService`) and
a clipboard cycle export. A 2026-09-03 note claiming step history was
"registered for export" was wrong; there was no registry to register in
(handoff Corrections). With `yoga_sequences` (v23) the count of tables with no
export path reached nineteen.

## Decision

1. **One faithful JSON document, every table, generically.** The exporter
   iterates `AppDatabase.allTables` and writes each row's generated `toJson()`
   under the table's SQL name. Nothing is reformatted or interpreted: epoch
   milliseconds stay as stored, JSON-blob columns stay as strings,
   soft-deleted rows are included (they are still her data until purged).
   Because the iteration is generic, **a new table is exported the day it is
   added**; a guard test fails if any table is neither exported by default nor
   in the explicit opt-in set below.
2. **Cycle and wellbeing data are opt-in, default off.** `cycle_records`,
   `daily_checkins`, `flare_events`, `recovery_days` — the same four the delete
   flow treats as the most sensitive tier — are written only when the notice's
   checkbox is ticked. A file that leaves the device should not carry
   reproductive data by accident.
3. **Delivered through the OS save dialog, not a share sheet.**
   `FilePicker.saveFile(bytes:)` (file_picker 12, already adopted for GPX/TCX)
   works on Android, iOS, Web (download) and Windows (native dialog), keeps
   the bytes in memory, writes **no temp file** (the share_plus cache-dir
   problem does not arise), and lets her decide the destination. An export is
   a deliberate act with a destination, not a broadcast.
4. **A notice first, every time.** Mirrors the online-lookup notice: plain
   language on what the file contains, that it is created on this device and
   goes only where she saves it, that nothing is sent to anyone, and the
   opt-in checkbox. Dismissing is declining.
5. **Envelope:** `app`, `format: femfit-export`, `formatVersion: 1`,
   `appVersion` (constant guarded against pubspec), `schemaVersion`,
   `exportedAt` (UTC), `includesCycleAndWellbeingData`, `tables`. Filename
   `femfit-export-YYYY-MM-DD.json`, pretty-printed so it is readable without
   tooling.

## Privacy

S1–S3 data leaves the device only by her explicit save; no network, no
logging of content; failures surface a static message. The S3 tier is
opt-in. Settings/preferences (S0, e.g. theme, screen-awake per hub) are not
exported — they are device configuration, not her data.

## Per-platform

| | iOS | Android | Web | Windows |
|---|---|---|---|---|
| Export | full (Files app sheet; Mac-unverified) | full | degraded: browser download, no destination choice | full (native dialog) |

## Consequences

- Row maps must stay JSON- and isolate-sendable: encoding runs in `compute()`.
  No table has a BLOB column today; adding one would break `jsonEncode` here
  and needs a base64 rule in the exporter first.

- Import of this file is **not** built (no round-trip yet). `formatVersion`
  exists so a future importer can refuse what it does not understand.
- CSV per table was rejected for now: 19 files need a container (zip → a new
  package) and CSV cannot carry the JSON-blob columns faithfully. A
  spreadsheet-friendly export can be layered later from the same document.
- share_plus delivery was rejected: temp files in the app cache, no
  destination choice, and unverified on Windows.
