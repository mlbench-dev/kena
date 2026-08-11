// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoreEmotionsResponse _$CoreEmotionsResponseFromJson(
  Map<String, dynamic> json,
) => CoreEmotionsResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => EmotionData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoreEmotionsResponseToJson(
  CoreEmotionsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

EmotionData _$EmotionDataFromJson(Map<String, dynamic> json) => EmotionData(
  coreEmotions: (json['coreEmotions'] as List<dynamic>?)
      ?.map((e) => EmotionItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  aspirationEmotions: (json['aspirationEmotions'] as List<dynamic>?)
      ?.map((e) => EmotionItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  aspirationReassessDate: json['aspirationReassessDate'] as String?,
);

Map<String, dynamic> _$EmotionDataToJson(EmotionData instance) =>
    <String, dynamic>{
      'coreEmotions': instance.coreEmotions,
      'aspirationEmotions': instance.aspirationEmotions,
      'aspirationReassessDate': instance.aspirationReassessDate,
    };

EmotionItem _$EmotionItemFromJson(Map<String, dynamic> json) => EmotionItem(
  key: json['key'] as String?,
  intensity: (json['intensity'] as num?)?.toInt(),
  id: json['_id'] as String?,
);

Map<String, dynamic> _$EmotionItemToJson(EmotionItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'intensity': instance.intensity,
      '_id': instance.id,
    };
