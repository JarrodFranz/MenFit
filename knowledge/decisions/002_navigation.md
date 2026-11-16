# 002 — Navigation: go_router with typed routes (go_router_builder)

- **Status:** Accepted
- **Date:** 2026-08-25

## Context
Must support web URLs, deep links (future notification taps, shared activity/route links like `/routes/shared/:token`), auth redirects, nested navigation (bottom-nav on mobile, rail on desktop) across all four platforms.

## Options considered
go_router (+ go_router_builder); auto_route; beamer; raw Navigator 2.0.

## Decision
**go_router + go_router_builder** typed routes. `StatefulShellRoute.indexedStack` for the adaptive tab shell (per-tab navigator stacks). All redirect/auth-guard logic centralised in `lib/app/router/router.dart`, driven by a Riverpod auth provider via `refreshListenable` when auth exists.

## Reasons
- First-party (flutter.dev publisher), officially feature-complete + stability-focused — API won't churn under a long-lived codebase. (v18 is current on pub.dev; this project resolves 17.5.0 inside the SDK-forced dependency window — see troubleshooting/dependency_resolution.md before upgrading.)
- Covers every requirement natively; notification/shared links are just deep links — the URI scheme is designed early.
- Typed routes (`ActivityDetailRoute(id: x).go(context)`) eliminate stringly-typed path bugs, a common agent-introduced defect.

## Consequences
No major new go_router features expected (fine — set is complete); shell+redirect interplay has sharp edges → single-file redirect rule; one more build_runner target.

## Rejected alternatives
- **auto_route** — capable but single-maintainer third-party with breaking-major-version history; unjustified bet vs the first-party option.
- **beamer** — effectively dormant.
- **raw Navigator 2.0** — weeks of RouterDelegate plumbing maintained forever, for no exotic need we have.

## Amendment — 2026-11-16: Health tab; Settings moves behind the Home gear
The shell is Home, Train (`/activity`), Nutrition, Keto, **Health** (`/health`), Recovery. Adding Health would have made seven destinations, but the bottom bar is at its six-destination limit on 320 dp phones (`test/core/adaptive_scaffold_real_font_test.dart`). The owner chose to drop the Settings tab and reach Settings from the gear already on the Home app bar.

The Settings route subtree keeps every typed route class and is nested under the Home route: `/home/settings`, `/home/settings/{profile,accessibility,wearables,safety}`. Every `Settings…RouteData().go(context)` call keeps working; a deep link into Settings selects the Home tab, and back returns to Home. Coverage: `test/app/health_branch_test.dart`.
