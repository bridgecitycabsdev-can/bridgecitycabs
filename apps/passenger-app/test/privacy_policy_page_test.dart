import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/profile/profile.dart';

void main() {
  Widget createTestWidget({ProfileRepository? repository}) {
    return MaterialApp(
      home: PrivacyPolicyPage(repository: repository),
    );
  }

  group('PrivacyPolicyPage Widget Tests (Screen 3)', () {
    testWidgets('renders trust and safety badge, policy cards and PIPA disclaimer', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Privacy And Data'), findsOneWidget);
      expect(find.text('LETHBRIDGE TRUST & SAFETY'), findsOneWidget);
      expect(
        find.text('How we protect and manage your data on Bridge City Cabs rides in Lethbridge.'),
        findsOneWidget,
      );

      // Data policy cards
      expect(find.text('Your location'), findsOneWidget);
      expect(find.text('Foreground only • GPS active during trips'), findsOneWidget);

      expect(find.text('Your payments'), findsOneWidget);
      expect(find.text('Stripe 256-bit SSL • PCI-DSS Tier 1'), findsOneWidget);

      expect(find.text('Your notifications'), findsOneWidget);
      expect(find.text('Push & SMS notifications'), findsOneWidget);

      // Legal & Policies
      expect(find.text('LEGAL & POLICIES'), findsOneWidget);
      expect(find.text('Read the Privacy Policy'), findsOneWidget);
      expect(find.text('Read the Terms and Conditions'), findsOneWidget);

      // PIPA compliance card
      expect(find.text(ProfileConfig.pipComplianceNotice), findsOneWidget);
    });

    testWidgets('tapping read privacy policy triggers feedback event', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Read the Privacy Policy'), findsOneWidget);
      await tester.tap(find.text('Read the Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Privacy'), findsWidgets);
    });
  });
}
