import 'package:equatable/equatable.dart';

enum FaqCategory {
  all,
  booking,
  payments,
  safety,
  airport;

  String get displayName => label;

  String get label {
    switch (this) {
      case FaqCategory.all:
        return 'All';
      case FaqCategory.booking:
        return 'Booking';
      case FaqCategory.payments:
        return 'Payments';
      case FaqCategory.safety:
        return 'Safety';
      case FaqCategory.airport:
        return 'Airport';
    }
  }
}

class MeteredFareBoxData extends Equatable {
  final String baseDrop;
  final String distanceRate;
  final String taxes;
  final String explanation;

  const MeteredFareBoxData({
    this.baseDrop = '\$3.80 CAD',
    this.distanceRate = '\$1.95 CAD / km',
    this.taxes = '5% Alberta GST applied',
    this.explanation =
        'Upfront digital estimates provide fixed certainty, while in-car physical taximeters track intermediate deviations.',
  });

  String get title => 'Metered fare';

  String get waitingRate => 'Included in the estimate';

  String get taxNote => taxes;

  @override
  List<Object?> get props => [baseDrop, distanceRate, taxes, explanation];
}

class FaqItem extends Equatable {
  final String id;
  final String question;
  final String answer;
  final FaqCategory category;
  final MeteredFareBoxData? meteredFareBox;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.meteredFareBox,
  });

  @override
  List<Object?> get props => [id, question, answer, category, meteredFareBox];
}
