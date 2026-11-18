import 'package:equatable/equatable.dart';

enum VerificationItemStatus {
  verified,
  underReview,
  pending;

  bool get isVerified => this == VerificationItemStatus.verified;
  bool get isUnderReview => this == VerificationItemStatus.underReview;
  bool get isPending => this == VerificationItemStatus.pending;
}

class DriverVerificationItem extends Equatable {
  final String title;
  final String subtitle;
  final VerificationItemStatus status;
  final String tagText;

  const DriverVerificationItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.tagText,
  });

  @override
  List<Object?> get props => [title, subtitle, status, tagText];
}
