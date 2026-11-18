import 'package:flutter/material.dart';
import '../../data/models/profile_setup_config.dart';

/// Avatar section allowing passengers to add or edit their profile picture.
class ProfilePhotoPicker extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback onTap;

  const ProfilePhotoPicker({
    super.key,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar Circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: hasPhoto ? const Color(0xFFF3F4F6) : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                    image: hasPhoto
                        ? DecorationImage(
                            image: NetworkImage(photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: !hasPhoto
                      ? const Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 48,
                          ),
                        )
                      : null,
                ),

                // Attached badge (+ or pencil)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB71C1C).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        hasPhoto ? Icons.edit_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Caption or Status Pill
          if (hasPhoto) ...[
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFFB71C1C),
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${ProfileSetupConfig.photoAdded} • ',
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ProfileSetupConfig.changePhoto,
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text(
              ProfileSetupConfig.addPhotoOptional,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
