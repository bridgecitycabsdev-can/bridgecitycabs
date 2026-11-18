import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_menu_config.dart';
import '../data/models/driver_menu_item.dart';
import '../data/models/driver_menu_status.dart';
import '../data/repositories/driver_menu_repository.dart';
import 'driver_menu_event.dart';
import 'driver_menu_state.dart';

class DriverMenuBloc extends Bloc<DriverMenuEvent, DriverMenuState> {
  final DriverMenuRepository repository;

  DriverMenuBloc({required this.repository})
      : super(DriverMenuState.initial()) {
    on<DriverMenuStarted>(_onStarted);
    on<DriverMenuItemSelected>(_onItemSelected);
    on<DriverMenuLogoutPressed>(_onLogoutPressed);
    on<DriverMenuLogoutCancelled>(_onLogoutCancelled);
    on<DriverMenuLogoutConfirmed>(_onLogoutConfirmed);
    on<DriverMenuContactSupportPressed>(_onContactSupportPressed);
    on<DriverMenuCallHubPressed>(_onCallHubPressed);
    on<DriverMenuDrawerClosed>(_onDrawerClosed);
    on<DriverMenuStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverMenuStarted event,
    Emitter<DriverMenuState> emit,
  ) {
    add(DriverMenuStateForced(event.initialStatus));
  }

  void _onItemSelected(
    DriverMenuItemSelected event,
    Emitter<DriverMenuState> emit,
  ) {
    final targetItem = state.menuItems.firstWhere(
      (item) => item.id == event.itemId,
      orElse: () => DriverMenuItemState(id: event.itemId),
    );

    if (targetItem.isLocked) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Locked features will activate upon municipal compliance approval.',
        ),
      );
      return;
    }

    final updatedItems = state.menuItems.map((item) {
      return item.copyWith(isSelected: item.id == event.itemId);
    }).toList();

    final route = switch (event.itemId) {
      DriverMenuItemId.profile => '/profile',
      DriverMenuItemId.earnings => '/earnings',
      DriverMenuItemId.history => '/history',
      DriverMenuItemId.reviews => '/reviews',
      DriverMenuItemId.settings => '/settings',
      DriverMenuItemId.flagRide => '/flag-ride',
    };

    emit(
      state.copyWith(
        menuItems: updatedItems,
        selectedRouteTarget: route,
        feedbackMessage: 'Opening ${event.itemId.label}...',
      ),
    );
  }

  void _onLogoutPressed(
    DriverMenuLogoutPressed event,
    Emitter<DriverMenuState> emit,
  ) {
    if (state.status == DriverMenuStatus.activeTrip) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Finish current trip before logging out. Unit 42 is on active dispatch.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        previousStatus: state.status,
        status: DriverMenuStatus.logoutConfirmation,
      ),
    );
  }

  void _onLogoutCancelled(
    DriverMenuLogoutCancelled event,
    Emitter<DriverMenuState> emit,
  ) {
    emit(state.copyWith(status: state.previousStatus));
  }

  Future<void> _onLogoutConfirmed(
    DriverMenuLogoutConfirmed event,
    Emitter<DriverMenuState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.logoutDriver();
      emit(
        state.copyWith(
          isActionLoading: false,
          shouldNavigateToLogin: true,
          feedbackMessage: 'Logged out successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Logout failed: $e',
        ),
      );
    }
  }

  void _onContactSupportPressed(
    DriverMenuContactSupportPressed event,
    Emitter<DriverMenuState> emit,
  ) {
    emit(
      state.copyWith(
        feedbackMessage:
            'Connecting to Bridge City Support (${DriverMenuConfig.supportHelpline})...',
      ),
    );
  }

  void _onCallHubPressed(
    DriverMenuCallHubPressed event,
    Emitter<DriverMenuState> emit,
  ) {
    emit(
      state.copyWith(
        feedbackMessage:
            'Calling Bridge City Dispatch Hub (${state.activeTrip.dispatchLinePhone})...',
      ),
    );
  }

  void _onDrawerClosed(
    DriverMenuDrawerClosed event,
    Emitter<DriverMenuState> emit,
  ) {
    emit(state.copyWith(selectedRouteTarget: null));
  }

  void _onStateForced(
    DriverMenuStateForced event,
    Emitter<DriverMenuState> emit,
  ) {
    switch (event.status) {
      case DriverMenuStatus.online:
        emit(
          state.copyWith(
            status: DriverMenuStatus.online,
            previousStatus: DriverMenuStatus.online,
            profile: DriverMenuConfig.defaultProfile(),
            stats: DriverMenuConfig.onlineStats(),
            menuItems: DriverMenuConfig.defaultMenuItems(
              selectedId: DriverMenuItemId.earnings,
            ),
            isActionLoading: false,
            shouldNavigateToLogin: false,
          ),
        );
        break;
      case DriverMenuStatus.logoutConfirmation:
        emit(
          state.copyWith(
            status: DriverMenuStatus.logoutConfirmation,
            profile: DriverMenuConfig.dialogProfile(),
            stats: DriverMenuConfig.dialogStats(),
            menuItems: DriverMenuConfig.defaultMenuItems(),
            isActionLoading: false,
          ),
        );
        break;
      case DriverMenuStatus.offline:
        emit(
          state.copyWith(
            status: DriverMenuStatus.offline,
            previousStatus: DriverMenuStatus.offline,
            profile: DriverMenuConfig.defaultProfile(),
            stats: DriverMenuConfig.offlineStats(),
            menuItems: DriverMenuConfig.defaultMenuItems(
              selectedId: DriverMenuItemId.profile,
            ),
            isActionLoading: false,
            shouldNavigateToLogin: false,
          ),
        );
        break;
      case DriverMenuStatus.activeTrip:
        emit(
          state.copyWith(
            status: DriverMenuStatus.activeTrip,
            previousStatus: DriverMenuStatus.activeTrip,
            profile: DriverMenuConfig.defaultProfile(),
            stats: DriverMenuConfig.onlineStats(),
            activeTrip: DriverMenuConfig.activeTripInfo(),
            menuItems: DriverMenuConfig.defaultMenuItems(
              flagRideNotification: true,
            ),
            isActionLoading: false,
            shouldNavigateToLogin: false,
          ),
        );
        break;
      case DriverMenuStatus.underReview:
        emit(
          state.copyWith(
            status: DriverMenuStatus.underReview,
            previousStatus: DriverMenuStatus.underReview,
            profile: DriverMenuConfig.defaultProfile(),
            stats: DriverMenuConfig.offlineStats(),
            menuItems: DriverMenuConfig.defaultMenuItems(
              lockedIds: {
                DriverMenuItemId.earnings,
                DriverMenuItemId.flagRide,
              },
            ),
            isActionLoading: false,
            shouldNavigateToLogin: false,
          ),
        );
        break;
    }
  }
}
