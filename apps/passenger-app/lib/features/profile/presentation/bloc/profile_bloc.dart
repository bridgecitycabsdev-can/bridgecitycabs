import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileNotificationToggleTapped>(_onNotificationToggleTapped);
    on<ProfileEditProfileTapped>(_onEditProfileTapped);
    on<ProfileSaveEditedProfile>(_onSaveEditedProfile);
    on<ProfileLogoutTapped>(_onLogoutTapped);
    on<ProfileContactSupportTapped>(_onContactSupportTapped);
    on<ProfileOpenPaymentMethodsTapped>(_onOpenPaymentMethodsTapped);
    on<ProfileOpenNotificationsTapped>(_onOpenNotificationsTapped);
    on<ProfileOpenPrivacyTapped>(_onOpenPrivacyTapped);
    on<ProfileOpenFaqTapped>(_onOpenFaqTapped);
    on<ProfileOpenTermsTapped>(_onOpenTermsTapped);
    on<ProfileBecomeDriverTapped>(_onBecomeDriverTapped);
    on<ProfileAboutTapped>(_onAboutTapped);
    on<ProfileCallRegionalDispatchTapped>(_onCallRegionalDispatchTapped);
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = event.initialProfile ?? await _repository.getUserProfile();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        isNotificationsEnabled: user.notificationsEnabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onNotificationToggleTapped(
    ProfileNotificationToggleTapped event,
    Emitter<ProfileState> emit,
  ) async {
    final updatedUser = state.user.copyWith(notificationsEnabled: event.enabled);
    emit(state.copyWith(
      isNotificationsEnabled: event.enabled,
      user: updatedUser,
      feedbackMessage: () =>
          'Notifications ${event.enabled ? 'turned on' : 'turned off'}.',
    ));
    await _repository.toggleNotifications(event.enabled);
  }

  void _onEditProfileTapped(
    ProfileEditProfileTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(isEditing: true));
  }

  Future<void> _onSaveEditedProfile(
    ProfileSaveEditedProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      final updated = state.user.copyWith(
        fullName: event.fullName.trim(),
        email: event.email.trim(),
      );
      final saved = await _repository.updateUserProfile(updated);
      emit(state.copyWith(
        status: ProfileStatus.updateSuccess,
        user: saved,
        isEditing: false,
        feedbackMessage: () => 'Profile details updated.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onLogoutTapped(
    ProfileLogoutTapped event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loggingOut));
    await _repository.logout();
    emit(state.copyWith(
      status: ProfileStatus.loggedOut,
      feedbackMessage: () => 'Logged out of Bridge City Cabs.',
    ));
  }

  void _onContactSupportTapped(
    ProfileContactSupportTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Contacting Bridge City Support...',
    ));
  }

  void _onOpenPaymentMethodsTapped(
    ProfileOpenPaymentMethodsTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Payment Methods...',
    ));
  }

  void _onOpenNotificationsTapped(
    ProfileOpenNotificationsTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Notifications Center...',
    ));
  }

  void _onOpenPrivacyTapped(
    ProfileOpenPrivacyTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Privacy and Data...',
    ));
  }

  void _onOpenFaqTapped(
    ProfileOpenFaqTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Frequently Asked Questions...',
    ));
  }

  void _onOpenTermsTapped(
    ProfileOpenTermsTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Terms and Conditions...',
    ));
  }

  void _onBecomeDriverTapped(
    ProfileBecomeDriverTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () => 'Opening Driver Application Portal...',
    ));
  }

  void _onAboutTapped(
    ProfileAboutTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () =>
          'Bridge City Cabs • Locally operated in Lethbridge since 2012.',
    ));
  }

  void _onCallRegionalDispatchTapped(
    ProfileCallRegionalDispatchTapped event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: () =>
          'Calling Regional Phone Dispatch: (403) 327-4005...',
    ));
  }
}
