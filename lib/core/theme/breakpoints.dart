/// Material 3 window size classes, expressed as the single source of truth
/// for every responsive layout decision in the app. No other file should
/// hard-code a breakpoint width; import this instead.
enum WindowSize {
  /// < 600 logical pixels wide (phones in portrait).
  compact,

  /// 600 - 839 logical pixels wide (small tablets, phones in landscape).
  medium,

  /// 840 - 1199 logical pixels wide (large tablets, small desktop windows).
  expanded,

  /// >= 1200 logical pixels wide (desktop windows, large tablets landscape).
  large;

  /// Resolves the [WindowSize] for a given layout [width] in logical pixels.
  factory WindowSize.fromWidth(double width) {
    if (width >= Breakpoints.large) {
      return WindowSize.large;
    }
    if (width >= Breakpoints.expanded) {
      return WindowSize.expanded;
    }
    if (width >= Breakpoints.medium) {
      return WindowSize.medium;
    }
    return WindowSize.compact;
  }

  bool get isCompact => this == WindowSize.compact;

  bool get isAtLeastMedium => index >= WindowSize.medium.index;

  bool get isAtLeastExpanded => index >= WindowSize.expanded.index;

  bool get isAtLeastLarge => index >= WindowSize.large.index;
}

/// The raw breakpoint widths (logical pixels) backing [WindowSize].
abstract final class Breakpoints {
  /// Lower bound of the medium window size class.
  static const double medium = 600;

  /// Lower bound of the expanded window size class.
  static const double expanded = 840;

  /// Lower bound of the large window size class.
  static const double large = 1200;
}
