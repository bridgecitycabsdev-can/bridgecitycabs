import 'package:flutter/material.dart';
import '../../data/models/driver_credential_model.dart';
import '../../data/models/driver_profile_status.dart';

class DriverProfileDocumentsTab extends StatelessWidget {
  final List<DriverCredentialModel> credentials;
  final DriverProfileStatus status;
  final ValueChanged<DriverCredentialModel> onCredentialTap;
  final ValueChanged<String> onUploadRequested;
  final VoidCallback onCallDesk;
  final VoidCallback onUpdateDocuments;

  const DriverProfileDocumentsTab({
    super.key,
    required this.credentials,
    required this.status,
    required this.onCredentialTap,
    required this.onUploadRequested,
    required this.onCallDesk,
    required this.onUpdateDocuments,
  });

  @override
  Widget build(BuildContext context) {
    final hasExpired = credentials.any(
      (c) => c.status == DriverCredentialStatus.expired,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Required Credentials',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            Text(
              hasExpired ? '1 EXPIRED' : '3 of 4 Verified',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: hasExpired
                    ? const Color(0xFFC62828)
                    : const Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Credential Cards
        ...credentials.map((cred) => _buildCredentialCard(cred)),
        const SizedBox(height: 14),

        // Support Operations Desk Box
        _buildDispatchDeskBox(),
        const SizedBox(height: 16),

        // Bottom CTA Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onUpdateDocuments,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Update Documents to Go Online',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Approvals typically take 15–30 minutes during shift hours',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCredentialCard(DriverCredentialModel cred) {
    Color badgeBg;
    Color badgeColor;
    String badgeText = cred.status.label;

    switch (cred.status) {
      case DriverCredentialStatus.expired:
        badgeBg = const Color(0xFFC62828);
        badgeColor = Colors.white;
        break;
      case DriverCredentialStatus.expiringSoon:
        badgeBg = const Color(0xFFFFF3E0);
        badgeColor = const Color(0xFFE65100);
        break;
      case DriverCredentialStatus.approved:
      case DriverCredentialStatus.valid:
        badgeBg = const Color(0xFFE8F5E9);
        badgeColor = const Color(0xFF2E7D32);
        break;
      case DriverCredentialStatus.inReview:
        badgeBg = const Color(0xFFEEEEEE);
        badgeColor = Colors.black87;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cred.status == DriverCredentialStatus.expired
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cred.status == DriverCredentialStatus.expired
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  cred.title.contains('Licence')
                      ? Icons.badge_outlined
                      : cred.title.contains('registration')
                          ? Icons.directions_car
                          : Icons.shield_outlined,
                  size: 18,
                  color: cred.status == DriverCredentialStatus.expired
                      ? const Color(0xFFC62828)
                      : Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cred.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cred.subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cred.expiryText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cred.status == DriverCredentialStatus.expired
                            ? const Color(0xFFC62828)
                            : cred.status == DriverCredentialStatus.expiringSoon
                                ? const Color(0xFFE65100)
                                : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (cred.status == DriverCredentialStatus.valid ||
                  cred.status == DriverCredentialStatus.inReview)
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                  onPressed: () => onCredentialTap(cred),
                ),
            ],
          ),

          // Upload CTA Button if expired
          if (cred.status == DriverCredentialStatus.expired) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onUploadRequested(cred.id),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFFB71C1C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Upload New Licence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Upload CTA button if expiring soon
          if (cred.status == DriverCredentialStatus.expiringSoon) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => onCredentialTap(cred),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  backgroundColor: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Upload new',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDispatchDeskBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help from Dispatch?',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                'Lethbridge Operations Desk 24/7',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onCallDesk,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0F0F0),
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone, size: 12, color: Color(0xFFC62828)),
                SizedBox(width: 4),
                Text('Call Desk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
