import 'dart:async';

import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/nutrition/data/online_lookup_notice_store.dart';
import 'package:menfit_app/features/nutrition/domain/fallback_food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_data_provider.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_region.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_day_screen_test.dart' show flushDriftTimers, scrollTo;

/// A [FoodDataProvider] that **records every call it receives**.
///
/// The recording is the point of most of this file: the wave's central
/// invariant is that a barcode already in the catalogue reaches nothing, and
/// that a declined notice sends nothing. Both are provable only by asserting
/// on what was *not* called.
class RecordingFoodDataProvider implements FoodDataProvider {
  RecordingFoodDataProvider({
    this.supportsTextSearch = true,
    this.product,
    this.hits = const [],
    this.barcodeError,
    this.foodSource = FoodSource.openFoodFacts,
  });

  @override
  FoodSource foodSource;

  /// Every barcode this provider was asked about, in order. Empty is the
  /// assertion in the local-first and declined-notice tests.
  final List<String> barcodeLookups = [];

  /// Every search hit whose full record was fetched (by its
  /// `providerFoodId`, via [fetchDetails]), in order. Kept apart from
  /// [barcodeLookups] because a hit's id is never a barcode (B23).
  final List<String> detailFetches = [];

  /// Every query this provider was asked to search, in order.
  final List<String> searches = [];

  /// The scope each call arrived with, in order — one list for both methods,
  /// because the point of recording them is that *nothing* reaches the
  /// provider under a scope the user did not choose.
  final List<FoodSearchScope> scopes = [];

  @override
  final bool supportsTextSearch;

  /// When set, [findByBarcode] parks on this until the test completes it.
  ///
  /// Everything else in this file is in-memory and finishes inside a single
  /// frame, so "while a lookup is in flight" is otherwise not a state a test
  /// can ever observe. This is the only way to hold the UI in that state
  /// deliberately rather than hoping to catch it.
  Completer<void>? gate;

  ProviderFood? product;
  List<ProviderFoodSummary> hits;
  Object? barcodeError;

  @override
  String get attributionName => 'Open Food Facts';

  @override
  String get attributionUrl => 'https://openfoodfacts.org';

  @override
  Uri productPageUrl(String barcode) =>
      Uri.parse('https://world.openfoodfacts.org/product/$barcode');

  @override
  FoodDataProvider providerFor(FoodSource source) => this;

  @override
  Future<ProviderFood?> findByBarcode(
    String barcode, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    barcodeLookups.add(barcode);
    scopes.add(scope);
    await gate?.future;
    final error = barcodeError;
    // Deliberately rethrown as-is so the controller sees exactly what the
    // real client would throw; the analyzer's `only_throw_errors` rule is
    // about production code, and every value assigned here is an
    // `AppException`.
    // ignore: only_throw_errors
    if (error != null) throw error;
    return product;
  }

  @override
  Future<ProviderFood?> fetchDetails(
    ProviderFoodSummary hit, {
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    detailFetches.add(hit.providerFoodId);
    scopes.add(scope);
    await gate?.future;
    final error = barcodeError;
    // Rethrown as-is, for the same reason as [findByBarcode]'s.
    // ignore: only_throw_errors
    if (error != null) throw error;
    return product;
  }

  @override
  Future<List<ProviderFoodSummary>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
    FoodSearchScope scope = FoodSearchScope.anywhereInEnglish,
  }) async {
    searches.add(query);
    scopes.add(scope);
    if (!supportsTextSearch) {
      throw const ValidationException(
        message: 'Food database text search is unavailable on this platform',
        userMessageKey: 'error.nutrition.searchUnsupported',
      );
    }
    return page == 1 ? hits : const [];
  }
}

/// A valid EAN-13 (check digit verified) — the code these tests type in.
const String _ean13 = '5000112637922';

/// The same string with its last digit changed, so the check digit fails.
const String _badCheckDigit = '5000112637923';

/// A real UPC-A as printed on a US packet (Honey Nut Cheerios) — 12 digits.
///
/// The genuine typed-vs-stored difference, and the one that actually
/// happens: `Barcode.digits` pads this to [_upcAEchoed], and Open Food
/// Facts echoes the same padded form back. Both halves were measured on
/// 2026-08-27 (`domain/barcode.dart` records the table). Used wherever a
/// test needs the stored code to differ from the typed one *without*
/// inventing provider behaviour.
const String _upcA = '016000275270';

/// What Open Food Facts echoes for [_upcA], and therefore what a saved row
/// is keyed on.
const String _upcAEchoed = '0016000275270';

/// A valid EAN-8. Open Food Facts leaves GTIN-8 codes at eight digits,
/// which is exactly what `domain/barcode.dart` does — measured, not
/// assumed — so against OFF this code and the echoed one agree.
const String _ean8 = '96385074';

/// The 13-digit code a **hypothetical** provider that zero-padded GTIN-8
/// would echo for [_ean8].
///
/// Open Food Facts does **not** do this. The fixture is deliberately a
/// provider whose normalisation disagrees with ours, because that is the
/// only way to exercise the drift guard in `BarcodeLookupController.lookUp`
/// — a guard that exists so the no-duplicate-rows invariant does not rest
/// on a third party's rules continuing to match ours, or on a second
/// provider behind the same port sharing them. Nothing keyed to this
/// constant is a claim about OFF.
const String _providerThatPadsGtin8 = '0000096385074';

void main() {
  final now = DateTime.utc(2026, 8, 27, 8);

  late db.AppDatabase database;
  late RecordingFoodDataProvider dataProvider;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    dataProvider = RecordingFoodDataProvider();
  });

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  ProviderFood providerFood({
    String? barcode = _ean13,
    String? providerFoodId,
    String name = 'Porridge oats',
    double? caloriesKcal = 372,
    double? proteinGrams = 11.6,
    double? carbsGrams = 60,
    double? fatGrams = 8.1,
    double? ironMg = 4.2,
    ServingBasis servingBasis = ServingBasis.statedPerServing,
    bool hasNoNutritionData = false,
    double? completeness = 0.8,
    FoodSource source = FoodSource.openFoodFacts,
  }) {
    return ProviderFood(
      source: source,
      providerFoodId: providerFoodId,
      barcode: barcode,
      name: name,
      servingDescription: '40 g',
      servingBasis: servingBasis,
      brand: 'Quaker',
      servingGrams: 40,
      caloriesKcal: caloriesKcal,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      ironMg: ironMg,
      completeness: completeness,
      hasNoNutritionData: hasNoNutritionData,
    );
  }

  /// Writes straight through the repository, before the app is pumped.
  Future<void> seedDatabase(
    Future<void> Function(ProviderContainer) body,
  ) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    await body(container);
  }

  Future<void> saveFood(Food food) => seedDatabase(
    (container) => container.read(nutritionRepositoryProvider).saveFood(food),
  );

  Future<void> saveGoals(NutritionGoals goals) => seedDatabase(
    (container) =>
        container.read(nutritionGoalsRepositoryProvider).saveGoals(goals),
  );

  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> preferences = const {},
    OnlineLookupNoticeStore? noticeStore,
    // Overrides `dataProvider` when a test needs something other than the
    // single-provider recorder — a `FallbackFoodDataProvider` composing two
    // of them, for the fallback-routing tests.
    FoodDataProvider? provider,
  }) async {
    tester.view
      ..physicalSize = const Size(500, 1600)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      ...preferences,
    });
    final prefs = await SharedPreferences.getInstance();
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
          foodDataProviderProvider.overrideWithValue(provider ?? dataProvider),
          if (noticeStore != null)
            onlineLookupNoticeStoreProvider.overrideWithValue(noticeStore),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Lets UI-triggered Drift writes finish outside the fake-async zone, then
  /// pumps for the resulting UI (central testing-pitfalls.md).
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addFood-breakfast')));
    await tester.pumpAndSettle();
  }

  Future<void> typeBarcode(WidgetTester tester, String code) async {
    await tester.tap(find.byKey(const Key('enterBarcodeAction')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('barcodeEntryField')), code);
    await tester.pump();
    await tester.tap(find.byKey(const Key('barcodeEntrySubmit')));
    await settleRealAsync(tester);
  }

  /// The text actually sitting in a form field, rather than the value that
  /// was passed to it — the difference matters, because `TextFormField`
  /// takes `initialValue` only when it has no controller and this asserts
  /// the seeded text really reached the field.
  String fieldText(WidgetTester tester, String key) {
    return tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
  }

  Future<void> acceptNotice(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onlineLookupNoticeAccept')));
    await settleRealAsync(tester);
  }

  testWidgets(
    'a barcode already in the catalogue goes straight to the log dialog and '
    'the provider is never called',
    (tester) async {
      await saveFood(
        Food(
          id: 'food-oats',
          name: 'Porridge oats',
          servingDescription: '1 cup (dry)',
          perServing: const NutritionFacts(
            caloriesKcal: 300,
            proteinGrams: 10,
            carbsGrams: 54,
            fatGrams: 5,
            ironMg: 3,
          ),
          barcode: _ean13,
          source: FoodSource.openFoodFacts,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await pumpApp(tester);
      await openPicker(tester);
      await typeBarcode(tester, _ean13);

      // Straight into the log dialog for the saved food...
      expect(find.text('Add to your day'), findsOneWidget);
      expect(find.text('Porridge oats'), findsWidgets);
      // ...with the notice never shown, because nothing was going out.
      expect(find.byKey(const Key('onlineLookupNoticeAccept')), findsNothing);
      // The invariant of the whole wave: zero requests for a food we know.
      expect(dataProvider.barcodeLookups, isEmpty);
      expect(dataProvider.searches, isEmpty);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a result saves under its OWN source, not the provider it came through '
    '— the fallback-provider case',
    (tester) async {
      // Simulates what `FallbackFoodDataProvider` does in production: the
      // composite provider's own `foodSource` (FatSecret, its primary) is
      // not the source a given RESULT carries when the fallback (Open Food
      // Facts) is the one that actually answered. The mapped `Food` must
      // record where the DATA came from, not which provider this app asked
      // first.
      dataProvider
        ..foodSource = FoodSource.fatSecret
        // Defaults to openFoodFacts — the point of the test.
        ..product = providerFood();
      await pumpApp(tester);
      await openPicker(tester);
      await typeBarcode(tester, _ean13);
      await acceptNotice(tester);

      expect(find.text('Add to your day'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await settleRealAsync(tester);

      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(1));
      expect(rows.single.source, 'open_food_facts');

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'the first-run notice is shown once, and backing out aborts the lookup '
    'without sending anything',
    (tester) async {
      dataProvider.product = providerFood();
      await pumpApp(tester);
      await openPicker(tester);

      // First attempt: the notice, then "Not now".
      await typeBarcode(tester, _ean13);
      expect(find.text('Looking a food up online'), findsOneWidget);
      expect(find.textContaining('Open Food Facts'), findsWidgets);
      expect(find.textContaining('No name, no account'), findsOneWidget);
      // The region and language setting rides along on every request from
      // 2026-09-03, and this dialog's whole promise is to list what goes
      // out — an undisclosed parameter would make the rest of it a claim
      // rather than a description (ADR 010's amendment).
      expect(
        find.textContaining('food database region and language'),
        findsOneWidget,
      );
      // The claim is bounded rather than absolute: an IP address goes with
      // any request, and `core/platform/barcode_scanning.dart` treats that
      // same disclosure as material enough to withhold a feature over. A
      // consent dialog cannot promise more than the code two layers down.
      expect(find.textContaining('internet address'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onlineLookupNoticeDecline')));
      await settleRealAsync(tester);

      // Declining is a real abort, not a delay.
      expect(dataProvider.barcodeLookups, isEmpty);
      expect(find.text('Check these details'), findsNothing);

      // Second attempt: still unacknowledged, so it asks again — then goes.
      await typeBarcode(tester, _ean13);
      expect(find.text('Looking a food up online'), findsOneWidget);
      await acceptNotice(tester);
      expect(dataProvider.barcodeLookups, [_ean13]);
      expect(find.text('Add to your day'), findsOneWidget);

      // Back to the picker, and a third lookup no longer asks.
      await tester.tap(find.text('Cancel'));
      await settleRealAsync(tester);
      await typeBarcode(tester, _ean13);
      expect(find.text('Looking a food up online'), findsNothing);
      expect(dataProvider.barcodeLookups, [_ean13, _ean13]);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'where text search is unsupported the online search affordance is absent, '
    'the screen says barcodes still work, and manual entry does',
    (tester) async {
      dataProvider = RecordingFoodDataProvider(
        supportsTextSearch: false,
        product: providerFood(),
      );
      await pumpApp(tester);
      await openPicker(tester);

      // Absent, not present-and-broken. No provider we ship answers false
      // here any more - web searches foods like every other platform, by a
      // different endpoint - but the capability is still on the port, so
      // the branch behind it stays covered.
      expect(find.byKey(const Key('onlineSearchButton')), findsNothing);
      await scrollTo(tester, find.textContaining("isn't available here"));
      expect(find.textContaining('Barcodes still are'), findsOneWidget);
      // ...and it says so without blaming the browser, which would be a
      // false explanation now.
      expect(find.textContaining('web browser'), findsNothing);

      // ...and the barcode path really is still there.
      expect(find.byKey(const Key('enterBarcodeAction')), findsOneWidget);
      await typeBarcode(tester, _ean13);
      await acceptNotice(tester);
      expect(dataProvider.barcodeLookups, [_ean13]);
      expect(find.text('Add to your day'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a provider record with missing macros seeds BLANK fields, never zeros, '
    'and cannot be saved until they are filled in',
    (tester) async {
      dataProvider.product = providerFood(
        proteinGrams: null,
        carbsGrams: null,
        fatGrams: null,
        ironMg: null,
        completeness: 0.2,
      );
      await pumpApp(tester);
      await openPicker(tester);
      await typeBarcode(tester, _ean13);
      await acceptNotice(tester);

      // What the database said is there...
      expect(fieldText(tester, 'foodNameField'), 'Porridge oats');
      expect(fieldText(tester, 'caloriesField'), '372');
      // ...and what it didn't say is EMPTY. A `0` here would turn someone
      // else's gap into a claim about the food.
      expect(fieldText(tester, 'proteinField'), '');
      expect(fieldText(tester, 'carbsField'), '');
      expect(fieldText(tester, 'fatField'), '');

      // The caution informs; it does not scold, and it does not hide the
      // result.
      expect(find.textContaining('nobody has filled them in'), findsOneWidget);

      await scrollTo(tester, find.text('Save food'));
      await tester.tap(find.text('Save food'));
      await settleRealAsync(tester);

      // Existing validation does the work: three required blanks, nothing
      // written.
      expect(find.text('Add a number here (0 is fine).'), findsNWidgets(3));
      expect(await database.select(database.foods).get(), isEmpty);

      // Optional nutrients in accordion are also empty
      await scrollTo(tester, find.byKey(const Key('additionalNutrientsTile')));
      await tester.tap(find.byKey(const Key('additionalNutrientsTile')));
      await settleRealAsync(tester);
      expect(fieldText(tester, 'ironField'), '');

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a saved provider food carries source open_food_facts and the '
    "provider's echoed barcode, not the one that was typed",
    (tester) async {
      // The real UPC-A case rather than an invented one: a US packet prints
      // twelve digits, and both our canonicalisation and Open Food Facts
      // answer with the thirteen-digit GTIN. Using a code OFF genuinely
      // normalises keeps the fixture a statement about the provider we
      // actually call.
      dataProvider.product = providerFood(barcode: _upcAEchoed);
      await pumpApp(tester);
      await openPicker(tester);
      await typeBarcode(tester, _upcA);
      await acceptNotice(tester);

      expect(find.text('Add to your day'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await settleRealAsync(tester);

      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(1));
      // Providers normalise codes server-side; the row has to key on what
      // will come back next time, not on what was typed.
      expect(rows.single.barcode, _upcAEchoed);
      expect(rows.single.barcode, isNot(_upcA));
      expect(rows.single.source, 'open_food_facts');

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a food saved from a provider record is found in the catalogue next '
    'time: one request in total, and one row',
    (tester) async {
      // The round trip the local-first rule is *for*. The first scan saves a
      // row keyed on the provider's echoed code; the second must find it,
      // which it can only do if what `lookUp` searches for and what the save
      // wrote are the same string.
      dataProvider.product = providerFood(barcode: _upcAEchoed);
      await pumpApp(tester);
      await openPicker(tester);

      await typeBarcode(tester, _upcA);
      await acceptNotice(tester);

      expect(find.text('Add to your day'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await settleRealAsync(tester);

      // Back out and open picker again
      await openPicker(tester);

      // The same packet, scanned a second time.
      await typeBarcode(tester, _upcA);

      expect(find.text('Add to your day'), findsOneWidget);
      expect(find.byType(FoodFormScreen), findsNothing);
      // The whole point: the catalogue answered, so there is still exactly
      // one request ever made for this product...
      expect(dataProvider.barcodeLookups, hasLength(1));
      // ...and exactly one row, rather than a second copy per scan.
      expect(await database.select(database.foods).get(), hasLength(1));

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'scanning a search-saved provider food reuses its edited local definition',
    (tester) async {
      await saveFood(
        Food(
          id: 'search-saved',
          name: 'My edited oats',
          servingDescription: 'My bowl',
          perServing: const NutritionFacts(caloriesKcal: 123),
          source: FoodSource.fatSecret,
          providerFoodId: '27365861',
          createdAt: now,
          updatedAt: now,
        ),
      );
      dataProvider.product = providerFood(
        source: FoodSource.fatSecret,
        providerFoodId: '27365861',
      );
      await pumpApp(tester);
      await openPicker(tester);
      await typeBarcode(tester, _ean13);
      await acceptNotice(tester);

      expect(dataProvider.barcodeLookups, [_ean13]);
      expect(find.text('Add to your day'), findsOneWidget);
      expect(find.text('My edited oats'), findsWidgets);
      expect(find.byType(FoodFormScreen), findsNothing);
      final saved = await database.select(database.foods).getSingle();
      expect(saved.id, 'search-saved');
      expect(saved.name, 'My edited oats');
      expect(saved.caloriesKcal, 123);
      expect(saved.barcode, isNull);
      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a provider whose canonical code differs from ours still resolves to '
    'the saved row instead of duplicating it',
    (tester) async {
      // Not Open Food Facts' behaviour — see [_providerThatPadsGtin8]. This
      // is the drift guard: the local-first check searches our canonical
      // spelling, the saved row is keyed on the provider's, and where those
      // disagree nothing else would ever match.
      dataProvider.product = providerFood(barcode: _providerThatPadsGtin8);
      await pumpApp(tester);
      await openPicker(tester);

      await typeBarcode(tester, _ean8);
      await acceptNotice(tester);
      expect(find.text('Add to your day'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await settleRealAsync(tester);

      await openPicker(tester);
      await typeBarcode(tester, _ean8);

      // The second fetch is unavoidable — our spelling misses the row — but
      // the echoed code it comes back with does not, so they land on the log
      // dialog for the food they already have.
      expect(dataProvider.barcodeLookups, [_ean8, _ean8]);
      expect(find.text('Add to your day'), findsOneWidget);
      expect(find.byType(FoodFormScreen), findsNothing);
      expect(await database.select(database.foods).get(), hasLength(1));

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'hide calorie numbers blanks calories in the online results list, while '
    'the review screen keeps its calorie field',
    (tester) async {
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: now,
          updatedAt: now,
          hideCalorieNumbers: true,
        ),
      );
      dataProvider
        ..hits = const [
          ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            providerFoodId: _ean13,
            barcode: _ean13,
            name: 'Porridge oats',
            brand: 'Quaker',
            caloriesKcal: 372,
            proteinGrams: 11.6,
            carbsGrams: 60,
            fatGrams: 8.1,
          ),
        ]
        ..product = providerFood();
      await pumpApp(tester);
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      // Typing alone sends nothing — the whole point of the explicit action.
      expect(dataProvider.searches, isEmpty);

      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);
      await acceptNotice(tester);
      expect(dataProvider.searches, ['oats']);

      // The picker is inside the preference's scope: no energy figure in
      // the online region either.
      await scrollTo(tester, find.text('Porridge oats · Quaker'));
      expect(find.textContaining('kcal'), findsNothing);
      expect(find.textContaining('Serving: 40 g'), findsWidgets);
      // The full record states these macros per 40 g serving; the search
      // index's per-100 g values must not replace that serving definition.
      expect(find.text('P 12 g · C 60 g · F 8 g'), findsOneWidget);

      // Picking a hit fetches the FULL record and opens log dialog
      await tester.tap(find.text('Porridge oats · Quaker'));
      await settleRealAsync(tester);
      expect(dataProvider.detailFetches, [_ean13, _ean13]);
      expect(dataProvider.barcodeLookups, isEmpty);

      // Tapping "Edit food details & macros" opens the review screen
      expect(find.text('Edit food details & macros'), findsOneWidget);
      await tester.tap(find.text('Edit food details & macros'));
      await settleRealAsync(tester);

      // The review screen is an input surface, and keeps its calorie field.
      expect(find.byKey(const Key('caloriesField')), findsOneWidget);
      expect(fieldText(tester, 'caloriesField'), '372');
      expect(fieldText(tester, 'ironField'), '4.2');

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'every request a search makes carries the chosen region and the device '
    'language',
    (tester) async {
      // The 2026-09-03 fix, end to end: an unfiltered search is how an
      // Australian user got Bulgarian products. The scope has to reach the
      // provider from the *preference*, not from a default buried in the
      // client, and it has to reach the enrichment fetches too — a page
      // resolved under one language and its records under another would
      // show two different names for the same food.
      dataProvider
        ..hits = const [
          ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            providerFoodId: _ean13,
            barcode: _ean13,
            name: 'Porridge oats',
          ),
        ]
        ..product = providerFood();
      await pumpApp(
        tester,
        preferences: {
          'nutrition_food_search_region': 'australia',
          'nutrition_online_lookup_notice_seen': true,
        },
      );
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);

      expect(dataProvider.searches, ['oats']);
      expect(dataProvider.scopes, isNotEmpty);
      expect(
        dataProvider.scopes.map((scope) => scope.region).toSet(),
        {FoodSearchRegion.australia},
      );
      expect(
        dataProvider.scopes.map((scope) => scope.languageCode).toSet(),
        {'en'},
      );
      // And the caption says which region those results are from, so an
      // empty set would be explainable rather than mysterious.
      expect(find.textContaining('Showing Australia results'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'picking a search hit for a food already in the catalogue logs the saved '
    'one instead of creating a duplicate row',
    (tester) async {
      // The same product, already saved — reached by scanning it once before.
      await saveFood(
        Food(
          id: 'food-oats',
          name: 'Porridge oats',
          servingDescription: '1 cup (dry)',
          perServing: const NutritionFacts(
            caloriesKcal: 300,
            proteinGrams: 10,
            carbsGrams: 54,
            fatGrams: 5,
            ironMg: 3,
          ),
          barcode: _ean13,
          source: FoodSource.openFoodFacts,
          createdAt: now,
          updatedAt: now,
        ),
      );
      dataProvider
        ..hits = const [
          ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            providerFoodId: _ean13,
            barcode: _ean13,
            name: 'Porridge oats',
            brand: 'Quaker',
            caloriesKcal: 372,
          ),
        ]
        ..product = providerFood();
      await pumpApp(tester);
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);
      await acceptNotice(tester);
      expect(dataProvider.searches, ['oats']);

      // Local edits include clearing the brand; select the online result
      // by identity instead of expecting the provider's stale brand.
      final onlineHit = find.byKey(const Key('online-openFoodFacts-$_ean13'));
      await scrollTo(tester, onlineHit);
      await tester.tap(onlineHit);
      await settleRealAsync(tester);

      // Straight to logging the food they already have - not through the
      // review screen again.
      expect(find.text('Add to your day'), findsOneWidget);
      expect(find.byType(FoodFormScreen), findsNothing);
      // No second request: the catalogue answered.
      expect(dataProvider.barcodeLookups, isEmpty);
      expect(dataProvider.detailFetches, isEmpty);
      // And, the actual defect this guards: still ONE row for this product.
      // Reaching a food by searching rather than by scanning must not change
      // what ends up stored.
      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'food-oats');

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a barcode the database has never heard of opens the review screen with '
    'the code pre-filled, and saving keeps it',
    (tester) async {
      dataProvider.product = null;
      await pumpApp(tester);
      await openPicker(tester);
      await typeBarcode(tester, _ean13);
      await acceptNotice(tester);

      expect(dataProvider.barcodeLookups, [_ean13]);
      // Framed as something to add, never as a failure.
      expect(find.text('Add this food'), findsOneWidget);
      expect(find.text(foodNotFoundOnlineCopy), findsOneWidget);
      // B23: the not-found copy names no food database — public UI is
      // unbranded (2026-09-29).
      expect(find.textContaining('FatSecret'), findsNothing);
      expect(find.textContaining('Open Food Facts'), findsNothing);
      // Nothing was attributed, because no provider data was used.
      expect(find.textContaining('Food data from'), findsNothing);

      Future<void> enter(String key, String value) async {
        await scrollTo(tester, find.byKey(Key(key)));
        await tester.enterText(find.byKey(Key(key)), value);
        await tester.pump();
      }

      await enter('foodNameField', 'Shop-brand oats');
      await enter('servingDescriptionField', '40 g');
      await enter('caloriesField', '150');
      await enter('proteinField', '5');
      await enter('carbsField', '27');
      await enter('fatField', '3');
      await scrollTo(tester, find.text('Save food'));
      await tester.tap(find.text('Save food'));
      await settleRealAsync(tester);

      final rows = await database.select(database.foods).get();
      expect(rows, hasLength(1));
      // The barcode came along, so the next scan resolves locally with no
      // request at all.
      expect(rows.single.barcode, _ean13);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'manual entry rejects a bad check digit, sends nothing, and never repeats '
    'the digits back',
    (tester) async {
      await pumpApp(tester);
      await openPicker(tester);

      await tester.tap(find.byKey(const Key('enterBarcodeAction')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('barcodeEntryField')),
        _badCheckDigit,
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('barcodeEntrySubmit')));
      await settleRealAsync(tester);

      expect(
        find.text(
          "That doesn't look like a product barcode — check the "
          'digits?',
        ),
        findsOneWidget,
      );
      // The dialog stays open, and nothing left the device.
      expect(find.byKey(const Key('barcodeEntryField')), findsOneWidget);
      expect(dataProvider.barcodeLookups, isEmpty);

      // S2: no message anywhere on screen repeats what was typed. (The
      // field itself holds it, which is why this looks at Text widgets
      // only.)
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .toList();
      expect(
        texts.where((text) => text.contains(_badCheckDigit)),
        isEmpty,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'tapping a second result while the first is still loading sends one '
    'request and opens one review screen',
    (tester) async {
      dataProvider
        ..hits = const [
          ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            providerFoodId: _ean13,
            barcode: _ean13,
            name: 'Porridge oats',
            brand: 'Quaker',
            caloriesKcal: 372,
          ),
          ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            providerFoodId: _upcAEchoed,
            barcode: _upcAEchoed,
            name: 'Honey Nut Cheerios',
            brand: 'Cheerios',
            caloriesKcal: 382,
          ),
        ]
        ..product = providerFood();
      // Notice already acknowledged: this test is about the tiles, and a
      // modal in the way would hide what they do.
      await pumpApp(
        tester,
        preferences: {'nutrition_online_lookup_notice_seen': true},
      );
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);
      expect(dataProvider.searches, ['oats']);

      // Hold the first lookup open. Without this the whole thing resolves
      // inside one frame — an in-memory database and a fake provider are far
      // faster than a real round trip — and "still loading" would never be a
      // state this test could actually see.
      final gate = Completer<void>();
      dataProvider.gate = gate;

      await scrollTo(tester, find.text('Porridge oats · Quaker'));
      await tester.tap(find.text('Porridge oats · Quaker'));
      // Deliberately no pump in between. A real double-tap lands inside one
      // frame, before any rebuild could have disabled anything, so the
      // controller's re-entrancy guard is the half that has to hold here.
      // Two requests would spend two of a documented 15/minute budget, and
      // the first completion would clear the busy flag while the second was
      // still out — leaving two review screens stacked up.
      await tester.tap(find.text('Honey Nut Cheerios · Cheerios'));
      await tester.pump();

      // Once a frame arrives mid-lookup the tiles are visibly out of action
      // too — the other half of the fix, and what stops the second tap ever
      // being made. This is also what catches the busy flag being dropped
      // during the consent step when no notice is actually shown.
      expect(
        tester
            .widget<ListTile>(
              find.widgetWithText(ListTile, 'Honey Nut Cheerios · Cheerios'),
            )
            .onTap,
        isNull,
        reason: 'tiles must not go live again while a lookup is in flight',
      );

      gate.complete();
      dataProvider.gate = null;
      await settleRealAsync(tester);

      expect(
        dataProvider.detailFetches,
        [_ean13, _upcAEchoed, _ean13],
      );
      expect(find.text('Add to your day'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'a FatSecret-sourced search hit is enriched and fully fetched via the '
    'FatSecret leg only — its food_id must never reach the Open Food Facts '
    'fallback as if it were a barcode',
    (tester) async {
      // Stands in for a FatSecret `food_id` (`data/fat_secret_service.dart`'s
      // doc on `ProviderFoodSummary.barcode`) — deliberately not shaped like
      // a barcode. Handing this to `FallbackFoodDataProvider.findByBarcode`
      // instead of the specific provider that produced it would pad it into
      // a barcode shape, miss on FatSecret, and fall back to Open Food Facts
      // under a code that means nothing there.
      const fatSecretFoodId = '445566';
      final fatSecret = RecordingFoodDataProvider(
        foodSource: FoodSource.fatSecret,
        hits: [
          const ProviderFoodSummary(
            source: FoodSource.fatSecret,
            providerFoodId: fatSecretFoodId,
            name: 'Porridge oats',
          ),
        ],
        product: providerFood(
          source: FoodSource.fatSecret,
          barcode: null,
          providerFoodId: fatSecretFoodId,
        ),
      );
      final openFoodFacts = RecordingFoodDataProvider();
      final composite = FallbackFoodDataProvider(
        primary: fatSecret,
        fallback: openFoodFacts,
      );

      await pumpApp(
        tester,
        provider: composite,
        preferences: {'nutrition_online_lookup_notice_seen': true},
      );
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);

      // Enrichment (`OnlineFoodSearchController._fetchPage`) resolved the
      // provider that produced this hit — the FatSecret leg — and never
      // touched the OFF one.
      expect(fatSecret.detailFetches, [fatSecretFoodId]);
      expect(fatSecret.barcodeLookups, isEmpty);
      expect(openFoodFacts.barcodeLookups, isEmpty);
      expect(openFoodFacts.detailFetches, isEmpty);

      // Picking the hit fetches the FULL record
      // (`BarcodeLookupController.fetchFullRecord`) — same requirement.
      // The tile now reads "Porridge oats · Quaker": the enrichment above
      // merged the brand off the fetched [providerFood] product.
      await scrollTo(tester, find.text('Porridge oats · Quaker'));
      await tester.tap(find.text('Porridge oats · Quaker'));
      await settleRealAsync(tester);

      expect(fatSecret.detailFetches, [fatSecretFoodId, fatSecretFoodId]);
      expect(fatSecret.barcodeLookups, isEmpty);
      expect(openFoodFacts.barcodeLookups, isEmpty);
      expect(openFoodFacts.detailFetches, isEmpty);
      expect(find.text('Add to your day'), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'B23: tapping a FatSecret hit whose id passes the EAN-8 check digit opens '
    'the food with its nutrition, never the not-found form, and the id never '
    'becomes a barcode',
    (tester) async {
      // The owner's real case: "crumbed hoki", FatSecret food 27365861. Those
      // eight digits pass the EAN-8 check digit, so the old pick path looked
      // the id up as a barcode, missed, and opened "Add this food" with the
      // id in the barcode field.
      const hokiId = '27365861';
      final fatSecret = RecordingFoodDataProvider(
        foodSource: FoodSource.fatSecret,
        hits: const [
          ProviderFoodSummary(
            source: FoodSource.fatSecret,
            providerFoodId: hokiId,
            name: 'New Zealand Wild Hoki',
            brand: "Talley's",
          ),
        ],
        product: const ProviderFood(
          source: FoodSource.fatSecret,
          barcode: null,
          providerFoodId: hokiId,
          name: 'New Zealand Wild Hoki',
          brand: "Talley's",
          servingDescription: '1 piece (120 g)',
          servingBasis: ServingBasis.statedPerServing,
          servingGrams: 120,
          caloriesKcal: 250,
          proteinGrams: 14,
          carbsGrams: 20,
          fatGrams: 12,
        ),
      );
      final openFoodFacts = RecordingFoodDataProvider();
      final composite = FallbackFoodDataProvider(
        primary: fatSecret,
        fallback: openFoodFacts,
      );

      await pumpApp(
        tester,
        provider: composite,
        preferences: {'nutrition_online_lookup_notice_seen': true},
      );
      await openPicker(tester);

      await tester.enterText(
        find.byKey(const Key('foodSearchField')),
        'crumbed hoki',
      );
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);

      await scrollTo(tester, find.text("New Zealand Wild Hoki · Talley's"));
      await tester.tap(find.text("New Zealand Wild Hoki · Talley's"));
      await settleRealAsync(tester);

      // Fetched by id, from FatSecret only — never as a barcode, anywhere.
      expect(fatSecret.detailFetches, [hokiId, hokiId]);
      expect(fatSecret.barcodeLookups, isEmpty);
      expect(openFoodFacts.barcodeLookups, isEmpty);
      expect(openFoodFacts.detailFetches, isEmpty);

      // The normal log flow for the food itself, not the not-found form.
      expect(find.text('Add to your day'), findsOneWidget);
      expect(find.text(foodNotFoundOnlineCopy), findsNothing);
      expect(find.text('Add this food'), findsNothing);

      // Its review screen carries the name and macros, and an EMPTY barcode
      // field: FatSecret stated no barcode, and an id is not one.
      await tester.tap(find.text('Edit food details & macros'));
      await settleRealAsync(tester);
      expect(fieldText(tester, 'foodNameField'), 'New Zealand Wild Hoki');
      expect(fieldText(tester, 'caloriesField'), '250');
      expect(fieldText(tester, 'proteinField'), '14');
      expect(fieldText(tester, 'carbsField'), '20');
      expect(fieldText(tester, 'fatField'), '12');
      await scrollTo(tester, find.byKey(const Key('foodBarcodeField')));
      expect(fieldText(tester, 'foodBarcodeField'), '');
      expect(find.text(hokiId), findsNothing);

      await flushDriftTimers(tester);
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );

  testWidgets(
    'B23: a hit whose provider DID state a real barcode carries it into the '
    'barcode field',
    (tester) async {
      dataProvider
        ..hits = const [
          ProviderFoodSummary(
            source: FoodSource.openFoodFacts,
            providerFoodId: _ean13,
            barcode: _ean13,
            name: 'Porridge oats',
            brand: 'Quaker',
          ),
        ]
        ..product = providerFood();
      await pumpApp(
        tester,
        preferences: {'nutrition_online_lookup_notice_seen': true},
      );
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);
      await scrollTo(tester, find.text('Porridge oats · Quaker'));
      await tester.tap(find.text('Porridge oats · Quaker'));
      await settleRealAsync(tester);

      expect(find.text('Add to your day'), findsOneWidget);
      await tester.tap(find.text('Edit food details & macros'));
      await settleRealAsync(tester);
      await scrollTo(tester, find.byKey(const Key('foodBarcodeField')));
      expect(fieldText(tester, 'foodBarcodeField'), _ean13);

      await flushDriftTimers(tester);
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );

  testWidgets(
    'a failed consent write on the search path says so instead of '
    'disappearing',
    (tester) async {
      // `search` is invoked as a `VoidCallback`, so nothing awaits its
      // future: an exception escaping it reaches PlatformDispatcher.onError
      // and the user sees no spinner, no message, and no state change — a
      // button that simply did nothing.
      await pumpApp(tester, noticeStore: _FailingNoticeStore());
      await openPicker(tester);

      await tester.enterText(find.byKey(const Key('foodSearchField')), 'oats');
      await tester.pump();
      await scrollTo(tester, find.byKey(const Key('onlineSearchButton')));
      await tester.tap(find.byKey(const Key('onlineSearchButton')));
      await settleRealAsync(tester);
      await acceptNotice(tester);

      expect(
        find.text('Something went wrong saving your data. Please try again.'),
        findsOneWidget,
      );
      // And the failure happened before anything went out.
      expect(dataProvider.searches, isEmpty);

      await flushDriftTimers(tester);
    },
  );
}

/// An [OnlineLookupNoticeStore] whose acknowledgement write fails, as the
/// real one does when `SharedPreferences.setBool` comes back `false`.
class _FailingNoticeStore implements OnlineLookupNoticeStore {
  @override
  bool hasSeenNotice() => false;

  @override
  Future<void> markNoticeSeen() async {
    throw const StorageException(
      message: 'Failed to persist the online lookup notice acknowledgement',
    );
  }

  @override
  Future<void> clear() async {}
}
