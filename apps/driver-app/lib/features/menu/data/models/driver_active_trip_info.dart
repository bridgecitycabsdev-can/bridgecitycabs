import 'package:equatable/equatable.dart';

class DriverActiveTripInfo extends Equatable {
  final String unitNumber;
  final String destinationAddress;
  final String alertMessage;
  final bool hasFlagRideNotification;
  final String dispatchLinePhone;

  const DriverActiveTripInfo({
    this.unitNumber = 'Unit 42',
    this.destinationAddress = '501 1st Ave S',
    this.alertMessage =
        'Finish current trip before logging out.\nUnit 42 is on active dispatch to 501 1st Ave S.',
    this.hasFlagRideNotification = true,
    this.dispatchLinePhone = '403-328-8888',
  });

  DriverActiveTripInfo copyWith({
    String? unitNumber,
    String? destinationAddress,
    String? alertMessage,
    bool? hasFlagRideNotification,
    String? dispatchLinePhone,
  }) {
    return DriverActiveTripInfo(
      unitNumber: unitNumber ?? this.unitNumber,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      alertMessage: alertMessage ?? this.alertMessage,
      hasFlagRideNotification:
          hasFlagRideNotification ?? this.hasFlagRideNotification,
      dispatchLinePhone: dispatchLinePhone ?? this.dispatchLinePhone,
    );
  }

  @override
  List<Object?> get props => [
    unitNumber,
    destinationAddress,
    alertMessage,
    hasFlagRideNotification,
    dispatchLinePhone,
  ];
}
