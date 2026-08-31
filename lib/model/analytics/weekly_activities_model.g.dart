// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_activities_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyActivitiesModel _$WeeklyActivitiesModelFromJson(
  Map<String, dynamic> json,
) => WeeklyActivitiesModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => WeeklyActivitiesData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeeklyActivitiesModelToJson(
  WeeklyActivitiesModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

WeeklyActivitiesData _$WeeklyActivitiesDataFromJson(
  Map<String, dynamic> json,
) => WeeklyActivitiesData(
  period: json['period'] as String?,
  startDay: json['startDay'] as String?,
  endDay: json['endDay'] as String?,
  progress: json['progress'] == null
      ? null
      : Progress.fromJson(json['progress'] as Map<String, dynamic>),
  chartData: (json['chartData'] as List<dynamic>?)
      ?.map((e) => ActivityChartData.fromJson(e as Map<String, dynamic>))
      .toList(),
  topActivities: (json['topActivities'] as List<dynamic>?)
      ?.map((e) => TopActivity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeeklyActivitiesDataToJson(
  WeeklyActivitiesData instance,
) => <String, dynamic>{
  'period': instance.period,
  'startDay': instance.startDay,
  'endDay': instance.endDay,
  'progress': instance.progress,
  'chartData': instance.chartData,
  'topActivities': instance.topActivities,
};

Progress _$ProgressFromJson(Map<String, dynamic> json) => Progress(
  percentage: (json['percentage'] as num?)?.toInt(),
  activitiesDone: (json['activitiesDone'] as num?)?.toInt(),
  goal: (json['goal'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
  'percentage': instance.percentage,
  'activitiesDone': instance.activitiesDone,
  'goal': instance.goal,
};

ActivityChartData _$ActivityChartDataFromJson(Map<String, dynamic> json) =>
    ActivityChartData(
      day: json['day'] as String?,
      goal: (json['goal'] as num?)?.toInt(),
      achieved: (json['achieved'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ActivityChartDataToJson(ActivityChartData instance) =>
    <String, dynamic>{
      'day': instance.day,
      'goal': instance.goal,
      'achieved': instance.achieved,
    };

TopActivity _$TopActivityFromJson(Map<String, dynamic> json) => TopActivity(
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
  percentage: (json['percentage'] as num?)?.toInt(),
  duration: json['duration'] as String?,
);

Map<String, dynamic> _$TopActivityToJson(TopActivity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'percentage': instance.percentage,
      'duration': instance.duration,
    };
