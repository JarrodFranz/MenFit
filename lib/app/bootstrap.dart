import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/env.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Logs [message] via `dart:developer`, gated by [AppEnv.logLevel] so
/// noisy levels (e.g. `debug`) are silent in staging/prod while still
/// honest about what's configured — no logging package, per
/// `knowledge/engineering/error_handling.md`.
void _log(
  String message, {
  required LogLevel level,
  String name = 'FemFit',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!AppEnv.instance.logLevel.allows(level)) {
    return;
  }
  developer.log(
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    level: level.numericLevel,
  );
}

/// Wires up global error hooks, prepares async singletons, and runs the app.
///
/// Kept out of `main.dart` so `main.dart` stays a one-line entry point and
/// so this logic can be exercised/reused independently of the platform
/// entry point (e.g. in future flavored `main_dev.dart` files).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    _log(
      details.exceptionAsString(),
      level: LogLevel.severe,
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _log(
      'Uncaught platform error',
      level: LogLevel.severe,
      name: 'PlatformDispatcher',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
