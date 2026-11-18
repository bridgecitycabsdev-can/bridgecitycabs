import 'package:equatable/equatable.dart';

class DriverSupportFaqItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String iconType;
  final bool isDestructive;

  const DriverSupportFaqItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconType,
    this.isDestructive = false,
  });

  @override
  List<Object?> get props => [id, title, subtitle, iconType, isDestructive];
}
