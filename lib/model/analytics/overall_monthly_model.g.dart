// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overall_monthly_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverallMonthlyModel _$OverallMonthlyModelFromJson(Map<String, dynamic> json) =>
    OverallMonthlyModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OverallMonthlyModelToJson(
  OverallMonthlyModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  period: json['period'] == null
      ? null
      : Period.fromJson(json['period'] as Map<String, dynamic>),
  predictionInsights: json['predictionInsights'] == null
      ? null
      : PredictionInsights.fromJson(
          json['predictionInsights'] as Map<String, dynamic>,
        ),
  planUseful: json['planUseful'] == null
      ? null
      : PlanUseful.fromJson(json['planUseful'] as Map<String, dynamic>),
  worseBetterVsGoal: json['worseBetterVsGoal'] == null
      ? null
      : WorseBetterVsGoal.fromJson(
          json['worseBetterVsGoal'] as Map<String, dynamic>,
        ),
  topEmotions: json['topEmotions'] == null
      ? null
      : TopEmotions.fromJson(json['topEmotions'] as Map<String, dynamic>),
  coreAndAspirational: json['coreAndAspirational'] == null
      ? null
      : CoreAndAspirational.fromJson(
          json['coreAndAspirational'] as Map<String, dynamic>,
        ),
  topActivities: (json['topActivities'] as List<dynamic>?)
      ?.map((e) => TopActivities.fromJson(e as Map<String, dynamic>))
      .toList(),
  thoughtMonitoring: json['thoughtMonitoring'] == null
      ? null
      : ThoughtMonitoring.fromJson(
          json['thoughtMonitoring'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'period': instance.period?.toJson(),
  'predictionInsights': instance.predictionInsights?.toJson(),
  'planUseful': instance.planUseful?.toJson(),
  'worseBetterVsGoal': instance.worseBetterVsGoal?.toJson(),
  'topEmotions': instance.topEmotions?.toJson(),
  'coreAndAspirational': instance.coreAndAspirational?.toJson(),
  'topActivities': instance.topActivities?.map((e) => e.toJson()).toList(),
  'thoughtMonitoring': instance.thoughtMonitoring?.toJson(),
};

Period _$PeriodFromJson(Map<String, dynamic> json) => Period(
  startDay: json['startDay'] as String?,
  endDay: json['endDay'] as String?,
  days: (json['days'] as num?)?.toInt(),
  type: json['type'] as String?,
);

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
  'startDay': instance.startDay,
  'endDay': instance.endDay,
  'days': instance.days,
  'type': instance.type,
};

PredictionInsights _$PredictionInsightsFromJson(Map<String, dynamic> json) =>
    PredictionInsights(
      accuracyPercent: (json['accuracyPercent'] as num?)?.toInt(),
      matchedDays: (json['matchedDays'] as num?)?.toInt(),
      daysForecasted: (json['daysForecasted'] as num?)?.toInt(),
      daysActualRecorded: (json['daysActualRecorded'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PredictionInsightsToJson(PredictionInsights instance) =>
    <String, dynamic>{
      'accuracyPercent': instance.accuracyPercent,
      'matchedDays': instance.matchedDays,
      'daysForecasted': instance.daysForecasted,
      'daysActualRecorded': instance.daysActualRecorded,
    };

PlanUseful _$PlanUsefulFromJson(Map<String, dynamic> json) =>
    PlanUseful(percent: (json['percent'] as num?)?.toInt());

Map<String, dynamic> _$PlanUsefulToJson(PlanUseful instance) =>
    <String, dynamic>{'percent': instance.percent};

WorseBetterVsGoal _$WorseBetterVsGoalFromJson(Map<String, dynamic> json) =>
    WorseBetterVsGoal(
      dailyValues: (json['dailyValues'] as List<dynamic>?)
          ?.map((e) => DailyValues.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorseBetterVsGoalToJson(WorseBetterVsGoal instance) =>
    <String, dynamic>{
      'dailyValues': instance.dailyValues?.map((e) => e.toJson()).toList(),
    };

DailyValues _$DailyValuesFromJson(Map<String, dynamic> json) => DailyValues(
  day: json['day'] as String?,
  value: (json['value'] as num?)?.toInt(),
);

Map<String, dynamic> _$DailyValuesToJson(DailyValues instance) =>
    <String, dynamic>{'day': instance.day, 'value': instance.value};

TopEmotions _$TopEmotionsFromJson(Map<String, dynamic> json) => TopEmotions(
  forecast: (json['forecast'] as List<dynamic>?)
      ?.map((e) => Forecast.fromJson(e as Map<String, dynamic>))
      .toList(),
  actual: (json['actual'] as List<dynamic>?)
      ?.map((e) => Actual.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TopEmotionsToJson(TopEmotions instance) =>
    <String, dynamic>{
      'forecast': instance.forecast?.map((e) => e.toJson()).toList(),
      'actual': instance.actual?.map((e) => e.toJson()).toList(),
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
  key: json['key'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  count: (json['count'] as num?)?.toInt(),
  intensity: json['intensity'] as num?,
  intensityLabel: json['intensityLabel'] as String?,
  percentOfPeriodDays: (json['percentOfPeriodDays'] as num?)?.toInt(),
  percentOfDenomDays: (json['percentOfDenomDays'] as num?)?.toInt(),
  emoji: json['emoji'] as String?,
);

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'count': instance.count,
  'intensity': instance.intensity,
  'intensityLabel': instance.intensityLabel,
  'percentOfPeriodDays': instance.percentOfPeriodDays,
  'percentOfDenomDays': instance.percentOfDenomDays,
  'emoji': instance.emoji,
};

Actual _$ActualFromJson(Map<String, dynamic> json) => Actual(
  key: json['key'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  count: (json['count'] as num?)?.toInt(),
  intensity: json['intensity'] as num?,
  intensityLabel: json['intensityLabel'] as String?,
  percentOfPeriodDays: (json['percentOfPeriodDays'] as num?)?.toInt(),
  percentOfDenomDays: (json['percentOfDenomDays'] as num?)?.toInt(),
);

Map<String, dynamic> _$ActualToJson(Actual instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'count': instance.count,
  'intensity': instance.intensity,
  'intensityLabel': instance.intensityLabel,
  'percentOfPeriodDays': instance.percentOfPeriodDays,
  'percentOfDenomDays': instance.percentOfDenomDays,
};

CoreAndAspirational _$CoreAndAspirationalFromJson(Map<String, dynamic> json) =>
    CoreAndAspirational(
      core: (json['core'] as List<dynamic>?)
          ?.map((e) => Core.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspirational: (json['aspirational'] as List<dynamic>?)
          ?.map((e) => Aspirational.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoreAndAspirationalToJson(
  CoreAndAspirational instance,
) => <String, dynamic>{
  'core': instance.core?.map((e) => e.toJson()).toList(),
  'aspirational': instance.aspirational?.map((e) => e.toJson()).toList(),
};

Core _$CoreFromJson(Map<String, dynamic> json) => Core(
  key: json['key'] as String?,
  name: json['name'] as String?,
  forecast: (json['forecast'] as num?)?.toInt(),
  actual: (json['actual'] as num?)?.toInt(),
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$CoreToJson(Core instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'forecast': instance.forecast,
  'actual': instance.actual,
  'intensity': instance.intensity,
  'imageUrl': instance.imageUrl,
};

Aspirational _$AspirationalFromJson(Map<String, dynamic> json) => Aspirational(
  key: json['key'] as String?,
  name: json['name'] as String?,
  emoji: json['emoji'] as String?,
  forecast: (json['forecast'] as num?)?.toInt(),
  actual: (json['actual'] as num?)?.toInt(),
  intensity: (json['intensity'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$AspirationalToJson(Aspirational instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'emoji': instance.emoji,
      'forecast': instance.forecast,
      'actual': instance.actual,
      'intensity': instance.intensity,
      'imageUrl': instance.imageUrl,
    };

TopActivities _$TopActivitiesFromJson(Map<String, dynamic> json) =>
    TopActivities(
      name: json['name'] as String?,
      frequency: json['frequency'] as String?,
      isCustom: json['isCustom'] as bool?,
      completedDays: (json['completedDays'] as num?)?.toInt(),
      targetCount: (json['targetCount'] as num?)?.toInt(),
      achievementPercent: (json['achievementPercent'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TopActivitiesToJson(TopActivities instance) =>
    <String, dynamic>{
      'name': instance.name,
      'frequency': instance.frequency,
      'isCustom': instance.isCustom,
      'completedDays': instance.completedDays,
      'targetCount': instance.targetCount,
      'achievementPercent': instance.achievementPercent,
    };

ThoughtMonitoring _$ThoughtMonitoringFromJson(Map<String, dynamic> json) =>
    ThoughtMonitoring(
      positive: (json['positive'] as num?)?.toInt(),
      neutral: (json['neutral'] as num?)?.toInt(),
      negative: (json['negative'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      raw: json['raw'] == null
          ? null
          : Raw.fromJson(json['raw'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThoughtMonitoringToJson(ThoughtMonitoring instance) =>
    <String, dynamic>{
      'positive': instance.positive,
      'neutral': instance.neutral,
      'negative': instance.negative,
      'total': instance.total,
      'raw': instance.raw?.toJson(),
    };

Raw _$RawFromJson(Map<String, dynamic> json) => Raw(
  positive: (json['positive'] as num?)?.toInt(),
  neutral: (json['neutral'] as num?)?.toInt(),
  negative: (json['negative'] as num?)?.toInt(),
);

Map<String, dynamic> _$RawToJson(Raw instance) => <String, dynamic>{
  'positive': instance.positive,
  'neutral': instance.neutral,
  'negative': instance.negative,
};
