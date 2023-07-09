// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkPreview _$LinkPreviewFromJson(Map<String, dynamic> json) => LinkPreview(
      link: json['link'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$LinkPreviewToJson(LinkPreview instance) {
  final val = <String, dynamic>{
    'link': instance.link,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('imageUrl', instance.imageUrl);
  writeNotNull('title', instance.title);
  return val;
}
