// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought_monitoring_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThoughtMonitoringSettingsModel _$ThoughtMonitoringSettingsModelFromJson(
  Map<String, dynamic> json,
) => ThoughtMonitoringSettingsModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map(
        (e) =>
            ThoughtMonitoringSettingsData.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ThoughtMonitoringSettingsModelToJson(
  ThoughtMonitoringSettingsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

ThoughtMonitoringSettingsData _$ThoughtMonitoringSettingsDataFromJson(
  Map<String, dynamic> json,
) => ThoughtMonitoringSettingsData(
  enabled: json['enabled'] as bool?,
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  timezoneOffsetMinutes: (json['timezoneOffsetMinutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$ThoughtMonitoringSettingsDataToJson(
  ThoughtMonitoringSettingsData instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'timezoneOffsetMinutes': instance.timezoneOffsetMinutes,
};
