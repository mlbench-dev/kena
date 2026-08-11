import 'package:json_annotation/json_annotation.dart';

part 'forecast_plan_activities.g.dart';

@JsonSerializable()
class ForecastPlanActivities {
  final bool? success;
  final String? message;
  final List<ForecastPlanData>? data;

  ForecastPlanActivities({this.success, this.message, this.data});

  factory ForecastPlanActivities.fromJson(Map<String, dynamic> json) =>
      _$ForecastPlanActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastPlanActivitiesToJson(this);
}

@JsonSerializable()
class ForecastPlanData {
  final String? day;
  final String? forecastPlan;

  /// Replace with a proper model if the API returns objects.
  final List<dynamic>? forecastActivities;

  final List<PlannedActivity>? plannedActivities;

  ForecastPlanData({
    this.day,
    this.forecastPlan,
    this.forecastActivities,
    this.plannedActivities,
  });

  factory ForecastPlanData.fromJson(Map<String, dynamic> json) =>
      _$ForecastPlanDataFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastPlanDataToJson(this);
}

@JsonSerializable()
class PlannedActivity {
  final String? id;
  final String? name;
  final String? frequency;
  final bool? isCustom;

  PlannedActivity({this.id, this.name, this.frequency, this.isCustom});

  factory PlannedActivity.fromJson(Map<String, dynamic> json) =>
      _$PlannedActivityFromJson(json);

  Map<String, dynamic> toJson() => _$PlannedActivityToJson(this);
}
