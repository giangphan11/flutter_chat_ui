// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsupported_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnsupportedMessage _$UnsupportedMessageFromJson(Map<String, dynamic> json) =>
    UnsupportedMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      timestamp:
          const EpochDateTimeConverter().fromJson(json['timestamp'] as int),
      type: json['type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UnsupportedMessageToJson(UnsupportedMessage instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'senderId': instance.senderId,
    'timestamp': const EpochDateTimeConverter().toJson(instance.timestamp),
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('metadata', instance.metadata);
  return val;
}
