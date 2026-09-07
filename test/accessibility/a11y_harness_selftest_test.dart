import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness/a11y_checks.dart';
import 'harness/a11y_driver.dart';
import 'harness/a11y_findings.dart';

/// Does the harness actually detect the things it claims to detect?
///
/// A check that misses a known-present bug is worse than no check, because
/// it converts "we never looked" into "we looked and it was fine". These
/// tests plant each defect deliberately and fail if the harness stays
/// quiet — they are the calibration the rest of the audit rests on.
void main() {
  setUpAll(loadRealAppFont);

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<List<FlutterErrorDetails>> pumpCapturing(
    WidgetTester tester,
    Widget child,
  ) async {
    final captured = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = captured.add;
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );
      await tester.pump();
    } finally {
      FlutterError.onError = previous;
    }
    return captured;
  }

  testWidgets('overflow check reports a planted 2px vertical overflow', (
    tester,
  ) async {
    // The exact shape of the bug the owner photographed: a fixed-height
    // card whose column of text is two logical pixels too tall.
    final errors = await pumpCapturing(
      tester,
      const SizedBox(
        height: 20,
        width: 140,
        child: Column(
          children: [SizedBox(height: 11), SizedBox(height: 11)],
        ),
      ),
    );

    final findings = overflowFindings(
      screen: 'selftest',
      scenario: 'planted',
      errors: errors,
    );

    expect(
      findings.where((f) => f.issue == A11yIssue.overflow),
      isNotEmpty,
      reason:
          'The overflow check did not see a planted RenderFlex overflow. '
          'Everything downstream of it is untrustworthy until it does.',
    );
    expect(findings.first.measurement, '2.0px');
  });

  testWidgets('tap-target check reports a planted 24dp button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: GestureDetector(
                onTap: () {},
                child: Semantics(
                  label: 'Tiny action',
                  container: true,
                  child: const ColoredBox(color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final findings = tapTargetFindings(
      screen: 'selftest',
      scenario: 'planted',
      tester: tester,
    );

    expect(
      findings.map((f) => f.measurement).join(),
      contains('24.0x24.0dp'),
      reason: 'The tap-target check missed a planted 24x24 target.',
    );
    semantics.dispose();
  });

  testWidgets('truncation check separates cut chrome from cut content', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'Active Energy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  'A user-entered activity title that is genuinely long and '
                  'may legitimately be cut',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final findings = truncationFindings(
      screen: 'selftest',
      scenario: 'planted',
      tester: tester,
    );

    final chrome = findings.where((f) => f.severity == A11ySeverity.high);
    final content = findings.where((f) => f.severity == A11ySeverity.low);
    expect(
      chrome.single.detail,
      contains('Active Energy'),
      reason: 'A cut chrome label must be reported as a high-severity bug.',
    );
    expect(
      content.single.detail,
      contains('acceptable'),
      reason: 'A cut long user string must be reported, but not as a bug.',
    );
  });

  testWidgets('mid-word wrap check reports a planted "Wellb/eing"', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 24, child: Text('Wellbeing')),
        ),
      ),
    );
    await tester.pump();

    final findings = truncationFindings(
      screen: 'selftest',
      scenario: 'planted',
      tester: tester,
    );

    expect(
      findings.where((f) => f.issue == A11yIssue.midWordWrap),
      isNotEmpty,
      reason:
          'The mid-word wrap check missed a planted wrap. This is the check '
          'that catches the multi-tab NavigationBar label problem.',
    );
  });

  testWidgets('wrap check ignores a wrap nobody can see', (tester) async {
    // Material lays a `NavigationBar` label out even when `labelBehavior`
    // is `alwaysHide`, then paints it at zero opacity. Reporting that wrap
    // would make the icon-only fallback in `AppAdaptiveScaffold` look
    // broken when it is the fix.
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Opacity(
            opacity: 0,
            child: SizedBox(width: 24, child: Text('Wellbeing')),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      truncationFindings(
        screen: 'selftest',
        scenario: 'planted',
        tester: tester,
      ),
      isEmpty,
      reason:
          'A wrap inside a fully faded subtree is not something the reader '
          'can see, so it is not a visual defect.',
    );
  });

  testWidgets('occlusion check reports a planted floating button overlap', (
    tester,
  ) async {
    // The exact shape of the bug the owner reported and the first audit
    // could not see: a floating action button painted across a card that
    // is still showing numbers underneath it. Nothing overflows, nothing
    // truncates, nothing is undersized.
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Positioned(
                left: 200,
                top: 700,
                width: 180,
                height: 60,
                child: Text('42.8 km this week'),
              ),
              Positioned(
                left: 300,
                top: 720,
                width: 80,
                height: 56,
                child: FloatingActionButton.extended(
                  onPressed: () {},
                  label: const Text('Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final findings = occlusionFindings(
      screen: 'selftest',
      scenario: 'planted',
      tester: tester,
    );

    expect(
      findings.where((f) => f.issue == A11yIssue.occlusion),
      isNotEmpty,
      reason:
          'The occlusion check missed a floating button planted across a '
          'text rect. This is the check that catches the Record button '
          'sitting on the weekly-distance card.',
    );
    expect(
      findings.first.detail,
      contains('42.8 km this week'),
      reason: 'The finding must name the content that was covered.',
    );
  });

  testWidgets('occlusion check ignores a button covering its own label', (
    tester,
  ) async {
    // Calibration in the other direction: every button contains its own
    // text, and every card-sized InkWell contains everything on the card.
    // A check that reported those would bury the real findings.
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                width: 300,
                height: 120,
                child: Column(
                  children: [
                    Text('Weekly Volume'),
                    Text('42.8 km'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      occlusionFindings(
        screen: 'selftest',
        scenario: 'planted',
        tester: tester,
      ),
      isEmpty,
      reason:
          'A tappable containing its own content is an affordance, not an '
          'occlusion.',
    );
  });

  testWidgets('the real bundled Inter is loaded, not the test font', (
    tester,
  ) async {
    // Ahem-style test glyphs are one em wide, so "Nutrition" at 12sp
    // measures ~108dp there and ~52dp in real Inter. If this assertion
    // fails, every width-sensitive finding in the audit is fiction.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Nutrition',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final width = tester.getSize(find.text('Nutrition')).width;
    expect(
      width,
      lessThan(80),
      reason:
          'Text measured ${width.toStringAsFixed(1)}dp — that is the test '
          'font, not Inter. loadRealAppFont() did not take effect.',
    );
  });
}
