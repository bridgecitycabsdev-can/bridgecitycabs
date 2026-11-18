import 'package:flutter/material.dart';
import '../../data/models/delete_account_config.dart';
import '../../data/models/delete_account_model.dart';

class AccountSafeguardsMatrixView extends StatelessWidget {
  final AccountSafeguardState selectedSafeguard;
  final ActiveTripBlockerInfo activeTrip;
  final UnpaidBalanceBlockerInfo unpaidBalance;
  final ValueChanged<AccountSafeguardState> onSafeguardSelected;
  final VoidCallback onGoToTrip;
  final VoidCallback onViewReceiptAndPay;
  final VoidCallback onContactSupport;

  const AccountSafeguardsMatrixView({
    super.key,
    required this.selectedSafeguard,
    required this.activeTrip,
    required this.unpaidBalance,
    required this.onSafeguardSelected,
    required this.onGoToTrip,
    required this.onViewReceiptAndPay,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ACCOUNT SAFEGUARDS MATRIX • Interactive Preview',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Protective checkpoints preventing accidental data loss or disruption during account termination.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AccountSafeguardState.values.map((state) {
                final isSelected = selectedSafeguard == state;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSafeguardSelected(state),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        state.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // State 6: Offline Banner
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state6Offline) ...[
            _buildSectionHeader('State 6 · Network Disconnected', 'Global Banner'),
            _buildOfflineCard(),
            const SizedBox(height: 16),
          ],

          // State 1: Active Transit Safeguard
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state1ActiveTrip) ...[
            _buildSectionHeader('State 1 · Active Transit Safeguard', 'Action Blocked', isRedBadge: true),
            _buildActiveTripCard(),
            const SizedBox(height: 16),
          ],

          // State 2: Ledger Balance Safeguard
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state2UnpaidBalance) ...[
            _buildSectionHeader('State 2 · Ledger Balance Safeguard', 'Settlement Required', isOrangeBadge: true),
            _buildUnpaidBalanceCard(),
            const SizedBox(height: 16),
          ],

          // State 3: Validation Conflict (Incorrect PIN)
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state3IncorrectPin) ...[
            _buildSectionHeader('State 3 · Validation Conflict', 'Incorrect PIN', isRedBadge: true),
            _buildIncorrectPinCard(),
            const SizedBox(height: 16),
          ],

          // State 4: Session Timeout (Expired Token)
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state4ExpiredCode) ...[
            _buildSectionHeader('State 4 · Session Timeout', 'Expired Token'),
            _buildExpiredTokenCard(),
            const SizedBox(height: 16),
          ],

          // State 5: System Level Exception (HTTP 500 / Timeout)
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state5SystemError) ...[
            _buildSectionHeader('State 5 · System Level Exception', 'HTTP 500 / Timeout', isRedBadge: true),
            _buildSystemErrorCard(),
            const SizedBox(height: 16),
          ],

          // State 7: Mutating State Lock
          if (selectedSafeguard == AccountSafeguardState.none ||
              selectedSafeguard == AccountSafeguardState.state7MutatingLock) ...[
            _buildSectionHeader('State 7 · Mutating State Lock', 'Locked Inputs'),
            _buildMutatingLockCard(),
            const SizedBox(height: 16),
          ],

          // Footer
          const Center(
            child: Text(
              '🛡 Bridge City Cabs Lethbridge • Alberta Transport Compliance & Privacy',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badgeText, {bool isRedBadge = false, bool isOrangeBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isRedBadge
                  ? const Color(0xFFFEE2E2)
                  : (isOrangeBadge ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isRedBadge
                    ? const Color(0xFFDC2626)
                    : (isOrangeBadge ? const Color(0xFFD97706) : const Color(0xFF4B5563)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're offline",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                ),
                Text(
                  'Reconnect to continue account deletion.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF3C7),
              foregroundColor: const Color(0xFF92400E),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_car, color: Color(0xFFDC2626), size: 18),
              SizedBox(width: 8),
              Text(
                'Active trip in progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'You have a trip currently underway. Finish it before deleting your account to ensure driver safety and fair billing.',
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.35),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_taxi, color: Color(0xFF4B5563), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${activeTrip.vehicleModel} - ${activeTrip.driverName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                      ),
                      Text(
                        '● ${activeTrip.minutesToDropoff} mins from dropoff - ${activeTrip.dropoffStreet}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onGoToTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              icon: const Icon(Icons.warning_amber, size: 16),
              label: const Text('Go to my trip', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 8),
              Text(
                'Outstanding balance pending',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'You have an unpaid trip. Complete the payment before deleting your account to clear your passenger record.',
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.35),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRIP REFERENCE ${unpaidBalance.tripReference}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      unpaidBalance.statusLabel,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  unpaidBalance.formattedAmount,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                ),
                Text(
                  unpaidBalance.routeDescription,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onViewReceiptAndPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              icon: const Icon(Icons.payment, size: 16),
              label: const Text('View receipt & pay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncorrectPinCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter confirmation PIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 2),
          const Text(
            'We sent a 6-digit authorization code to +1 (403) •••-0481 to confirm permanent deletion.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['9', '2', '0', '4', '1', '8'].map((digit) {
              return Container(
                width: 42,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text(
                      'Incorrect code. Please try again.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
                Text(
                  'Resend code',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              child: const Text('Confirm Deletion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredTokenCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_off_outlined, color: Color(0xFF4B5563), size: 18),
              SizedBox(width: 8),
              Text(
                'Verification code expired',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Code expired after 10 minutes to protect your account. Generated security tokens are single-use only.',
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                    SizedBox(width: 6),
                    Text('Token generated at 14:22 MDT', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
                Text('00:00 remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Resend new code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemErrorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
              SizedBox(width: 8),
              Text(
                'Request could not be completed',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "We couldn't process your request due to a server connection timeout. Your profile, trip receipts, and payment credentials remain untouched.",
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.35),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try again', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: onContactSupport,
              child: const Text(
                'Contact support (${DeleteAccountConfig.supportPhone})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutatingLockCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Final Verification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 2),
          const Text(
            'Releasing stored tokens, clearing cached payment instruments, and finalizing data purge.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inputs locked during transaction', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                disabledBackgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  ),
                  SizedBox(width: 8),
                  Text('Verifying & deleting...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
