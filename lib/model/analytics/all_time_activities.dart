import 'package:json_annotation/json_annotation.dart';

part 'all_time_activities.g.dart';

@JsonSerializable(explicitToJson: true)
class AllTimeActivities {
  final bool? success;
  final String? message;
  final List<AllTimeActivitiesData>? data;

  const AllTimeActivities({this.success, this.message, this.data});

  factory AllTimeActivities.fromJson(Map<String, dynamic> json) =>
      _$AllTimeActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$AllTimeActivitiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AllTimeActivitiesData {
  final String? period;
  final String? startDay;
  final String? endDay;
  final Progress? progress;
  final List<ChartData>? chartData;
  final List<TopActivities>? topActivities;

  const AllTimeActivitiesData({
    this.period,
    this.startDay,
    this.endDay,
    this.progress,
    this.chartData,
    this.topActivities,
  });

  factory AllTimeActivitiesData.fromJson(Map<String, dynamic> json) =>
      _$AllTimeActivitiesDataFromJson(json);

  Map<String, dynamic> toJson() => _$AllTimeActivitiesDataToJson(this);
}

@JsonSerializable()
class Progress {
  final int? percentage;
  final int? activitiesDone;
  final int? goal;

  const Progress({this.percentage, this.activitiesDone, this.goal});

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}

@JsonSerializable()
class ChartData {
  final int? month;
  final String? monthName;
  final int? goal;
  final int? achieved;

  const ChartData({this.month, this.monthName, this.goal, this.achieved});

  factory ChartData.fromJson(Map<String, dynamic> json) =>
      _$ChartDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChartDataToJson(this);
}

@JsonSerializable()
class TopActivities {
  final String? name;
  final int? count;
  final int? percentage;
  final String? duration;

  const TopActivities({this.name, this.count, this.percentage, this.duration});

  factory TopActivities.fromJson(Map<String, dynamic> json) =>
      _$TopActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$TopActivitiesToJson(this);
}
