/// Every string the label parser can put in front of a user.
///
/// Copy rules, the same ones `nutrition_validation.dart` and
/// `barcode.dart` already hold, restated as a constraint on this file:
///
/// 1. **No recognised value is ever interpolated into a warning.** What a
///    panel says is data about a food a specific person is about to eat,
///    and warnings end up in test output and crash text. Every message
///    here is a fixed string.
/// 2. Plain and non-blaming. A misread label is a misread label — the
///    photo was fine, the parser is a heuristic.
/// 3. Each says what to check, because every one of these ends up beside
///    a field the user is about to correct.
library;

const warnCouldNotRead =
    "This photo couldn't be read as a nutrition panel. You can enter the "
    'details yourself.';

const warnNoPanelFound =
    'No nutrition panel was found in this photo. Try again, or enter the '
    'details yourself.';

const warnUnknownFormat =
    "This doesn't look like a nutrition panel we recognise, so please "
    'check every value.';

const warnColumnsAssumed =
    "The column headings weren't recognised. The left column has been read "
    'as per serving and the right as per 100 g — check which is which.';

const warnBasisUnclear =
    "It isn't clear whether these numbers are per serving or per 100 g. "
    'Check before saving.';

const warnPer100Millilitres =
    'This panel is per 100 mL. Millilitres are a volume, not a weight, so '
    "these numbers can't be turned into grams — set the serving yourself.";

const warnEnergyDerivedFromKilojoules =
    'Calories were worked out from the kilojoule figure rather than read '
    'off the panel.';

const warnEnergyFiguresDisagree =
    "The kilojoule and calorie figures don't agree with each other. Check "
    'both.';

const warnSodiumDerivedFromSalt =
    'Sodium was worked out from the salt figure. Check it.';

const warnLessThanValues =
    'Some values were printed as "less than" a figure. Those are read as '
    'half the stated limit.';

const warnTraceValues =
    'Some values were printed as a trace and have been read as zero.';

const warnRepairedDigits =
    'Some digits were unclear in the photo. Check the numbers carefully.';

const warnDuplicateValues =
    'A nutrient appeared more than once in the same column; the first '
    'reading was used.';

const warnImplausibleUnit =
    "A value was printed in a unit that doesn't fit its nutrient and has "
    'been left out.';
