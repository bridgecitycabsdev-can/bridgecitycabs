import 'package:flutter/material.dart';
import '../../data/models/splash_config.dart';

/// Secondary action box in the Connection Interrupted modal:
/// Displays the urgent phone dispatch hotline for passengers needing an immediate cab.
class UrgentContactBox extends StatelessWidget {
  final VoidCallback onTap;

  const UrgentContactBox({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_taxi_rounded,
                    color: Color(0xFFB71C1C),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    SplashConfig.urgentCabHeader,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                SplashConfig.urgentCabPhoneDisplay,
                style: const TextStyle(
                  color: Color(0xFF980F1B),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
