import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards Android system backup being OFF (known_bugs B6). The app's private
/// data (unencrypted health database, SharedPreferences, backup folder) must
/// leave the device only by the user's own choice, never via Google Auto
/// Backup or device-to-device transfer. Config-only surface, so it is pinned
/// here: a manifest edit that re-enabled backup would otherwise go unnoticed.
void main() {
  const manifestPath = 'android/app/src/main/AndroidManifest.xml';
  const rulesDir = 'android/app/src/main/res/xml';

  String stripXmlComments(String source) =>
      source.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

  final manifest = stripXmlComments(File(manifestPath).readAsStringSync());
  final application = RegExp(
    r'<application\b[^>]*>',
  ).firstMatch(manifest)!.group(0)!;

  String? attr(String name) =>
      RegExp('android:$name="([^"]*)"').firstMatch(application)?.group(1);

  /// `<exclude domain="..."/>` domains inside [element] of [xml].
  Set<String> excludedDomains(String xml, String element) {
    final block = RegExp(
      '<$element>([\\s\\S]*?)</$element>',
    ).firstMatch(xml)?.group(1);
    expect(block, isNotNull, reason: '<$element> missing');
    return RegExp(
      r'<exclude\s+domain="(\w+)"\s+path="\."\s*/>',
    ).allMatches(block!).map((m) => m.group(1)!).toSet();
  }

  const allDomains = {'root', 'file', 'database', 'sharedpref', 'external'};

  test('allowBackup is explicitly false', () {
    expect(attr('allowBackup'), 'false');
  });

  test('manifest points at both rules files', () {
    expect(attr('fullBackupContent'), '@xml/backup_rules');
    expect(attr('dataExtractionRules'), '@xml/data_extraction_rules');
  });

  test('backup_rules.xml excludes every domain and includes nothing', () {
    final xml = stripXmlComments(
      File('$rulesDir/backup_rules.xml').readAsStringSync(),
    );
    expect(xml, contains('<full-backup-content>'));
    expect(xml, isNot(contains('<include')));
    expect(excludedDomains(xml, 'full-backup-content'), allDomains);
  });

  test('data_extraction_rules.xml excludes every domain in both modes', () {
    final xml = stripXmlComments(
      File('$rulesDir/data_extraction_rules.xml').readAsStringSync(),
    );
    expect(xml, isNot(contains('<include')));
    expect(excludedDomains(xml, 'cloud-backup'), allDomains);
    expect(excludedDomains(xml, 'device-transfer'), allDomains);
  });
}
