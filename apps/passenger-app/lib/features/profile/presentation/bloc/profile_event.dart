import 'package:equatable/equatable.dart';
import '../../data/models/user_profile_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  final UserProfile? initialProfile;
  const ProfileStarted({this.initialProfile});

  @override
  List<Object?> get props => [initialProfile];
}

class ProfileNotificationToggleTapped extends ProfileEvent {
  final bool enabled;
  const ProfileNotificationToggleTapped(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ProfileEditProfileTapped extends ProfileEvent {
  const ProfileEditProfileTapped();
}

class ProfileSaveEditedProfile extends ProfileEvent {
  final String fullName;
  final String email;

  const ProfileSaveEditedProfile({
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [fullName, email];
}

class ProfileLogoutTapped extends ProfileEvent {
  const ProfileLogoutTapped();
}

class ProfileContactSupportTapped extends ProfileEvent {
  const ProfileContactSupportTapped();
}

class ProfileOpenPaymentMethodsTapped extends ProfileEvent {
  const ProfileOpenPaymentMethodsTapped();
}

class ProfileOpenNotificationsTapped extends ProfileEvent {
  const ProfileOpenNotificationsTapped();
}

class ProfileOpenPrivacyTapped extends ProfileEvent {
  const ProfileOpenPrivacyTapped();
}

class ProfileOpenFaqTapped extends ProfileEvent {
  const ProfileOpenFaqTapped();
}

class ProfileOpenTermsTapped extends ProfileEvent {
  const ProfileOpenTermsTapped();
}

class ProfileBecomeDriverTapped extends ProfileEvent {
  const ProfileBecomeDriverTapped();
}

class ProfileAboutTapped extends ProfileEvent {
  const ProfileAboutTapped();
}

class ProfileCallRegionalDispatchTapped extends ProfileEvent {
  const ProfileCallRegionalDispatchTapped();
}
