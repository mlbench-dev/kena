// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_check_ins_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayCheckInsModel _$TodayCheckInsModelFromJson(Map<String, dynamic> json) =>
    TodayCheckInsModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TodayCheckInsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodayCheckInsModelToJson(TodayCheckInsModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

TodayCheckInsData _$TodayCheckInsDataFromJson(Map<String, dynamic> json) =>
    TodayCheckInsData(
      day: json['day'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CheckInItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodayCheckInsDataToJson(TodayCheckInsData instance) =>
    <String, dynamic>{'day': instance.day, 'items': instance.items};

CheckInItem _$CheckInItemFromJson(Map<String, dynamic> json) => CheckInItem(
  id: json['id'] as String?,
  mood: json['mood'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$CheckInItemToJson(CheckInItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mood': instance.mood,
      'createdAt': instance.createdAt,
    };
