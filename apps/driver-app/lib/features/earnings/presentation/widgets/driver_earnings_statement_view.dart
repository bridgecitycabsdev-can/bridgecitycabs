import 'package:flutter/material.dart';
import '../../data/models/driver_payout_statement.dart';

class DriverEarningsStatementView extends StatelessWidget {
  final DriverPayoutStatement statement;
  final VoidCallback onBack;
  final VoidCallback onDownloadPdf;

  const DriverEarningsStatementView({
    super.key,
    required this.statement,
    required this.onBack,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: onBack,
        ),
        title: const Text(
          'Statement Detail',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Payout Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B0000), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB71C1C).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay Period: ${statement.periodLabel}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${statement.netPayout.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statement.paidDateText ?? 'Paid',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA5D6A7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statement.bankAccountText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payout Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payout Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildBreakdownRow(
                    'Gross fares',
                    '\$${statement.grossFares.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  _buildBreakdownRow(
                    'Tips (100% kept)',
                    '+\$${statement.tips.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 10),
                  _buildBreakdownRow(
                    'Bridge City Cabs fee (15%)',
                    '-\$${statement.platformFee.abs().toStringAsFixed(2)}',
                    valueColor: const Color(0xFFC62828),
                  ),
                  const SizedBox(height: 10),
                  _buildBreakdownRow(
                    'GST / Provincial Tax remitted',
                    '-\$${statement.taxRemitted.abs().toStringAsFixed(2)}',
                    valueColor: const Color(0xFFC62828),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  _buildBreakdownRow(
                    'Net Payout',
                    '\$${statement.netPayout.toStringAsFixed(2)}',
                    isBold: true,
                    fontSize: 15,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  _buildBreakdownRow(
                    'Cash collected in cab',
                    '\$${statement.cashCollectedByDriver.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  _buildBreakdownRow(
                    'Card disbursed to bank',
                    '\$${statement.cardDisbursed.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF1565C0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Completed Trips
            const Text(
              'Trips in Statement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),

            ...statement.trips.map((trip) {
              final isCard = trip.paymentType.toLowerCase() == 'card';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF0EBEB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCard
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCard
                            ? Icons.credit_card_rounded
                            : Icons.attach_money_rounded,
                        color: isCard
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF388E3C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.timestampText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${trip.pickupAddress} → ${trip.dropoffAddress}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${trip.fareCad.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Download PDF Statement Button
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onDownloadPdf,
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFFB71C1C),
                ),
                label: const Text(
                  'Download PDF Statement',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Footer
            const Center(
              child: Text(
                'Official tax invoice issued by Bridge City Cabs Ltd. • Lethbridge, AB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF1E1E1E) : const Color(0xFF616161),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ??
                (isBold ? const Color(0xFF1E1E1E) : const Color(0xFF212121)),
          ),
        ),
      ],
    );
  }
}
