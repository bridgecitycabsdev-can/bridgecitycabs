import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/onboarding/onboarding.dart';

void main() {
  group('DriverOnboardingPage Widget Tests', () {
    testWidgets('renders Slide 1 (Get Rides) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOnboardingPage(
            initialIndex: 0,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Top bar elements
      expect(find.text('DRIVER'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Bottom sheet content
      expect(find.text('GET RIDES'), findsOneWidget);
      expect(find.text('Go online, get\nrequests.'), findsOneWidget);

      // Ride request card
      expect(find.byType(DriverRideRequestCard), findsOneWidget);
      expect(find.text('\$22.50'), findsOneWidget);
      expect(find.text('Estimated Fare'), findsOneWidget);
      expect(find.text('Scenic Dr & 4th Ave S'), findsOneWidget);
      expect(find.text('University Dr W, ULeth'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);

      // Forward arrow button
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders Slide 2 (Earn More) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOnboardingPage(
            initialIndex: 1,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Bottom sheet content
      expect(find.text('EARN MORE'), findsOneWidget);
      expect(find.text('Track every dollar you earn.'), findsOneWidget);

      // Earnings preview card
      expect(find.byType(DriverEarningsPreviewCard), findsOneWidget);
      expect(find.text("TODAY'S TOTAL METER"), findsOneWidget);
      expect(find.text('\$148.60'), findsOneWidget);
      expect(find.text('CAD'), findsOneWidget);
      expect(find.text('Shift Active'), findsOneWidget);
      expect(find.text('8 Trips'), findsOneWidget);
      expect(find.text('4h 15m Online'), findsOneWidget);
      expect(find.text('64.2 km'), findsOneWidget);
    });

    testWidgets('renders Slide 3 (Support when you need it) elements accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOnboardingPage(
            initialIndex: 2,
            showQaToolbar: false,
          ),
        ),
      );
      await tester.pump();

      // Bottom sheet content
      expect(find.text('DRIVE WITH CONFIDENCE'), findsOneWidget);
      expect(find.text('Support when you\nneed it.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);

      // Profile & Compliance card
      expect(find.byType(DriverSupportComplianceCard), findsOneWidget);
      expect(find.text('Jesse C.'), findsOneWidget);
      expect(find.text('Lethbridge Fleet'), findsOneWidget);
      expect(find.text('4.98'), findsOneWidget);
      expect(find.text('Alberta Class 4 & Inspection'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('tapping QA matrix bar switches between states and submitting',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverOnboardingPage(
            initialIndex: 0,
            showQaToolbar: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverOnboardingQaMatrixBar), findsOneWidget);

      // Switch to Slide 2: Earn More
      await tester.tap(find.text('2. Earn More'));
      await tester.pumpAndSettle();

      expect(find.text('EARN MORE'), findsOneWidget);
      expect(find.byType(DriverEarningsPreviewCard), findsOneWidget);

      // Switch to Slide 4: Setting Up Dispatch
      await tester.tap(find.text('4. Setting Up Dispatch'));
      await tester.pumpAndSettle();

      expect(find.text('Setting up dispatch...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Vehicle Safety'), findsOneWidget);
      expect(find.text('Driver Partner'), findsOneWidget);
      expect(find.text('Dispatch Ops'), findsOneWidget);
    });
  });
}
