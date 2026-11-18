import 'package:equatable/equatable.dart';

enum DriverSupportSender {
  driver,
  agent,
  system;

  bool get isDriver => this == DriverSupportSender.driver;
  bool get isAgent => this == DriverSupportSender.agent;
  bool get isSystem => this == DriverSupportSender.system;
}

enum DriverSupportMessageDeliveryStatus {
  sending,
  sent,
  delivered,
  failed;

  bool get isSending => this == DriverSupportMessageDeliveryStatus.sending;
  bool get isDelivered => this == DriverSupportMessageDeliveryStatus.delivered;
  bool get isFailed => this == DriverSupportMessageDeliveryStatus.failed;
}

class DriverSupportMessage extends Equatable {
  final String id;
  final DriverSupportSender sender;
  final String authorName;
  final String text;
  final String timestamp;
  final DriverSupportMessageDeliveryStatus deliveryStatus;
  final String? attachmentName;
  final String? attachmentSize;

  const DriverSupportMessage({
    required this.id,
    required this.sender,
    required this.authorName,
    required this.text,
    required this.timestamp,
    this.deliveryStatus = DriverSupportMessageDeliveryStatus.delivered,
    this.attachmentName,
    this.attachmentSize,
  });

  DriverSupportMessage copyWith({
    String? id,
    DriverSupportSender? sender,
    String? authorName,
    String? text,
    String? timestamp,
    DriverSupportMessageDeliveryStatus? deliveryStatus,
    String? attachmentName,
    String? attachmentSize,
  }) {
    return DriverSupportMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      authorName: authorName ?? this.authorName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        authorName,
        text,
        timestamp,
        deliveryStatus,
        attachmentName,
        attachmentSize,
      ];
}
