// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayActivityModel _$TodayActivityModelFromJson(Map<String, dynamic> json) =>
    TodayActivityModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TodayActivityData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodayActivityModelToJson(TodayActivityModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

TodayActivityData _$TodayActivityDataFromJson(Map<String, dynamic> json) =>
    TodayActivityData(
      day: json['day'] as String?,
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodayActivityDataToJson(TodayActivityData instance) =>
    <String, dynamic>{
      'day': instance.day,
      'activities': instance.activities?.map((e) => e.toJson()).toList(),
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String?,
  name: json['name'] as String?,
  completed: json['completed'] as bool?,
  isCustom: json['isCustom'] as bool?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'completed': instance.completed,
  'isCustom': instance.isCustom,
};
