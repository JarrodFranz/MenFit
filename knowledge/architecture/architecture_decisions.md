# Architecture Decisions — Summary Index

*Full records in `../decisions/`. This is the quick-scan index.*

| ADR | Decision | Essence |
|---|---|---|
| [001](../decisions/001_state_management.md) | State management | Riverpod 3 with codegen — DI + state + AsyncValue in one system |
| [002](../decisions/002_navigation.md) | Navigation | go_router + typed routes; StatefulShellRoute shell; redirects centralised |
| [003](../decisions/003_local_database.md) | Local DB | Drift on all four platforms (WASM/OPFS on web); prefs + secure-storage sidecars |
| [004](../decisions/004_backend_strategy.md) | Backend | Local-first, UUIDv7 ids, outbox sync pattern; vendor decision deferred behind per-feature remote interfaces |
| [005](../decisions/005_models_and_codegen.md) | Models/codegen | freezed + json_serializable; generated files committed; build_runner embraced |
| [006](../decisions/006_environment_configuration.md) | Env config | dart-define-from-file, committed non-secret env/*.json; no flavors yet |
| [007](../decisions/007_cross_feature_providers.md) | Cross-feature providers | Each feature exposes `<name>_providers.dart` (domain-typed) as the only cross-feature entry besides domain/ |
| [008](../decisions/008_run_recording_stack.md) | Run recording | geolocator 14 built-in FGS; NO ACCESS_BACKGROUND_LOCATION; permission_handler for POST_NOTIFICATIONS; flutter_foreground_task as named fallback |
| [009](../decisions/009_routing_engine.md) | Routing engine | OpenRouteService round-trip behind RouteSuggestionService; start point leaves device (disclosed); vendor swap re-triggers privacy assessment |

Open decisions queued for future ADRs: backend vendor + auth (with E2E-encryption design for cycle sync), production map-tile provider, local-DB encryption (SQLCipher) for cycle data, food database source. (Resolved since bootstrap: maps → flutter_map [in use]; background location → ADR 008; routing engine → ADR 009.)
