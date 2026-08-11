// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EndDayModel _$EndDayModelFromJson(Map<String, dynamic> json) => EndDayModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => EndDayData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EndDayModelToJson(EndDayModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

EndDayData _$EndDayDataFromJson(Map<String, dynamic> json) => EndDayData(
  day: json['day'] as String?,
  endDay: json['endDay'] == null
      ? null
      : EndDay.fromJson(json['endDay'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EndDayDataToJson(EndDayData instance) =>
    <String, dynamic>{'day': instance.day, 'endDay': instance.endDay};

EndDay _$EndDayFromJson(Map<String, dynamic> json) => EndDay(
  emotions: (json['emotions'] as List<dynamic>?)
      ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  wentAsForecast: json['wentAsForecast'] as bool?,
  compareToForecast: (json['compareToForecast'] as num?)?.toInt(),
  planUseful: json['planUseful'] as bool?,
  planFeedback: json['planFeedback'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$EndDayToJson(EndDay instance) => <String, dynamic>{
  'emotions': instance.emotions,
  'wentAsForecast': instance.wentAsForecast,
  'compareToForecast': instance.compareToForecast,
  'planUseful': instance.planUseful,
  'planFeedback': instance.planFeedback,
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
