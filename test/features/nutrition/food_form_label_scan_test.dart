import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/ocr/ocr_text.dart';
import 'package:menfit_app/core/platform/ocr/label_capture.dart';
import 'package:menfit_app/core/platform/ocr/ocr_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_warnings.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/food_form_field.dart';

import '../../core/platform/ocr/fake_ocr_adapter.dart';
import 'label_ocr/label_fixtures.dart';

/// "Scan nutrition label" on the food form (ADR 012).
///
/// Everything here runs against a **fake camera and a fake recogniser**:
/// `LabelCaptureService` is built with a `pickPhoto` that hands back a path
/// and a `FakeOcrAdapter` that returns a transcribed panel from
/// `label_ocr/label_fixtures.dart`. No test may reach a real recogniser,
/// and none of them photographs anything.
///
/// The two properties worth having a widget test for at all — that a scan
/// **never** overwrites a value the user typed, and that a per-100 mL panel
/// cannot be saved as though it were per 100 g — are asserted through the
/// screen rather than the mapper, because both are only true if the screen
/// actually shows what the state holds.
void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Food? popped;

  /// A capture service that never opens a camera **and never reaches a
  /// plugin**: [result] is what the "recogniser" returns, [throwOnPick]
  /// what the "camera" throws instead of handing back a photo, and a null
  /// [result] with no throw is the user backing out.
  ///
  /// [lostPhotos] scripts the abandoned-capture sweep. Injecting it is not
  /// optional: the default sweeper calls `ImagePicker().retrieveLostData()`
  /// for real, which in a widget test means an unregistered plugin channel
  /// on every scan — a round trip through code under test has no business
  /// making, and one that made the camera-denied path stop surfacing its
  /// snack bar.
  LabelCaptureService fakeCapture({
    OcrResult? result,
    Object? throwOnPick,
    bool cancelled = false,
    List<String> lostPhotos = const [],
  }) => LabelCaptureService(
    adapter: FakeOcrAdapter(result: result),
    sweepLostPhotos: () async => lostPhotos,
    pickPhoto: () async {
      if (throwOnPick != null) {
        // Deliberately `Object`: on a device the camera throws whatever the
        // platform channel throws, and a fake restricted to well-behaved
        // exceptions could not reproduce a denied permission.
        // ignore: only_throw_errors
        throw throwOnPick;
      }
      // A path that does not exist: `deleteCapturedFile` is best-effort and
      // simply finds nothing to unlink, which is the same thing it does
      // after a real capture has already been read.
      return cancelled ? null : 'no-such-label-photo.jpg';
    },
  );

  Widget host(LabelCaptureService capture) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      labelCaptureServiceProvider.overrideWithValue(capture),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                popped = await Navigator.of(context).push<Food>(
                  MaterialPageRoute(
                    builder: (_) => const FoodFormScreen(),
                  ),
                );
              },
              child: const Text('open the form'),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> openForm(
    WidgetTester tester,
    LabelCaptureService capture,
  ) async {
    popped = null;
    tester.view
      ..physicalSize = const Size(800, 4200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(capture));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open the form'));
    await tester.pumpAndSettle();
  }

  /// Overrides the platform and clears it **inside the test body** —
  /// `flutter_test` asserts every foundation debug variable is unset at the
  /// end of the body, which runs before any tear-down. Same pattern as
  /// `food_form_barcode_test.dart`.
  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  Future<void> tapScan(WidgetTester tester) async {
    final button = find.byKey(const Key('foodLabelScanButton'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String value) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
  }

  /// Lets the real Drift futures inside `save` complete before pumping.
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  /// Switches the basis unit to grams, so the amount is a weight rather
  /// than a serving count — `_effectiveServing` only records
  /// `servingGrams` for a weight unit.
  Future<void> chooseGramsUnit(WidgetTester tester) async {
    final dropdown = find.byKey(const Key('basisUnitField'));
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('g').last);
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    final save = find.text('Save food');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await settleRealAsync(tester);
  }

  String fieldText(WidgetTester tester, String key) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  /// Dismisses whatever SnackBar is showing deterministically — its
  /// auto-dismiss timer lives in the real zone and would still be pending
  /// at teardown otherwise (idiom from `routes_flow_test.dart`).
  Future<void> clearSnackBars(WidgetTester tester) async {
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
        .clearSnackBars();
    await tester.pump();
  }

  /// Brings a field inside the collapsible "Additional nutrients" section
  /// into the widget tree.
  ///
  /// The form is a lazy `ListView`: a field far enough down has not been
  /// *built*, so `ensureVisible` cannot find it — it only scrolls to
  /// something that already exists. `scrollUntilVisible` drags until the
  /// finder matches, which is what a lazily built list needs and what makes
  /// this independent of how tall the form happens to be today.
  Future<void> scrollToOptionalNutrient(
    WidgetTester tester,
    String key,
  ) async {
    final scrollable = find.byType(Scrollable).first;
    final tile = find.byKey(const Key('additionalNutrientsTile'));
    await tester.scrollUntilVisible(tile, 300, scrollable: scrollable);
    await tester.pumpAndSettle();

    final field = find.byKey(Key(key));
    if (field.evaluate().isEmpty) {
      // Only when the section is genuinely still collapsed. A scan is meant
      // to reopen it, and tapping an already-open tile would close it.
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(field, 300, scrollable: scrollable);
    await tester.pumpAndSettle();
  }

  group('where the section appears', () {
    testWidgets('is offered on a phone', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(result: fsanzTwoColumn()));

        expect(find.byKey(const Key('foodLabelScanButton')), findsOneWidget);
        expect(find.text(labelScanExplainerText), findsOneWidget);
      });
    });

    testWidgets('is absent on Windows, and manual entry is untouched', (
      tester,
    ) async {
      // No on-device recogniser exists on Windows or the web (ADR 012), and
      // there is no manual equivalent of "read this photo" — so the entry
      // point is absent rather than disabled, and the rest of the form,
      // which *is* the manual path, is unchanged.
      await onPlatform(TargetPlatform.windows, () async {
        await openForm(tester, fakeCapture(result: fsanzTwoColumn()));

        expect(find.byKey(const Key('foodLabelScanButton')), findsNothing);
        expect(find.text(labelScanExplainerText), findsNothing);
        expect(find.byKey(const Key('caloriesField')), findsOneWidget);
        expect(find.byKey(const Key('foodNameField')), findsOneWidget);
      });
    });
  });

  group('when nothing comes back', () {
    testWidgets('backing out of the camera changes nothing and says nothing', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(cancelled: true));
        await enter(tester, 'caloriesField', '150');

        await tapScan(tester);

        expect(fieldText(tester, 'caloriesField'), '150');
        expect(find.byKey(const Key('labelScanBanner')), findsNothing);
        // A cancel is a decision, not a failure; the app does not comment.
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    testWidgets('a refused camera explains itself instead of crashing', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(
          tester,
          fakeCapture(
            throwOnPick: PlatformException(code: 'camera_access_denied'),
          ),
        );

        await tapScan(tester);

        expect(
          find.text(
            'Camera access is off. Allow it in Settings to scan labels.',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('labelScanBanner')), findsNothing);
        expect(fieldText(tester, 'caloriesField'), isEmpty);
        await clearSnackBars(tester);
      });
    });

    testWidgets('a photo with no panel in it leaves the form alone', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(result: receipt()));
        await enter(tester, 'caloriesField', '150');

        await tapScan(tester);

        expect(
          find.text(
            "Couldn't read a nutrition panel in that photo. Try again with "
            'the table filling the frame, or type the values.',
          ),
          findsOneWidget,
        );
        expect(fieldText(tester, 'caloriesField'), '150');
        expect(find.byKey(const Key('labelScanBanner')), findsNothing);
        await clearSnackBars(tester);
      });
    });

    testWidgets('a build with no recogniser says so rather than failing', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(
          tester,
          fakeCapture(result: const OcrResult.unsupported()),
        );

        await tapScan(tester);

        expect(
          find.textContaining("Scanning labels isn't available"),
          findsOneWidget,
        );
        expect(find.byKey(const Key('labelScanBanner')), findsNothing);
        await clearSnackBars(tester);
      });
    });
  });

  group('a panel that reads', () {
    testWidgets('fills the fields and shows the review banner', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(result: fsanzTwoColumn()));

        await tapScan(tester);

        expect(fieldText(tester, 'caloriesField'), '198');
        expect(fieldText(tester, 'proteinField'), '5.2');
        expect(fieldText(tester, 'carbsField'), '18.6');
        expect(fieldText(tester, 'fatField'), '10.2');
        expect(fieldText(tester, 'basisAmountField'), '30');

        // The banner is unconditional after a scan: it says what these
        // numbers are, not how well they were read.
        expect(find.byKey(const Key('labelScanBanner')), findsOneWidget);
        expect(find.text(labelScanBannerText), findsOneWidget);
      });
    });

    testWidgets('marks the value it was unsure of, and lists the caution', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        final handle = tester.ensureSemantics();
        await openForm(tester, fakeCapture(result: fsanzNoisy()));

        await tapScan(tester);

        // Asserted BEFORE scrolling anywhere. The banner sits at the top of
        // a lazy `ListView`, so scrolling down to the optional nutrients
        // disposes it and `find.text` would then report its absence as a
        // missing warning rather than as a scrolled-away one.
        expect(find.byKey(const Key('labelScanBanner')), findsOneWidget);
        // The parser's own caution about the repaired "34.O".
        expect(find.text(warnRepairedDigits), findsOneWidget);
        // A clean reading on the same panel carries no marker — checked
        // while the protein field is still on screen.
        expect(
          find.byKey(const Key('proteinFieldLowConfidence')),
          findsNothing,
        );

        // The optional-nutrient section reopens itself after a scan: eight
        // freshly filled fields behind a collapsed header would be eight
        // values they cannot review.
        await scrollToOptionalNutrient(tester, 'saturatedFatField');

        // "Saturatecl" was read as saturated fat, and trusted less for it.
        expect(fieldText(tester, 'saturatedFatField'), '4.1');
        expect(
          find.byKey(const Key('saturatedFatFieldLowConfidence')),
          findsOneWidget,
        );
        // A regex, not the bare string: the marker's `Semantics` node sits
        // inside an `InputDecoration.suffixIcon`, and a decorator that
        // merges the field's own label into the same node would defeat an
        // equality match while the marker is still perfectly present.
        expect(
          find.bySemanticsLabel(RegExp(lowConfidenceSemanticsLabel)),
          findsWidgets,
        );

        // Disposed here, as the last statement of the body, and **not** via
        // `addTearDown`: `WidgetTester._verifySemanticsHandlesWereDisposed`
        // runs when the body returns, which is before any tear-down, so a
        // deferred dispose fails the test with "A SemanticsHandle was active
        // at the end of the test" even though every assertion passed. Same
        // class of trap as the pending-timer invariant, and the same
        // placement rule as the `flushDriftTimers` last-statement discipline
        // in `manage_foods_screen_test.dart`. (This file pumps no
        // Drift-watching screen, so there is no flush to sit after it.)
        handle.dispose();
      });
    });

    testWidgets('keeps what they typed and says where the label disagreed', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(result: fsanzTwoColumn()));
        // They read the packet themselves first. A scan may not undo that.
        await enter(tester, 'caloriesField', '210');

        await tapScan(tester);

        expect(fieldText(tester, 'caloriesField'), '210');
        expect(
          find.text('Kept your value for calories (label read 198).'),
          findsOneWidget,
        );
        // The fields they had left blank are still filled.
        expect(fieldText(tester, 'proteinField'), '5.2');
      });
    });

    testWidgets('saves exactly the reviewed values, and no zero for a '
        'nutrient the panel never stated', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(result: fsanzTwoColumn()));

        await tapScan(tester);
        await enter(tester, 'foodNameField', 'Shop-brand muesli');
        await tapSave(tester);

        final saved = popped;
        expect(saved, isNotNull);
        expect(saved!.perServing.caloriesKcal, 198);
        expect(saved.perServing.proteinGrams, closeTo(5.2, 0.001));
        expect(saved.perServing.carbsGrams, closeTo(18.6, 0.001));
        expect(saved.perServing.fatGrams, closeTo(10.2, 0.001));
        expect(saved.perServing.saturatedFatGrams, closeTo(4.1, 0.001));
        expect(saved.perServing.fiberGrams, closeTo(3.4, 0.001));
        expect(saved.perServing.sodiumMg, 115);
        expect(saved.servingGrams, 30);
        // A photographed packet is the user's own reading, not a
        // database's record (ADR 010).
        expect(saved.source, FoodSource.custom);

        // The nutrients this panel does not print stay unknown. `0` would
        // be a claim about the food, and the round-trip is what proves the
        // null survives the repository rather than being defaulted.
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
        );
        addTearDown(container.dispose);
        final reloaded = await container
            .read(nutritionRepositoryProvider)
            .getFood(saved.id);

        expect(reloaded, isNotNull);
        expect(reloaded!.perServing.caloriesKcal, 198);
        expect(reloaded.perServing.fiberGrams, closeTo(3.4, 0.001));
        expect(reloaded.perServing.ironMg, isNull);
        expect(reloaded.perServing.calciumMg, isNull);
        expect(reloaded.perServing.potassiumMg, isNull);
        expect(reloaded.perServing.vitaminDMcg, isNull);
        expect(reloaded.perServing.vitaminCMg, isNull);
        expect(reloaded.perServing.transFatGrams, isNull);
        expect(reloaded.perServing.addedSugarsGrams, isNull);
      });
    });
  });

  group('a panel whose standard cannot be named', () {
    testWidgets('is accepted, not refused as unreadable', (tester) async {
      // A tight crop that lost every heading still has all its numbers.
      // Refusing it told the user their perfectly good photo could not be
      // read; the caution to check the values says the true thing.
      await onPlatform(TargetPlatform.android, () async {
        await openForm(tester, fakeCapture(result: unattributablePanel()));

        await tapScan(tester);

        expect(find.byType(SnackBar), findsNothing);
        expect(find.byKey(const Key('labelScanBanner')), findsOneWidget);
        expect(find.text(warnUnknownFormat), findsOneWidget);
        expect(fieldText(tester, 'proteinField'), '5.2');
        expect(fieldText(tester, 'carbsField'), '18.6');
        expect(fieldText(tester, 'fatField'), '10.2');
      });
    });
  });

  group('a drink, printed per 100 mL', () {
    testWidgets('fills the numbers, leaves the amount, and blocks the save '
        'until a weight is given', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(
          tester,
          fakeCapture(result: fsanzPer100Millilitres()),
        );

        await tapScan(tester);

        expect(fieldText(tester, 'carbsField'), '10.6');
        expect(fieldText(tester, 'proteinField'), '0.5');
        // No amount, and above all not "100 g": a millilitre is not a mass
        // (`knowledge/domain/nutrition.md`).
        expect(fieldText(tester, 'basisAmountField'), isEmpty);
        expect(find.text(labelScanPerVolumeWarning), findsOneWidget);

        await enter(tester, 'foodNameField', 'Sports drink');
        await tapSave(tester);

        expect(popped, isNull, reason: 'no weight, no save');
        // Said again where they are looking, under the form.
        expect(find.text(labelScanPerVolumeWarning), findsWidgets);

        await enter(tester, 'basisAmountField', '104');
        await tapSave(tester);

        expect(popped, isNotNull);
        expect(popped!.servingGrams, 104);
        expect(popped!.perServing.carbsGrams, closeTo(10.6, 0.001));
      });
    });

    testWidgets('scanning it twice does not unlock the save', (tester) async {
      // The guard used to be derived from "was the basis untouched", and
      // the first scan is what touches the basis — so a second scan cleared
      // it and 100 mL of a drink was saved as 100 g.
      await onPlatform(TargetPlatform.android, () async {
        await openForm(
          tester,
          fakeCapture(result: fsanzPer100Millilitres()),
        );

        await tapScan(tester);
        await tapScan(tester);

        expect(fieldText(tester, 'basisAmountField'), isEmpty);

        await enter(tester, 'foodNameField', 'Sports drink');
        await tapSave(tester);

        expect(popped, isNull, reason: 'still no weight, still no save');
        expect(find.text(labelScanPerVolumeWarning), findsWidgets);

        await enter(tester, 'basisAmountField', '104');
        await tapSave(tester);

        expect(popped, isNotNull);
        expect(popped!.servingGrams, 104);
      });
    });

    testWidgets('a weight typed before the scan is not an answer to it', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.android, () async {
        await openForm(
          tester,
          fakeCapture(result: fsanzPer100Millilitres()),
        );

        // They were defining a food by weight first. Their 250 g says nothing
        // about what 100 mL of this drink weighs.
        await enter(tester, 'foodNameField', 'Sports drink');
        await chooseGramsUnit(tester);
        expect(
          tester
              .widget<DropdownButtonFormField<String>>(
                find.byKey(const Key('basisUnitField')),
              )
              .initialValue,
          'g',
          reason:
              'the amount has to be a weight — `_effectiveServing` records '
              'no servingGrams for the "serving" unit',
        );
        await enter(tester, 'basisAmountField', '250');
        await tapScan(tester);

        expect(
          fieldText(tester, 'basisAmountField'),
          '250',
          reason: 'a scan never replaces what they typed',
        );

        await tapSave(tester);
        expect(popped, isNull);
        expect(find.text(labelScanPerVolumeWarning), findsWidgets);

        // Answering the warning: the weight of 100 mL of the drink, which
        // is the number the label's basis actually needs — not the 250 g
        // they had typed for a food they were defining by weight.
        //
        // It has to be a *different* number, and that is a property of the
        // harness rather than of the form: `EditableText` fires `onChanged`
        // only `if (oldValue.text != currentText)`, so `enterText` with the
        // string already in the field is a no-op and never reaches
        // `updateBasisAmount`. A real edit — deleting a digit, typing
        // another number — always fires it.
        await enter(tester, 'basisAmountField', '104');
        await tapSave(tester);

        expect(popped, isNotNull);
        expect(popped!.servingGrams, 104);
      });
    });
  });
}
