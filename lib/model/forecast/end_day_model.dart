import 'package:json_annotation/json_annotation.dart';

part 'end_day_model.g.dart';

@JsonSerializable()
class EndDayModel {
  final bool? success;
  final String? message;
  final List<EndDayData>? data;

  EndDayModel({this.success, this.message, this.data});

  factory EndDayModel.fromJson(Map<String, dynamic> json) =>
      _$EndDayModelFromJson(json);

  Map<String, dynamic> toJson() => _$EndDayModelToJson(this);
}

@JsonSerializable()
class EndDayData {
  final String? day;
  final EndDay? endDay;

  EndDayData({this.day, this.endDay});

  factory EndDayData.fromJson(Map<String, dynamic> json) =>
      _$EndDayDataFromJson(json);

  Map<String, dynamic> toJson() => _$EndDayDataToJson(this);
}

@JsonSerializable()
class EndDay {
  final List<Emotion>? emotions;
  final bool? wentAsForecast;
  final int? compareToForecast;
  final bool? planUseful;
  final String? planFeedback;
  final String? createdAt;

  EndDay({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.planFeedback,
    this.createdAt,
  });

  factory EndDay.fromJson(Map<String, dynamic> json) => _$EndDayFromJson(json);

  Map<String, dynamic> toJson() => _$EndDayToJson(this);
}

@JsonSerializable()
class Emotion {
  final String? key;
  final int? intensity;
  final String? imageUrl;

  Emotion({this.key, this.intensity, this.imageUrl});

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);
}
