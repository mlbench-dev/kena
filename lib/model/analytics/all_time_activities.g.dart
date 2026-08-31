// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_time_activities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllTimeActivities _$AllTimeActivitiesFromJson(Map<String, dynamic> json) =>
    AllTimeActivities(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => AllTimeActivitiesData.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$AllTimeActivitiesToJson(AllTimeActivities instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

AllTimeActivitiesData _$AllTimeActivitiesDataFromJson(
  Map<String, dynamic> json,
) => AllTimeActivitiesData(
  period: json['period'] as String?,
  startDay: json['startDay'] as String?,
  endDay: json['endDay'] as String?,
  progress: json['progress'] == null
      ? null
      : Progress.fromJson(json['progress'] as Map<String, dynamic>),
  chartData: (json['chartData'] as List<dynamic>?)
      ?.map((e) => ChartData.fromJson(e as Map<String, dynamic>))
      .toList(),
  topActivities: (json['topActivities'] as List<dynamic>?)
      ?.map((e) => TopActivities.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AllTimeActivitiesDataToJson(
  AllTimeActivitiesData instance,
) => <String, dynamic>{
  'period': instance.period,
  'startDay': instance.startDay,
  'endDay': instance.endDay,
  'progress': instance.progress?.toJson(),
  'chartData': instance.chartData?.map((e) => e.toJson()).toList(),
  'topActivities': instance.topActivities?.map((e) => e.toJson()).toList(),
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

ChartData _$ChartDataFromJson(Map<String, dynamic> json) => ChartData(
  month: (json['month'] as num?)?.toInt(),
  monthName: json['monthName'] as String?,
  goal: (json['goal'] as num?)?.toInt(),
  achieved: (json['achieved'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChartDataToJson(ChartData instance) => <String, dynamic>{
  'month': instance.month,
  'monthName': instance.monthName,
  'goal': instance.goal,
  'achieved': instance.achieved,
};

TopActivities _$TopActivitiesFromJson(Map<String, dynamic> json) =>
    TopActivities(
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
      percentage: (json['percentage'] as num?)?.toInt(),
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$TopActivitiesToJson(TopActivities instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'percentage': instance.percentage,
      'duration': instance.duration,
    };
