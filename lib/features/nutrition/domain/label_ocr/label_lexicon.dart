/// The nutrient-name dictionary and the fuzzy matching around it.
///
/// Two normalisations live here and they treat OCR confusions
/// differently, which is the non-obvious part:
///
/// - [normaliseLabelText] is for nutrient names, which are all letters, so
///   stray digits are pushed back to letters (`S0dium` → `sodium`) and
///   digits are then dropped entirely.
/// - [normaliseHeaderText] is for column headings, which legitimately mix
///   letters and digits, so neither direction is safe: it folds each
///   ambiguous glyph onto one representative and must be applied to both
///   sides of a comparison.
///
/// Run the label one over a heading and `per 100 g` becomes `perg`.
library;

/// A nutrient row the parser knows how to read.
enum LabelField {
  energy,
  protein,
  fat,
  saturatedFat,
  transFat,
  carbs,
  sugars,
  addedSugars,
  fiber,
  sodium,

  /// EU/UK panels print salt, not sodium. Converted on the way out — see
  /// `saltGramsToSodiumMg`.
  salt,
  potassium,
  cholesterol,
  calcium,
  iron,
  vitaminD,
  vitaminC,
}

/// A successful nutrient-name match.
class LabelFieldMatch {
  const LabelFieldMatch({
    required this.field,
    required this.distance,
    required this.synonym,
  });

  final LabelField field;

  /// Edit distance between the normalised printed text and [synonym].
  /// `0` is an exact match; the parser turns this into confidence.
  final int distance;

  final String synonym;
}

/// Prefixes that qualify a nutrient rather than naming a different one.
/// Stripped before matching so `Total Fat`, `- saturated`, `of which
/// sugars` and `Includes 10g Added Sugars` all reach the same entries.
const _strippablePrefixes = <String>[
  'ofwhich',
  'includes',
  'incl',
  'total',
  'dietary',
];

/// Nutrient names, already in normalised (compacted, lowercase) form.
///
/// Longer, more specific names matter: matching is whole-string, so
/// `saturatedfat` never collapses into `fat`.
const _synonyms = <LabelField, List<String>>{
  LabelField.energy: [
    'energy',
    'energykj',
    'energykcal',
    'energykjcal',
    'energyvalue',
    'calories',
    'calorie',
    'kilojoules',
    'kj',
  ],
  LabelField.protein: ['protein', 'proteins'],
  LabelField.fat: ['fat', 'fats', 'fattotal', 'fatstotal', 'lipids'],
  LabelField.saturatedFat: [
    'saturated',
    'saturates',
    'saturatedfat',
    'saturatedfats',
    'satfat',
    'saturatedfattyacids',
  ],
  LabelField.transFat: [
    'trans',
    'transfat',
    'transfats',
    'transfattyacids',
  ],
  LabelField.carbs: [
    'carbohydrate',
    'carbohydrates',
    'carbohydratetotal',
    'carbs',
  ],
  LabelField.sugars: ['sugars', 'sugar'],
  LabelField.addedSugars: [
    'addedsugars',
    'addedsugar',
    'sugarsadded',
  ],
  LabelField.fiber: [
    'fibre',
    'fiber',
    'dietaryfibre',
    'dietaryfiber',
  ],
  LabelField.sodium: ['sodium', 'sodiumna'],
  LabelField.salt: ['salt', 'saltequivalent'],
  LabelField.potassium: ['potassium', 'potassiumk'],
  LabelField.cholesterol: ['cholesterol'],
  LabelField.calcium: ['calcium'],
  LabelField.iron: ['iron'],
  // Digits do not survive `normaliseLabelText`, so no `vitamind3` entry —
  // "Vitamin D3" already normalises to `vitamind`.
  LabelField.vitaminD: ['vitamind', 'vitd'],
  LabelField.vitaminC: ['vitaminc', 'vitc', 'ascorbicacid'],
};

/// Normalise a printed nutrient name for matching.
///
/// Lowercases, repairs digit-for-letter OCR confusions, drops everything
/// that is not a letter, then strips qualifying prefixes.
String normaliseLabelText(String raw) {
  final lowered = raw.toLowerCase();
  final repaired = StringBuffer();
  for (final rune in lowered.runes) {
    final ch = String.fromCharCode(rune);
    switch (ch) {
      case '0':
        repaired.write('o');
      case '1':
      case '|':
        repaired.write('l');
      case '5':
        repaired.write('s');
      case '8':
        repaired.write('b');
      default:
        repaired.write(ch);
    }
  }
  var compact = repaired.toString().replaceAll(RegExp('[^a-z]'), '');
  // Strip repeatedly: "Total Dietary Fibre" carries two.
  var stripped = true;
  while (stripped) {
    stripped = false;
    for (final prefix in _strippablePrefixes) {
      if (compact.length > prefix.length && compact.startsWith(prefix)) {
        compact = compact.substring(prefix.length);
        stripped = true;
      }
    }
  }
  return compact;
}

/// Normalise a column heading for matching.
///
/// Headings mix letters and digits (`Per 100 g`), so neither repair
/// direction is right. Instead every ambiguous glyph is **folded onto one
/// representative**: `o/O/0` → `0`, `l/L/i/I/1/|` → `1`, `s/S/5` → `s`.
/// `Per 100g`, `Per lOOg` and `Per 1OO g` all become `per100g`.
///
/// This must be applied to **both sides** of a comparison — the heading
/// and the key it is tested against — which is why the key lists in
/// `label_columns.dart` are written in plain English and folded at match
/// time rather than pre-folded by hand.
String normaliseHeaderText(String raw) {
  final lowered = raw.toLowerCase();
  final folded = StringBuffer();
  for (final rune in lowered.runes) {
    final ch = String.fromCharCode(rune);
    switch (ch) {
      case 'o':
      case '0':
        folded.write('0');
      case 'l':
      case 'i':
      case '|':
      case '1':
        folded.write('1');
      case 's':
      case '5':
        folded.write('s');
      default:
        folded.write(ch);
    }
  }
  return folded.toString().replaceAll(RegExp('[^a-z0-9%]'), '');
}

/// How far a printed name may stray from a known one before the match is
/// rejected. Short names get no slack at all — `fat` and `salt` are three
/// and four characters, and one edit of slack would let them swallow each
/// other's neighbours.
int _toleranceFor(String synonym) {
  if (synonym.length < 5) return 0;
  if (synonym.length < 8) return 1;
  return 2;
}

/// The best nutrient match for a printed row label, or `null` if the text
/// is not a nutrient name we know.
///
/// [raw] is the *whole* leading text of the row; matching is whole-string
/// (not substring) so that `saturated fat` cannot resolve to `fat`.
LabelFieldMatch? matchLabelField(String raw) {
  final text = normaliseLabelText(raw);
  if (text.length < 2) return null;

  LabelFieldMatch? best;
  for (final entry in _synonyms.entries) {
    for (final synonym in entry.value) {
      // Cheap reject before the O(n*m) table: an edit distance is at
      // least the length difference.
      final lengthGap = (synonym.length - text.length).abs();
      if (lengthGap > _toleranceFor(synonym)) continue;
      final distance = levenshtein(text, synonym);
      if (distance > _toleranceFor(synonym)) continue;
      final isBetter =
          best == null ||
          distance < best.distance ||
          (distance == best.distance && synonym.length > best.synonym.length);
      if (isBetter) {
        best = LabelFieldMatch(
          field: entry.key,
          distance: distance,
          synonym: synonym,
        );
      }
    }
  }
  return best;
}

/// Plain Levenshtein edit distance, two-row implementation.
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 0; i < a.length; i++) {
    current[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final substitution = previous[j] + (a[i] == b[j] ? 0 : 1);
      final insertion = current[j] + 1;
      final deletion = previous[j + 1] + 1;
      var min = substitution;
      if (insertion < min) min = insertion;
      if (deletion < min) min = deletion;
      current[j + 1] = min;
    }
    final swap = previous;
    previous = current;
    current = swap;
  }
  return previous[b.length];
}

/// Sodium, in mg, from a salt figure in grams.
///
/// Salt is sodium chloride: 1 g of salt carries ~0.4 g (400 mg) of sodium,
/// the same 2.5 factor EU labelling uses in the other direction. An
/// approximation, and the parser always warns when it uses it.
double saltGramsToSodiumMg(double saltGrams) => saltGrams * 400;
