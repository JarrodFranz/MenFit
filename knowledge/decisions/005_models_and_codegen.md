# 005 — Models & Code Generation: freezed + json_serializable; build_runner as committed infrastructure

- **Status:** Accepted
- **Date:** 2026-08-25

## Context
Riverpod codegen (ADR 001), typed routes (ADR 002), and Drift (ADR 003) already require build_runner. Question: model strategy and how to keep codegen from hurting the agent-driven workflow.

## Options considered
freezed + json_serializable; dart_mappable; plain hand-written classes; built_value.

## Decision
**freezed** for domain entities and UI state (immutability, `copyWith`, equality, sealed unions with exhaustive switching); **json_serializable** for DTOs at the remote boundary only. Drift row classes stay Drift-generated — map to freezed entities at the DAO/repository boundary; never freeze Drift rows.

Codegen workflow rules:
- Run `dart run build_runner build --delete-conflicting-outputs` after any model/provider/route/table edit (first step of the validation sequence).
- **Generated files are committed**; CI verifies cleanliness via build + `git diff --exit-code`.
- Scope builders with `build.yaml` `generate_for` as the app grows.

## Reasons
Sealed unions (sync status, auth state, failure types) with Dart 3 exhaustive pattern matching are the payoff; freezed has by far the largest ecosystem/agent familiarity → most consistent generated usage; hand-written `copyWith`/`==` is exactly the repetitive code that gets subtly wrong.

## Consequences
`part` files everywhere; build step in the loop (~mitigated by committing outputs); one coherent codegen story rather than a mixed stack.

## Rejected alternatives
- **dart_mappable** — decent, smaller ecosystem, insufficient benefit to deviate from the standard.
- **plain classes** — error-prone boilerplate.
- **built_value** — legacy ergonomics.
- **zero-codegen stack** — would also surrender riverpod_generator/go_router_builder/drift benefits; the codegen ship has sailed, so commit coherently.
