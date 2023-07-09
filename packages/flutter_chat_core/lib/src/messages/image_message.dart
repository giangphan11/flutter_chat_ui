import 'package:json_annotation/json_annotation.dart';

import '../date_time_epoch_converter.dart';
import '../message.dart';

part 'image_message.g.dart';

@JsonSerializable()
@EpochDateTimeConverter()
class ImageMessage extends Message {
  final String source;
  final String? thumbhash;
  final double? width;
  final double? height;

  static const Object _sentinelValue = Object();

  const ImageMessage({
    required super.id,
    required super.senderId,
    required super.timestamp,

    /// needed to have [ImageMessage.type] in generated code
    // ignore: avoid_unused_constructor_parameters
    String? type,
    super.metadata,
    required this.source,
    this.thumbhash,
    this.width,
    this.height,
  }) : super(type: 'image');

  @override
  List<Object?> get props => super.props..addAll([source]);

  factory ImageMessage.fromJson(Map<String, dynamic> json) =>
      _$ImageMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageMessageToJson(this);

  @override
  ImageMessage copyWith({
    DateTime? timestamp,
    Object? metadata = _sentinelValue,
    String? source,
    Object? thumbhash = _sentinelValue,
    Object? width = _sentinelValue,
    Object? height = _sentinelValue,
  }) =>
      ImageMessage(
        id: id,
        senderId: senderId,
        timestamp: timestamp ?? this.timestamp,
        metadata: metadata == _sentinelValue
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        source: source ?? this.source,
        thumbhash:
            thumbhash == _sentinelValue ? this.thumbhash : thumbhash as String?,
        width: width == _sentinelValue ? this.width : width as double?,
        height: height == _sentinelValue ? this.height : height as double?,
      );
}
