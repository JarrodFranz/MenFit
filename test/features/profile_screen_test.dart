import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/presentation/profile_screen.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_repository.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';

class _FakeProfileRepository implements ProfileRepository {
  UserProfile? profile;
  final List<UserProfile> saved = [];
  final _controller = StreamController<UserProfile?>.broadcast();

  void emit(UserProfile? value) {
    profile = value;
    _controller.add(value);
  }

  @override
  Stream<UserProfile?> watchProfile() async* {
    yield profile;
    yield* _controller.stream;
  }

  @override
  Future<UserProfile?> getProfile() async => profile;

  @override
  Future<void> saveProfile(UserProfile value) async {
    saved.add(value);
    emit(value);
  }

  @override
  Future<void> deleteAllData() async {
    saved.clear();
    emit(null);
  }

  Future<void> close() => _controller.close();
}

/// Absorbs the controller's profile -> weight-history write-through (task
/// 2.1). Only [saveLog] is reachable from this screen; the real provider
/// would open a Drift database against the filesystem inside a widget test.
class _FakeWeightRepository implements WeightRepository {
  final List<WeightLog> saved = [];

  @override
  Future<void> saveLog(WeightLog log) async => saved.add(log);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unexpected ${invocation.memberName}');
}

void main() {
  late _FakeProfileRepository repository;
  late _FakeWeightRepository weightRepository;

  UserProfile seedProfile({
    UnitSystem unitSystem = UnitSystem.imperial,
    double? heightCm,
    double? weightKg,
  }) => UserProfile(
    id: 'id-1',
    displayName: 'Jordan',
    unitSystem: unitSystem,
    weeklyActivityGoal: 4,
    heightCm: heightCm,
    weightKg: weightKg,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  setUp(() {
    repository = _FakeProfileRepository();
    weightRepository = _FakeWeightRepository();
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        weightRepositoryProvider.overrideWithValue(weightRepository),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const ProfileScreen()),
    );
  }

  // The S1-3 field expansion made the form far taller than the default
  // 800x600 test surface - a plain `ListView(children: ...)` only *builds*
  // the children within its viewport + cache extent (elements outside that
  // range genuinely don't exist yet, so `find.text`/`ensureVisible` can't
  // find them either), so every test needs a tall-enough surface for the
  // whole form to be built and reachable, same pattern as the onboarding
  // flow tests.
  void useTallSurface(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(400, 2400)
      ..devicePixelRatio = 1;
  }

  testWidgets('renders the current profile values', (tester) async {
    useTallSurface(tester);
    repository.emit(seedProfile());

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Jordan'), findsOneWidget); // in the display-name field
    expect(find.text('4 times / week'), findsOneWidget);

    final segmented = tester.widget<SegmentedButton<UnitSystem>>(
      find.byType(SegmentedButton<UnitSystem>),
    );
    expect(segmented.selected, {UnitSystem.imperial});
  });

  testWidgets('editing the name and saving persists the new value', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(seedProfile());

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profileNameField')), 'Alex');
    await tester.tap(find.text('Save name'));
    await tester.pumpAndSettle();

    expect(repository.saved, isNotEmpty);
    expect(repository.saved.last.displayName, 'Alex');
    expect(repository.saved.last.id, 'id-1');
  });

  testWidgets(
    'tapping top AppBar Save button persists name and shows confirmation',
    (tester) async {
      useTallSurface(tester);
      repository.emit(seedProfile());

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('profileNameField')),
        'Taylor',
      );
      await tester.tap(find.byKey(const Key('profileSaveButton')));
      await tester.pumpAndSettle();

      expect(repository.saved, isNotEmpty);
      expect(repository.saved.last.displayName, 'Taylor');
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Profile saved successfully'), findsOneWidget);
    },
  );

  testWidgets('both sections render with their field labels', (tester) async {
    useTallSurface(tester);
    repository.emit(seedProfile(unitSystem: UnitSystem.metric));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('About you'), findsOneWidget);
    expect(find.text('Date of birth (optional)'), findsOneWidget);
    expect(find.text('Height (optional)'), findsOneWidget);
    expect(find.text('Weight (optional)'), findsOneWidget);

    expect(find.text('Training'), findsOneWidget);
    expect(find.text('Fitness goals (optional)'), findsOneWidget);
    expect(find.text('Running experience (optional)'), findsOneWidget);
    expect(find.text('Strength experience (optional)'), findsOneWidget);
    expect(find.text('Preferred training days (optional)'), findsOneWidget);
    expect(
      find.textContaining('How many times per week is your goal to exercise?'),
      findsOneWidget,
    );
    expect(find.text('Units'), findsOneWidget);
  });

  testWidgets('entering a metric height and saving persists heightCm', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(seedProfile(unitSystem: UnitSystem.metric));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('profileHeightField')),
      '170',
    );
    await tester.tap(find.text('Save height'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.heightCm, 170);
  });

  testWidgets(
    'entering an imperial height (ft/in) and saving converts and persists '
    'heightCm',
    (tester) async {
      useTallSurface(tester);
      repository.emit(seedProfile());

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('profileHeightFeetField')),
        '5',
      );
      await tester.enterText(
        find.byKey(const Key('profileHeightInchesField')),
        '7',
      );
      await tester.tap(find.text('Save height'));
      await tester.pumpAndSettle();

      expect(repository.saved.last.heightCm, closeTo(170.18, 0.01));
    },
  );

  testWidgets('entering a metric weight and saving persists weightKg', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(seedProfile(unitSystem: UnitSystem.metric));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profileWeightField')), '65');
    await tester.tap(find.text('Save weight'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.weightKg, 65);
  });

  testWidgets(
    'entering an imperial weight (lb) and saving converts and persists '
    'weightKg',
    (tester) async {
      useTallSurface(tester);
      repository.emit(seedProfile());

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('profileWeightField')),
        '150',
      );
      await tester.tap(find.text('Save weight'));
      await tester.pumpAndSettle();

      expect(repository.saved.last.weightKg, closeTo(68.04, 0.01));
    },
  );

  testWidgets('clearing an already-set height persists null', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(
      seedProfile(unitSystem: UnitSystem.metric, heightCm: 170),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Clear height'), findsOneWidget);
    await tester.tap(find.text('Clear height'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.heightCm, isNull);
  });

  testWidgets('clearing an already-set weight persists null', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(
      seedProfile(unitSystem: UnitSystem.metric, weightKg: 65),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Clear weight'), findsOneWidget);
    await tester.tap(find.text('Clear weight'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.weightKg, isNull);
  });

  testWidgets('choosing a fitness goal chip persists it', (tester) async {
    useTallSurface(tester);
    repository.emit(seedProfile(unitSystem: UnitSystem.metric));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Run further'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.fitnessGoal, FitnessGoal.runFurther);
  });

  testWidgets(
    'tapping the already-selected fitness goal chip clears it',
    (tester) async {
      useTallSurface(tester);
      repository.emit(
        seedProfile(
          unitSystem: UnitSystem.metric,
        ).copyWith(fitnessGoal: FitnessGoal.runFurther),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Run further'));
      await tester.pumpAndSettle();

      expect(repository.saved.last.fitnessGoal, isNull);
    },
  );

  testWidgets(
    'picking a date of birth via the date picker persists it',
    (tester) async {
      useTallSurface(tester);
      repository.emit(seedProfile(unitSystem: UnitSystem.metric));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Not set'), findsOneWidget);
      await tester.tap(find.byKey(const Key('profileDateOfBirthField')));
      await tester.pumpAndSettle();

      // Accept the picker's default-selected date (25 years before today,
      // since no date of birth was set yet) without navigating the
      // calendar - this test asserts a date got persisted, not which one.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(repository.saved.last.dateOfBirth, isNotNull);
    },
  );

  testWidgets('clearing an already-set date of birth persists null', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(
      seedProfile(
        unitSystem: UnitSystem.metric,
      ).copyWith(dateOfBirth: LocalDate(1990, 3, 15)),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Mar 15, 1990'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear date of birth'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.dateOfBirth, isNull);
  });

  testWidgets('choosing a training day toggles it into trainingDays', (
    tester,
  ) async {
    useTallSurface(tester);
    repository.emit(seedProfile(unitSystem: UnitSystem.metric));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mon'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.trainingDays, {Weekday.mon});
  });
}
