# Architecture Overview

*Established 2026-08-25 (bootstrap). Read this before any code change. Central Flutter knowledge (cross-project): `D:\Documents\Claude\Flutter development knowledge\`.*

## Shape

Single Flutter package, **feature-oriented with three uniform layers per feature**, and a shared kernel. Not Clean-Architecture-ceremonial: no use-case classes until logic spans ≥2 repositories (the cycle-aware training suggester will likely be the first).

```
lib/
  main.dart                # thin: calls bootstrap()
  app/                     # composition root: bootstrap, App widget, router, (future) l10n
    bootstrap.dart         # binding, global error hooks, ProviderScope
    app.dart               # MaterialApp.router + theme wiring
    router/                # ALL route definitions + redirect logic live here (single route table)
  core/                    # shared kernel — no feature imports core→feature
    config/                # env.dart (ADR 006), shared_preferences_provider  [exists]
    db/                    # app_database (schema v8: profiles, activities+samples, cycle, checkins, flares, recovery days, routes) — ALL Drift tables central  [exists]
    domain/                # shared value types: entity ids (UUIDv7), units, LocalDate  [exists]
    errors/                # sealed AppException hierarchy + user message mapping  [exists]
    platform/              # platform adapters (location/…) behind interfaces  [exists]
    theme/                 # app_theme, tokens, breakpoints — design system source  [exists]
    utils/                 # combine_latest etc. — created on first need  [exists]
    widgets/               # design-system widgets (AppAdaptiveScaffold, MonthCalendar)  [exists]
    network/               # (future) api client abstraction
    sync/                  # (future) SyncService + outbox (ADR 004)
  features/<name>/
    <name>_providers.dart  # composition surface: providers typed as domain interfaces (ADR 007)
    domain/                # freezed entities, repository ABSTRACT interface, pure logic. No Flutter imports.
    data/                  # repository impl, Drift DAO, remote data source, DTOs+mappers
    presentation/          # screens, widgets, @riverpod controllers
```

Features as of 2026-08-28: `home` (dashboard: streak card + Today sheet, check-in card), `activity` (manual entry, history, GPS recording with forgotten-end handling, splits/PRs, route maps), `routes` (suggestion via ORS — ADR 009, saved routes), `cycle` (period tracking), `wellbeing` (check-ins, flares), `streaks` (protected-recovery engine + recovery_days data), `progress` (weekly trends + PRs), `nutrition` (food diary, custom foods, day/meal totals, targets + BMR/TDEE estimate — S1-4), `profile` (expanded §5.1), `onboarding`, `settings`. Planned: `auth`, `workouts`, `safety` (trusted contacts + live tracking), `social`.

## Dependency rules (enforced by convention + review; lint tooling if violated repeatedly)

1. `domain/` imports no Flutter, no data/, no presentation/.
2. Features may depend on another feature's **domain/** and its **`<name>_providers.dart` composition surface** (feature root; exposes providers typed as domain interfaces — ADR 007) — never its data/ or presentation/.
3. Truly shared entities live in `core/domain`, not copied between features.
4. Platform-specific code (health, location, notifications, sharing, secure storage) lives behind interfaces in `core/platform/` or the owning feature's domain interface, with per-platform adapters; **nothing outside adapters may import `dart:io`-conditional or plugin-specific APIs**. `SharingAdapter` (share_plus, ADR 011) lives at `core/platform/sharing/`.
5. Every feature gets all three folders even when thin — uniformity beats economy (agents copy shapes).

## Key mechanisms (see ADRs)

- **State/DI:** Riverpod 3 codegen (ADR 001). Controllers call repositories; repositories are provided via `@Riverpod(keepAlive: true)`.
- **Routing:** go_router typed routes, `StatefulShellRoute.indexedStack`, redirects centralised (ADR 002).
- **Persistence:** Drift, offline-first, UUIDv7 ids, outbox sync when backend arrives (ADRs 003/004).
- **Models:** freezed entities; Drift rows mapped at repository boundary (ADR 005).
- **Errors:** data layer wraps raw errors into sealed `AppException`s; `AsyncValue` carries them to UI; *expected* outcomes are sealed return values, not exceptions (see engineering/error_handling.md).
- **Responsive:** M3 window size classes, constants only from `core/theme/breakpoints.dart`; `AppAdaptiveScaffold` switches NavigationBar/NavigationRail (see platform_architecture.md).
- **Theme:** M3 `ColorScheme.fromSeed` + `AppTokens` ThemeExtension for semantic colors (cycle phases, intensity zones) and spacing/radius scales. No raw `Color(0x...)` in feature widgets.

## Sensitive-data architecture constraint

Cycle/health/location data handling rules in `engineering/security_and_privacy.md` are architectural requirements, not suggestions: local-first for S3 data, no sensitive data in logs/analytics, cycle data never denormalised into other records.

## What we deliberately did NOT build (avoid overengineering)

Melos monorepo/package split (boundaries preserved by rule 2 keep this option open), use-case classes, generic repository base classes, event bus, plugin system, DI beyond Riverpod. Add only when a concrete need arrives, via ADR.

## Composition-surface cycle trap (2026-09-04)

A feature whose presentation must be reachable from another feature exposes a
`<name>_widgets.dart` barrel (ADR 007 amendment). If its controller imports
the feature's own `<name>_providers.dart`, do **not** re-export the controller
from that providers surface: two generated `part` files then form a library
cycle. The controller belongs in the widgets barrel (`data_export` is the
worked example: `data_export_providers.dart` exposes the service and source,
`data_export_widgets.dart` exposes the controller, dialog and state types).

## Overlays from shell tabs (added 2026-09-02, revised 2026-09-03)

**Every modal bottom sheet goes through `core/widgets/app_bottom_sheet.dart`'s
`showAppBottomSheet`.** No feature calls `showModalBottomSheet` directly;
`test/app/modal_sheets_use_root_navigator_test.dart` scans `lib/` and fails on
any that does. The wrapper owns the two things a sheet gets wrong on a device
and never in a test:

* **The navigator.** `useRootNavigator: true`, always. The shell branch
  navigator's overlay is the tab body, so a branch-level sheet is clipped
  above the `NavigationBar` and the tabs stay live under the scrim.
* **The system navigation bar.** Android draws edge-to-edge (mandatory from
  Android 15) and Flutter's `useSafeArea: true` only guards the *top*
  (`SafeArea(bottom: false)` inside `ModalBottomSheetRoute`). The wrapper pads
  the sheet's content by `max(viewPadding.bottom, viewInsets.bottom)` -
  nav bar, or keyboard when it is up and covering the bar - and consumes that
  padding via `MediaQuery.removePadding`, so a sheet must NOT add its own
  `SafeArea` or `viewInsets` padding.

`showDialog` still passes `useRootNavigator: true` at its call sites; a
centred dialog has no bottom-inset problem.

Content that centres horizontally on wide screens uses
`Align(alignment: Alignment.topCenter)` + `ConstrainedBox(maxWidth)` around
the scroll view, never `Center` (it also centres vertically).

Full-screen routes outside the shell carry their own bottom inset: their
`Scaffold.body` root is a `SafeArea`. Scaffold handles it for you only in the
`floatingActionButton`, `bottomNavigationBar` and `persistentFooterButtons`
slots - content you pin to the bottom of the body yourself needs a `SafeArea`.

## Shared month grid (added 2026-09-03)

`core/widgets/month_calendar.dart`'s `MonthCalendar` owns the month-grid
mechanics both calendars need: header + prev/next + jump-to-today, the
weekday row, the 5/6-row layout, swipe paging, the full-bleed cell tap
target (the 2dp-inside-the-cell padding trick) and the per-day semantics
wrapper. It is **controlled** — the caller owns the displayed month and
gets `onMonthChanged` — because a calendar whose contents come from a
per-month query has to know which month is showing. Callers supply only a
per-day visual and an optional spoken label via `cellBuilder`, plus an
optional `latestMonth` cap on forward navigation (cycle leaves it null for
predictions; wellbeing caps it at the current month). Extracted from
`cycle_calendar_view.dart` with no behaviour or appearance change.
