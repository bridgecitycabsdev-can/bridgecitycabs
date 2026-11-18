import 'package:flutter/material.dart';
import '../../data/models/driver_register_config.dart';

class DriverRegisterPhotoPicker extends StatelessWidget {
  final bool hasPhoto;
  final String? photoUrl;
  final String? photoError;
  final VoidCallback onTap;

  const DriverRegisterPhotoPicker({
    super.key,
    required this.hasPhoto,
    this.photoUrl,
    this.photoError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Avatar Container with Camera Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3F4F6),
                  border: Border.all(
                    color: photoError != null
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasPhoto && photoUrl != null
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),

              // Red Camera Badge at Bottom Right
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC91A25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subtext / Error / Success Message
          if (hasPhoto) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 15,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 5),
                const Text(
                  '${DriverRegisterConfig.photoAddedSuccess} · ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    DriverRegisterConfig.changePhotoAction,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC91A25),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (photoError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 13,
                    color: Color(0xFFDC2626),
                  ),
                  SizedBox(width: 5),
                  Text(
                    DriverRegisterConfig.photoRequiredError,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              DriverRegisterConfig.photoBylawSubtext,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ] else ...[
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
                children: [
                  TextSpan(text: '${DriverRegisterConfig.addPhotoHeading} '),
                  TextSpan(
                    text: DriverRegisterConfig.requiredRedTag,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                DriverRegisterConfig.addPhotoSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        size: 52,
        color: Color(0xFFD1D5DB),
      ),
    );
  }
}
