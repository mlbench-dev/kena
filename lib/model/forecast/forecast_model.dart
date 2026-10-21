import 'package:json_annotation/json_annotation.dart';

part 'forecast_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ForecastModel {
  final bool? success;
  final String? message;
  final List<ForecastData>? data;

  ForecastModel({this.success, this.message, this.data});

  factory ForecastModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ForecastData {
  final String? day;
  final Forecast? forecast;
  final List<Activity>? activities;
  final bool? isForecastShared;

  ForecastData({
    this.day,
    this.forecast,
    this.activities,
    this.isForecastShared,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) =>
      _$ForecastDataFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastDataToJson(this);
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

@JsonSerializable()
class Emotion {
  final String? key;
  final num? intensity;
  final String? imageUrl;
  final String? title;
  final int? count;

  Emotion({this.key, this.intensity, this.imageUrl, this.title, this.count});

  Emotion copyWith({
    String? key,
    num? intensity,
    String? imageUrl,
    String? title,
    int? count,
  }) {
    return Emotion(
      key: key ?? this.key,
      intensity: intensity ?? this.intensity,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      count: count ?? this.count,
    );
  }

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);
}

@JsonSerializable()
class Activity {
  final String? id;
  final String? name;
  final bool? isCustom;
  final bool? isCompleted;
  final bool? isForecastOrEOD;

  Activity({
    this.id,
    this.name,
    this.isCustom,
    this.isCompleted,
    this.isForecastOrEOD,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
