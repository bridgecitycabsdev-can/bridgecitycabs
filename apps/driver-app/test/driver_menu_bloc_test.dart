import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/menu/menu.dart';

void main() {
  group('DriverMenuBloc Tests', () {
    late FakeDriverMenuRepository repository;
    late DriverMenuBloc bloc;

    setUp(() {
      repository = FakeDriverMenuRepository(latency: const Duration(milliseconds: 10));
      bloc = DriverMenuBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to online with Shajil Kunhumon and $41.77 earnings', () {
      expect(bloc.state.status, DriverMenuStatus.online);
      expect(bloc.state.profile.name, 'Shajil Kunhumon');
      expect(bloc.state.stats.todayEarnings, 41.77);
      expect(bloc.state.stats.ridesCompleted, 1);
      expect(bloc.state.isOnline, isTrue);
    });

    test('Selecting unlocked menu item updates selection and target route', () {
      bloc.add(const DriverMenuItemSelected(DriverMenuItemId.history));
      expect(bloc.state.selectedRouteTarget, '/history');
      final historyItem = bloc.state.menuItems.firstWhere((i) => i.id == DriverMenuItemId.history);
      expect(historyItem.isSelected, isTrue);
    });

    test('Selecting locked menu item under review prevents navigation and emits feedback', () {
      bloc.add(const DriverMenuStateForced(DriverMenuStatus.underReview));
      bloc.add(const DriverMenuItemSelected(DriverMenuItemId.earnings));

      expect(bloc.state.selectedRouteTarget, isNull);
      expect(
        bloc.state.feedbackMessage,
        'Locked features will activate upon municipal compliance approval.',
      );
    });

    test('Logout pressed when online transitions to logoutConfirmation dialog', () {
      bloc.add(const DriverMenuLogoutPressed());
      expect(bloc.state.status, DriverMenuStatus.logoutConfirmation);
      expect(bloc.state.isLogoutDialogVisible, isTrue);
      expect(bloc.state.previousStatus, DriverMenuStatus.online);
    });

    test('Logout cancelled returns to previous status', () {
      bloc.add(const DriverMenuLogoutPressed());
      expect(bloc.state.status, DriverMenuStatus.logoutConfirmation);

      bloc.add(const DriverMenuLogoutCancelled());
      expect(bloc.state.status, DriverMenuStatus.online);
    });

    test('Logout confirmed executes logout and triggers shouldNavigateToLogin', () async {
      bloc.add(const DriverMenuLogoutPressed());
      bloc.add(const DriverMenuLogoutConfirmed());

      expect(bloc.state.isActionLoading, isTrue);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.shouldNavigateToLogin, isTrue);
    });

    test('Logout pressed during active trip is blocked and emits warning', () {
      bloc.add(const DriverMenuStateForced(DriverMenuStatus.activeTrip));
      bloc.add(const DriverMenuLogoutPressed());

      expect(bloc.state.status, DriverMenuStatus.activeTrip);
      expect(
        bloc.state.feedbackMessage,
        contains('Finish current trip before logging out'),
      );
    });

    test('Forcing states via QA matrix loads appropriate presets', () {
      // 1. Offline
      bloc.add(const DriverMenuStateForced(DriverMenuStatus.offline));
      expect(bloc.state.status, DriverMenuStatus.offline);
      expect(bloc.state.stats.todayEarnings, 0.00);
      expect(bloc.state.stats.shiftPrompt, contains('Go online'));

      // 2. Active Trip
      bloc.add(const DriverMenuStateForced(DriverMenuStatus.activeTrip));
      expect(bloc.state.status, DriverMenuStatus.activeTrip);
      expect(bloc.state.activeTrip.unitNumber, 'Unit 42');
      expect(bloc.state.canLogout, isFalse);

      // 3. Under Review
      bloc.add(const DriverMenuStateForced(DriverMenuStatus.underReview));
      expect(bloc.state.status, DriverMenuStatus.underReview);
      final earningsItem = bloc.state.menuItems.firstWhere((i) => i.id == DriverMenuItemId.earnings);
      final flagRideItem = bloc.state.menuItems.firstWhere((i) => i.id == DriverMenuItemId.flagRide);
      expect(earningsItem.isLocked, isTrue);
      expect(flagRideItem.isLocked, isTrue);
    });
  });
}
