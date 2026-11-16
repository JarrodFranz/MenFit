# Blood glucose reference ranges: evidence review

## Status

Evidence gathered 2026-11-16. Owner chose to show reference ranges
(2026-11-16); the specific range table below is the reviewed proposal.

Product sign-off on the table, the context mapping and the wording: the
orchestrator narrowed the proposal as described in "As built" below. The
owner has not separately confirmed the narrowed table. One pre-ship check is outstanding: the RCPA
page was read from a 2024 archive copy, not the live page (see Open
uncertainties).

Scope: the Health tab, blood glucose marker only. Self-measured finger-prick
readings, logged with a context (`fasting`, `beforeMeal`, `afterMeal`,
`bedtime`, `other`) in mmol/L or mg/dL. Adult male user without diagnosed
diabetes. The app shows a published general reference range next to the
reading, with its source, labelled as not a diagnosis. Gate:
`../domain/mens_health.md`.

This review supersedes the "store and chart, no interpretation" default in the
"Blood glucose" section of `blood_pressure_classification.md`. It also
verifies the RACGP numbers that file took from a search snippet.

## As built (orchestrator ruling, 2026-11-16)

Code: `lib/features/health/domain/blood_marker_reference.dart` and
`lib/features/health/presentation/blood_marker_copy.dart`.

- Only `fasting` (3.0–5.4 mmol/L) and `afterMeal` (3.0–7.7 mmol/L, label
  "After a meal (2 h or more)") have a range and a per-reading position.
- `beforeMeal`, `bedtime`, `other` and a reading with no context are
  store-and-chart only. The before-meal mapping in the table below was an
  inference by this review, not a sourced range, so it was dropped.
- The comparison is made at one decimal place in mmol/L. The mg/dL text
  therefore reads "about 54–98" and "about 54–139", because 98 mg/dL rounds to
  5.4 mmol/L and counts as within range.
- The low lines show for any reading under 3.0 mmol/L regardless of context.
  Safety text must not depend on a dropdown choice.
- The above-range line carries no reassurance.
- The "15.0 or more" urgent line and the 3.0–3.9 soft note are **not
  implemented**. The trigger is not sourced for people without diabetes. This
  is an open owner decision.
- The RCPA live page could not be opened (bot verification, twice, including
  from a browser). The numbers rest on a Wayback copy dated 4 October 2024.
  The owner should confirm them in a browser before a public release.

## Recommendation

Display the **RCPA Manual reference interval for glucose** (Royal College of
Pathologists of Australasia). Do not build a source selector.

- It is the only Australian source found that publishes a *reference
  interval* rather than a diagnostic threshold or a treatment target.
- It gives two intervals: fasting, and more than 2 hours after eating.
- Its upper bounds agree with every other source read:
  - Fasting 5.4 matches the RACGP 2024 screening flowchart, where fasting
    glucose below 5.5 mmol/L is "Diabetes unlikely".
  - 7.7 matches "below 7.8" in Diabetes Australia, IDF 2011 and WHO 2006.
- The entry itself says "whole blood meters are now routinely calibrated to
  give plasma equivalent results". That is the only bridge any source gives
  from a laboratory interval to a home meter.
- Keep the table as one versioned data record (source id, year, URL), as the
  blood pressure table is. A changed interval is then a data swap.

Rejected as the display source:

- **Diabetes Australia "4.0–7.8 mmol/L"** for a person without diabetes
  "throughout the day". It has no fasting range. A fasting reading of 7.5
  would show as within range, yet 7.0 fasting is the diabetes diagnostic
  threshold. It cites no source and names no sample type.
- **RACGP 2024, ADA 2026, WHO 2006.** These publish diagnostic thresholds for
  venous laboratory samples, not reference ranges.

## Table to implement

RCPA Manual, "Glucose", section "Reference Interval: Venous plasma or serum".
Last reviewed by RCPA 02 Jan 2024.
<https://www.rcpa.edu.au/Manuals/RCPA-Manual/Pathology-Tests/G/Glucose>

| Context | Reference range (mmol/L) | mg/dL (×18.016) | Basis |
|---|---|---|---|
| `fasting` | 3.0–5.4 | 54–97 | Direct: "Fasting: 3.0 - 5.4 mmol/L" |
| `afterMeal` | 3.0–7.7, for 2 hours or more after eating | 54–139 | Direct, with the time qualifier: ">2 h post-prandial 'Random': 3.0 - 7.7 mmol/L" |
| `beforeMeal` | 3.0–7.7, for 2 hours or more after eating | 54–139 | Inferred. The source does not say "before meal". Owner decision |
| `bedtime` | no reviewed range — store and chart only | — | Time since eating is unknown |
| `other` | no reviewed range — store and chart only | — | Time since eating is unknown |

- **Bounds:** both ends inclusive, at one decimal place. Fasting is within
  range when 3.0 ≤ value ≤ 5.4. The RCPA text confirms the upper ends:
  fasting "< 5.5 mmol/L and/or random levels < 7.8 mmol/L make diabetes
  mellitus unlikely".
- **Comparison rule:** round the stored mmol/L value to one decimal place
  (half up), then compare. Australian meters display one decimal place.
- **mg/dL:** RCPA publishes no mg/dL figures. The mg/dL column is this
  review's conversion (3.0 → 54.05, 5.4 → 97.29, 7.7 → 138.72), rounded to
  whole numbers.
  - Edge case: 98 mg/dL is 5.44 mmol/L, which rounds to 5.4 and is within
    range, although the displayed bound is 97. Either display 54–98 in mg/dL
    mode or compare mg/dL entries against the displayed whole-number bounds.
    Pin the choice with a test.
- **`afterMeal` in the first 2 hours:** no reviewed range. Readings then run
  higher, and capillary readings run higher than venous ones (WHO 2006). The
  app does not record time since eating, so the range line must carry the
  "2 hours or more after eating" qualifier. Renaming the context label to
  "2 h after meal" would remove the ambiguity (owner decision).
- **`beforeMeal`:** the mapping assumes a pre-meal reading is at least 2 hours
  after the last food. A reading before breakfast is better logged as
  `fasting`. If the owner does not accept the inference, set `beforeMeal` to
  "no reviewed range".
- **Lower bound 3.0, not 4.0.** See "Low readings".

## What the other sources say

| Source | Figure | Applies to | Opened |
|---|---|---|---|
| RACGP handbook, Figure 1 (recommendations dated 14/11/2024) | FBG <5.5 "Diabetes unlikely"; 5.5–6.9 "Diabetes possible"; ≥7.0 or random ≥11.1 "Diabetes likely" | Asymptomatic high-risk adults; venous samples | Yes |
| RACGP handbook, Figure 1, after OGTT | Fasting <6.1 and two-hour <7.8: "Normal glucose tolerance"; IFG 6.1–6.9; IGT two-hour ≥7.8 and <11.1 | 75 g OGTT, venous | Yes |
| RACGP handbook, Box 2 | Diabetes: FBG ≥7.0, random ≥11.1, two-hour ≥11.1, HbA1c ≥6.5% (48 mmol/mol). "These tests are undertaken on venous blood samples." | Diagnosis | Yes |
| Diabetes Australia, "Blood glucose level range" | "4.0 – 7.8" mmol/L "throughout the day" | Person without diabetes; sample type not stated | Yes |
| Diabetes Australia, same page | Before meals 4.0–7.0; 2 hours after starting meals 5.0–10.0 | Targets, type 1 and type 2 diabetes | Yes |
| ADA Standards of Care 2026, Section 2 | Diabetes: FPG ≥7.0 (126 mg/dL), 2-h ≥11.1 (200). Prediabetes: FPG 5.6–6.9 (100–125), 2-h 7.8–11.0 (140–199) | Venous plasma | Yes (first 100k characters) |
| ADA Standards of Care 2026, Section 6 | Goals: before meals 4.4–7.2; peak after meals <10.0. Hypoglycaemia Level 1 <3.9 and ≥3.0; Level 2 <3.0 | People with diabetes | Yes (first 100k characters) |
| WHO/IDF 2006 | Diabetes: fasting ≥7.0 or 2-h ≥11.1. IGT: 2-h ≥7.8 and <11.1. IFG: fasting 6.1 to 6.9 | Venous plasma | Yes |
| IDF 2011 postmeal guideline | Plasma glucose "generally rises no higher than 7.8 mmol/l (140 mg/dl) in response to meals and typically returns to premeal levels within two to three hours" | People with normal glucose tolerance | Yes |
| Alfred Health pathology handbook | Fasting 3.5–6.0; random 3.5–7.7 (effective 06/06/2013) | One hospital laboratory | Yes |
| Healthdirect, blood glucose test | No range for people without diabetes | — | Yes |

- **WHO 2006 declines to define "normal".** Recommendation 2: "Since there are
  insufficient data to accurately define normal glucose levels, the term
  'normoglycaemia' should be used". This is a reason to say "reference range"
  and never "normal".
- **The fasting upper bound is not agreed worldwide.** RCPA and RACGP use 5.4
  (below 5.5). ADA uses below 5.6. WHO and the RACGP post-OGTT row use below
  6.1. Laboratories differ too (Alfred: 6.0). The app shows one named
  source's interval. It does not claim a universal one.
- **RACGP is inconsistent with itself** on the IGT upper bound: a footnote
  says "≥7.8 to <11.0", Figure 1 says "≥7.8 and <11.1". Not displayed, so no
  effect.
- **The RCPA entry writes its diagnostic text as ">7.0" and ">11.1"**, where
  RACGP, WHO and ADA write "≥". Not displayed, so no effect.

## Finger-prick meter against laboratory test

No source read gives a reference range defined for self-monitored capillary
glucose in people without diabetes. The Diabetes Australia sentence is the
nearest and does not name the sample type. The table above is a laboratory
venous interval applied to meter readings. The copy must say so.

- **Fasting:** WHO 2006: "Fasting values for venous and capillary plasma
  glucose are identical."
- **Not fasting:** WHO 2006: "in the non-fasting state capillary will give
  higher results than venous samples." WHO says it provides capillary
  conversion values for post-load readings. They were not found in the
  extracted text, so none are quoted here.
- **Plasma against whole blood:** WHO 2006: plasma glucose is "approximately
  11% higher" than whole blood. RCPA: meters "are now routinely calibrated to
  give plasma equivalent results".
- **Meter accuracy:** ISO 15197:2013 requires 95% of results within ±15 mg/dL
  of the reference below 100 mg/dL, and within ±15% at or above it (Freckmann
  et al. 2015; the standard itself was not opened). ±15 mg/dL is about ±0.8
  mmol/L (this review's conversion). A true fasting 5.0 can read anywhere
  from about 4.2 to 5.8 on a compliant meter.
- **Australian position on home meters:** the ADS/ADEA 2007 position
  statement says portable monitors "have significant attendant error
  (> 10%)" and sees "no role for routine home capillary blood glucose
  monitoring in people with prediabetes".
- **Diagnosis is a laboratory matter.** RACGP: venous samples, repeated on a
  second day when there are no symptoms. ADA 2026: glucose results "can vary
  depending on sample type ... and source (capillary, venous, arterial)".
- **Diabetes Australia** on repeat readings: "All meters will give a
  different result with a different drop of blood. As long as there is not a
  big difference (more than 2mmol/L) there is not usually cause for concern."

**A 2-hour OGTT value is not an "after a meal" value.** The OGTT is a 75 g
glucose drink taken fasting, with a venous sample at 2 hours. Its 7.8 and 11.1
cut-offs define IGT and diabetes for that test only. The app's `afterMeal`
range comes from the RCPA post-prandial interval, not from the OGTT.

## Low readings

- **4.0 is the low threshold for people with diabetes.** Healthdirect: "A
  blood glucose level lower than 4 mmol/L is considered hypoglycaemia", on a
  page about diabetes medicines. Diabetes Australia: "usually below
  4.0mmol/L".
- **For people without diabetes the evidence points to 3.0.**
  - RCPA lower reference limit: 3.0 mmol/L.
  - Endocrine Society 2009: "In healthy individuals, symptoms of hypoglycemia
    develop at a mean plasma glucose concentration of approximately 55 mg/dl"
    (3.0 mmol/L). Lower values "occur in healthy individuals" without
    symptoms. A value above 70 mg/dL (3.9 mmol/L) indicates symptoms are not
    due to hypoglycaemia.
  - The same guideline evaluates low glucose in people without diabetes only
    when Whipple's triad is documented, and says the glucose must be measured
    "with a reliable laboratory method, not with self-monitoring of blood
    glucose".
  - ADA 2026 Level 2 hypoglycaemia is below 3.0 mmol/L (a classification for
    people with diabetes).
- **Consequence:** "below the reference range" starts under 3.0. Readings of
  3.0 to 3.9 are within the range and get a soft note only. A fit man, or one
  eating low-carbohydrate, can read 3.5 to 3.9 fasting. Flagging those as low
  would over-alarm.
- **An urgent line is warranted, gated on symptoms.** Healthdirect: worsening
  hypoglycaemia can cause confusion, seizure or unconsciousness and needs
  emergency care. Without symptoms, a meter reading under 3.0 in a person
  without diabetes is more likely a meter or technique error, so the first
  step is to measure again.

## High readings

- No source gives a "seek care" number for people without diabetes.
- Healthdirect and Diabetes Australia both describe hyperglycaemia as above
  15 mmol/L, in the context of diabetes. Healthdirect: see a doctor
  immediately or go to an emergency department "if your high blood sugar
  doesn't go down, or you can't keep fluids down".
- Use 15.0 mmol/L (270 mg/dL), any context, as the trigger for the "well
  above" line. It is a consumer safety figure, not a diagnostic threshold.
- Do not use 7.0 fasting or 11.1 as hidden triggers. Those are the diagnostic
  thresholds. A prompt that fires on them is a screening function.

## Copy (as built; source of truth is `lib/features/health/presentation/blood_marker_copy.dart`)

The strings live only in that file. This list says what exists and why; if it
differs from the file, the file wins.

- **Range lines:** "Reference range, fasting: 3.0–5.4 mmol/L" and "Reference
  range, 2 hours or more after eating: 3.0–7.7 mmol/L". In mg/dL mode the
  bounds read "about 54–98" and "about 54–139".
- **No range:** "No reference range for this context." for before meal,
  bedtime, other and no context.
- **Source line:** "Source: RCPA Manual, Glucose reference interval (Royal
  College of Pathologists of Australasia, reviewed 2024). Defined for
  laboratory tests on blood from a vein, for adults in general."
- **Not a diagnosis:** "This shows where your reading sits against a published
  reference range. It is not a diagnosis or medical advice. Only a health
  professional can interpret your results."
- **Who it is for:** "This range is for adults without diagnosed diabetes. If
  you have diabetes or take medicine that lowers glucose, use the targets from
  your care team."
- **Position words:** "Below the reference range", "Within the reference
  range", "Above the reference range". No colour that implies good or bad.
- **Meter line:** "Finger-prick meters and laboratory tests differ. A meter
  can read up to about 15% away from a laboratory result, and readings after
  food run higher from a finger-prick. One reading is a snapshot."
- **Above the range:** "If your readings are often above the range, mention
  it to a health professional. They can arrange a laboratory test." It carries
  no reassurance.
- **Below the range** (under 3.0 mmol/L): "This reading is below the
  reference range. Wash and dry your hands and measure again. If it is still
  this low and you feel shaky, sweaty, dizzy or confused, eat or drink
  something sugary and contact a health professional today."
- **Urgent line** (shown with the line above): "If someone is very drowsy,
  cannot swallow, has a seizure or passes out, call 000."

Not implemented from the earlier draft: the before-meal range line, the
after-meal note, the "well above" line at 15.0 mmol/L, and the soft 3.0 to 3.9
note.

Notes on the copy:

- "Eat or drink something sugary" is a treatment instruction. It follows
  Healthdirect's first step for a low reading with symptoms, written for
  people with diabetes. Keeping it is an owner decision under the "no medical
  advice" rule.
- The "who it is for" line uses the word "diabetes". It is a scope statement,
  not a verdict on the reading.
- "About 15%" in the meter line rests on ISO 15197:2013 as reported by a
  secondary source.

## What must not be shown

The app must not present a diagnostic threshold as a finding about the user.
That rules out the words "diabetes", "prediabetes", "impaired fasting
glucose", "impaired glucose tolerance", "hypoglycaemia" and "hyperglycaemia"
as labels on a reading, and any band built on 5.5–6.9, 6.1–6.9, 7.0, 7.8 or
11.1. It must not show targets written for people with diabetes (Diabetes
Australia 4.0–7.0 before meals and 5.0–10.0 after; ADA 4.4–7.2 and below
10.0) as if they were general ranges. It must not use "normal", "abnormal",
"good", "bad", "healthy" or "at risk", must not average readings into a
verdict or estimate HbA1c, and must not prompt the user to change food,
training or medicine because of a reading. Regulatory caution, not legal
advice: the Therapeutic Goods (Excluded Goods) Determination 2018 excludes
consumer software for "general health or wellness" (items 14A to 14C), but
each item carves out diagnosis, screening or monitoring of a "serious disease"
or anything "in relation to" one. Item 14B covers measuring or monitoring a
physical parameter "through non-invasive means" and lists movement, sleep,
heart rate, heart rhythm, temperature, blood pressure and oxygen saturation.
Blood glucose is not listed and a finger-prick is not non-invasive. Item 14C
excludes coaching software only when it does not "provide information to the
consumer that would generally be accepted to require the interpretation of a
health professional". The Medical Devices Regulations define a serious disease
as one that "may result in death or long-term disability", "may be incurable
or require major therapeutic interventions" and "must be diagnosed
accurately". Diabetes plausibly meets that definition. A glucose logbook with
a labelled general reference range sits nearer the line than store-and-chart
does. Screening-style wording or prompts keyed to diagnostic thresholds would
move it further. The owner should take advice before any public release. A
private tester build does not change the legal test, only the exposure.

## Sources

Accessed 2026-11-16.

Opened and read:

- [RCPA Manual, Glucose](https://www.rcpa.edu.au/Manuals/RCPA-Manual/Pathology-Tests/G/Glucose),
  read from the
  [Wayback Machine copy of 4 October 2024](http://web.archive.org/web/20241004115413/https://www.rcpa.edu.au/Manuals/RCPA-Manual/Pathology-Tests/G/Glucose).
  "Last Reviewed: 02 Jan 2024". The live page returned a bot challenge (HTTP
  403) and was **not** read.
- [RACGP, Management of type 2 diabetes: A handbook for general practice — Defining and diagnosing type 2 diabetes](https://www.racgp.org.au/clinical-resources/clinical-guidelines/key-racgp-guidelines/view-all-racgp-guidelines/management-of-type-2-diabetes/defining-and-diagnosing-type-2-diabetes).
  Recommendations dated 14/11/2024. Full page text and the Figure 1 image.
- [Diabetes Australia, Blood glucose level range](https://www.diabetesaustralia.com.au/managing-diabetes/blood-glucose-range/),
  [Blood glucose monitoring](https://www.diabetesaustralia.com.au/managing-diabetes/blood-glucose-monitoring/)
  and [Hypoglycaemia and hyperglycaemia](https://www.diabetesaustralia.com.au/managing-diabetes/hypo-hyperglycaemia/).
  No review dates shown. The third page was read through a summarising fetch.
- Healthdirect [blood glucose test](https://www.healthdirect.gov.au/blood-glucose-test)
  (reviewed March 2025; summarising fetch),
  [hypoglycaemia](https://www.healthdirect.gov.au/conditions/metabolic-diseases/hypoglycaemia-low-blood-sugar)
  and [hyperglycaemia](https://www.healthdirect.gov.au/conditions/metabolic-diseases/hyperglycaemia-high-blood-sugar)
  (both reviewed November 2024).
- [WHO/IDF 2006, Definition and diagnosis of diabetes mellitus and intermediate hyperglycaemia](https://www.who.int/publications/i/item/definition-and-diagnosis-of-diabetes-mellitus-and-intermediate-hyperglycaemia).
  Full PDF text.
- [IDF 2011 Guideline for Management of PostMeal Glucose in Diabetes](https://www.idf.org/media/uploads/2023/05/attachments-51.pdf).
  PDF text; the passages on normal glucose tolerance.
- [ADA Standards of Care 2026, Section 2](https://pmc.ncbi.nlm.nih.gov/articles/PMC12690183)
  and [Section 6](https://pmc.ncbi.nlm.nih.gov/articles/PMC12690178).
  Summarising fetch, first 100k characters of each.
- [Twigg et al. 2007, Prediabetes: ADS and ADEA position statement, MJA](https://www.mja.com.au/journal/2007/186/9/prediabetes-position-statement-australian-diabetes-society-and-australian).
- [Cryer et al. 2009, Endocrine Society guideline on adult hypoglycemic disorders, JCEM](https://academic.oup.com/jcem/article/94/3/709/2596247).
  Summarising fetch, first 100k characters. Quotes are short excerpts.
- [Freckmann et al. 2015, J Diabetes Sci Technol](https://pmc.ncbi.nlm.nih.gov/articles/PMC4525642),
  for the ISO 15197:2013 criteria. Summarising fetch.
- [Alfred Health pathology handbook, Glucose](https://pathology.alfred.org.au/handbook/?testid=537).
  Summarising fetch.
- [Therapeutic Goods (Excluded Goods) Determination 2018](https://www.legislation.gov.au/F2018L01350/latest/text),
  compilation of 8 August 2024, items 14A to 14I.
- [Therapeutic Goods (Medical Devices) Regulations 2002](https://www.legislation.gov.au/F2002B00237/2024-10-14/2024-10-14/text/original/epub/OEBPS/document_1/document_1.html),
  compilation of 14 October 2024, Dictionary: "serious" and "serious
  disease".
- [TGA explanatory statement F2021L00047](https://www.legislation.gov.au/F2021L00047/asmade/2021-01-15/es/original/pdf).

Not opened (blocked, timed out or not attempted):

- RCPA Manual live page (bot challenge, HTTP 403).
- TGA guidance on excluded software (bot check, then timeout).
- ISO 15197:2013 itself (paywalled; secondary source only).
- RCPA/AACB 2008 joint position statement cited by the Alfred handbook.
- Any Australian Diabetes Society statement other than Twigg 2007. No ADS
  statement giving a range for people without diabetes was found.
- NDSS fact sheets on blood glucose monitoring and hypoglycaemia.
- The 2026 compilation of the Medical Devices Regulations.
- ADA 2026 Sections 2 and 6 beyond the first 100k characters.

## Open uncertainties

- **The RCPA interval was read from a 2024 archive copy.** Open the live page
  in a browser and confirm "Fasting: 3.0 - 5.4" and ">2 h post-prandial
  'Random': 3.0 - 7.7" before shipping.
- The RCPA interval is for venous plasma or serum. Applying it to finger-prick
  readings rests on one sentence in that entry and on WHO 2006 for the fasting
  state. No source validates it for capillary readings after food.
- The `beforeMeal` mapping is an inference by this review.
- The mg/dL figures are this review's conversions, not published values.
- The 15.0 mmol/L trigger and the 4.0 soft note come from pages written for
  people with diabetes. No source gives action thresholds for people without
  it.
- Endocrine Society and ADA text was read through a summarising fetch. Quotes
  are short and may be trimmed.
- The regulatory position is unresolved. No TGA guidance was read. Whether
  diabetes is a "serious disease" under the definition is this review's
  reading, not a ruling.
- RCPA lists no age or sex variation for the adult interval. No male-specific
  interval was looked for.
