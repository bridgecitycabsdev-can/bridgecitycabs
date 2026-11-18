import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final double rating;
  final int totalRides;
  final String memberSince;
  final bool isVerified;
  final String riderTier;
  final String defaultPaymentMethod;
  final String notificationsSummary;
  final bool notificationsEnabled;
  final String privacySummary;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.rating = 5.0,
    this.totalRides = 42,
    this.memberSince = '2023',
    this.isVerified = true,
    this.riderTier = 'Lethbridge Rider',
    this.defaultPaymentMethod = 'Visa ending in 4242 • Default',
    this.notificationsSummary = 'Push & SMS active',
    this.notificationsEnabled = true,
    this.privacySummary = 'Location & card policies',
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    double? rating,
    int? totalRides,
    String? memberSince,
    bool? isVerified,
    String? riderTier,
    String? defaultPaymentMethod,
    String? notificationsSummary,
    bool? notificationsEnabled,
    String? privacySummary,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      memberSince: memberSince ?? this.memberSince,
      isVerified: isVerified ?? this.isVerified,
      riderTier: riderTier ?? this.riderTier,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      notificationsSummary: notificationsSummary ?? this.notificationsSummary,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privacySummary: privacySummary ?? this.privacySummary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        email,
        rating,
        totalRides,
        memberSince,
        isVerified,
        riderTier,
        defaultPaymentMethod,
        notificationsSummary,
        notificationsEnabled,
        privacySummary,
      ];
}
