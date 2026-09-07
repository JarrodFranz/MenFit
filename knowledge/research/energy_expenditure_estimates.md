# Activity Energy Expenditure ("Calories Burnt") — Evidence Review

*Written 2026-08-28. Required by `../domain/mens_health.md` rule 2: no health
calculation ships without a documented evidence review. Companion to
`nutrition_energy_estimates.md` (BMR/TDEE), whose conclusions this review
depends on and must not contradict. Presentation constraints are governed by
the ED-safe stance in `../domain/nutrition.md`. Fork note (2026-09-07): this
review's body is FemFit-era research into MET-equation sex differences and is
not currently wired to any shipped feature (see `nutrition.md`'s "no code
path from an activity energy estimate to `calorie_target.dart`" rule). It is
left as historical evidence rather than rewritten, since MenFit has no
activity-energy feature to gate; redo this review for an adult-male
population before ever wiring one up.*

## The claim this review gates

The app estimates the **energy expended during a single recorded activity**
(run, walk, hike, ride) from: activity type, duration, distance (hence average
pace), the user's body weight and age from her profile, and a GPS track with
elevation. **There is no heart-rate input.**

**This is an estimate of a population average applied to an individual. It is
not a measurement, and the realistic error is large enough — roughly ±20–30%
for an individual, worse at low intensities — that it must never be presented
as a precise figure and must never be connected to the user's food target.**
Every surface showing it must say the first part; the architecture must enforce
the second.

## 1. The candidate methods

| Method | Needs | Produces | Real-world accuracy |
|---|---|---|---|
| **MET / Compendium** | Activity type, speed band, body mass, duration | Gross kcal | Population-mean oxygen cost per kg applied to an individual. Errors dominated by body composition, economy, terrain, surface. **Feasible with our inputs.** |
| **ACSM metabolic equations** | Speed (m/min), fractional grade, body mass | Gross VO₂ → kcal | Stated ceiling ~7%; independent validation finds ~12% systematic overestimation, mean differences −30% to +20%. Valid only in narrow speed windows. **Feasible; the only method with a principled gradient term.** |
| **Distance rule** (~1 kcal/kg/km, running) | Distance, body mass | kcal | Robust to pace noise; running only. Literature inconsistent on gross vs net — itself a ~10% error. **Feasible.** |
| **Heart-rate methods** | HR, age, sex, mass | kcal | Not available to us, and **not the accuracy fix people assume**: Shcherbina et al. (2017) found seven wrist devices measured HR to within 1.8–5.5% while their *energy* error was 27% for the best device and 93% for the worst. |
| **Indirect calorimetry / DLW** | Lab, mask, isotopes | The reference | Named so the gap between "estimate" and "measurement" stays explicit. |

**Recommendation: MET-based**, with ACSM as the source of a gradient term if
elevation is ever used, and the distance rule as a sanity check rather than a
second implementation. §2.5 shows MET and distance agree to ±7% for running, so
the choice between them is not where the error lives.

## 2. The MET route

### 2.1 The formula

```
kcal/min = MET × 3.5 × bodyMassKg / 200      ≡      kcal = MET × bodyMassKg × hours
```

Algebraically identical. The `/200` is `÷1000` (ml → L) `× 5` (kcal per litre
of O₂); the `× 3.5` converts a MET back into ml O₂/kg/min.

### 2.2 Why the "3.5 is a male value" objection mostly does not apply here

A Compendium MET is **measured activity VO₂ ÷ 3.5**. The 3.5 is a stipulated
resting value traced by Byrne et al. (2005) to the resting oxygen consumption
of **one 70 kg, 40-year-old man**.

But because `kcal/min = (VO₂_measured / 3.5) × 3.5 × kg / 200`, **the 3.5
cancels.** For an activity whose Compendium value was *measured*, the formula
returns the originally measured population-mean absolute oxygen cost per kg.
The male-derived constant does not propagate one-for-one into the calorie
figure.

The constant's documented bias therefore bites in exactly three places:

1. **Intensity classification** ("moderate"/"vigorous") — genuinely wrong for
   many people (Kozey 2010). **We do not classify intensity, so this does not
   affect us.**
2. **Estimated rather than measured Compendium entries** — 18% of 2024 entries.
3. **The gross-to-net subtraction**, if we subtract a generic "1 MET". See §5.

**The widespread claim that "MET calories are 20–35% too high for women because
3.5 is a male value" is not correct as stated.** The real female-specific
concerns are different, and are §4.

### 2.3 2024 Compendium values (all rows measured, not estimated)

**Running** — 6.4 km/h 6.5 · 8.0 km/h 8.5 · 9.7 km/h 9.3 · 10.8 km/h 10.5 ·
11.3 km/h 11.0 · 12.1 km/h 11.8 · 12.9 km/h 12.0 · 14.5 km/h 13.0 ·
16.1 km/h 14.8

**Walking (level, firm)** — <3.2 km/h 2.3 · 3.2–3.9 2.8 · 4.0 3.0 ·
4.5–5.5 3.8 · 5.6–6.3 (brisk) 4.8 · 6.4–7.1 5.5 · 7.2–7.9 7.0 · 8.0–8.9 8.5

**Walking uphill, no load** — 1–5% grade 5.3 · 6–10% 7.0 · 11–20% 8.8

**Hiking** — slow/ambling 3.8 · normal pace 5.3 · cross-country 6.0

**Cycling** — <16 km/h 4.0 · 16–19 6.8 · 19–22 8.0 · 22–25 10.0 · 26–30 12.0 ·
mountain 8.5 · self-selected easy/moderate/vigorous 4.3 / 7.0 / 9.0

> **Band trap.** These step coarsely. 10.1 km/h is 9.3 MET; 10.8 km/h is 10.5 —
> a **13% jump for a 6% pace change**. Typical GPS distance error of 2–5% can
> move a user across a boundary and change her displayed figure by more than a
> tenth. **Interpolate linearly between band midpoints**; do not implement the
> step function naively.

### 2.4 The distance rule and its ambiguity

Margaria et al. (1963): the energy cost of running per unit distance is
essentially speed-independent, giving ~1 kcal/kg/km. It is quoted inconsistently
as gross and as net — Margaria's own figure is usually reported as **net**,
modern simplifications use a **gross** 1.03–1.04. Measured: **1.01–1.07
kcal/kg/km in men, 1.05–1.09 in women.** The gross/net ambiguity alone is ~10%,
which is why we derive net explicitly from METs rather than adopt a constant
whose basis is unclear.

**Does not transfer to walking**: walking cost per km is roughly half running's,
strongly speed-dependent with a minimum near 1.2–1.4 m/s. Never apply a per-km
constant to a walk.

### 2.5 The two methods agree

Compendium running METs converted to kcal/kg/km give **0.92–1.06 gross across
8–16 km/h** — the "1 kcal/kg/km" rule is a fair summary of the Compendium
itself. The methods agree within ±7%. **Gross-vs-net (§5) and presentation (§7)
are where the real decisions are.**

### 2.6 Worked examples (65 kg user)

**5 km run in 30:00** (10 km/h → 9.3 MET): gross 302 kcal · net via generic
1 MET 270 · net via her own Mifflin-St Jeor BMR 273 · distance rule 309–325.
**Honest presentation at ±20%: "roughly 220–330 kcal".**

**60-minute walk at 5 km/h** (3.8 MET): gross 247 · net **182 — 26% lower.**
The gross/net choice matters far more for walking than for running.

## 3. Accuracy and error margins

- **Consumer devices vs indirect calorimetry** — Shcherbina et al. (2017),
  n=60, seven wrist wearables: **energy expenditure error 27% for the best
  device, 93% for the worst.** The closest published analogue to what a consumer
  app shows. The authors explicitly caution against using device EE in
  health-improvement programmes.
- **ACSM equations** — ACSM states ≤7%; independent validation found predicted
  VO₂ **12% greater than measured**, the running equation overestimating in
  **88% of subjects**; walking SEE 1.56–3.15 ml/kg/min (10–25% of a walking
  VO₂). Worst in the walk/run transition region.
- **MET questionnaires vs doubly labelled water** — across seven instruments,
  **none** produced statistically equivalent activity energy expenditure;
  differences **−547 to +77 kcal/day**.
- **Inter-individual economy** — even among trained runners at the same speed,
  running economy varies ~**8%**; within-subject test–retest CV 2–3%. An
  irreducible individual offset survives any method.
- **The caloric equivalent of oxygen** — the flat 5.0 kcal/L is correct only at
  RER 1.00; at 0.70 it is 4.686. Worth **±3–4%**, biased to overestimation at
  easy intensities.
- **Where it goes most wrong:** low intensities (resting share largest, RER
  assumption worst, bands coarsest — a slow walk is the least reliable figure
  this feature will produce); walking generally; high and low body mass
  (Browning & Kram 2006: net cost per kg ~10% greater in class-II obesity, body
  fat % r² = 0.43); gradient; trail and uneven surfaces, for which the
  firm-level-surface values are simply the wrong reference.

**Assume ±20–30% for an individual, worse for slow walks.** No published work
supports tighter for this input set.

## 4. Female-specific limitations — the section that matters most

### 4.1 Well established

- **Byrne et al. (2005)** — 769 adults, **642 women (83%)**. Measured resting
  **2.6 ± 0.4 ml O₂/kg/min** and **0.84 ± 0.16 kcal/kg/h**, both well below the
  stipulated 3.5 and 1.0: **the 3.5 constant overestimates resting VO₂ by 35%,
  the 1 kcal/kg/h constant overestimates resting EE by 20%.** Fat mass and
  fat-free mass together explained **62%** of the variance, against 14% for age.
- **Wilms et al. (2014)** — n=1,331, **72% women**. MET-REE **2.47 ± 0.33
  ml/kg/min in women vs 2.62 ± 0.34 in men**; deviation from 3.5 significantly
  greater in women, worsening with BMI.
- **The mechanism is body composition, not sex as such.** At matched mass women
  carry more fat and less metabolically active fat-free mass; normalised to
  fat-free mass, **sex differences largely disappear**. Same mechanism our BMR
  review invokes for the Mifflin-St Jeor sex term.

### 4.2 The contradicting evidence, which must not be suppressed

**The direction of the bias flips in leaner, fitter populations.**

- Individually measured 1-MET was **significantly higher** than 1 kcal/kg/h in
  control men, control women *and* endurance-trained men — the standard constant
  **under**estimates for active people. MAPE **6.6% for control women vs 10.3%
  for control men**, and **endurance-trained women showed no significant
  difference from the standard value at all.**
- Adolescent females measured **1.11 kcal/kg/h** (95% CI 1.07–1.14),
  significantly *above* 1.0. Pregnant (1.01) and post-pregnant (1.00) women were
  indistinguishable from 1.0.

**So "the constant overestimates for women" is true for women with higher
adiposity and false for lean, trained women — for whom it is roughly right or
slightly low.** An app that "corrected downward for women" would make its
estimates *worse* for exactly the runners it is built for.

### 4.3 Does the bias reach the *exercise* number?

Only partly, and the evidence points both ways.

- Per §2.2 the 3.5 cancels for measured entries. The question becomes whether
  the Compendium's population means represent women. **The sex composition of
  the 2024 Compendium's source studies could not be established — a real gap,
  recorded as one.**
- **Walking:** Browning & Kram (2006), n=39 — **net metabolic rate per kg ~10%
  greater in women than men**, independent of the obesity effect. Points to a
  sex-blind walking estimate **under**estimating for women by roughly a tenth.
- **Running:** measured cost **1.05–1.09 kcal/kg/km in women vs 1.01–1.07 in
  men**, and **no significant sex effect** once intensity is expressed relative
  to lactate threshold. Sex is a minor term.
- **Substrate use:** women oxidise proportionally more fat at matched relative
  intensity → slightly lower RER → **2–3%** fewer kcal per litre O₂. Real,
  directionally correct, comfortably inside the noise. Not a reason to act.
- **ACSM equations** contain **no sex term at all**, and carry the same
  male-derived `+3.5`. One validation notes overestimation bias in fitter women.

### 4.4 The honest summary

The resting-constant finding is **well evidenced and quantified**. The claim
that it translates into a specific, signed error in **activity** estimates for
recreationally active women is **not**:

- the resting constant largely cancels out of the arithmetic;
- the resting bias and the walking-cost bias point in **opposite directions**
  at similar magnitude, so they partly cancel;
- the resting finding **reverses sign** in lean and trained women, a large part
  of this app's audience;
- the strongest female-specific evidence comes from clinical obesity cohorts,
  not recreational female runners;
- **no DLW or calorimetry validation of MET-derived workout-calorie estimates
  in recreationally active women was located.** If none exists, that absence is
  itself the finding.

**Therefore: apply no sex-based correction factor.** There is no defensible
coefficient, the evidence would not support its sign, and inventing one is
exactly the folklore rule 2 exists to prevent. The correct response to this
uncertainty is **a wider presented range and plainer language**, not a fudge
factor.

### 4.5 A trap to avoid explicitly

The Compendium publishes a "corrected METs" method (divide the standard MET by
the individual's predicted RMR in ml/kg/min). **It exists for intensity
classification and must never be used to compute calorie totals** — correcting
the MET then multiplying back by the standard 3.5 changes the absolute estimate
in a way the Compendium does not endorse and no validation supports. It is a
natural-looking "improvement" that would silently make the number worse. This
belongs in a code comment so it is not helpfully added later.

## 5. Gross vs net — and the double-count that actually matters

### 5.1 The resting share is `1 / MET`

Running 10 km/h (9.3) **11%** · cycling 19–22 km/h (8.0) 13% · hiking (5.3) 19%
· brisk walk (4.8) 21% · easy cycling (4.0) 25% · walking 4.5–5.5 km/h (3.8)
**26%**.

So gross-vs-net is worth ~10% on a run and **about a quarter of the number on a
walk**.

### 5.2 The much larger error next door

Our TDEE is `BMR × activity factor`, and **those multipliers already contain
habitual exercise**. For a 65 kg, 165 cm, 30-year-old woman (BMR ≈ 1370):
sedentary (1.2) = 1644 kcal; moderately active (1.55) = 2124. **The multiplier
step alone adds 480 kcal/day — more than an entire 5 km run.**

Adding a logged workout on top of an activity-adjusted TDEE therefore does not
merely double-count the resting share; **it double-counts almost the whole
workout.** This is the MyFitnessPal failure mode in its severe form, and it is
the concrete hazard here because **both numbers already exist in this codebase.**

### 5.3 The decision

**Report net, and never wire it to the nutrition target.**

```
netKcal = (MET × bodyMassKg × hours) − (mifflinStJeorBmrPerDay / 1440) × minutes
```

1. **It is the quantity the literature defines.** In the energy-availability
   framework, gross exercise energy expenditure explicitly includes RMR "that
   should be subtracted to provide a net value" — relevant here because the
   RED-S / low-energy-availability literature is the closest clinical neighbour
   to anything a women's running app displays.
2. **It is the only figure that could ever be combined with anything else
   without double counting** — so even though §7 forbids combining it, the
   stored number should be the combinable one, making a future mistake smaller.
3. **It is the smaller, more conservative number.** In an ED-safe app the
   conservative direction is the right default for a figure that could
   rationalise restriction.

**Use her own BMR, not a generic 1 MET.** Free, more personal, internally
consistent with the BMR floor, and it avoids the male-derived constant in the
one place §2.2 shows it does *not* cancel. It also degrades correctly: **with no
BMR estimate (missing height, weight or date of birth) there is no net figure
and therefore no estimate at all** — a typed absence in the same shape as
`NoEnergyEstimate` / `NoCalorieTarget`, never a silent fallback to gross.

## 6. Elevation

### 6.1 The evidence

Minetti et al. (2002), −45% to +45% grade:

- **Walking:** minimum 1.64 ± 0.50 J/kg/m level; **17.33 ± 1.11 at +45%**; falls
  to a *minimum* of **0.81 ± 0.37 at −10%**, then **rises again to 3.46 ± 0.95
  at −45%**.
- **Running:** 3.40 ± 0.24 J/kg/m level; **18.93 ± 1.74 at +45%**; minimum
  **1.73 ± 0.36 at −20%**; back to **3.92 ± 0.81 at −45%**.

Two consequences a naive implementation gets wrong:

- **Descent is not negative ascent.** Cost falls to a minimum around −10%/−20%
  then *increases* as eccentric braking dominates. **A signed net-elevation term
  is physiologically wrong.**
- **Net elevation zero ≠ flat.** An out-and-back over a hill costs more than a
  flat route of the same distance. Only **cumulative** ascent and descent carry
  information, and cost is convex in gradient, so applying an average gradient
  to a rolling route systematically underestimates.

### 6.2 Is there a defensible coefficient?

Partly. Converting ACSM's grade terms to energy per **vertical** metre:

- **Walking: 0.009 kcal/kg per vertical metre.** Independently corroborated —
  raising 1 kg by 1 m is 9.81 J, so this implies ~26% gross efficiency, squarely
  that of concentric muscular work and consistent with Minetti's steep-slope
  marginal cost. **Well anchored.**
- **Running: 0.0045 kcal/kg per vertical metre** — about **half** the walking
  coefficient and half what Minetti and the physics imply (~0.008–0.009). ACSM's
  running grade term is calibrated for 0–10% treadmill grades and is widely held
  to be low outside that. **Contested by roughly a factor of two.**

8 km trail run, 300 m ascent, 65 kg: base gross ≈ 494 kcal; ascent adjustment
**+88 (ACSM, +18%)** or **+176 (Minetti/physics, +36%)**. A term worth up to a
third of the total, on which two defensible sources differ twofold.

### 6.3 The data problem

Our ascent figure is not a trustworthy measured quantity. GPS altitude is
precise to a few metres at best; barometric altimeters are better but drift with
weather — **a 4 hPa pressure drop registers ~120 ft of phantom gain while
standing still.** Every platform applies undisclosed smoothing, so "300 m of
ascent" is a **platform-specific derived statistic**, and the same run yields
materially different figures on different devices.

### 6.4 Decision

**Do not shift the point estimate for elevation in v1.** The effect is real and
sometimes large, but our input is unreliable, the running coefficient is
contested twofold, and a signed term would be actively wrong.

**Let elevation widen the presented range instead** — since §7 requires a range
anyway, substantial cumulative ascent extends the upper bound (defensibly, by
the ACSM ascent term) with a one-line note that hilly routes cost more. Honest
about both the physiology and our measurement quality, and it cannot produce a
confidently-wrong single number.

If a future version acquires trustworthy barometric ascent, the **walking/hiking**
coefficient is anchored well enough for a point estimate. The running one is not.

## 7. What may and may not be claimed

### 7.1 A single number is not defensible; a range is

At ±20–30% individual error, "302 kcal" asserts a precision that does not exist.
**Show a coarsely rounded range** — "roughly 220–330 kcal". Never decimals.
Never narrower than the evidence. If a single number is unavoidable for layout,
round to at least the nearest 25 kcal and label it as an estimate **in the same
visual unit** — not a footnote, not behind an info icon.

### 7.2 Mandatory disclaimers

Every surface must say, in plain words: that it is an **estimate from averages**,
not a measurement of her body; that individual variation is large; and that it
is **not an amount of food she needs to eat, or may eat.** The third is not
optional and is not covered by the first two.

### 7.3 Prohibited — enforce in types and tests, not in a style guide

1. **Never added to the daily calorie target**, automatically or by opt-in.
   §5.2 shows this would double-count almost the entire workout. There must be
   **no code path** from the activity estimate to `calorie_target.dart`.
2. **Never as calories "earned", "banked", "available" or "offset".** No
   exchange-rate framing in either direction.
3. **Never as food equivalence** ("that's a slice of cake"), in copy,
   notifications or share images.
4. **Never as a goal, target, streak input or achievement.** No weekly or
   monthly totals, no personal bests, no badges — summing a ±25% estimate over a
   month produces a number with no meaning and considerable pull.
5. **Never used to compute, justify or widen a deficit**, including through any
   energy-availability display, which would need its own review.
6. **Never the headline metric of a workout.** Distance, duration and pace are
   measured; this is inferred, and the visual hierarchy must say so.
7. **Never compared between users or to a reference value.**
8. **Never labelled with a unit implying measurement** — avoid "burnt", which
   asserts a physiological fact. "Estimated energy used" is accurate and
   unremarkable.

### 7.4 Interaction with the hide-calories preference

It is a calorie number, so `nutrition_goals.hide_calorie_numbers` must blank it.
It does **not** qualify for either documented exception in `../domain/nutrition.md`
— those cover *input* surfaces where a user could not otherwise complete her
task. This is a derived output on a workout screen. It is squarely inside the
preference's scope, and the activity screen needs the same "no calorie text
findable at all" test the nutrition day view already has.

**Stronger, and the recommendation this review makes: the estimate is its own
opt-in, off by default.** (a) Unlike the BMR floor it has no protective
function; (b) hide-calories is a nutrition-diary setting, and a user who left it
off has not thereby consented to calorie figures on her runs; (c) a user who
wants it can enable it in one tap, and a user who does not should never have
seen it once.

## 8. Recommendation

**Ship it — but only under all four constraints. If any one will not be built,
do not ship the feature.**

1. **Opt-in, off by default**, and additionally suppressed by hide-calories.
2. **A rounded range, never a single precise number**, labelled as an estimate
   on the same surface, with the "this is not food you need to eat" line stated
   rather than implied.
3. **Net, not gross** — minus her own Mifflin-St Jeor BMR for the duration; **no
   estimate at all when there is no BMR estimate**, as a typed absence.
4. **An architectural firewall to nutrition.** No code path from this estimate to
   the calorie target, the diary, or any daily total. A layer rule with a test,
   not a convention.

Plus: **no sex correction factor** (§4.4); **no elevation adjustment to the
point estimate** in v1 — ascent widens the range (§6.4); **no "corrected METs"**
applied to totals (§4.5); **interpolate between MET bands** rather than stepping
(§2.3).

**The case against shipping at all is coherent and is recorded rather than
dismissed:** the BMR floor earns its ±10% error because it *protects* the user,
while this number has no protective function, carries a wider error, and is the
exact metric that fuels compensatory exercise. If the product cannot commit to
constraints 1 and 4, the honest choice is to show distance, duration, pace and
elevation — all measured — and no calorie figure at all.

**What tips the balance to ship:** the error is not materially worse than the
TDEE figure the app already displays with disclaimers; the number is derivable
by any user with a calculator and will otherwise be sought from an app that
presents it far less carefully; and a well-disclaimed range, opt-in, is a
smaller risk than a user importing an unconstrained figure from elsewhere. That
balance depends entirely on the constraints holding.

## 9. Known gaps — stated so silence is not mistaken for evidence

- **The sex composition of the 2024 Compendium's source studies was not
  established.** The biggest unresolved question for §4.3.
- **No DLW or calorimetry validation of MET-derived workout-calorie estimates in
  recreationally active women was located.**
- **The running gradient coefficient is contested twofold** and this review did
  not resolve it.
- **Nothing here is linked to cycle phase.** Energy cost across the menstrual
  cycle has genuinely mixed literature and needs **its own** review under rule 2.
  This feature must contain no cycle inputs.
- **Pregnancy, postpartum and lactation are out of scope entirely.**
- **Trail/uneven-surface running** has no good Compendium reference; the hiking
  entries are the nearest available and are not equivalent.

## 10. Sources

- Herrmann SD, Willis EA, Ainsworth BE, et al. *2024 Adult Compendium of
  Physical Activities.* J Sport Health Sci 2024;13(1):6–12. PMID 38242596.
  Tables and corrected-METs guidance at https://pacompendium.com.
- Byrne NM, Hills AP, Hunter GR, Weinsier RL, Schutz Y. *Metabolic equivalent:
  one size does not fit all.* J Appl Physiol 2005;99(3):1112–1119. PMID 15831804.
- Wilms B, Ernst B, Thurnheer M, Weisser B, Schultes B. *Correction factors for
  the calculation of metabolic equivalents in overweight to extremely obese
  subjects.* Int J Obes 2014;38(11):1383–1387. PMID 24503879.
- Kozey S, Lyden K, Howe CA, Staudenmayer JW, Freedson PS. *Errors in MET
  estimates of physical activities using 3.5 ml·kg⁻¹·min⁻¹ as the baseline
  oxygen consumption.* J Phys Act Health 2010;7(4):508–516. PMID 20683093.
- *Comparison of Conventional and Individualized 1-MET Values…* PMC6412759, 2019.
  (The §4.2 counter-evidence.)
- *Metabolic Equivalent in Adolescents, Active Adults and Pregnant Women.*
  PMC4963914, 2016.
- Browning RC, Baker EA, Herron JA, Kram R. *Effects of obesity and sex on the
  energetic cost and preferred speed of walking.* J Appl Physiol
  2006;100(2):390–398. PMID 16210434.
- Minetti AE, Moia C, Roi GS, Susta D, Ferretti G. *Energy cost of walking and
  running at extreme uphill and downhill slopes.* J Appl Physiol
  2002;93(3):1039–1046. PMID 12183501.
- Margaria R, Cerretelli P, Aghemo P, Sassi G. *Energy cost of running.* J Appl
  Physiol 1963;18(2):367–370. PMID 13932993.
- Shcherbina A, Mattsson CM, Waggott D, et al. *Accuracy in Wrist-Worn,
  Sensor-Based Measurements of Heart Rate and Energy Expenditure in a Diverse
  Cohort.* J Pers Med 2017;7(2):3. PMC5491979.
- *ACSM's Guidelines for Exercise Testing and Prescription*, metabolic-equations
  appendix — 11th ed. (2021); **verify the current edition before citing in
  shipped copy.** Walking `VO₂ = 0.1·S + 1.8·S·G + 3.5`; running
  `VO₂ = 0.2·S + 0.9·S·G + 3.5` (S m/min, G fractional grade). Both gross.
- *Pitfalls of Conducting and Interpreting Estimates of Energy Availability in
  Free-Living Athletes.* Int J Sport Nutr Exerc Metab 2018;28(4):350–363.

## 11. Related

- `nutrition_energy_estimates.md` — the BMR/TDEE review this depends on; §5.3
  reuses its Mifflin-St Jeor estimate and §5.2 concerns its activity multipliers.
- `../domain/nutrition.md` — the ED-safe stance governing §7.
- `../domain/mens_health.md` — rule 2, which required this review (this review's body predates the fork; see the note at the top of the file).
