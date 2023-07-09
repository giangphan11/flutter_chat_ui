import 'package:json_annotation/json_annotation.dart';

import '../date_time_epoch_converter.dart';
import '../message.dart';

part 'unsupported_message.g.dart';

@JsonSerializable()
@EpochDateTimeConverter()
class UnsupportedMessage extends Message {
  static const Object _sentinelValue = Object();

  const UnsupportedMessage({
    required super.id,
    required super.senderId,
    required super.timestamp,

    /// needed to have [UnsupportedMessage.type] in generated code
    // ignore: avoid_unused_constructor_parameters
    String? type,
    super.metadata,
  }) : super(type: 'unsupported');

  factory UnsupportedMessage.fromJson(Map<String, dynamic> json) =>
      _$UnsupportedMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsupportedMessageToJson(this);

  @override
  UnsupportedMessage copyWith({
    DateTime? timestamp,
    Object? metadata = _sentinelValue,
  }) =>
      UnsupportedMessage(
        id: id,
        senderId: senderId,
        timestamp: timestamp ?? this.timestamp,
        metadata: metadata == _sentinelValue
            ? this.metadata
            : metadata as Map<String, dynamic>?,
      );
}
