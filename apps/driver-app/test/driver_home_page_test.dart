import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/home/home.dart';

void main() {
  group('DriverHomePage Widget Tests', () {
    testWidgets('renders State 1 (Offline) accurately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.offline),
        ),
      );
      await tester.pump();

      expect(find.text(DriverHomeConfig.offlineTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.offlineSubtitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.offlineTag), findsOneWidget);
      expect(find.text(DriverHomeConfig.goOnlineButton), findsOneWidget);
      expect(find.text('Rides today'), findsOneWidget);
      expect(find.text('Acceptance'), findsOneWidget);
      expect(find.text('Online time'), findsOneWidget);
      expect(
          find.text(DriverHomeConfig.dispatchServerActive), findsOneWidget);
      expect(find.text('Ping 18ms'), findsOneWidget);
    });

    testWidgets('renders State 2 (Online & Searching) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.onlineSearching),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Shift started'), findsOneWidget);
      expect(find.text(DriverHomeConfig.onlineTag), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Away'), findsOneWidget);
      expect(find.text(DriverHomeConfig.searchingRidesTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.highDemandTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.surgeBadge), findsOneWidget);
    });

    testWidgets('renders State 3 (Location / GPS Off) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.locationOff),
        ),
      );
      await tester.pump();

      expect(find.text(DriverHomeConfig.locationOffBannerTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.locationRequiredTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.locationOffTag), findsOneWidget);
      expect(
          find.text(DriverHomeConfig.enableLocationSettings), findsOneWidget);
      expect(find.text(DriverHomeConfig.signalLostBadge), findsOneWidget);
    });

    testWidgets('renders State 4 (Shift on Pause / Away) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.shiftAway),
        ),
      );
      await tester.pump();

      expect(find.text(DriverHomeConfig.shiftOnPauseTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.awayTag), findsOneWidget);
      expect(find.text(DriverHomeConfig.currentlyAwayTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.backToActiveButton), findsOneWidget);
      expect(find.text(DriverHomeConfig.downtownLocationPill), findsOneWidget);
    });

    testWidgets('renders State 5 (Network Connection Lost) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.networkOffline),
        ),
      );
      await tester.pump();

      expect(find.text(DriverHomeConfig.signalPausedTopBar), findsOneWidget);
      expect(find.text(DriverHomeConfig.offlineReconnectingBanner),
          findsOneWidget);
      expect(find.text(DriverHomeConfig.connectionLostTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.offlineNetworkTag), findsOneWidget);
      expect(find.text(DriverHomeConfig.dispatchHelpline), findsOneWidget);
      expect(find.text(DriverHomeConfig.dispatchPhone), findsOneWidget);
      expect(find.text(DriverHomeConfig.retryConnectionNow), findsOneWidget);
    });

    testWidgets('renders State 6 (Incoming Ride Offer Broadcast) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.incomingOffer),
        ),
      );
      await tester.pump();

      expect(find.text(DriverHomeConfig.incomingRideOfferTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.alertActiveTag), findsOneWidget);
      expect(find.text(DriverHomeConfig.incomingDispatchChime), findsOneWidget);
      expect(find.text(DriverHomeConfig.dispatchBroadcast), findsOneWidget);
      expect(find.textContaining('View incoming trip offer (13s remaining)'),
          findsOneWidget);
    });

    testWidgets('renders State 7 (Account Pending / Dispatch Locked) accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DriverHomePage(initialStatus: DriverHomeStatus.accountPending),
        ),
      );
      await tester.pump();

      expect(find.text('Today \$0.00'), findsOneWidget);
      expect(find.text(DriverHomeConfig.documentsUnderReviewTitle),
          findsOneWidget);
      expect(find.text(DriverHomeConfig.accountPendingTitle), findsOneWidget);
      expect(find.text(DriverHomeConfig.pendingReviewTag), findsOneWidget);
      expect(find.text(DriverHomeConfig.dispatchLockedTag), findsOneWidget);
      expect(find.text(DriverHomeConfig.verificationChecklistTitle),
          findsOneWidget);
      expect(find.text("Driver's License (Class 4)"), findsOneWidget);
      expect(find.text('Vehicle Registration'), findsOneWidget);
      expect(find.text('City Mechanical Inspection'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('UNDER REVIEW'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.textContaining('Check application status'), findsOneWidget);
    });
  });
}
