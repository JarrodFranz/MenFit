# Product Vision

*Last updated: 2026-08-27 — revised per the product owner's women-first handover specification (see `stage1_audit.md` for the full mapping).*

## Vision refinement (2026-08-27)

The product is a **women-first fitness platform, not a period-first app**: a full fitness/running/strength/nutrition platform designed around the reality that training needs and life circumstances change — **without treating those changes as failure**. Core corollaries:

- All women's-health functionality is **optional and modular**; the app must be fully useful for users who don't menstruate, use hormonal contraception, have irregular cycles, are peri/post-menopausal, pregnant, postpartum, or don't want to track reproductive health at all.
- **Recovery is never failure**: the streak/plan systems recognise protected recovery (symptoms, flares, illness, life) as success-equivalent, with no proof demanded. Terminology: "Recovery Day / Protected Recovery", never "excused/failed/skipped because of period".
- **Respond to the individual, not stereotypes**: the user's reported state and personal history outrank cycle-phase folklore; a period with high energy changes nothing; predictions are honest ranges with confidence, never deterministic phases.
- Personalisation hierarchy: safety red-flags > user's direct request > current symptoms > recent recovery/training data > personal history > plan requirements > population assumptions.

## What we are building

A **women-focused running, fitness, health and nutrition application** — combining capabilities in the spirit of Strava (GPS activity tracking, social) and MyFitnessPal (nutrition logging), but **designed around women's physiology, safety, and needs from the ground up**, not a generic fitness app with feminine styling.

## Why it's different

Mainstream fitness apps treat the male physiology and threat model as the default. This product treats women as the default user:

- **Cycle-aware training** — the menstrual cycle is a first-class input to training load, recovery, and goal logic (e.g. fitness streaks pause during a user's period rather than breaking).
- **Safety as a feature** — trusted contacts can live-track a user during a run or workout session.
- **Women's strength & nutrition** — programming and nutrition guidance oriented to female physiology, pregnancy/postpartum considerations (future, with appropriate medical caution).
- **Privacy by design** — cycle, health, and location data are among the most sensitive data categories that exist. Minimal collection, explicit permissions, no casual flow into analytics.

## Core capability areas (long-term)

1. **Running/activity** — GPS tracking (run/walk/hike), pace, distance, elevation, routes, splits, HR, PRs, history, goals, training load.
2. **Route suggestion** — suggest runnable routes given a target distance (e.g. "give me a 5 km route from here").
3. **Fitness** — strength workouts, exercises, sets/reps/weight, plans, progression, recovery.
4. **Nutrition** — food logging, calories, macros, meals, goals, body metrics; barcode scanning later.
5. **Women's health** — cycle tracking, cycle-phase-aware recommendations, streak pausing, energy/recovery insight.
6. **Social** — profiles, sharing, friends, reactions, challenges, clubs; female-focused community norms and safety controls.

## Signature features named by the product owner

- Fitness **streaks pause automatically during the user's period** (cycle-aware streak logic).
- **Trusted-contact live tracking** during runs/exercise.
- **Route suggestions for a target distance in km.**

## Non-negotiable constraints

- Flutter, targeting **iOS, Android, Web, Windows**.
- Core domain logic stays platform-independent; platform specifics behind adapters.
- The app must be useful **without AI**; AI features are additive, later.
- No medical claims. Cycle/health features are informational and clearly disclaimed; anything resembling medical advice requires explicit product/evidence decisions first.

## Scope confirmation (2026-08-26)

The product owner confirmed the long-term goal is **full functional parity with Strava and MyFitnessPal**, adapted around women's needs — tracked feature-by-feature in `feature_parity.md`. This includes cycling as an activity type (previously "possible later"). Still deferred: monetisation decisions; wearable integrations remain architected-for until Phase K.
