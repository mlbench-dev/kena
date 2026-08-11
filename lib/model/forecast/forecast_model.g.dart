// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastModel _$ForecastModelFromJson(Map<String, dynamic> json) =>
    ForecastModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ForecastData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForecastModelToJson(ForecastModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

ForecastData _$ForecastDataFromJson(Map<String, dynamic> json) => ForecastData(
  day: json['day'] as String?,
  forecast: json['forecast'] == null
      ? null
      : Forecast.fromJson(json['forecast'] as Map<String, dynamic>),
  activities: (json['activities'] as List<dynamic>?)
      ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  isForecastShared: json['isForecastShared'] as bool?,
);

Map<String, dynamic> _$ForecastDataToJson(ForecastData instance) =>
    <String, dynamic>{
      'day': instance.day,
      'forecast': instance.forecast?.toJson(),
      'activities': instance.activities?.map((e) => e.toJson()).toList(),
      'isForecastShared': instance.isForecastShared,
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  plan: json['plan'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'emotions': instance.emotions?.map((e) => e.toJson()).toList(),
  'plan': instance.plan,
  'notes': instance.notes,
  'createdAt': instance.createdAt,
};

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
  key: json['key'] as String?,
  intensity: json['intensity'] as num?,
  imageUrl: json['imageUrl'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
  'key': instance.key,
  'intensity': instance.intensity,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
};

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String?,
  name: json['name'] as String?,
  isCustom: json['isCustom'] as bool?,
  isCompleted: json['isCompleted'] as bool?,
  isForecastOrEOD: json['isForecastOrEOD'] as bool?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isCustom': instance.isCustom,
  'isCompleted': instance.isCompleted,
  'isForecastOrEOD': instance.isForecastOrEOD,
};
