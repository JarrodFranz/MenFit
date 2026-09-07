import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard test for the Windows CMake floor (ADR 014).
///
/// `audioplayers_windows` declares `cmake_minimum_required(VERSION 3.15)`,
/// and CMake refuses to configure a project tree whose top-level floor is
/// lower than a subdirectory's when that lowers policy settings underneath
/// it. The Flutter template ships 3.14, so adopting audioplayers meant
/// raising `windows/CMakeLists.txt` to 3.15.
///
/// **Nothing on the Windows dev machine fails until someone runs
/// `flutter build windows`**, which is a slow build nobody runs by
/// accident - and the two lines look like inert boilerplate to a quick
/// read, which is exactly the kind of line that gets reverted in a template
/// resync. Hence a guard, in the style of
/// `android_release_r8_rules_test.dart`.
void main() {
  group('windows/CMakeLists.txt', () {
    final file = File('windows/CMakeLists.txt');

    test('exists', () {
      expect(file.existsSync(), isTrue);
    });

    test('requires CMake 3.15 or newer', () {
      final match = RegExp(
        r'cmake_minimum_required\(VERSION (\d+)\.(\d+)',
      ).firstMatch(file.readAsStringSync());

      expect(match, isNotNull, reason: 'no cmake_minimum_required() found');
      final major = int.parse(match!.group(1)!);
      final minor = int.parse(match.group(2)!);

      expect(
        major > 3 || (major == 3 && minor >= 15),
        isTrue,
        reason:
            'audioplayers_windows requires 3.15; a lower floor here fails '
            '`flutter build windows` at the CMake configure step, not at '
            'analyze or test time. Found $major.$minor.',
      );
    });

    test('the policy floor matches the minimum', () {
      final match = RegExp(
        r'cmake_policy\(VERSION (\d+)\.(\d+)',
      ).firstMatch(file.readAsStringSync());

      expect(match, isNotNull, reason: 'no cmake_policy(VERSION ...) found');
      final major = int.parse(match!.group(1)!);
      final minor = int.parse(match.group(2)!);

      expect(
        major > 3 || (major == 3 && minor >= 15),
        isTrue,
        reason:
            'leaving the policy floor at 3.14 while the minimum says 3.15 '
            'reintroduces the pre-3.15 policy behaviour the bump was for. '
            'Found $major.$minor.',
      );
    });
  });
}
