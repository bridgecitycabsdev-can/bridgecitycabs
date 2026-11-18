import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/menu/menu.dart';

void main() {
  group('DriverMenuPage Widget Tests', () {
    late FakeDriverMenuRepository repository;

    setUp(() {
      repository = FakeDriverMenuRepository(latency: Duration.zero);
    });

    Widget createWidget({
      DriverMenuStatus initialStatus = DriverMenuStatus.online,
    }) {
      return MaterialApp(
        home: DriverMenuPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders State 1: Online Menu items and stats correctly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverMenuStatus.online));
      await tester.pumpAndSettle();

      expect(find.text('Shajil Kunhumon'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('\$41.77'), findsOneWidget);
      expect(find.text('1 Ride'), findsOneWidget);
      expect(find.text('10 km'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Flag Ride'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('LETHBRIDGE FLEET UNIT #42'), findsOneWidget);
    });

    testWidgets('Renders State 2: Logout Confirmation Dialog correctly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverMenuStatus.logoutConfirmation));
      await tester.pumpAndSettle();

      expect(find.textContaining('Log out of Bridge City Cabs'), findsOneWidget);
      expect(find.text("You'll stop receiving ride requests."), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Renders State 3: Offline Menu correctly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverMenuStatus.offline));
      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
      expect(find.text('Rides 0'), findsOneWidget);
      expect(find.text('Go online to start shift'), findsOneWidget);
    });

    testWidgets('Renders State 4: Active Trip Menu with banner and locked logout', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverMenuStatus.activeTrip));
      await tester.pumpAndSettle();

      expect(find.text('Finish current trip before logging out.'), findsOneWidget);
      expect(find.textContaining('Unit 42 is on active dispatch'), findsOneWidget);
      expect(find.text('ACTIVE TRIP'), findsOneWidget);
      expect(find.text('Call Hub'), findsOneWidget);
      expect(find.text('Log out (Active Trip)'), findsOneWidget);
    });

    testWidgets('Renders State 5: Under Review Menu with locked icons and compliance notice', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverMenuStatus.underReview));
      await tester.pumpAndSettle();

      expect(find.text('Account Under Review'), findsOneWidget);
      expect(find.textContaining('Lethbridge Taxi Commission compliance'), findsOneWidget);
      expect(find.text('PENDING REVIEW'), findsOneWidget);
      expect(find.text('SHIFT LOCKED'), findsOneWidget);
      expect(find.text('Verification Required'), findsOneWidget);
      expect(find.textContaining('Locked features will activate'), findsOneWidget);
      expect(find.text('Contact support ➔'), findsOneWidget);
    });

    testWidgets('QA Matrix bar toggles states when clicked', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverMenuStatus.online));
      await tester.pumpAndSettle();

      expect(find.text('ONLINE'), findsOneWidget);

      final activeTripChip = find.text('4: Active Trip (Locked)');
      expect(activeTripChip, findsOneWidget);
      await tester.tap(activeTripChip);
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE TRIP'), findsOneWidget);
      expect(find.text('Log out (Active Trip)'), findsOneWidget);
    });
  });
}
