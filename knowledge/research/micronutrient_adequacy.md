# Evidence Review: Male Micronutrient Adequacy

*Required by `knowledge/domain/mens_health.md` Rule 2 and
`knowledge/domain/nutrition.md` before implementing any feature that evaluates
nutrient adequacy against biological reference intakes. Fork note
(2026-09-07): this review replaces the FemFit-era female-physiology review at
the fork from FemFit (ADR 017); rewritten against adult-male Dietary
Reference Intakes.*

---

## 1. Background & Scope

Active adult men have micronutrient requirements driven by training demands
(mechanical impact, bone turnover, sweat losses) rather than the
menstrual-blood-loss driver that shaped the female-specific iron intake used
before the fork.

This feature evaluates daily and weekly logged intake against recognized
**Dietary Reference Intakes (DRIs / RDAs)** for key micronutrients, sourced
from the NIH Office of Dietary Supplements (ODS) reference tables:

- **Iron (Fe)**
- **Calcium (Ca)**
- **Vitamin D**
- **Dietary Fiber**
- **Vitamin C (Ascorbic Acid)**

---

## 2. Biological Reference Intakes & Physiological Rationale

### A. Iron (Fe)
- **Reference Standard**: Adult males (19–50): **8 mg/day** (NIH ODS / Institute
  of Medicine). Tolerable Upper Intake Level (UL): 45 mg/day.
- **Athletic Considerations**:
  - Foot-strike hemolysis (erythrocyte rupture from mechanical shock in
    running shoes) applies regardless of sex.
  - Exercise-induced inflammation triggers an increase in the liver hormone
    **hepcidin** (peaking 3–6 hours post-exercise), which binds to and degrades
    ferroportin, blocking intestinal iron absorption. Consuming iron-rich meals
    well before strenuous training optimizes absorption.
  - Non-heme iron (plant sources) has lower bioavailability (~5–12%) than
    heme iron (~15–35%). Ascorbic acid (Vitamin C) acts as a powerful reducing
    agent, significantly increasing non-heme iron uptake when consumed in the
    same meal.
  - Because the adult-male reference (8 mg/day) is under half the
    premenopausal-female reference the FemFit build used (18 mg/day), the app
    must not carry over any FemFit-era hardcoded threshold — the domain layer
    reads the reference value from one place (`knowledge/domain/mens_health.md`).

### B. Calcium (Ca)
- **Reference Standard**: Adult males (19–50): **1,000 mg/day**; males >70:
  **1,200 mg/day**. Tolerable Upper Intake Level (UL): 2,500 mg/day.
- **Athletic Considerations**: Bone mineral density (BMD) is a protective
  buffer against bone stress injuries (stress reactions and stress fractures)
  in runners and lifters alike; calcium adequacy is a nutritional defense
  regardless of sex.

### C. Vitamin D
- **Reference Standard**: Adult males: **15 mcg/day (600 IU)** (20 mcg /
  800 IU for >70). Tolerable Upper Intake Level (UL): 100 mcg/day (4,000 IU).
- **Synergistic Action**: Vitamin D is indispensable for active intestinal
  transport and absorption of dietary calcium. Without adequate vitamin D,
  only 10–15% of dietary calcium is absorbed. Plays vital roles in skeletal
  muscle contractile performance, immune homeostasis, and injury recovery.

### D. Supporting Nutrients
- **Dietary Fiber**: Adequate Intake (AI): **38 g/day** for adult males
  (higher than the 25 g/day female reference — driven by the higher total
  energy intake reference for adult men, per the same DRI tables).
- **Vitamin C**: RDA: **90 mg/day** for adult males (higher than the 75
  mg/day female reference). Essential cofactor for collagen synthesis
  (ligaments, tendons, cartilage) and acts synergistically to enhance
  non-heme iron absorption.

---

## 3. Product Rules & Domain Invariants

1. **No Medical Claims or Clinical Diagnosis**:
   - The app surfaces biological reference intakes for educational and
     lifestyle adequacy monitoring only.
   - The app must never diagnose iron deficiency anemia, osteopenia, or
     osteoporosis.
   - Therapeutic high-dose supplementation (e.g. 100–200 mg elemental iron)
     is clinical treatment that requires physician oversight and bloodwork
     (ferritin / transferrin saturation); the app never prescribes dosages.
2. **No Calorie-Style Budgets or Shaming**:
   - Nutrient tracking must never turn red or convey "over-budget" penalties
     when intake exceeds reference values.
   - Progress bars clamp at 100% and express positive attainment (e.g.
     "6.4 of 8 mg").
3. **Honesty Regarding Incomplete Food Label Data ("Partial Reports")**:
   - Food packaging standards in many jurisdictions (such as EU and
     Australia/NZ) do not require iron, calcium, or vitamin D to be declared
     unless fortified or advertised.
   - When any logged food in a day omits a nutrient, the day total is
     explicitly flagged as **"Partial report (floor)"**. The app must never
     substitute `0` for missing values, which would mislead the user.
4. **Non-Medical Disclaimer**:
   - All surfaces displaying micronutrient adequacy must carry a visible
     disclaimer stating that reference values are general guidelines and
     not individualized medical advice.

## Sources

- NIH Office of Dietary Supplements fact sheets (Iron, Calcium, Vitamin D,
  Vitamin C) — Dietary Reference Intake tables for adult males 19–50.
- Institute of Medicine (National Academies) Dietary Reference Intake
  reports for iron, calcium, vitamin D, fiber and vitamin C.
