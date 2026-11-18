import 'package:equatable/equatable.dart';

class RidePreference extends Equatable {
  final bool vanOnly;
  final bool ladyDriverOnly;

  const RidePreference({
    this.vanOnly = false,
    this.ladyDriverOnly = false,
  });

  RidePreference copyWith({
    bool? vanOnly,
    bool? ladyDriverOnly,
  }) {
    return RidePreference(
      vanOnly: vanOnly ?? this.vanOnly,
      ladyDriverOnly: ladyDriverOnly ?? this.ladyDriverOnly,
    );
  }

  @override
  List<Object?> get props => [vanOnly, ladyDriverOnly];
}
