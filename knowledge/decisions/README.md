# Architectural Decision Records

Lightweight ADRs for significant technical decisions. **Not** for trivial implementation choices.

## When to write an ADR

Write one when a decision is expensive to reverse, shapes many features, or a future agent would otherwise re-litigate it: state management, database, backend strategy, auth, navigation, major package adoption, data-model shifts, encryption approach.

## Conventions

- Filename: `NNN_short_name.md`, numbered sequentially.
- Status is one of: **Proposed**, **Accepted**, **Superseded by NNN**, **Rejected**.
- Never delete an ADR; supersede it.

## Template

```markdown
# NNN — Title

- **Status:** Accepted
- **Date:** YYYY-MM-DD

## Context
What problem/forces led to this decision.

## Options considered
The realistic alternatives, one line each.

## Decision
What we chose.

## Reasons
Why, concretely.

## Consequences
What this enables, costs, and constrains.

## Rejected alternatives
Why each serious alternative lost.
```

## Index

| # | Decision | Status |
|---|---|---|
| 001 | State management | Accepted |
| 002 | Navigation/routing | Accepted |
| 003 | Local database | Accepted |
| 004 | Backend strategy | Accepted (deferral) |
| 005 | Models & code generation | Accepted |
| 006 | Environment configuration | Accepted |
| 007 | Cross-feature providers (composition surface) | Accepted |
| 008 | Run recording stack (geolocator FGS, no background-location permission) | Accepted |
| 009 | Routing engine (OpenRouteService round-trip; start point leaves device — privacy-gated) | Accepted |
| 010 | Food data source (Open Food Facts behind `FoodDataProvider`; first user-typed content to leave the device; ODbL) | Accepted |
| 011 | Native sharing via share_plus (behind `SharingAdapter`; Copy stays first-class; Windows result reporting always `unavailable`) | Accepted |
| 012 | On-device nutrition label OCR (google_mlkit_text_recognition behind `OcrAdapter`, Android/iOS only; mandatory review form before save; owner go/no-go pending) | Proposed |
| 013 | Local daily step history (`daily_step_totals` keyed by day, filled from `HealthPlatformAdapter`; schema v22) | Accepted |
| 014 | Yoga sequences with timed, cued pose transitions (verified on emulator-5554, 2026-09-04) | Accepted |
| 015 | Whole-app data export as one JSON file, saved where she chooses (2026-09-04) | Accepted |
| 016 | FatSecret primary, Open Food Facts fallback (`FallbackFoodDataProvider`; per-result `source`; supersedes ADR 010's single-provider wiring, not its `FoodDataProvider` port) | Accepted |

*(Update this table when adding ADRs.)*
