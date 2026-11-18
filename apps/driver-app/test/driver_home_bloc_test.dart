import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/home/home.dart';

class TestDriverHomeRepository implements DriverHomeRepository {
  final bool shouldSucceed;

  TestDriverHomeRepository({this.shouldSucceed = true});

  @override
  Future<bool> startShift() async => shouldSucceed;

  @override
  Future<bool> pauseShift() async => shouldSucceed;

  @override
  Future<bool> resumeShift() async => shouldSucceed;

  @override
  Future<bool> endShift() async => shouldSucceed;

  @override
  Future<bool> retryNetworkConnection() async => shouldSucceed;

  @override
  Future<bool> requestLocationPermission() async => shouldSucceed;

  @override
  Future<DriverHomeMetrics> refreshMetrics() async {
    return const DriverHomeMetrics(
      todayEarnings: 41.77,
      ridesToday: 1,
      acceptanceRate: 50,
      onlineTime: '2h 15m',
      pingMs: 18,
    );
  }
}

void main() {
  group('DriverHomeBloc Tests', () {
    test('initial state defaults to offline with default metrics', () {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());
      expect(bloc.state.status, DriverHomeStatus.offline);
      expect(bloc.state.isOffline, isTrue);
      expect(bloc.state.metrics.todayEarnings, 41.77);
      expect(bloc.state.metrics.ridesToday, 1);
      expect(bloc.state.metrics.acceptanceRate, 50);
    });

    test('go online starts shift and transitions to onlineSearching', () async {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());

      bloc.add(const DriverHomeGoOnlineRequested());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverHomeStatus.onlineSearching);
      expect(bloc.state.shiftMode, DriverShiftMode.active);
      expect(bloc.state.feedbackMessage, contains('Shift started!'));
    });

    test('pause and resume shift update shift mode and state', () async {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());

      // Set Away
      bloc.add(const DriverHomeSetAwayRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.status, DriverHomeStatus.shiftAway);
      expect(bloc.state.shiftMode, DriverShiftMode.away);

      // Resume Active
      bloc.add(const DriverHomeResumeActiveRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.status, DriverHomeStatus.onlineSearching);
      expect(bloc.state.shiftMode, DriverShiftMode.active);
    });

    test('enabling location from locationOff restores searching', () async {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());

      bloc.add(
          const DriverHomeStateSwitched(DriverHomeStatus.locationOff));
      expect(bloc.state.isLocationOff, isTrue);
      expect(bloc.state.isDarkMode, isTrue);

      bloc.add(const DriverHomeEnableLocationRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isOnlineSearching, isTrue);
      expect(bloc.state.isDarkMode, isFalse);
    });

    test('retrying connection restores onlineSearching', () async {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());

      bloc.add(
          const DriverHomeStateSwitched(DriverHomeStatus.networkOffline));
      expect(bloc.state.isNetworkOffline, isTrue);

      bloc.add(const DriverHomeRetryConnectionRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isOnlineSearching, isTrue);
    });

    test('theme toggle switches isDarkMode', () {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());
      expect(bloc.state.isDarkMode, isFalse);

      bloc.add(const DriverHomeThemeToggled());
      expect(bloc.state.isDarkMode, isTrue);

      bloc.add(const DriverHomeThemeToggled());
      expect(bloc.state.isDarkMode, isFalse);
    });

    test('earnings refresh updates metrics from repository', () async {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());

      bloc.add(const DriverHomeEarningsRefreshRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.metrics.todayEarnings, 41.77);
      expect(bloc.state.feedbackMessage, contains(r'$41.77'));
    });

    test('switching state directly via QA event reproduces all 7 screen states',
        () {
      final bloc = DriverHomeBloc(repository: TestDriverHomeRepository());

      // 1. Offline (Image 1)
      bloc.add(const DriverHomeStateSwitched(DriverHomeStatus.offline));
      expect(bloc.state.isOffline, isTrue);
      expect(bloc.state.metrics.currentLocationName, 'Lethbridge Fleet Zone 01');

      // 2. Online & Searching (Image 2)
      bloc.add(
          const DriverHomeStateSwitched(DriverHomeStatus.onlineSearching));
      expect(bloc.state.isOnlineSearching, isTrue);
      expect(bloc.state.surgeZone.multiplier, 1.3);

      // 3. Location Off (Image 3)
      bloc.add(const DriverHomeStateSwitched(DriverHomeStatus.locationOff));
      expect(bloc.state.isLocationOff, isTrue);
      expect(bloc.state.shiftMode, DriverShiftMode.locked);

      // 4. Shift on Pause / Away (Image 4)
      bloc.add(const DriverHomeStateSwitched(DriverHomeStatus.shiftAway));
      expect(bloc.state.isShiftAway, isTrue);
      expect(bloc.state.shiftMode, DriverShiftMode.away);

      // 5. Network Offline (Image 5)
      bloc.add(
          const DriverHomeStateSwitched(DriverHomeStatus.networkOffline));
      expect(bloc.state.isNetworkOffline, isTrue);

      // 6. Incoming Ride Offer (Image 6)
      bloc.add(const DriverHomeStateSwitched(DriverHomeStatus.incomingOffer));
      expect(bloc.state.isIncomingOffer, isTrue);
      expect(bloc.state.incomingOffer.remainingSeconds, 13);

      // 7. Account Pending / Locked (Image 7)
      bloc.add(const DriverHomeStateSwitched(DriverHomeStatus.accountPending));
      expect(bloc.state.isAccountPending, isTrue);
      expect(bloc.state.metrics.isEarningsLocked, isTrue);
      expect(bloc.state.verificationItems.length, 3);
    });
  });
}
