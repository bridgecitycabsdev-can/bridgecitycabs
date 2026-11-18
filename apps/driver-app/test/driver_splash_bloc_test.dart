import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/splash/splash.dart';

class TestSplashRepository implements DriverSplashRepository {
  final bool isOnline;
  final bool hasUpdate;
  final bool retryResult;

  TestSplashRepository({
    this.isOnline = true,
    this.hasUpdate = false,
    this.retryResult = true,
  });

  @override
  Future<DriverDispatchHubInfo> getHubInfo() async {
    return const DriverDispatchHubInfo(
      hubName: 'Lethbridge Central Hub',
      serverRegion: 'ca-central-1',
      version: 'v2.1.0',
    );
  }

  @override
  Future<bool> checkFleetConnectivity() async => isOnline;

  @override
  Future<bool> isUpdateRequired() async => hasUpdate;

  @override
  Future<bool> retryHubConnection() async => retryResult;
}

void main() {
  group('DriverSplashBloc Tests', () {
    test('initial state has default status and not retrying', () {
      final bloc = DriverSplashBloc(repository: TestSplashRepository());
      expect(bloc.state.status, DriverSplashStatus.initial);
      expect(bloc.state.isRetrying, isFalse);
      expect(bloc.state.retryCount, 0);
      expect(bloc.state.feedbackMessage, isNull);
    });

    test('transitions to ready when connectivity and update check pass', () async {
      final bloc = DriverSplashBloc(
        repository: TestSplashRepository(isOnline: true, hasUpdate: false),
      );

      bloc.add(const DriverSplashStarted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverSplashState>((s) => s.status == DriverSplashStatus.initial),
          predicate<DriverSplashState>((s) => s.status == DriverSplashStatus.ready),
        ]),
      );
    });

    test('transitions to updateRequired when update is required', () async {
      final bloc = DriverSplashBloc(
        repository: TestSplashRepository(hasUpdate: true),
      );

      bloc.add(const DriverSplashStarted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverSplashState>((s) => s.status == DriverSplashStatus.initial),
          predicate<DriverSplashState>((s) => s.status == DriverSplashStatus.updateRequired),
        ]),
      );
    });

    test('transitions to connectionError when offline', () async {
      final bloc = DriverSplashBloc(
        repository: TestSplashRepository(isOnline: false, hasUpdate: false),
      );

      bloc.add(const DriverSplashStarted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverSplashState>((s) => s.status == DriverSplashStatus.initial),
          predicate<DriverSplashState>((s) => s.status == DriverSplashStatus.connectionError),
        ]),
      );
    });

    test('retry hub connection sets isRetrying and transitions on success', () async {
      final bloc = DriverSplashBloc(
        repository: TestSplashRepository(retryResult: true),
      );

      bloc.add(const DriverSplashRetryTapped());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<DriverSplashState>((s) =>
              s.isRetrying == true &&
              s.status == DriverSplashStatus.connecting &&
              s.retryCount == 1),
          predicate<DriverSplashState>((s) =>
              s.isRetrying == false &&
              s.status == DriverSplashStatus.ready &&
              s.feedbackMessage != null),
        ]),
      );
    });

    test('status changed event updates state status directly', () async {
      final bloc = DriverSplashBloc(repository: TestSplashRepository());

      bloc.add(const DriverSplashStatusChanged(DriverSplashStatus.updateRequired));
      await expectLater(
        bloc.stream,
        emits(predicate<DriverSplashState>(
            (s) => s.status == DriverSplashStatus.updateRequired)),
      );
    });

    test('update now event generates feedback message', () async {
      final bloc = DriverSplashBloc(repository: TestSplashRepository());

      bloc.add(const DriverSplashUpdateNowTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<DriverSplashState>((s) => s.feedbackMessage != null)),
      );
    });
  });
}
