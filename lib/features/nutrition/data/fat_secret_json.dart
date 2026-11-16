/// Reading raw values out of FatSecret's XML-to-JSON responses.
///
/// Two coercions, shared by the search and detail mappers (which are
/// separate files as of 2026-09-08): every value in a FatSecret response can
/// arrive as a string, and blank strings stand in for absent fields.
library;

/// A string field, or `null` when absent **or** blank after trimming.
String? fatSecretText(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

/// A numeric field, which frequently arrives quoted (`"150"`, `"2.50"`).
///
/// A field that cannot be read is `null`, never `0` — a missing nutrient is
/// not a zero one (`domain/provider_food.dart`). Neither is a non-finite
/// value: `double.tryParse` accepts `"NaN"` and `"Infinity"`, which would
/// otherwise flow into nutrition maths, so they read as `null` too.
double? fatSecretNumber(dynamic value) {
  final number = switch (value) {
    final num n => n.toDouble(),
    final String s when s.trim().isNotEmpty => double.tryParse(s.trim()),
    _ => null,
  };
  return (number != null && number.isFinite) ? number : null;
}
