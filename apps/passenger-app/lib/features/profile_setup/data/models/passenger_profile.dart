import 'package:equatable/equatable.dart';
import 'canadian_postal_code.dart';

/// Data model representing a verified passenger profile.
class PassengerProfile extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String postalCode;
  final String gender;
  final String? photoUrl;

  const PassengerProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.postalCode,
    this.gender = 'Female',
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  /// Detects verified institutional emails (e.g. University of Lethbridge or Lethbridge College).
  String? get verifiedInstitutionTag {
    final lower = email.trim().toLowerCase();
    if (lower.endsWith('@uleth.ca')) {
      return 'U of Lethbridge verified';
    } else if (lower.endsWith('@lethbridgecollege.ca')) {
      return 'Lethbridge College verified';
    }
    return null;
  }

  /// Resolves Lethbridge neighborhood name (e.g. "West Lethbridge").
  String? get neighborhoodTag =>
      CanadianPostalCode.resolveRegion(postalCode);

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  PassengerProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? postalCode,
    String? gender,
    String? photoUrl,
  }) {
    return PassengerProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      postalCode: postalCode ?? this.postalCode,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        postalCode,
        gender,
        photoUrl,
      ];
}
