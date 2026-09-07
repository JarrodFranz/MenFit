# Coding Standards

*Established 2026-08-25. Enforcement: very_good_analysis + strict analyzer modes; riverpod_lint when installable (currently blocked — see `../troubleshooting/dependency_resolution.md`); the rest by review.*

## Validation sequence (run before claiming any change done)

```
dart run build_runner build   # after model/provider/route/table edits (the old --delete-conflicting-outputs flag was removed in this toolchain, 2026-09-02)
dart format .
flutter analyze --fatal-infos     # zero issues
flutter test                      # all pass
```

For packages with native Android code, run `flutter build apk --release` once before adoption is complete — R8 runs only in release, so a clean debug build proves nothing about it (see `knowledge/troubleshooting/android_build.md`, 2026-09-03, for the `google_mlkit_text_recognition` "Missing class" failure this caught).

## Structure & size

- Follow the layout in `../architecture/architecture_overview.md`; new features copy the existing feature shape exactly.
- No giant files: split widgets/classes approaching ~300 lines; a screen file contains one screen; extract private widgets to classes (not helper methods returning trees) once they exceed a trivial size.
- Business/domain logic never lives in widgets or controllers-as-god-objects; it lives in `domain/` (pure Dart, testable without Flutter).

## Riverpod conventions

- Codegen only (`@riverpod` / `@Riverpod(keepAlive: true)`); never hand-rolled `Provider(...)` globals.
- Default autoDispose; `keepAlive` only for app-scoped services (repositories, router, sync) with a comment unnecessary — the annotation is the signal.
- Controllers (`class Foo extends _$Foo`) hold UI state + orchestrate repository calls; they contain no domain rules.

## Widgets & theming

- No `Color(0x...)`, no ad-hoc `TextStyle`, no magic spacing numbers in feature widgets — use `Theme.of(context)`/`ColorScheme`/`AppTokens` and the spacing scale.
- No breakpoint literals outside `core/theme/breakpoints.dart`.
- `const` constructors wherever possible; keys on list items.
- Every screen must lay out correctly at compact (<600) and large (≥1200) widths — check both in widget tests when layout differs.

## Data & domain

- Freezed for entities/state; Drift rows mapped at the repository boundary (never leak Drift types above `data/`).
- UUIDv7 ids client-generated at entity creation; UTC timestamps; canonical metric units stored, converted at presentation.
- Errors: wrap raw exceptions into sealed `AppException`s at the data layer; expected outcomes are sealed result values (see error_handling.md).

## Privacy (mechanically enforced habits)

- Never log location coordinates, health/cycle values, tokens, or personal identifiers. Log event names and non-sensitive ids only.
- New collected data fields require a stated reason and a sensitivity tier (see security_and_privacy.md).

## Comments & docs

- Comments state non-obvious constraints/invariants only; no narration, no changelog comments.
- Public API docs (`///`) for `core/` utilities and domain interfaces; feature-internal code doesn't need doc comments (`public_member_api_docs` is disabled).

## Dependencies

- No new package without an evaluation (maintenance, all-4-platform support, necessity) — use the `package-evaluation` workflow; record verdicts in `../flutter/package_decisions.md`; significant ones get an ADR.
