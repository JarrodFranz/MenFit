/// Sealed hierarchy of typed application failures.
///
/// The data layer catches raw platform/IO errors (`SqliteException`,
/// `SocketException`, plugin errors, ...) at the lowest level and rethrows
/// one of these — a raw platform exception must never cross a repository
/// boundary (see `knowledge/engineering/error_handling.md`). Riverpod
/// captures thrown [AppException]s into `AsyncError`; presentation code
/// pattern-matches on the sealed type and maps [userMessageKey] to copy.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    required this.userMessageKey,
    this.cause,
    this.stackTrace,
  });

  /// Developer-facing description of what went wrong. Never shown to
  /// users and never contains sensitive payloads (coordinates, health/cycle
  /// values, tokens, personal identifiers).
  final String message;

  /// Key identifying the user-presentable message, resolved against l10n
  /// once localisation exists. Not human copy itself.
  final String userMessageKey;

  /// The original error this exception was wrapped from, if any.
  final Object? cause;

  /// The stack trace captured at the point of wrapping, if any.
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message';
}

/// Local persistence failed (Drift/SQLite errors, disk I/O, migration
/// failures).
final class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.storage',
  });
}

/// A network/API call failed (connectivity, timeout, non-2xx response).
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.network',
  });
}

/// Authentication failed or the current session is no longer valid.
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.auth',
  });
}

/// A required OS-level permission (location, notifications, health data)
/// was denied or is unavailable.
final class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.permission',
  });
}

/// Input failed validation. Prefer sealed result values for expected
/// per-field form validation; reserve this for failures surfaced as
/// exceptions (e.g. validation performed deep in a repository call).
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.validation',
  });
}

/// The outbox/sync pipeline failed to push or pull data (see ADR 004).
final class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.sync',
  });
}

/// A failure that doesn't fit another category, or an unexpected raw error
/// caught at a boundary with no more specific classification available.
final class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.cause,
    super.stackTrace,
    super.userMessageKey = 'error.unknown',
  });
}
