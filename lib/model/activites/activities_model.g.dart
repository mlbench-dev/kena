// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activities_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivitiesModel _$ActivitiesModelFromJson(Map<String, dynamic> json) =>
    ActivitiesModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ActivityData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActivitiesModelToJson(ActivitiesModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ActivityData _$ActivityDataFromJson(Map<String, dynamic> json) => ActivityData(
  day: json['day'] as String?,
  activities: (json['activities'] as List<dynamic>?)
      ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  frequencies: (json['frequencies'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ActivityDataToJson(ActivityData instance) =>
    <String, dynamic>{
      'day': instance.day,
      'activities': instance.activities,
      'frequencies': instance.frequencies,
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  name: json['name'] as String?,
  frequency: json['frequency'] as String?,
  isCustom: json['isCustom'] as bool?,
  completed: json['completed'] as bool?,
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'name': instance.name,
  'frequency': instance.frequency,
  'isCustom': instance.isCustom,
  'completed': instance.completed,
};
