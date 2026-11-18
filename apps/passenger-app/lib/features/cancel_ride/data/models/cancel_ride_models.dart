import 'package:equatable/equatable.dart';

enum CancelRideStatus {
  confirm,
  cancelling,
  cancelledSuccess,
  cannotCancel,
}

class CancellationDetails extends Equatable {
  final String bookingId;
  final String selectedReason;
  final String? customReason;
  final bool isTripStarted;
  final String driverName;
  final String vehicleInfo;
  final double driverRating;
  final double feeAmountCad;

  const CancellationDetails({
    this.bookingId = 'BC-123456',
    this.selectedReason = 'Changed my plans',
    this.customReason,
    this.isTripStarted = false,
    this.driverName = 'Michael K.',
    this.vehicleInfo = 'Bridge City Cab #42 • Toyota Camry',
    this.driverRating = 4.96,
    this.feeAmountCad = 0.0,
  });

  String get formattedFee => '\$${feeAmountCad.toStringAsFixed(2)} CAD';

  static const List<String> commonReasons = [
    'Changed my plans',
    'Driver taking too long',
    'Wrong pickup location',
    'Booked by mistake',
    'Driver asked me to cancel',
    'Other',
  ];

  CancellationDetails copyWith({
    String? bookingId,
    String? selectedReason,
    String? customReason,
    bool? isTripStarted,
    String? driverName,
    String? vehicleInfo,
    double? driverRating,
    double? feeAmountCad,
  }) {
    return CancellationDetails(
      bookingId: bookingId ?? this.bookingId,
      selectedReason: selectedReason ?? this.selectedReason,
      customReason: customReason ?? this.customReason,
      isTripStarted: isTripStarted ?? this.isTripStarted,
      driverName: driverName ?? this.driverName,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      driverRating: driverRating ?? this.driverRating,
      feeAmountCad: feeAmountCad ?? this.feeAmountCad,
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        selectedReason,
        customReason,
        isTripStarted,
        driverName,
        vehicleInfo,
        driverRating,
        feeAmountCad,
      ];
}
