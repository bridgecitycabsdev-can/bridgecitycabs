import 'package:equatable/equatable.dart';
import '../data/models/driver_document_type.dart';
import '../data/models/driver_register_step3_data.dart';
import '../data/models/driver_register_step3_status.dart';

abstract class DriverRegisterStep3Event extends Equatable {
  const DriverRegisterStep3Event();

  @override
  List<Object?> get props => [];
}

class DriverRegisterStep3Started extends DriverRegisterStep3Event {
  final DriverRegisterStep3Data? initialData;
  final DriverRegisterStep3Status initialStatus;

  const DriverRegisterStep3Started({
    this.initialData,
    this.initialStatus = DriverRegisterStep3Status.initial,
  });

  @override
  List<Object?> get props => [initialData, initialStatus];
}

class DriverRegisterUploadModalOpened extends DriverRegisterStep3Event {
  final DriverDocumentType documentType;

  const DriverRegisterUploadModalOpened(this.documentType);

  @override
  List<Object?> get props => [documentType];
}

class DriverRegisterUploadModalDismissed extends DriverRegisterStep3Event {
  const DriverRegisterUploadModalDismissed();
}

class DriverRegisterDocumentUploadRequested extends DriverRegisterStep3Event {
  final DriverDocumentType documentType;
  final String source; // 'camera', 'gallery', 'pdf'

  const DriverRegisterDocumentUploadRequested({
    required this.documentType,
    required this.source,
  });

  @override
  List<Object?> get props => [documentType, source];
}

class DriverRegisterDocumentUploadProgressed extends DriverRegisterStep3Event {
  final DriverDocumentType documentType;
  final double progress;

  const DriverRegisterDocumentUploadProgressed({
    required this.documentType,
    required this.progress,
  });

  @override
  List<Object?> get props => [documentType, progress];
}

class DriverRegisterDocumentDeleted extends DriverRegisterStep3Event {
  final DriverDocumentType documentType;

  const DriverRegisterDocumentDeleted(this.documentType);

  @override
  List<Object?> get props => [documentType];
}

class DriverRegisterDocumentRetakeRequested extends DriverRegisterStep3Event {
  final DriverDocumentType documentType;

  const DriverRegisterDocumentRetakeRequested(this.documentType);

  @override
  List<Object?> get props => [documentType];
}

class DriverRegisterStep3Submitted extends DriverRegisterStep3Event {
  const DriverRegisterStep3Submitted();
}

class DriverRegisterStep3StateSwitched extends DriverRegisterStep3Event {
  final DriverRegisterStep3Status status;

  const DriverRegisterStep3StateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
