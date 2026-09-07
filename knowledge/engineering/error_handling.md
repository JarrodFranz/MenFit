# Error Handling

*Established 2026-08-25 (from bootstrap architecture research).*

## Model

- **Failures → exceptions, typed.** Sealed `AppException` hierarchy in `core/errors/`: `NetworkException`, `StorageException`, `AuthException`, `PermissionException`, `ValidationException`, `SyncException`, `UnknownException` — each carries a user-presentable message key + `cause`.
- **Data layer wraps at the boundary.** Catch raw platform/IO errors (`SqliteException`, `SocketException`, plugin errors) at the lowest level and rethrow as typed `AppException`. A raw platform exception must never cross a repository boundary.
- **Presentation consumes via `AsyncValue`.** Riverpod captures thrown exceptions into `AsyncError`; UI pattern-matches and maps `AppException` → copy. `AsyncValue` *is* our Result type at the UI boundary — do not introduce Either/fpdart alongside it.
- **Expected domain outcomes are return values, not exceptions.** Form validation results, "no route found for that distance", "streak paused" — sealed result classes per operation. Exceptions signal failures, not branches.

## Global hooks

`bootstrap.dart` installs `FlutterError.onError` and `PlatformDispatcher.instance.onError` → logging façade. When crash reporting is added (own evaluation), breadcrumbs are scrubbed — no sensitive data (see security_and_privacy.md).

## Logging

A single logging façade (candidate: `logging` package) is adopted with the first real service (per package_decisions.md); until then `bootstrap.dart` logs via `dart:developer`. Whatever the mechanism: levels used honestly; no sensitive payloads ever (coordinates, health values, tokens); log messages name events and non-sensitive ids.
