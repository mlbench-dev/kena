import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/analytics/overall_monthly_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/activities/widgets/thought_monitoring_widget.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/deviation_chart.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/prediction_insights.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/progress_card.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MonthlyOverall extends StatefulWidget {
  const MonthlyOverall({super.key});

  @override
  State<MonthlyOverall> createState() => _MonthlyOverallState();
}

class _MonthlyOverallState extends State<MonthlyOverall> {
  final _service = UserHomeService();
  OverallMonthlyModel? _monthlyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await _service.getOverallMonthly(context);
    if (mounted) {
      setState(() {
        _monthlyData = result;
        _isLoading = false;
      });
    }
  }

  Data? get _data => (_monthlyData?.data?.isNotEmpty == true)
      ? _monthlyData!.data!.first
      : null;

  Map<String, dynamic> _getPredictionSummary() {
    final pi = _data?.predictionInsights;
    if (pi == null) return {};
    return {
      'predictionAccuracyPercent': pi.accuracyPercent ?? 0,
      'daysForecasted': pi.daysForecasted ?? 0,
      'daysReflected': pi.matchedDays ?? 0,
      'daysActualRecorded': pi.daysActualRecorded ?? 0,
    };
  }

  List<ChartDataModel> _getDeviationData() {
    final dailyValues = _data?.worseBetterVsGoal?.dailyValues;
    if (dailyValues == null || dailyValues.isEmpty) return [];
    return dailyValues.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ChartDataModel(
        label: '${index + 1}',
        value: (item.value ?? 0).toDouble(),
      );
    }).toList();
  }

  List<Emotion> _getForecastEmotions() {
    final forecast = _data?.topEmotions?.forecast;
    if (forecast == null || forecast.isEmpty) return [];
    return forecast.take(3).map((f) {
      return Emotion(
        key: f.key,
        title: f.name,
        imageUrl: f.imageUrl,
        intensity: f.intensity,
      );
    }).toList();
  }

  List<Emotion> _getActualEmotions() {
    final actual = _data?.topEmotions?.actual;
    if (actual == null || actual.isEmpty) return [];
    return actual.take(3).map((a) {
      return Emotion(
        key: a.key,
        title: a.name,
        imageUrl: a.imageUrl,
        intensity: a.intensity,
      );
    }).toList();
  }

  List<Emotion> _getCoreEmotions() {
    final core = _data?.coreAndAspirational?.core;
    if (core == null || core.isEmpty) return [];
    return core.map((c) {
      return Emotion(
        key: c.key,
        title: c.name,
        imageUrl: c.imageUrl,
        intensity: c.intensity,
      );
    }).toList();
  }

  List<Emotion> _getAspirationalEmotions() {
    final aspirational = _data?.coreAndAspirational?.aspirational;
    if (aspirational == null || aspirational.isEmpty) return [];
    return aspirational.map((a) {
      return Emotion(
        key: a.key,
        title: a.name,
        imageUrl: a.imageUrl,
        intensity: a.intensity,
      );
    }).toList();
  }

  List<ActivityDataModel> _getTopActivities() {
    final activities = _data?.topActivities;
    if (activities == null || activities.isEmpty) return [];
    return activities.map((a) {
      return ActivityDataModel(
        name: a.name ?? '',
        currentDays: (a.completedDays ?? 0).toDouble(),
        maxDays: (a.targetCount ?? 30).toDouble(),
        barColor: const Color(0xFF21573b),
      );
    }).toList();
  }

  List<ThoughtCategory> _getThoughtCategories() {
    final tm = _data?.thoughtMonitoring;
    if (tm == null) return [];
    return [
      ThoughtCategory(
        label: "Positive",
        percentage: (tm.positive ?? 0).toDouble(),
        color: const Color(0xFF1E5631),
        icon: Assets.images.batteryCharge.image(),
      ),
      ThoughtCategory(
        label: "Negative",
        percentage: (tm.negative ?? 0).toDouble(),
        color: const Color(0xFFD90000),
        icon: Assets.images.batteryLow.image(),
      ),
      ThoughtCategory(
        label: "Neutral",
        percentage: (tm.neutral ?? 0).toDouble(),
        color: const Color(0xFFC8A200),
        icon: const Icon(Icons.remove, color: Color(0xFFC8A200), size: 28),
      ),
    ];
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

    final predictionSummary = _getPredictionSummary();
    final planUsefulPercent = _data?.planUseful?.percent ?? 0;
    final deviationData = _getDeviationData();
    final forecastEmotions = _getForecastEmotions();
    final actualEmotions = _getActualEmotions();
    final coreEmotions = _getCoreEmotions();
    final aspirationalEmotions = _getAspirationalEmotions();
    final topActivities = _getTopActivities();
    final thoughtCategories = _getThoughtCategories();
    final thoughtGoal = _data?.thoughtMonitoring?.total ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PredictionInsightsCard(summary: predictionSummary),
          SizedBox(height: 16.h),
          AllTimeProgressCard(
            currentProgress: planUsefulPercent.toDouble(),
            goalValue: 100,
            lable: 'Plan useful',
            hidebottomLabel: false,
          ),
          SizedBox(height: 16.h),
          if (deviationData.isNotEmpty)
            PerformanceDeviationChart(data: deviationData),
          if (deviationData.isNotEmpty) SizedBox(height: 16.h),
          Text(
            "Forecast vs Actual emotions",
            style: context.typography.body.copyWith(
              fontFamily: 'Inter',
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Forecast vs Actual comparison and how many days in the period.",
            style: context.typography.body.copyWith(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildEmotionsSection(
            context,
            title: 'Top 3 Forecast Emotions',
            emotions: forecastEmotions,
          ),
          SizedBox(height: 16.h),
          _buildEmotionsSection(
            context,
            title: 'Top 3 Actual Emotions',
            emotions: actualEmotions,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Assets.icons.graph.svg(),
              SizedBox(width: 5.w),
              Text(
                "Core & aspirational emotions",
                style: context.typography.body.copyWith(
                  fontFamily: 'Inter',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "See how your core & aspirational emotions reflect in your day-day pulse i.e. No of times Forecast vs Actual in period e.g. 1-5",
            style: context.typography.body.copyWith(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildEmotionsSection(
            context,
            title: 'Core Emotions',
            emotions: coreEmotions,
          ),
          SizedBox(height: 16.h),
          _buildEmotionsSection(
            context,
            title: 'Aspirational Emotions',
            emotions: aspirationalEmotions,
          ),
          SizedBox(height: 16.h),
          TopActivitiesFlSection(activities: topActivities),
          SizedBox(height: 16.h),
          if (thoughtCategories.isNotEmpty)
            ThoughtMonitoringWidget(
              categories: thoughtCategories,
              goal: thoughtGoal,
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionsSection(
    BuildContext context, {
    required String title,
    required List<Emotion> emotions,
  }) {
    final emotionsToShow = emotions.take(3).toList();

    return EmotionsSectionCard(
      title: title,
      isEditMode: false,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      tiles: emotionsToShow.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: emotion,
          showImage: true,
        );
      }).toList(),
    );
  }
}
