// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsModel _$AnalyticsModelFromJson(Map<String, dynamic> json) =>
    AnalyticsModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AnalyticsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsModelToJson(AnalyticsModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AnalyticsData _$AnalyticsDataFromJson(Map<String, dynamic> json) =>
    AnalyticsData(
      period: json['period'] == null
          ? null
          : Period.fromJson(json['period'] as Map<String, dynamic>),
      summary: json['summary'] == null
          ? null
          : Summary.fromJson(json['summary'] as Map<String, dynamic>),
      coreAndAspirational: json['coreAndAspirational'] == null
          ? null
          : CoreAndAspirational.fromJson(
              json['coreAndAspirational'] as Map<String, dynamic>,
            ),
      topEmotions: json['topEmotions'] == null
          ? null
          : TopEmotions.fromJson(json['topEmotions'] as Map<String, dynamic>),
      charts: json['charts'] == null
          ? null
          : Charts.fromJson(json['charts'] as Map<String, dynamic>),
      distributions: json['distributions'] == null
          ? null
          : Distributions.fromJson(
              json['distributions'] as Map<String, dynamic>,
            ),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsDataToJson(AnalyticsData instance) =>
    <String, dynamic>{
      'period': instance.period,
      'summary': instance.summary,
      'coreAndAspirational': instance.coreAndAspirational,
      'topEmotions': instance.topEmotions,
      'charts': instance.charts,
      'distributions': instance.distributions,
      'activities': instance.activities,
    };

Period _$PeriodFromJson(Map<String, dynamic> json) => Period(
  startDay: json['startDay'] as String?,
  endDay: json['endDay'] as String?,
  days: (json['days'] as num?)?.toInt(),
);

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
  'startDay': instance.startDay,
  'endDay': instance.endDay,
  'days': instance.days,
};

Summary _$SummaryFromJson(Map<String, dynamic> json) => Summary(
  predictionAccuracyPercent: (json['predictionAccuracyPercent'] as num?)
      ?.toInt(),
  daysForecasted: (json['daysForecasted'] as num?)?.toInt(),
  daysReflected: (json['daysReflected'] as num?)?.toInt(),
  daysActualRecorded: (json['daysActualRecorded'] as num?)?.toInt(),
);

Map<String, dynamic> _$SummaryToJson(Summary instance) => <String, dynamic>{
  'predictionAccuracyPercent': instance.predictionAccuracyPercent,
  'daysForecasted': instance.daysForecasted,
  'daysReflected': instance.daysReflected,
  'daysActualRecorded': instance.daysActualRecorded,
};

CoreAndAspirational _$CoreAndAspirationalFromJson(Map<String, dynamic> json) =>
    CoreAndAspirational(
      core: (json['core'] as List<dynamic>?)
          ?.map((e) => CoreEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspirational: (json['aspirational'] as List<dynamic>?)
          ?.map((e) => AspirationalEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoreAndAspirationalToJson(
  CoreAndAspirational instance,
) => <String, dynamic>{
  'core': instance.core,
  'aspirational': instance.aspirational,
};

CoreEmotion _$CoreEmotionFromJson(Map<String, dynamic> json) => CoreEmotion(
  key: json['key'] as String?,
  name: json['name'] as String?,
  forecast: (json['forecast'] as num?)?.toInt(),
  actual: (json['actual'] as num?)?.toInt(),
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$CoreEmotionToJson(CoreEmotion instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'forecast': instance.forecast,
      'actual': instance.actual,
      'intensity': instance.intensity,
      'imageUrl': instance.imageUrl,
    };

AspirationalEmotion _$AspirationalEmotionFromJson(Map<String, dynamic> json) =>
    AspirationalEmotion(
      key: json['key'] as String?,
      name: json['name'] as String?,
      forecast: (json['forecast'] as num?)?.toInt(),
      actual: (json['actual'] as num?)?.toInt(),
      intensity: (json['intensity'] as num?)?.toInt(),
      emoji: json['emoji'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$AspirationalEmotionToJson(
  AspirationalEmotion instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'forecast': instance.forecast,
  'actual': instance.actual,
  'intensity': instance.intensity,
  'emoji': instance.emoji,
  'imageUrl': instance.imageUrl,
};

TopEmotions _$TopEmotionsFromJson(Map<String, dynamic> json) => TopEmotions(
  forecast: (json['forecast'] as List<dynamic>?)
      ?.map((e) => ForecastEmotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  actual: (json['actual'] as List<dynamic>?)
      ?.map((e) => ActualEmotion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TopEmotionsToJson(TopEmotions instance) =>
    <String, dynamic>{'forecast': instance.forecast, 'actual': instance.actual};

ForecastEmotion _$ForecastEmotionFromJson(Map<String, dynamic> json) =>
    ForecastEmotion(
      key: json['key'] as String?,
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
      percentOfPeriodDays: (json['percentOfPeriodDays'] as num?)?.toInt(),
      percentOfDenomDays: (json['percentOfDenomDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ForecastEmotionToJson(ForecastEmotion instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'count': instance.count,
      'percentOfPeriodDays': instance.percentOfPeriodDays,
      'percentOfDenomDays': instance.percentOfDenomDays,
    };

ActualEmotion _$ActualEmotionFromJson(Map<String, dynamic> json) =>
    ActualEmotion(
      key: json['key'] as String?,
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
      emoji: json['emoji'] as String?,
    );

Map<String, dynamic> _$ActualEmotionToJson(ActualEmotion instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'count': instance.count,
      'emoji': instance.emoji,
    };

Charts _$ChartsFromJson(Map<String, dynamic> json) => Charts(
  totalDaysForecastTop3: (json['totalDaysForecastTop3'] as List<dynamic>?)
      ?.map((e) => Top3.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalDaysActualTop3: (json['totalDaysActualTop3'] as List<dynamic>?)
      ?.map((e) => Top3.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChartsToJson(Charts instance) => <String, dynamic>{
  'totalDaysForecastTop3': instance.totalDaysForecastTop3,
  'totalDaysActualTop3': instance.totalDaysActualTop3,
};

Top3 _$Top3FromJson(Map<String, dynamic> json) => Top3(
  key: json['key'] as String?,
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
);

Map<String, dynamic> _$Top3ToJson(Top3 instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'count': instance.count,
};

Distributions _$DistributionsFromJson(Map<String, dynamic> json) =>
    Distributions(
      forecastByEmotion: (json['forecastByEmotion'] as List<dynamic>?)
          ?.map((e) => EmotionDistribution.fromJson(e as Map<String, dynamic>))
          .toList(),
      actualByEmotion: (json['actualByEmotion'] as List<dynamic>?)
          ?.map((e) => EmotionDistribution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DistributionsToJson(Distributions instance) =>
    <String, dynamic>{
      'forecastByEmotion': instance.forecastByEmotion,
      'actualByEmotion': instance.actualByEmotion,
    };

EmotionDistribution _$EmotionDistributionFromJson(Map<String, dynamic> json) =>
    EmotionDistribution(
      key: json['key'] as String?,
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EmotionDistributionToJson(
  EmotionDistribution instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'count': instance.count,
};

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  name: json['name'] as String?,
  frequency: json['frequency'] as String?,
  isCustom: json['isCustom'] as bool?,
  completedDays: (json['completedDays'] as num?)?.toInt(),
  targetCount: (json['targetCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'name': instance.name,
  'frequency': instance.frequency,
  'isCustom': instance.isCustom,
  'completedDays': instance.completedDays,
  'targetCount': instance.targetCount,
};
