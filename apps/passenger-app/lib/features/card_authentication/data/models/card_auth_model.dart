import 'package:equatable/equatable.dart';

enum CardAuthStage {
  prompt3ds,
  waitingForBank,
  verified,
  declined,
  expiredCard,
  canceled;

  String get displayName {
    switch (this) {
      case CardAuthStage.prompt3ds:
        return '3D Secure Verification';
      case CardAuthStage.waitingForBank:
        return 'Waiting for Bank';
      case CardAuthStage.verified:
        return 'Card Verified';
      case CardAuthStage.declined:
        return 'Payment Authorization Error';
      case CardAuthStage.expiredCard:
        return 'Confirm Trip';
      case CardAuthStage.canceled:
        return 'Authentication Canceled';
    }
  }
}

enum AuthTestScenario {
  waiting,
  verified,
  failed,
  canceled;

  String get label {
    switch (this) {
      case AuthTestScenario.waiting:
        return '1. Waiting';
      case AuthTestScenario.verified:
        return '2. Verified';
      case AuthTestScenario.failed:
        return '3. Failed';
      case AuthTestScenario.canceled:
        return '4. Canceled';
    }
  }
}

enum EdgeCaseScenario {
  expiredCard,
  insufficientFunds,
  paymentError;

  String get label {
    switch (this) {
      case EdgeCaseScenario.expiredCard:
        return '1. Expired Card';
      case EdgeCaseScenario.insufficientFunds:
        return '2. Insufficient Funds';
      case EdgeCaseScenario.paymentError:
        return '3. Payment Error';
    }
  }
}

class AuthPaymentMethod extends Equatable {
  final String id;
  final String brand;
  final String last4;
  final String expiry;
  final String accountType;
  final bool isExpired;
  final bool isDeclined;
  final bool isBackup;
  final bool isCash;
  final String? subtitle;

  const AuthPaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    this.accountType = 'Debit card',
    this.isExpired = false,
    this.isDeclined = false,
    this.isBackup = false,
    this.isCash = false,
    this.subtitle,
  });

  String get displayTitle => isCash ? 'Cash' : '$brand •••• $last4';

  AuthPaymentMethod copyWith({
    String? id,
    String? brand,
    String? last4,
    String? expiry,
    String? accountType,
    bool? isExpired,
    bool? isDeclined,
    bool? isBackup,
    bool? isCash,
    String? subtitle,
  }) {
    return AuthPaymentMethod(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
      accountType: accountType ?? this.accountType,
      isExpired: isExpired ?? this.isExpired,
      isDeclined: isDeclined ?? this.isDeclined,
      isBackup: isBackup ?? this.isBackup,
      isCash: isCash ?? this.isCash,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brand,
        last4,
        expiry,
        accountType,
        isExpired,
        isDeclined,
        isBackup,
        isCash,
        subtitle,
      ];
}
