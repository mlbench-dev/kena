// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlannedActivityModel _$PlannedActivityModelFromJson(
  Map<String, dynamic> json,
) => PlannedActivityModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => PlannedActivityData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlannedActivityModelToJson(
  PlannedActivityModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

PlannedActivityData _$PlannedActivityDataFromJson(Map<String, dynamic> json) =>
    PlannedActivityData(
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlannedActivityDataToJson(
  PlannedActivityData instance,
) => <String, dynamic>{'activities': instance.activities};

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
  weeklyDays: json['weeklyDays'] as List<dynamic>?,
  monthlyDays: json['monthlyDays'] as List<dynamic>?,
  monthlyWeekDay: (json['monthlyWeekDay'] as num?)?.toInt(),
  monthlyWeekNumber: (json['monthlyWeekNumber'] as num?)?.toInt(),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'frequency': instance.frequency,
  'weeklyDays': instance.weeklyDays,
  'monthlyDays': instance.monthlyDays,
  'monthlyWeekDay': instance.monthlyWeekDay,
  'monthlyWeekNumber': instance.monthlyWeekNumber,
};
