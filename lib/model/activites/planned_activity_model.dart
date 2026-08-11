import 'package:json_annotation/json_annotation.dart';

part 'planned_activity_model.g.dart';

@JsonSerializable()
class PlannedActivityModel {
  final bool? success;
  final String? message;
  final List<PlannedActivityData>? data;

  PlannedActivityModel({this.success, this.message, this.data});

  factory PlannedActivityModel.fromJson(Map<String, dynamic> json) =>
      _$PlannedActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlannedActivityModelToJson(this);
}

@JsonSerializable()
class PlannedActivityData {
  final List<Activity>? activities;

  PlannedActivityData({this.activities});

  factory PlannedActivityData.fromJson(Map<String, dynamic> json) =>
      _$PlannedActivityDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlannedActivityDataToJson(this);
}

@JsonSerializable()
class Activity {
  final String? id;
  final String? name;
  final Schedule? schedule;
  final bool? isCustom;
  final String? uiLabel;
  final String? uiBadge;

  Activity({
    this.id,
    this.name,
    this.schedule,
    this.isCustom,
    this.uiLabel,
    this.uiBadge,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class Schedule {
  final String? frequency;

  /// Replaced List<Null> with List<dynamic>
  final List<dynamic>? weeklyDays;
  final List<dynamic>? monthlyDays;
  final int? monthlyWeekDay;
  final int? monthlyWeekNumber;

  Schedule({
    this.frequency,
    this.weeklyDays,
    this.monthlyDays,
    this.monthlyWeekDay,
    this.monthlyWeekNumber,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}
