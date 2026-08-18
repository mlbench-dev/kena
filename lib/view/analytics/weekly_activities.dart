import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/model/analytics/weekly_activities_model.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/bar_graph.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/build_chart_legend.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/progress_card.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WeeklyActivities extends StatefulWidget {
  const WeeklyActivities({super.key});

  @override
  State<WeeklyActivities> createState() => _WeeklyActivitiesState();
}

final List<ChartDataModel> weeklyProgress = [
  ChartDataModel(label: "M", achievedValue: 2.2, goalValue: 4.0),
  ChartDataModel(label: "T", achievedValue: 1.5, goalValue: 3.0),
  ChartDataModel(label: "W", achievedValue: 0.8, goalValue: 5.0),
  ChartDataModel(label: "T", achievedValue: 2.6, goalValue: 4.3),
  ChartDataModel(label: "F", achievedValue: 4.5, goalValue: 5.0),
  ChartDataModel(label: "S", achievedValue: 1.0, goalValue: 2.4),
  ChartDataModel(label: "S", achievedValue: 4.0, goalValue: 4.0),
];

final List<ActivityDataModel> dummyActivities = [
  ActivityDataModel(
    name: "Acts of kindness",
    currentDays: 6.8, // Nearly full bar
    maxDays: 7.0,
  ),
  ActivityDataModel(name: "Meditation", currentDays: 6.0, maxDays: 7.0),
  ActivityDataModel(name: "Physical exercise", currentDays: 5.2, maxDays: 7.0),
  ActivityDataModel(name: "Journaling", currentDays: 4.8, maxDays: 7.0),
  ActivityDataModel(
    name: "Time with friends",
    currentDays: 4.2, // Lowest bar in the top 5
    maxDays: 7.0,
  ),
];

class _WeeklyActivitiesState extends State<WeeklyActivities> {
  final _service = UserHomeService();
  WeeklyActivitiesModel? _weeklyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final result = await _service.getWeeklyActivites(context);
    if (mounted) {
      setState(() {
        _weeklyData = result;
        _isLoading = false;
      });
    }
  }

  List<ChartDataModel> _getChartData() {
    if (_weeklyData?.data?.isEmpty ?? true) {
      return weeklyProgress;
    }
    final chartData = _weeklyData!.data!.first.chartData ?? [];
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ChartDataModel(
        label: weeklyProgress[index].label,
        achievedValue: (item.achieved ?? 0).toDouble(),
        goalValue: (item.goal ?? 0).toDouble(),
      );
    }).toList();
  }

  List<ActivityDataModel> _getTopActivities() {
    if (_weeklyData?.data?.isEmpty ?? true) {
      return [];
    }
    final topActivities = _weeklyData!.data!.first.topActivities ?? [];
    if (topActivities.isEmpty) {
      return [];
    }
    return topActivities.map((item) {
      return ActivityDataModel(
        name: item.name ?? '',
        currentDays: (item.count ?? 0).toDouble(),
        maxDays: 7.0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 250.h),
          Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: context.colors.primary,
              size: 45,
            ),
          ),
        ],
      );
    }

    final progress = _weeklyData?.data?.first.progress;
    final chartData = _getChartData();
    final activities = _getTopActivities();

    return SingleChildScrollView(
      child: Column(
        children: [
          AllTimeProgressCard(
            lable: 'Weekly Progress',
            currentProgress: (progress?.activitiesDone ?? 0).toDouble(),
            goalValue: (progress?.goal ?? 1000).toDouble(),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 280.h,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(12.r),
              // border: Border.all(
              //   color: context.colors.textSecondary.withValues(alpha: 0.1),
              // ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.w),
            child: Column(
              children: [
                BuildChartLegend(),
                SizedBox(height: 16.h),
                Expanded(child: CustomBarChart(dataList: chartData)),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          TopActivitiesFlSection(activities: activities),
        ],
      ),
    );
  }
}
