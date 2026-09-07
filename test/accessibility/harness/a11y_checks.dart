import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'a11y_findings.dart';

/// Material's `kMinInteractiveDimension`, and Android's documented minimum
/// touch target. iOS HIG asks for 44pt, so anything under 44 is worse than
/// both platforms' floors and is reported one step more severely.
const double kMinTapTarget = 48;
const double kIosMinTapTarget = 44;

/// Matches the message `DebugOverflowIndicatorMixin` reports, e.g.
/// `A RenderFlex overflowed by 2.0 pixels on the bottom.`
final RegExp _overflowPattern = RegExp(
  r'A (\w+) overflowed by ([\d.]+) pixels on the (\w+)',
);

/// Turns the errors captured while a screen was pumped into findings.
///
/// Overflow is the primary check: it is the class of bug the owner
/// photographed on real hardware, and it was invisible to every assertion
/// this suite had before this harness existed.
List<A11yFinding> overflowFindings({
  required String screen,
  required String scenario,
  required List<FlutterErrorDetails> errors,
}) {
  final findings = <A11yFinding>[];
  for (final error in errors) {
    final text = error.exceptionAsString();
    final match = _overflowPattern.firstMatch(text);
    if (match != null) {
      final pixels = double.tryParse(match.group(2)!) ?? 0;
      findings.add(
        A11yFinding(
          screen: screen,
          scenario: scenario,
          issue: A11yIssue.overflow,
          severity: pixels >= 20 ? A11ySeverity.critical : A11ySeverity.high,
          detail: '${match.group(1)} overflowed on the ${match.group(3)}',
          measurement: '${match.group(2)}px',
          source: _creatorChain(error),
        ),
      );
      continue;
    }
    findings.add(
      A11yFinding(
        screen: screen,
        scenario: scenario,
        issue: A11yIssue.renderFailure,
        severity: A11ySeverity.critical,
        detail: _firstLine(text),
        source: _creatorChain(error) ?? _appFrames(error.stack),
      ),
    );
  }
  return findings;
}

/// Digs the widget chain out of an overflow report.
///
/// `DebugOverflowIndicatorMixin` attaches a [DebugCreator] to the error's
/// information collector precisely so the offending widget can be named;
/// without pulling it out, every overflow finding reads "a RenderFlex
/// somewhere overflowed", which is not actionable.
String? _creatorChain(FlutterErrorDetails error) {
  final nodes = error.informationCollector?.call();
  if (nodes == null) return null;
  for (final node in nodes) {
    final value = node.value;
    if (value is DebugCreator) {
      // Overflow is reported during *layout*, but the findings are read
      // afterwards — by then a scrolled-away list item's element can already
      // be defunct, and `Element.widget` throws on those. An unattributable
      // overflow is still a real overflow, so degrade rather than lose it.
      final element = value.element;
      if (!element.mounted) return null;
      try {
        return appWidgetChain(element);
      } on Object {
        return null;
      }
    }
  }
  return null;
}

/// Framework wrappers that appear in every creator chain and identify
/// nothing. Filtering them out is the difference between "a RenderFlex
/// somewhere overflowed" and "`_ExerciseHubsSection` overflowed".
const Set<String> _frameworkNoise = {
  'AbsorbPointer', 'Align', 'AnimatedContainer', 'AnimatedDefaultTextStyle',
  'AnimatedOpacity', 'AnimatedPadding', 'AnimatedSize', 'AspectRatio',
  'Baseline', 'Builder', 'Center', 'ClipPath', 'ClipRRect', 'ClipRect',
  'ColoredBox', 'Column', 'ConstrainedBox', 'Container', 'CupertinoTheme',
  'CustomMultiChildLayout', 'CustomPaint', 'CustomSingleChildLayout',
  'DecoratedBox', 'DecoratedBoxTransition', 'DefaultSelectionStyle',
  'DefaultTextStyle', 'Directionality', 'Expanded', 'FadeTransition',
  'Flex', 'Flexible', 'FractionallySizedBox', 'GestureDetector', 'Icon',
  'IconTheme', 'IgnorePointer', 'InheritedCupertinoTheme', 'InkResponse',
  'InkWell', 'IntrinsicHeight', 'IntrinsicWidth', 'KeyedSubtree',
  'LayoutBuilder', 'LayoutId', 'Listener', 'Material', 'MediaQuery',
  'MouseRegion', 'NotificationListener', 'Offstage', 'Opacity', 'Padding',
  'PhysicalModel', 'PhysicalShape', 'Positioned', 'RawGestureDetector',
  'RepaintBoundary', 'RichText', 'Row', 'SafeArea', 'Scrollable',
  'Semantics', 'SingleChildScrollView', 'SizedBox', 'SliverPadding',
  'Stack', 'Text', 'TextFieldTapRegion', 'Transform', 'UnconstrainedBox',
  'Viewport', 'Wrap',
  // Material/widgets internals that wrap essentially every control.
  'Actions', 'AnimatedBuilder', 'AnimatedPhysicalModel', 'AnimatedTheme',
  'Card', 'Focus', 'FocusTraversalOrder', 'FocusTraversalGroup',
  'InheritedTheme', 'ListenableBuilder',
  'PrimaryScrollController', 'ScrollConfiguration',
  'ScrollNotificationObserver', 'Shortcuts', 'Theme', 'TickerMode',
  'Tooltip', 'ValueListenableBuilder',
  '_ActionsScope', '_EffectiveTickerMode', '_FocusInheritedScope',
  '_FocusMarker', '_InheritedTheme', '_InkFeatures', '_MaterialInterior',
  '_ParentInkResponseProvider', '_ScrollableScope', '_ScrollSemantics',
  '_SelectionKeepAlive', '_ShapeBorderPaint', '_ShortcutsMarker',
};

/// The nearest few *app* widgets above [element], noise removed.
String appWidgetChain(Element element, {int keep = 5}) {
  final names = <String>[];

  void consider(Widget widget) {
    final name = widget.runtimeType
        .toString()
        .split('-')
        .first
        .split('<')
        .first;
    if (_frameworkNoise.contains(name)) return;
    if (names.isNotEmpty && names.last == name) return;
    names.add(name);
  }

  consider(element.widget);
  element.visitAncestorElements((ancestor) {
    consider(ancestor.widget);
    return names.length < keep;
  });
  return names.take(keep).join(' < ');
}

/// The first few frames of [stack] that belong to this app rather than to
/// the framework — the only ones that name a file a fix could be made in.
String? _appFrames(StackTrace? stack) {
  if (stack == null) return null;
  final frames = const LineSplitter()
      .convert(stack.toString())
      .where((line) => line.contains('package:menfit_app/'))
      .take(3)
      .map((line) => line.trim())
      .toList();
  return frames.isEmpty ? null : frames.join(' / ');
}

String _firstLine(String value) {
  final line = value.split('\n').first.trim();
  return line.length > 160 ? '${line.substring(0, 157)}...' : line;
}

/// An interactive widget and the box it was actually laid out into.
class TapTarget {
  const TapTarget({
    required this.label,
    required this.rect,
    required this.chain,
  });

  final String label;
  final Rect rect;
  final String chain;

  double get smallestSide =>
      rect.width < rect.height ? rect.width : rect.height;
}

/// Whether [widget] is something the user can press, and it is enabled.
///
/// Disabled controls are skipped: a greyed-out button is not a tap target
/// the user can miss.
bool _isInteractive(Widget widget) {
  return switch (widget) {
    InkResponse(:final onTap, :final onLongPress, :final onDoubleTap) =>
      onTap != null || onLongPress != null || onDoubleTap != null,
    GestureDetector(:final onTap, :final onLongPress) =>
      onTap != null || onLongPress != null,
    IconButton(:final onPressed) => onPressed != null,
    ButtonStyleButton(:final onPressed, :final onLongPress) =>
      onPressed != null || onLongPress != null,
    FloatingActionButton(:final onPressed) => onPressed != null,
    ListTile(:final onTap, :final onLongPress) =>
      onTap != null || onLongPress != null,
    Checkbox(:final onChanged) => onChanged != null,
    Switch(:final onChanged) => onChanged != null,
    // `Radio.onChanged` is deprecated in favour of `RadioGroup`, but the
    // audit must still recognise the widget for as long as the framework
    // ships it and this app can still be using it.
    // ignore: deprecated_member_use
    Radio<Object?>(:final onChanged) => onChanged != null,
    RawChip(:final onPressed, :final onSelected) =>
      onPressed != null || onSelected != null,
    ActionChip(:final onPressed) => onPressed != null,
    FilterChip(:final onSelected) => onSelected != null,
    ChoiceChip(:final onSelected) => onSelected != null,
    _ => false,
  };
}

/// Every enabled interactive widget on screen, measured from the **render**
/// tree rather than the semantics tree.
///
/// The semantics tree looks like the better source — it is what Android's
/// Accessibility Scanner reads, and it de-duplicates composite widgets for
/// free — but its rects are clipped by every ancestor clip, so a chip half
/// scrolled under the navigation bar reports as a 22dp-tall "violation"
/// that scrolling would fix. `RenderBox.size` is the laid-out size, which
/// is the thing a designer can actually change.
///
/// De-duplication instead uses containment: a candidate is dropped when an
/// ancestor candidate wraps it at no more than [_wrapperAreaRatio] times its
/// area — that is Material's `Button > InkWell > child` padding chain, one
/// target, not three. A small button inside a large tappable card has no
/// such tight wrapper, so it is still reported.
const double _wrapperAreaRatio = 4;

/// Containment has to be inclusive of the shared edge.
///
/// [Rect.contains] is half-open — a point on the right or bottom edge is
/// *not* contained — so a control flush with its wrapper's edge failed the
/// containment test and was reported as a second, smaller target. Every
/// Material chip does exactly that: `_ChipRedirectingHitDetectionWidget`
/// grows the chip's height to 48dp but never its width, so the inner
/// `InkWell` shares both vertical edges with it and the pair never
/// collapsed into one target. The chip then reported at its label height
/// (38dp) no matter what the theme did to its tap target, which made the
/// Large Touch Targets preference look inert when it was not.
const double _edgeEpsilon = 0.01;

bool _containsInclusive(Rect outer, Rect inner) =>
    inner.left >= outer.left - _edgeEpsilon &&
    inner.top >= outer.top - _edgeEpsilon &&
    inner.right <= outer.right + _edgeEpsilon &&
    inner.bottom <= outer.bottom + _edgeEpsilon;

/// The Material list tiles that *own* their control.
///
/// `SwitchListTile`, `CheckboxListTile` and `RadioListTile` deliberately
/// build their toggle with `MaterialTapTargetSize.shrinkWrap` (see
/// `switch_list_tile.dart`) because the whole tile is wired to the same
/// callback: the user toggles by tapping anywhere on a ~411x72dp row, and
/// the toggle graphic is not a separate thing to hit. Measuring the
/// graphic and calling it a 40dp target measures the wrong box — no
/// accessibility setting can, or should, change it, because the target the
/// user aims at is the tile, which is measured on its own.
const Set<String> _controlOwningListTiles = {
  'SwitchListTile',
  'CheckboxListTile',
  'RadioListTile',
};

/// Whether [element] is the control of one of [_controlOwningListTiles],
/// and so should be folded into that tile's target however much bigger the
/// tile is.
///
/// Deliberately unbounded rather than "look up a few levels": a Material
/// tile interposes dozens of framework elements between its trailing slot
/// and itself (`InkWell > … > Ink > SafeArea > … > _ListTile > …`), and a
/// depth cap tuned by eye is exactly the kind of thing that silently stops
/// reaching far enough after a framework upgrade. Walking to the root
/// costs one pass over an already-materialised ancestor chain, and nothing
/// above a toggle list tile can turn something into that tile's control.
bool _isOwnedTileControl(Element element) {
  var owned = false;
  element.visitAncestorElements((ancestor) {
    final name = ancestor.widget.runtimeType.toString().split('<').first;
    if (_controlOwningListTiles.contains(name)) {
      owned = true;
      return false;
    }
    return true;
  });
  return owned;
}

List<TapTarget> tapTargets(WidgetTester tester) {
  final candidates = <Element, Rect>{};

  for (final element in tester.allElements) {
    if (!_isInteractive(element.widget)) continue;
    final renderObject = element.renderObject;
    if (renderObject is! RenderBox) continue;
    if (!renderObject.hasSize || renderObject.size.isEmpty) continue;
    if (!renderObject.attached) continue;
    final origin = renderObject.localToGlobal(Offset.zero);
    candidates[element] = origin & renderObject.size;
  }

  final targets = <TapTarget>[];
  for (final entry in candidates.entries) {
    final rect = entry.value;
    final ownedByTile = _isOwnedTileControl(entry.key);
    var wrapped = false;
    entry.key.visitAncestorElements((ancestor) {
      final ancestorRect = candidates[ancestor];
      if (ancestorRect != null &&
          _containsInclusive(ancestorRect, rect) &&
          (ownedByTile ||
              _area(ancestorRect) <= _area(rect) * _wrapperAreaRatio)) {
        wrapped = true;
        return false;
      }
      return true;
    });
    if (wrapped) continue;

    targets.add(
      TapTarget(
        label: _labelFor(entry.key),
        rect: rect,
        chain: appWidgetChain(entry.key),
      ),
    );
  }
  return targets;
}

double _area(Rect rect) => rect.width * rect.height;

/// The first piece of text under [element], or the widget's own type — the
/// name a reviewer needs to find the control on screen.
String _labelFor(Element element) {
  String? found;
  void search(Element candidate) {
    if (found != null) return;
    final renderObject = candidate.renderObject;
    if (renderObject is RenderParagraph) {
      final text = renderObject.text.toPlainText().trim();
      if (text.isNotEmpty) {
        found = text.length > 40 ? '${text.substring(0, 37)}...' : text;
        return;
      }
    }
    final widget = candidate.widget;
    if (widget is Icon && widget.semanticLabel != null) {
      found = widget.semanticLabel;
      return;
    }
    candidate.visitChildren(search);
  }

  element.visitChildren(search);
  final label = found;
  return (label == null || label.isEmpty)
      ? element.widget.runtimeType.toString()
      : label;
}

/// Flags interactive widgets laid out smaller than [minimum].
List<A11yFinding> tapTargetFindings({
  required String screen,
  required String scenario,
  required WidgetTester tester,
  double minimum = kMinTapTarget,
}) {
  final surface = tester.view.physicalSize / tester.view.devicePixelRatio;
  final viewport = Rect.fromLTWH(0, 0, surface.width, surface.height);
  final findings = <A11yFinding>[];
  final seen = <String>{};

  for (final target in tapTargets(tester)) {
    final rect = target.rect;
    if (!rect.overlaps(viewport)) continue;
    if (rect.width >= minimum && rect.height >= minimum) continue;

    final size =
        '${rect.width.toStringAsFixed(1)}x'
        '${rect.height.toStringAsFixed(1)}dp';
    if (!seen.add('${target.label}|$size')) continue;

    findings.add(
      A11yFinding(
        screen: screen,
        scenario: scenario,
        issue: A11yIssue.tapTarget,
        severity: target.smallestSide < kIosMinTapTarget
            ? A11ySeverity.high
            : A11ySeverity.medium,
        detail: 'tap target "${target.label}" below ${minimum.toInt()}dp',
        measurement:
            '$size at (${rect.left.toStringAsFixed(0)},'
            '${rect.top.toStringAsFixed(0)})',
        source: target.chain,
      ),
    );
  }
  return findings;
}

/// Text that lost meaning: ellipsised/clipped labels, and single words
/// broken mid-word by a wrap.
///
/// Long strings are treated as acceptable truncation — a user-entered
/// activity title or food name legitimately ends in an ellipsis. Short
/// strings are app chrome: a cut-off "Strength" or "Active Energy" is a
/// layout bug, not a content-length problem.
List<A11yFinding> truncationFindings({
  required String screen,
  required String scenario,
  required WidgetTester tester,
  int chromeLengthThreshold = 28,
}) {
  final findings = <A11yFinding>[];
  final seen = <String>{};

  for (final element in tester.allElements) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderParagraph) continue;
    if (!renderObject.hasSize || renderObject.size.isEmpty) continue;
    // Both findings below describe what the reader *sees*, so text that is
    // laid out but painted at zero opacity is out of scope — see
    // [_isPainted] for the case that forced this.
    if (!_isPainted(renderObject)) continue;

    final text = renderObject.text.toPlainText().trim();
    if (text.isEmpty) continue;

    if (renderObject.didExceedMaxLines) {
      final isChrome = text.length <= chromeLengthThreshold;
      if (seen.add('trunc|$text')) {
        findings.add(
          A11yFinding(
            screen: screen,
            scenario: scenario,
            issue: A11yIssue.truncation,
            severity: isChrome ? A11ySeverity.high : A11ySeverity.low,
            detail: isChrome
                ? 'chrome label truncated: "${_clip(text)}"'
                : 'long content truncated (acceptable): "${_clip(text)}"',
            measurement:
                '${renderObject.size.width.toStringAsFixed(1)}dp wide, '
                'maxLines=${renderObject.maxLines}',
            source: isChrome ? appWidgetChain(element) : null,
          ),
        );
      }
      continue;
    }

    // Mid-word wrap: a label with no whitespace rendered on more than one
    // line. Material's NavigationBar label has neither ellipsis nor
    // hyphenation, so this is how "Wellbeing" becomes "Wellb / eing".
    if (!text.contains(RegExp(r'\s'))) {
      final oneLine = renderObject.getMinIntrinsicHeight(double.infinity);
      if (renderObject.size.height > oneLine + 0.5 && seen.add('wrap|$text')) {
        findings.add(
          A11yFinding(
            screen: screen,
            scenario: scenario,
            issue: A11yIssue.midWordWrap,
            severity: A11ySeverity.high,
            detail: 'single word wrapped mid-word: "${_clip(text)}"',
            measurement:
                '${renderObject.size.height.toStringAsFixed(1)}dp tall vs '
                '${oneLine.toStringAsFixed(1)}dp for one line',
            source: appWidgetChain(element),
          ),
        );
      }
    }
  }
  return findings;
}

String _clip(String value) =>
    value.length <= 48 ? value : '${value.substring(0, 45)}...';

/// Whether [renderObject] is actually drawn, or sits inside a subtree that
/// has been faded fully out.
///
/// Material keeps *building* a `NavigationBar` label when `labelBehavior`
/// is `alwaysHide`: the label is still laid out at the destination's width,
/// so a long one still breaks mid-word, and is then painted at zero opacity
/// with `alwaysIncludeSemantics: true` so screen readers keep announcing
/// it. That is precisely the state `AppAdaptiveScaffold`'s icon-only
/// fallback puts the bar into, and a wrap nobody can see is not the defect
/// this audit is looking for.
///
/// Only the *visual* checks consult this. The tap-target check deliberately
/// does not: a transparent control is still pressable, and a control the
/// user can hit but not see is a worse bug, not an excused one.
bool _isPainted(RenderObject renderObject) {
  RenderObject? node = renderObject;
  while (node != null) {
    if (node is RenderAnimatedOpacity) {
      if (node.opacity.value == 0) return false;
    } else if (node is RenderOpacity) {
      if (node.opacity == 0) return false;
    }
    node = node.parent;
  }
  return true;
}

/// How far two rects may overlap before it is called occlusion.
///
/// Not zero: adjoining boxes share an edge, and anti-aliased borders and
/// sub-pixel rounding routinely put a fraction of a logical pixel of one
/// widget inside another. 4dp is below the smallest thing a finger can
/// distinguish and well above that noise.
const double _occlusionTolerance = 4;

/// One rectangle in the occlusion comparison: either a control the user can
/// press, or a run of text they are meant to read.
class _OcclusionBox {
  const _OcclusionBox({
    required this.element,
    required this.rect,
    required this.label,
    required this.tappable,
  });

  final Element element;
  final Rect rect;
  final String label;
  final bool tappable;
}

/// Flags tappables laid out on top of other controls or of text.
///
/// This is the check the first audit did not have, and the reason the
/// owner's photograph of the Activity screen's floating Record button
/// sitting across the weekly-distance card produced no finding: nothing
/// overflows, nothing is truncated and nothing is undersized — the button
/// is simply painted over content the user still needs. Overlap is a
/// distinct failure mode from every other check here and needs its own
/// geometry.
///
/// Two exclusions keep it honest rather than noisy:
///
/// * **Nesting.** A button's own label, and a small control inside a larger
///   tappable card, are ancestor/descendant pairs. They overlap by
///   construction and are not a defect, so relationship — not geometry —
///   is what disqualifies them.
/// * **Modality.** A dialog or bottom sheet is *supposed* to cover the page
///   behind it. Widgets in different overlay entries are therefore never
///   compared.
List<A11yFinding> occlusionFindings({
  required String screen,
  required String scenario,
  required WidgetTester tester,
  double tolerance = _occlusionTolerance,
}) {
  final surface = tester.view.physicalSize / tester.view.devicePixelRatio;
  final viewport = Rect.fromLTWH(0, 0, surface.width, surface.height);

  final tappables = <_OcclusionBox>[];
  final coverable = <_OcclusionBox>[];

  for (final element in tester.allElements) {
    final renderObject = element.renderObject;
    if (renderObject is! RenderBox) continue;
    if (!renderObject.hasSize || renderObject.size.isEmpty) continue;
    if (!renderObject.attached) continue;

    final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    if (!rect.overlaps(viewport)) continue;

    if (_isInteractive(element.widget)) {
      final box = _OcclusionBox(
        element: element,
        rect: rect,
        label: _labelFor(element),
        tappable: true,
      );
      tappables.add(box);
      coverable.add(box);
      continue;
    }

    if (renderObject is RenderParagraph && _isPainted(renderObject)) {
      final text = renderObject.text.toPlainText().trim();
      if (text.isEmpty) continue;
      coverable.add(
        _OcclusionBox(
          element: element,
          rect: rect,
          label: _clip(text),
          tappable: false,
        ),
      );
    }
  }

  final overlayEntries = <Element, Element?>{};
  Element? overlayEntryOf(Element element) =>
      overlayEntries.putIfAbsent(element, () => _overlayEntryOf(element));

  final findings = <A11yFinding>[];
  final seen = <String>{};

  for (final over in tappables) {
    for (final under in coverable) {
      if (identical(over, under)) continue;

      final overlap = over.rect.intersect(under.rect);
      if (overlap.width <= tolerance || overlap.height <= tolerance) continue;
      if (_isRelated(over.element, under.element)) continue;
      if (overlayEntryOf(over.element) != overlayEntryOf(under.element)) {
        continue;
      }

      final kind = under.tappable ? 'tap target' : 'text';
      if (!seen.add('${over.label}|$kind|${under.label}')) continue;

      findings.add(
        A11yFinding(
          screen: screen,
          scenario: scenario,
          issue: A11yIssue.occlusion,
          // An unreachable control is worse than an unreadable label: the
          // label can at least be scrolled out from under the thing on top
          // of it, whereas a button under another button cannot be pressed
          // at all.
          severity: under.tappable ? A11ySeverity.critical : A11ySeverity.high,
          detail: 'tappable "${over.label}" covers $kind "${under.label}"',
          measurement:
              '${overlap.width.toStringAsFixed(1)}x'
              '${overlap.height.toStringAsFixed(1)}dp overlap at '
              '(${overlap.left.toStringAsFixed(0)},'
              '${overlap.top.toStringAsFixed(0)})',
          source: appWidgetChain(under.element),
        ),
      );
    }
  }
  return findings;
}

/// Whether either element is an ancestor of the other.
bool _isRelated(Element a, Element b) =>
    _isDescendantOf(a, b) || _isDescendantOf(b, a);

bool _isDescendantOf(Element element, Element candidate) {
  var found = false;
  element.visitAncestorElements((ancestor) {
    if (identical(ancestor, candidate)) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// The overlay entry [element] is drawn in, or `null` when it is not in an
/// overlay at all. Two widgets in different entries are in different
/// layers, and one covering the other is modality working as intended.
Element? _overlayEntryOf(Element element) {
  Element? entry;
  element.visitAncestorElements((ancestor) {
    if (ancestor.widget.runtimeType.toString().startsWith(
      '_OverlayEntryWidget',
    )) {
      entry = ancestor;
      return false;
    }
    return true;
  });
  return entry;
}
