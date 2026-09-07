/// Minimum severity a log call must meet to actually be emitted.
///
/// Ordered low → high; `dart:developer`'s `log(level: ...)` uses roughly
/// the same numeric bands (`fine`=500, `info`=800, `warning`=900,
/// `severe`=1000), which [numericLevel] mirrors so callers can pass it
/// straight through.
enum LogLevel {
  debug,
  info,
  warning,
  severe;

  /// Parses the `LOG_LEVEL` env value, defaulting to [info] for anything
  /// unrecognised.
  static LogLevel fromEnvValue(String value) {
    return switch (value) {
      'debug' => LogLevel.debug,
      'info' => LogLevel.info,
      'warning' => LogLevel.warning,
      'severe' => LogLevel.severe,
      _ => LogLevel.info,
    };
  }

  /// The approximate `dart:developer` numeric level for this severity.
  int get numericLevel => switch (this) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.severe => 1000,
  };

  /// Whether a message logged at [other] severity should be emitted given
  /// this as the minimum configured level.
  bool allows(LogLevel other) => other.index >= index;
}

/// Build-time application environment configuration.
///
/// Values are supplied via `--dart-define-from-file=env/<name>.json` (see
/// the `env/` directory). When no dart-define is supplied at all, every
/// value falls back to sensible `dev` defaults so the app still runs.
class AppEnv {
  const AppEnv._({
    required this.name,
    required this.appName,
    required this.apiBaseUrl,
    required this.mapTileUrl,
    required this.orsApiKey,
    required this.offBaseUrl,
    required this.offSearchBaseUrl,
    required this.offContact,
    required this.fatSecretClientId,
    required this.fatSecretClientSecret,
    required this.fatSecretTokenUrl,
    required this.fatSecretApiBaseUrl,
    required this.fatSecretProxyUrl,
    required this.fatSecretProxyKey,
  });

  /// The single, immutable instance of the current environment.
  static const AppEnv instance = AppEnv._(
    name: _appEnv,
    appName: _appName,
    apiBaseUrl: _apiBaseUrl,
    mapTileUrl: _mapTileUrl,
    orsApiKey: _orsApiKey,
    offBaseUrl: _offBaseUrl,
    offSearchBaseUrl: _offSearchBaseUrl,
    offContact: _offContact,
    fatSecretClientId: _fatSecretClientId,
    fatSecretClientSecret: _fatSecretClientSecret,
    fatSecretTokenUrl: _fatSecretTokenUrl,
    fatSecretApiBaseUrl: _fatSecretApiBaseUrl,
    fatSecretProxyUrl: _fatSecretProxyUrl,
    fatSecretProxyKey: _fatSecretProxyKey,
  );

  static const String _appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String _appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'MenFit',
  );

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// XYZ tile template URL for the route-map tile layer.
  ///
  /// Defaults to OSM's public `tile.openstreetmap.org`, which is acceptable
  /// for dev/low-volume use only (unique User-Agent + visible attribution
  /// required - see `knowledge/research/run_tracking_stack.md#map-tiles`).
  /// Swapping to a production tile provider (MapTiler/Stadia/Thunderforest)
  /// is a deferred product decision - this env var is the single seam that
  /// change goes through; no code change needed, just a new `env/*.json`
  /// value (and, if the provider requires a key, a `MAP_TILE_URL` with an
  /// embedded key supplied via the gitignored `env/*.secrets.json` overlay
  /// per ADR 006 rather than committed here).
  static const String _mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
  );

  /// OpenRouteService API key for route suggestions (routes feature).
  ///
  /// Deliberately NOT present in the committed `env/*.json` files — it's a
  /// secret-ish client key per ADR 006 / security_and_privacy.md rule 2
  /// (rate-limited server-side, but still not repo material). Supply it via
  /// `--dart-define=ORS_API_KEY=your_key` or a gitignored
  /// `env/dev.secrets.json` passed as an additional
  /// `--dart-define-from-file`. When empty (the default), the route-suggest
  /// UI shows a setup card instead of calling the API (see
  /// `features/routes/presentation/route_suggest_screen.dart`).
  static const String _orsApiKey = String.fromEnvironment('ORS_API_KEY');

  /// Open Food Facts host for barcode/product lookups (nutrition feature).
  ///
  /// Points at **production `.org` in every environment, including dev**,
  /// deliberately. Open Food Facts asks developers to test against the
  /// `.net` staging server, and their stated reason is keeping the product
  /// database safe — a guard against test *writes*. This client is strictly
  /// read-only and can no more damage their database than a browser can.
  /// Staging also carries a separate, incomplete product database, so
  /// pointing dev at it would make local testing actively misleading (every
  /// barcode "not found"). This stays env-configurable so switching to
  /// `https://world.openfoodfacts.net` is a one-line change if that ever
  /// becomes necessary.
  ///
  /// Not a secret (ADR 006): it is a public, keyless, read-only endpoint,
  /// so unlike `ORS_API_KEY` it belongs in the committed `env/*.json`.
  static const String _offBaseUrl = String.fromEnvironment(
    'OFF_BASE_URL',
    defaultValue: 'https://world.openfoodfacts.org',
  );

  /// Open Food Facts Search-a-licious host for food text search.
  ///
  /// A separate host from [_offBaseUrl], not a path on it. Same
  /// production-not-staging reasoning; also not a secret.
  static const String _offSearchBaseUrl = String.fromEnvironment(
    'OFF_SEARCH_BASE_URL',
    defaultValue: 'https://search.openfoodfacts.org',
  );

  /// Contact address embedded in the Open Food Facts User-Agent.
  ///
  /// Open Food Facts requires `AppName/Version (ContactEmail)` and uses the
  /// contact to reach a misbehaving client rather than simply blocking its
  /// traffic — so **this must be set before distribution** (tracked in
  /// `knowledge/flutter/platform_notes.md`'s pre-distribution checklist
  /// alongside the `com.example` rename). Empty by default, in which case
  /// the User-Agent is built without the parenthetical rather than with a
  /// placeholder.
  ///
  /// **Never a personal email address** — a role/support address only. It
  /// ships in the binary and is sent on every request, so a personal one
  /// would be publishing the developer's address, not configuring an app.
  static const String _offContact = String.fromEnvironment('OFF_CONTACT');

  /// FatSecret Client ID for food search and barcode lookups.
  ///
  /// Supplied via `--dart-define=FATSECRET_CLIENT_ID=...` or via gitignored
  /// `env/*.secrets.json` overlay.
  static const String _fatSecretClientId = String.fromEnvironment(
    'FATSECRET_CLIENT_ID',
  );

  /// FatSecret Client Secret for OAuth 2.0 Client Credentials grant.
  ///
  /// Never commit to git (ADR 006). Supplied via gitignored secrets overlay.
  static const String _fatSecretClientSecret = String.fromEnvironment(
    'FATSECRET_CLIENT_SECRET',
  );

  /// FatSecret OAuth2 token exchange endpoint.
  static const String _fatSecretTokenUrl = String.fromEnvironment(
    'FATSECRET_TOKEN_URL',
    defaultValue: 'https://oauth.fatsecret.com/connect/token',
  );

  /// FatSecret REST API endpoint.
  static const String _fatSecretApiBaseUrl = String.fromEnvironment(
    'FATSECRET_API_BASE_URL',
    defaultValue: 'https://platform.fatsecret.com/rest/server.api',
  );

  /// Optional FatSecret proxy endpoint URL (the Compute Engine VM proxy,
  /// see backend/fatsecret-proxy/README.md).
  static const String _fatSecretProxyUrl = String.fromEnvironment(
    'FATSECRET_PROXY_URL',
  );

  /// Optional secret key passed to the FatSecret proxy via X-MenFit-Key.
  static const String _fatSecretProxyKey = String.fromEnvironment(
    'FATSECRET_PROXY_KEY',
  );

  static const String _logLevelValue = String.fromEnvironment(
    'LOG_LEVEL',
    defaultValue: 'debug',
  );

  /// The active environment name: `dev`, `staging`, or `prod`.
  final String name;

  /// The human-readable application name.
  final String appName;

  /// Base URL for API calls. Empty by default until a backend exists.
  final String apiBaseUrl;

  /// XYZ tile template URL for the route-map tile layer (see
  /// `_mapTileUrl` above for the production-swap plan).
  final String mapTileUrl;

  /// OpenRouteService API key for route suggestions; empty when not
  /// configured (see `_orsApiKey` above for how to supply it — never via
  /// the committed `env/*.json` files).
  final String orsApiKey;

  /// Open Food Facts host for barcode/product lookups (see `_offBaseUrl`
  /// above for why this is production in every environment).
  final String offBaseUrl;

  /// Open Food Facts Search-a-licious host for food text search.
  final String offSearchBaseUrl;

  /// Contact address for the Open Food Facts User-Agent; empty until it is
  /// set before distribution (see `_offContact` above).
  final String offContact;

  /// FatSecret Client ID; empty when not configured.
  final String fatSecretClientId;

  /// FatSecret Client Secret; empty when not configured.
  final String fatSecretClientSecret;

  /// FatSecret OAuth2 token exchange endpoint.
  final String fatSecretTokenUrl;

  /// FatSecret REST API endpoint.
  final String fatSecretApiBaseUrl;

  /// Optional FatSecret proxy endpoint URL.
  final String fatSecretProxyUrl;

  /// Optional shared secret key for the FatSecret proxy.
  final String fatSecretProxyKey;

  /// The minimum severity that should be logged in this environment.
  LogLevel get logLevel => LogLevel.fromEnvValue(_logLevelValue);

  bool get isDev => name == 'dev';

  bool get isStaging => name == 'staging';

  bool get isProd => name == 'prod';
}
