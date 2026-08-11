import 'package:json_annotation/json_annotation.dart';

part 'today_activity_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TodayActivityModel {
  final bool? success;
  final String? message;
  final List<TodayActivityData>? data;

  TodayActivityModel({this.success, this.message, this.data});

  factory TodayActivityModel.fromJson(Map<String, dynamic> json) =>
      _$TodayActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayActivityModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TodayActivityData {
  final String? day;
  final List<Activity>? activities;

  TodayActivityData({this.day, this.activities});

  factory TodayActivityData.fromJson(Map<String, dynamic> json) =>
      _$TodayActivityDataFromJson(json);

  Map<String, dynamic> toJson() => _$TodayActivityDataToJson(this);
}

@JsonSerializable()
class Activity {
  final String? id;
  final String? name;
  final bool? completed;
  final bool? isCustom;

  Activity({this.id, this.name, this.completed, this.isCustom});

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
