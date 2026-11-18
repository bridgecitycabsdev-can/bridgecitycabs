import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository repository;

  NotificationsBloc({NotificationsRepository? repository})
      : repository = repository ?? MockNotificationsRepository(),
        super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsCategoryFilterChanged>(_onCategoryFilterChanged);
    on<NotificationsMarkAllAsReadTapped>(_onMarkAllAsReadTapped);
    on<NotificationsItemTapped>(_onItemTapped);
    on<NotificationsCheckForUpdatesTapped>(_onCheckForUpdatesTapped);
    on<NotificationsRetryTapped>(_onRetryTapped);
    on<NotificationsEnablePushTapped>(_onEnablePushTapped);
    on<NotificationsDismissPermissionSheet>(_onDismissPermissionSheet);
    on<NotificationsBackTapped>(_onBackTapped);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.simulateLoading) {
      emit(state.copyWith(status: NotificationsViewStatus.loading));
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (event.initialStatus != null) {
      emit(state.copyWith(
        status: event.initialStatus!,
        items: event.initialItems ?? state.items,
        clearError: true,
      ));
      return;
    }

    try {
      final items = event.initialItems ?? await repository.fetchNotifications();
      emit(state.copyWith(
        status: items.isEmpty
            ? NotificationsViewStatus.empty
            : NotificationsViewStatus.loaded,
        items: items,
        clearError: true,
        navigateBack: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsViewStatus.offlineError,
        errorMessage: 'Unable to sync latest ride updates',
      ));
    }
  }

  void _onCategoryFilterChanged(
    NotificationsCategoryFilterChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  Future<void> _onMarkAllAsReadTapped(
    NotificationsMarkAllAsReadTapped event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.markAllAsRead();
    final updatedItems = state.items.map((item) {
      return item.copyWith(isRead: true);
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  Future<void> _onItemTapped(
    NotificationsItemTapped event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.markAsRead(event.item.id);
    final updatedItems = state.items.map((item) {
      return item.id == event.item.id ? item.copyWith(isRead: true) : item;
    }).toList();

    emit(state.copyWith(
      items: updatedItems,
      targetRoute: event.item.targetRoute,
    ));
  }

  Future<void> _onCheckForUpdatesTapped(
    NotificationsCheckForUpdatesTapped event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsViewStatus.loading));
    try {
      final items = await repository.fetchNotifications();
      emit(state.copyWith(
        status: items.isEmpty
            ? NotificationsViewStatus.empty
            : NotificationsViewStatus.loaded,
        items: items,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsViewStatus.offlineError,
        errorMessage: 'Unable to sync latest ride updates',
      ));
    }
  }

  Future<void> _onRetryTapped(
    NotificationsRetryTapped event,
    Emitter<NotificationsState> emit,
  ) async {
    add(const NotificationsCheckForUpdatesTapped());
  }

  Future<void> _onEnablePushTapped(
    NotificationsEnablePushTapped event,
    Emitter<NotificationsState> emit,
  ) async {
    await repository.enablePushNotifications();
    emit(state.copyWith(showPermissionSheet: false));
  }

  void _onDismissPermissionSheet(
    NotificationsDismissPermissionSheet event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(showPermissionSheet: false));
  }

  void _onBackTapped(
    NotificationsBackTapped event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(navigateBack: true));
  }
}
