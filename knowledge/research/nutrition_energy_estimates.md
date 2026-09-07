# Energy-Needs Estimation (BMR / TDEE) — Evidence Review

*Written 2026-08-28 for S1-4 (Nutrition core). Required by `../domain/womens_health.md` rule 2: no nutrition recommendation ships without a documented evidence review. Reviewed against: the equation literature below; no cycle-phase claims are in scope here (see "Explicitly out of scope").*

## The claim this review gates

The app estimates a user's **basal metabolic rate (BMR)** and **total daily energy expenditure (TDEE)** from profile data they optionally provide (date of birth, height, weight) plus a self-selected activity level, and uses the BMR estimate as a **floor** under any daily calorie target.

**These are estimates, not measurements, and not medical advice.** Nothing in this feature diagnoses, treats, or prescribes. Every surface that shows one of these numbers must say so.

## What Mifflin-St Jeor is

A linear regression predicting resting energy expenditure from weight, height, age and sex, published by Mifflin, St Jeor and colleagues in 1990 from indirect-calorimetry measurements on 498 healthy adults (roughly half women, ages ~19–78, spanning normal-weight and obese participants).

Published female form:

```
REE = 9.99 × weight(kg) + 6.25 × height(cm) − 4.92 × age(years) − 161
```

Male form differs only in the final term (`+ 5` instead of `− 161`).

**We implement the conventionally rounded form** — `10 × weight + 6.25 × height − 5 × age − 161` — which is what almost every consumer implementation uses. The difference from the published coefficients is about 2–4 kcal/day for a typical adult (e.g. 65 kg, 30 years: 0.01 × 65 + 0.08 × 30 ≈ 3 kcal), which is two orders of magnitude smaller than the equation's own error. Recorded here so the choice is visible rather than implicit. Implementation: `lib/features/nutrition/domain/energy_estimate.dart`.

TDEE is then `BMR × activity factor`, with the conventional 1.2 / 1.375 / 1.55 / 1.725 / 1.9 multipliers.

## Why it was chosen over the alternatives

| Equation | Why not |
|---|---|
| **Harris-Benedict** (1919; Roza & Shizgal 1984 revision) | The older standard. Derived from an early-20th-century sample and consistently reported to **overestimate** resting energy expenditure, by roughly 5% on average, in modern populations. Superseded in practice. |
| **Katch-McArdle / Cunningham** (lean-body-mass based) | More accurate *when lean body mass is known* — genuinely better for lean, athletic users, which describes part of this app's audience. Rejected because it requires a body-fat percentage the app does not collect and could not collect reliably (user-estimated body fat is worse than no input). Revisit only if body-composition data ever arrives from a source we trust. |
| **Measured indirect calorimetry** | The actual gold standard, and not something an app can do. Named here so the gap between "estimate" and "measurement" stays explicit. |
| **Mifflin-St Jeor** | **Chosen.** The 2005 Academy of Nutrition and Dietetics (then ADA) systematic review by Frankenfield and colleagues compared the common predictive equations against measured resting metabolic rate and found Mifflin-St Jeor the most reliable for both non-obese and obese healthy adults, and recommended it for that use. It needs only inputs the profile already holds. |

## Documented error margins — and what they mean for the UI

- In the Frankenfield review, Mifflin-St Jeor predicted resting metabolic rate to **within 10% of measured** in roughly 80% of non-obese healthy adults, and roughly 70% of obese adults. So even the best-validated equation is outside ±10% for **one person in five**.
- That is BMR. **TDEE is less reliable still**: the activity multipliers are coarse, poorly validated bands, and self-selection between "lightly active" and "moderately active" moves the answer by ~13% on its own. Treat the TDEE figure as the roughest number this feature produces.
- Consequence for the product: never present these as precise. Round generously, never show decimals, always label as an estimate, and never build a UI that implies a user is "over" or "under" a number derived this way. Ranges and "roughly" language are more honest than a single figure.

## The female-coefficient assumption, and its limits

The profile deliberately does not collect sex (`knowledge/product/stage1_audit.md` §5.1). Mifflin-St Jeor requires a sex term. The product decision is to **apply the female variant to everyone**, because this is a women-focused app and its population is women.

The limits, stated plainly:

- For any user the female variant does not fit, the estimate is **low by 166 kcal/day** (the difference between −161 and +5). Since a *low* estimate produces a *lower* BMR floor and a *lower* maintenance figure, this error direction is the one that reduces the floor's protective value — it is not a "safe" error.
- The equation's sex term is a proxy for average body-composition differences, not an identity claim. It does not fit every woman either: it under-predicts for users with high lean mass (well-trained athletes are the obvious case here) and behaves worst at the extremes of the input ranges.
- It says nothing about, and adjusts for nothing regarding: thyroid conditions, medications affecting metabolism, pregnancy or lactation (out of scope entirely — `../domain/nutrition.md`), menopause, prior or current disordered eating and metabolic adaptation, or age beyond a linear term.

Any future decision to collect sex, or to offer a variant switch, is a product decision with its own privacy implications and needs its own review — not a quiet code change.

## The BMR floor decision

**Rule:** the app will not produce a daily calorie target below the user's estimated BMR. If a requested deficit would go lower, the target is raised to the BMR estimate and the user is told, with the reason. Implementation: `lib/features/nutrition/domain/calorie_target.dart` (`FlooredCalorieTarget`).

Rationale:

1. **It is personal, not arbitrary.** The floor is derived from the user's own inputs and moves with them. A hardcoded number (the widely-copied "1200 kcal") is an unsourced, medical-flavoured claim that is simultaneously too low for many people and irrelevant for others. We do not ship one.
2. **It is defensible without being clinical.** "Don't plan to eat less than your body uses at rest" is a statement about what the app will suggest, not a health prescription or a threshold with a diagnostic meaning.
3. **It fits the ED-safe stance** in `../domain/nutrition.md`: deficits are allowed (the app does not refuse the user's goal outright, which would be paternalistic and would push determined users to lie to the app), but they are bounded, and the boundary is *explained* rather than silently applied.
4. **It degrades honestly.** With no estimate — because height, weight or date of birth is missing — there is no floor and therefore no target at all, rather than a default. The typed result forces callers to handle that case (`NoEnergyEstimate` / `NoCalorieTarget`).

Its limits, equally plainly: BMR estimated to ±10% means the floor is estimated to ±10% too. It is a guardrail against the app *suggesting* something unreasonable — it is not a safety threshold, not a clinical minimum, and not a substitute for a dietitian. The floor's user-facing copy says exactly that.

## Explicitly out of scope

**No claim anywhere in this feature is linked to cycle phase.** Energy needs do vary across the menstrual cycle, and the literature on the size and consistency of that variation is genuinely mixed. Under `../domain/womens_health.md` rule 2, any cycle-phase-linked nutrition guidance needs **its own** documented evidence review and product sign-off before implementation. S1-4 ships none, and the code contains no cycle inputs at all.

Also out of scope, for the same reason: pregnancy and lactation energy needs, any adjustment for RED-S / low energy availability, and any claim about macronutrient distribution beyond letting the user set their own targets.

## Sources

- Mifflin MD, St Jeor ST, Hill LA, Scott BJ, Daugherty SA, Koh YO. *A new predictive equation for resting energy expenditure in healthy individuals.* American Journal of Clinical Nutrition, 1990;51(2):241–247.
- Frankenfield D, Roth-Yousey L, Compher C. *Comparison of predictive equations for resting metabolic rate in healthy nonobese and obese adults: a systematic review.* Journal of the American Dietetic Association, 2005;105(5):775–789.
- Harris JA, Benedict FG. *A Biometric Study of Basal Metabolism in Man.* Carnegie Institution of Washington, 1919; revised by Roza AM, Shizgal HM, American Journal of Clinical Nutrition, 1984;40(1):168–182.
- Cunningham JJ. *Body composition as a determinant of energy expenditure: a synthetic review and a proposed general prediction equation.* American Journal of Clinical Nutrition, 1991;54(6):963–969. (Lean-mass approach, of which Katch-McArdle is the popular form.)

## Related

- `../domain/nutrition.md` — the ED-safe product stance this feature implements.
- `../domain/womens_health.md` — rule 2, which required this review.
- `../product/stage1_audit.md` §S1-4.
