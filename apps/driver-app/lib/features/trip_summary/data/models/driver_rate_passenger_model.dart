import 'package:equatable/equatable.dart';

class DriverRatePassengerModel extends Equatable {
  final String passengerName;
  final String tripId;
  final String routeSummary;
  final String ridesCompletedSummary;
  final String tripFareTypeSummary;
  final double rating;
  final List<String> selectedTags;
  final String dispatcherFeedbackNotes;
  final bool isSubmitted;

  const DriverRatePassengerModel({
    this.passengerName = 'Alex M.',
    this.tripId = 'BC-9942',
    this.routeSummary = '4th Ave S to Scenic Dr',
    this.ridesCompletedSummary = 'Lethbridge Rider • 42 rides completed',
    this.tripFareTypeSummary = '\$18.78 Cash Trip',
    this.rating = 4.5,
    this.selectedTags = const ['Polite', 'On time'],
    this.dispatcherFeedbackNotes = '',
    this.isSubmitted = false,
  });

  static const List<String> availableTags = [
    'Polite',
    'On time',
    'Clean',
    'Respectful',
  ];

  String get ratingLabel {
    if (rating >= 4.8) return '$rating - Excellent passenger';
    if (rating >= 4.3) return '$rating - Great passenger';
    if (rating >= 3.8) return '$rating - Good passenger';
    if (rating >= 2.8) return '$rating - Average experience';
    return '$rating - Poor experience';
  }

  DriverRatePassengerModel copyWith({
    String? passengerName,
    String? tripId,
    String? routeSummary,
    String? ridesCompletedSummary,
    String? tripFareTypeSummary,
    double? rating,
    List<String>? selectedTags,
    String? dispatcherFeedbackNotes,
    bool? isSubmitted,
  }) {
    return DriverRatePassengerModel(
      passengerName: passengerName ?? this.passengerName,
      tripId: tripId ?? this.tripId,
      routeSummary: routeSummary ?? this.routeSummary,
      ridesCompletedSummary:
          ridesCompletedSummary ?? this.ridesCompletedSummary,
      tripFareTypeSummary: tripFareTypeSummary ?? this.tripFareTypeSummary,
      rating: rating ?? this.rating,
      selectedTags: selectedTags ?? this.selectedTags,
      dispatcherFeedbackNotes:
          dispatcherFeedbackNotes ?? this.dispatcherFeedbackNotes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        passengerName,
        tripId,
        routeSummary,
        ridesCompletedSummary,
        tripFareTypeSummary,
        rating,
        selectedTags,
        dispatcherFeedbackNotes,
        isSubmitted,
      ];
}
