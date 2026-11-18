import 'package:equatable/equatable.dart';
import '../../data/models/canadian_postal_code.dart';
import '../../data/models/passenger_profile.dart';

enum ProfileSetupStatus {
  /// User editing form, not yet submitted.
  editing,

  /// All required fields are valid and profile is ready for first booking (Screen 2).
  valid,

  /// One or more required fields have validation errors (Screen 3).
  invalid,

  /// Submitting profile data to backend.
  submitting,

  /// Profile saved successfully, triggers navigation to ride options.
  success,

  /// User selected "Skip for now", triggers navigation.
  skipped,
}

/// State for the Profile Setup form.
class ProfileSetupState extends Equatable {
  final ProfileSetupStatus status;
  final PassengerProfile profile;
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? postalCodeError;
  final bool hasAttemptedSubmit;
  final String? targetRoute;

  const ProfileSetupState({
    required this.status,
    required this.profile,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.postalCodeError,
    this.hasAttemptedSubmit = false,
    this.targetRoute,
  });

  bool get isValid => status == ProfileSetupStatus.valid;
  bool get isInvalid => status == ProfileSetupStatus.invalid;
  bool get isSubmitting => status == ProfileSetupStatus.submitting;
  bool get isSuccess => status == ProfileSetupStatus.success;
  bool get isSkipped => status == ProfileSetupStatus.skipped;

  /// Counts current active validation errors.
  int get errorCount {
    var count = 0;
    if (firstNameError != null) count++;
    if (lastNameError != null) count++;
    if (emailError != null) count++;
    if (postalCodeError != null) count++;
    return count;
  }

  bool get hasErrors => errorCount > 0;

  bool get canSubmit =>
      profile.firstName.trim().isNotEmpty &&
      profile.lastName.trim().isNotEmpty &&
      profile.email.trim().isNotEmpty &&
      CanadianPostalCode.isValid(profile.postalCode) &&
      !isSubmitting;

  ProfileSetupState copyWith({
    ProfileSetupStatus? status,
    PassengerProfile? profile,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? postalCodeError,
    bool? hasAttemptedSubmit,
    String? targetRoute,
    bool clearFirstNameError = false,
    bool clearLastNameError = false,
    bool clearEmailError = false,
    bool clearPostalCodeError = false,
  }) {
    return ProfileSetupState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      firstNameError:
          clearFirstNameError ? null : (firstNameError ?? this.firstNameError),
      lastNameError:
          clearLastNameError ? null : (lastNameError ?? this.lastNameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      postalCodeError: clearPostalCodeError
          ? null
          : (postalCodeError ?? this.postalCodeError),
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        firstNameError,
        lastNameError,
        emailError,
        postalCodeError,
        hasAttemptedSubmit,
        targetRoute,
      ];
}
