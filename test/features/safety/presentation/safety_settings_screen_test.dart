import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/safety/presentation/safety_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/platform/sharing/fake_sharing_adapter.dart';

class _FakeProfileRepo implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Stream<UserProfile?> watchProfile() => Stream.value(null);

  @override
  Future<void> saveProfile(UserProfile profile) async {}

  @override
  Future<void> deleteAllData() async {}
}

void main() {
  group('SafetySettingsScreen', () {
    late SharedPreferences prefs;
    late FakeSharingAdapter fakeSharing;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      fakeSharing = FakeSharingAdapter();
    });

    Widget createSubject() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sharingAdapterProvider.overrideWithValue(fakeSharing),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepo()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SafetySettingsScreen(),
        ),
      );
    }

    testWidgets('renders all safety sections and empty contacts state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Safety & Emergency Contacts'), findsOneWidget);
      expect(find.text('100% On-Device & Private'), findsOneWidget);
      expect(find.text('Trusted Contacts'), findsOneWidget);
      expect(find.text('No Emergency Contacts'), findsOneWidget);
      expect(find.text('Safety Check-in Timer'), findsNWidgets(2));
      expect(find.text('Stationary Inactivity Detection'), findsOneWidget);
      expect(find.text('Emergency Message Preview'), findsOneWidget);
    });

    testWidgets('adds an emergency contact via dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ Add Contact'));
      await tester.pumpAndSettle();

      expect(find.text('Add Emergency Contact'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Sarah Connor',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '0412345678',
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Sarah Connor'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
      expect(find.text('Other • 0412345678'), findsOneWidget);
    });

    testWidgets('taps Test Send SOS Alert and invokes shareText', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Scroll down to the preview section
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Send SOS Alert'));
      await tester.pumpAndSettle();

      expect(fakeSharing.shareCount, 1);
      expect(
        fakeSharing.textShares.first.subject,
        'MenFit Safety Alert (Test)',
      );
      expect(
        fakeSharing.textShares.first.text,
        contains('MenFit Safety Alert:'),
      );
    });
  });
}
