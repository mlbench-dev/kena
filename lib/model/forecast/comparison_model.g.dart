// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComparisonModel _$ComparisonModelFromJson(Map<String, dynamic> json) =>
    ComparisonModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ComparisonData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ComparisonModelToJson(ComparisonModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

ComparisonData _$ComparisonDataFromJson(Map<String, dynamic> json) =>
    ComparisonData(
      day: json['day'] as String?,
      isEndDay: json['isEndDay'] as bool?,
      forecast: json['forecast'] == null
          ? null
          : Forecast.fromJson(json['forecast'] as Map<String, dynamic>),
      reality: json['reality'] == null
          ? null
          : Reality.fromJson(json['reality'] as Map<String, dynamic>),
      activitiesToday: (json['activitiesToday'] as List<dynamic>?)
          ?.map((e) => ActivityToday.fromJson(e as Map<String, dynamic>))
          .toList(),
      activitiesCompleted: json['activitiesCompleted'] as List<dynamic>?,
    );

Map<String, dynamic> _$ComparisonDataToJson(
  ComparisonData instance,
) => <String, dynamic>{
  'day': instance.day,
  'isEndDay': instance.isEndDay,
  'forecast': instance.forecast?.toJson(),
  'reality': instance.reality?.toJson(),
  'activitiesToday': instance.activitiesToday?.map((e) => e.toJson()).toList(),
  'activitiesCompleted': instance.activitiesCompleted,
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

Reality _$RealityFromJson(Map<String, dynamic> json) => Reality(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  wentAsForecast: json['wentAsForecast'] as bool?,
  compareToForecast: (json['compareToForecast'] as num?)?.toInt(),
  planUseful: json['planUseful'] as bool?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$RealityToJson(Reality instance) => <String, dynamic>{
  'emotions': instance.emotions?.map((e) => e.toJson()).toList(),
  'wentAsForecast': instance.wentAsForecast,
  'compareToForecast': instance.compareToForecast,
  'planUseful': instance.planUseful,
  'createdAt': instance.createdAt,
};

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
  key: json['key'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
  'key': instance.key,
  'intensity': instance.intensity,
  'imageUrl': instance.imageUrl,
};

ActivityToday _$ActivityTodayFromJson(Map<String, dynamic> json) =>
    ActivityToday(
      name: json['name'] as String?,
      isCustom: json['isCustom'] as bool?,
      isCompleted: json['isCompleted'] as bool?,
    );

Map<String, dynamic> _$ActivityTodayToJson(ActivityToday instance) =>
    <String, dynamic>{
      'name': instance.name,
      'isCustom': instance.isCustom,
      'isCompleted': instance.isCompleted,
    };
