import 'package:equatable/equatable.dart';

enum DriverGender {
  male,
  female,
  other,
  unspecified;

  String get label {
    switch (this) {
      case DriverGender.male:
        return 'Male';
      case DriverGender.female:
        return 'Female';
      case DriverGender.other:
        return 'Other';
      case DriverGender.unspecified:
        return '';
    }
  }
}

class DriverRegisterStep1Data extends Equatable {
  final bool hasPhoto;
  final String? photoUrl;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isPhoneVerified;
  final String driverLicenceNumber;
  final String postalCode;
  final DriverGender gender;

  const DriverRegisterStep1Data({
    this.hasPhoto = false,
    this.photoUrl,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '+1 (403) 555-0192',
    this.isPhoneVerified = true,
    this.driverLicenceNumber = '',
    this.postalCode = '',
    this.gender = DriverGender.unspecified,
  });

  bool get isFirstNameValid => firstName.trim().isNotEmpty;
  bool get isLastNameValid => lastName.trim().isNotEmpty;

  bool get isEmailValid {
    if (email.trim().isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  bool get isLicenceValid {
    final cleaned = driverLicenceNumber.replaceAll(RegExp(r'[\s-]'), '');
    return cleaned.length >= 6;
  }

  bool get isPostalCodeValid {
    final cleaned = postalCode.replaceAll(' ', '').toUpperCase();
    return RegExp(r'^[A-Z]\d[A-Z]\d[A-Z]\d$').hasMatch(cleaned);
  }

  bool get isFormValid =>
      hasPhoto &&
      isFirstNameValid &&
      isLastNameValid &&
      isEmailValid &&
      isLicenceValid &&
      isPostalCodeValid;

  DriverRegisterStep1Data copyWith({
    bool? hasPhoto,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? isPhoneVerified,
    String? driverLicenceNumber,
    String? postalCode,
    DriverGender? gender,
  }) {
    return DriverRegisterStep1Data(
      hasPhoto: hasPhoto ?? this.hasPhoto,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      driverLicenceNumber: driverLicenceNumber ?? this.driverLicenceNumber,
      postalCode: postalCode ?? this.postalCode,
      gender: gender ?? this.gender,
    );
  }

  @override
  List<Object?> get props => [
        hasPhoto,
        photoUrl,
        firstName,
        lastName,
        email,
        phone,
        isPhoneVerified,
        driverLicenceNumber,
        postalCode,
        gender,
      ];
}
