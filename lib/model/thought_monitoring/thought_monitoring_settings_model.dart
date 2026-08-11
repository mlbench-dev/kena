import 'package:json_annotation/json_annotation.dart';

part 'thought_monitoring_settings_model.g.dart';

@JsonSerializable()
class ThoughtMonitoringSettingsModel {
  final bool? success;
  final String? message;
  final List<ThoughtMonitoringSettingsData>? data;

  ThoughtMonitoringSettingsModel({this.success, this.message, this.data});

  factory ThoughtMonitoringSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$ThoughtMonitoringSettingsModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ThoughtMonitoringSettingsModelToJson(this);
}

@JsonSerializable()
class ThoughtMonitoringSettingsData {
  final bool? enabled;
  final String? startTime;
  final String? endTime;
  final int? timezoneOffsetMinutes;

  ThoughtMonitoringSettingsData({
    this.enabled,
    this.startTime,
    this.endTime,
    this.timezoneOffsetMinutes,
  });

  factory ThoughtMonitoringSettingsData.fromJson(Map<String, dynamic> json) =>
      _$ThoughtMonitoringSettingsDataFromJson(json);

  Map<String, dynamic> toJson() => _$ThoughtMonitoringSettingsDataToJson(this);
}
