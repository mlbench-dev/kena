import 'package:json_annotation/json_annotation.dart';

part 'comparison_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ComparisonModel {
  final bool? success;
  final String? message;
  final List<ComparisonData>? data;

  ComparisonModel({this.success, this.message, this.data});

  factory ComparisonModel.fromJson(Map<String, dynamic> json) =>
      _$ComparisonModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ComparisonData {
  final String? day;
  final bool? isEndDay;
  final Forecast? forecast;
  final Reality? reality;
  final List<ActivityToday>? activitiesToday;

  /// Was List<Null> in the old model
  final List<dynamic>? activitiesCompleted;

  ComparisonData({
    this.day,
    this.isEndDay,
    this.forecast,
    this.reality,
    this.activitiesToday,
    this.activitiesCompleted,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) =>
      _$ComparisonDataFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Forecast {
  final List<Emotion>? emotions;
  final String? plan;
  final String? notes;
  final String? createdAt;

  Forecast({this.emotions, this.plan, this.notes, this.createdAt});

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Reality {
  final List<Emotion>? emotions;
  final bool? wentAsForecast;
  final int? compareToForecast;
  final bool? planUseful;
  final String? createdAt;

  Reality({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.createdAt,
  });

  factory Reality.fromJson(Map<String, dynamic> json) =>
      _$RealityFromJson(json);

  Map<String, dynamic> toJson() => _$RealityToJson(this);
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

  Emotion copyWith({String? key, int? intensity, String? imageUrl}) {
    return Emotion(
      key: key ?? this.key,
      intensity: intensity ?? this.intensity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

@JsonSerializable()
class ActivityToday {
  final String? name;
  final bool? isCustom;
  final bool? isCompleted;

  ActivityToday({this.name, this.isCustom, this.isCompleted});

  factory ActivityToday.fromJson(Map<String, dynamic> json) =>
      _$ActivityTodayFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityTodayToJson(this);
}
