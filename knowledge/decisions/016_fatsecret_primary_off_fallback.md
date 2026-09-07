# 016 — FatSecret primary, Open Food Facts fallback

- **Status:** Accepted
- **Date:** 2026-09-05

## Context

ADR 010 chose Open Food Facts (OFF) as the sole food catalogue, rejecting
FatSecret at the time on licensing cost — a commercial API meant an account,
a per-call key, and ADR 006's secret-management burden for a feature that
worked without it.

Since then, two things changed:

- FatSecret's food catalogue landed anyway (2026-09-05 session), behind the
  same `FoodDataProvider` port ADR 010 specified, using OAuth 2.0 client
  credentials against the FatSecret Platform REST API
  (`lib/features/nutrition/data/fat_secret_service.dart`,
  `fat_secret_token_manager.dart`, `fat_secret_mapper.dart`).
- A Compute Engine `e2-micro` VM proxy (`backend/fatsecret-proxy/`,
  `https://34.27.29.29.sslip.io/rest/server.api`) now brokers those calls, so
  the client never holds `FATSECRET_CLIENT_SECRET` and FatSecret's IP
  allowlist can be satisfied with one static IP. That removed the specific
  cost ADR 010 was reacting to: the client needs no credentials of its own,
  only `FATSECRET_PROXY_URL` (`knowledge/engineering/release_and_distribution.md`,
  `backend/fatsecret-proxy/README.md`).

The owner then compared the two catalogues directly and judged FatSecret's
nutrition data — serving structure and micronutrient coverage in particular —
more reliable than OFF's crowd-sourced entries. OFF still has strengths ADR
010 already recorded: no account of any kind, broader coverage of
region-specific branded products outside FatSecret's catalogue, and it keeps
working if the proxy VM is ever down. Neither catalogue alone is clearly
better in every dimension, which is what makes a fallback the right shape
rather than a straight switch.

**Owner decision, 2026-09-05:** food lookups use FatSecret as the primary
catalogue and OFF as the backup, in every build where FatSecret is
configured — including tester builds, not just the dev machine.

## Options considered

- FatSecret only (drop OFF).
- OFF only (status quo, ADR 010 unchanged).
- FatSecret primary, OFF fallback (chosen).

## Decision

`FallbackFoodDataProvider(primary, fallback)` in
`lib/features/nutrition/domain/fallback_food_data_provider.dart` implements
`FoodDataProvider` by trying `primary` first and falling through to
`fallback` under specific, asymmetric rules (below). The composition surface
(`foodDataProvider` in `lib/features/nutrition/nutrition_providers.dart`)
wires it as FatSecret-via-proxy over OFF when `FATSECRET_PROXY_URL` is
configured, else OFF alone — there is no build configuration that runs
FatSecret without an OFF fallback behind it.

`ProviderFood` and `ProviderFoodSummary` each carry a `source` field so a
result records **which catalogue actually answered**, not which provider the
port happens to be pointed at. This distinction matters precisely because of
the fallback: a search can be served by OFF even when FatSecret is the
configured primary, and a saved food's provenance, the attribution shown on
the review screen, and the ODbL/FatSecret-terms obligations that follow all
depend on knowing which one it was for *that* result. `source` is stamped
from the result, never from the provider instance that happened to be tried
first.

### Fallback rules

- **Barcode lookup** falls back to OFF on network failure **or** not-found.
  A barcode is a global identifier partitioned across two independent
  catalogues; if FatSecret doesn't have it, OFF might, so a genuine
  not-found result is worth spending a second call on.
- **Text search** falls back to OFF on network failure **only**. An empty
  results page from FatSecret does *not* trigger a fallback — search is
  paginated, and switching catalogues mid-pagination (or between an empty
  page and a later one) would silently mix result sets from two providers
  under one scroll. A search that is genuinely exhausted on the primary
  catalogue is not distinguishable from one that would fall back on retry, so
  the rule holds pagination to one catalogue per search session.
- **`ValidationException` never falls back.** A validation failure (a
  malformed barcode, a query rejected before it reached either network) is
  the caller's input, not the primary catalogue's availability — retrying it
  against the fallback would repeat the same failure for no reason and would
  misreport a client-side problem as a provider outage.

### Attribution

The composite's `attributionName`/`attributionUrl` read **"FatSecret and
Open Food Facts"**, not just the primary's. The first-run consent notice
(`knowledge/domain/nutrition.md`'s "first-run consent gate") names who a
lookup's words or barcode may be sent to, and with a live fallback in place
that is honestly *either* service, not necessarily the one whose name is
configured first. Per-result attribution — the review screen, saved-food
provenance, and the ODbL/FatSecret licence obligations below — still names
the specific catalogue in `source`, exactly as ADR 010 required for OFF
alone.

- **FatSecret's Platform API terms require attribution** ("Powered by
  FatSecret"), which `FatSecretService.attributionName`/`attributionUrl`
  already carry (`'FatSecret'` / `'https://www.fatsecret.com'`) the same way
  `OpenFoodFactsService` carries OFF's. Both remain correct as
  *per-provider* attribution; the composite's combined string is additional,
  not a replacement.
- **OFF's ODbL attribution obligation is unchanged** by any of this — see
  ADR 010's "Attribution is required" and its share-alike discussion, which
  still applies to any OFF-sourced row regardless of whether FatSecret is
  also configured.

### Privacy consequence

A query or barcode that reaches the fallback path now potentially reaches
**two** third parties instead of one: FatSecret first (via the proxy, so
FatSecret itself, not the proxy operator, receives it — see
`backend/fatsecret-proxy/README.md`'s CORS/key notes for what the proxy does
and does not see), then OFF if FatSecret's answer doesn't qualify under the
rules above. This is the same category of disclosure ADR 010 already gated
behind an explicit first-run action rather than search-as-you-type; nothing
about *when* a lookup happens changes, only that a single explicit lookup
can now generate two outbound requests instead of one. The first-run notice
copy must name both services for this to stay honest, which is why the
composite's attribution string exists.

### Why ADR 010's licensing objection no longer applies

ADR 010 rejected FatSecret because a commercial API "reintroduces ADR 006's
secret-management burden for a feature that works without it, and couples a
core flow to a billing relationship." The proxy removes the first half: the
client embeds no FatSecret credential, committed or otherwise — only a proxy
URL, which is not a secret in the same sense (it is a routing detail, not a
credential; see ADR 006 and the proxy's `X-MenFit-Key` gate for what
*is* treated as one). The second half — a billing relationship — is not
eliminated, only currently absent: FatSecret is being used on **the tier the
owner registered for**, and this ADR does not assert a specific price or
quota, current or future, that has not been confirmed. If that tier's terms
or limits change, this decision should be revisited rather than assumed to
still hold.

## Consequences

- Food lookups are more resilient: FatSecret's proxy (a single VM) or
  FatSecret's own API being unavailable no longer means "no online lookup at
  all" — OFF picks up barcode misses and search-call failures.
  Correspondingly, OFF being blocked or slow no longer degrades a build that
  has FatSecret configured, since OFF is only reached on failure.
- A build with no FatSecret configuration (no `FATSECRET_PROXY_URL` and no
  client credentials) is unaffected: it still resolves to OFF alone, exactly
  as ADR 010 specified. `FallbackFoodDataProvider` is never constructed with
  only one side.
- Saved foods can now legitimately carry either `FoodSource.fatSecret` or
  `FoodSource.openFoodFacts` in the *same* build and even within the *same*
  search session (a query that falls back mid-session), which was not
  previously possible outside switching build configuration. Any code that
  assumed "this build's provider" was a single, static answer for the whole
  session needs to read `source` off the individual result instead.
- Env/config surfaces (`release_and_distribution.md`, `distribute_android.ps1`,
  `tools/menfit_deploy/DeployCore.cs`) now describe "no FatSecret proxy
  configured" as "this build uses OFF only", not as a degraded or
  unsupported state — it is ADR 010's behaviour, unchanged, and remains a
  legitimate build shape (e.g. a build made before the owner sets up
  `env/<env>.secrets.json`).

## What a future session must not do

- **Do not re-add single-provider wiring to `foodDataProvider`.** The
  composition surface must always resolve to `FallbackFoodDataProvider(fatSecret,
  openFoodFacts)` when FatSecret is configured, never to FatSecret alone —
  "FatSecret primary" describes ordering, not exclusivity.
- **Do not stamp `source` from which provider instance was asked.** Stamp it
  from the result that actually answered. A `FallbackFoodDataProvider` that
  hardcodes `source: fatSecret` because "that's the primary" will mislabel
  every OFF-served fallback result, which breaks both provenance and the
  ODbL attribution obligation that provenance exists to satisfy.
- **Do not detail or enrich a specific result through the composite.** A
  `ProviderFoodSummary.barcode` from FatSecret is a FatSecret `food_id`, not
  a GTIN; sent through the composite it misses on the FatSecret leg and
  then hits Open Food Facts as an EAN-8, returning the wrong product. Every
  per-result fetch (`online_food_search_controller.dart` enrichment,
  `BarcodeLookupController.fetchFullRecord`, any future one) must go
  through `provider.providerFor(result.source)`. Only a user-scanned or
  typed barcode, which has no source yet, goes to the composite.
- **Do not let an empty search page fall back.** Only a network failure
  falls back a search; a legitimately exhausted result set falling back
  would silently interleave two catalogues' pagination.
- **Do not let `ValidationException` fall back.** It is a caller-input
  failure, not a provider-availability signal.
- **Do not assert a FatSecret price or quota this ADR does not state.** Say
  "the tier the owner registered for," not a specific plan name or free/paid
  claim, unless `backend/fatsecret-proxy/README.md` or the session log is
  amended to confirm one.
- **Do not drop the composite attribution string.** The first-run consent
  notice must keep naming both services while a fallback is live, even
  though a single successful lookup only ever used one of them.

## Rejected alternatives

- **FatSecret only (drop OFF).** Loses OFF's broader coverage of
  region-specific branded products FatSecret's catalogue lacks (ADR 010's
  original reason for choosing OFF), and makes the single proxy VM a hard
  single point of failure for the entire food-lookup feature rather than a
  soft one. Also throws away the ODbL-driven design work already done
  (`ServingBasis`, review-before-save, provenance) for no gain, since none
  of it is FatSecret-specific.
- **OFF only (status quo, ADR 010 unchanged).** Keeps the feature working
  exactly as shipped, with zero migration risk, but forgoes the data-quality
  improvement (serving structure, micronutrient coverage) the owner
  identified as the actual motivation for this change. Rejected because the
  proxy work already removed ADR 010's stated objection (the secret-
  management burden), leaving no remaining reason to keep FatSecret out.
