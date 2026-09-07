# Evidence Review: Female Micronutrient & Iron Adequacy

*Required by `knowledge/domain/womens_health.md` Rule 2 and
`knowledge/domain/nutrition.md` before implementing any feature that evaluates
nutrient adequacy against biological reference intakes or cycle phase.*

---

## 1. Background & Scope

Female runners and active women have distinct micronutrient requirements
driven by reproductive physiology (menstrual blood loss) and athletic demands
(mechanical impact, bone turnover, sweat losses, and exercise-induced
hepcidin surges).

This feature evaluates daily and weekly logged intake against recognized
**Biological Dietary Reference Intakes (DRIs / RDAs)** for key micronutrients:
- **Iron (Fe)**
- **Calcium (Ca)**
- **Vitamin D**
- **Dietary Fiber**
- **Vitamin C (Ascorbic Acid)**

---

## 2. Biological Reference Intakes & Physiological Rationale

### A. Iron (Fe)
- **Reference Standard**:
  - Premenopausal adult females (19–50): **18 mg/day** (NIH ODS / Institute
    of Medicine / EFSA / NHMRC).
  - Post-menopausal females or non-menstruating baseline: **8 mg/day**.
  - Tolerable Upper Intake Level (UL): 45 mg/day.
- **Menstrual Phase Impact**:
  - Average menstrual blood loss is 30–40 mL per cycle, equating to an iron
    loss of 15–20 mg per cycle (~1.5–2.0 mg/day of elemental iron during
    active bleeding days).
  - Compensating for this loss requires sustained dietary intake of ~18 mg/day.
- **Athletic Considerations for Female Runners**:
  - Foot-strike hemolysis (erythrocyte rupture from mechanical shock in
    running shoes).
  - Exercise-induced inflammation triggers an increase in the liver hormone
    **hepcidin** (peaking 3–6 hours post-exercise), which binds to and degrades
    ferroportin, blocking intestinal iron absorption. Consuming iron-rich meals
    in the morning or well before strenuous afternoon training optimizes
    absorption.
  - Non-heme iron (plant sources) has lower bioavailability (~5–12%) than
    heme iron (~15–35%). Ascorbic acid (Vitamin C) acts as a powerful reducing
    agent, significantly increasing non-heme iron uptake when consumed in the
    same meal.

### B. Calcium (Ca)
- **Reference Standard**:
  - Adult females (19–50): **1,000 mg/day**.
  - Females >50: **1,200 mg/day**.
  - Tolerable Upper Intake Level (UL): 2,500 mg/day.
- **Athletic Considerations**:
  - Bone mineral density (BMD) is a critical protective buffer against
    bone stress injuries (stress reactions and stress fractures) in runners.
  - In female athletes experiencing low energy availability (Relative Energy
    Deficiency in Sport / RED-S), estrogen suppression accelerates bone
    resorption. Ensuring calcium adequacy is an essential nutritional defense.

### C. Vitamin D
- **Reference Standard**:
  - Adult females: **15 mcg/day (600 IU)** (20 mcg / 800 IU for >70).
  - Tolerable Upper Intake Level (UL): 100 mcg/day (4,000 IU).
- **Synergistic Action**:
  - Vitamin D is indispensable for active intestinal transport and absorption
    of dietary calcium. Without adequate vitamin D, only 10–15% of dietary
    calcium is absorbed.
  - Plays vital roles in skeletal muscle contractile performance, immune
    homeostasis, and injury recovery.

### D. Supporting Nutrients
- **Dietary Fiber**:
  - Adequate Intake (AI): **25 g/day** for adult females.
  - Promotes gastrointestinal motility, microbiome biodiversity, and healthy
    circulating estrogen clearance.
- **Vitamin C**:
  - RDA: **75 mg/day**.
  - Essential cofactor for collagen synthesis (ligaments, tendons, cartilage)
    and acts synergistically to enhance non-heme iron absorption.

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
     "14.2 of 18 mg").
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
