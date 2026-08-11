// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_emotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultEmotionModel _$ResultEmotionModelFromJson(Map<String, dynamic> json) =>
    ResultEmotionModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ResultEmotionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResultEmotionModelToJson(ResultEmotionModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ResultEmotionData _$ResultEmotionDataFromJson(Map<String, dynamic> json) =>
    ResultEmotionData(
      coreEmotions: (json['coreEmotions'] as List<dynamic>?)
          ?.map((e) => CoreEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspirationEmotions: (json['aspirationEmotions'] as List<dynamic>?)
          ?.map((e) => AspirationEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspirationReassessDate: json['aspirationReassessDate'] as String?,
      reviewDate: json['reviewDate'] as String?,
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResultEmotionDataToJson(ResultEmotionData instance) =>
    <String, dynamic>{
      'coreEmotions': instance.coreEmotions,
      'aspirationEmotions': instance.aspirationEmotions,
      'aspirationReassessDate': instance.aspirationReassessDate,
      'reviewDate': instance.reviewDate,
      'activities': instance.activities,
    };

CoreEmotion _$CoreEmotionFromJson(Map<String, dynamic> json) => CoreEmotion(
  key: json['key'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  id: json['_id'] as String?,
);

Map<String, dynamic> _$CoreEmotionToJson(CoreEmotion instance) =>
    <String, dynamic>{
      'key': instance.key,
      'intensity': instance.intensity,
      'imageUrl': instance.imageUrl,
      '_id': instance.id,
    };

AspirationEmotion _$AspirationEmotionFromJson(Map<String, dynamic> json) =>
    AspirationEmotion(
      key: json['key'] as String?,
      intensity: (json['intensity'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$AspirationEmotionToJson(AspirationEmotion instance) =>
    <String, dynamic>{
      'key': instance.key,
      'intensity': instance.intensity,
      'imageUrl': instance.imageUrl,
      '_id': instance.id,
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String?,
  name: json['name'] as String?,
  schedule: json['schedule'] == null
      ? null
      : Schedule.fromJson(json['schedule'] as Map<String, dynamic>),
  isCustom: json['isCustom'] as bool?,
  uiLabel: json['uiLabel'] as String?,
  uiBadge: json['uiBadge'] as String?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'schedule': instance.schedule,
  'isCustom': instance.isCustom,
  'uiLabel': instance.uiLabel,
  'uiBadge': instance.uiBadge,
};

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  frequency: json['frequency'] as String?,
  monthlyWeekDay: (json['monthlyWeekDay'] as num?)?.toInt(),
  monthlyWeekNumber: (json['monthlyWeekNumber'] as num?)?.toInt(),
  monthlyDay: (json['monthlyDay'] as num?)?.toInt(),
  monthlyDays: (json['monthlyDays'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  weeklyDays: (json['weeklyDays'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'frequency': instance.frequency,
  'monthlyWeekDay': instance.monthlyWeekDay,
  'monthlyWeekNumber': instance.monthlyWeekNumber,
  'monthlyDay': instance.monthlyDay,
  'monthlyDays': instance.monthlyDays,
  'weeklyDays': instance.weeklyDays,
};
