import 'package:json_annotation/json_annotation.dart';

part 'result_emotion_model.g.dart';

@JsonSerializable()
class ResultEmotionModel {
  final bool? success;
  final String? message;
  final List<ResultEmotionData>? data;

  ResultEmotionModel({this.success, this.message, this.data});

  factory ResultEmotionModel.fromJson(Map<String, dynamic> json) =>
      _$ResultEmotionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResultEmotionModelToJson(this);
}

@JsonSerializable()
class ResultEmotionData {
  final List<CoreEmotion>? coreEmotions;
  final List<AspirationEmotion>? aspirationEmotions;
  final String? aspirationReassessDate;
  final String? reviewDate;
  final List<Activity>? activities;

  ResultEmotionData({
    this.coreEmotions,
    this.aspirationEmotions,
    this.aspirationReassessDate,
    this.reviewDate,
    this.activities,
  });

  factory ResultEmotionData.fromJson(Map<String, dynamic> json) =>
      _$ResultEmotionDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResultEmotionDataToJson(this);
}

@JsonSerializable()
class CoreEmotion {
  final String? key;
  final int? intensity;
  final String? imageUrl;

  @JsonKey(name: '_id')
  final String? id;

  CoreEmotion({this.key, this.intensity, this.imageUrl, this.id});

  factory CoreEmotion.fromJson(Map<String, dynamic> json) =>
      _$CoreEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$CoreEmotionToJson(this);
}

@JsonSerializable()
class AspirationEmotion {
  final String? key;
  final int? intensity;
  final String? imageUrl;

  @JsonKey(name: '_id')
  final String? id;

  AspirationEmotion({this.key, this.intensity, this.imageUrl, this.id});

  factory AspirationEmotion.fromJson(Map<String, dynamic> json) =>
      _$AspirationEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$AspirationEmotionToJson(this);
}

@JsonSerializable()
class Activity {
  final String? id;
  final String? name;
  final Schedule? schedule;
  final bool? isCustom;
  final String? uiLabel;
  final String? uiBadge;

  Activity({
    this.id,
    this.name,
    this.schedule,
    this.isCustom,
    this.uiLabel,
    this.uiBadge,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class Schedule {
  final String? frequency;
  final int? monthlyWeekDay;
  final int? monthlyWeekNumber;
  final int? monthlyDay;
  final List<int>? monthlyDays;
  final List<int>? weeklyDays;

  Schedule({
    this.frequency,
    this.monthlyWeekDay,
    this.monthlyWeekNumber,
    this.monthlyDay,
    this.monthlyDays,
    this.weeklyDays,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
