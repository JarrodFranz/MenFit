# 010 — Food data source: Open Food Facts behind a `FoodDataProvider` port

- **Status:** Accepted
  **Amended by ADR 016 (2026-09-05):** FatSecret is now primary, OFF is the
  fallback; the port and everything else here still stands.
- **Date:** 2026-08-27 (S1-5)

## Context

The food diary shipped in S1-4 can only log foods the user types in herself. A
diary nobody can populate quickly is a diary nobody uses, so S1-5 adds an
external food database and barcode lookup. `knowledge/domain/nutrition.md`
required a dedicated research task before this landed ("Food databases are the
hard part"), and this ADR records its outcome.

Requirements that shaped the choice:

- **Iron must survive the round trip.** Iron is one of the two adequacy
  indicators this feature treats as first-class, and `NutritionFacts.ironMg`
  distinguishes unknown from zero. A source that cannot supply iron, or that
  supplies it in a way we might misread, is disqualified or must be handled
  explicitly.
- **All four platforms.** iOS, Android, Web and Windows.
- **No new runtime dependency without the `package-evaluation` workflow.**
- **Nutrition data is S2-tier** (`knowledge/engineering/security_and_privacy.md`).
  Sending it off-device is a privacy decision, not an implementation detail.

## Options considered

Open Food Facts (ODbL, crowd-sourced, barcode-native); USDA FoodData Central
(high quality, US-centric, no barcode coverage for branded EU products);
Nutritionix / FatSecret / Edamam (commercial, licence fees, per-call keys);
shipping a bundled offline food table; and no external source at all
(user-entered only, as today).

## Decision

**Open Food Facts**, reached through a `FoodDataProvider` port in
`features/nutrition/domain/` so the vendor is swappable, with a hand-written
`dio` client in `features/nutrition/data/open_food_facts_service.dart`.

Contract verified against **live responses on 2026-08-27**, not from
documentation alone:

- **Barcode lookup uses API v3** (`GET /api/v3/product/{barcode}.json`), not v2.
  OFF's own version table marks **v2 as deprecated**; most third-party
  tutorials and much of the SDK ecosystem still target it. v3's `status` is a
  *string* and a found product may return `"success"` **or**
  `"success_with_warnings"`. Not-found is signalled in the body
  (`result.id == "product_not_found"`), so callers branch on the body, never on
  the HTTP status alone.
- **Text search uses Search-a-licious** (`search.openfoodfacts.org`). The
  legacy `/cgi/search.pl` and `/api/v2/search` endpoints are the first thing
  OFF sheds under load — both were observed returning **HTTP 503 with an HTML
  body**, which is why response parsing guards `jsonDecode` behind a
  content-type check.
- A `fields=` allowlist cuts a product response from ~149 KB to under 1 KB
  (measured). **Image fields are deliberately excluded** — product images are
  CC-BY-SA, a stricter licence than the data's ODbL, and we display none.
- **No authentication.** Read access needs no key, so unlike ADR 009 there is
  no secret to manage.

### Provider data is a *candidate*, never a `Food`

`ProviderFood` carries **nullable** calories, protein, carbs and fat — not just
nullable iron. OFF omits what no contributor entered, and coalescing a missing
value to `0` would turn a gap in a crowd-sourced database into a factual claim
about a food. That is the same mistake `NutritionFacts.ironMg` already refuses
to make, applied consistently. Because `Food` requires non-null macros, a
provider result **cannot** become a catalogue row without passing through a
review screen where the user sees and fills the gaps. There is deliberately no
`ProviderFood.toFood()`.

`ServingBasis` records where the per-serving numbers came from —
`statedPerServing`, `derivedFromPer100g`, or `per100g` — and the UI shows which.
OFF's `serving_size` is unnormalised free text (a live sample read
`"3/4 cup (28 g) (28 g)"`) and `serving_quantity_unit` is sometimes flatly
wrong (`"ml"` on a dry breakfast cereal), so serving data is displayed and
offered for correction, never silently trusted.

### Barcode canonicalisation agrees with the provider's — measured

The catalogue is keyed on a barcode, so our canonical form has to agree with
the code the provider echoes back or a saved food can never be found again.
Probed live on 2026-08-27:

| Requested | Echoed `code` |
|---|---|
| `016000275270` (UPC-A, 12 digits) | `0016000275270` — **padded up to GTIN-13** |
| `16000275270` (11) | `0016000275270` |
| `20000691` (a real GTIN-8 product) | `20000691` — **left at 8, not padded** |
| `03017620422003` (14) | `3017620422003` — leading zero stripped |

Open Food Facts pads UPC-A to 13 and leaves GTIN-8 at 8 — **exactly what
`domain/barcode.dart` does**, which confirms the deliberate decision not to
pad EAN-8 (padding would be arithmetically harmless but would miss every
GTIN-8 record).

The lookup nonetheless re-checks the catalogue on the echoed code whenever it
differs from ours. Not because the two differ today, but because this
invariant would otherwise rest on a third party's normalisation rules
continuing to match ours — and a silent breakage would show up as duplicate
catalogue rows accumulating one per scan, which is a miserable thing to
diagnose from a bug report.

### No schema change

Provider foods are stored in the existing `foods` table with
`source = 'open_food_facts'`. The table was designed for this in S1-4: it
already carries a deliberately non-unique `barcode` column so a scanned product
can be matched against cached rows rather than re-fetched.

The **catalogue is the cache**: a provider result becomes a row only when the
user saves it, which is `knowledge/domain/nutrition.md`'s "local caching of
*used* foods". Search results live in memory only. A separate provider-cache
table was considered and rejected — the `source` column already identifies
provider-derived rows exactly as precisely as a separate table would, while a
second table would force either a polymorphic foreign key from
`nutrition_entries` or duplicated rows.

## Reasons

- The only realistic option with **barcode coverage of branded products outside
  the US**, which USDA FoodData Central does not have.
- Free, open, no API key, no per-call licence fee, no vendor account to manage.
- Supplies **iron** (as `iron_100g`), which is non-negotiable here.
- Its weaknesses — uneven completeness, messy serving text — are honestly
  representable rather than hidden, and the review-before-save flow turns them
  into something the user can correct instead of something the app gets wrong
  silently.

## Consequences

- **Privacy commitment.** This is the second feature to send user data
  off-device (after ADR 009's route start point) and the **first to send
  user-typed content**. Consequently:
  - Online lookup is an **explicit user action** — typing searches the local
    catalogue only. Nothing is sent search-as-you-type. This is also what keeps
    us inside OFF's documented **10 req/min** search and **15 req/min** product
    read limits; a live-search box would be blocked almost immediately. Both
    reasons are recorded in the client's dartdoc so the behaviour is not
    "improved" away later.
  - No user identifier, device id, cookie, or analytics accompanies a request.
    The only identifying header is the OFF-required **application** User-Agent.
  - No barcode and no search query may appear in an exception message, a log
    line, or an analytics event — enforced by a test, not by convention.
- **Iron arrives in GRAMS and must be multiplied by 1000.** Verified live on two
  fortified products (`iron_100g: 0.01607` → 16.07 mg/100 g). Getting this wrong
  would under-report iron by three orders of magnitude in the one feature where
  iron is a headline number. Regression-tested with those exact values.
- ~~**Text search does not work on Flutter Web.**~~ **Superseded 2026-08-27 —
  text search is now two endpoints behind one port.** `search.openfoodfacts.org`
  still returns no `Access-Control-Allow-Origin` header (re-measured), so
  browsers still cannot reach Search-a-licious. But `world.openfoodfacts.org`
  — the host the product API already uses on web, which sends `*` — still
  serves the **legacy CGI search**
  (`/cgi/search.pl?search_terms=…&search_simple=1&action=process&json=1`),
  returning JSON with a `products` array and honouring `fields=`. Native
  platforms keep Search-a-licious; web uses the CGI endpoint, chosen by a
  `useLegacySearch` flag fed `kIsWeb` from the composition surface.
  `supportsTextSearch` is consequently `true` everywhere and survives on the
  port only as a *provider* capability, not a platform one. `/api/v2/search`
  was re-tested and is not a third option: it answers HTTP 503.

  **This is a workaround, not a preference.** OFF explicitly discourages the
  CGI endpoint for new integrations and sheds it first under load — it was
  observed answering HTTP 503 with an **HTML** body, which is exactly why the
  `jsonDecode` guard exists, and that guard is load-bearing on this path. The
  10 req/min limit and the "never search-as-you-type" instruction apply here
  as before, and this is the more fragile endpoint on which to spend them.
  Upstream configures permissive CORS in `search-a-licious`'s `app/api.py` and
  something at the edge strips it, so **if the header ever appears, delete the
  fallback rather than keep it.** Nothing else changed: no user identifier,
  device id or cookie is sent, both `User-Agent` and `X-User-Agent` carry the
  app identity, and no query may reach a message, log line or analytics event
  — enforced by tests that now exercise both endpoints.
- **ODbL share-alike is a future constraint, not a current one.** The clause
  binds *public use* of a derivative database. A food diary that never leaves
  the user's device is not public use, so nothing is triggered today. It becomes
  real the day ADR 004's sync backend builds a **server-side** food catalogue
  from OFF-derived rows. The `source` column is what will make those rows
  separable when that decision arrives; any such backend must revisit this
  section before shipping.
- **Attribution is required.** ODbL obliges naming Open Food Facts with a link,
  and linking to the specific product page when reproducing information about a
  particular product. The stored barcode is enough to build
  `https://world.openfoodfacts.org/product/{barcode}`.
- **A real support contact must be set before distribution.** OFF's required
  User-Agent format is `AppName/Version (ContactEmail)`; ours is env-configured
  and empty by default. A missing contact is the difference between OFF emailing
  about unusual traffic and silently IP-banning it. Added to the pre-distribution
  checklist in `knowledge/flutter/platform_notes.md` beside the `com.example`
  rename.
- We point every environment at **production** `world.openfoodfacts.org` rather
  than the `world.openfoodfacts.net` staging host OFF suggests for testing.
  Their stated reason for staging is keeping the product database *safe* — a
  guard against test **writes**, and this client is strictly read-only. Staging
  also carries an incomplete product database, which would make dev testing
  actively misleading (every barcode "not found"). The base URL is
  env-configurable, so switching is a one-line change.

## Rejected alternatives

- **USDA FoodData Central** — excellent data quality, but US-centric with no
  barcode coverage of the branded products this feature is built around. Worth
  revisiting later as a *second* provider behind the same port for generic
  wholefoods, where its quality beats OFF's.
- **Nutritionix / FatSecret / Edamam** — better-curated, but each needs a
  commercial licence, an account, and a per-call API key. That reintroduces
  ADR 006's secret-management burden for a feature that works without it, and
  couples a core flow to a billing relationship.
- **The official `openfoodfacts` Dart SDK** — rejected under step 1 of the
  `package-evaluation` workflow ("can existing dependencies or ~100 lines of
  owned code do this?"). We already have `dio` and a close precedent in
  `OrsRouteService`; much of the SDK ecosystem still targets the deprecated v2
  and the dead CGI search; and a hand-written client keeps exact control over
  the User-Agent, the `fields=` allowlist, and the exception-message privacy
  rules above. Every new dependency also has to clear the analyzer-9 window
  (`knowledge/troubleshooting/dependency_resolution.md`).
- **A bundled offline food table** — no barcode story, immediately stale, and
  shipping an OFF extract inside the app *is* distribution, which would trigger
  ODbL share-alike on day one.
- **User-entered foods only (status quo)** — rejected as a product decision:
  it is the single biggest drag on diary adoption.

## Amendment 2026-09-03

Provenance is now decided by `FoodFormSeed.source`, not by "was there a seed
at all" — the distinction matters because a seed can exist without any of its
data having come from OFF. Concretely, `forUnknownBarcode` (OFF had no
product for the scanned code and the user typed every field herself) is now
tagged `FoodSource.custom`; it had been wrongly tagged
`FoodSource.openFoodFacts`, understating how much of a saved food's data
actually came from the provider. Fixed in the 2026-09-03 food-logging round —
see
`knowledge/domain/nutrition.md`.

## Amendment 2026-09-03 (2) — every request carries a region and a language

**Symptom (owner's report, release build, Australia):** searching "zarrafa
cheese" returned Bulgarian products — Cyrillic names, Cyrillic pack sizes
("500 г"). Open Food Facts is a **global** database with no default
locality, and this client was sending no country filter and a hard-coded
`lc=en`/`langs=en`.

**Decision.** Text search is now scoped by a `FoodSearchScope`
(`features/nutrition/domain/food_search_region.dart`) — a `FoodSearchRegion`
plus a language — resolved on the composition surface and passed down through
`FoodDataProvider`. What goes on the wire, exactly:

| | Search-a-licious (native) | legacy CGI (web) | product v3 (barcode) |
|---|---|---|---|
| country | appended to `q` as `countries_tags:"en:australia"` — the endpoint has no country parameter, its `q` is Lucene | `tagtype_0=countries`, `tag_contains_0=contains`, `tag_0=australia` (**no** `en:` prefix) | **none** |
| language | `lc=<lc>`, `langs=<lc>` | `lc=<lc>` (no `langs` on this endpoint) | — |
| fields | `product_name_<lc>` added to the allowlist | same | same |

**Probed live on 2026-09-03** (Search-a-licious, `q=cheese countries_tags:"en:australia"`,
`langs=en`): 1,367 hits, every sampled record carrying `en:australia` in
`countries_tags` (Devondale Colby, Halloumi, Pantalica mascarpone …). The
control without the term returned the owner's bug verbatim — the first page
was Bulgarian white brined cheeses with Cyrillic names — so the `q`-embedded
filter is measured, not inferred. The legacy CGI form is the documented one
and was not probed.

`FoodSearchRegion.anywhere` sends no country filter on either path and still
sends the language — the pre-amendment behaviour, kept as a **choice** rather
than as a default nobody picked.

**Barcode lookup is unchanged apart from the language.** A barcode is a global
identifier; a country filter there could only turn a correct answer into "not
found". The language is still sent, because the *name shown* now prefers
`product_name_<lc>` over `product_name` over `generic_name`.

**No script or language heuristic over the results.** Locality is decided by
the request. Dropping a result because its name is not in the user's alphabet
would hide products she can actually buy (a French brand on an Australian
shelf), and would have spent the request anyway. A record whose only name is
in another language is shown with that name.

**Default = the device locale's country**, overridable in Settings ("Food
database region", `Data & Privacy`, stored in `shared_preferences` under
`nutrition_food_search_region`; absent means "not chosen", so the default
keeps following the device until she picks one — including a deliberate pick
of "Anywhere", which then sticks). The default is the actual fix: nobody
would go looking for a region control they did not know existed, and "why is
this in Cyrillic?" does not point at one.

**Countries offered:** Australia, New Zealand, United Kingdom, United States,
Canada, Ireland, plus Anywhere. Deliberately short — markets where OFF's
branded coverage is worth searching *and* where this app's single English
locale matches the packet. A 200-country dropdown of markets with a dozen
products each would present an empty result as the user's mistake. Adding a
country is a product decision, not a data-entry one.

**Privacy.** The scope is on the wire, so the online-lookup notice now lists
it ("Your food database region and language setting goes too…"). It is not
personal data — a whole country and a language shared by hundreds of millions
identify nobody — but that dialog's promise is to name *everything* that goes
out, and an unmentioned parameter would make the rest of it less believable.
Still no user identifier, device id, cookie or analytics.

**Related parser trap, confirmed rather than changed.**
`_extractGramsOrMl`'s unit alternation is Latin-only, so "500 г" yields **no**
serving weight — the text is displayed verbatim (it is the packet's) and the
grams stay unknown. That is correct and is now regression-tested: reading the
500 would be a plausible-looking wrong number that every macro then gets
scaled by.
