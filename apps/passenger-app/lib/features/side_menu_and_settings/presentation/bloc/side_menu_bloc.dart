import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/side_menu_model.dart';
import '../../data/repositories/side_menu_repository.dart';
import 'side_menu_event.dart';
import 'side_menu_state.dart';

class SideMenuBloc extends Bloc<SideMenuEvent, SideMenuState> {
  final SideMenuRepository repository;

  SideMenuBloc({required this.repository}) : super(const SideMenuState()) {
    on<SideMenuStarted>(_onStarted);
    on<SideMenuLayoutToggled>(_onLayoutToggled);
    on<SideMenuQaStateSelected>(_onQaStateSelected);
    on<SideMenuNavigationTapped>(_onNavigationTapped);
    on<SideMenuLiveTripTapped>(_onLiveTripTapped);
    on<SideMenuLogoutTapped>(_onLogoutTapped);
    on<SideMenuDismissTapped>(_onDismissTapped);
  }

  Future<void> _onStarted(
    SideMenuStarted event,
    Emitter<SideMenuState> emit,
  ) async {
    final qa = event.initialQaState ?? QaSideMenuState.defaultState;
    final profile = await repository.getProfile(qa);
    final activeTrip = await repository.getActiveTrip(qa);
    final unread = await repository.getUnreadNotificationsCount(qa);

    emit(state.copyWith(
      layout: event.initialLayout ??
          (qa == QaSideMenuState.liveTripActive
              ? SideMenuLayout.list
              : SideMenuLayout.grid),
      qaState: qa,
      profile: profile,
      activeTrip: () => activeTrip,
      unreadCount: unread,
    ));
  }

  void _onLayoutToggled(
    SideMenuLayoutToggled event,
    Emitter<SideMenuState> emit,
  ) {
    final nextLayout =
        state.isGrid ? SideMenuLayout.list : SideMenuLayout.grid;
    emit(state.copyWith(
      layout: nextLayout,
      feedbackMessage: () => 'Switched to ${nextLayout.label}',
    ));
  }

  Future<void> _onQaStateSelected(
    SideMenuQaStateSelected event,
    Emitter<SideMenuState> emit,
  ) async {
    final profile = await repository.getProfile(event.qaState);
    final activeTrip = await repository.getActiveTrip(event.qaState);
    final unread = await repository.getUnreadNotificationsCount(event.qaState);

    emit(state.copyWith(
      qaState: event.qaState,
      profile: profile,
      activeTrip: () => activeTrip,
      unreadCount: unread,
      layout: event.qaState == QaSideMenuState.liveTripActive
          ? SideMenuLayout.list
          : state.layout,
      feedbackMessage: () => 'QA state: ${event.qaState.chipLabel}',
    ));
  }

  void _onNavigationTapped(
    SideMenuNavigationTapped event,
    Emitter<SideMenuState> emit,
  ) {
    emit(state.copyWith(
      navigationTarget: () => event.route,
      feedbackMessage: () => 'Navigating to ${event.route}',
    ));
  }

  void _onLiveTripTapped(
    SideMenuLiveTripTapped event,
    Emitter<SideMenuState> emit,
  ) {
    emit(state.copyWith(
      navigationTarget: () => '/tracking',
      feedbackMessage: () => 'Opening live trip tracking...',
    ));
  }

  Future<void> _onLogoutTapped(
    SideMenuLogoutTapped event,
    Emitter<SideMenuState> emit,
  ) async {
    if (state.isLogoutLocked) {
      emit(state.copyWith(
        feedbackMessage: () => 'Finish your trip before logging out.',
      ));
      return;
    }

    await repository.logout();
    emit(state.copyWith(
      navigationTarget: () => '/phone',
      feedbackMessage: () => 'Logged out successfully',
    ));
  }

  void _onDismissTapped(
    SideMenuDismissTapped event,
    Emitter<SideMenuState> emit,
  ) {
    emit(state.copyWith(isClosed: true));
  }
}
