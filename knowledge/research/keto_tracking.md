# Keto tracking: evidence and data-convention review

Reviewed 2026-11-16 for the proposed Keto tab. Status: informational
tracking design; no clinical recommendation or automatic net-carb calculation
included. Owner approved logging scope through the separate-tab and measurement-selector directions.

Owner subsequently selected a separate Keto tab with macros and manual ketone
readings, then requested a selection of measurement types. Blood, urine and
breath are supported as distinct methods; the earlier macro-only scope is superseded. The carbohydrate limitations below still apply.

## What the existing data supports

MenFit stores carbohydrate and nullable dietary fibre in food definitions and
entry snapshots. Neither MenFit nor the inspected Frelia implementation records
whether carbohydrate includes fibre. Provider region settings do not establish
the convention of every saved food or historical snapshot. Optional nutrient
totals can be partial; an unknown fibre value must not be treated as zero.
The inspected Open Food Facts mappers in both apps do not populate fibre;
FatSecret does. A saved field's existence does not mean the source supplied it.

The existing data can support a view of **recorded carbs**, protein and fat,
with the user's own optional targets. It cannot safely support a uniform
`carbohydrate - fibre` conversion or a claim that the user is in ketosis.

## Label conventions

FSANZ's nutrition-panel calculator documents available carbohydrate by
difference with dietary fibre already subtracted. Subtracting it again would
undercount that value. FDA documentation describes US total carbohydrate as
including dietary fibre. This supports retaining the source value and making
the missing convention explicit, rather than guessing from the app's region.

Sources checked:

- [FSANZ: nutrients in the nutrition panel calculator](https://www.foodstandards.gov.au/business/labelling/nutrition-panel-calculator/nutrients-in-the-NPC).
  Search-index text supplied the formula; direct fetch returned HTTP 403.
- [Australia New Zealand Food Standards Code, Schedule 11](https://www.legislation.gov.au/F2015L00481/2024-10-29/2024-10-29/text/original/epub/OEBPS/document_1/document_1.html),
  S11—3, available carbohydrate calculation. Historical compilation corroborates
  the convention; this review does not claim legal compliance.
- [FDA: Total Carbohydrate](https://www.accessdata.fda.gov/scripts/InteractiveNutritionFactsLabel/assets/InteractiveNFL_TotalCarbohydrate_October2021.pdf).

## Product boundaries

Healthdirect describes limitations and risks of ketogenic diets, including
uncertainty about long-term weight-loss benefits and medication-related risks.
Tracking a user-chosen diet is not evidence that prescribing it is appropriate.
The feature will not set a clinical carb target, predict ketosis, recommend
medication changes or promise weight loss. A concise informational disclaimer
fits the existing men's-health policy; no new symptom or medical data collection
is justified by the requested tracking view.

Source: [Healthdirect: ketogenic diet](https://www.healthdirect.gov.au/healthy-living/food-and-nutrition/ketogenic-diet),
page reviewed August 2025, accessed 2026-11-16.

## Requirements before a future net-carb calculation

Persist an explicit carbohydrate basis on each food and logged snapshot;
preserve legacy rows as unknown; capture/review basis in manual, provider and
OCR paths; preserve unknown fibre; document sugar-alcohol policy separately;
test mixed conventions, partial data, editing, copying, migration, export,
import and deletion. Do not retrofit old diary values by assuming their label
convention. New formulae need another evidence review and product sign-off.

## Manual ketone measurements

Blood and urine ketone tests are distinct measurement methods; urine results
may depend on the strip brand and its scale. Do not mix measurement types,
convert between them, or assign one unit to an unspecified reading. The owner
requested a selector covering all three methods.

The feature records measurements without physiological interpretation,
threshold bands, clinical alerts or a claim of confirmed/safe ketosis. It
should say plainly that readings are not interpreted, with meter instructions
and clinician advice remaining the source for interpretation. No numeric
clinical thresholds are prescribed by this review. Store readings as S3 data
with export opt-in, hard deletion, import validation and no health-value logs.

Sources checked 2026-11-16:

- [MedlinePlus: ketones blood test](https://medlineplus.gov/ency/article/003498.htm).
- [American Diabetes Association: using a ketone management plan](https://professional.diabetes.org/sites/dpro/files/2026-09/how-to-use-the-sample-ketone-management-plan-hcp.pdf),
  which distinguishes blood/urine methods and notes strip-brand variation.

These sources support distinguishing measurement methods; they do not establish
an interchangeable blood/urine/breath scale or endorse the planned app as a
medical monitoring system.


### Selected-method storage policy (2026-11-16)

Blood results carry mmol/L; breath results carry ppm. Both allow a non-negative
finite number or the literal meter result LO/HI. These strings are kept without
substituting a number, and no device range or clinical threshold is inferred.
Urine results are entered as the short category/value printed on the strip
scale, including its unit when numeric; brand scales are not normalized.

Manufacturer documentation confirms concrete formats only:
[Keto-Mojo LO/HI results](https://keto-mojo.com/help-docs/lo-and-hi-ketone-meter-readings/)
and [Ketonix PPM display](https://www.ketonix.com/app/measure/).
These examples are not recommendations to use either device and do not make
measurements from different methods equivalent. Reading type is stored on each
row; switching type clears an unsaved result to prevent accidental relabelling.
