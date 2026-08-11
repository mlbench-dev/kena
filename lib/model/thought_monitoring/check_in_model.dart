import 'package:json_annotation/json_annotation.dart';

part 'check_in_model.g.dart';

@JsonSerializable()
class CheckInModel {
  final bool? success;
  final String? message;
  final List<CheckInData>? data;

  CheckInModel({this.success, this.message, this.data});

  factory CheckInModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInModelToJson(this);
}

@JsonSerializable()
class CheckInData {
  final String? id;
  final String? mood;
  final String? day;
  final String? createdAt;

  CheckInData({this.id, this.mood, this.day, this.createdAt});

  factory CheckInData.fromJson(Map<String, dynamic> json) =>
      _$CheckInDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInDataToJson(this);
}
