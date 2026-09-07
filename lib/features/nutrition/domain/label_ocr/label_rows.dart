/// Rebuilding the *rows* of the table out of loose boxes.
///
/// The engine's own block and line grouping cannot be trusted here: on a
/// real panel ML Kit routinely returns a whole column as one block, so the
/// numbers arrive column-by-column rather than row-by-row. Everything in
/// this file therefore works from element geometry alone, and the order
/// the engine happened to emit things in is never consulted.
library;

import 'package:menfit_app/core/domain/ocr/ocr_text.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_numbers.dart';

/// One reconstructed row of the panel, left to right.
class OcrRow {
  const OcrRow({required this.elements, required this.centerY});

  final List<OcrElement> elements;
  final double centerY;

  String get text => elements.map((e) => e.text).join(' ');
}

/// Flatten a result to elements, dropping empties.
///
/// A line with no elements of its own (some adapters only populate line
/// text) becomes a single element so nothing is lost.
List<OcrElement> flattenElements(OcrResult ocr) {
  final out = <OcrElement>[];
  for (final block in ocr.blocks) {
    if (block.lines.isEmpty) {
      if (block.text.trim().isNotEmpty) {
        out.add(OcrElement(text: block.text.trim(), box: block.box));
      }
      continue;
    }
    for (final line in block.lines) {
      if (line.elements.isEmpty) {
        if (line.text.trim().isNotEmpty) {
          out.add(OcrElement(text: line.text.trim(), box: line.box));
        }
        continue;
      }
      for (final element in line.elements) {
        if (element.text.trim().isEmpty) continue;
        out.add(
          OcrElement(
            text: element.text.trim(),
            box: element.box,
            confidence: element.confidence,
          ),
        );
      }
    }
  }
  return out;
}

/// The median element height — the parser's only length scale. Every
/// tolerance below is a fraction of it, so the parser is independent of
/// image resolution and of how close the phone was held.
double medianHeightOf(List<OcrElement> elements) {
  if (elements.isEmpty) return 0;
  final heights = elements.map((e) => e.box.height).toList()..sort();
  final middle = heights.length ~/ 2;
  if (heights.length.isOdd) return heights[middle];
  return (heights[middle - 1] + heights[middle]) / 2;
}

/// Group elements into rows by vertical position, then order each row
/// left to right and glue split tokens back together.
List<OcrRow> clusterRows(OcrResult ocr) {
  final elements = flattenElements(ocr);
  if (elements.isEmpty) return const [];

  final scale = medianHeightOf(elements);
  final tolerance = scale > 0 ? scale * 0.5 : 1.0;

  final sorted = [...elements]
    ..sort((a, b) => a.box.centerY.compareTo(b.box.centerY));

  final groups = <List<OcrElement>>[];
  var currentMean = sorted.first.box.centerY;
  var current = <OcrElement>[sorted.first];
  for (final element in sorted.skip(1)) {
    if ((element.box.centerY - currentMean).abs() <= tolerance) {
      current.add(element);
      currentMean =
          current.map((e) => e.box.centerY).reduce((a, b) => a + b) /
          current.length;
    } else {
      groups.add(current);
      current = <OcrElement>[element];
      currentMean = element.box.centerY;
    }
  }
  groups.add(current);

  return [
    for (final group in groups)
      OcrRow(
        elements: mergeSplitTokens(
          [...group]..sort((a, b) => a.box.left.compareTo(b.box.left)),
          scale,
        ),
        centerY:
            group.map((e) => e.box.centerY).reduce((a, b) => a + b) /
            group.length,
      ),
  ];
}

/// Glue back together what the engine split apart.
///
/// Three real failure modes, in the order they are repaired:
/// `less` + `than` → `<`; a bound sign left on its own; a number split
/// mid-digits (`1` + `2.5 g`); and a unit emitted as its own element
/// (`5.2` + `g`). Only tokens that are horizontally *touching* — a gap
/// well under one line height — are ever merged, so two columns of
/// numbers cannot fuse.
List<OcrElement> mergeSplitTokens(List<OcrElement> row, double scale) {
  if (row.length < 2) return row;
  final tight = scale > 0 ? scale * 0.6 : 1.0;
  final veryTight = scale > 0 ? scale * 0.35 : 0.5;

  // "less than" first: it turns two words into a bound sign, which the
  // merge loop below then attaches to the number.
  final collapsed = <OcrElement>[];
  for (var i = 0; i < row.length; i++) {
    final isLess = row[i].text.toLowerCase() == 'less';
    final hasThan =
        i + 1 < row.length && row[i + 1].text.toLowerCase() == 'than';
    if (isLess && hasThan) {
      collapsed.add(
        OcrElement(
          text: '<',
          box: row[i].box.union(row[i + 1].box),
          confidence: _lowerConfidence(row[i], row[i + 1]),
        ),
      );
      i++;
    } else {
      collapsed.add(row[i]);
    }
  }

  final out = <OcrElement>[];
  var index = 0;
  while (index < collapsed.length) {
    var current = collapsed[index];
    var next = index + 1;
    while (next < collapsed.length) {
      final candidate = collapsed[next];
      final gap = candidate.box.left - current.box.right;
      if (gap > tight) break;
      if (!_shouldMerge(current, candidate, gap, veryTight)) break;
      current = OcrElement(
        text: '${current.text}${candidate.text}',
        box: current.box.union(candidate.box),
        confidence: _lowerConfidence(current, candidate),
      );
      next++;
    }
    out.add(current);
    index = next;
  }
  return out;
}

bool _shouldMerge(
  OcrElement current,
  OcrElement candidate,
  double gap,
  double veryTight,
) {
  final currentText = current.text;
  if (currentText == '<' || currentText == '≤') {
    return isValueToken(candidate.text);
  }
  final currentToken = parseNumericToken(currentText);
  if (currentToken == null) return false;
  if (isUnitOnlyToken(candidate.text)) return true;
  // Digits split mid-number. Deliberately the tightest rule of the three:
  // it is the only one that could fuse two different values.
  if (gap <= veryTight &&
      currentToken.unit == UnitKind.none &&
      RegExp('^[0-9.,]').hasMatch(candidate.text) &&
      isValueToken(candidate.text)) {
    return true;
  }
  return false;
}

double? _lowerConfidence(OcrElement a, OcrElement b) {
  final left = a.confidence;
  final right = b.confidence;
  if (left == null) return right;
  if (right == null) return left;
  return left < right ? left : right;
}
