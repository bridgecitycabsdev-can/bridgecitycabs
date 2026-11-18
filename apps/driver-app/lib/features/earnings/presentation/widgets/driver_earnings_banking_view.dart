import 'package:flutter/material.dart';
import '../../data/models/driver_bank_details.dart';

class DriverEarningsBankingView extends StatefulWidget {
  final DriverBankDetails bankDetails;
  final bool isLoading;
  final VoidCallback onBack;
  final ValueChanged<DriverBankDetails> onSave;

  const DriverEarningsBankingView({
    super.key,
    required this.bankDetails,
    required this.isLoading,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<DriverEarningsBankingView> createState() =>
      _DriverEarningsBankingViewState();
}

class _DriverEarningsBankingViewState extends State<DriverEarningsBankingView> {
  late TextEditingController _holderController;
  late TextEditingController _instController;
  late TextEditingController _transitController;
  late TextEditingController _accountController;
  late bool _isConfirmed;

  @override
  void initState() {
    super.initState();
    _holderController = TextEditingController(
      text: widget.bankDetails.accountHolderName,
    );
    _instController = TextEditingController(
      text: widget.bankDetails.institutionNumber,
    );
    _transitController = TextEditingController(
      text: widget.bankDetails.transitNumber,
    );
    _accountController = TextEditingController(
      text: widget.bankDetails.accountNumber,
    );
    _isConfirmed = widget.bankDetails.isConfirmed;
  }

  @override
  void dispose() {
    _holderController.dispose();
    _instController.dispose();
    _transitController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  String _detectBankName(String inst) {
    switch (inst) {
      case '001':
        return 'Bank of Montreal (BMO)';
      case '002':
        return 'Scotiabank';
      case '003':
        return 'RBC Royal Bank';
      case '004':
        return 'TD Canada Trust';
      case '006':
        return 'National Bank';
      case '010':
        return 'CIBC';
      case '016':
        return 'HSBC Canada';
      case '030':
        return 'Canadian Western Bank';
      case '899':
        return 'ATB Financial';
      default:
        return 'Canadian Institution';
    }
  }

  void _submit() {
    final updated = widget.bankDetails.copyWith(
      accountHolderName: _holderController.text.trim(),
      institutionNumber: _instController.text.trim(),
      bankName: _detectBankName(_instController.text.trim()),
      transitNumber: _transitController.text.trim(),
      accountNumber: _accountController.text.trim(),
      maskedAccount: _accountController.text.length >= 4
          ? '•••• ${_accountController.text.substring(_accountController.text.length - 4)}'
          : '•••• 4821',
      isConfirmed: _isConfirmed,
      isVerified: true,
    );
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final bankName = _detectBankName(_instController.text.trim());

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Direct Deposit Banking',
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
            // Security Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Direct Deposit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '256-bit Canadian banking encryption',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Sample Canadian Cheque Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCFD8DC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _holderController.text.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF455A64),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        'CHQ #0142',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF78909C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Cheque watermark / lines
                  Container(
                    height: 1,
                    color: const Color(0xFFECEFF1),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Sample Canadian Cheque (MICR Guide)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // MICR Numbers with highlight chips
                  Row(
                    children: [
                      // Transit
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCDD2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE57373)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _transitController.text.isEmpty
                                  ? '04212'
                                  : _transitController.text,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                            const Text(
                              'Transit (5)',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Institution
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCFD8DC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF90A4AE)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _instController.text.isEmpty
                                  ? '003'
                                  : _instController.text,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF263238),
                              ),
                            ),
                            const Text(
                              'Institution (3)',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF263238),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Account
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEFF1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFB0BEC5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _accountController.text.isEmpty
                                    ? '1048219'
                                    : _accountController.text,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF37474F),
                                ),
                              ),
                              const Text(
                                'Account #',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF546E7A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form Field 1: Account holder name
            _buildField(
              label: 'Account holder name',
              controller: _holderController,
              onChanged: (val) => setState(() {}),
              suffix: const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ),
            const SizedBox(height: 14),

            // Form Field 2: Institution number (3 digits)
            _buildField(
              label: 'Institution number (3 digits)',
              controller: _instController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              onChanged: (val) => setState(() {}),
              suffix: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bankName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Form Field 3: Transit number (5 digits)
            _buildField(
              label: 'Transit number (5 digits)',
              controller: _transitController,
              keyboardType: TextInputType.number,
              maxLength: 5,
              onChanged: (val) => setState(() {}),
              suffix: const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ),
            const SizedBox(height: 14),

            // Form Field 4: Account number (7 to 12 digits)
            _buildField(
              label: 'Account number (7 to 12 digits)',
              controller: _accountController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              onChanged: (val) => setState(() {}),
              suffix: const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ),
            const SizedBox(height: 14),

            // Checkbox confirmation
            InkWell(
              onTap: () => setState(() => _isConfirmed = !_isConfirmed),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isConfirmed,
                    activeColor: const Color(0xFFB71C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) =>
                        setState(() => _isConfirmed = val ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'I confirm these details are correct and belong to the registered driver ${_holderController.text}.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.isLoading || !_isConfirmed ? null : _submit,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white, size: 20),
                label: Text(
                  widget.isLoading
                      ? 'Saving...'
                      : 'Save banking information',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Notice
            const Center(
              child: Text(
                'Payments are disbursed bi-weekly on Mondays.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                  buildCounter: (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                      null,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ],
      ),
    );
  }
}
