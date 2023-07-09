// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextMessage _$TextMessageFromJson(Map<String, dynamic> json) => TextMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      timestamp:
          const EpochDateTimeConverter().fromJson(json['timestamp'] as int),
      type: json['type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      text: json['text'] as String,
      linkPreview: json['linkPreview'] == null
          ? null
          : LinkPreview.fromJson(json['linkPreview'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TextMessageToJson(TextMessage instance) {
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
  val['text'] = instance.text;
  writeNotNull('linkPreview', instance.linkPreview?.toJson());
  return val;
}
