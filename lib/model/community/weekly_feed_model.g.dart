// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyFeedModel _$WeeklyFeedModelFromJson(Map<String, dynamic> json) =>
    WeeklyFeedModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FeedPeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WeeklyFeedModelToJson(WeeklyFeedModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

FeedPeriod _$FeedPeriodFromJson(Map<String, dynamic> json) => FeedPeriod(
  isWeeklyShared: json['isWeeklyShared'] as bool?,
  summary: json['summary'] == null
      ? null
      : Summary.fromJson(json['summary'] as Map<String, dynamic>),
  insights: json['insights'] == null
      ? null
      : Insights.fromJson(json['insights'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => FeedEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FeedPeriodToJson(FeedPeriod instance) =>
    <String, dynamic>{
      'isWeeklyShared': instance.isWeeklyShared,
      'summary': instance.summary?.toJson(),
      'insights': instance.insights?.toJson(),
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

Summary _$SummaryFromJson(Map<String, dynamic> json) => Summary(
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  totalEntries: (json['totalEntries'] as num?)?.toInt(),
  forecastCount: (json['forecastCount'] as num?)?.toInt(),
  reflectionCount: (json['reflectionCount'] as num?)?.toInt(),
  topEmotions: (json['topEmotions'] as List<dynamic>?)
      ?.map((e) => TopEmotions.fromJson(e as Map<String, dynamic>))
      .toList(),
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
  forecastVsActual: json['forecastVsActual'] == null
      ? null
      : ForecastVsActual.fromJson(
          json['forecastVsActual'] as Map<String, dynamic>,
        ),
  topActivities: (json['topActivities'] as List<dynamic>?)
      ?.map((e) => TopActivities.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SummaryToJson(Summary instance) => <String, dynamic>{
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'totalEntries': instance.totalEntries,
  'forecastCount': instance.forecastCount,
  'reflectionCount': instance.reflectionCount,
  'topEmotions': instance.topEmotions?.map((e) => e.toJson()).toList(),
  'predictionInsights': instance.predictionInsights?.toJson(),
  'planUseful': instance.planUseful?.toJson(),
  'worseBetterVsGoal': instance.worseBetterVsGoal?.toJson(),
  'forecastVsActual': instance.forecastVsActual?.toJson(),
  'topActivities': instance.topActivities?.map((e) => e.toJson()).toList(),
};

TopEmotions _$TopEmotionsFromJson(Map<String, dynamic> json) => TopEmotions(
  key: json['key'] as String?,
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
  title: json['title'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$TopEmotionsToJson(TopEmotions instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'count': instance.count,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
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
  authorId: json['authorId'] as String?,
  authorName: json['authorName'] as String?,
);

Map<String, dynamic> _$DailyValuesToJson(DailyValues instance) =>
    <String, dynamic>{
      'day': instance.day,
      'value': instance.value,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
    };

ForecastVsActual _$ForecastVsActualFromJson(Map<String, dynamic> json) =>
    ForecastVsActual(
      forecast: (json['forecast'] as List<dynamic>?)
          ?.map((e) => Forecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      actual: (json['actual'] as List<dynamic>?)
          ?.map((e) => Actual.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForecastVsActualToJson(ForecastVsActual instance) =>
    <String, dynamic>{
      'forecast': instance.forecast?.map((e) => e.toJson()).toList(),
      'actual': instance.actual?.map((e) => e.toJson()).toList(),
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
  key: json['key'] as String?,
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
  percentOfPeriodDays: (json['percentOfPeriodDays'] as num?)?.toInt(),
  percentOfDenomDays: (json['percentOfDenomDays'] as num?)?.toInt(),
  title: json['title'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'count': instance.count,
  'percentOfPeriodDays': instance.percentOfPeriodDays,
  'percentOfDenomDays': instance.percentOfDenomDays,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
};

Actual _$ActualFromJson(Map<String, dynamic> json) => Actual(
  key: json['key'] as String?,
  name: json['name'] as String?,
  count: (json['count'] as num?)?.toInt(),
  percentOfPeriodDays: (json['percentOfPeriodDays'] as num?)?.toInt(),
  percentOfDenomDays: (json['percentOfDenomDays'] as num?)?.toInt(),
  title: json['title'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ActualToJson(Actual instance) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'count': instance.count,
  'percentOfPeriodDays': instance.percentOfPeriodDays,
  'percentOfDenomDays': instance.percentOfDenomDays,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
};

TopActivities _$TopActivitiesFromJson(Map<String, dynamic> json) =>
    TopActivities(
      name: json['name'] as String?,
      goalCount: (json['goalCount'] as num?)?.toInt(),
      achievedCount: (json['achievedCount'] as num?)?.toInt(),
      achievementPercent: (json['achievementPercent'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TopActivitiesToJson(TopActivities instance) =>
    <String, dynamic>{
      'name': instance.name,
      'goalCount': instance.goalCount,
      'achievedCount': instance.achievedCount,
      'achievementPercent': instance.achievementPercent,
    };

Insights _$InsightsFromJson(Map<String, dynamic> json) => Insights(
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
  forecastVsActual: json['forecastVsActual'] == null
      ? null
      : ForecastVsActual.fromJson(
          json['forecastVsActual'] as Map<String, dynamic>,
        ),
  topActivities: (json['topActivities'] as List<dynamic>?)
      ?.map((e) => TopActivities.fromJson(e as Map<String, dynamic>))
      .toList(),
  topEmotions: (json['topEmotions'] as List<dynamic>?)
      ?.map((e) => TopEmotions.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InsightsToJson(Insights instance) => <String, dynamic>{
  'predictionInsights': instance.predictionInsights?.toJson(),
  'planUseful': instance.planUseful?.toJson(),
  'worseBetterVsGoal': instance.worseBetterVsGoal?.toJson(),
  'forecastVsActual': instance.forecastVsActual?.toJson(),
  'topActivities': instance.topActivities?.map((e) => e.toJson()).toList(),
  'topEmotions': instance.topEmotions?.map((e) => e.toJson()).toList(),
};

FeedEntry _$FeedEntryFromJson(Map<String, dynamic> json) => FeedEntry(
  id: json['_id'] as String?,
  day: json['day'] as String?,
  createdAt: json['createdAt'] as String?,
  author: json['author'] == null
      ? null
      : Author.fromJson(json['author'] as Map<String, dynamic>),
  dominantEmotions: (json['dominantEmotions'] as List<dynamic>?)
      ?.map((e) => DominantEmotions.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasForecast: json['hasForecast'] as bool?,
  hasReflection: json['hasReflection'] as bool?,
  wentAsForecast: json['wentAsForecast'] as bool?,
  compareToForecast: (json['compareToForecast'] as num?)?.toInt(),
);

Map<String, dynamic> _$FeedEntryToJson(FeedEntry instance) => <String, dynamic>{
  '_id': instance.id,
  'day': instance.day,
  'createdAt': instance.createdAt,
  'author': instance.author?.toJson(),
  'dominantEmotions': instance.dominantEmotions
      ?.map((e) => e.toJson())
      .toList(),
  'hasForecast': instance.hasForecast,
  'hasReflection': instance.hasReflection,
  'wentAsForecast': instance.wentAsForecast,
  'compareToForecast': instance.compareToForecast,
};

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  id: json['_id'] as String?,
  username: json['username'] as String?,
  aliasName: json['aliasName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  '_id': instance.id,
  'username': instance.username,
  'aliasName': instance.aliasName,
  'avatarUrl': instance.avatarUrl,
  'email': instance.email,
};

DominantEmotions _$DominantEmotionsFromJson(Map<String, dynamic> json) =>
    DominantEmotions(
      key: json['key'] as String?,
      intensity: (json['intensity'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$DominantEmotionsToJson(DominantEmotions instance) =>
    <String, dynamic>{
      'key': instance.key,
      'intensity': instance.intensity,
      'imageUrl': instance.imageUrl,
      'source': instance.source,
      'title': instance.title,
    };
