import 'package:equatable/equatable.dart';

import 'messages/image_message.dart';
import 'messages/text_message.dart';
import 'messages/unsupported_message.dart';

abstract class Message extends Equatable {
  final String id;
  final String senderId;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.senderId,
    required this.timestamp,
    required this.type,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, senderId, timestamp, type];

  factory Message.fromJson(Map<String, dynamic> json) {
    final type = json['type'];

    final messageFactory = {
      'image': ImageMessage.fromJson,
      'text': TextMessage.fromJson,
    };

    if (messageFactory.containsKey(type)) {
      return messageFactory[type]!(json);
    } else {
      // Unsupported message type
      return UnsupportedMessage.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  Message copyWith({
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  });
}
