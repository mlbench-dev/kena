import 'package:json_annotation/json_annotation.dart';

part 'forecast_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ForecastHistoryModel {
  final bool? success;
  final String? message;
  final List<ForecastHistoryData>? data;

  ForecastHistoryModel({this.success, this.message, this.data});

  factory ForecastHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastHistoryModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ForecastHistoryData {
  final String? date;
  final String? day;
  final ForecastHistoryForecast? forecast;
  final Reflection? reflection;
  final List<ForecastActivity>? activities;
  final dynamic dailyNotes;
  final String? createdAt;
  final String? updatedAt;

  ForecastHistoryData({
    this.date,
    this.day,
    this.forecast,
    this.reflection,
    this.activities,
    this.dailyNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory ForecastHistoryData.fromJson(Map<String, dynamic> json) =>
      _$ForecastHistoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastHistoryDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ForecastHistoryForecast {
  final List<Emotion>? emotions;
  final String? plan;
  final String? notes;
  final List<UserNote>? userNotes;
  final String? createdAt;

  ForecastHistoryForecast({
    this.emotions,
    this.plan,
    this.notes,
    this.userNotes,
    this.createdAt,
  });

  factory ForecastHistoryForecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastHistoryForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastHistoryForecastToJson(this);
}

@JsonSerializable()
class Emotion {
  final String? key;
  final int? intensity;
  final String? imageUrl;
  final String? title;

  Emotion({this.key, this.intensity, this.imageUrl, this.title});

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);
}

@JsonSerializable()
class UserNote {
  final String? content;
  final String? createdAt;
  final bool? isPrivate;
  final bool? isAspire;
  final int? likes;
  final int? comments;

  @JsonKey(name: '_id')
  final String? id;

  UserNote({
    this.content,
    this.createdAt,
    this.isPrivate,
    this.isAspire,
    this.likes,
    this.comments,
    this.id,
  });

  factory UserNote.fromJson(Map<String, dynamic> json) =>
      _$UserNoteFromJson(json);

  Map<String, dynamic> toJson() => _$UserNoteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Reflection {
  final List<Emotion>? emotions;
  final bool? wentAsForecast;
  final int? compareToForecast;
  final bool? planUseful;
  final String? planFeedback;
  final String? createdAt;

  Reflection({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.planFeedback,
    this.createdAt,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) =>
      _$ReflectionFromJson(json);

  Map<String, dynamic> toJson() => _$ReflectionToJson(this);
}

@JsonSerializable()
class ForecastActivity {
  final String? name;
  final bool? completed;

  ForecastActivity({this.name, this.completed});

  factory ForecastActivity.fromJson(Map<String, dynamic> json) =>
      _$ForecastActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastActivityToJson(this);
}
