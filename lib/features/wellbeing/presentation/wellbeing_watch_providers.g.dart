// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellbeing_watch_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the check-in logged for [day], if any. Used by the home
/// check-in card (today) and the check-in sheet (pre-filling an edit).

@ProviderFor(checkinForDay)
final checkinForDayProvider = CheckinForDayFamily._();

/// Watches the check-in logged for [day], if any. Used by the home
/// check-in card (today) and the check-in sheet (pre-filling an edit).

final class CheckinForDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyCheckin?>,
          DailyCheckin?,
          Stream<DailyCheckin?>
        >
    with $FutureModifier<DailyCheckin?>, $StreamProvider<DailyCheckin?> {
  /// Watches the check-in logged for [day], if any. Used by the home
  /// check-in card (today) and the check-in sheet (pre-filling an edit).
  CheckinForDayProvider._({
    required CheckinForDayFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'checkinForDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkinForDayHash();

  @override
  String toString() {
    return r'checkinForDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DailyCheckin?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DailyCheckin?> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return checkinForDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CheckinForDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkinForDayHash() => r'f783dc1e0d00a105e9f0d6ebba1b731524b530c4';

/// Watches the check-in logged for [day], if any. Used by the home
/// check-in card (today) and the check-in sheet (pre-filling an edit).

final class CheckinForDayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DailyCheckin?>, LocalDate> {
  CheckinForDayFamily._()
    : super(
        retry: null,
        name: r'checkinForDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches the check-in logged for [day], if any. Used by the home
  /// check-in card (today) and the check-in sheet (pre-filling an edit).

  CheckinForDayProvider call(LocalDate day) =>
      CheckinForDayProvider._(argument: day, from: this);

  @override
  String toString() => r'checkinForDayProvider';
}

/// Watches every flare logged on [day]. Used by the home check-in card
/// (today's flare chip) and the wellbeing history screen.

@ProviderFor(flaresOnDay)
final flaresOnDayProvider = FlaresOnDayFamily._();

/// Watches every flare logged on [day]. Used by the home check-in card
/// (today's flare chip) and the wellbeing history screen.

final class FlaresOnDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlareEvent>>,
          List<FlareEvent>,
          Stream<List<FlareEvent>>
        >
    with $FutureModifier<List<FlareEvent>>, $StreamProvider<List<FlareEvent>> {
  /// Watches every flare logged on [day]. Used by the home check-in card
  /// (today's flare chip) and the wellbeing history screen.
  FlaresOnDayProvider._({
    required FlaresOnDayFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'flaresOnDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flaresOnDayHash();

  @override
  String toString() {
    return r'flaresOnDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FlareEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FlareEvent>> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return flaresOnDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FlaresOnDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flaresOnDayHash() => r'436d8256beb39e7694f726ae19cf047d75f39438';

/// Watches every flare logged on [day]. Used by the home check-in card
/// (today's flare chip) and the wellbeing history screen.

final class FlaresOnDayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FlareEvent>>, LocalDate> {
  FlaresOnDayFamily._()
    : super(
        retry: null,
        name: r'flaresOnDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every flare logged on [day]. Used by the home check-in card
  /// (today's flare chip) and the wellbeing history screen.

  FlaresOnDayProvider call(LocalDate day) =>
      FlaresOnDayProvider._(argument: day, from: this);

  @override
  String toString() => r'flaresOnDayProvider';
}

/// Watches every check-in within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.

@ProviderFor(recentCheckins)
final recentCheckinsProvider = RecentCheckinsFamily._();

/// Watches every check-in within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.

final class RecentCheckinsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyCheckin>>,
          List<DailyCheckin>,
          Stream<List<DailyCheckin>>
        >
    with
        $FutureModifier<List<DailyCheckin>>,
        $StreamProvider<List<DailyCheckin>> {
  /// Watches every check-in within the last [days] days (inclusive of
  /// today). Used by the wellbeing history screen.
  RecentCheckinsProvider._({
    required RecentCheckinsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'recentCheckinsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentCheckinsHash();

  @override
  String toString() {
    return r'recentCheckinsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailyCheckin>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyCheckin>> create(Ref ref) {
    final argument = this.argument as int;
    return recentCheckins(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentCheckinsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentCheckinsHash() => r'94cd9432c2d49e7cdf9b31fd51a867a9653229f0';

/// Watches every check-in within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.

final class RecentCheckinsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<DailyCheckin>>, int> {
  RecentCheckinsFamily._()
    : super(
        retry: null,
        name: r'recentCheckinsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every check-in within the last [days] days (inclusive of
  /// today). Used by the wellbeing history screen.

  RecentCheckinsProvider call(int days) =>
      RecentCheckinsProvider._(argument: days, from: this);

  @override
  String toString() => r'recentCheckinsProvider';
}

/// Watches every flare logged within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.

@ProviderFor(recentFlares)
final recentFlaresProvider = RecentFlaresFamily._();

/// Watches every flare logged within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.

final class RecentFlaresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlareEvent>>,
          List<FlareEvent>,
          Stream<List<FlareEvent>>
        >
    with $FutureModifier<List<FlareEvent>>, $StreamProvider<List<FlareEvent>> {
  /// Watches every flare logged within the last [days] days (inclusive of
  /// today). Used by the wellbeing history screen.
  RecentFlaresProvider._({
    required RecentFlaresFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'recentFlaresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentFlaresHash();

  @override
  String toString() {
    return r'recentFlaresProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FlareEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FlareEvent>> create(Ref ref) {
    final argument = this.argument as int;
    return recentFlares(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentFlaresProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentFlaresHash() => r'18d2747f40e12367c124accef36a57f75bc1dfcb';

/// Watches every flare logged within the last [days] days (inclusive of
/// today). Used by the wellbeing history screen.

final class RecentFlaresFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FlareEvent>>, int> {
  RecentFlaresFamily._()
    : super(
        retry: null,
        name: r'recentFlaresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every flare logged within the last [days] days (inclusive of
  /// today). Used by the wellbeing history screen.

  RecentFlaresProvider call(int days) =>
      RecentFlaresProvider._(argument: days, from: this);

  @override
  String toString() => r'recentFlaresProvider';
}

/// Watches every check-in in the inclusive range `[from, to]`, oldest
/// first. Used by the wellbeing calendar, which needs whichever month is
/// on screen rather than a window ending today.

@ProviderFor(checkinsForRange)
final checkinsForRangeProvider = CheckinsForRangeFamily._();

/// Watches every check-in in the inclusive range `[from, to]`, oldest
/// first. Used by the wellbeing calendar, which needs whichever month is
/// on screen rather than a window ending today.

final class CheckinsForRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyCheckin>>,
          List<DailyCheckin>,
          Stream<List<DailyCheckin>>
        >
    with
        $FutureModifier<List<DailyCheckin>>,
        $StreamProvider<List<DailyCheckin>> {
  /// Watches every check-in in the inclusive range `[from, to]`, oldest
  /// first. Used by the wellbeing calendar, which needs whichever month is
  /// on screen rather than a window ending today.
  CheckinsForRangeProvider._({
    required CheckinsForRangeFamily super.from,
    required (LocalDate, LocalDate) super.argument,
  }) : super(
         retry: null,
         name: r'checkinsForRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkinsForRangeHash();

  @override
  String toString() {
    return r'checkinsForRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailyCheckin>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyCheckin>> create(Ref ref) {
    final argument = this.argument as (LocalDate, LocalDate);
    return checkinsForRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CheckinsForRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkinsForRangeHash() => r'68d0bb96cc239f8b6f6e025f1f13088aaeaf5169';

/// Watches every check-in in the inclusive range `[from, to]`, oldest
/// first. Used by the wellbeing calendar, which needs whichever month is
/// on screen rather than a window ending today.

final class CheckinsForRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<DailyCheckin>>,
          (LocalDate, LocalDate)
        > {
  CheckinsForRangeFamily._()
    : super(
        retry: null,
        name: r'checkinsForRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every check-in in the inclusive range `[from, to]`, oldest
  /// first. Used by the wellbeing calendar, which needs whichever month is
  /// on screen rather than a window ending today.

  CheckinsForRangeProvider call(LocalDate from, LocalDate to) =>
      CheckinsForRangeProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'checkinsForRangeProvider';
}

/// Watches every flare overlapping the inclusive range `[from, to]`,
/// oldest start day first. Used by the wellbeing calendar.

@ProviderFor(flaresForRange)
final flaresForRangeProvider = FlaresForRangeFamily._();

/// Watches every flare overlapping the inclusive range `[from, to]`,
/// oldest start day first. Used by the wellbeing calendar.

final class FlaresForRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlareEvent>>,
          List<FlareEvent>,
          Stream<List<FlareEvent>>
        >
    with $FutureModifier<List<FlareEvent>>, $StreamProvider<List<FlareEvent>> {
  /// Watches every flare overlapping the inclusive range `[from, to]`,
  /// oldest start day first. Used by the wellbeing calendar.
  FlaresForRangeProvider._({
    required FlaresForRangeFamily super.from,
    required (LocalDate, LocalDate) super.argument,
  }) : super(
         retry: null,
         name: r'flaresForRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flaresForRangeHash();

  @override
  String toString() {
    return r'flaresForRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<FlareEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FlareEvent>> create(Ref ref) {
    final argument = this.argument as (LocalDate, LocalDate);
    return flaresForRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FlaresForRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flaresForRangeHash() => r'7129c42f2f57f164c6126cba0aebe012d98f757d';

/// Watches every flare overlapping the inclusive range `[from, to]`,
/// oldest start day first. Used by the wellbeing calendar.

final class FlaresForRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<FlareEvent>>,
          (LocalDate, LocalDate)
        > {
  FlaresForRangeFamily._()
    : super(
        retry: null,
        name: r'flaresForRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every flare overlapping the inclusive range `[from, to]`,
  /// oldest start day first. Used by the wellbeing calendar.

  FlaresForRangeProvider call(LocalDate from, LocalDate to) =>
      FlaresForRangeProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'flaresForRangeProvider';
}

/// Watches every event logged on [day]. Used by day details and sheets.

@ProviderFor(eventsOnDay)
final eventsOnDayProvider = EventsOnDayFamily._();

/// Watches every event logged on [day]. Used by day details and sheets.

final class EventsOnDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WellbeingEvent>>,
          List<WellbeingEvent>,
          Stream<List<WellbeingEvent>>
        >
    with
        $FutureModifier<List<WellbeingEvent>>,
        $StreamProvider<List<WellbeingEvent>> {
  /// Watches every event logged on [day]. Used by day details and sheets.
  EventsOnDayProvider._({
    required EventsOnDayFamily super.from,
    required LocalDate super.argument,
  }) : super(
         retry: null,
         name: r'eventsOnDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsOnDayHash();

  @override
  String toString() {
    return r'eventsOnDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<WellbeingEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WellbeingEvent>> create(Ref ref) {
    final argument = this.argument as LocalDate;
    return eventsOnDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsOnDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsOnDayHash() => r'4dab483ac13eb46a4015e5ff3589b40ff26224fc';

/// Watches every event logged on [day]. Used by day details and sheets.

final class EventsOnDayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<WellbeingEvent>>, LocalDate> {
  EventsOnDayFamily._()
    : super(
        retry: null,
        name: r'eventsOnDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every event logged on [day]. Used by day details and sheets.

  EventsOnDayProvider call(LocalDate day) =>
      EventsOnDayProvider._(argument: day, from: this);

  @override
  String toString() => r'eventsOnDayProvider';
}

/// Watches every event in the inclusive range `[from, to]`.
/// Used by calendars to render event glyphs.

@ProviderFor(eventsForRange)
final eventsForRangeProvider = EventsForRangeFamily._();

/// Watches every event in the inclusive range `[from, to]`.
/// Used by calendars to render event glyphs.

final class EventsForRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WellbeingEvent>>,
          List<WellbeingEvent>,
          Stream<List<WellbeingEvent>>
        >
    with
        $FutureModifier<List<WellbeingEvent>>,
        $StreamProvider<List<WellbeingEvent>> {
  /// Watches every event in the inclusive range `[from, to]`.
  /// Used by calendars to render event glyphs.
  EventsForRangeProvider._({
    required EventsForRangeFamily super.from,
    required (LocalDate, LocalDate) super.argument,
  }) : super(
         retry: null,
         name: r'eventsForRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsForRangeHash();

  @override
  String toString() {
    return r'eventsForRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<WellbeingEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WellbeingEvent>> create(Ref ref) {
    final argument = this.argument as (LocalDate, LocalDate);
    return eventsForRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsForRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsForRangeHash() => r'b981cde3b74c4b13eb399170bc22f09beed94bc7';

/// Watches every event in the inclusive range `[from, to]`.
/// Used by calendars to render event glyphs.

final class EventsForRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<WellbeingEvent>>,
          (LocalDate, LocalDate)
        > {
  EventsForRangeFamily._()
    : super(
        retry: null,
        name: r'eventsForRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches every event in the inclusive range `[from, to]`.
  /// Used by calendars to render event glyphs.

  EventsForRangeProvider call(LocalDate from, LocalDate to) =>
      EventsForRangeProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'eventsForRangeProvider';
}
