import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/tour_controller.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/analytics/forecast_plan_activities.dart';
import 'package:kena_emotional_journey/model/tour_section/tour_content.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/activities/widgets/add_activity_bottom_sheet.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

const List<String> searchActivities = [
  'Gratitude',
  'Kind Acts',
  'Meditation',
  'Reframing',
  'Find Benefit',
  'Listen actively',
  'Physical Exercise',
  'Practice being present',
];

class ActivityItem {
  final String id;
  final String title;
  final bool isCustom;
  bool isForecastActivity;
  bool isChecked;

  ActivityItem({
    required this.id,
    required this.title,
    this.isCustom = false,
    this.isForecastActivity = false,
    this.isChecked = false,
  });
}

class PlanAndActivities extends StatefulWidget {
  const PlanAndActivities({super.key});

  @override
  State<PlanAndActivities> createState() => _PlanAndActivitiesState();
}

class _PlanAndActivitiesState extends State<PlanAndActivities> {
  List<ActivityItem> _activities = [];
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey activitiesKey = GlobalKey();
  TourHandle? _tourHandle;

  final TextEditingController _customActivityController =
      TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  final UserHomeService _service = UserHomeService();

  @override
  void initState() {
    super.initState();
    _loadPlannedActivities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startActivityTour();
    });
  }

  void _startActivityTour() {
    if (!mounted) return;
    _tourHandle = TourController.start(
      context: context,
      sectionKey: TourSections.planAndActivities,
      targetKeys: [activitiesKey],
    );
  }

  @override
  void dispose() {
    _tourHandle?.cancel();
    _planController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlannedActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.getForecastPlanActivities();

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _activities = [];
        _errorMessage = 'Could not load forecast plan activities.';
        _isLoading = false;
      });
      return;
    }

    final days = result.data ?? const <ForecastPlanData>[];
    final forecastPlan = days
        .map((day) => day.forecastPlan)
        .where((plan) => plan != null && plan.trim().isNotEmpty)
        .cast<String>()
        .firstOrNull;
    final mergedActivities = <String, ActivityItem>{};

    for (final day in days) {
      for (final activity
          in day.plannedActivities ?? const <PlannedActivity>[]) {
        final title = activity.name?.trim();
        if (title == null || title.isEmpty) continue;

        mergedActivities.putIfAbsent(
          title.toLowerCase(),
          () => ActivityItem(
            id: activity.id ?? title,
            title: title,
            isCustom: activity.isCustom ?? false,
          ),
        );
      }

      for (final activity in day.forecastActivities ?? const <dynamic>[]) {
        final title = _activityValue(activity, 'name')?.trim();
        if (title == null || title.isEmpty) continue;

        final key = title.toLowerCase();
        final existing = mergedActivities[key];

        if (existing != null) {
          existing.isChecked = true;
          existing.isForecastActivity = true;
        } else {
          mergedActivities[key] = ActivityItem(
            id:
                _activityValue(activity, '_id') ??
                _activityValue(activity, 'id') ??
                title,
            title: title,
            isCustom: _boolActivityValue(activity, 'isCustom'),
            isForecastActivity: true,
            isChecked: true,
          );
        }
      }
    }

    setState(() {
      _planController.text = forecastPlan ?? '';
      _activities = mergedActivities.values.toList();
      _isLoading = false;
    });
  }

  Future<void> _saveForecastActivities() async {
    if (_isSaving) return;

    final selectedActivities = _activities
        .where((activity) => activity.isChecked)
        .toList();

    if (_planController.text.trim().isEmpty && selectedActivities.isEmpty) {
      if (mounted) {
        context.flushBarErrorMessage(
          message: "Please add a plan or select at least one activity.",
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final activitiesToAdd = selectedActivities
        .where((activity) => !activity.isForecastActivity)
        .map(_activityPayload)
        .toList();

    final addSuccess = activitiesToAdd.isEmpty
        ? true
        : await _service.addForecastPlanActivities(
            context: context,
            activities: activitiesToAdd,
          );

    if (!mounted) return;

    if (!addSuccess) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    for (final activity in selectedActivities) {
      activity.isForecastActivity = true;
    }

    final success = await _service.saveForecastPlanActivities(
      context: context,
      forecastPlan: _planController.text.trim(),
      activities: selectedActivities.map(_activityPayload).toList(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      context.flushBarSuccessMessage(message: "Plan saved successfully.");

      if (!mounted) return;

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.forecastResultScreen,
            (route) =>
                route.settings.name == RoutesName.homeScreen || route.isFirst,
          );
        }
      });
    }
  }

  Map<String, dynamic> _activityPayload(ActivityItem activity) {
    return {
      "name": activity.title,
      "isCustom": activity.isCustom,
      "completed": false,
    };
  }

  String? _activityValue(dynamic activity, String key) {
    if (activity is Map<String, dynamic>) {
      return activity[key]?.toString();
    }
    if (activity is Map) {
      return activity[key]?.toString();
    }
    return null;
  }

  bool _boolActivityValue(dynamic activity, String key) {
    final value = activity is Map ? activity[key] : null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
          DrawerMenuItem(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: 'Logout',
            isDisabled: actions.isAnyLoading,
            onTap: () => AuthService.logout(context),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Expected truth',
          style: context.typography.title.copyWith(
            fontSize: 20.sp,
            fontFamily: 'sfpro',
            fontWeight: FontWeight.w600,
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
      body: SingleChildScrollView(
        // FIXED: Prevents screen overflow if keyboard or many items show up
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Meeting X will be frustrating or annoying.',
                style: context.typography.body.copyWith(
                  fontSize: 14.sp,
                  fontFamily: 'sfpro',
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              MyTextField(
                fillColor: context.colors.textSecondary.withValues(alpha: 0.08),
                controller: _planController,
                hint: 'Write your plan thinking: Truth - Plan - Result',
                maxLines: 4,
              ),
              SizedBox(height: 20.h),

              if (_isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: context.colors.primary,
                      size: 45,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: context.typography.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                )
              else if (_activities.isNotEmpty)
                Container(
                  key: activitiesKey,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _activities.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          return activityTile(context, _activities[index]);
                        },
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: MyButton(
                          label: 'View More',
                          onPressed: _showAllActivitiesDialog,
                          textColor: context.colors.primary,
                          backgroundColor: context.colors.background,
                          borderColor: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      Text(
                        'No planned activities found.',
                        textAlign: TextAlign.center,
                        style: context.typography.body.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      MyButton(
                        label: 'View More',
                        onPressed: _showAllActivitiesDialog,
                        textColor: context.colors.primary,
                        backgroundColor: context.colors.background,
                        borderColor: context.colors.primary,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 40.h),
              MyButton(
                label: 'Save',
                onPressed: _saveForecastActivities,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddActivitySheet() {
    _customActivityController.clear();

    MyBottomSheet.show(
      context,
      isDismissible: true,
      child: AddActivityBottomSheet(
        controller: _customActivityController,

        saveButtonText: "Save",

        onCancel: () {
          Navigator.pop(context);
        },

        onSave: (name) async {
          Navigator.pop(context);
          setState(() {
            final existingIndex = _activities.indexWhere(
              (item) => item.title.toLowerCase() == name.toLowerCase(),
            );

            if (existingIndex != -1) {
              _activities[existingIndex].isChecked = true;
            } else {
              _activities.add(
                ActivityItem(
                  id: name.toLowerCase(),
                  title: name,
                  isCustom: true,
                  isChecked: true,
                ),
              );
            }
          });
        },
      ),
    );
  }

  void _showAllActivitiesDialog() {
    _searchController.clear();

    MyDialogBox.show(
      context,
      child: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final keyword = _searchController.text.trim().toLowerCase();
          final selectedActivities = _activities
              .where((activity) => activity.isChecked)
              .toList();
          final searchResults = keyword.isEmpty
              ? <String>[]
              : searchActivities
                    .where(
                      (activity) => activity.toLowerCase().contains(keyword),
                    )
                    .toList();

          return Container(
            padding: EdgeInsets.all(16.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 24.w),
                    Text(
                      "Your Aspire Activities:",
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Icon(
                          Icons.close,
                          color: context.colors.textPrimary,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                MyTextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setDialogState(() {});
                  },
                  hint: 'Search activities',
                  borderColor: context.colors.textSecondary.withValues(
                    alpha: 0.3,
                  ),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (keyword.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: 180.h),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: searchResults.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                            child: Text(
                              'No search results found.',
                              style: context.typography.body.copyWith(
                                color: context.colors.textSecondary,
                                fontSize: 14.sp,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            itemCount: searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1.h,
                              color: context.colors.textSecondary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final activityTitle = searchResults[index];

                              return ListTile(
                                dense: true,
                                title: Text(
                                  activityTitle,
                                  style: context.typography.body.copyWith(
                                    color: context.colors.textPrimary,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.add,
                                  color: context.colors.primary,
                                  size: 20.w,
                                ),
                                onTap: () {
                                  setState(() {
                                    final existingIndex = _activities
                                        .indexWhere(
                                          (item) =>
                                              item.title.toLowerCase() ==
                                              activityTitle.toLowerCase(),
                                        );

                                    if (existingIndex != -1) {
                                      _activities[existingIndex].isChecked =
                                          true;
                                    } else {
                                      _activities.add(
                                        ActivityItem(
                                          id: activityTitle.toLowerCase(),
                                          title: activityTitle,
                                          isCustom: false,
                                          isChecked: true,
                                        ),
                                      );
                                    }
                                  });
                                  _searchController.clear();
                                  setDialogState(() {});
                                },
                              );
                            },
                          ),
                  ),
                ],
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 360.h),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (selectedActivities.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: Text(
                                  'No activities selected yet.',
                                  textAlign: TextAlign.center,
                                  style: context.typography.body.copyWith(
                                    color: context.colors.textSecondary,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: selectedActivities.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                return ActivityTileInDialogBox(
                                  activity: selectedActivities[index],
                                );
                              },
                            ),
                          // SizedBox(height: 10.h),
                          // GestureDetector(
                          //   child: Icon(
                          //     Icons.add,
                          //     color: context.colors.primary,
                          //   ),
                          //   onTap: () {
                          //     // TODO: Implement functionality to add a Custom activity
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                MyButton(
                  borderColor: context.colors.primary,
                  textColor: context.colors.primary,
                  backgroundColor: context.colors.background,
                  label: 'Add Custom Activity',
                  onPressed: () {
                    // Navigator.pop(dialogContext);
                    _showAddActivitySheet();
                  },
                ),
                SizedBox(height: 10.h),
                MyButton(
                  label: 'Save',
                  onPressed: () {
                    setState(() {
                      _activities = _activities
                          .where((activity) => activity.isChecked)
                          .toList();
                    });
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // FIXED: Accepts the concrete ActivityItem object model
  Widget activityTile(BuildContext context, ActivityItem activity) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Centered layout looks cleaner horizontally
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      maxLines: 2, // Optional: Keeps text to a single line
                      overflow: TextOverflow
                          .ellipsis, // Optional: Adds '...' if text is too long
                      style: TextStyle(
                        color: const Color(0xFF1B4332), // Dark green text color
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _activities.removeWhere(
                          (item) => item.id == activity.id,
                        );
                      });
                    },
                    child: Assets.icons.bin.svg(height: 26.h, width: 26.w),
                  ),
                  SizedBox(width: 10.w),
                  ActivityCheckbox(
                    isChecked: activity.isChecked,
                    onTap: () {
                      setState(() {
                        activity.isChecked = !activity
                            .isChecked; // FIXED: Toggles individual element property
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivityTileInDialogBox extends StatelessWidget {
  final ActivityItem activity;

  const ActivityTileInDialogBox({super.key, required this.activity});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              activity.title,
              maxLines: 2, // Optional: Keeps text to a single line
              overflow: TextOverflow
                  .ellipsis, // Optional: Adds '...' if text is too long
              style: TextStyle(
                color: const Color(0xFF1B4332), // Dark green text color
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Color(0xFFFFF5D6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                'Aspire',
                style: context.typography.body.copyWith(
                  color: Color(0xFFDBA800),
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const ActivityCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked ? context.colors.tertiary : Colors.transparent,
          border: Border.all(
            color: isChecked
                ? context.colors.tertiary
                : context.colors.textSecondary.withValues(alpha: 0.3),
            width: isChecked ? 2.w : 1.5.w,
          ),
        ),
        child: isChecked
            ? Icon(Icons.check, size: 14.sp, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
