import 'package:equatable/equatable.dart';
import 'driver_document_item.dart';
import 'driver_document_type.dart';

class DriverRegisterStep3Data extends Equatable {
  final Map<DriverDocumentType, DriverDocumentItem> documents;
  final DriverDocumentType? activeModalDocument;
  final int transmissionPercentage;
  final String dispatchNode;

  const DriverRegisterStep3Data({
    this.documents = const {},
    this.activeModalDocument,
    this.transmissionPercentage = 98,
    this.dispatchNode = 'YQL-Fleet-Node-04',
  });

  DriverDocumentItem getDocument(DriverDocumentType type) {
    return documents[type] ?? DriverDocumentItem(type: type);
  }

  int get requiredDocumentsCount =>
      DriverDocumentType.values.where((t) => t.isRequired).length;

  int get uploadedRequiredCount => documents.values
      .where((doc) => doc.isRequired && doc.status == DocumentUploadStatus.uploaded)
      .length;

  bool get areAllRequiredUploaded =>
      uploadedRequiredCount >= requiredDocumentsCount;

  bool get hasAnyUploading =>
      documents.values.any((doc) => doc.status == DocumentUploadStatus.uploading);

  bool get hasAnyNeedsRetake =>
      documents.values.any((doc) => doc.status == DocumentUploadStatus.needsRetake);

  DriverRegisterStep3Data copyWith({
    Map<DriverDocumentType, DriverDocumentItem>? documents,
    DriverDocumentType? activeModalDocument,
    int? transmissionPercentage,
    String? dispatchNode,
  }) {
    return DriverRegisterStep3Data(
      documents: documents ?? this.documents,
      activeModalDocument: activeModalDocument ?? this.activeModalDocument,
      transmissionPercentage:
          transmissionPercentage ?? this.transmissionPercentage,
      dispatchNode: dispatchNode ?? this.dispatchNode,
    );
  }

  @override
  List<Object?> get props => [
        documents,
        activeModalDocument,
        transmissionPercentage,
        dispatchNode,
      ];
}
