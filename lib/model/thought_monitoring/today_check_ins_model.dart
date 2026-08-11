import 'package:json_annotation/json_annotation.dart';

part 'today_check_ins_model.g.dart';

@JsonSerializable()
class TodayCheckInsModel {
  final bool? success;
  final String? message;
  final List<TodayCheckInsData>? data;

  TodayCheckInsModel({this.success, this.message, this.data});

  factory TodayCheckInsModel.fromJson(Map<String, dynamic> json) =>
      _$TodayCheckInsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayCheckInsModelToJson(this);
}

@JsonSerializable()
class TodayCheckInsData {
  final String? day;
  final List<CheckInItem>? items;

  TodayCheckInsData({this.day, this.items});

  factory TodayCheckInsData.fromJson(Map<String, dynamic> json) =>
      _$TodayCheckInsDataFromJson(json);

  Map<String, dynamic> toJson() => _$TodayCheckInsDataToJson(this);
}

@JsonSerializable()
class CheckInItem {
  final String? id;
  final String? mood;
  final String? createdAt;

  CheckInItem({this.id, this.mood, this.createdAt});

  factory CheckInItem.fromJson(Map<String, dynamic> json) =>
      _$CheckInItemFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInItemToJson(this);
}
