/// Transcribed nutrition panels, as `OcrResult`s.
///
/// **These are not real OCR captures.** Nobody photographed packaging to
/// produce them: every box, every confidence and every split token here
/// was written by hand to *model* what ML Kit returns, from the layout of
/// panels in the three standards ADR 012 names. That makes them good at
/// what they are for — pinning the parser's rules down so a change that
/// breaks FSANZ two-column reading fails loudly — and useless as evidence
/// that the parser works on a real phone pointed at a real box.
///
/// An on-device corpus (photographs of actual packaging, run through the
/// real engine, with the recognised text checked against the printed
/// panel) is a **registered follow-up**, called out in ADR 012's effort
/// estimate as the part that cannot be done from fixtures. Nothing in this
/// file should be read as having done it.
///
/// Geometry convention: 7 units per character, 14 units per line, rows 20
/// apart. The parser's tolerances are all fractions of the median element
/// height, so those numbers only matter relative to each other: a unit
/// glued onto its number sits ~3 units away (well inside the 8.4 merge
/// gap) and columns sit ~100 apart (well outside it).
library;

import 'package:menfit_app/core/domain/ocr/ocr_text.dart';

const charWidth = 7.0;
const lineHeight = 14.0;

/// One recognised word at ([x], [y]), sized from its own text.
OcrElement word(String text, double x, double y, {double? confidence}) =>
    OcrElement(
      text: text,
      box: OcrRect(
        left: x,
        top: y,
        right: x + text.length * charWidth,
        bottom: y + lineHeight,
      ),
      confidence: confidence,
    );

/// A row of `(text, x)` pairs at [y].
List<OcrElement> row(
  double y,
  List<(String, double)> tokens, {
  double? confidence,
}) => [
  for (final token in tokens)
    word(token.$1, token.$2, y, confidence: confidence),
];

OcrRect _union(List<OcrElement> elements) {
  var box = elements.first.box;
  for (final element in elements.skip(1)) {
    box = box.union(element.box);
  }
  return box;
}

OcrLine _lineOf(List<OcrElement> elements) => OcrLine(
  text: elements.map((e) => e.text).join(' '),
  box: _union(elements),
  elements: elements,
);

/// The friendly case: one block per printed row, in reading order.
OcrResult panelOf(List<List<OcrElement>> rows) {
  final lines = [for (final elements in rows) _lineOf(elements)];
  return OcrResult(
    blocks: [
      for (final line in lines)
        OcrBlock(text: line.text, box: line.box, lines: [line]),
    ],
    fullText: lines.map((l) => l.text).join('\n'),
  );
}

/// The same panel grouped the way ML Kit actually groups a table: one
/// block per *column*, values before labels, so nothing about the emitted
/// order tells you which number belongs to which row.
OcrResult columnMajorPanelOf(
  List<List<OcrElement>> rows,
  List<double> bandStarts,
) {
  final all = [for (final elements in rows) ...elements];
  final bands = <int, List<OcrElement>>{};
  for (final element in all) {
    var band = 0;
    for (var i = 0; i < bandStarts.length; i++) {
      if (element.box.centerX >= bandStarts[i]) band = i;
    }
    bands.putIfAbsent(band, () => []).add(element);
  }
  final ordered = bands.keys.toList()..sort((a, b) => b.compareTo(a));
  return OcrResult(
    blocks: [
      for (final band in ordered)
        OcrBlock(
          text: bands[band]!.map((e) => e.text).join(' '),
          box: _union(bands[band]!),
          lines: [
            for (final element in bands[band]!) _lineOf([element]),
          ],
        ),
    ],
    fullText: [
      for (final elements in rows) elements.map((e) => e.text).join(' '),
    ].join('\n'),
  );
}

/// (a) A clean FSANZ Nutrition Information Panel, Per Serving + Per 100 g,
/// energy on two lines (kJ then the bracketed calorie figure), indented
/// "- saturated" / "- sugars" sub-rows.
List<List<OcrElement>> fsanzTwoColumnRows({double? confidence = 0.95}) => [
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)], confidence: confidence),
  row(20, [
    ('Servings', 10),
    ('per', 70),
    ('package:', 95),
    ('12', 160),
  ], confidence: confidence),
  row(40, [
    ('Serving', 10),
    ('size:', 65),
    ('30g', 105),
  ], confidence: confidence),
  row(60, [
    ('Per', 190),
    ('Serving', 214),
    ('Per', 310),
    ('100g', 333),
  ], confidence: confidence),
  row(80, [
    ('Energy', 10),
    ('830', 200),
    ('kJ', 224),
    ('2770', 315),
    ('kJ', 346),
  ], confidence: confidence),
  row(100, [
    ('(198', 200),
    ('Cal)', 231),
    ('(662', 315),
    ('Cal)', 346),
  ], confidence: confidence),
  row(120, [
    ('Protein', 10),
    ('5.2', 200),
    ('g', 224),
    ('17.3', 315),
    ('g', 346),
  ], confidence: confidence),
  row(140, [
    ('Fat,', 10),
    ('total', 45),
    ('10.2', 200),
    ('g', 229),
    ('34.0', 315),
    ('g', 346),
  ], confidence: confidence),
  row(160, [
    ('-', 20),
    ('saturated', 30),
    ('4.1', 200),
    ('g', 224),
    ('13.7', 315),
    ('g', 346),
  ], confidence: confidence),
  row(180, [
    ('Carbohydrate', 10),
    ('18.6', 200),
    ('g', 229),
    ('62.0', 315),
    ('g', 346),
  ], confidence: confidence),
  row(200, [
    ('-', 20),
    ('sugars', 30),
    ('2.1', 200),
    ('g', 224),
    ('7.0', 315),
    ('g', 339),
  ], confidence: confidence),
  row(220, [
    ('Dietary', 10),
    ('Fibre', 60),
    ('3.4', 200),
    ('g', 224),
    ('11.3', 315),
    ('g', 346),
  ], confidence: confidence),
  row(240, [
    ('Sodium', 10),
    ('115', 200),
    ('mg', 224),
    ('383', 315),
    ('mg', 339),
  ], confidence: confidence),
];

OcrResult fsanzTwoColumn() => panelOf(fsanzTwoColumnRows());

/// (j) The same panel, emitted column-by-column instead of row-by-row.
OcrResult fsanzTwoColumnInterleaved() =>
    columnMajorPanelOf(fsanzTwoColumnRows(), const [0, 180, 300]);

/// (b) The same panel with the noise a real capture carries: letters read
/// as digits and back again, a mangled nutrient name, a number split
/// across two elements, and a low engine confidence throughout.
OcrResult fsanzNoisy() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)], confidence: 0.55),
  row(20, [
    ('Servings', 10),
    ('per', 70),
    ('package:', 95),
    ('12', 160),
  ], confidence: 0.55),
  row(40, [
    ('Serving', 10),
    ('size:', 65),
    ('30g', 105),
  ], confidence: 0.55),
  row(60, [
    ('Per', 190),
    ('Serving', 214),
    ('Per', 310),
    ('100g', 333),
  ], confidence: 0.55),
  row(80, [
    ('Energy', 10),
    ('830', 200),
    ('kJ', 224),
    ('2770', 315),
    ('kJ', 346),
  ], confidence: 0.55),
  row(100, [
    ('(198', 200),
    ('Cal)', 231),
    ('(662', 315),
    ('Cal)', 346),
  ], confidence: 0.55),
  // "Protein" with a zero for the o.
  row(120, [
    ('Pr0tein', 10),
    ('5.2', 200),
    ('g', 224),
    ('17.3', 315),
    ('g', 346),
  ], confidence: 0.55),
  // 10.2 split mid-number; 34.0 with a letter O for the zero.
  row(140, [
    ('Fat,', 10),
    ('total', 45),
    ('1', 200),
    ('0.2', 209),
    ('g', 233),
    ('34.O', 315),
    ('g', 346),
  ], confidence: 0.55),
  // "saturated" mangled into "Saturatecl".
  row(160, [
    ('-', 20),
    ('Saturatecl', 30),
    ('4.1', 200),
    ('g', 224),
    ('13.7', 315),
    ('g', 346),
  ], confidence: 0.55),
  row(180, [
    ('Carbohydrate', 10),
    ('18.6', 200),
    ('g', 229),
    ('62.0', 315),
    ('g', 346),
  ], confidence: 0.55),
  row(240, [
    ('S0dium', 10),
    ('115', 200),
    ('mg', 224),
    ('383', 315),
    ('mg', 339),
  ], confidence: 0.55),
]);

/// (c) FSANZ with the optional %DI column between the two quantity ones.
OcrResult fsanzThreeColumn() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)]),
  row(60, [
    ('Per', 190),
    ('Serving', 214),
    ('%DI', 340),
    ('Per', 430),
    ('100g', 453),
  ]),
  row(80, [
    ('Energy', 10),
    ('830', 200),
    ('kJ', 224),
    ('9%', 345),
    ('2770', 445),
    ('kJ', 476),
  ]),
  row(120, [
    ('Protein', 10),
    ('5.2', 200),
    ('g', 224),
    ('10%', 345),
    ('17.3', 455),
    ('g', 486),
  ]),
  row(140, [
    ('Fat,', 10),
    ('total', 45),
    ('10.2', 200),
    ('g', 229),
    ('15%', 345),
    ('34.0', 455),
    ('g', 486),
  ]),
  row(240, [
    ('Sodium', 10),
    ('115', 200),
    ('mg', 224),
    ('5%', 345),
    ('383', 455),
    ('mg', 479),
  ]),
]);

/// (d) A drink: one column, per 100 **mL**.
OcrResult fsanzPer100Millilitres() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)]),
  row(20, [
    ('Serving', 10),
    ('size:', 65),
    ('250', 105),
    ('mL', 129),
  ]),
  row(60, [('Per', 250), ('100mL', 273)]),
  row(80, [('Energy', 10), ('195', 260), ('kJ', 283)]),
  row(100, [('Protein', 10), ('0.5', 260), ('g', 284)]),
  row(120, [
    ('Fat,', 10),
    ('total', 45),
    ('0.1', 260),
    ('g', 284),
  ]),
  row(140, [('Carbohydrate', 10), ('10.6', 260), ('g', 291)]),
  row(160, [
    ('-', 20),
    ('sugars', 30),
    ('10.6', 260),
    ('g', 291),
  ]),
  row(180, [('Sodium', 10), ('8', 260), ('mg', 270)]),
]);

/// (e) A US FDA Nutrition Facts panel: one column plus % Daily Value, a
/// bare "Calories" number, and the "Includes 10g Added Sugars" row whose
/// number sits in the middle of its own name.
OcrResult usFdaPanel() => panelOf([
  row(0, [('Nutrition', 10), ('Facts', 95)]),
  row(20, [
    ('8', 10),
    ('servings', 24),
    ('per', 85),
    ('container', 110),
  ]),
  row(40, [
    ('Serving', 10),
    ('size', 65),
    ('2/3', 100),
    ('cup', 126),
    ('(55g)', 152),
  ]),
  row(60, [('Amount', 10), ('per', 60), ('serving', 85)]),
  row(80, [('Calories', 10), ('230', 250)]),
  row(100, [('%', 300), ('Daily', 312), ('Value*', 350)]),
  row(120, [
    ('Total', 10),
    ('Fat', 48),
    ('8g', 250),
    ('10%', 330),
  ]),
  row(140, [
    ('Saturated', 20),
    ('Fat', 90),
    ('1g', 250),
    ('5%', 330),
  ]),
  row(160, [('Trans', 20), ('Fat', 60), ('0g', 250)]),
  row(180, [('Cholesterol', 10), ('0mg', 250), ('0%', 330)]),
  row(200, [('Sodium', 10), ('160mg', 250), ('7%', 330)]),
  row(220, [
    ('Total', 10),
    ('Carbohydrate', 48),
    ('37g', 250),
    ('13%', 330),
  ]),
  row(240, [
    ('Dietary', 20),
    ('Fiber', 75),
    ('4g', 250),
    ('14%', 330),
  ]),
  row(260, [('Total', 20), ('Sugars', 58), ('12g', 250)]),
  row(280, [
    ('Includes', 20),
    ('10g', 80),
    ('Added', 105),
    ('Sugars', 145),
    ('20%', 330),
  ]),
  row(300, [('Protein', 10), ('3g', 250)]),
  row(320, [
    ('Vitamin', 10),
    ('D', 62),
    ('2mcg', 250),
    ('10%', 330),
  ]),
  row(340, [('Calcium', 10), ('260mg', 250), ('20%', 330)]),
  row(360, [('Iron', 10), ('8mg', 250), ('45%', 330)]),
  row(380, [('Potassium', 10), ('235mg', 250), ('6%', 330)]),
]);

/// (f) EU/UK "Typical values", per 100 g only, with "of which" sub-rows
/// and salt rather than sodium.
OcrResult euUkPanel() => panelOf([
  row(0, [
    ('Typical', 10),
    ('values', 70),
    ('per', 250),
    ('100g', 275),
  ]),
  row(20, [
    ('Energy', 10),
    ('1046kJ', 250),
    ('/', 300),
    ('250kcal', 312),
  ]),
  row(40, [('Fat', 10), ('12.5g', 250)]),
  row(60, [
    ('of', 20),
    ('which', 40),
    ('saturates', 90),
    ('3.1g', 250),
  ]),
  row(80, [('Carbohydrate', 10), ('62.4g', 250)]),
  row(100, [
    ('of', 20),
    ('which', 40),
    ('sugars', 90),
    ('5.2g', 250),
  ]),
  row(120, [('Fibre', 10), ('7.1g', 250)]),
  row(140, [('Protein', 10), ('11.3g', 250)]),
  row(160, [('Salt', 10), ('1.25g', 250)]),
]);

/// (g) Comma decimals, and a comma used as a thousands separator on the
/// same panel — the ambiguity the number parser has to resolve.
OcrResult commaDecimalPanel() => panelOf([
  row(0, [
    ('Typical', 10),
    ('values', 70),
    ('per', 250),
    ('100g', 275),
  ]),
  row(20, [('Energy', 10), ('1,046', 250), ('kJ', 288)]),
  row(40, [('Fat', 10), ('12,5', 250), ('g', 280)]),
  row(60, [('Protein', 10), ('5,2', 250), ('g', 272)]),
  row(80, [('Salt', 10), ('0,8', 250), ('g', 272)]),
]);

/// (h) Bounds and a stated zero: "<1g", "less than 0.5 g" split across
/// four elements, and "Nil".
OcrResult boundedValuePanel() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)]),
  row(40, [('Per', 250), ('Serving', 274)]),
  row(60, [('Energy', 10), ('620', 250), ('kJ', 273)]),
  row(80, [('Sugars', 10), ('<1g', 250)]),
  row(100, [
    ('Fat,', 10),
    ('total', 45),
    ('less', 250),
    ('than', 280),
    ('0.5', 312),
    ('g', 335),
  ]),
  row(120, [('Sodium', 10), ('Nil', 250)]),
]);

/// (i) Energy stated in kilojoules only — the calorie figure has to be
/// derived, and said so.
OcrResult kilojoulesOnlyPanel() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)]),
  row(60, [
    ('Per', 190),
    ('Serving', 214),
    ('Per', 310),
    ('100g', 333),
  ]),
  row(80, [
    ('Energy', 10),
    ('830', 200),
    ('kJ', 224),
    ('2770', 315),
    ('kJ', 346),
  ]),
  row(120, [
    ('Protein', 10),
    ('5.2', 200),
    ('g', 224),
    ('17.3', 315),
    ('g', 346),
  ]),
]);

/// (m) Two columns whose heading row could not be read at all — the
/// fallback that infers columns from where the numbers sit.
OcrResult headerlessTwoColumn() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)]),
  row(60, [('Qly', 190), ('Amt', 310)]),
  row(80, [
    ('Energy', 10),
    ('830', 200),
    ('kJ', 224),
    ('2770', 315),
    ('kJ', 346),
  ]),
  row(120, [
    ('Protein', 10),
    ('5.2', 200),
    ('g', 224),
    ('17.3', 315),
    ('g', 346),
  ]),
  row(140, [
    ('Fat,', 10),
    ('total', 45),
    ('10.2', 200),
    ('g', 229),
    ('34.0', 315),
    ('g', 346),
  ]),
]);

/// (k) Not a nutrition panel at all.
/// (k) A panel with numbers and **no cue to which standard it is** — a
/// tight crop that lost every heading. Readable; just unattributable.
OcrResult unattributablePanel() => panelOf([
  row(0, [('Energy', 10), ('830', 200), ('kJ', 224)]),
  row(20, [('Protein', 10), ('5.2', 200), ('g', 224)]),
  row(40, [
    ('Fat,', 10),
    ('total', 45),
    ('10.2', 200),
    ('g', 229),
  ]),
  row(60, [('Carbohydrate', 10), ('18.6', 200), ('g', 229)]),
]);

/// (l) An FSANZ panel that prints its energy as a bare "Calories 230" with
/// no unit — the case where the panel-wide "unlabelled energy is
/// kilojoules" default is wrong and the row's own name says so.
OcrResult fsanzBareCaloriesPanel() => panelOf([
  row(0, [('NUTRITION', 10), ('INFORMATION', 90)]),
  row(20, [
    ('Serving', 10),
    ('size:', 65),
    ('30g', 105),
  ]),
  row(40, [('Calories', 10), ('230', 200)]),
  row(60, [('Protein', 10), ('5.2', 200), ('g', 224)]),
  row(80, [
    ('Fat,', 10),
    ('total', 45),
    ('10.2', 200),
    ('g', 229),
  ]),
  row(100, [('Carbohydrate', 10), ('18.6', 200), ('g', 229)]),
]);

OcrResult receipt() => panelOf([
  row(0, [('WOOLWORTHS', 10), ('METRO', 90)]),
  row(20, [('MELBOURNE', 10), ('CENTRAL', 90)]),
  row(60, [('MILK', 10), ('2L', 60), ('3.90', 200)]),
  row(80, [('BREAD', 10), ('WHITE', 60), ('4.50', 200)]),
  row(100, [('BANANAS', 10), ('1.2', 80), ('kg', 100), ('4.68', 200)]),
  row(140, [('TOTAL', 10), ('13.08', 200)]),
  row(160, [('EFTPOS', 10), ('13.08', 200)]),
]);
