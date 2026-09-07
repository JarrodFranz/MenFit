/// Robust summary statistics for the insights engine.
///
/// Everything here is deliberately **rank- or median-based**. The inputs
/// are a handful of self-logged sessions, where one 21 km long run or one
/// mis-typed 500 kg lift can be an order of magnitude away from the rest.
/// A mean would let that single day decide what the app tells the user
/// about their own body; a median or a rank statistic cannot.
library;

/// The median of [values].
///
/// Returns `null` for an empty list — there is no median of nothing, and
/// returning 0 would silently become "their output was zero".
double? median(List<double> values) {
  if (values.isEmpty) return null;
  final sorted = List<double>.of(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}

/// The symmetrically trimmed mean of [values], discarding [proportion] of
/// the observations from each tail.
///
/// Offered alongside [median] for callers that want to keep more of the
/// distribution's shape than the midpoint while still refusing to let the
/// extremes vote. Never trims away everything: with small samples it
/// falls back to trimming fewer (or zero) observations, so the result is
/// always defined for a non-empty list.
double? trimmedMean(List<double> values, {double proportion = 0.1}) {
  if (values.isEmpty) return null;
  final sorted = List<double>.of(values)..sort();
  var cut = (sorted.length * proportion).floor();
  while (sorted.length - 2 * cut < 1 && cut > 0) {
    cut--;
  }
  final kept = sorted.sublist(cut, sorted.length - cut);
  final sum = kept.fold<double>(0, (total, value) => total + value);
  return sum / kept.length;
}

/// Cliff's delta between [a] and [b]: the probability that a value drawn
/// from [a] exceeds one drawn from [b], minus the probability of the
/// reverse.
///
/// Ranges from -1 (every value in [a] is below every value in [b]) through
/// 0 (complete overlap) to +1. It reads only the *ordering* of the two
/// samples, so an outlier can move it by at most one pair's worth — which
/// is exactly the property this engine needs from an effect size.
///
/// Returns `null` when either sample is empty.
double? cliffsDelta(List<double> a, List<double> b) {
  if (a.isEmpty || b.isEmpty) return null;
  var greater = 0;
  var lesser = 0;
  for (final left in a) {
    for (final right in b) {
      if (left > right) {
        greater++;
      } else if (left < right) {
        lesser++;
      }
    }
  }
  return (greater - lesser) / (a.length * b.length);
}

/// The difference between [higher] and [lower] as a fraction of [lower].
///
/// Returns `null` when [lower] is not strictly positive: a relative
/// difference against zero is undefined, and reporting it as "infinitely
/// more" would be a claim the data cannot support.
double? relativeDifference({required double higher, required double lower}) {
  if (lower <= 0) return null;
  return (higher - lower) / lower;
}
