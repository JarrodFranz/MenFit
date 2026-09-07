---
name: testing
description: Use when writing tests, improving coverage, or investigating flaky/failing tests.
---

# Testing Workflow

1. **Read** — `knowledge/engineering/testing_strategy.md` (pyramid, expectations) and central `testing-pitfalls.md` (confirmed traps: setMockInitialValues-once, runAsync null-swallow, uncontested concurrency tests, guard tests for config surfaces).
2. **Pick the right layer** — pure-Dart domain tests > in-memory-Drift repository tests > ProviderContainer tests > widget tests > integration tests. Test at the lowest layer that proves the behaviour.
3. **Tests must be able to fail** — for logic guarding order/priority/forwarding, verify the test fails under a plausible regression (mutation-check). No placeholder or tautological tests, ever.
4. **Edge cases that are mandatory in this app** — date/timezone boundaries, unit conversions, retroactive cycle logging, prediction-vs-confirmed data, empty/irregular data, offline states.
5. **Flaky tests** — treat as bugs (use `bug-fix`); usual suspects: unawaited async chains, real I/O in fake-async zones, shared state between tests, physical-size not reset in teardown.
6. **Validate & capture** — `flutter test` green; new trap discoveries go to central `testing-pitfalls.md` (generic) or `knowledge/troubleshooting/` (project-specific).
