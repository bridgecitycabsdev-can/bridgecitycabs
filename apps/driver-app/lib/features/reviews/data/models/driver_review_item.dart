import 'package:equatable/equatable.dart';

class DriverReviewItem extends Equatable {
  final String id;
  final String tripId;
  final String passengerName;
  final String? passengerAvatar;
  final String dateFormatted;
  final int rating;
  final String comment;
  final bool isLowRating;
  final List<String> tags;
  final String tripRouteSummary;
  final String? pickupLocation;

  const DriverReviewItem({
    required this.id,
    this.tripId = 'BC-123456',
    required this.passengerName,
    this.passengerAvatar,
    required this.dateFormatted,
    required this.rating,
    required this.comment,
    this.isLowRating = false,
    this.tags = const [],
    this.tripRouteSummary = '4.52 km • ⏱ 14 mins • 🚘 Sedan Medium',
    this.pickupLocation,
  });

  DriverReviewItem copyWith({
    String? id,
    String? tripId,
    String? passengerName,
    String? passengerAvatar,
    String? dateFormatted,
    int? rating,
    String? comment,
    bool? isLowRating,
    List<String>? tags,
    String? tripRouteSummary,
    String? pickupLocation,
  }) {
    return DriverReviewItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      passengerName: passengerName ?? this.passengerName,
      passengerAvatar: passengerAvatar ?? this.passengerAvatar,
      dateFormatted: dateFormatted ?? this.dateFormatted,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isLowRating: isLowRating ?? this.isLowRating,
      tags: tags ?? this.tags,
      tripRouteSummary: tripRouteSummary ?? this.tripRouteSummary,
      pickupLocation: pickupLocation ?? this.pickupLocation,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tripId,
    passengerName,
    passengerAvatar,
    dateFormatted,
    rating,
    comment,
    isLowRating,
    tags,
    tripRouteSummary,
    pickupLocation,
  ];
}
