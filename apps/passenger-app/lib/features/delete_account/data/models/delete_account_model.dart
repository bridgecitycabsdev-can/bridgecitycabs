import 'package:equatable/equatable.dart';

enum DeleteAccountStep {
  warning,          // Screen 1: Delete Account Warning
  verification,     // Screen 2: Security Verification & 2FA
  requestedResult,  // Screen 3: Deletion requested confirmation
  safeguardsMatrix, // Screen 4: Account Safeguards Matrix
}

enum LeavingReason {
  dontUseApp("I don't use the app"),
  privacyConcerns('Privacy concerns'),
  hadBadExperience('Had a bad experience'),
  prices('Prices'),
  other('Other');

  final String label;
  const LeavingReason(this.label);
}

enum AccountSafeguardState {
  none,
  state1ActiveTrip,
  state2UnpaidBalance,
  state3IncorrectPin,
  state4ExpiredCode,
  state5SystemError,
  state6Offline,
  state7MutatingLock;

  String get label {
    switch (this) {
      case AccountSafeguardState.none:
        return 'Show All (7)';
      case AccountSafeguardState.state1ActiveTrip:
        return '1. Live Trip';
      case AccountSafeguardState.state2UnpaidBalance:
        return '2. Unpaid Trip';
      case AccountSafeguardState.state3IncorrectPin:
        return '3. Wrong PIN';
      case AccountSafeguardState.state4ExpiredCode:
        return '4. Expired Code';
      case AccountSafeguardState.state5SystemError:
        return '5. HTTP Error';
      case AccountSafeguardState.state6Offline:
        return '6. Offline';
      case AccountSafeguardState.state7MutatingLock:
        return '7. State Lock';
    }
  }
}

class DeletionRequestResult extends Equatable {
  final String targetDeletionDate;
  final String verifiedPhone;
  final int gracePeriodDays;

  const DeletionRequestResult({
    this.targetDeletionDate = '30 Nov 2026',
    this.verifiedPhone = '+1 403-•••-••17',
    this.gracePeriodDays = 30,
  });

  @override
  List<Object?> get props => [targetDeletionDate, verifiedPhone, gracePeriodDays];
}

class ActiveTripBlockerInfo extends Equatable {
  final String vehicleModel;
  final String driverName;
  final int minutesToDropoff;
  final String dropoffStreet;

  const ActiveTripBlockerInfo({
    this.vehicleModel = 'Toyota Camry SE',
    this.driverName = 'Michael R.',
    this.minutesToDropoff = 3,
    this.dropoffStreet = '4th Ave S',
  });

  @override
  List<Object?> get props => [vehicleModel, driverName, minutesToDropoff, dropoffStreet];
}

class UnpaidBalanceBlockerInfo extends Equatable {
  final String tripReference;
  final double amountCad;
  final String statusLabel;
  final String routeDescription;

  const UnpaidBalanceBlockerInfo({
    this.tripReference = '#BC-8842',
    this.amountCad = 22.10,
    this.statusLabel = 'Cash collection pending',
    this.routeDescription = 'Lethbridge Downtown ➔ West Highlands',
  });

  String get formattedAmount => '\$${amountCad.toStringAsFixed(2)} CAD';

  @override
  List<Object?> get props => [tripReference, amountCad, statusLabel, routeDescription];
}
