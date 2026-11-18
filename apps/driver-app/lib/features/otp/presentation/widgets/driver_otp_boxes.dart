import 'package:flutter/material.dart';
import '../../data/models/driver_otp_status.dart';

class DriverOtpBoxes extends StatelessWidget {
  final DriverOtpStatus status;
  final String code;

  const DriverOtpBoxes({
    super.key,
    required this.status,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return _buildDigitBox(index);
      }),
    );
  }

  Widget _buildDigitBox(int index) {
    String displayChar = '';
    Color boxBg = const Color(0xFFF9FAFB);
    Color borderColor = const Color(0xFFE5E7EB);
    Color textColor = const Color(0xFF111827);
    bool isCursor = false;

    if (status == DriverOtpStatus.incorrect) {
      boxBg = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFCA5A5);
      textColor = const Color(0xFF991B1B);
      if (index < code.length) {
        displayChar = code[index];
      }
    } else if (status == DriverOtpStatus.expired) {
      boxBg = const Color(0xFFF3F4F6);
      borderColor = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF9CA3AF);
      if (index < code.length) {
        displayChar = code[index];
      }
    } else if (status == DriverOtpStatus.initial && code.isEmpty) {
      if (index == 0) {
        isCursor = true;
        boxBg = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFCA5A5);
      } else {
        displayChar = '-';
        textColor = const Color(0xFFD1D5DB);
      }
    } else {
      if (index < code.length) {
        displayChar = code[index];
        boxBg = Colors.white;
        borderColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF111827);
      } else if (index == code.length) {
        isCursor = true;
        boxBg = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFCA5A5);
      } else {
        displayChar = '-';
        textColor = const Color(0xFFD1D5DB);
      }
    }

    return Container(
      width: 48,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: status == DriverOtpStatus.ready || status == DriverOtpStatus.submitting
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Center(
        child: isCursor
            ? Container(
                width: 2,
                height: 22,
                color: const Color(0xFFB91C1C),
              )
            : Text(
                displayChar,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
