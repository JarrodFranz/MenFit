# Testing Strategy

*Established 2026-08-25. Pitfall catalogue: central base `testing-pitfalls.md` — read it before writing tests.*

## Pyramid

1. **Pure Dart unit tests** (bulk): domain logic — cycle/streak calculations, pace/distance math, unit conversions, sync merge rules. No Flutter imports needed because domain/ has none.
2. **Repository tests on in-memory Drift** (`NativeDatabase.memory()`): real SQL, no mocks — schema, DAOs, and queries proven together.
3. **Provider/controller tests**: `ProviderContainer(overrides: [...])`, repository fakes/mocktail.
4. **Widget tests**: per screen, at compact AND expanded sizes when layout adapts; mocked providers.
5. **Thin `integration_test` suite** (later, CI): record-activity happy path, auth redirect.
6. **Golden tests**: deferred until the design system stabilises (then `alchemist`).

## Expectations

- Meaningful business logic ships with tests; UI plumbing doesn't need placeholder tests.
- Tests must have the power to fail: contested concurrency scenarios, mutation-check forwarded parameters, one `setMockInitialValues` call per test (see central pitfalls file for all confirmed traps).
- **Config-only surfaces get source-reading guard tests** under `test/platform/` (manifest permissions, entitlements, plist keys) — established at bootstrap with the Android INTERNET guard.
- Cycle/streak logic edge cases are mandatory test territory: retroactive logging, overlapping records, prediction-vs-confirmed, timezone/day boundaries.

## Project-specific traps

- Shell navigation labels ("Nutrition", "Cycle"…) collide textually with dashboard card titles — `find.text(...)` is ambiguous in shell-level widget tests; scope with `find.descendant(of: find.byType(NavigationBar), matching: ...)`.
- **Real `App` with an in-memory Drift database: unmount inside the test body (2026-11-16).** After the last assertion, `await tester.pumpWidget(const SizedBox.shrink());` then `await tester.pump(const Duration(milliseconds: 1));` as `test/app/keto_branch_test.dart` does. Doing it in `addTearDown` is too late and fails with "A Timer is still pending even after the widget tree was disposed".
- **Format by explicit path in a shared worktree.** `dart format <dir>` in a worktree several agents are editing reformats the other agents' files too. Pass the exact files you own.

## Commands

`flutter test` (all), `flutter test test/features/x` (scoped). Coverage when wanted: `flutter test --coverage`.
