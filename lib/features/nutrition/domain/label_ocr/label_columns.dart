/// Working out what the *columns* of the table are, and which one a value
/// at a given x belongs to.
///
/// Columns come from the heading row when one can be read, and from where
/// the numbers themselves sit when it cannot — the second case is always
/// declared to the user and always costs confidence.
library;

import 'package:menfit_app/features/nutrition/domain/label_ocr/label_lexicon.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_rows.dart';

/// What a column of numbers is *per*.
enum ColumnKind {
  perServing,
  per100g,
  per100ml,

  /// A `%DI` / `%DV` column. Recognised only so values landing in it can
  /// be discarded — a share of a reference intake is not a quantity.
  percentDaily,
}

/// One detected column.
class LabelColumn {
  const LabelColumn({required this.kind, required this.anchorX});

  final ColumnKind kind;

  /// Horizontal centre of the heading that named this column.
  final double anchorX;
}

/// Where a value landed, and how sure we are it landed there.
class ColumnHit {
  const ColumnHit({required this.column, required this.certainty});

  final LabelColumn column;

  /// 0..1. Below 1 when the value sat between two columns, or when the
  /// whole layout was assumed rather than read from headings.
  final double certainty;
}

/// The columns of one panel.
class ColumnLayout {
  const ColumnLayout({
    required this.columns,
    required this.fromHeaders,
    this.headerRowIndex,
  });

  final List<LabelColumn> columns;

  /// Whether the columns came from recognised headings. When false they
  /// were inferred from where the numbers sit, and every assignment
  /// carries a permanent confidence penalty.
  final bool fromHeaders;

  /// Index into the row list of the heading row, so nutrient scanning can
  /// start below it.
  final int? headerRowIndex;

  bool get isEmpty => columns.isEmpty;

  /// Which column a value at [x] belongs to.
  ColumnHit? hitFor(double x) {
    if (columns.isEmpty) return null;
    var nearest = columns.first;
    var best = (x - nearest.anchorX).abs();
    var second = double.infinity;
    for (final column in columns.skip(1)) {
      final distance = (x - column.anchorX).abs();
      if (distance < best) {
        second = best;
        nearest = column;
        best = distance;
      } else if (distance < second) {
        second = distance;
      }
    }
    // Values sit right-aligned or centred under their heading, so a
    // correct assignment is close to its anchor relative to the gap
    // between columns. Near the midpoint, say so instead of guessing.
    final spacing = second.isFinite ? second + best : double.infinity;
    var certainty = 1.0;
    if (spacing.isFinite && spacing > 0) {
      final ratio = best / spacing;
      if (ratio > 0.5) {
        certainty = 0.6;
      } else if (ratio > 0.35) {
        certainty = 0.8;
      }
    }
    if (!fromHeaders) certainty *= 0.75;
    return ColumnHit(column: nearest, certainty: certainty);
  }
}

/// Heading phrases, plain English; folded by [normaliseHeaderText] before
/// use so both sides of the comparison share one alphabet.
///
/// Order matters within a kind and across kinds: `per 100 ml` must be
/// tested before `per 100 g`, so a millilitre heading is never read as a
/// gram one.
const _headerKeys = <(ColumnKind, String)>[
  (ColumnKind.percentDaily, 'daily intake'),
  (ColumnKind.percentDaily, 'daily value'),
  (ColumnKind.percentDaily, 'reference intake'),
  (ColumnKind.percentDaily, '%di'),
  (ColumnKind.percentDaily, '%dv'),
  (ColumnKind.percentDaily, '%ri'),
  (ColumnKind.per100ml, 'per 100 ml'),
  (ColumnKind.per100ml, '100 ml'),
  (ColumnKind.per100g, 'per 100 g'),
  (ColumnKind.per100g, 'per 100 grams'),
  (ColumnKind.per100g, '100 g'),
  (ColumnKind.perServing, 'amount per serving'),
  (ColumnKind.perServing, 'quantity per serving'),
  (ColumnKind.perServing, 'qty per serving'),
  (ColumnKind.perServing, 'qty per serve'),
  (ColumnKind.perServing, 'per serving'),
  (ColumnKind.perServing, 'per serve'),
  (ColumnKind.perServing, 'per portion'),
  // Deliberately absent: a bare "per 100" (it would claim the first two
  // elements of "Per 100 mL" before the millilitre key is ever tried) and
  // "per pack" (it matches inside "servings per package", which is a
  // serving statement, not a column heading).
];

final _foldedHeaderKeys = <(ColumnKind, String)>[
  for (final entry in _headerKeys) (entry.$1, normaliseHeaderText(entry.$2)),
];

/// Every heading phrase in one row, with the x each sits at.
///
/// **Shortest spans win, across the whole row.** Sweeping spans as the
/// outer loop (rather than positions) is the part that matters: the four
/// elements `Typical values per 100g` join into one string that *contains*
/// `per100g`, so a position-first scan claims all four at index 0 and
/// anchors the column at the average of them — over the caption on the
/// left, not over the numbers on the right. Sweeping span 1 first finds
/// `100g` on its own element and anchors there instead.
List<LabelColumn> _scanRow(OcrRow row) {
  final found = <int, LabelColumn>{};
  final claimed = <int>{};
  for (var span = 1; span <= 4; span++) {
    for (var index = 0; index + span <= row.elements.length; index++) {
      final range = [for (var i = index; i < index + span; i++) i];
      if (range.any(claimed.contains)) continue;
      final slice = row.elements.sublist(index, index + span);
      final joined = normaliseHeaderText(slice.map((e) => e.text).join());
      if (joined.isEmpty) continue;
      for (final key in _foldedHeaderKeys) {
        if (!joined.contains(key.$2)) continue;
        final anchor =
            slice.map((e) => e.box.centerX).reduce((a, b) => a + b) /
            slice.length;
        found[index] = LabelColumn(kind: key.$1, anchorX: anchor);
        claimed.addAll(range);
        break;
      }
    }
  }
  final indices = found.keys.toList()..sort();
  return [for (final index in indices) found[index]!];
}

/// Find the heading row and the columns it defines, or `null` when the
/// panel has no heading this parser recognises.
///
/// The heading row is the one carrying the most phrases; ties go to the
/// topmost, because a panel's real heading sits above its numbers.
ColumnLayout? detectHeaderColumns(List<OcrRow> rows) {
  var bestIndex = -1;
  var best = <LabelColumn>[];
  for (var i = 0; i < rows.length; i++) {
    final found = _scanRow(rows[i]);
    final quantityColumns = found
        .where((c) => c.kind != ColumnKind.percentDaily)
        .length;
    if (quantityColumns == 0) continue;
    final bestQuantity = best
        .where((c) => c.kind != ColumnKind.percentDaily)
        .length;
    if (found.length > best.length ||
        (found.length == best.length && quantityColumns > bestQuantity)) {
      best = found;
      bestIndex = i;
    }
  }
  if (best.isEmpty) return null;
  final deduped = _dedupeColumns(best);
  return ColumnLayout(
    columns: deduped,
    fromHeaders: true,
    headerRowIndex: bestIndex,
  );
}

/// Drop a repeated heading kind at nearly the same x (a heading the
/// engine emitted twice), keeping the leftmost.
List<LabelColumn> _dedupeColumns(List<LabelColumn> columns) {
  final sorted = [...columns]..sort((a, b) => a.anchorX.compareTo(b.anchorX));
  final out = <LabelColumn>[];
  for (final column in sorted) {
    final duplicate = out.any(
      (existing) =>
          existing.kind == column.kind &&
          (existing.anchorX - column.anchorX).abs() < 1,
    );
    if (!duplicate) out.add(column);
  }
  return out;
}

/// Infer columns from where the numbers themselves sit, for a panel whose
/// headings could not be read.
///
/// [count] columns are cut at the [count] - 1 widest horizontal gaps.
/// Capped at two by the caller: guessing a third column's meaning without
/// a heading is not a guess worth making.
ColumnLayout columnsFromValuePositions(
  List<double> xs,
  int count,
  List<ColumnKind> kinds,
) {
  if (xs.isEmpty || count < 1) {
    return const ColumnLayout(columns: [], fromHeaders: false);
  }
  final sorted = [...xs]..sort();
  final wanted = count > kinds.length ? kinds.length : count;
  final gaps = <(double, int)>[];
  for (var i = 1; i < sorted.length; i++) {
    gaps.add((sorted[i] - sorted[i - 1], i));
  }
  gaps.sort((a, b) => b.$1.compareTo(a.$1));
  final cuts = gaps.take(wanted - 1).map((g) => g.$2).toList()..sort();

  final groups = <List<double>>[];
  var start = 0;
  for (final cut in cuts) {
    groups.add(sorted.sublist(start, cut));
    start = cut;
  }
  groups.add(sorted.sublist(start));

  final columns = <LabelColumn>[];
  for (var i = 0; i < groups.length && i < kinds.length; i++) {
    final group = groups[i];
    if (group.isEmpty) continue;
    columns.add(
      LabelColumn(
        kind: kinds[i],
        anchorX: group.reduce((a, b) => a + b) / group.length,
      ),
    );
  }
  return ColumnLayout(columns: columns, fromHeaders: false);
}
