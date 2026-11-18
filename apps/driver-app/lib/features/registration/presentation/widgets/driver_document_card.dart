import 'package:flutter/material.dart';
import '../../data/models/driver_document_item.dart';
import '../../data/models/driver_document_type.dart';

class DriverDocumentCard extends StatelessWidget {
  final DriverDocumentItem item;
  final VoidCallback onUploadPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onRetakePressed;

  const DriverDocumentCard({
    super.key,
    required this.item,
    required this.onUploadPressed,
    this.onDeletePressed,
    this.onRetakePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.status.isNeedsRetake
            ? const Color(0xFFFFF5F5)
            : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.status.isNeedsRetake
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFE5E7EB),
          width: item.status.isNeedsRetake ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFEBEE),
                ),
                child: Icon(
                  item.type.icon,
                  color: const Color(0xFFC62828),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.type.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (item.isLocked) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.lock, size: 13, color: Color(0xFF6B7280)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.type.complianceSpecification,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          // Body Content Based on Document Status
          if (item.status.isNotUploaded) ...[
            const SizedBox(height: 12),
            InkWell(
              key: ValueKey('doc_upload_action_${item.type.name}'),
              onTap: onUploadPressed,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined,
                        size: 16, color: Color(0xFF4B5563)),
                    const SizedBox(width: 8),
                    Text(
                      item.isRequired
                          ? 'Upload document'
                          : 'Upload permit (optional)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (item.status.isUploading) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_upload_outlined,
                              size: 18, color: Color(0xFFC62828)),
                          const SizedBox(width: 8),
                          Text(
                            item.fileName ?? 'uploading...',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(item.uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.uploadProgress,
                      backgroundColor: const Color(0xFFFFEBEE),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.fileDescriptor ??
                        'Encrypting and uploading to Bridge City Fleet Vault...',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (item.status.isUploaded && !item.isLocked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: item.fileName?.endsWith('.pdf') == true
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      item.fileName?.endsWith('.pdf') == true
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      size: 18,
                      color: item.fileName?.endsWith('.pdf') == true
                          ? const Color(0xFFC62828)
                          : const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.fileName ?? 'document_file',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${item.fileSize ?? '2.4 MB'} · ${item.fileDescriptor ?? 'High resolution'}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDeletePressed != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Color(0xFF9CA3AF)),
                      onPressed: onDeletePressed,
                    )
                  else
                    const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
            if (item.expiryDate != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        'Expires: ${item.expiryDate} ✔',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  if (item.complianceBadge != null)
                    Text(
                      item.complianceBadge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.complianceBadge!.contains('BONUS')
                            ? const Color(0xFFE65100)
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                ],
              ),
            ],
          ] else if (item.status.isNeedsRetake) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.error_outline,
                          size: 16, color: Color(0xFFD32F2F)),
                      SizedBox(width: 6),
                      Text(
                        'AUTOMATED CHECK FAILED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD32F2F),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.errorMessage ??
                        'Image is blurry and corners are cut off. Please retake in good lighting without flash glare.',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      key: ValueKey('retake_button_${item.type.name}'),
                      onPressed: onRetakePressed ?? onUploadPressed,
                      icon: const Icon(Icons.camera_alt_outlined,
                          size: 16, color: Colors.white),
                      label: const Text(
                        'Retake photo / Re-upload',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (item.isLocked) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE8F5E9),
        ),
        child: const Icon(Icons.shield, size: 16, color: Color(0xFF2E7D32)),
      );
    }

    switch (item.status) {
      case DocumentUploadStatus.uploaded:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check, size: 12, color: Color(0xFF2E7D32)),
              SizedBox(width: 4),
              Text(
                'Uploaded',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        );

      case DocumentUploadStatus.uploading:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Uploading ${(item.uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        );

      case DocumentUploadStatus.needsRetake:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error_outline, size: 12, color: Color(0xFFC62828)),
              SizedBox(width: 4),
              Text(
                'Needs retake',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        );

      case DocumentUploadStatus.notUploaded:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Not uploaded',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        );
    }
  }
}
