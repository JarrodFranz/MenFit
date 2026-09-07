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
