import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/model/analytics/monthly_activities_model.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/bar_graph.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/build_chart_legend.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/progress_card.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MonthlyActivities extends StatefulWidget {
  const MonthlyActivities({super.key});

  @override
  State<MonthlyActivities> createState() => _MonthlyActivitiesState();
}

final List<ChartDataModel> monthlyProgress = [
  ChartDataModel(label: "1", achievedValue: 0.9, goalValue: 2.9),
  ChartDataModel(label: "2", achievedValue: 4.5, goalValue: 5.0),
  ChartDataModel(label: "3", achievedValue: 2.7, goalValue: 4.8),
  ChartDataModel(label: "4", achievedValue: 4.5, goalValue: 5.0),
  ChartDataModel(label: "5", achievedValue: 1.0, goalValue: 5.0),
  ChartDataModel(label: "6", achievedValue: 1.0, goalValue: 5.0),
  ChartDataModel(
    label: "7",
    achievedValue: 4.3,
    goalValue: 5.0,
  ), // Will be highlighted pink
  ChartDataModel(label: "8", achievedValue: 1.6, goalValue: 4.0),
  ChartDataModel(label: "9", achievedValue: 4.3, goalValue: 5.0),
  ChartDataModel(label: "10", achievedValue: 2.1, goalValue: 5.0),
  ChartDataModel(label: "11", achievedValue: 2.1, goalValue: 5.0),
  ChartDataModel(label: "12", achievedValue: 3.3, goalValue: 5.0),
  ChartDataModel(label: "13", achievedValue: 3.2, goalValue: 4.5),
  ChartDataModel(
    label: "14",
    achievedValue: 3.3,
    goalValue: 5.0,
  ), // Will be highlighted pink
  ChartDataModel(label: "15", achievedValue: 4.2, goalValue: 5.0),
  ChartDataModel(label: "16", achievedValue: 4.2, goalValue: 5.0),
  ChartDataModel(label: "17", achievedValue: 1.6, goalValue: 2.7),
  ChartDataModel(label: "18", achievedValue: 4.2, goalValue: 5.0),
  ChartDataModel(label: "19", achievedValue: 4.2, goalValue: 5.0),
  ChartDataModel(label: "20", achievedValue: 0.6, goalValue: 5.0),
  ChartDataModel(
    label: "21",
    achievedValue: 0.6,
    goalValue: 5.0,
  ), // Will be highlighted pink
  ChartDataModel(label: "22", achievedValue: 2.7, goalValue: 4.3),
  ChartDataModel(label: "23", achievedValue: 0.6, goalValue: 5.0),
  ChartDataModel(label: "24", achievedValue: 0.9, goalValue: 3.9),
  ChartDataModel(label: "25", achievedValue: 0.6, goalValue: 5.0),
  ChartDataModel(label: "26", achievedValue: 1.6, goalValue: 5.0),
  ChartDataModel(label: "27", achievedValue: 1.6, goalValue: 5.0),
  ChartDataModel(
    label: "28",
    achievedValue: 3.2,
    goalValue: 4.2,
  ), // Will be highlighted pink
  ChartDataModel(label: "29", achievedValue: 1.6, goalValue: 5.0),
  ChartDataModel(label: "30", achievedValue: 1.6, goalValue: 5.0),
];

// final List<ActivityDataModel> dummyActivities = [
//   ActivityDataModel(name: "Acts of kindness", currentDays: 25.0, maxDays: 30.0),
//   ActivityDataModel(name: "Meditation", currentDays: 22.0, maxDays: 30.0),
//   ActivityDataModel(
//     name: "Physical exercise",
//     currentDays: 18.0,
//     maxDays: 30.0,
//   ),
//   ActivityDataModel(name: "Journaling", currentDays: 15.0, maxDays: 30.0),
//   ActivityDataModel(
//     name: "Time with friends",
//     currentDays: 12.0,
//     maxDays: 30.0,
//   ),
// ];

class _MonthlyActivitiesState extends State<MonthlyActivities> {
  final _service = UserHomeService();
  MonthlyActivitiesModel? _monthlyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    final result = await _service.getMonthlyActivites(context);
    if (mounted) {
      setState(() {
        _monthlyData = result;
        _isLoading = false;
      });
    }
  }

  List<ChartDataModel> _getChartData() {
    if (_monthlyData?.data?.isEmpty ?? true) {
      return monthlyProgress;
    }
    final chartData = _monthlyData!.data!.first.chartData ?? [];
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      // Use index if within bounds, otherwise use modulo to cycle through monthlyProgress
      final safeIndex = index < monthlyProgress.length
          ? index
          : index % monthlyProgress.length;
      return ChartDataModel(
        label: monthlyProgress[safeIndex].label,
        achievedValue: (item.achieved ?? 0).toDouble(),
        goalValue: (item.goal ?? 0).toDouble(),
      );
    }).toList();
  }

  List<ActivityDataModel> _getTopActivities() {
    if (_monthlyData?.data?.isEmpty ?? true) {
      return [];
    }
    final topActivities = _monthlyData!.data!.first.topActivities ?? [];
    if (topActivities.isEmpty) {
      return [];
    }
    return topActivities.map((item) {
      return ActivityDataModel(
        name: item.name ?? '',
        currentDays: (item.count ?? 0).toDouble(),
        maxDays: 30.0,
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

    final progress = _monthlyData?.data?.first.progress;
    final chartData = _getChartData();
    final activities = _getTopActivities();

    return SingleChildScrollView(
      child: Column(
        children: [
          AllTimeProgressCard(
            lable: 'Monthly',
            currentProgress: (progress?.activitiesDone ?? 0).toDouble(),
            goalValue: (progress?.goal ?? 1000).toDouble(),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 280.h, // Matched height for UI uniformity
            width: double.infinity,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(12.r),
              // border: Border.all(
              //   color: context.colors.textSecondary.withValues(alpha: 0.1),
              // ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BuildChartLegend(), // Injecting the top right indicators
                SizedBox(height: 16.h),
                Expanded(
                  // 💡 LOGIC FIX: Prevents text clashing on 30 items
                  child: CustomBarChart(
                    dataList: chartData,
                    highlightedLabels: const ["7", "14", "21", "28"],
                  ),
                ),
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
