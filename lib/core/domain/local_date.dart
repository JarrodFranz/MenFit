/// An immutable calendar date (year/month/day), with no time-of-day or
/// timezone component.
///
/// Cycle records and streak evaluation operate on **user-local calendar
/// days**, not instants (see
/// `knowledge/architecture/data_architecture.md`'s "Calendar-day semantics"
/// section): a period that starts "today" starts today regardless of
/// timezone travel, and days are compared as dates, never converted through
/// UTC instants. [LocalDate] is the shared value type for that concept —
/// truly shared across features (cycle today, streaks next), so it lives in
/// `core/domain/` per `architecture_overview.md` rule 3.
///
/// Internally represented via a UTC-noon-anchored [DateTime] so that
/// [difference] can be computed with plain millisecond math without ever
/// crossing a DST transition — the anchor never observes DST because UTC
/// has none, and noon keeps arithmetic well clear of any local-time
/// boundary a caller might separately reason about.
class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day)
    : _anchor = DateTime.utc(year, month, day, 12) {
    assert(
      _anchor.year == year && _anchor.month == month && _anchor.day == day,
      // S3: no interpolated field values here even though this is
      // debug-only - keep the same "never put a period date in a message"
      // habit as `LocalDate.parse` and every repository in this codebase.
      'LocalDate fields do not form a valid calendar date - check for a '
      'day-of-month or month overflow (e.g. a February 30th).',
    );
  }

  LocalDate._fromAnchor(DateTime anchor)
    : year = anchor.year,
      month = anchor.month,
      day = anchor.day,
      _anchor = anchor;

  /// Today's date, read from [clock] (defaults to the real system clock).
  /// Pass an injected [clock] in tests instead of depending on the real
  /// current time.
  factory LocalDate.today({DateTime Function()? clock}) {
    final now = (clock ?? DateTime.now)();
    return LocalDate.fromDateTime(now);
  }

  /// Extracts the local calendar-date fields from [dateTime] — if
  /// [dateTime] is a UTC instant, convert it to local time first with
  /// `.toLocal()` before calling this, since this reads whatever
  /// year/month/day are already on the given [DateTime] verbatim.
  factory LocalDate.fromDateTime(DateTime dateTime) {
    return LocalDate(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Parses an ISO-8601 date string (`YYYY-MM-DD`). Throws [FormatException]
  /// if [value] isn't in that shape, or if it's shaped correctly but doesn't
  /// name a real calendar date (e.g. `2026-02-30`).
  factory LocalDate.parse(String value) {
    final match = _isoPattern.firstMatch(value);
    if (match == null) {
      // S3 (`knowledge/engineering/security_and_privacy.md`): [value] may
      // be a period date - a static message only, never `'...: $value'`.
      // Cycle dates must never enter an exception string that could reach
      // a crash log.
      throw const FormatException(_notIsoShapedMessage);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final anchor = DateTime.utc(year, month, day, 12);
    if (anchor.year != year || anchor.month != month || anchor.day != day) {
      // Same S3 reasoning as above - e.g. `2026-13-05` or `2026-02-30` is
      // ISO-*shaped* but not a real date; DateTime would otherwise silently
      // normalise it (rolling into the next month/year) instead of
      // rejecting it.
      throw const FormatException(_notCalendarDateMessage);
    }
    return LocalDate(year, month, day);
  }

  static final RegExp _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static const String _notIsoShapedMessage =
      'Not a valid ISO date (expected YYYY-MM-DD).';
  static const String _notCalendarDateMessage =
      "Not a valid calendar date (that day doesn't exist in that month).";

  final int year;
  final int month;
  final int day;

  /// UTC-noon anchor for this date, used only for internal arithmetic.
  final DateTime _anchor;

  /// The ISO-8601 date string form (`YYYY-MM-DD`), zero-padded.
  String toIso() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool isBefore(LocalDate other) => _anchor.isBefore(other._anchor);

  bool isAfter(LocalDate other) => _anchor.isAfter(other._anchor);

  @override
  int compareTo(LocalDate other) => _anchor.compareTo(other._anchor);

  /// Returns the date [n] days after this one (negative [n] goes
  /// backwards). Pure calendar arithmetic via the UTC-noon anchor, so it's
  /// unaffected by DST — the result is always exactly [n] calendar days
  /// away, never off by an hour.
  LocalDate addDays(int n) {
    return LocalDate._fromAnchor(_anchor.add(Duration(days: n)));
  }

  /// The number of days from this date to [other] (positive if [other] is
  /// later). DST-safe: both endpoints are UTC-noon anchors, so the
  /// difference in milliseconds is always an exact multiple of a day with
  /// no fractional-hour drift from a DST transition in between.
  int difference(LocalDate other) {
    return other._anchor.difference(_anchor).inDays;
  }

  @override
  // This class has no setters and every field is final - it's immutable in
  // substance, just not annotated `@immutable` (that annotation lives in
  // `package:meta`, and `domain/` code stays dependency-free per
  // `architecture_overview.md`'s layer rules), hence the lint suppression.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    return other is LocalDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
