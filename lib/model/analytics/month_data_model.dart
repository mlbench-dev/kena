import 'package:json_annotation/json_annotation.dart';

part 'month_data_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MonthDataModel {
  final bool? success;
  final String? message;
  final List<MonthData>? data;

  const MonthDataModel({this.success, this.message, this.data});

  factory MonthDataModel.fromJson(Map<String, dynamic> json) =>
      _$MonthDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonthDataModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MonthData {
  final String? month;
  final String? startDay;
  final String? endDay;
  final List<MonthDay>? days;

  const MonthData({this.month, this.startDay, this.endDay, this.days});

  factory MonthData.fromJson(Map<String, dynamic> json) =>
      _$MonthDataFromJson(json);

  Map<String, dynamic> toJson() => _$MonthDataToJson(this);
}

@JsonSerializable()
class MonthDay {
  final String? day;
  final bool? activity;
  final bool? core;
  final bool? aspirational;
  final bool? forecast;
  final bool? reflection;

  const MonthDay({
    this.day,
    this.activity,
    this.core,
    this.aspirational,
    this.forecast,
    this.reflection,
  });

  factory MonthDay.fromJson(Map<String, dynamic> json) =>
      _$MonthDayFromJson(json);

  Map<String, dynamic> toJson() => _$MonthDayToJson(this);
}
