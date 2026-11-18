import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/profile/profile.dart';

void main() {
  Widget createTestWidget({UserProfile? initialUser, ProfileRepository? repository}) {
    return MaterialApp(
      home: SettingsPage(
        initialUser: initialUser,
        repository: repository,
      ),
    );
  }

  group('SettingsPage Widget Tests (Screen 2)', () {
    testWidgets('renders rider card, preferences, bylaw notice and logout', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('JC'), findsOneWidget);
      expect(find.text('Jesse Campbell'), findsOneWidget);
      expect(find.text('Rider'), findsOneWidget);
      expect(find.text('+1 (403) 555-0182'), findsOneWidget);
      expect(find.text('jesse.campbell@yqlmail.ca'), findsOneWidget);

      // Preferences & Policies
      expect(find.text('PREFERENCES & POLICIES'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Frequently asked questions'), findsOneWidget);
      expect(find.text('Terms and conditions'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Become a driver'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
      expect(find.text('About Bridge City Cabs'), findsOneWidget);

      // Coulee and Dispatch notices
      expect(find.text('HIGH LEVEL BRIDGE SPIRIT'), findsOneWidget);
      expect(find.text('Lethbridge City Dispatch'), findsOneWidget);
      expect(find.text(ProfileConfig.bylawCode), findsOneWidget);
      expect(find.textContaining('Version 1.0.19 (Build 240)'), findsOneWidget);
      expect(find.textContaining(ProfileConfig.regionalDispatchPhone), findsOneWidget);

      // Logout button
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('toggling notifications switch updates state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final updatedSwitch = tester.widget<Switch>(switchFinder);
      expect(updatedSwitch.value, isFalse);
    });
  });
}
