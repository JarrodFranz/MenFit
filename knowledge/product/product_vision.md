# Product Vision

*Last updated: 2026-09-07 at the fork from FemFit (ADR 017). Historical framing before this date described a women-first product; that framing does not apply here.*

## What we are building

A **men's strength-first training, running and nutrition application** —
combining capabilities in the spirit of Strava (GPS activity tracking,
social) and MyFitnessPal (nutrition logging), built around consistent
training, honest recovery, and adequate fuelling — not a generic fitness app
reskinned.

## Vision principles

- **Recovery is never failure**: the streak/plan systems recognise protected
  recovery (illness, injury, flares, life) as success-equivalent, with no
  proof demanded. Terminology: "Recovery day", never "excused/failed/skipped".
- **Respond to the individual, not stereotypes**: the user's reported state
  and personal history outrank population folklore; predictions are honest
  ranges with confidence, never deterministic claims.
- **Strength-first**: Home leads with training and progression, not with a
  single headline metric.
- Personalisation hierarchy: safety red-flags > user's direct request >
  current symptoms > recent recovery/training data > personal history > plan
  requirements > population assumptions.

## Why it's different

- **Strength-first training** — programming, progression memory and
  streak/recovery logic are built around consistent lifting and running, not
  bolted onto a generic tracker.
- **Safety as a feature** — trusted contacts can live-track a user during a
  run or workout session.
- **Privacy by design** — health check-ins, flares, body weight and location
  data are among the most sensitive categories the app holds. Minimal
  collection, explicit permissions, no casual flow into analytics.

## Core capability areas (long-term)

1. **Running/activity** — GPS tracking (run/walk/hike), pace, distance, elevation, routes, splits, HR, PRs, history, goals, training load.
2. **Route suggestion** — suggest runnable routes given a target distance (e.g. "give me a 5 km route from here").
3. **Fitness** — strength workouts, exercises, sets/reps/weight, plans, progression, recovery.
4. **Nutrition** — food logging, calories, macros, meals, goals, body metrics; barcode scanning.
5. **Recovery** — check-ins, flare logging (injury, illness, migraine, back pain, other), flare-protected streaks.
6. **Social** — profiles, sharing, friends, reactions, challenges, clubs.

## Non-negotiable constraints

- Flutter, targeting **iOS, Android, Web, Windows**.
- Core domain logic stays platform-independent; platform specifics behind adapters.
- The app must be useful **without AI**; AI features are additive, later.
- No medical claims. Health/recovery features are informational and clearly
  disclaimed; anything resembling medical advice requires explicit
  product/evidence decisions first (`knowledge/domain/mens_health.md`).

## Scope

Full functional parity with Strava and MyFitnessPal, adapted for a
strength-first men's audience — tracked feature-by-feature in
`feature_parity.md`. Monetisation decisions and wearable integrations remain
deferred (`deferred.md`).
