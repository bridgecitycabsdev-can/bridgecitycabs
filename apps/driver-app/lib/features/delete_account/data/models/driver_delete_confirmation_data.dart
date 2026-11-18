import 'package:equatable/equatable.dart';

class DriverDeleteConfirmationData extends Equatable {
  final String fleetUnit;
  final String deletionTargetDate;
  final double finalPayoutAmount;
  final String finalPayoutDate;
  final String bankAccountMasked;
  final int gracePeriodDays;
  final String driverRating;
  final String depotPhone;

  const DriverDeleteConfirmationData({
    this.fleetUnit = 'BRIDGE CITY FLEET #408 • LETHBRIDGE, AB',
    this.deletionTargetDate = '30 Nov 2026',
    this.finalPayoutAmount = 342.60,
    this.finalPayoutDate = 'Fri, 20 Nov 2026',
    this.bankAccountMasked = 'RBC Royal Bank account (•••• 8219)',
    this.gracePeriodDays = 30,
    this.driverRating = '4.96★',
    this.depotPhone = '(403) 555-0199',
  });

  DriverDeleteConfirmationData copyWith({
    String? fleetUnit,
    String? deletionTargetDate,
    double? finalPayoutAmount,
    String? finalPayoutDate,
    String? bankAccountMasked,
    int? gracePeriodDays,
    String? driverRating,
    String? depotPhone,
  }) {
    return DriverDeleteConfirmationData(
      fleetUnit: fleetUnit ?? this.fleetUnit,
      deletionTargetDate: deletionTargetDate ?? this.deletionTargetDate,
      finalPayoutAmount: finalPayoutAmount ?? this.finalPayoutAmount,
      finalPayoutDate: finalPayoutDate ?? this.finalPayoutDate,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      driverRating: driverRating ?? this.driverRating,
      depotPhone: depotPhone ?? this.depotPhone,
    );
  }

  @override
  List<Object?> get props => [
        fleetUnit,
        deletionTargetDate,
        finalPayoutAmount,
        finalPayoutDate,
        bankAccountMasked,
        gracePeriodDays,
        driverRating,
        depotPhone,
      ];
}
