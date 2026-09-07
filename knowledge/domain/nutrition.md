# Nutrition Domain Notes

*Initial bootstrap notes, 2026-08-25. Energy-estimation stance added with S1-4, 2026-08-28.*

## Evidence reviews

- **[Energy-needs estimation (BMR/TDEE)](../research/nutrition_energy_estimates.md)** — why Mifflin-St Jeor, the female-coefficient assumption and its limits, the documented error margins, and the BMR-floor decision. Required by `womens_health.md` rule 2 and **must be read before changing anything in `features/nutrition/domain/energy_estimate.dart` or `calorie_target.dart`.** No nutrition claim is tied to cycle phase; that needs its own review.

- **[Activity energy expenditure ("calories burnt")](../research/energy_expenditure_estimates.md)**
  — required by `womens_health.md` rule 2 before any such figure ships. Read it
  before touching activity-energy code. Two conclusions bind this domain
  directly: **there must be no code path from an activity energy estimate to
  `calorie_target.dart`, the diary, or any daily total** (our TDEE already
  contains an activity multiplier, so adding workout calories double-counts
  almost the whole workout, not merely its resting share), and the estimate is
  **its own opt-in, off by default**, additionally suppressed by
  `hideCalorieNumbers` — it qualifies for neither documented exception, being a
  derived output rather than an input surface.

## Core concepts

- **Food:** nutritional definition per serving/100g (calories, protein, carbs, fat; micronutrients later — iron is the first micronutrient worth adding for this audience).
- **NutritionEntry:** a logged quantity of a food at a time, assigned to a **Meal** (breakfast/lunch/dinner/snack — user-configurable later).
- **Goals:** daily calorie and macro targets. Later: cycle-phase-aware hints (evidence-gated).
- **Body metrics:** weight over time first; measurements later. Trend-smoothed weight (rolling average) matters more than daily points.

## Food data sourcing

- Food databases are the hard part: options include Open Food Facts (open, barcode-friendly, variable quality), USDA FoodData Central (high quality, US-centric), commercial APIs (Nutritionix, FatSecret — licensing costs). **Decided at S1-5: Open Food Facts behind a `FoodDataProvider` port — see [ADR 010](../decisions/010_food_data_source.md)**, which supersedes the "dedicated research task" note this bullet used to carry. The port keeps sourcing vendor-agnostic; the catalogue *is* the cache (a provider result becomes a row only when the user saves it). **Amended 2026-09-05: FatSecret is now the primary catalogue, with Open Food Facts as the fallback — see [ADR 016](../decisions/016_fatsecret_primary_off_fallback.md).** The port and the caching model above are unchanged; a saved food's `source` now records whichever catalogue actually answered a given lookup, not a single build-wide provider.
- Barcode scanning is mobile-only (camera); keep it an enhancement, not the core path. **Manual barcode entry is not a fallback** — it is the only path on Windows and Web, and the permission-denied/unreadable-label path everywhere, so it is offered on every platform and never gated on `barcodeScanningSupported`.

### What shipped at S1-5 (2026-08-27), and the rules behind it

- **Lookup order is local-first, always.** A scanned or typed barcode is validated and canonicalised (`domain/barcode.dart`), then looked up in the user's own catalogue (`NutritionRepository.getFoodByBarcode`). A hit goes straight to the log dialog and **makes zero network requests**. Only a miss reaches the provider. Two independent reasons, both load-bearing: barcodes get scanned in supermarket aisles where signal is worst, and the app must not tell a third party about a food it already knows. Where several live rows share a barcode (the column is deliberately non-unique), the most recently updated one wins.
- **Online lookup is an explicit action, never search-as-you-type.** Typing searches the local catalogue only; sending words to the provider takes a button press or a field submit. **Two independent reasons, either sufficient on its own:** (1) privacy — this is the first feature to send user-*typed* content off-device, and ADR 010 makes that an act rather than a side-effect of typing; (2) rate limits — Open Food Facts documents 10 search requests/minute per IP, which for a client-side app is per end-user, so a live-search box would be blocked within seconds. Both reasons are restated in code comments (`presentation/online_food_search_controller.dart`, `data/open_food_facts_service.dart`) so the behaviour is not "improved" away. Paging is one page per explicit request, ending when a page returns fewer hits than the page size; the provider's total count is a capped estimate and is **never rendered**.
- **A first-run consent gate, not a notice.** Before the *first* outbound lookup of any kind (text search or barcode fetch), a dialog states what is sent (the words, or the barcode), to whom (the named provider, with its address), what is not sent (nothing identifying — no name, no account, nothing else from the diary), and that a result is only kept if she saves it. **Backing out actually aborts the lookup** — a notice you can only agree to is a delay, not consent. "Already seen" persists in `shared_preferences` (a trivial device preference), and is recorded only after she proceeds.
- **A search hit is never enough to build a food.** Picking a text-search result triggers a *mandatory* second call, `findByBarcode(summary.barcode)`, before the review screen. Not an optimisation: the provider's search index exposes seven nutriments and **iron is not among them**, so a food built from a summary would be silently missing the one nutrient this app treats as first-class. Search-hit figures are also per 100 g, and are labelled as such wherever they render.
- **Review before save.** Provider data is a candidate the user checks, never something the app accepts on her behalf. A number the provider did not state seeds a **blank** field, never `0` — existing validation then requires it, which is the intended outcome. The review screen surfaces `ServingBasis` (stated per serving / derived from per-100 g / per 100 g), says so when the record carries no nutrition data at all, and gives a quiet, non-judgemental caution when the record looks thin — a sparse record means nobody has filled the product in, not that the food lacks anything. Saved foods carry `source: openFoodFacts` (even after the user edits every number — provenance records where data *came from*) and the provider's **echoed** barcode.
- **Attribution is a licence obligation** (ODbL), not decoration: the online results region and the review screen both name the source and carry its address. Rendered as copyable `SelectableText` because `url_launcher` is not a dependency; making it tappable needs the `package-evaluation` workflow.
- **A search is scoped to a country and a language (2026-09-03 fix).** Open Food Facts is global and unlocalised by default, so an unfiltered search from Australia came back full of Bulgarian products with Cyrillic names and Cyrillic pack sizes ("500 г"). Text search now sends the user's `FoodSearchRegion` as a country filter (`countries_tags:"en:australia"` appended to Search-a-licious' Lucene `q`; the `tagtype_0/tag_contains_0/tag_0` triple on the legacy CGI path) and her language as `lc`/`langs` plus a `product_name_<lc>` field request, with the mapper preferring that field over the plain `product_name`. The default is the **device locale's country**, overridable in Settings → Data & Privacy ("Food database region": Australia, New Zealand, United Kingdom, United States, Canada, Ireland, or Anywhere; stored in `shared_preferences`, absent meaning "not chosen" so the default keeps following the device). **Barcode lookup is unchanged** — a barcode is global, and a country filter there could only turn a correct answer into "not found" — apart from preferring the localised name. There is deliberately **no script or language heuristic over the results**: locality is decided by the request, and dropping a result because its name is not in her alphabet would hide products she can actually buy. Free-text `serving_size`/`quantity` is displayed verbatim but never parsed when its unit is not one we recognise, so "500 г" yields an *unknown* weight rather than 500 g. Details, wire formats and the privacy note in [ADR 010](../decisions/010_food_data_source.md)'s second 2026-09-03 amendment.
- **Scope of the hide-calories mode, extended.** The **review/new-food form** joins the goals screen as a documented exception: its calorie *field* stays visible under the preference, for the same reason — you cannot define a food without entering its energy, and blanking it would leave a user unable to finish what she opened the screen for. It is an input, not a total. The **online results list is inside** the preference's scope, exactly as the local picker list already was.

## Shipped after S1-5

- **Searching the food database works on every platform, including web.** The
  earlier restriction — browser users could only reach the database by barcode
  — is gone. Web reaches it by a different endpoint than phones and desktop do
  (see ADR 010), but that is a transport detail inside the data layer: the UI
  shows no banner, no caveat and no hint about which route served a result,
  because the user has no decision to make about it. Everything else is
  unchanged — typing still searches only her own foods, nothing leaves the
  device until she presses Search, results are still per-100 g summaries that
  must pass through the review screen, and the first-run notice still gates
  every outbound request. Copy telling web users to use a barcode instead has
  been removed from the picker *and* from the error-message table.

- **Macro targets in percentages (schema v12).** The three macro targets can be
  stated in grams or as percentages of the day's energy;
  `nutrition_goals.macro_target_mode` (default `'grams'`) names which stored
  set is authoritative. Both sets persist side by side and neither is written
  from the other, so switching representation never destroys what was typed in
  the mode she left. Percent-mode grams are **derived on demand**
  (`domain/macro_targets.dart`), never stored, so a changed calorie target
  moves them instead of leaving a stale snapshot. Atwater factors (protein 4,
  carbohydrate 4, fat 9 kcal/g) are used purely as a unit conversion:
  **there is no default or suggested split**, no ratio is described as
  balanced or recommended, and the fields start blank (`womens_health.md`
  rule 1). The basis is her own calorie target when set, otherwise the
  resolved target with the BMR floor already applied; with neither, there is
  no basis at all and that is a typed outcome the screen explains rather than
  a set of zero-gram targets. Validation states arithmetic and never judges:
  "These come to 96% — they need to add up to 100% between them." That is the
  one message in `nutrition_validation.dart` permitted to quote a number the
  user typed — a split is a shape she chose, not a logged intake — and it
  stays UI-only.

  **Every surface showing a macro target must go through
  `NutritionGoals.macroTargetGramsFor(basisKcal)`**, never
  `proteinTargetGrams` and friends directly: those are populated only in grams
  mode, and reading them directly made percent-mode targets vanish from the
  diary entirely. That was a real defect, caught in review and now regression-
  tested in `nutrition_day_screen_test.dart`.

  **Hide-calories scope, extended again:** derived-grams lines are always
  shown — grams are not calories, and they are the figures the diary measures
  against — but the calorie *basis* behind them is inside the preference's
  scope, so with it on the goals screen names the basis in words ("Shares of
  your daily calorie target.") and prints no kcal figure in the macro section.
  The goals screen's documented exception covers the calorie target *field* as
  an input; it is not licence to print an energy figure somewhere new.

- **Log by weight (schema v13).** An entry now records *how the quantity was
  expressed* as well as what it means: `quantity_amount` (the number typed),
  `quantity_unit` (a `QuantityUnit` key — servings, g, oz, kg, lb), and
  `serving_grams`, a **snapshot** of the food's grams-per-serving at log time.
  `quantity_servings` remains the canonical multiplier and the only quantity
  `NutritionEntry.facts` and every total read, so 2 servings and 60 g of a
  30 g-serving food contribute identical nutrition — asserted directly,
  because that is the whole correctness claim.

  `serving_grams` is snapshotted for the same reason the nutrition numbers
  are: correcting a food's serving weight next month must not retroactively
  re-interpret what "47 g" meant in an entry logged today. Existing rows were
  explicitly backfilled (`quantity_amount = quantity_servings`) rather than
  left on a column default, because before v13 servings were the only thing
  loggable, so the amount typed *was* the serving count. Their `serving_grams`
  stays null, which the conversion core reads as "weight units unavailable for
  this entry" rather than guessing one.

  **No millilitres and no milligrams** (`domain/quantity_unit.dart`). The app
  stores no notion of whether a food is liquid and a millilitre is not a mass
  — 100 ml of oil is ~92 g, of honey ~140 g — so a volume unit that silently
  behaved as a mass would produce numbers that look right and are wrong.
  Supporting ml properly means storing a serving *volume* beside the serving
  weight and offering it only for foods that have one (Open Food Facts
  supplies `serving_quantity_unit: "ml"` for drinks). That is a deliberate
  future step, not an oversight.

  Where a food has no recorded gram weight the picker holds only "serving",
  and the dialog says once — without correcting the user — that adding a gram
  weight would allow logging by weight. Validation bounds stay on the
  resulting serving count so one set of limits covers every unit; the typed
  amount is checked only for being positive and finite. Two quantity messages
  were reworded unit-neutrally: copy that says "servings" to someone who just
  typed grams reads as though the app misunderstood her.

### Food logging round (2026-09-03)

- **Barcode entry joins the food form.** The food form gained a Barcode
  section: a digits field validated by `validateBarcode` (digits are never
  interpolated into a validation message — the same discipline ADR 010 holds
  the OFF client's exception messages to), a Scan button shown only where
  `barcodeScanningSupported` (reuses `BarcodeScanScreen`), and manual entry
  available on every platform regardless of scan support. Saving over a
  barcode that another live food already carries prompts a three-way choice —
  "Use existing `<name>`", "Save as a new food anyway", "Keep editing" — with
  the food's own row exempted by id, so re-saving an edited food never trips
  its own duplicate check.

- **Provenance fix.** `Food.source` is now decided by `FoodFormSeed.source`,
  not by "was there a seed at all". Concretely, `forUnknownBarcode` — the path
  where OFF had no product for a scanned code and the user typed every field
  herself — is now tagged `FoodSource.custom`. It had been wrongly tagged
  `FoodSource.openFoodFacts`, which is exactly the provenance guarantee
  ADR 010 exists to protect: `source` records where the data actually came
  from, and none of it came from OFF on that path. See ADR 010's
  2026-09-03 amendment.

- **"No millilitres and no milligrams" is now mechanically enforced.** The
  rule above has stood since schema v13, but commit e325bc0 had quietly
  reintroduced ml and fl oz as 1:1 / 29.57 g masses in code — the documented
  rule and the shipped behaviour disagreed. `QuantityUnit.offerable` now
  excludes `millilitre` and `fluidOunce`, `availableFor()` never offers them,
  and the food form's basis picker lost `ml`. The enum values themselves are
  **kept** — deleting them would break deserialisation and display of legacy
  entries already logged in those units; they survive for display only, never
  for new offers. The non-obvious trap: withdrawing a unit from the *offered*
  set must not make an *existing* entry uneditable, so
  `availableFor(servingGrams, including: unit)` exists specifically to keep a
  withdrawn unit selectable when it is the unit an entry was already logged
  in — forget the `including:` argument and a legacy ml/fl-oz entry becomes
  impossible to edit without silently changing its unit. A proper "serving
  volume beside serving weight" model — the fix that would let ml be offered
  correctly instead of withdrawn — is still not built (`product/deferred.md`).

- **Edit-in-place.** `FoodFormSeed.existingFoodId` plus
  `FoodFormSeed.forEditing(Food)` fix a duplicate-row defect: every
  "Edit food details & macros" save had been creating a new catalogue row,
  because the seed carried no id to upsert against. `saveFood` now upserts by
  id, preserves `createdAt`, and clears `deletedAt`.

- **Picker: recents, copy-from-yesterday, quick-add, manage foods.**
  `getRecentFoods`/`watchRecentFoods`/`getFrequentFoods` inner-join foods to
  `nutrition_entries` grouped by `foods.id` (most-recent-use, or a count
  within a day window for "frequent"), excluding soft-deleted foods and
  quick-add entries from both. `recentFoodsProvider` is a Drift **stream**,
  deliberately not a one-shot `Future` — see the `activeStrengthCycle`
  Corrections entry (2026-09-02) in `handoff/HANDOFF.md` for what a one-shot
  provider costs on a surface like this. The Recent section (max 10) sits
  above "Your foods" while the search box is empty. `getFrequentFoods` has no
  UI caller yet (`product/deferred.md`).
  Copying yesterday's meal is offered only when today's meal is empty *and*
  yesterday has entries for it, never on a future day; it copies the logged
  snapshots verbatim (new ids, `createdAt` staggered 1 ms apart to preserve
  order) rather than re-reading the food, so quick-add entries and entries
  whose food has since been deleted still copy correctly. The confirmation
  reads "Copied N items" with no calorie figure — an ED-safe choice,
  consistent with the hide-calories scope above.
  Quick Add's "Save to my foods" switch (off by default) creates a custom
  `Food` ('1 serving', `servingGrams` null) and links the entry to it.
  Manage foods lives at `/nutrition/foods`
  (`NutritionManageFoodsRouteData`, a child route of the nutrition branch
  like goals), reached from the food picker's app-bar overflow menu; it
  lists and searches by name-or-brand, shows a source badge (Yours / Food
  database / Open Food Facts), and soft-deletes behind a confirmation dialog
  offered both by long-press and a visible icon (mouse and screen-reader
  parity). `hideCalorieNumbers` is honoured throughout. There is no entry
  point from the goals screen yet (`product/deferred.md`). `MealSection`'s
  action row is now a `Wrap` — three buttons no longer force overflow at
  360dp.

- **Data loss found and fixed the same day: the 13 optional nutrients now
  reach the database (schema v21, 2026-09-03).** The `foods` table had no
  columns for saturated, trans, mono- or poly-unsaturated fat, fibre,
  sugars, added sugars, sodium, potassium, cholesterol, calcium, vitamin D
  or vitamin C. The form collected and validated all thirteen and
  `Food.perServing` carried them in memory, but the repository discarded
  them on save with nothing surfacing it to the user. v21 adds all thirteen
  to **both** `foods` and `nutrition_entries` — the entry table snapshots
  per-serving facts at log time, so persisting them on foods alone would
  have moved the loss one step later. `null` still means unknown, never
  zero, and no existing row is backfilled: nobody recorded the fibre in a
  food logged last month, and `0` would be a claim about it. The day view
  deliberately still shows only kcal/macros/iron — a "more nutrients"
  surface is a separate product decision (`product/deferred.md`); this
  change was about not losing the data. Migration detail:
  `knowledge/troubleshooting/database_migrations.md` (the ADD COLUMN
  idempotency trap and the PRAGMA-guarded helper v21 introduced).

### Photographing a nutrition label into the food form (2026-09-03)

ADR 012 has the decision and the platform detail; this is the *domain*
half — what a photographed panel is allowed to do to a food definition.

- **A scan fills blank fields and never replaces one.** Where the panel and
  a number the user already typed disagree, hers stands and the difference
  is stated under the review banner ("Kept your value for calories (label
  read 198)."). Same for the amount and unit: the scanned basis is applied
  only while the amount, unit, serving weight and portion description are
  all still untouched defaults.
- **Unknown stays blank, never `0`.** `ParsedColumn.toNutritionFacts()`
  cannot express an unread core macro — `NutritionFacts` requires energy
  and the three macros, so it emits `0` — so the form is prefilled from the
  **nullable `ParsedValue` fields** and never from that method. This is the
  same rule the Open Food Facts review screen holds; the difference is that
  here the type system will happily hand you a zero if you ask the
  convenient way.
- **Column choice:** per-serving when the panel also stated a serving
  weight (the only case where both the numbers and what they are per can be
  recorded), otherwise per-100 as a "Per Reference" 100 g basis.
- **Per 100 mL is not per 100 g.** A drink panel prefills the values into
  per-reference mode with a **blank** amount and blocks the save until the
  user supplies a weight, because a blank amount is otherwise read as 100
  and would file per-100 mL figures as per-100 g. This is the same rule
  that withdrew `ml` from the quantity picker: 100 ml of oil is ~92 g, of
  honey ~140 g. Copy: "This label is per 100 mL. MenFit records weight —
  enter the grams for 100 mL before saving." The guard is **sticky and
  independent of who set the amount**: a second scan does not clear it, and
  a weight typed *before* the scan does not count as an answer to it (she
  was defining a food by weight and then photographed a drink; the two
  numbers have nothing to do with each other). Touching the amount field
  after the scan is the confirmation.
- **An unrecognised standard is not an unreadable photo.** The scan is
  refused only when nothing at all was read; a panel whose standard could
  not be named still fills the fields and carries `warnUnknownFormat`. Two
  supporting parser rules: "per serving" and "calories" are format cues in
  their own right (the heading row is the panel once the title is cropped
  off), and an energy figure with **no unit** on a row named *Calories* is
  kcal regardless of the detected format — read as kilojoules it reaches
  the form as a quarter of the truth.
- **Confidence 0.6** marks a field "check this" (icon plus the semantics
  label "low confidence, please check"). A UI threshold, not a truth
  threshold — everything scanned is reviewed regardless. Only fields taken
  from the panel are ever marked; a number she typed never is.
- **ED-safe copy applies unchanged.** No message blames the photo, the
  label or the user, and none quotes a value except the one deliberate
  exception above, which is UI-only and never logged.
- A photographed packet saves as `FoodSource.custom`. Her camera supplied
  the data, not a database (ADR 010).

**Parser traps worth not rediscovering** (each is a comment in the code;
repeated here so they are findable from the domain notes):

- *Two normalisations, in opposite directions.* Nutrient names are all
  letters, so `normaliseLabelText` pushes stray digits back to letters
  (`S0dium` → `sodium`) and then drops digits entirely. Column headings
  legitimately mix letters and digits, so neither direction is safe:
  `normaliseHeaderText` folds each ambiguous glyph onto one representative
  and **must be applied to both sides of a comparison**. Running the label
  normaliser over a heading turns `per 100 g` into `perg`.
- *A token is a value only if its leading run parses as a number with at
  least one real digit and everything after it is a unit we recognise.*
  Without the trailing-unit test, `S0dium` reads as the number 50 (its
  leading run `S0` repairs to `50`) — a
  plausible-looking wrong answer, which is the only kind that matters here.
  Relatedly, a confusable letter at the **end** of an integer run is far
  more often a unit than a digit (`2L` is two litres, not twenty-one), so
  the letter-to-digit repair is allowed only *after* a decimal point
  (`34.O` → 34.0).
- *Heading scan: shortest spans first, across the whole row.* Sweeping
  spans as the outer loop rather than positions is the load-bearing part:
  `Typical values per 100g` joined into one string *contains* `per100g`, so
  a position-first scan claims all four elements at index 0 and anchors the
  column over the caption on the left instead of over the numbers on the
  right. Span 1 first finds `100g` on its own element and anchors there.

### Volume-based nutrition logging (schema v25, 2026-09-07, Task 3.2)

- **Volume model beside mass.** `foods` and `nutrition_entries` tables carry
  an optional `serving_volume_ml` (REAL) column alongside `serving_grams`.
  This allows three distinct valid states:
  1. **Pure mass food** (`servingGrams > 0`, `servingVolumeMl == null`): offers
     mass units (`serving`, `g`, `oz`, `kg`, `lb`).
  2. **Pure volume food** (`servingVolumeMl > 0`, `servingGrams == null`):
     drinks, oils, broths without known gram weight. Offers volume units
     (`serving`, `ml`, `fl oz`).
  3. **Dual-unit food** (`servingGrams > 0` and `servingVolumeMl > 0`): both mass
     and volume specified, computing `liquidDensityGramsPerMl` ($g/ml$) and
     `energyDensityKcalPer100Ml`. Offers all mass and volume units.
- **`QuantityUnit` architecture:**
  - `isVolume` (`mlPerUnit != null`) and `isMass` (`gramsPerUnit != null`).
  - `offerableMass` (`serving`, `g`, `oz`, `kg`, `lb`) and `offerableVolume`
    (`serving`, `ml`, `fl oz`). `offerable` aliases `offerableMass`.
  - `availableFor(servingGrams, servingVolumeMl: ...)` returns the appropriate
    unit set based on the food's recorded measurements.
  - Conversions via `servingsFor` and `amountFor` handle volume units against
    `servingVolumeMl`.
- **Backward compatibility guarantee:**
  - Pre-v25 entries logged prior to volume columns convert via legacy 1:1 mass
    fallback against `servingGrams` snapshot.
  - When neither volume nor weight is known, `servingsFor` returns
    `NoServingVolume` rather than inventing data.
- **Catalogue & Ingestion:**
  - Open Food Facts and FatSecret mappers extract `ml`/`cl`/`l` from portion
    strings into `servingVolumeMl` and classify liquid items as
    `ServingBasis.per100ml`.
  - `serving_quantity_unit` in Open Food Facts is treated as untrusted (often
    falsely set to "ml" on solid cereals) and is not allowed to override
    textual `serving_size` measurements.


## Women-specific considerations

- Calorie guidance must be handled responsibly: avoid aggressive-deficit defaults; consider eating-disorder-safe design (no shaming, ability to hide calorie numbers, focus on adequacy e.g. protein/iron). This is a product-differentiating safety area — treat with the same seriousness as privacy.
- **Decided and implemented at S1-4 (2026-08-28):** calories and macros are first-class (MyFitnessPal parity) *with guardrails* — no "over budget" or shaming semantics anywhere; a user-controlled **hide calorie numbers** preference (`nutrition_goals.hide_calorie_numbers`, display-only — calories stay recorded); protein and iron treated as first-class adequacy indicators, with unknown iron stored as `null` rather than `0` so a total is never presented as complete when it isn't; no aggressive-deficit defaults (weight goal defaults to "maintain", requested deficit defaults to 0). Deficits are **allowed but floored at the user's estimated BMR**, with the floor explained rather than silently applied — see the evidence review above. Validation copy in `nutrition_validation.dart` carries an explicit no-shaming/no-moralising rule as a code comment.
- **UI shipped at S1-4 (2026-08-28), scope of the hide-calories mode:** the preference blanks calorie figures across the **diary** (day totals, meal subtotals, entry rows, the food picker — local *and* online results, added S1-5 — and the log dialog's preview) and nothing else. Two documented exceptions, both **input** surfaces rather than totals: the **goals screen**, which keeps the calorie target field and the energy estimate because that is where the number is entered and where the switch itself lives; and the **new-food/review form** (S1-5), because a food cannot be defined without its energy. Blanking either would leave a user unable to finish what she came for. Any new surface that renders a calorie figure must honour the preference; the day view has a test asserting no calorie text is findable at all in that mode.
- No user-set **iron target** exists, deliberately: a personal iron number is a clinical figure (`womens_health.md` rule 1). Iron is surfaced as a logged total only.
- Energy needs vary across the cycle; any recommendation is evidence-gated and disclaimed.
- Pregnancy/breastfeeding nutrition is out of scope until medical review exists.
