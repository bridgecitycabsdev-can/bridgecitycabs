import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/side_menu_and_settings/side_menu_and_settings.dart';

void main() {
  group('SideMenuBloc Tests', () {
    late SideMenuBloc bloc;

    setUp(() {
      bloc = SideMenuBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state has default values', () {
      expect(bloc.state.status, SideMenuStatus.initial);
      expect(bloc.state.layout, SideMenuLayout.grid);
      expect(bloc.state.qaState, QaSideMenuState.unreadBadge);
      expect(bloc.state.unreadCount, 3);
      expect(bloc.state.profile.name, 'Marcus Vance');
      expect(bloc.state.isLogoutLocked, isFalse);
    });

    test('SideMenuStarted initializes state', () async {
      bloc.add(const SideMenuStarted());
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) =>
            s.status == SideMenuStatus.ready &&
            s.profile.name == 'Marcus Vance' &&
            s.unreadCount == 3)),
      );
    });

    test('SideMenuLayoutToggled toggles between grid and list', () async {
      bloc.add(const SideMenuLayoutToggled(SideMenuLayout.list));
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) => s.layout == SideMenuLayout.list)),
      );

      bloc.add(const SideMenuLayoutToggled(SideMenuLayout.grid));
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) => s.layout == SideMenuLayout.grid)),
      );
    });

    test('SideMenuQaStateSelected updates scenario state correctly', () async {
      // Switch to liveTripActive
      bloc.add(const SideMenuQaStateSelected(QaSideMenuState.liveTripActive));
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) =>
            s.qaState == QaSideMenuState.liveTripActive &&
            s.layout == SideMenuLayout.list &&
            s.profile.name == 'Clara Henderson' &&
            s.profile.isVerified &&
            s.activeTrip != null &&
            s.activeTrip!.driverName == 'Marcus V.' &&
            s.isLogoutLocked == true)),
      );

      // Switch to defaultState
      bloc.add(const SideMenuQaStateSelected(QaSideMenuState.defaultState));
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) =>
            s.qaState == QaSideMenuState.defaultState &&
            s.unreadCount == 0 &&
            s.activeTrip == null &&
            s.isLogoutLocked == false)),
      );
    });

    test('SideMenuLogoutTapped prevents logout when live trip is active', () async {
      bloc.add(const SideMenuQaStateSelected(QaSideMenuState.liveTripActive));
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(const SideMenuLogoutTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) =>
            s.lastActionMessage != null &&
            s.lastActionMessage!.contains('Please finish your active trip'))),
      );
    });

    test('SideMenuLogoutTapped succeeds when no active trip', () async {
      bloc.add(const SideMenuStarted());
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(const SideMenuLogoutTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<SideMenuState>((s) =>
            s.lastActionMessage != null &&
            s.lastActionMessage!.contains('Logged out'))),
      );
    });
  });
}
