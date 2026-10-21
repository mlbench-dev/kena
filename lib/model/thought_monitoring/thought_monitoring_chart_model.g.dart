// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought_monitoring_chart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThoughtMonitoringChart _$ThoughtMonitoringChartFromJson(
  Map<String, dynamic> json,
) => ThoughtMonitoringChart(
  labels: (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList(),
  positive: (json['positive'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  negative: (json['negative'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  neutral: (json['neutral'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  skipped: (json['skipped'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$ThoughtMonitoringChartToJson(
  ThoughtMonitoringChart instance,
) => <String, dynamic>{
  'labels': instance.labels,
  'positive': instance.positive,
  'negative': instance.negative,
  'neutral': instance.neutral,
  'skipped': instance.skipped,
};
