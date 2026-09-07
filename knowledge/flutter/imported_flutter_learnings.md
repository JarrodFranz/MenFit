# Imported Flutter Learnings (from Mobile Soft PLC project)

> **Note:** the project-agnostic parts of these learnings now live canonically in the **central Flutter knowledge base** at `D:\Documents\Claude\Flutter development knowledge\` (shared across all Flutter projects). Read that base for the maintained versions; this file records what was imported for *this* project and its relevance to our features.

*Extracted 2026-08-25 from `D:\Documents\Claude\Projects\Mobile Soft PLC\knowledge` (read-only reference). That project was a Flutter soft-PLC app; PLC domain content was excluded (see end). Source paths refer to files under that directory. "CL-N" ids are that project's confirmed-learning ids, kept for traceability.*

## 1. UI performance

- **High-frequency live values must not rebuild the widget tree via parent `setState`.** Use a dataless `ChangeNotifier` "pulse" with leaf-only subscriptions (`ListenableBuilder`). When exposing it via `InheritedNotifier`, look it up with `getInheritedWidgetOfExactType` (non-dependency) — `dependOnInheritedWidgetOfExactType` registers every `of()` call site for rebuild. Directly applicable to live pace/HR/split displays during a run. *(app/ui-performance.md §1–2)*
- **Throttle high-frequency streams with a trailing-edge coalescer**: a tiny `dart:async`-only `NotifyThrottle` with `request()` (arm once per window) + `immediate()` (cancel-and-fire-now for state changes). Reuse for GPS sample → UI refresh coalescing. *(§3)*
- **Time-series display buffers**: memory-only ring buffer, externally clocked (no internal timer → deterministic tests), per-series retention (count or time window), trim with a single `removeRange` not repeated `removeAt(0)`. Applicable to pace/HR/elevation charts. *(§5)*
- **CanvasKit web builds can show "continuous repaint" that is engine-level, not app code.** Check for your own `AnimationController`/`Ticker` before hunting a phantom repaint loop. *(§7)*

## 2. Lifecycle handling

- `AppLifecycleState.inactive` is **transient** (notification shade, app switcher) — never treat it as suspend. `hidden` = about to background (flush pending writes); `paused` = process may be suspended (stop sockets/streams/location listeners). `hidden` can fire immediately before `paused`, so suspend handlers may run twice in quick succession — make them idempotent. *(app/app-lifecycle.md §1)*
- **Scope re-entrancy guards precisely.** A busy-flag shared between a light "flush" path and a heavy "full suspend" path let a slow flush make the real suspend silently no-op (CL-28). For us: a GPS-tracking pause/save on backgrounding must have its own guard.
- **Chain lifecycle handlers onto a single Future tail** so `resumed` can't race a still-running `paused` handler on the same resource (GPS stream start/stop races). Tests must await the chain tail or they're flaky. *(§3)*

## 3. Secure storage & secrets

- **Never call `flutter_secure_storage` (or any secure-storage package) directly from app logic.** Wrap in an injectable abstract backend + in-memory fake for tests. *(app/platform-secrets.md §1–2)*
- The real backend **cannot be exercised by `flutter_test`** (real platform channel; hangs/fails in fake-async). Prove it once manually per platform (Keychain / Keystore / DPAPI / web-none) and keep an on-device checklist. Web has no secure storage — never persist long-lived secrets there. *(§3, §6)*
- **Secrets never go to `SharedPreferences`, logs (even masked), or exported files.** *(§4, §6)*

## 4. Testing pitfalls (Flutter-specific)

- `SharedPreferences.setMockInitialValues({})` **replaces** the mock store. Calling it in a shared `freshRepo()` helper silently defeats cross-instance persistence tests (CL-31). Call it exactly once per test.
- Real I/O (`dart:io` sockets, processes) **never completes in the widget-test fake-async zone** — wrap in `tester.runAsync(...)` and assert result non-null (swallowed exceptions make it return null → always-green test) (CL-10).
- **Config-only deliverables need source-reading guard tests** (CL-27): a missing `android.permission.INTERNET` in the *release* manifest was invisible to debug runs. Cheap fix: a test that reads `AndroidManifest.xml` / `Info.plist` and asserts the required entry exists. Highly relevant here — HealthKit entitlements, background-location modes, `ACTIVITY_RECOGNITION`, foreground-service declarations are all release-only surfaces. *(practices/development-process.md §6)*
- **Uncontested concurrency tests prove nothing** (CL-25): stagger timing and make multiple conditions simultaneously true, or a regressed "any-wins" implementation passes identically. Relevant to merging sensor streams and GPS-vs-manual-pause races.
- **Optional forwarded parameters can be silently dropped at one hop** and defaults hide it (CL-21). Guard with a call-chain-level test that fails when the forward is removed.
- **Byte-identical snapshot tests for pure refactors**: capture serialized form as a fixture pre-refactor, assert equality post-refactor. Stronger than "tests still pass". *(development-process.md §4)*
- **Id-gated one-shot seeding ledgers silently swallow reused ids** (CL-12): if default content (e.g. seed workout plans, achievements) is seeded once per id, a reused/retired id never reaches existing installs. Always mint fresh ids.

## 5. Windows & web platform notes

- **Windows privileged ports**: binding <1024 needs no elevation on Windows (unlike POSIX); `WSAEACCES` (10013) usually means in-use. Port probes must classify permission-denied separately per platform (CL-11).
- **Git-Bash on Windows**: `$!` after `cmd &` is a synthetic MSYS job id, not the Windows PID — `taskkill //PID $!` silently fails. Find the real PID via `netstat -ano` on the listening port, then `taskkill //F //T //PID <pid>`. *(practices/verification.md §5.3)*
- **Canvas-rendered Flutter web has no DOM for E2E locators.** Verify via headless Playwright screenshots + console capture (watch for "A RenderFlex overflowed") + network capture at fixed viewports (1440×900 / 768×1024 / 390×844), coordinate clicks; try enabling the semantics tree via `flt-semantics-placeholder` first (CL-9, CL-16).
- **Embedded preview panes time out on continuously-repainting UIs** (they wait for paint-idle); headless Playwright `page.screenshot()` doesn't (CL-16).
- **Stale local dev servers serve stale content silently** — confirm exactly one listener on the port (`netstat -ano | findstr :PORT`) before trusting E2E output.
- **Desktop verification must drive the real built .exe** (real file persistence), not the web build (fresh localStorage each session). Kill stale instances first; never run two instances against the same save files. *(verification.md §6)*
- **Pushes touching `.github/workflows/` need the `workflow` OAuth scope** — the error names the scope; no client-side workaround (CL-29).

## 6. Process patterns worth carrying forward

- **Two-tier review**: per-task review right after implementation (catches contract drift) + whole-branch review over the full diff (catches cross-task seams: duplicated logic, broken invariants, UX inconsistency). Deliberately non-redundant. *(development-process.md §1–2)*
- **A single `DEFERRED.md` registry** for consciously-scoped-out work (item, priority, actionable note); items are struck through when shipped, never deleted — doubles as a changelog and is the one place to check "known gap or unnoticed bug?". We adopt this as `knowledge/product/deferred.md` when needed.
- **Maintain a recurring defect-shape catalogue** (e.g. "loops that rescan mutated state steal values"; "identity/dedup gates must cover every element kind"). We continue this in `knowledge/engineering/` as shapes are discovered.
- **Headless-verify loop for UI changes**: build → serve → screenshot at fixed viewports → zero console warnings / zero failed requests bar → fix → repeat.

## 7. Knowledge-system design adopted from the old project

The old base's governance was strong. We adopt: single canonical file per topic (search before creating); corrections marked superseded, never silently deleted; "when a doc and the code disagree, the code wins"; explicit list of what does NOT belong in knowledge (in-progress work, specs, generated artifacts, raw vendor text); date/version stamps per file. We deliberately simplified away its TL/CL two-stage learning registry and machine-readable manifest for now — at this project's size, direct capture into topical files with dates is lower-friction; revisit if the knowledge base grows past ~50 files. *(governance.md, index.md, canonical-manifest.json)*

## 8. Explicitly not imported (PLC-specific)

Protocol wire formats (Modbus/OPC UA/S7comm/…), IEC 61131-3 language semantics, PLC file formats (L5X, TC6 XML), scan-engine/task-scheduler internals, simulation engine, tag-model grammar, protocol-hosting architecture, default-project catalogue content, per-protocol E2E client choices. Reviewed and excluded 2026-08-25.
