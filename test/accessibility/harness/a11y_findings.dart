import 'dart:io';

/// What kind of accessibility problem a finding describes.
enum A11yIssue {
  /// A `RenderFlex`/`RenderBox` overflow reported during paint.
  overflow,

  /// A tap target smaller than the platform minimum.
  tapTarget,

  /// Text truncated with an ellipsis or clipped mid-glyph.
  truncation,

  /// A single word wrapped mid-word (no ellipsis, no hyphenation).
  midWordWrap,

  /// A colour pair below the WCAG contrast threshold.
  contrast,

  /// A tappable widget laid out on top of another control or of text.
  occlusion,

  /// The screen threw while building, or could not be reached.
  renderFailure,
}

/// Rough triage weight, so the report can be read top-down.
enum A11ySeverity { critical, high, medium, low }

/// One audited problem: which screen, under which accessibility scenario,
/// what went wrong and by how much.
class A11yFinding {
  const A11yFinding({
    required this.screen,
    required this.scenario,
    required this.issue,
    required this.severity,
    required this.detail,
    this.measurement,
    this.source,
  });

  final String screen;
  final String scenario;
  final A11yIssue issue;
  final A11ySeverity severity;

  /// Human-readable description — the widget, the label, the colour pair.
  final String detail;

  /// The number that makes the finding actionable: `2.0px`, `32.0x32.0`,
  /// `3.1:1`.
  final String? measurement;

  /// `file:line` when the harness can attribute the finding, else `null`.
  final String? source;

  /// A stable key for de-duplicating the same problem seen under several
  /// scenarios.
  String get dedupeKey => '$screen|${issue.name}|$detail|${measurement ?? ''}';

  @override
  String toString() =>
      '[${severity.name}] $screen ($scenario) ${issue.name}: $detail'
      '${measurement == null ? '' : ' — $measurement'}'
      '${source == null ? '' : ' @ $source'}';
}

/// Collects findings across every test in a file and writes them out once,
/// so an audit run produces one artefact instead of scattered `print`s.
class A11yReport {
  A11yReport(this.name);

  /// Report file stem, e.g. `shell_tabs`.
  final String name;

  final List<A11yFinding> findings = [];

  /// Screens the harness pumped, whether or not they produced findings —
  /// so "no findings" can be distinguished from "never ran".
  final Set<String> auditedScreens = {};

  /// `screen (scenario)` pairs actually executed.
  final List<String> executedCells = [];

  void add(A11yFinding finding) => findings.add(finding);

  void addAll(Iterable<A11yFinding> newFindings) =>
      findings.addAll(newFindings);

  void recordCell(String screen, String scenario) {
    auditedScreens.add(screen);
    executedCells.add('$screen | $scenario');
  }

  /// Writes `build/accessibility_audit/<name>.md` and echoes a compact
  /// summary to the test output.
  void write() {
    final buffer = StringBuffer()
      ..writeln('# Accessibility audit — $name')
      ..writeln()
      ..writeln('Screens audited: ${auditedScreens.length}')
      ..writeln('Screen x scenario cells executed: ${executedCells.length}')
      ..writeln('Findings: ${findings.length}')
      ..writeln();

    final sorted = [...findings]
      ..sort((a, b) {
        final bySeverity = a.severity.index.compareTo(b.severity.index);
        if (bySeverity != 0) return bySeverity;
        final byScreen = a.screen.compareTo(b.screen);
        if (byScreen != 0) return byScreen;
        return a.issue.index.compareTo(b.issue.index);
      });

    buffer
      ..writeln(
        '| Severity | Screen | Scenario | Issue | Detail | Measure | Where |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final f in sorted) {
      buffer.writeln(
        '| ${f.severity.name} | ${f.screen} | ${f.scenario} | '
        '${f.issue.name} | ${_cell(f.detail)} | ${f.measurement ?? ''} | '
        '${_cell(f.source ?? '')} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Cells executed')
      ..writeln();
    for (final cell in executedCells) {
      buffer.writeln('- $cell');
    }

    final directory = Directory('build/accessibility_audit');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    File('${directory.path}/$name.md').writeAsStringSync(buffer.toString());

    // The report IS this harness's output; there is nowhere else for it
    // to go in a test run.
    // ignore: avoid_print
    print(
      'A11Y[$name] ${findings.length} findings across '
      '${executedCells.length} cells -> build/accessibility_audit/$name.md',
    );
    for (final f in sorted) {
      // Same reason as above: stdout is the only channel a test run has.
      // ignore: avoid_print
      print('A11Y[$name] $f');
    }
  }

  String _cell(String value) =>
      value.replaceAll('|', r'\|').replaceAll('\n', ' ');
}
