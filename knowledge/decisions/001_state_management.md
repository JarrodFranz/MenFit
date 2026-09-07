# 001 — State Management: Riverpod 3 with code generation

- **Status:** Accepted
- **Date:** 2026-08-25

## Context
Long-lived multi-platform app (iOS/Android/Web/Windows), heavy async (DB streams, GPS streams, sync status), sensitive-data DI needs, codebase developed primarily by AI agents (consistency matters more than cleverness).

## Options considered
Riverpod 3 (with/without codegen); Bloc/Cubit; Provider; signals; ChangeNotifier + InheritedWidget.

## Decision
**Riverpod 3 with codegen** (`@riverpod` via `riverpod_generator`). Default `autoDispose`; annotate `keepAlive: true` for app-scoped services. (`riverpod_lint` intended but currently uninstallable due to an analyzer version conflict — see `../troubleshooting/dependency_resolution.md`; re-add when possible.)

## Reasons
- DI and reactive state in one system — no separate get_it/injectable layer.
- `AsyncValue<T>` / `StreamProvider` map directly onto repository streams with uniform loading/error handling; async is this app's core workload.
- Best testing story: `ProviderContainer(overrides: [...])` gives pure-Dart tests of any provider graph.
- Codegen leaves exactly one way to declare each provider → agent-consistent code; Riverpod 3 removed most legacy variants, shrinking the decision surface.
- Pure Dart — identical on all four platforms.

## Consequences
build_runner is committed infrastructure (see ADR 005); provider files carry `part '*.g.dart'`; agents must respect `ref` lifecycle rules.

## Rejected alternatives
- **Bloc/Cubit** — disciplined but needs separate DI, ~2× ceremony per feature, no AsyncValue equivalent; nothing it does better matters here.
- **Provider** — maintenance mode; runtime-only DI errors.
- **signals** — young, small ecosystem, no DI story.
- **Hand-rolled ChangeNotifier/DI** — hand-maintaining DI, async caching, and disposal at this scale is negative value.
