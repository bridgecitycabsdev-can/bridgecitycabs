import 'package:flutter/material.dart';
import '../../data/models/driver_document_type.dart';

class DriverDocumentUploadModal extends StatelessWidget {
  final DriverDocumentType documentType;
  final ValueChanged<String> onSourceSelected; // 'camera', 'gallery', 'pdf'
  final VoidCallback onDismiss;

  const DriverDocumentUploadModal({
    super.key,
    required this.documentType,
    required this.onSourceSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Upload ${documentType.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Step 3 of 4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Select how you would like to provide your document photo or file.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),

          // Option 1: Take Photo
          _buildOptionTile(
            key: const ValueKey('doc_upload_source_camera'),
            icon: Icons.camera_alt_outlined,
            title: 'Take photo',
            subtitle: 'Use device camera (Front & Back)',
            onTap: () => onSourceSelected('camera'),
          ),
          const SizedBox(height: 12),

          // Option 2: Choose from Gallery
          _buildOptionTile(
            key: const ValueKey('doc_upload_source_gallery'),
            icon: Icons.photo_outlined,
            title: 'Choose from gallery',
            subtitle: 'JPG or PNG from your photo library',
            onTap: () => onSourceSelected('gallery'),
          ),
          const SizedBox(height: 12),

          // Option 3: Upload PDF
          _buildOptionTile(
            key: const ValueKey('doc_upload_source_pdf'),
            icon: Icons.picture_as_pdf_outlined,
            title: 'Upload PDF',
            subtitle: 'Official digital document or scan (Max 10 MB)',
            onTap: () => onSourceSelected('pdf'),
          ),
          const SizedBox(height: 18),

          // Guidelines Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGuidelineItem(Icons.light_mode_outlined, 'Good lighting'),
                const Text('•', style: TextStyle(color: Color(0xFFD1D5DB))),
                _buildGuidelineItem(Icons.wb_sunny_outlined, 'No glare'),
                const Text('•', style: TextStyle(color: Color(0xFFD1D5DB))),
                _buildGuidelineItem(Icons.crop_free, 'All 4 corners visible'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Cancel Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              key: const ValueKey('doc_upload_modal_cancel'),
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF374151),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFC62828), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
