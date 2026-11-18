import 'package:equatable/equatable.dart';
import 'driver_document_type.dart';

enum DocumentUploadStatus {
  notUploaded,
  uploading,
  uploaded,
  needsRetake;

  bool get isUploaded => this == DocumentUploadStatus.uploaded;
  bool get isUploading => this == DocumentUploadStatus.uploading;
  bool get isNeedsRetake => this == DocumentUploadStatus.needsRetake;
  bool get isNotUploaded => this == DocumentUploadStatus.notUploaded;
}

class DriverDocumentItem extends Equatable {
  final DriverDocumentType type;
  final DocumentUploadStatus status;
  final String? fileName;
  final String? fileSize;
  final String? fileDescriptor;
  final String? expiryDate;
  final String? complianceBadge;
  final double uploadProgress;
  final String? errorMessage;
  final bool isLocked;

  const DriverDocumentItem({
    required this.type,
    this.status = DocumentUploadStatus.notUploaded,
    this.fileName,
    this.fileSize,
    this.fileDescriptor,
    this.expiryDate,
    this.complianceBadge,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.isLocked = false,
  });

  bool get isRequired => type.isRequired;
  bool get isSatisfied => !isRequired || status == DocumentUploadStatus.uploaded;

  DriverDocumentItem copyWith({
    DriverDocumentType? type,
    DocumentUploadStatus? status,
    String? fileName,
    String? fileSize,
    String? fileDescriptor,
    String? expiryDate,
    String? complianceBadge,
    double? uploadProgress,
    String? errorMessage,
    bool? isLocked,
  }) {
    return DriverDocumentItem(
      type: type ?? this.type,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileDescriptor: fileDescriptor ?? this.fileDescriptor,
      expiryDate: expiryDate ?? this.expiryDate,
      complianceBadge: complianceBadge ?? this.complianceBadge,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
        type,
        status,
        fileName,
        fileSize,
        fileDescriptor,
        expiryDate,
        complianceBadge,
        uploadProgress,
        errorMessage,
        isLocked,
      ];
}
