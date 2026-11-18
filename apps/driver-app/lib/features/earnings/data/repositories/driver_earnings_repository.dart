import '../models/driver_bank_details.dart';
import '../models/driver_earnings_config.dart';
import '../models/driver_earnings_period.dart';
import '../models/driver_earnings_summary.dart';
import '../models/driver_payout_statement.dart';

abstract class DriverEarningsRepository {
  Future<DriverEarningsSummary> fetchEarningsSummary(DriverEarningsPeriod period);
  Future<bool> saveBankDetails(DriverBankDetails details);
  Future<DriverPayoutStatement> fetchStatementDetail(String statementId);
  Future<String> downloadPdfStatement(String statementId);
}

class FakeDriverEarningsRepository implements DriverEarningsRepository {
  final Duration latency;

  FakeDriverEarningsRepository({
    this.latency = const Duration(milliseconds: 200),
  });

  @override
  Future<DriverEarningsSummary> fetchEarningsSummary(DriverEarningsPeriod period) async {
    await Future.delayed(latency);
    return DriverEarningsConfig.overviewPreset().copyWith(period: period);
  }

  @override
  Future<bool> saveBankDetails(DriverBankDetails details) async {
    await Future.delayed(latency);
    return true;
  }

  @override
  Future<DriverPayoutStatement> fetchStatementDetail(String statementId) async {
    await Future.delayed(latency);
    return DriverEarningsConfig.statementDetailPreset();
  }

  @override
  Future<String> downloadPdfStatement(String statementId) async {
    await Future.delayed(latency);
    return 'https://bridgecity.ca/statements/$statementId.pdf';
  }
}
