import 'driver_bank_details.dart';
import 'driver_earnings_period.dart';
import 'driver_earnings_summary.dart';
import 'driver_payment_split.dart';
import 'driver_payout_statement.dart';

class DriverEarningsConfig {
  const DriverEarningsConfig._();

  static DriverEarningsSummary overviewPreset() {
    return const DriverEarningsSummary(
      driverName: 'Shajil',
      period: DriverEarningsPeriod.thisWeek,
      totalEarnings: 53.93,
      tips: 0.00,
      totalRides: 2,
      totalDistanceKm: 11.0,
      zoneLabel: 'Lethbridge Zone',
      periodDateRange: 'Jun 24 - Jun 30',
      split: DriverPaymentSplit(
        cashAmount: 29.43,
        cashPercent: 55,
        cardAmount: 24.50,
        cardPercent: 45,
        totalTrips: 2,
      ),
      bankDetails: DriverBankDetails(
        accountHolderName: 'Marcus Vance',
        institutionNumber: '003',
        bankName: 'RBC Royal Bank',
        transitNumber: '04212',
        accountNumber: '1048219',
        maskedAccount: '•••• 4821',
        isVerified: true,
      ),
    );
  }

  static DriverBankDetails bankingFormPreset() {
    return const DriverBankDetails(
      accountHolderName: 'Marcus Vance',
      institutionNumber: '003',
      bankName: 'RBC Royal Bank',
      transitNumber: '04212',
      accountNumber: '1048219',
      maskedAccount: '•••• 4821',
      isVerified: true,
      isConfirmed: true,
    );
  }

  static DriverPayoutStatement statementDetailPreset() {
    return const DriverPayoutStatement(
      id: 'stmt_jun_30_full',
      periodLabel: '16 Jun – 30 Jun, 2024',
      netPayout: 341.49,
      statusLabel: 'PAID',
      paidDateText: 'Paid on Jul 03, 2024',
      bankAccountText: 'Deposited to RBC Royal Bank •••• 4821',
      grossFares: 392.50,
      tips: 18.00,
      platformFee: -58.88,
      taxRemitted: -10.13,
      cashCollectedByDriver: 112.50,
      cardDisbursed: 228.99,
      tripCount: 12,
    );
  }
}
