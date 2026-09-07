# Dependency Resolution

## 2026-08-28: Flutter 3.47.2 / Dart 3.13.2 Upgrade (Analyzer Window Resolved)

The SDK upgrade lifted the `analyzer-9` window completely:
- Flutter: `3.47.2`, Dart: `3.13.2`, `meta`: `1.19.0`, `analyzer`: `13.3.0`
- Updated toolchain: `riverpod_generator 4.0.8`, `flutter_riverpod 3.4.2`, `freezed 4.0.0`, `drift 2.34.3`, `drift_dev 2.34.5`, `drift_flutter 0.3.1`, `sqlite3 3.5.2`, `json_serializable 6.14.1`, `go_router_builder 4.4.1`.
- Web SQLite/Drift assets (`web/sqlite3.wasm` and `web/drift_worker.js`) refreshed to match `drift 2.34.3` and `sqlite3 3.5.2`.
- `custom_lint` + `riverpod_lint`: analyzer 13 is unblocked, but `riverpod_lint 3.1.8` requires `analyzer_plugin ^0.14.0` whereas `custom_lint 0.8.1` requires `analyzer_plugin ^0.13.0`. Kept uninstalled until `custom_lint` publishes support for `analyzer_plugin ^0.14.0`.
- All 1,173 tests and web/apk/windows builds pass.

## 2026-08-28: the analyzer window is an SDK pin, not a package pin

Measured with a throwaway probe package (a scratch `pubspec.yaml` outside the
repo, resolved with `flutter pub get` — **never `pub upgrade` in the repo**).
This supersedes the earlier explanation below on two counts.

**It is not `freezed`.** `freezed 3.2.5` allows `analyzer >=9 <11`. Nor is it
ultimately `riverpod_generator`, though that is the only generator capped at
`^9.0.0` while every other one already allows `<11` or wider:

| Generator (ours) | analyzer range |
|---|---|
| `go_router_builder` 4.4.0 | `>=8.2.0 <14.0.0` |
| `drift_dev` 2.31.0 | `>=8.1.0 <11.0.0` |
| `freezed` 3.2.5 | `>=9.0.0 <11.0.0` |
| `json_serializable` 6.13.0 | `>=9.0.0 <11.0.0` |
| **`riverpod_generator` 4.0.3** | **`^9.0.0`** |

`riverpod_generator` has **no version accepting analyzer 10 or 11** — it jumps
`^9.0.0` (4.0.3) straight to `^12.0.0` (4.0.4), latest `^13.0.0` (4.0.8). So
there is no small bump; the escape is the whole toolchain onto analyzer 13.

**And analyzer 13 is blocked by the Flutter SDK itself**, two ways:

- `analyzer >=13.1.0` needs `meta ^1.18.3`, but **`flutter` from the SDK pins
  `meta 1.18.0`.**
- `freezed 4.0.0` (the first freezed on analyzer 13) requires **Dart
  `>=3.13.0`**; we are on **3.12.2**.

**Therefore the single action that lifts this window is a Flutter SDK
upgrade.** Not waiting on riverpod, not swapping a generator. Every latest
generator already converges on analyzer 13 (`riverpod_generator` 4.0.8,
`freezed` 4.0.0, `drift_dev` 2.34.5, `json_serializable` 6.14.1,
`go_router_builder` 4.4.1) — the ecosystem has moved; we have not.

**Two hazards to plan for in that upgrade, both surfaced by the same probe:**

1. **`freezed 4.0.0` is a major version** — breaking codegen across every model
   in the app (ADR 005). The 1173-test suite is the gate.
2. **`drift_dev >=2.32.0` moves to `sqlite3 ^3.0.0`** while `drift_flutter
   0.2.8` still requires `sqlite3 ^2.4.6`. Our **`web/sqlite3.wasm` is pinned to
   match sqlite3 2.9.4 / drift 2.31.0** (see `package_decisions.md`) — the web
   assets must be re-fetched to match whatever drift version lands, or the web
   build breaks at runtime, not at compile time.

**Reusable probe recipe:** copy the dependency list into a scratch package
outside the repo, loosen the constraints under test to `any`, run `flutter pub
get`, and read the solver's explanation — it names the binding constraint
directly. The repo's own lockfile is never touched.

## The analyzer-9 window is load-bearing (2026-08-25, Flutter 3.44.4 / Dart 3.12.2)

**Symptom:** attempting latest riverpod/freezed/custom_lint versions → unsolvable pub resolution with unreadable solver output.

**Cause:** this Flutter SDK pins `flutter_test` → `test_api 0.7.11` exactly → `test 1.31.0` → `analyzer <13`. `freezed` has a gap (no release supports analyzer 11.x–12.x; jumps 3.2.5 → 4.0.0/analyzer 13). The only window satisfying test + riverpod_generator + freezed + json_serializable + build_runner simultaneously is **analyzer 9.x**, forcing: `riverpod 3.2.1` / `riverpod_annotation 4.0.2` / `riverpod_generator 4.0.3` / `freezed 3.2.5` / `json_serializable 6.13.0` / `json_annotation ^4.11.0` (not latest of any).

**Consequences:**
- **Do not run `flutter pub upgrade` casually** — it will likely break this resolution.
- `custom_lint` + `riverpod_lint` could NOT be installed at all (verified via pub.dev API 2026-08-25: custom_lint 0.8.1 caps analyzer ^8; riverpod_lint 3.1.8 needs analyzer ^13 **and pins riverpod exactly 3.4.2**, vs our forced 3.2.1 — doubly incompatible; no overlapping pair exists). Documented in `analysis_options.yaml`; **re-attempt both together after the next Flutter SDK upgrade**, and also retry latest riverpod/freezed then.
- API notes at these pins: `AsyncValue.valueOrNull` does not exist on riverpod 3.2.1 (use `.value`); `PlatformDispatcher` needs explicit `import 'dart:ui'`.

**Fix technique (reusable):** don't parse solver traces — pull each candidate version's `analyzer` constraint from `https://pub.dev/api/packages/<name>` and intersect ranges manually. Minutes instead of hours.

## Drift pins inside the same window (added 2026-08-26)

Newest drift pair fitting analyzer-9: **drift 2.31.0 + drift_dev 2.31.0** (drift_dev 2.32.0 hard-pins analyzer ^10). The binding constraint is a *double* intersection: drift_dev 2.31.0 caps `sqlite3 ^2.4.6` while drift_flutter ≥0.3.0 floors `sqlite3 ^3.0.0` → forced **drift_flutter 0.2.8** + **sqlite3 2.9.4** + **sqlite3_flutter_libs 0.5.42**. Web assets must match resolved versions: `sqlite3.wasm` from GitHub release `sqlite3-2.9.4`, `drift_worker.js` from release `drift-2.31.0` (both worked first try). Re-check the whole chain after the next Flutter SDK upgrade.

## flutter test output truncation quirk (2026-08-26)

With default concurrency, this shell's captured `flutter test` output can silently drop whole test files' lines (tests still ran and passed). If a run looks short, re-run `flutter test -j 1` — deterministic full output.


## "Cannot access the file" on flutter test = stale flutter_tester holding sqlite3.dll (2026-09-01)

A wedged/orphaned `flutter_tester.exe` from an interrupted run keeps
`build/native_assets/windows/sqlite3.dll` locked; the next `flutter test`
fails with a misleading file-permissions error that points at the SDK.
Fix: `taskkill` the stale flutter_tester PIDs (tasklist | findstr
flutter_tester). The stall watchdog reports them; this is the error you
get if you ignore it.
