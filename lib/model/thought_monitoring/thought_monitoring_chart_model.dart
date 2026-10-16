import 'package:json_annotation/json_annotation.dart';

part 'thought_monitoring_chart_model.g.dart';

/// `thoughtMonitoringChart` from the API: one entry per label (e.g. "1pm" or
/// "Jul"), with each category as a 0–100 percentage.
@JsonSerializable()
class ThoughtMonitoringChart {
  final List<String>? labels;
  final List<double>? positive;
  final List<double>? negative;
  final List<double>? neutral;
  final List<double>? skipped;

  ThoughtMonitoringChart({
    this.labels,
    this.positive,
    this.negative,
    this.neutral,
    this.skipped,
  });

  factory ThoughtMonitoringChart.fromJson(Map<String, dynamic> json) =>
      _$ThoughtMonitoringChartFromJson(json);

  Map<String, dynamic> toJson() => _$ThoughtMonitoringChartToJson(this);
}
