# Blood pressure classification and health-marker logging: evidence review

## Status

Evidence gathered 2026-11-16. The owner signed off the Heart Foundation of
Australia 2016 categories and wording on 2026-11-16. The signed-off design is a
per-reading category, a 7-day-average headline once 5 of 7 days have readings,
a source line, a not-a-diagnosis line, and a re-measure / doctor / 000 line at
or above 180/110.

Scope: the proposed Health tab, where the user manually logs blood pressure
(systolic, diastolic, pulse) and blood glucose. The app shows the named
category of a published guideline with its source. It does not give a bespoke
verdict, a diagnosis or medical advice. Gate: `../domain/mens_health.md`.

## As built (2026-11-16)

The shipped behaviour differs from, or adds to, the recommendation below in
these ways. Code: `lib/features/health/domain/blood_pressure_category.dart`
and `lib/features/health/presentation/blood_pressure_*.dart`.

- Readings under 90 systolic or under 60 diastolic get no category and show
  the low line instead. This is an addition beyond the owner's wording,
  because the guideline does not classify low readings.
- The 7-day average has its own wording for the highest-range line and the
  low line (an average is not a single reading, so it does not say to measure
  again).
- Averages display rounded down, so the shown number never disagrees with its
  category (a 129.6 average shows as 129 beside "Normal", never 130).
- The chart draws dashed reference lines at 140 systolic and 90 diastolic,
  captioned with the guideline.

## Recommendation

Display the **National Heart Foundation of Australia 2016** classification by
default. Do not build a guideline selector.

- It is still the current Australian adult guideline. The Heart Foundation
  professional page (updated 12 October 2026) says "New guidelines coming
  soon". Healthdirect cites the 2016 guideline.
- It matches what an Australian GP will say: hypertension starts at 140/90.
- ACC/AHA would label 130/80 "Stage 1 hypertension". ESC 2024 would label a
  diastolic of 70 "Elevated". Both contradict local practice and would
  over-flag fit men.
- Keep the thresholds as one versioned data table (source id and year). The
  coming Australian guideline then becomes a data swap. Re-check on its
  release.

The table is defined for clinic readings. Apply it to the 7-day average and
show the home note from the draft copy. Whether to name "hypertension" grades
at all is an owner decision, given the regulatory section below.

## Table to implement

Heart Foundation 2016, Table 2.1 "Classification of clinic blood pressure
levels in adults". Checked against the guideline PDF.

| Category | Systolic (mmHg) | | Diastolic (mmHg) |
|---|---|---|---|
| Optimal | <120 | and | <80 |
| Normal | 120–129 | and/or | 80–84 |
| High-normal | 130–139 | and/or | 85–89 |
| Grade 1 (mild) hypertension | 140–159 | and/or | 90–99 |
| Grade 2 (moderate) hypertension | 160–179 | and/or | 100–109 |
| Grade 3 (severe) hypertension | ≥180 | and/or | ≥110 |
| Isolated systolic hypertension | >140 | and | <90 |

- **Tie-break:** the higher category wins. The table footnote says that when
  systolic and diastolic levels "fall into different categories, the higher
  diagnostic category and recommended actions apply". Implement as
  `max(sysCategory, diaCategory)`.
- **Isolated systolic hypertension:** do not implement as a label. It is a
  subtype that overlaps the grades.
- **Home threshold (Table 4.3):** hypertension by home monitoring is ≥135
  and/or ≥85. Clinic is ≥140 and/or ≥90. Daytime ambulatory is ≥135/85,
  night-time ≥120/70, 24-hour ≥130/80.
- **Home protocol (Table 4.6):** validated upper-arm device; morning and
  evening; after 5 minutes sitting; two consecutive measures 1 minute apart.
  Finger and wrist devices are not recommended (Table 4.4).
- **Headline category:** compute it from the 7-day average once at least 5
  days have readings. The Heart Foundation consumer page says seven days
  (minimum five), two measures one minute apart. Show a per-reading label only
  with the single-reading caveat.

## Age and sex

**No adult guideline reviewed changes its diagnostic categories by age or
sex.** Only treatment thresholds and targets vary with age.

- Heart Foundation 2016: one table for all adults. For patients over 75, a
  systolic target below 120 may be used if tolerated.
- ESC 2024: single cutoffs for all adults. More lenient targets apply at 85
  and over, or with frailty.
- ESH 2023: one classification. Drug initiation at 80 and over is at systolic
  ≥160 (editors' commentary only).
- ACC/AHA 2025: one category set (press release).
- Population percentiles (NHANES, AIHW) describe how readings are distributed,
  not what is healthy. Average blood pressure rises with age, so "normal for
  your age" hides risk. None of the four guidelines uses percentiles for
  adults. The AIHW and NHANES sources were not opened.

## Other guidelines

| Guideline | Categories (mmHg) | Mixed systolic/diastolic | Home readings |
|---|---|---|---|
| ACC/AHA 2017, kept in 2025 (published 14 Aug 2025) | Normal <120 and <80; Elevated 120–129 and <80; Stage 1 130–139 or 80–89; Stage 2 ≥140 or ≥90 | Higher category (from memory, not verified) | Home monitoring recommended to confirm; multiple readings required |
| ESC 2024 | Non-elevated <120/70; Elevated 120/70 to <140/90; Hypertension ≥140/90. No grades | "and/or": either value qualifies | Own home column: <120/70; 120/70 to <135/85; ≥135/85 |
| ESH 2023 | Same grades as Heart Foundation 2016, plus isolated diastolic hypertension (numbers from memory) | Higher category (from memory, not verified) | ≥135/85 |

- No guideline classifies a single reading. ESC 2024 uses two readings 1–2
  minutes apart, twice daily, for 3 to 7 days, averaged. It says a single
  screening reading is not sufficient for a diagnosis.
- No newer Australian adult guideline has been published. A paediatric
  guideline was released in July 2026. The RACGP reviewed an adult draft and
  asked for clearer thresholds.

## Low readings

- No guideline defines a low category. Heart Foundation 2016 excludes
  "diagnosis and treatment of hypotension" from its scope.
- Healthdirect gives no number: "any blood pressure that is lower than
  expected for you".
- ESC 2024 defines only orthostatic hypotension: a drop of ≥20 systolic or
  ≥10 diastolic on standing.
- The <90/60 trigger used in the draft copy is a common convention. It was not
  verified against a primary source in this review.

## Crisis range

- Heart Foundation 2016: hypertensive urgency is above 180/110 with symptoms
  or moderate organ damage. Emergency is often above 220/140 with acute organ
  damage. Marked elevation alone "does not automatically require emergency
  therapy".
- ESC 2024: at ≥180/110, assess for hypertensive emergency.
- ACC/AHA 2025: "severe hypertension" is above 180/120 without acute organ
  damage. The term "hypertensive urgency" is retired (secondary sources).
- AHA consumer wording (search snippet; the page returned 403): above 180/120
  with symptoms, call emergency services and do not wait. Without symptoms,
  contact a health professional. The five-minute recheck is attributed to the
  AHA by secondary sources only.
- Healthdirect lists symptoms of very high blood pressure (headache, vomiting,
  eyesight problems, confusion, seizures, chest pain, shortness of breath) and
  says to go to an emergency department or call 000. The Heart Foundation
  consumer page has no crisis wording.
- Comparable products: Withings uses AHA 2017 in the US and Canada and ESC/ESH
  in the EU; its BPM Pro 2 shows "hypertensive crisis" and says to contact a
  physician immediately (snippets). Omron US manuals use ACC/AHA 2017;
  elsewhere Omron cites the ESH home threshold of 135/85 (snippets). Apple
  Watch hypertension notifications are "not intended to diagnose". No source
  was found for Apple Health or Samsung Health category displays.

## Entry bounds

| Field | Health Connect (verified) | Devices (snippets) | Recommended hard bounds |
|---|---|---|---|
| Systolic | 20–200 mmHg; 20–300 on SDK extension 17+ | Withings 60–230 | 40–300 |
| Diastolic | 10–180 mmHg; 10–300 on SDK extension 17+ | Withings 40–130 | 20–200 |
| Pulse | not part of the blood pressure record | Omron and Withings 40–180 | 25–250 |
| Glucose | 0–50 mmol/L | — | 0.5–50 mmol/L |

- Require systolic greater than diastolic.
- The recommended bounds are a judgement of this review, not a standard.
- A later write to Health Connect on devices below SDK extension 17 throws
  above 200 systolic or 180 diastolic.

## Blood glucose

Default product decision stands: **store and chart, no interpretation.**

**Superseded 2026-11-16:** the owner chose to show reference ranges, so
`blood_glucose_reference_ranges.md` now governs glucose. The rest of this
section is kept as the original evidence.

- Units: mmol/L is the Australian unit. mg/dL = mmol/L × 18.016. As built,
  the app stores the value as entered together with its unit (the Keto "as
  printed" precedent) and converts only for display and charting.
- Contexts: Health Connect has general, fasting, before meal and after meal.
  Bedtime has no enum value; map it to general.
- The Australian and US prediabetes bands disagree. That is a further reason
  not to interpret.

Reference tables — **not displayed by the app**:

| Measure | ADA 2026 (verified) | RACGP (snippet) |
|---|---|---|
| Diabetes, fasting | ≥7.0 mmol/L (126 mg/dL) | ≥7.0 mmol/L |
| Diabetes, 2-hour, or random with symptoms | ≥11.1 mmol/L (200 mg/dL) | ≥11.1 mmol/L |
| Diabetes, HbA1c | ≥6.5% (48 mmol/mol) | same |
| Prediabetes, fasting | 5.6–6.9 mmol/L (100–125 mg/dL) | 6.1–6.9 mmol/L |
| Prediabetes, 2-hour | 7.8–11.0 mmol/L (140–199 mg/dL) | 7.8 to <11.1 mmol/L |
| Prediabetes, HbA1c | 5.7–6.4% (39–47 mmol/mol) | not diagnosable by HbA1c |
| Goals for people with diabetes | before meals 4.4–7.2; peak after meals <10.0 mmol/L | — |
| Hypoglycaemia | Level 1 <3.9 and ≥3.0; Level 2 <3.0 mmol/L | — |

One abnormal result never diagnoses. ADA requires two abnormal results.

## Regulatory position (not legal advice; needs owner decision)

- TGA: the Therapeutic Goods (Excluded Goods) Determination 2018, items 14A to
  14E (inserted 2021), excludes consumer-facing software for "general health
  or wellness". The explanatory statement says items 14A and 14B do not
  exclude software "used in relation to serious diseases". The test is the
  intended purpose shown in labelling and advertising. The item text itself
  was not opened (the TGA site timed out).
- FDA: the general wellness guidance was revised on 6 January 2026. Law-firm
  summaries say a product leaves general wellness if it references diseases or
  diagnostic thresholds, or has alarms that direct medical action.
- Consequence: store-and-chart is the safest position. Named hypertension
  categories and the crisis prompt sit nearer the line. Any glucose
  interpretation is nearer still.

## Marker units for later additions

Standard conversions; not re-verified in this review. Show no interpretation
for any of these.

| Marker | Australia | US | Conversion |
|---|---|---|---|
| Total, LDL, HDL cholesterol | mmol/L | mg/dL | mg/dL = mmol/L × 38.67 |
| Triglycerides | mmol/L | mg/dL | mg/dL = mmol/L × 88.57 |
| Glucose | mmol/L | mg/dL | mg/dL = mmol/L × 18.016 |
| HbA1c | % and mmol/mol | % | mmol/mol = (% − 2.15) × 10.929 |
| Total testosterone | nmol/L | ng/dL | ng/dL = nmol/L × 28.84 |
| PSA | µg/L | ng/mL | 1:1 |
| Ferritin | µg/L | ng/mL | 1:1 |
| 25-OH vitamin D | nmol/L | ng/mL | ng/mL = nmol/L ÷ 2.496 |

Data model: store marker id, value and unit, with one conversion entry per
marker. HbA1c is an affine conversion, not a simple multiply.

## Smartwatch-derived metrics

- Show trends against the user's own baseline only. Show no normal ranges.
- Apple says Blood Oxygen is "not intended for medical use" and only for
  "general fitness and wellness purposes".
- The 2025 AHA/ACC guideline does not recommend cuffless devices for clinical
  blood pressure assessment (secondary sources).
- HRV and sleep-stage definitions differ by vendor, so values are not
  comparable across devices. This is general knowledge, not sourced in this
  review.
- Suggested label: "From your watch. An estimate, not for medical use."

## Copy (signed off 2026-11-16; source of truth is `lib/features/health/presentation/blood_pressure_copy.dart`)

- **Category labels:** `Optimal`, `Normal`, `High-normal`,
  `Grade 1 (mild) hypertension range`,
  `Grade 2 (moderate) hypertension range`,
  `Grade 3 (severe) hypertension range`.
- **Source line:** "Categories: National Heart Foundation of Australia,
  Guideline for the diagnosis and management of hypertension in adults (2016).
  Defined for clinic readings."
- **Not a diagnosis:** "This shows where your numbers sit in a published
  guideline. It is not a diagnosis or medical advice. Only a health
  professional can diagnose high blood pressure."
- **Single reading:** "One reading is a snapshot. Blood pressure changes
  through the day. The guideline works from averages: two readings a minute
  apart, morning and evening, over about a week."
- **Home note** (average ≥135/85 and <140/90): "Home readings usually run
  lower than clinic readings. The same guideline treats a home average of
  135/85 or more like 140/90 in a clinic."
- **Age and sex:** "These categories are the same for all adults. They do not
  change with age or sex."
- **Crisis line** (≥180 or ≥110): "This reading is in the highest range of the
  guideline. Sit quietly for five minutes and measure again. If it is still
  this high, contact a doctor today. If you also have chest pain, shortness of
  breath, a severe headache, confusion, weakness or numbness, or trouble
  seeing or speaking, call 000 now."
- **Low line** (<90 or <60): "This reading is below the ranges the guideline
  classifies. Low blood pressure is often normal, especially in fit people. If
  you feel dizzy, faint or unwell, talk to a doctor. If you collapse or feel
  very unwell, call 000."

## Sources

Accessed 2026-11-16.

Opened and read:

- [Heart Foundation 2016 guideline PDF (third-party mirror)](https://static1.squarespace.com/static/56b957c5d51cd446dcdb43d8/t/5905277e893fc05255722e2a/1493510021495/PRO-167_Hypertension-guideline-2016_WEB.pdf).
  Tables 2.1, 4.3, 4.4, 4.6; scope; urgency text. Not hosted on
  heartfoundation.org.au.
- [MJA 2016 guideline summary](https://www.mja.com.au/journal/2016/205/2/guideline-diagnosis-and-management-hypertension-adults-2016).
- [Heart Foundation professional hypertension page](https://www.heartfoundation.org.au/for-professionals/hypertension)
  and [consumer page](https://www.heartfoundation.org.au/your-heart/blood-pressure-and-your-heart).
- [ESC 2024 guideline, Eur Heart J](https://academic.oup.com/eurheartj/article/45/38/3912/7741010).
  First 200k of 264k characters, read through a summarising fetch.
- [Rev Esp Cardiol comment on ESC 2024](https://www.revespcardiol.org/en-comments-on-2024-esc-guidelines-articulo-S1885585725000477).
- [ACC press release, 2025 AHA/ACC guideline](https://www.acc.org/about-acc/press-releases/2025/08/13/20/03/new-high-blood-pressure-guideline-emphasizes-prevention-early-treatment-to-reduce-cvd-risk).
- [Editors' commentary on ESH 2023, Hypertension](https://pmc.ncbi.nlm.nih.gov/articles/PMC10527435).
- [ADA Standards of Care 2026, Section 2](https://pmc.ncbi.nlm.nih.gov/articles/PMC12690183)
  and [Section 6](https://pmc.ncbi.nlm.nih.gov/articles/PMC12690178).
- Healthdirect [high blood pressure](https://www.healthdirect.gov.au/high-blood-pressure-hypertension)
  and [low blood pressure](https://www.healthdirect.gov.au/low-blood-pressure-hypotension),
  both reviewed November 2024.
- Health Connect [BloodPressureRecord](https://developer.android.com/reference/kotlin/androidx/health/connect/client/records/BloodPressureRecord)
  and [BloodGlucoseRecord](https://developer.android.com/reference/kotlin/androidx/health/connect/client/records/BloodGlucoseRecord).
- [TGA explanatory statement F2021L00047](https://www.legislation.gov.au/F2021L00047/asmade/2021-01-15/es/original/pdf).
- [Apple Blood Oxygen support page](https://support.apple.com/en-au/120358).
- [FDA general wellness guidance page](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices).
  Issue date only.

Not opened (HTTP 403 or timeout; search snippets or memory only):

- heart.org consumer pages, including
  [Understanding Blood Pressure Readings](https://www.heart.org/en/health-topics/high-blood-pressure/understanding-blood-pressure-readings).
- 2025 AHA/ACC guideline full text (DOI 10.1161/CIR.0000000000001356).
- ESH 2023 primary guideline (DOI 10.1097/HJH.0000000000003480).
- TGA excluded-software guidance and the Determination's item text.
- Withings and Omron support pages.
- RACGP type 2 diabetes handbook.

## Open uncertainties

- The new Australian adult guideline may change the categories. No release
  date is confirmed.
- ESH 2023 thresholds and the ACC/AHA tie-break rule are from memory. The
  ACC/AHA clinic-to-home equivalence table is unverified.
- The five-minute recheck is grounded in Heart Foundation Table 4.6 (five
  minutes seated before measuring). The AHA attribution is secondary.
- Apple Health and Samsung Health category behaviour is unknown.
- The TGA definition of "serious disease" was not read. The legal position
  needs an owner decision.
- Marker conversion factors and smartwatch accuracy claims were not
  re-verified.
- The <90/60 low-reading trigger is a convention, not a guideline threshold.
