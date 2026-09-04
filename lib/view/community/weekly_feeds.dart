import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/community/weekly_feed_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    hide Forecast;
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/weekly_overall.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/deviation_chart.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/prediction_insights.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/progress_card.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:kena_emotional_journey/view/community/empty_feed_screen.dart';
import 'package:kena_emotional_journey/view/community/widgets/weekly_feeds_shimmer.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';

class WeeklyFeeds extends StatefulWidget {
  const WeeklyFeeds({
    super.key,
    required this.scope,
    required this.communityId,
  });
  final String scope;
  final String communityId;

  @override
  State<WeeklyFeeds> createState() => _WeeklyFeedsState();
}

class _WeeklyFeedsState extends State<WeeklyFeeds> {
  final UserHomeService _service = UserHomeService();
  WeeklyFeedModel? _weeklyFeedData;
  bool _isLoading = true;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklyFeed();
  }

  @override
  void didUpdateWidget(WeeklyFeeds oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scope != widget.scope) {
      setState(() {
        _isLoading = true;
        _weeklyFeedData = null;
      });
      _loadWeeklyFeed();
    }
  }

  Future<void> _loadWeeklyFeed() async {
    final data = await _service.getWeeklyFeed(
      communityId: widget.communityId,
      scope: widget.scope,
      context: context,
    );

    if (mounted) {
      setState(() {
        _weeklyFeedData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _stopSharingWeekly() async {
    // Get list of shared members first
    final sharedResult = await _service.getSharedMembers(context: context);
    if (!mounted) return;

    final userIds =
        sharedResult?.data?.map((m) => m.id).whereType<String>().toList() ?? [];
    if (userIds.isEmpty) {
      context.flushBarErrorMessage(message: 'No shared members found');
      return;
    }

    setState(() => _isStopping = true);

    final today = DateTime.now().toIso8601String().split('T')[0];
    final success = await _service.stopSharingWeeklyForecast(
      userIds: userIds,
      endDate: today,
      context: context,
    );

    if (!mounted) return;
    setState(() => _isStopping = false);

    if (success) {
      context.flushBarSuccessMessage(
        message: 'Stopped sharing weekly forecast',
      );
      await _loadWeeklyFeed();
    }
  }

  bool get _isWeeklyShared =>
      _weeklyFeedData?.data?.firstOrNull?.isWeeklyShared == true;

  Future<void> _startSharingWeekly() async {
    await MyDialogBox.show(
      context,
      child: ShareWeeklyDialog(parentContext: context),
    );
    if (!mounted) return;
    await _loadWeeklyFeed();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const WeeklyFeedsShimmer();
    }

    if (widget.scope != 'me' && !_isWeeklyShared) {
      return EmptyFeedScreen(isStopSharing: false);
    }

    final feedPeriod = _weeklyFeedData?.data?.firstOrNull;

    if (feedPeriod == null || (feedPeriod.data?.isEmpty ?? true)) {
      return EmptyFeedScreen(isStopSharing: false);
    }

    final summary = feedPeriod.summary;
    final insights = feedPeriod.insights;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.scope == 'me')
              _isWeeklyShared
                  ? GestureDetector(
                      onTap: _isStopping ? null : _stopSharingWeekly,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isStopping)
                            SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: LoadingWidget(
                                color: context.colors.error,
                                size: 2,
                              ),
                            )
                          else
                            Assets.icons.notshare.svg(
                              height: 18.h,
                              width: 18.w,
                            ),
                          SizedBox(width: 8.w),
                          Text(
                            _isStopping ? "Stopping..." : "Stop Sharing",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                              fontFamily: "sfpro",
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 98.w,
                          height: 27.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: _startSharingWeekly,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Assets.icons.sharing.svg(
                                  height: 14.h,
                                  width: 14.w,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    "Start Sharing",
                                    overflow: TextOverflow.ellipsis,
                                    style: context.typography.body.copyWith(
                                      color: context.colors.background,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            if (widget.scope == 'me') SizedBox(height: 16.h),
            PredictionInsightsCard(
              summary: {
                'predictionAccuracyPercent':
                    summary?.predictionInsights?.accuracyPercent ?? 0,
                // 'daysForecasted':
                //     summary?.predictionInsights?.daysForecasted ?? 0,
                'daysReflected':
                    summary?.predictionInsights?.daysForecasted ?? 0,
                'daysActualRecorded':
                    summary?.predictionInsights?.daysActualRecorded ?? 0,
              },
            ),
            SizedBox(height: 16.h),
            AllTimeProgressCard(
              currentProgress: (insights?.planUseful?.percent ?? 0).toDouble(),
              goalValue: 100,
              lable: 'Plan useful',
              hidebottomLabel: false,
            ),
            SizedBox(height: 16.h),
            PerformanceDeviationChart(
              data: _buildDeviationChartData(
                insights?.worseBetterVsGoal?.dailyValues,
              ),
            ),
            SizedBox(height: 16.h),
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
              emotions: _buildEmotionsFromApi(
                summary?.forecastVsActual?.forecast,
              ),
            ),
            SizedBox(height: 16.h),
            _buildEmotionsSection(
              context,
              title: 'Top 3 Actual Emotions',
              emotions: _buildEmotionsFromApi(
                summary?.forecastVsActual?.actual,
              ),
            ),
            SizedBox(height: 16.h),
            TopActivitiesFlSection(
              activities: _buildActivitiesFromApi(summary?.topActivities),
            ),
            SizedBox(height: 16.h),
            const BannerAdWidget(),
          ],
        ),
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

  List<ChartDataModel> _buildDeviationChartData(
    List<DailyValues>? dailyValues,
  ) {
    if (dailyValues == null || dailyValues.isEmpty) {
      return [];
    }

    return dailyValues.map((dv) {
      return ChartDataModel(
        label: _getDayLabel(dv.day),
        value: (dv.value ?? 0).toDouble(),
      );
    }).toList();
  }

  String _getDayLabel(String? day) {
    if (day == null) return '';
    final date = DateTime.tryParse(day);
    if (date == null) return '';

    final dayOfWeek = date.weekday;
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[dayOfWeek - 1];
  }

  List<Emotion> _buildEmotionsFromApi(List<dynamic>? emotionsData) {
    if (emotionsData == null || emotionsData.isEmpty) {
      return [];
    }

    // Get image URLs from the feed data for emotions that have images
    final feedData = _weeklyFeedData?.data?.firstOrNull?.data ?? [];
    final emotionImageMap = <String, String>{};

    for (final feed in feedData) {
      final dominantEmotions = feed.dominantEmotions;
      if (dominantEmotions != null) {
        for (final emotion in dominantEmotions) {
          final key = emotion.key;
          final imageUrl = emotion.imageUrl;
          if (key != null && imageUrl != null && imageUrl.isNotEmpty) {
            emotionImageMap[key] = imageUrl;
          }
        }
      }
    }

    return emotionsData.take(3).map((e) {
      String? imageUrl;
      String? key;
      String? title;
      int? count;

      if (e is Map<String, dynamic>) {
        key = e['key'] as String?;
        title = e['title'] as String?;
        count = e['count'] as int?;
        imageUrl = e['imageUrl'] as String?;
      } else if (e is Forecast) {
        key = e.key;
        title = e.title;
        count = e.count;
        imageUrl = e.imageUrl;
      } else if (e is Actual) {
        key = e.key;
        title = e.title;
        count = e.count;
        imageUrl = e.imageUrl;
      } else if (e is TopEmotions) {
        key = e.key;
        title = e.title;
        count = e.count;
        imageUrl = e.imageUrl;
      }

      // Fall back to imageUrl derived from the day's dominant emotions
      // when the API didn't include one on the summary item itself.
      if ((imageUrl == null || imageUrl.isEmpty) && key != null) {
        imageUrl = emotionImageMap[key];
      }

      return Emotion(
        key: key,
        intensity: count ?? 0,
        title: title,
        imageUrl: imageUrl,
      );
    }).toList();
  }

  List<ActivityDataModel> _buildActivitiesFromApi(
    List<TopActivities>? activities,
  ) {
    if (activities == null || activities.isEmpty) {
      return [];
    }

    return activities.map((activity) {
      return ActivityDataModel(
        name: activity.name ?? '',
        currentDays: (activity.achievementPercent ?? 0).toDouble(),
        maxDays: 100,
        barColor:
            context.colors.secondary, // Use secondary color for the active bar
      );
    }).toList();
  }
}
