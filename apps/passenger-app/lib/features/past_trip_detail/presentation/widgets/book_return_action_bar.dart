import 'package:flutter/material.dart';

class BookReturnActionBar extends StatelessWidget {
  final bool isBookingReturn;
  final VoidCallback onGetReceipt;
  final VoidCallback onBookReturn;

  const BookReturnActionBar({
    super.key,
    this.isBookingReturn = false,
    required this.onGetReceipt,
    required this.onBookReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Get Receipt (Outlined)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGetReceipt,
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: const Text('Get Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1F2937),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Book Return (Filled Red)
            Expanded(
              child: ElevatedButton(
                onPressed: isBookingReturn ? null : onBookReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF991B1B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isBookingReturn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Book Return',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
