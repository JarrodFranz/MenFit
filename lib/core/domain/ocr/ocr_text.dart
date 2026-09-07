/// The recognised-text shape shared by the OCR adapter and the label
/// parser (ADR 012).
///
/// **One definition, in `core/domain/`, on purpose.** These types were
/// briefly declared twice — once beside the platform adapter that produces
/// them (`core/platform/ocr/ocr_result.dart`) and once beside the nutrition
/// parser that consumes them
/// (`features/nutrition/domain/label_ocr/ocr_text.dart`) — because neither
/// layer may import the other: architecture rule 1 keeps `domain/` free of
/// `core/platform`, and rule 3 says nothing in `core/` may reach into a
/// feature. Two structurally identical types with different APIs is the
/// worst of both: the adapter's mapping and the parser's reader drift
/// apart silently, and every test double has to pick a side. Rule 3's
/// actual answer is this file — `core/domain/` is where genuinely shared
/// value types live (`local_date.dart`, `units.dart`, `entity_id.dart`),
/// and it is importable from both sides.
///
/// **Pure Dart, and it has to stay that way.** No Flutter, no `dart:ui`,
/// no `dart:io`, no engine package — the parser is the only part of the
/// OCR feature testable without a device, and ADR 012 leaves Web and
/// Windows with no OCR path at all, so the day a `dart:ui` `Rect` sneaks in
/// here is the day the heuristic stops being testable on the machine it is
/// developed on. [OcrRect] exists for exactly that reason; the ML Kit
/// adapter converts at the boundary and is the only place a `Rect`
/// appears. Pinned by `test/features/nutrition/label_ocr/`
/// `label_ocr_import_guard_test.dart`, which scans this directory too.
///
/// Geometry is in whatever units the engine reported (ML Kit reports image
/// pixels). The parser only ever compares boxes with each other, never
/// against an absolute scale, so the unit does not matter as long as one
/// result uses one unit throughout.
library;

/// An axis-aligned bounding box in engine coordinates, origin top-left,
/// y increasing downwards.
///
/// The parser clusters rows by [centerY] and buckets columns by [centerX],
/// so those two getters are load-bearing rather than conveniences.
final class OcrRect {
  const OcrRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;

  double get height => bottom - top;

  double get centerX => (left + right) / 2;

  double get centerY => (top + bottom) / 2;

  /// The smallest box containing both this and [other] — used when two
  /// elements the engine split apart are merged back into one token.
  OcrRect union(OcrRect other) => OcrRect(
    left: left < other.left ? left : other.left,
    top: top < other.top ? top : other.top,
    right: right > other.right ? right : other.right,
    bottom: bottom > other.bottom ? bottom : other.bottom,
  );

  @override
  // Every field is final and there are no setters — immutable in
  // substance, just not annotated `@immutable`, which lives in
  // `package:meta` and would drag a dependency into a file the nutrition
  // `domain/` layer imports. Same call as `core/domain/local_date.dart`.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is OcrRect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  // Same reason as the `==` above: immutable in substance, and
  // `@immutable` is not importable here.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'OcrRect($left, $top, $right, $bottom)';
}

/// Roughly one space-separated word, with its own box.
final class OcrElement {
  const OcrElement({
    required this.text,
    required this.box,
    this.confidence,
  });

  final String text;
  final OcrRect box;

  /// The engine's own confidence, `0.0`-`1.0`, or `null` when the platform
  /// did not supply one.
  ///
  /// **Null is common and must not be substituted for.** ML Kit documents
  /// this field as Android-only ("for iOS returns null"), and it is
  /// reported to be null on Android too in some conditions — unverified on
  /// a device as of ADR 012. Nothing here invents a value to fill the gap:
  /// a fabricated confidence would be indistinguishable from a measured
  /// one exactly where it matters. The parser computes its own per-field
  /// confidence and treats this as, at most, a tiebreaker; an absent
  /// confidence is "no signal", never "low".
  final double? confidence;
}

/// One recognised line of text, in reading order within its block.
final class OcrLine {
  const OcrLine({
    required this.text,
    required this.box,
    this.elements = const [],
    this.confidence,
  });

  final String text;
  final OcrRect box;
  final List<OcrElement> elements;

  /// As [OcrElement.confidence] — Android-only, frequently `null`, never
  /// fabricated.
  final double? confidence;
}

/// A paragraph-ish group of lines.
///
/// ML Kit's block boundaries follow visual grouping, not table semantics,
/// so a nutrition panel may arrive as one block or as a dozen — on a real
/// panel it routinely returns a whole *column* as one block. Block and
/// line grouping is therefore **advisory only**: the parser rebuilds rows
/// from element geometry rather than trusting either.
final class OcrBlock {
  const OcrBlock({
    required this.text,
    required this.box,
    this.lines = const [],
  });

  final String text;
  final OcrRect box;
  final List<OcrLine> lines;
}

/// Whether [OcrResult] carries a recognition attempt or the statement that
/// this platform has no recognition at all.
///
/// The distinction is not cosmetic: an empty [OcrResult.blocks] from a real
/// attempt means "nothing legible in that photo, try again", while
/// [OcrOutcome.unsupported] means "this build cannot do this, do not offer
/// it". Collapsing the two would put a retry button in front of a Windows
/// user forever.
enum OcrOutcome { recognised, unsupported }

/// Everything one recognition pass produced.
final class OcrResult {
  const OcrResult({required this.blocks, required this.fullText})
    : outcome = OcrOutcome.recognised;

  /// The result an adapter returns on a platform without text recognition.
  const OcrResult.unsupported()
    : blocks = const <OcrBlock>[],
      fullText = '',
      outcome = OcrOutcome.unsupported;

  /// Nothing recognised — what an adapter returns for a blank or
  /// unreadable frame. Distinct from [OcrResult.unsupported]; see
  /// [OcrOutcome].
  static const OcrResult empty = OcrResult(blocks: [], fullText: '');

  final List<OcrBlock> blocks;

  /// Every recognised character, as the recogniser concatenated it. Used
  /// only for whole-panel cues (which label standard this is); useless for
  /// column layout, which needs the boxes.
  final String fullText;

  final OcrOutcome outcome;

  bool get isUnsupported => outcome == OcrOutcome.unsupported;

  /// Every line in every block, block order preserved.
  Iterable<OcrLine> get lines => blocks.expand((block) => block.lines);
}
