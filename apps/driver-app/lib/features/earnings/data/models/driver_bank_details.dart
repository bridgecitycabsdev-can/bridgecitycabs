import 'package:equatable/equatable.dart';

class DriverBankDetails extends Equatable {
  final String accountHolderName;
  final String institutionNumber;
  final String bankName;
  final String transitNumber;
  final String accountNumber;
  final String maskedAccount;
  final bool isVerified;
  final bool isConfirmed;

  const DriverBankDetails({
    this.accountHolderName = 'Marcus Vance',
    this.institutionNumber = '003',
    this.bankName = 'RBC Royal Bank',
    this.transitNumber = '04212',
    this.accountNumber = '1048219',
    this.maskedAccount = '•••• 4821',
    this.isVerified = true,
    this.isConfirmed = true,
  });

  DriverBankDetails copyWith({
    String? accountHolderName,
    String? institutionNumber,
    String? bankName,
    String? transitNumber,
    String? accountNumber,
    String? maskedAccount,
    bool? isVerified,
    bool? isConfirmed,
  }) {
    return DriverBankDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      institutionNumber: institutionNumber ?? this.institutionNumber,
      bankName: bankName ?? this.bankName,
      transitNumber: transitNumber ?? this.transitNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      maskedAccount: maskedAccount ?? this.maskedAccount,
      isVerified: isVerified ?? this.isVerified,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  List<Object?> get props => [
    accountHolderName,
    institutionNumber,
    bankName,
    transitNumber,
    accountNumber,
    maskedAccount,
    isVerified,
    isConfirmed,
  ];
}
