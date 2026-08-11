// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_plan_activities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastPlanActivities _$ForecastPlanActivitiesFromJson(
  Map<String, dynamic> json,
) => ForecastPlanActivities(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => ForecastPlanData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ForecastPlanActivitiesToJson(
  ForecastPlanActivities instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

ForecastPlanData _$ForecastPlanDataFromJson(Map<String, dynamic> json) =>
    ForecastPlanData(
      day: json['day'] as String?,
      forecastPlan: json['forecastPlan'] as String?,
      forecastActivities: json['forecastActivities'] as List<dynamic>?,
      plannedActivities: (json['plannedActivities'] as List<dynamic>?)
          ?.map((e) => PlannedActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForecastPlanDataToJson(ForecastPlanData instance) =>
    <String, dynamic>{
      'day': instance.day,
      'forecastPlan': instance.forecastPlan,
      'forecastActivities': instance.forecastActivities,
      'plannedActivities': instance.plannedActivities,
    };

PlannedActivity _$PlannedActivityFromJson(Map<String, dynamic> json) =>
    PlannedActivity(
      id: json['id'] as String?,
      name: json['name'] as String?,
      frequency: json['frequency'] as String?,
      isCustom: json['isCustom'] as bool?,
    );

Map<String, dynamic> _$PlannedActivityToJson(PlannedActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'frequency': instance.frequency,
      'isCustom': instance.isCustom,
    };
