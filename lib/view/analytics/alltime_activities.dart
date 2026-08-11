import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/model/analytics/all_time_activities.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/bar_graph.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/build_chart_legend.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/progress_card.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AlltimeActivities extends StatefulWidget {
  const AlltimeActivities({super.key});

  @override
  State<AlltimeActivities> createState() => _AlltimeActivitiesState();
}

class _AlltimeActivitiesState extends State<AlltimeActivities> {
  final _service = UserHomeService();
  AllTimeActivities? _allTimeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllTimeData();
  }

  Future<void> _loadAllTimeData() async {
    final result = await _service.getAlltimeActivites(context);
    if (mounted) {
      setState(() {
        _allTimeData = result;
        _isLoading = false;
      });
    }
  }

  List<ChartDataModel> _getChartData() {
    if (_allTimeData?.data?.isEmpty ?? true) {
      return [];
    }
    final chartData = _allTimeData!.data!.first.chartData ?? [];
    return chartData.map((item) {
      return ChartDataModel(
        label: item.monthName?.substring(0, 1) ?? '',
        achievedValue: (item.achieved ?? 0).toDouble(),
        goalValue: (item.goal ?? 0).toDouble(),
      );
    }).toList();
  }

  List<ActivityDataModel> _getTopActivities() {
    if (_allTimeData?.data?.isEmpty ?? true) {
      return [];
    }
    final topActivities = _allTimeData!.data!.first.topActivities ?? [];
    if (topActivities.isEmpty) {
      return [];
    }
    return topActivities.map((item) {
      return ActivityDataModel(
        name: item.name ?? '',
        currentDays: (item.count ?? 0).toDouble(),
        maxDays: 365.0,
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

    final progress = _allTimeData?.data?.isNotEmpty == true
        ? _allTimeData!.data!.first.progress
        : null;
    final period = _allTimeData?.data?.isNotEmpty == true
        ? _allTimeData!.data!.first.period
        : null;
    final chartData = _getChartData();
    final activities = _getTopActivities();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (period != null) SizedBox(height: 20.h),
          AllTimeProgressCard(
            lable: 'All Time',
            currentProgress: (progress?.activitiesDone ?? 0).toDouble(),
            goalValue: (progress?.goal ?? 1000).toDouble(),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 280.h,
            decoration: const BoxDecoration(),
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
