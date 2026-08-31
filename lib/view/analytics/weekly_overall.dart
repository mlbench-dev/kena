import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/analytics/overall_weekly_model.dart';
import 'package:kena_emotional_journey/model/community/community_members_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/activities/widgets/thought_monitoring_widget.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/deviation_chart.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/progress_card.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:kena_emotional_journey/view/community/widgets/user_profile_shimmer.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WeeklyOverall extends StatefulWidget {
  const WeeklyOverall({super.key});

  @override
  State<WeeklyOverall> createState() => _WeeklyOverallState();
}

class _WeeklyOverallState extends State<WeeklyOverall> {
  final _service = UserHomeService();
  OverallWeeklyModel? _weeklyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await _service.getOverallWeekly(context);
    if (mounted) {
      setState(() {
        _weeklyData = result;
        _isLoading = false;
      });
    }
  }

  Data? get _data =>
      (_weeklyData?.data?.isNotEmpty == true) ? _weeklyData!.data!.first : null;

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
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dailyValues.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ChartDataModel(
        label: index < dayLabels.length ? dayLabels[index] : (item.day ?? ''),
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
        maxDays: (a.targetCount ?? 7).toDouble(),
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

  Future<void> _onShareWithCircleTap() async {
    await MyDialogBox.show(
      context,
      child: ShareWeeklyDialog(parentContext: context),
    );
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
          // PredictionInsightsCard(summary: predictionSummary),
          // SizedBox(height: 16.h),
          AllTimeProgressCard(
            currentProgress: planUsefulPercent.toDouble(),
            goalValue: 100,
            lable: 'How often the plan was useful',
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
          if (thoughtCategories.isNotEmpty) SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colors.textSecondary.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Circle",
                  style: context.typography.body.copyWith(
                    fontFamily: "Inter",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "No of times shared their data",
                  style: context.typography.body.copyWith(
                    fontFamily: "Inter",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: 10.h),
                MyButton(
                  label: "Share with Circle",
                  backgroundColor: context.colors.background,
                  textColor: context.colors.primary,
                  borderColor: context.colors.primary,
                  onPressed: _onShareWithCircleTap,
                ),
              ],
            ),
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

// =========================================================
// SHARE WEEKLY DIALOG
// =========================================================

class ShareWeeklyDialog extends StatefulWidget {
  const ShareWeeklyDialog({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  State<ShareWeeklyDialog> createState() => _ShareWeeklyDialogState();
}

class _ShareWeeklyDialogState extends State<ShareWeeklyDialog> {
  final UserHomeService _service = UserHomeService();
  final ValueNotifier<List<bool>> _selectedMembers = ValueNotifier([]);

  bool _isLoading = true;
  bool _isSending = false;
  CommunityMembers? _membersModel;

  List<MemberData> get _members => _membersModel?.data ?? [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _selectedMembers.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final result = await _service.getForecastCommunityMembers(
      context: widget.parentContext,
    );
    if (!mounted) return;

    final members = result?.data ?? [];

    setState(() {
      _membersModel = result;
      _isLoading = false;
    });

    _selectedMembers.value = List.filled(members.length, false);
  }

  Future<void> _shareWeekly() async {
    final selected = _selectedMembers.value;
    final selectedIds = [
      for (var i = 0; i < _members.length; i++)
        if (selected[i] && (_members[i].id?.isNotEmpty ?? false))
          _members[i].id!,
    ];

    if (selectedIds.isEmpty) {
      if (widget.parentContext.mounted) {
        widget.parentContext.flushBarErrorMessage(
          message: 'Please select at least one member',
        );
      }
      return;
    }

    setState(() => _isSending = true);

    final today = DateTime.now().toIso8601String().split('T')[0];
    final success = await _service.shareWeeklyForecast(
      memberIds: selectedIds,
      endDate: today,
      message: 'Here is my forecast for this week!',
      context: widget.parentContext,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.pop(context);
      if (widget.parentContext.mounted) {
        widget.parentContext.flushBarSuccessMessage(
          message: 'Weekly forecast shared successfully!',
        );
      }
    }
  }

  void _toggleMember(int index, [bool? explicitValue]) {
    final updated = List<bool>.from(_selectedMembers.value);
    updated[index] = explicitValue ?? !updated[index];
    _selectedMembers.value = updated;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: 10.h),
            _buildDescription(),
            SizedBox(height: 10.h),
            _buildMembersSection(),
            const Spacer(),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.cancel, color: context.colors.error),
        ),
        SizedBox(width: 37.w),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Share Weekly Forecast',
            style: context.typography.title.copyWith(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontFamily: 'sfpro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildDescription() {
    return Center(
      child: Text(
        'Share your weekly forecast with your circle members.',
        textAlign: TextAlign.center,
        style: context.typography.body.copyWith(
          color: context.colors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    if (_isLoading) {
      return const Center(child: UserProfileShimmerLoading());
    }

    if (_members.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: context.colors.textPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 22.sp,
                  color: context.colors.textPrimary.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No members found',
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Members you add will show up here once they join.',
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary.withValues(alpha: 0.55),
                  fontSize: 10.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<List<bool>>(
      valueListenable: _selectedMembers,
      builder: (context, values, _) {
        return SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _members.length,
            separatorBuilder: (_, a) => SizedBox(width: 12.w),
            itemBuilder: (context, index) =>
                _buildMemberItem(index, values[index]),
          ),
        );
      },
    );
  }

  Widget _buildMemberItem(int index, bool isSelected) {
    final member = _members[index];
    final name = (member.aliasName?.isNotEmpty ?? false)
        ? member.aliasName!
        : member.username ?? 'Unknown';

    return GestureDetector(
      onTap: () => _toggleMember(index),
      child: SizedBox(
        width: 90.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                MemberAvatar(avatarUrl: member.avatarUrl),
                Positioned(
                  top: -2,
                  right: -2,
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: Checkbox(
                      value: isSelected,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) => _toggleMember(index, val ?? false),
                      fillColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? context.colors.primary
                            : Colors.white,
                      ),
                      checkColor: Colors.white,
                      side: WidgetStateBorderSide.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? BorderSide(
                                color: context.colors.primary,
                                width: 1.5,
                              )
                            : const BorderSide(
                                color: Colors.black54,
                                width: 1.5,
                              ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return MyButton(
      label: 'Share Weekly',
      isLoading: _isSending,
      fontWeight: FontWeight.w400,
      onPressed: _isSending ? null : _shareWeekly,
    );
  }
}

// =========================================================
// MEMBER AVATAR
// =========================================================

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 30.r,
      backgroundColor: const Color(0xFFE0E7FF),
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: const Color(0xFF475569),
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
        child: hasAvatar
            ? null
            : Icon(Icons.person, size: 20.sp, color: Colors.white),
      ),
    );
  }
}
