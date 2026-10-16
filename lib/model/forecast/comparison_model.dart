import 'package:json_annotation/json_annotation.dart';
import 'package:kena_emotional_journey/model/thought_monitoring/thought_monitoring_chart_model.dart';

part 'comparison_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ComparisonModel {
  final bool? success;
  final String? message;
  final List<ComparisonData>? data;

  ComparisonModel({this.success, this.message, this.data});

  factory ComparisonModel.fromJson(Map<String, dynamic> json) =>
      _$ComparisonModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ComparisonData {
  final String? day;
  final bool? isEndDay;
  final Forecast? forecast;
  final Reality? reality;
  final List<ActivityToday>? activitiesToday;

  /// Was List<Null> in the old model
  final List<dynamic>? activitiesCompleted;

  @JsonKey(
    fromJson: ThoughtMonitoring.fromJsonValue,
    toJson: ThoughtMonitoring.toJsonValue,
  )
  final ThoughtMonitoring? thoughtMonitoring;

  /// Percentages per time slot for the Thought Monitoring graph.
  final ThoughtMonitoringChart? thoughtMonitoringChart;

  ComparisonData({
    this.day,
    this.isEndDay,
    this.forecast,
    this.reality,
    this.activitiesToday,
    this.activitiesCompleted,
    this.thoughtMonitoring,
    this.thoughtMonitoringChart,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) =>
      _$ComparisonDataFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Forecast {
  final List<Emotion>? emotions;
  final String? plan;
  final String? notes;
  final String? createdAt;

  Forecast({this.emotions, this.plan, this.notes, this.createdAt});

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Reality {
  final List<Emotion>? emotions;
  final bool? wentAsForecast;
  final int? compareToForecast;
  final bool? planUseful;

  /// "full" or "quick".
  final String? checkInType;

  /// Answers keyed by question: wentWell, heavy, selfObservation, handover
  /// (full) or dayMetaphor (quick).
  final Map<String, dynamic>? checkInAnswers;
  final String? createdAt;

  Reality({
    this.emotions,
    this.wentAsForecast,
    this.compareToForecast,
    this.planUseful,
    this.checkInType,
    this.checkInAnswers,
    this.createdAt,
  });

  factory Reality.fromJson(Map<String, dynamic> json) =>
      _$RealityFromJson(json);

  Map<String, dynamic> toJson() => _$RealityToJson(this);
}

@JsonSerializable()
class Emotion {
  final String? key;
  final int? intensity;
  final String? imageUrl;

  Emotion({this.key, this.intensity, this.imageUrl});

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionToJson(this);

  Emotion copyWith({String? key, int? intensity, String? imageUrl}) {
    return Emotion(
      key: key ?? this.key,
      intensity: intensity ?? this.intensity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Thought counts for one point on the Thought Monitoring chart.
@JsonSerializable()
class ThoughtMonitoringPoint {
  final int? positive;
  final int? neutral;
  final int? negative;
  final int? skipped;

  ThoughtMonitoringPoint({
    this.positive,
    this.neutral,
    this.negative,
    this.skipped,
  });

  int get total =>
      (positive ?? 0) + (neutral ?? 0) + (negative ?? 0) + (skipped ?? 0);

  factory ThoughtMonitoringPoint.fromJson(Map<String, dynamic> json) =>
      _$ThoughtMonitoringPointFromJson(json);

  Map<String, dynamic> toJson() => _$ThoughtMonitoringPointToJson(this);
}

/// `thoughtMonitoring` from the API: either one counts object
/// (`{positive: 2, neutral: 12, ...}`) or a list of them, one per point.
class ThoughtMonitoring {
  final List<ThoughtMonitoringPoint> points;

  ThoughtMonitoring({this.points = const []});

  int get positive => points.fold(0, (sum, p) => sum + (p.positive ?? 0));
  int get neutral => points.fold(0, (sum, p) => sum + (p.neutral ?? 0));
  int get negative => points.fold(0, (sum, p) => sum + (p.negative ?? 0));
  int get skipped => points.fold(0, (sum, p) => sum + (p.skipped ?? 0));

  static ThoughtMonitoring? fromJsonValue(Object? json) {
    if (json is List) {
      return ThoughtMonitoring(
        points: json
            .whereType<Map<String, dynamic>>()
            .map(ThoughtMonitoringPoint.fromJson)
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      return ThoughtMonitoring(points: [ThoughtMonitoringPoint.fromJson(json)]);
    }
    return null;
  }

  static Object? toJsonValue(ThoughtMonitoring? value) =>
      value?.points.map((p) => p.toJson()).toList();
}

@JsonSerializable()
class ActivityToday {
  final String? name;
  final bool? isCustom;
  final bool? isCompleted;

  ActivityToday({this.name, this.isCustom, this.isCompleted});

  factory ActivityToday.fromJson(Map<String, dynamic> json) =>
      _$ActivityTodayFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityTodayToJson(this);
}
