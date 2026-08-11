// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthDataModel _$MonthDataModelFromJson(Map<String, dynamic> json) =>
    MonthDataModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MonthData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MonthDataModelToJson(MonthDataModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

MonthData _$MonthDataFromJson(Map<String, dynamic> json) => MonthData(
  month: json['month'] as String?,
  startDay: json['startDay'] as String?,
  endDay: json['endDay'] as String?,
  days: (json['days'] as List<dynamic>?)
      ?.map((e) => MonthDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MonthDataToJson(MonthData instance) => <String, dynamic>{
  'month': instance.month,
  'startDay': instance.startDay,
  'endDay': instance.endDay,
  'days': instance.days?.map((e) => e.toJson()).toList(),
};

MonthDay _$MonthDayFromJson(Map<String, dynamic> json) => MonthDay(
  day: json['day'] as String?,
  activity: json['activity'] as bool?,
  core: json['core'] as bool?,
  aspirational: json['aspirational'] as bool?,
  forecast: json['forecast'] as bool?,
  reflection: json['reflection'] as bool?,
);

Map<String, dynamic> _$MonthDayToJson(MonthDay instance) => <String, dynamic>{
  'day': instance.day,
  'activity': instance.activity,
  'core': instance.core,
  'aspirational': instance.aspirational,
  'forecast': instance.forecast,
  'reflection': instance.reflection,
};
