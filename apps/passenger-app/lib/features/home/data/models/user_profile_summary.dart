import 'package:equatable/equatable.dart';

/// Summarized passenger profile for navigation drawer and home header.
class UserProfileSummary extends Equatable {
  final String name;
  final String? photoUrl;
  final double rating;
  final String riderStatus;
  final int unreadNotifications;
  final String defaultPayment;

  const UserProfileSummary({
    required this.name,
    this.photoUrl,
    required this.rating,
    required this.riderStatus,
    this.unreadNotifications = 2,
    this.defaultPayment = 'Personal •••• 8842',
  });

  @override
  List<Object?> get props => [
        name,
        photoUrl,
        rating,
        riderStatus,
        unreadNotifications,
        defaultPayment,
      ];
}
