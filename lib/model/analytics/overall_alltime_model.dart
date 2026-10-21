import 'package:json_annotation/json_annotation.dart';
import 'package:kena_emotional_journey/model/thought_monitoring/thought_monitoring_chart_model.dart';

part 'overall_alltime_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OverallAlltimeModel {
  bool? success;
  String? message;
  List<Data>? data;

  OverallAlltimeModel({this.success, this.message, this.data});

  factory OverallAlltimeModel.fromJson(Map<String, dynamic> json) =>
      _$OverallAlltimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$OverallAlltimeModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Data {
  Period? period;
  PredictionInsights? predictionInsights;
  PlanUseful? planUseful;
  WorseBetterVsGoal? worseBetterVsGoal;
  TopEmotions? topEmotions;
  CoreAndAspirational? coreAndAspirational;
  List<TopActivities>? topActivities;
  ThoughtMonitoring? thoughtMonitoring;
  ThoughtMonitoringChart? thoughtMonitoringChart;

  Data({
    this.period,
    this.predictionInsights,
    this.planUseful,
    this.worseBetterVsGoal,
    this.topEmotions,
    this.coreAndAspirational,
    this.topActivities,
    this.thoughtMonitoring,
    this.thoughtMonitoringChart,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Period {
  String? startDay;
  String? endDay;
  int? days;
  String? type;

  Period({this.startDay, this.endDay, this.days, this.type});

  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodToJson(this);
}

@JsonSerializable()
class PredictionInsights {
  int? accuracyPercent;
  int? matchedDays;
  int? daysForecasted;
  int? daysActualRecorded;

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

@JsonSerializable()
class PlanUseful {
  int? percent;

  PlanUseful({this.percent});

  factory PlanUseful.fromJson(Map<String, dynamic> json) =>
      _$PlanUsefulFromJson(json);

  Map<String, dynamic> toJson() => _$PlanUsefulToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WorseBetterVsGoal {
  List<DailyValues>? dailyValues;

  WorseBetterVsGoal({this.dailyValues});

  factory WorseBetterVsGoal.fromJson(Map<String, dynamic> json) =>
      _$WorseBetterVsGoalFromJson(json);

  Map<String, dynamic> toJson() => _$WorseBetterVsGoalToJson(this);
}

@JsonSerializable()
class DailyValues {
  String? day;
  int? value;

  DailyValues({this.day, this.value});

  factory DailyValues.fromJson(Map<String, dynamic> json) =>
      _$DailyValuesFromJson(json);

  Map<String, dynamic> toJson() => _$DailyValuesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TopEmotions {
  List<Forecast>? forecast;
  List<Actual>? actual;

  TopEmotions({this.forecast, this.actual});

  factory TopEmotions.fromJson(Map<String, dynamic> json) =>
      _$TopEmotionsFromJson(json);

  Map<String, dynamic> toJson() => _$TopEmotionsToJson(this);
}

@JsonSerializable()
class Forecast {
  String? key;
  String? name;
  String? imageUrl;
  int? count;
  num? intensity;
  String? intensityLabel;
  int? percentOfPeriodDays;
  int? percentOfDenomDays;
  String? emoji;

  Forecast({
    this.key,
    this.name,
    this.imageUrl,
    this.count,
    this.intensity,
    this.intensityLabel,
    this.percentOfPeriodDays,
    this.percentOfDenomDays,
    this.emoji,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable()
class Actual {
  String? key;
  String? name;
  String? imageUrl;
  int? count;
  num? intensity;
  String? intensityLabel;
  int? percentOfPeriodDays;
  int? percentOfDenomDays;

  Actual({
    this.key,
    this.name,
    this.imageUrl,
    this.count,
    this.intensity,
    this.intensityLabel,
    this.percentOfPeriodDays,
    this.percentOfDenomDays,
  });

  factory Actual.fromJson(Map<String, dynamic> json) => _$ActualFromJson(json);

  Map<String, dynamic> toJson() => _$ActualToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CoreAndAspirational {
  List<Core>? core;
  List<Aspirational>? aspirational;

  CoreAndAspirational({this.core, this.aspirational});

  factory CoreAndAspirational.fromJson(Map<String, dynamic> json) =>
      _$CoreAndAspirationalFromJson(json);

  Map<String, dynamic> toJson() => _$CoreAndAspirationalToJson(this);
}

@JsonSerializable()
class Core {
  String? key;
  String? name;
  int? forecast;
  int? actual;
  int? intensity;
  String? imageUrl;

  Core({
    this.key,
    this.name,
    this.forecast,
    this.actual,
    this.intensity,
    this.imageUrl,
  });

  factory Core.fromJson(Map<String, dynamic> json) => _$CoreFromJson(json);

  Map<String, dynamic> toJson() => _$CoreToJson(this);
}

@JsonSerializable()
class Aspirational {
  String? key;
  String? name;
  String? emoji;
  int? forecast;
  int? actual;
  int? intensity;
  String? imageUrl;

  Aspirational({
    this.key,
    this.name,
    this.emoji,
    this.forecast,
    this.actual,
    this.intensity,
    this.imageUrl,
  });

  factory Aspirational.fromJson(Map<String, dynamic> json) =>
      _$AspirationalFromJson(json);

  Map<String, dynamic> toJson() => _$AspirationalToJson(this);
}

@JsonSerializable()
class TopActivities {
  String? name;
  String? frequency;
  bool? isCustom;
  int? completedDays;
  int? targetCount;
  int? achievementPercent;

  TopActivities({
    this.name,
    this.frequency,
    this.isCustom,
    this.completedDays,
    this.targetCount,
    this.achievementPercent,
  });

  factory TopActivities.fromJson(Map<String, dynamic> json) =>
      _$TopActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$TopActivitiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ThoughtMonitoring {
  int? positive;
  int? neutral;
  int? negative;
  int? total;
  int? skipped;
  Raw? raw;

  ThoughtMonitoring({
    this.positive,
    this.neutral,
    this.negative,
    this.total,
    this.skipped,
    this.raw,
  });

  factory ThoughtMonitoring.fromJson(Map<String, dynamic> json) =>
      _$ThoughtMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$ThoughtMonitoringToJson(this);
}

@JsonSerializable()
class Raw {
  int? positive;
  int? neutral;
  int? negative;
  int? skipped;

  Raw({this.positive, this.neutral, this.negative, this.skipped});

  factory Raw.fromJson(Map<String, dynamic> json) => _$RawFromJson(json);

  Map<String, dynamic> toJson() => _$RawToJson(this);
}
