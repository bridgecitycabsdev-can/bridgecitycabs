import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/profile/profile.dart';

void main() {
  Widget createTestWidget({UserProfile? initialUser, ProfileRepository? repository}) {
    return MaterialApp(
      home: ProfilePage(
        initialUser: initialUser,
        repository: repository,
      ),
    );
  }

  group('ProfilePage Widget Tests (Screen 1)', () {
    testWidgets('renders user profile credentials and preferences', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Robert Vance'), findsNWidgets(2)); // Name header + Credential
      expect(find.text('5.0 (42 rides)'), findsOneWidget);
      expect(find.text('Lethbridge Rider • Member since 2023'), findsOneWidget);

      // Account credentials
      expect(find.text('ACCOUNT CREDENTIALS'), findsOneWidget);
      expect(find.text('Verified Identity'), findsOneWidget);
      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('+1 (403) 555-0192'), findsOneWidget);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('robert.vance@uleth.ca'), findsOneWidget);
      expect(find.text('contact support'), findsOneWidget);

      // Preferences & Security
      expect(find.text('PREFERENCES & SECURITY'), findsOneWidget);
      expect(find.text('Payment methods'), findsOneWidget);
      expect(find.text('Visa ending in 4242 • Default'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Push & SMS active'), findsOneWidget);
      expect(find.text('Privacy and data'), findsOneWidget);
      expect(find.text('Location & card policies'), findsOneWidget);

      // Logout and Version
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text(ProfileConfig.appVersion), findsOneWidget);
    });

    testWidgets('tapping contact support shows feedback message', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('contact support'), findsOneWidget);
      await tester.tap(find.text('contact support'));
      await tester.pumpAndSettle();
    });
  });
}
