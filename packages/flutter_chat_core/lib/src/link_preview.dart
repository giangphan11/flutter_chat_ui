import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'link_preview.g.dart';

@JsonSerializable()
class LinkPreview extends Equatable {
  final String link;
  final String? description;
  final String? imageUrl;
  final String? title;

  static const Object _sentinelValue = Object();

  const LinkPreview({
    required this.link,
    this.description,
    this.imageUrl,
    this.title,
  });

  @override
  List<Object?> get props => [link, description, imageUrl, title];

  factory LinkPreview.fromJson(Map<String, dynamic> json) =>
      _$LinkPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$LinkPreviewToJson(this);

  LinkPreview copyWith({
    String? link,
    Object? description = _sentinelValue,
    Object? imageUrl = _sentinelValue,
    Object? title = _sentinelValue,
  }) =>
      LinkPreview(
        link: link ?? this.link,
        description: description == _sentinelValue
            ? this.description
            : description as String?,
        imageUrl:
            imageUrl == _sentinelValue ? this.imageUrl : imageUrl as String?,
        title: title == _sentinelValue ? this.title : title as String?,
      );
}
