import 'package:json_annotation/json_annotation.dart';

part 'analytics_model.g.dart';

@JsonSerializable()
class AnalyticsModel {
  final bool? success;
  final String? message;
  final List<AnalyticsData>? data;

  AnalyticsModel({this.success, this.message, this.data});

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsModelToJson(this);
}

@JsonSerializable()
class AnalyticsData {
  final Period? period;
  final Summary? summary;
  final CoreAndAspirational? coreAndAspirational;
  final TopEmotions? topEmotions;
  final Charts? charts;
  final Distributions? distributions;
  final List<Activity>? activities;

  AnalyticsData({
    this.period,
    this.summary,
    this.coreAndAspirational,
    this.topEmotions,
    this.charts,
    this.distributions,
    this.activities,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDataToJson(this);
}

@JsonSerializable()
class Period {
  final String? startDay;
  final String? endDay;
  final int? days;

  Period({this.startDay, this.endDay, this.days});

  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodToJson(this);
}

@JsonSerializable()
class Summary {
  final int? predictionAccuracyPercent;
  final int? daysForecasted;
  final int? daysReflected;
  final int? daysActualRecorded;

  Summary({
    this.predictionAccuracyPercent,
    this.daysForecasted,
    this.daysReflected,
    this.daysActualRecorded,
  });

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryToJson(this);
}

@JsonSerializable()
class CoreAndAspirational {
  final List<CoreEmotion>? core;
  final List<AspirationalEmotion>? aspirational;

  CoreAndAspirational({this.core, this.aspirational});

  factory CoreAndAspirational.fromJson(Map<String, dynamic> json) =>
      _$CoreAndAspirationalFromJson(json);

  Map<String, dynamic> toJson() => _$CoreAndAspirationalToJson(this);
}

@JsonSerializable()
class CoreEmotion {
  final String? key;
  final String? name;
  final int? forecast;
  final int? actual;
  final int? intensity;
  final String? imageUrl;

  CoreEmotion({
    this.key,
    this.name,
    this.forecast,
    this.actual,
    this.intensity,
    this.imageUrl,
  });

  factory CoreEmotion.fromJson(Map<String, dynamic> json) =>
      _$CoreEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$CoreEmotionToJson(this);
}

@JsonSerializable()
class AspirationalEmotion {
  final String? key;
  final String? name;
  final int? forecast;
  final int? actual;
  final int? intensity;
  final String? emoji;
  final String? imageUrl;

  AspirationalEmotion({
    this.key,
    this.name,
    this.forecast,
    this.actual,
    this.intensity,
    this.emoji,
    this.imageUrl,
  });

  factory AspirationalEmotion.fromJson(Map<String, dynamic> json) =>
      _$AspirationalEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$AspirationalEmotionToJson(this);
}

@JsonSerializable()
class TopEmotions {
  final List<ForecastEmotion>? forecast;
  final List<ActualEmotion>? actual;

  TopEmotions({this.forecast, this.actual});

  factory TopEmotions.fromJson(Map<String, dynamic> json) =>
      _$TopEmotionsFromJson(json);

  Map<String, dynamic> toJson() => _$TopEmotionsToJson(this);
}

@JsonSerializable()
class ForecastEmotion {
  final String? key;
  final String? name;
  final int? count;
  final int? percentOfPeriodDays;
  final int? percentOfDenomDays;

  ForecastEmotion({
    this.key,
    this.name,
    this.count,
    this.percentOfPeriodDays,
    this.percentOfDenomDays,
  });

  factory ForecastEmotion.fromJson(Map<String, dynamic> json) =>
      _$ForecastEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastEmotionToJson(this);
}

@JsonSerializable()
class ActualEmotion {
  final String? key;
  final String? name;
  final int? count;
  final String? emoji;

  ActualEmotion({this.key, this.name, this.count, this.emoji});

  factory ActualEmotion.fromJson(Map<String, dynamic> json) =>
      _$ActualEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$ActualEmotionToJson(this);
}

@JsonSerializable()
class Charts {
  final List<Top3>? totalDaysForecastTop3;
  final List<Top3>? totalDaysActualTop3;

  Charts({this.totalDaysForecastTop3, this.totalDaysActualTop3});

  factory Charts.fromJson(Map<String, dynamic> json) => _$ChartsFromJson(json);

  Map<String, dynamic> toJson() => _$ChartsToJson(this);
}

@JsonSerializable()
class Top3 {
  final String? key;
  final String? name;
  final int? count;

  Top3({this.key, this.name, this.count});

  factory Top3.fromJson(Map<String, dynamic> json) => _$Top3FromJson(json);

  Map<String, dynamic> toJson() => _$Top3ToJson(this);
}

@JsonSerializable()
class Distributions {
  final List<EmotionDistribution>? forecastByEmotion;
  final List<EmotionDistribution>? actualByEmotion;

  Distributions({this.forecastByEmotion, this.actualByEmotion});

  factory Distributions.fromJson(Map<String, dynamic> json) =>
      _$DistributionsFromJson(json);

  Map<String, dynamic> toJson() => _$DistributionsToJson(this);
}

@JsonSerializable()
class EmotionDistribution {
  final String? key;
  final String? name;
  final int? count;

  EmotionDistribution({this.key, this.name, this.count});

  factory EmotionDistribution.fromJson(Map<String, dynamic> json) =>
      _$EmotionDistributionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionDistributionToJson(this);
}

@JsonSerializable()
class Activity {
  final String? name;
  final String? frequency;
  final bool? isCustom;
  final int? completedDays;
  final int? targetCount;

  Activity({
    this.name,
    this.frequency,
    this.isCustom,
    this.completedDays,
    this.targetCount,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
