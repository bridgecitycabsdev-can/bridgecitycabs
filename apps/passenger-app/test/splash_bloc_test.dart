import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/splash/splash.dart';

class MockSplashRepository implements SplashRepository {
  ConnectionStatus mockConnectivity = const ConnectionStatus(
    quality: NetworkQuality.normal,
    isFleetDispatchReachable: true,
  );
  bool mockHasSession = false;
  int hotlineCalls = 0;

  @override
  Future<ConnectionStatus> checkFleetDispatchConnectivity() async {
    return mockConnectivity;
  }

  @override
  Future<bool> callUrgentCabHotline() async {
    hotlineCalls++;
    return true;
  }

  @override
  Future<bool> hasStoredSession() async {
    return mockHasSession;
  }
}

void main() {
  group('SplashBloc Tests', () {
    late MockSplashRepository repository;
    late SplashBloc bloc;

    setUp(() {
      repository = MockSplashRepository();
      bloc = SplashBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is SplashInitial', () {
      expect(bloc.state, isA<SplashInitial>());
      expect(bloc.state.status, SplashStatus.initial);
    });

    test('transitions to SplashLoading and then SplashSuccess when connectivity succeeds without session', () async {
      repository.mockHasSession = false;

      bloc.add(const SplashStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SplashLoading>(),
          predicate<SplashState>((state) {
            return state is SplashSuccess &&
                !state.isAuthenticated &&
                state.destinationRoute == '/phone';
          }),
        ]),
      );
    });

    test('transitions to SplashSuccess with /home when user is authenticated', () async {
      repository.mockHasSession = true;

      bloc.add(const SplashStarted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SplashLoading>(),
          predicate<SplashState>((state) {
            return state is SplashSuccess &&
                state.isAuthenticated &&
                state.destinationRoute == '/home';
          }),
        ]),
      );
    });

    test('transitions to SplashSlowConnection when slow signal is reported', () async {
      bloc.add(const SplashStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const SplashSlowConnectionDetected(
        notice: 'Reconnecting to fleet dispatch',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SplashState>((state) {
            return state is SplashSlowConnection &&
                state.dispatchNotice == 'Reconnecting to fleet dispatch';
          }),
        ),
      );
    });

    test('transitions to SplashConnectionInterrupted when dispatch connection fails', () async {
      bloc.add(const SplashStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const SplashConnectionFailed(
        errorMessage: "Couldn't connect. Check your internet and try again.",
        isOffline: true,
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SplashState>((state) {
            return state is SplashConnectionInterrupted &&
                state.isOffline &&
                state.title == SplashConfig.errorTitle;
          }),
        ),
      );
    });

    test('increments retryCount on SplashRetryRequested', () async {
      bloc.add(const SplashRetryRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SplashState>((state) => state.retryCount == 1),
        ),
      );
    });

    test('calls hotline on SplashHotlineCallRequested', () async {
      bloc.add(const SplashHotlineCallRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repository.hotlineCalls, 1);
    });
  });
}
