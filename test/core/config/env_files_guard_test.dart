import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard test for the committed `env/*.json` files (config-only surface, so
/// it gets a guard test per `knowledge/engineering/coding_standards.md`).
///
/// ADR 006 / security_and_privacy.md rule 2: these files are committed, so
/// they may hold only non-secret config. The OpenRouteService key is the
/// first secret-ish value the app has (routes feature, ADR 009) and is
/// supplied via `--dart-define=ORS_API_KEY=...` or a gitignored
/// `env/*.secrets.json` overlay. If someone "fixes" a missing key by
/// pasting it into `env/dev.json`, this test is what catches it before the
/// commit reaches a remote.
void main() {
  /// Every committed env file. `*.secrets.json` is gitignored and may exist
  /// locally with a real key in it - excluded deliberately, since it is
  /// exactly where a key is *supposed* to go.
  final envFiles = Directory('env')
      .listSync()
      .whereType<File>()
      .where(
        (file) =>
            file.path.endsWith('.json') && !file.path.endsWith('.secrets.json'),
      )
      .toList();

  test('the env directory actually has committed files to check', () {
    // Otherwise every assertion below would pass vacuously if the files
    // moved or the test's working directory changed.
    expect(envFiles, isNotEmpty);
  });

  for (final file in envFiles) {
    final name = file.uri.pathSegments.last;

    group(name, () {
      test('carries no OpenRouteService key', () {
        final raw = file.readAsStringSync();
        expect(
          raw.toUpperCase(),
          isNot(contains('ORS_API_KEY')),
          reason:
              'env/$name is committed - the ORS key belongs in a '
              '--dart-define or a gitignored env/*.secrets.json (ADR 006).',
        );

        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final key in decoded.keys) {
          expect(
            key.toUpperCase(),
            isNot(contains('ORS')),
            reason:
                'env/$name must not name an ORS setting at all - not even '
                'an empty placeholder, which invites someone to fill it in.',
          );
        }
      });

      test('carries no FatSecret credentials', () {
        final raw = file.readAsStringSync();
        expect(
          raw.toUpperCase(),
          isNot(contains('FATSECRET_CLIENT_SECRET')),
          reason:
              'env/$name is committed - FatSecret secret belongs in a '
              '--dart-define or gitignored env/*.secrets.json (ADR 006).',
        );

        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final key in decoded.keys) {
          expect(
            key.toUpperCase(),
            isNot(contains('FATSECRET')),
            reason:
                'env/$name must not name FatSecret credentials - not even '
                'an empty placeholder.',
          );
        }
      });

      test('carries no value shaped like a pasted credential', () {
        // Catches the same mistake made under a name this test does not
        // know about ("API_KEY", "TOKEN", ...). URLs are the one long
        // opaque-looking value this config legitimately holds - a URL with
        // an embedded key is caught by review, not by shape.
        final decoded =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is! String || value.startsWith('http')) continue;
          expect(
            value.length,
            lessThan(32),
            reason:
                'env/$name: "${entry.key}" holds a long opaque string. If '
                'that is a credential it belongs in a gitignored '
                'env/*.secrets.json (ADR 006).',
          );
        }
      });
    });
  }
}
