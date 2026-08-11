import 'package:json_annotation/json_annotation.dart';

part 'activities_model.g.dart';

@JsonSerializable()
class ActivitiesModel {
  final bool? success;
  final String? message;
  final List<ActivityData>? data;

  ActivitiesModel({this.success, this.message, this.data});

  factory ActivitiesModel.fromJson(Map<String, dynamic> json) =>
      _$ActivitiesModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivitiesModelToJson(this);
}

@JsonSerializable()
class ActivityData {
  final String? day;
  final List<Activity>? activities;
  final List<String>? frequencies;

  ActivityData({this.day, this.activities, this.frequencies});

  factory ActivityData.fromJson(Map<String, dynamic> json) =>
      _$ActivityDataFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityDataToJson(this);
}

@JsonSerializable()
class Activity {
  final String? name;
  final String? frequency;
  final bool? isCustom;
  final bool? completed;

  Activity({this.name, this.frequency, this.isCustom, this.completed});

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
