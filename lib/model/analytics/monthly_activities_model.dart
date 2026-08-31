import 'package:json_annotation/json_annotation.dart';

part 'monthly_activities_model.g.dart';

@JsonSerializable()
class MonthlyActivitiesModel {
  final bool? success;
  final String? message;
  final List<MonthlyActivitiesData>? data;

  MonthlyActivitiesModel({this.success, this.message, this.data});

  factory MonthlyActivitiesModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyActivitiesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyActivitiesModelToJson(this);
}

@JsonSerializable()
class MonthlyActivitiesData {
  final String? period;
  final String? startDay;
  final String? endDay;
  final Progress? progress;
  final List<ActivityChartData>? chartData;
  final List<TopActivity>? topActivities;

  MonthlyActivitiesData({
    this.period,
    this.startDay,
    this.endDay,
    this.progress,
    this.chartData,
    this.topActivities,
  });

  factory MonthlyActivitiesData.fromJson(Map<String, dynamic> json) =>
      _$MonthlyActivitiesDataFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyActivitiesDataToJson(this);
}

@JsonSerializable()
class Progress {
  final int? percentage;
  final int? activitiesDone;
  final int? goal;

  Progress({this.percentage, this.activitiesDone, this.goal});

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}

@JsonSerializable()
class ActivityChartData {
  final String? day;
  final int? goal;
  final int? achieved;

  ActivityChartData({this.day, this.goal, this.achieved});

  factory ActivityChartData.fromJson(Map<String, dynamic> json) =>
      _$ActivityChartDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityChartDataToJson(this);
}

@JsonSerializable()
class TopActivity {
  final String? name;
  final int? count;
  final int? percentage;
  final String? duration;

  TopActivity({this.name, this.count, this.percentage, this.duration});

  factory TopActivity.fromJson(Map<String, dynamic> json) =>
      _$TopActivityFromJson(json);

  Map<String, dynamic> toJson() => _$TopActivityToJson(this);
}
