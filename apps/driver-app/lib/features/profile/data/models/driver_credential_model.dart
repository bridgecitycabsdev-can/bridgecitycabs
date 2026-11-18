import 'package:equatable/equatable.dart';

enum DriverCredentialStatus {
  approved('Approved'),
  valid('Valid'),
  inReview('In Review'),
  expiringSoon('Expiring soon'),
  expired('Expired');

  final String label;
  const DriverCredentialStatus(this.label);
}

class DriverCredentialModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final DriverCredentialStatus status;
  final String expiryText;
  final String? idNumber;
  final bool isInspectionShielded;
  final String? issueDate;
  final String? expirationDate;
  final String? policyNumber;

  const DriverCredentialModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.expiryText,
    this.idNumber,
    this.isInspectionShielded = false,
    this.issueDate,
    this.expirationDate,
    this.policyNumber,
  });

  DriverCredentialModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    DriverCredentialStatus? status,
    String? expiryText,
    String? idNumber,
    bool? isInspectionShielded,
    String? issueDate,
    String? expirationDate,
    String? policyNumber,
  }) {
    return DriverCredentialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      expiryText: expiryText ?? this.expiryText,
      idNumber: idNumber ?? this.idNumber,
      isInspectionShielded: isInspectionShielded ?? this.isInspectionShielded,
      issueDate: issueDate ?? this.issueDate,
      expirationDate: expirationDate ?? this.expirationDate,
      policyNumber: policyNumber ?? this.policyNumber,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    status,
    expiryText,
    idNumber,
    isInspectionShielded,
    issueDate,
    expirationDate,
    policyNumber,
  ];
}
