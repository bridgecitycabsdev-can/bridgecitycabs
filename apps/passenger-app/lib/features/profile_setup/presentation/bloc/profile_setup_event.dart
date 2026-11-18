import 'package:equatable/equatable.dart';
import '../../data/models/passenger_profile.dart';

/// Base class for all profile setup events.
abstract class ProfileSetupEvent extends Equatable {
  const ProfileSetupEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on page mount to load existing or prefilled profile data.
class ProfileSetupStarted extends ProfileSetupEvent {
  final PassengerProfile? initialProfile;

  const ProfileSetupStarted({this.initialProfile});

  @override
  List<Object?> get props => [initialProfile];
}

/// Dispatched when the user alters the first name input.
class ProfileFirstNameChanged extends ProfileSetupEvent {
  final String firstName;

  const ProfileFirstNameChanged(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

/// Dispatched when the user alters the last name input.
class ProfileLastNameChanged extends ProfileSetupEvent {
  final String lastName;

  const ProfileLastNameChanged(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

/// Dispatched when the user alters the email address input.
class ProfileEmailChanged extends ProfileSetupEvent {
  final String email;

  const ProfileEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user alters the Canadian postal code input.
class ProfilePostalCodeChanged extends ProfileSetupEvent {
  final String postalCode;

  const ProfilePostalCodeChanged(this.postalCode);

  @override
  List<Object?> get props => [postalCode];
}

/// Dispatched when the user selects a gender option (Male, Female, Other).
class ProfileGenderChanged extends ProfileSetupEvent {
  final String gender;

  const ProfileGenderChanged(this.gender);

  @override
  List<Object?> get props => [gender];
}

/// Dispatched when a photo is added, edited, or removed.
class ProfilePhotoChanged extends ProfileSetupEvent {
  final String? photoUrl;

  const ProfilePhotoChanged(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

/// Dispatched when the user taps "Continue to Ride Options →".
class ProfileSubmitRequested extends ProfileSetupEvent {
  const ProfileSubmitRequested();
}

/// Dispatched when the user taps "Skip for now".
class ProfileSkipRequested extends ProfileSetupEvent {
  const ProfileSkipRequested();
}
