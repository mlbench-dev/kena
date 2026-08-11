import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/expandable_text.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_history_model.dart'
    as history;
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    as forecast;
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/services/user/forecast_service.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SelectTodayForecast extends StatefulWidget {
  final DateTime date;
  const SelectTodayForecast({super.key, required this.date});

  @override
  State<SelectTodayForecast> createState() => _SelectTodayForecastState();
}

class _SelectTodayForecastState extends State<SelectTodayForecast> {
  bool _showImage = true;
  bool _isLoading = true;
  bool isPlanExpanded = false;
  bool isChecked = false;
  late DateTime _selectedDate;
  history.ForecastHistoryData? _forecastData;
  final List<history.ForecastHistoryData> _allForecasts = [];
  final UserHomeService _service = UserHomeService();

  history.ForecastHistoryForecast? get _forecast => _forecastData?.forecast;
  List<history.Emotion> get _emotions => _forecast?.emotions ?? [];

  bool _isSaving = false;

  Future<void> _onSavePressed() async {
    if (_isSaving) return;
    if (_forecastData == null) {
      context.flushBarErrorMessage(message: "No forecast data to save");
      return;
    }

    setState(() => _isSaving = true);

    final emotionsPayload = _emotions
        .map(
          (e) => {
            'key': e.key ?? '',
            'intensity': e.intensity ?? 0,
            'imageUrl': e.imageUrl ?? '',
          },
        )
        .toList();

    final activitiesPayload = (_forecastData?.activities ?? [])
        .map((a) => {'name': a.name ?? '', 'completed': a.completed ?? false})
        .toList();

    final todayStr = DateTime.now().toIso8601String().split('T').first;

    final success = await ForecastService().saveCopiedForecast(
      context: context,
      day: todayStr,
      emotions: emotionsPayload,
      plan: _forecast?.plan ?? '',
      notes: _forecast?.notes ?? '',
      activities: activitiesPayload,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.flushBarSuccessMessage(message: "Forecast saved successfully!");
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RoutesName.homeScreen, (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _loadForecastByDate(_selectedDate);
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  history.ForecastHistoryData? _findForecastForDate(DateTime date) {
    if (_allForecasts.isEmpty) return null;
    for (var fd in _allForecasts) {
      final raw = fd.day ?? fd.date;
      if (raw == null) continue;
      final fdDate = DateTime.tryParse(raw);
      if (fdDate == null) continue;
      if (fdDate.year == date.year &&
          fdDate.month == date.month &&
          fdDate.day == date.day) {
        return fd;
      }
    }
    return null;
  }

  Future<void> _loadForecastByDate(DateTime date) async {
    setState(() => _isLoading = true);

    final formattedDate = _formatDate(date);

    final result = await _service.getYestardayForecasts(
      date: formattedDate,
      context: context,
    );

    if (!mounted) return;

    final list = result?.data ?? [];

    setState(() {
      for (final item in list) {
        final key = item.day ?? item.date;
        _allForecasts.removeWhere((e) => (e.day ?? e.date) == key);
      }
      _allForecasts.addAll(list);

      _forecastData = list.isNotEmpty ? list.first : _findForecastForDate(date);
      _selectedDate = date;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activities = _forecastData?.activities ?? [];
    final actions = context.watch<NavigationActionsController>();
    return MyScaffold(
      endDrawer: MyDrawer(
        items: [
          DrawerMenuItem(
            icon: Assets.icons.homeOutline.svg(),
            label: 'Home',
            isDisabled: actions.isAnyLoading,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.homeScreen);
            },
          ),
          DrawerMenuItem(
            icon: Assets.icons.aspire.svg(),
            label: 'Aspire',
            isLoading: actions.aspireLoading,
            isDisabled: actions.isAnyLoading && !actions.aspireLoading,
            isAsync: true,
            onTap: () => actions.onAspireTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.dailyPuls.svg(),
            label: 'Daily Pulse',
            isLoading: actions.forecastLoading,
            isDisabled: actions.isAnyLoading && !actions.forecastLoading,
            isAsync: true,
            onTap: () => actions.onForecastTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.activity.svg(),
            label: 'Activities',
            isDisabled: actions.isAnyLoading,
            onTap: () => actions.onActivitiesTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.circle.svg(),
            label: 'Circle',
            isDisabled: actions.isAnyLoading,
            onTap: () => actions.onCommunityTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.bellIcon.svg(),
            label: 'Notifications',
            isDisabled: actions.isAnyLoading,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.notificationScreen);
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          "Select as Today's Forecast",
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            fontFamily: 'sfpro',
          ),
        ),
        leading: BackButton(color: context.colors.textPrimary),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Builder(
              builder: (scaffoldContext) => GestureDetector(
                onTap: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.menu,
                    color: context.colors.textPrimary,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: context.colors.primary,
                size: 45,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForecastSection(),
                    SizedBox(height: 15.h),
                    _infoCard(
                      context,
                      showEdit: false,
                      onEdit: null,
                      title: "Your Plan",
                      subtitle: ExpandableText(
                        text: _forecast?.plan?.isNotEmpty == true
                            ? _forecast!.plan!
                            : "No Plan recorded",
                        expanded: isPlanExpanded,
                        onToggle: () {
                          setState(() {
                            isPlanExpanded = !isPlanExpanded;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Activities',
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "sfpro",
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.textSecondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: activities.isEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                "No activities recorded",
                                style: context.typography.body.copyWith(
                                  color: context.colors.textSecondary,
                                  fontSize: 13.sp,
                                  fontFamily: 'sfpro',
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                for (int i = 0; i < activities.length; i++) ...[
                                  _buildActivitiesSection(
                                    context,
                                    activities[i].completed ?? false,
                                    activities[i].name ?? '',
                                    onChanged: null,
                                  ),
                                  if (i != activities.length - 1)
                                    SizedBox(height: 10.h),
                                ],
                              ],
                            ),
                    ),
                    SizedBox(height: 20.h),
                    MyButton(
                      label: _isSaving ? 'Saving...' : 'Save',
                      onPressed: _isSaving ? null : _onSavePressed,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildForecastSection() {
    final emotionsToShow = _emotions.take(3).toList();

    return EmotionsSectionCard(
      title: 'Forecast',
      isEditMode: false,
      onToggleEdit: null,
      tiles: emotionsToShow.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: forecast.Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
            title: emotion.title,
          ),
          showImage: _showImage,
          onEditImageTap: null,
        );
      }).toList(),
    );
  }
}

Widget _infoCard(
  BuildContext context, {
  required String title,
  required Widget subtitle,
  required bool showEdit,
  VoidCallback? onEdit,
}) {
  return Container(
    padding: EdgeInsets.all(10.w),
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: context.colors.textSecondary.withValues(alpha: 0.2),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
              if (title.isNotEmpty) SizedBox(height: 10.h),
              subtitle,
            ],
          ),
        ),
        if (showEdit)
          GestureDetector(onTap: onEdit, child: Assets.icons.pen2.svg()),
      ],
    ),
  );
}

Widget _buildActivitiesSection(
  BuildContext context,
  bool isChecked,
  String title, {
  ValueChanged<bool?>? onChanged,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Checkbox(
        value: isChecked,
        onChanged: onChanged,
        checkColor: context.colors.background,
        activeColor: context.colors.primary,
        side: BorderSide(color: context.colors.primary),
        shape: const CircleBorder(),
        // --- ADD THESE TWO LINES TO REDUCE HEIGHT ---
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      ),
      SizedBox(width: 5.w),
      Text(
        title,
        style: context.typography.body.copyWith(
          color: context.colors.primary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          fontFamily: 'sfpro',
        ),
      ),
    ],
  );
}
