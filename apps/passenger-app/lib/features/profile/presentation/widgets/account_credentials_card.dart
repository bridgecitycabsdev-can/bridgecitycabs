import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';

class AccountCredentialsCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onContactSupport;

  const AccountCredentialsCard({
    super.key,
    required this.user,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACCOUNT CREDENTIALS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.lock_outline, size: 13, color: Color(0xFF6B7280)),
                  SizedBox(width: 4),
                  Text(
                    'Verified Identity',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Credential 1: Full Name
        _CredentialTile(
          icon: Icons.badge_outlined,
          label: 'FULL NAME',
          value: user.fullName,
        ),

        // Credential 2: Phone Number
        _CredentialTile(
          icon: Icons.phone_outlined,
          label: 'PHONE NUMBER',
          value: user.phoneNumber,
        ),

        // Credential 3: Email Address
        _CredentialTile(
          icon: Icons.mail_outline,
          label: 'EMAIL ADDRESS',
          value: user.email,
        ),

        // Helper Note
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  children: [
                    const Text(
                      'To change your details, ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    InkWell(
                      onTap: onContactSupport,
                      child: const Text(
                        'contact support',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      '.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _CredentialTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CredentialTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF374151)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
