import 'package:json_annotation/json_annotation.dart';

part 'weekly_feed_model.g.dart';

// NOTE: The original version of this file declared two different classes
// both named `Data` (one holding summary/insights, one holding a single
// feed entry's id/day/author/emotions). That's a duplicate-symbol compile
// error in Dart. They've been split into `FeedPeriod` and `FeedEntry`
// below — rename them further if your team has different preferred names.

@JsonSerializable(explicitToJson: true)
class WeeklyFeedModel {
  final bool? success;
  final String? message;
  final List<FeedPeriod>? data;

  WeeklyFeedModel({this.success, this.message, this.data});

  factory WeeklyFeedModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyFeedModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyFeedModelToJson(this);
}

/// A summarized period (e.g. a week) of feed activity: an aggregate
/// [summary]/[insights] pair plus the individual [data] entries that make
/// up that period.
@JsonSerializable(explicitToJson: true)
class FeedPeriod {
  final bool? isWeeklyShared;
  final Summary? summary;
  final Insights? insights;
  final List<FeedEntry>? data;

  FeedPeriod({this.isWeeklyShared, this.summary, this.insights, this.data});

  factory FeedPeriod.fromJson(Map<String, dynamic> json) =>
      _$FeedPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$FeedPeriodToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Summary {
  final String? startDate;
  final String? endDate;
  final int? totalEntries;
  final int? forecastCount;
  final int? reflectionCount;
  final List<TopEmotions>? topEmotions;
  final PredictionInsights? predictionInsights;
  final PlanUseful? planUseful;
  final WorseBetterVsGoal? worseBetterVsGoal;
  final ForecastVsActual? forecastVsActual;
  final List<TopActivities>? topActivities;

  Summary({
    this.startDate,
    this.endDate,
    this.totalEntries,
    this.forecastCount,
    this.reflectionCount,
    this.topEmotions,
    this.predictionInsights,
    this.planUseful,
    this.worseBetterVsGoal,
    this.forecastVsActual,
    this.topActivities,
  });

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TopEmotions {
  final String? key;
  final String? name;
  final int? count;
  final String? title;
  final String? imageUrl;

  TopEmotions({this.key, this.name, this.count, this.title, this.imageUrl});

  factory TopEmotions.fromJson(Map<String, dynamic> json) =>
      _$TopEmotionsFromJson(json);

  Map<String, dynamic> toJson() => _$TopEmotionsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PredictionInsights {
  final int? accuracyPercent;
  final int? matchedDays;
  final int? daysForecasted;
  final int? daysActualRecorded;

  PredictionInsights({
    this.accuracyPercent,
    this.matchedDays,
    this.daysForecasted,
    this.daysActualRecorded,
  });

  factory PredictionInsights.fromJson(Map<String, dynamic> json) =>
      _$PredictionInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionInsightsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlanUseful {
  final int? percent;

  PlanUseful({this.percent});

  factory PlanUseful.fromJson(Map<String, dynamic> json) =>
      _$PlanUsefulFromJson(json);

  Map<String, dynamic> toJson() => _$PlanUsefulToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WorseBetterVsGoal {
  final List<DailyValues>? dailyValues;

  WorseBetterVsGoal({this.dailyValues});

  factory WorseBetterVsGoal.fromJson(Map<String, dynamic> json) =>
      _$WorseBetterVsGoalFromJson(json);

  Map<String, dynamic> toJson() => _$WorseBetterVsGoalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DailyValues {
  final String? day;
  final int? value;
  final String? authorId;
  final String? authorName;

  DailyValues({this.day, this.value, this.authorId, this.authorName});

  factory DailyValues.fromJson(Map<String, dynamic> json) =>
      _$DailyValuesFromJson(json);

  Map<String, dynamic> toJson() => _$DailyValuesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ForecastVsActual {
  final List<Forecast>? forecast;
  final List<Actual>? actual;

  ForecastVsActual({this.forecast, this.actual});

  factory ForecastVsActual.fromJson(Map<String, dynamic> json) =>
      _$ForecastVsActualFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastVsActualToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Forecast {
  final String? key;
  final String? name;
  final int? count;
  final int? percentOfPeriodDays;
  final int? percentOfDenomDays;
  final String? title;
  final String? imageUrl;

  Forecast({
    this.key,
    this.name,
    this.count,
    this.percentOfPeriodDays,
    this.percentOfDenomDays,
    this.title,
    this.imageUrl,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

/// The original file referenced an `Actual` class inside
/// `ForecastVsActual` (`List<Actual>? actual`) but never defined it — its
/// `fromJson`/`toJson` were effectively no-ops that always produced an
/// empty list. Modeled here with the same shape as [Forecast], since that's
/// the counterpart it's compared against; adjust the fields if the real API
/// response differs.
@JsonSerializable(explicitToJson: true)
class Actual {
  final String? key;
  final String? name;
  final int? count;
  final int? percentOfPeriodDays;
  final int? percentOfDenomDays;
  final String? title;
  final String? imageUrl;

  Actual({
    this.key,
    this.name,
    this.count,
    this.percentOfPeriodDays,
    this.percentOfDenomDays,
    this.title,
    this.imageUrl,
  });

  factory Actual.fromJson(Map<String, dynamic> json) => _$ActualFromJson(json);

  Map<String, dynamic> toJson() => _$ActualToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TopActivities {
  final String? name;
  final int? goalCount;
  final int? achievedCount;
  final int? achievementPercent;

  TopActivities({
    this.name,
    this.goalCount,
    this.achievedCount,
    this.achievementPercent,
  });

  factory TopActivities.fromJson(Map<String, dynamic> json) =>
      _$TopActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$TopActivitiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Insights {
  final PredictionInsights? predictionInsights;
  final PlanUseful? planUseful;
  final WorseBetterVsGoal? worseBetterVsGoal;
  final ForecastVsActual? forecastVsActual;
  final List<TopActivities>? topActivities;
  final List<TopEmotions>? topEmotions;

  Insights({
    this.predictionInsights,
    this.planUseful,
    this.worseBetterVsGoal,
    this.forecastVsActual,
    this.topActivities,
    this.topEmotions,
  });

  factory Insights.fromJson(Map<String, dynamic> json) =>
      _$InsightsFromJson(json);

  Map<String, dynamic> toJson() => _$InsightsToJson(this);
}

/// A single day's feed entry (was named `Data` in the original file —
/// renamed to avoid colliding with [FeedPeriod], which was also `Data`).
@JsonSerializable(explicitToJson: true)
class FeedEntry {
  @JsonKey(name: '_id')
  final String? id;
  final String? day;
  final String? createdAt;
  final Author? author;
  final List<DominantEmotions>? dominantEmotions;
  final bool? hasForecast;
  final bool? hasReflection;
  final bool? wentAsForecast;
  final int? compareToForecast;

  FeedEntry({
    this.id,
    this.day,
    this.createdAt,
    this.author,
    this.dominantEmotions,
    this.hasForecast,
    this.hasReflection,
    this.wentAsForecast,
    this.compareToForecast,
  });

  factory FeedEntry.fromJson(Map<String, dynamic> json) =>
      _$FeedEntryFromJson(json);

  Map<String, dynamic> toJson() => _$FeedEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Author {
  @JsonKey(name: '_id')
  final String? id;
  final String? username;
  final String? aliasName;
  final String? avatarUrl;
  final String? email;

  Author({this.id, this.username, this.aliasName, this.avatarUrl, this.email});

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DominantEmotions {
  final String? key;
  final int? intensity;
  final String? imageUrl;
  final String? source;
  final String? title;

  DominantEmotions({
    this.key,
    this.intensity,
    this.imageUrl,
    this.source,
    this.title,
  });

  factory DominantEmotions.fromJson(Map<String, dynamic> json) =>
      _$DominantEmotionsFromJson(json);

  Map<String, dynamic> toJson() => _$DominantEmotionsToJson(this);
}
