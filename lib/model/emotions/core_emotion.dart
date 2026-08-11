import 'package:json_annotation/json_annotation.dart';

part 'core_emotion.g.dart';

@JsonSerializable()
class CoreEmotionsResponse {
  final bool? success;
  final String? message;
  final List<EmotionData>? data;

  CoreEmotionsResponse({this.success, this.message, this.data});

  factory CoreEmotionsResponse.fromJson(Map<String, dynamic> json) =>
      _$CoreEmotionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoreEmotionsResponseToJson(this);
}

@JsonSerializable()
class EmotionData {
  final List<EmotionItem>? coreEmotions;
  final List<EmotionItem>? aspirationEmotions;
  final String? aspirationReassessDate;

  EmotionData({
    this.coreEmotions,
    this.aspirationEmotions,
    this.aspirationReassessDate,
  });

  factory EmotionData.fromJson(Map<String, dynamic> json) =>
      _$EmotionDataFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionDataToJson(this);
}

@JsonSerializable()
class EmotionItem {
  final String? key;
  final int? intensity;

  @JsonKey(name: '_id')
  final String? id;

  EmotionItem({this.key, this.intensity, this.id});

  factory EmotionItem.fromJson(Map<String, dynamic> json) =>
      _$EmotionItemFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionItemToJson(this);
}
