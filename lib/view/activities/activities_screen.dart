import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/activites/activity_frequency_model.dart';
import 'package:kena_emotional_journey/model/activites/planned_activity_model.dart'
    as planned;
import 'package:kena_emotional_journey/model/activites/today_activity_model.dart'
    as today;
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/user/activity_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

enum ActivityTab { today, planned }

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  ActivityTab _activeTab = ActivityTab.today;
  final UserHomeService _service = UserHomeService();
  bool isActivitiesEditMode = false;
  bool _isLoading = true;

  // Real API data
  List<today.Activity> _todayActivities = [];
  List<planned.Activity> _plannedActivities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final todayResult = await _service.getTodayActivities(context: context);

    // Add this check right here!
    if (!mounted) return;

    final plannedResult = await _service.getPlannedActivities(context: context);

    if (!mounted) return;
    setState(() {
      _todayActivities = todayResult?.data?.firstOrNull?.activities ?? [];
      _plannedActivities = plannedResult?.data?.firstOrNull?.activities ?? [];
      _isLoading = false;
    });
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
        ],
      ),
      appBar: AppBar(
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          "Activities",
          style: context.typography.body.copyWith(
            fontSize: 20.sp,
            fontFamily: 'sfpro',
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
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
      body: Column(
        children: [
          // 🚀 FIX: Passed current state and wired up state refresh callback
          _activityTabBar(context, _activeTab, (tab) {
            setState(() {
              _activeTab = tab;
            });
          }),

          // 🚀 FIX: Combined viewport scroll management using an Expanded wrapper
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Row containing the section Title text and action toggle button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _activeTab == ActivityTab.today
                            ? "Today's Activities"
                            : "Planned Activities",
                        style: context.typography.headline.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isActivitiesEditMode = !isActivitiesEditMode;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: isActivitiesEditMode
                              ? Text(
                                  'Done',
                                  key: const ValueKey('act_done_txt'),
                                  style: context.typography.body.copyWith(
                                    fontFamily: 'sfpro',
                                    color: context.colors.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('act_pen_icon'),
                                  child:
                                      (_activeTab == ActivityTab.today &&
                                              _todayActivities.isEmpty) ||
                                          (_activeTab == ActivityTab.planned &&
                                              _plannedActivities
                                                  .isEmpty) // Assuming your list variable is named _plannedActivities
                                      ? const SizedBox.shrink()
                                      : Assets.icons.penOutline.svg(),
                                ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      if (!isActivitiesEditMode)
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              RoutesName.chooseActivity,
                              arguments: {
                                'isToday': _activeTab == ActivityTab.today
                                    ? true
                                    : false,
                                'isFromForecast': false,
                              },
                            );
                            if (!context.mounted) return;
                            await _load();
                          },
                          child: Icon(Icons.add, color: context.colors.primary),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // 2. 🚀 THE MAIN SINGLE CONTAINER: Wraps the entire activities listing view block
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isActivitiesEditMode
                            ? context.colors.primary.withValues(
                                alpha: 0.8,
                              ) // Green border frame when active
                            : context.colors.textSecondary.withValues(
                                alpha: 0.2,
                              ),
                        width: 1.5,
                      ),
                    ),
                    child: _isLoading
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 30.h),
                            child: Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: context.colors.primary,
                                size: 50,
                              ),
                            ),
                          )
                        : _activeTab == ActivityTab.planned
                        ? _plannedActivities.isEmpty
                              ? _buildEmptyState('No planned activities')
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _plannedActivities.length,
                                  separatorBuilder: (_, index) =>
                                      SizedBox(height: 10.h),
                                  itemBuilder: (context, index) {
                                    final item = _plannedActivities[index];
                                    return PlannedActivityCard(
                                      parentContext: this.context,
                                      activityId: item.id ?? '',
                                      activityName: item.name ?? '',
                                      schedule: item.schedule,
                                      frequencyLabel:
                                          item.uiBadge ??
                                          item.schedule?.frequency ??
                                          '',
                                      isEditable: isActivitiesEditMode,
                                      onDeleted: () {
                                        // Remove item from UI after API confirms
                                        setState(() {
                                          _plannedActivities.removeAt(index);
                                        });
                                      },
                                      onEdited: (newName) {
                                        setState(() {
                                          _plannedActivities[index] =
                                              planned.Activity(
                                                id: item.id,
                                                name: newName,
                                                schedule: item.schedule,
                                                isCustom: item.isCustom,
                                                uiLabel: item.uiLabel,
                                                uiBadge: item.uiBadge,
                                              );
                                        });
                                      },
                                      onRefresh: _load,
                                    );
                                  },
                                )
                        : _todayActivities.isEmpty
                        ? _buildEmptyState('No activities for today')
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _todayActivities.length,
                            separatorBuilder: (_, index) =>
                                SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              final item = _todayActivities[index];
                              return TodayActivityCard(
                                parentContext: this.context,
                                activityId: item.id ?? '',
                                activityName: item.name ?? '',
                                isChecked: item.completed ?? false,
                                isEditable: isActivitiesEditMode,
                                onDeleted: () {
                                  // Optimistic: remove instantly from UI
                                  setState(() {
                                    _todayActivities.removeAt(index);
                                  });
                                },
                                onEdited: (newName) {
                                  setState(() {
                                    _todayActivities[index] = today.Activity(
                                      id: item.id,
                                      name: newName,
                                      completed: item.completed,
                                      isCustom: item.isCustom,
                                    );
                                  });
                                },
                                onCheckChanged: (newValue) async {
                                  final previousValue = item.completed ?? false;
                                  // Optimistic UI Update
                                  setState(() {
                                    _todayActivities[index] = today.Activity(
                                      id: item.id,
                                      name: item.name,
                                      completed: newValue,
                                      isCustom: item.isCustom,
                                    );
                                  });

                                  final success = await UserHomeService()
                                      .updateTodayActivity(
                                        context: context,
                                        id: item.id ?? '',
                                        name: item.name ?? '',
                                        completed: newValue,
                                        isCustom: item.isCustom ?? false,
                                      );

                                  if (!success) {
                                    // Revert if API failed
                                    if (mounted) {
                                      setState(() {
                                        _todayActivities[index] =
                                            today.Activity(
                                              id: item.id,
                                              name: item.name,
                                              completed: previousValue,
                                              isCustom: item.isCustom,
                                            );
                                      });
                                    }
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: Text(
          message,
          style: context.typography.body.copyWith(
            fontFamily: 'sfpro',
            fontSize: 14.sp,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class PlannedActivityCard extends StatelessWidget {
  final BuildContext parentContext;
  final String activityId;
  final String activityName;
  final planned.Schedule? schedule;
  final String frequencyLabel;
  final bool isEditable;
  final VoidCallback onDeleted;
  final ValueChanged<String> onEdited;
  final VoidCallback? onRefresh;

  const PlannedActivityCard({
    super.key,
    required this.parentContext,
    required this.activityId,
    required this.activityName,
    this.schedule,
    this.frequencyLabel = '',
    this.isEditable = false,
    required this.onDeleted,
    required this.onEdited,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              activityName,
              style: context.typography.body.copyWith(
                color: context.colors.primary,
                fontFamily: 'sfpro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (frequencyLabel.isNotEmpty) ...[
            SizedBox(width: 8.w),
            FrequencyChip(label: frequencyLabel, isActive: true),
          ],
          if (isEditable) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () => MyDialogBox.show(
                context,
                child: DeleteActivityDialogBox(
                  parentContext: parentContext,
                  activityName: activityName,
                  onDeleted: onDeleted,
                  isPlanned: true,
                ),
              ),
              child: Assets.icons.bin.svg(width: 22.w, height: 22.h),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => MyDialogBox.show(
                context,
                child: EditActivityDialogBox(
                  parentContext: parentContext,
                  activityId: activityId,
                  activityName: activityName,
                  isPlanned: true,
                  schedule: schedule,
                  onEdited: onEdited,
                  onRefresh: onRefresh,
                ),
              ),
              child: Assets.icons.pen.svg(width: 22.w, height: 22.h),
            ),
          ],
        ],
      ),
    );
  }
}

class TodayActivityCard extends StatelessWidget {
  final BuildContext parentContext;
  final String activityId;
  final String activityName;
  final bool isEditable;
  final bool isChecked;
  final VoidCallback onDeleted;
  final ValueChanged<String> onEdited;
  final ValueChanged<bool> onCheckChanged;

  const TodayActivityCard({
    super.key,
    required this.parentContext,
    required this.activityId,
    required this.activityName,
    this.isEditable = false,
    this.isChecked = false,
    required this.onDeleted,
    required this.onEdited,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isChecked
              ? context.colors.primary
              : context.colors.textSecondary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              activityName,
              style: context.typography.body.copyWith(
                color: context.colors.primary,
                fontFamily: 'sfpro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          if (!isEditable) ...[
            // Once an activity is marked done it can't be undone, so this
            // renders as a static badge rather than a tappable checkbox.
            isChecked
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFCAEAC7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 16.sp,
                          color: context.colors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Done',
                          style: TextStyle(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : ActivityCheckbox(
                    isChecked: isChecked,
                    onTap: () => onCheckChanged(!isChecked),
                  ),
          ],
          if (isEditable) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () => MyDialogBox.show(
                context,
                child: DeleteActivityDialogBox(
                  parentContext: parentContext,
                  activityName: activityName,
                  onDeleted: onDeleted,
                  isPlanned: false,
                ),
              ),
              child: Assets.icons.bin.svg(width: 22.w, height: 22.h),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => MyDialogBox.show(
                context,
                child: EditActivityDialogBox(
                  parentContext: parentContext,
                  activityId: activityId,
                  activityName: activityName,
                  isPlanned: false,
                  onEdited: onEdited,
                ),
              ),
              child: Assets.icons.pen.svg(width: 22.w, height: 22.h),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── DIALOG BOXES ───
class DeleteActivityDialogBox extends StatelessWidget {
  final BuildContext parentContext;
  final String activityName;
  final VoidCallback onDeleted;
  final bool isPlanned;

  const DeleteActivityDialogBox({
    super.key,
    required this.parentContext,
    required this.activityName,
    required this.onDeleted,
    this.isPlanned = false,
  });

  void _confirmDelete(BuildContext context) {
    // Close dialog, call API, then update UI on success
    Navigator.pop(context);
    Future.microtask(() async {
      if (!parentContext.mounted) return;

      bool success;
      if (isPlanned) {
        success = await UserHomeService().deletePlannedActivity(
          name: activityName,
          context: parentContext,
        );
      } else {
        success = await UserHomeService().deleteTodayActivity(
          name: activityName,
          context: parentContext,
        );
      }

      if (!parentContext.mounted) return;

      if (success) {
        onDeleted();
      } else {
        parentContext.flushBarErrorMessage(
          message: 'Failed to delete activity',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 175.h,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'Are you sure you want to delete this activity?',
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontFamily: 'sfpro',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Center(
                        child: Text(
                          "Delete",
                          style: context.typography.title.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: context.colors.background,
                            fontFamily: "sfpro",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Center(
                        child: Text(
                          "No",
                          style: context.typography.title.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                            fontFamily: "sfpro",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditActivityDialogBox extends StatefulWidget {
  final BuildContext parentContext;
  final String activityId;
  final String activityName;
  final bool isPlanned;
  final planned.Schedule? schedule;
  final ValueChanged<String> onEdited;
  final VoidCallback? onRefresh;

  const EditActivityDialogBox({
    super.key,
    required this.parentContext,
    required this.activityId,
    required this.activityName,
    this.isPlanned = false,
    this.schedule,
    required this.onEdited,
    this.onRefresh,
  });

  @override
  State<EditActivityDialogBox> createState() => _EditActivityDialogBoxState();
}

class _EditActivityDialogBoxState extends State<EditActivityDialogBox> {
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activityName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSaving = true);

    final service = ActivityService();
    bool success;

    if (widget.isPlanned) {
      success = await service.editPlannedActivity(
        context: widget.parentContext,
        id: widget.activityId,
        newName: newName,
        frequency: widget.schedule?.frequency,
        weeklyDays: widget.schedule?.weeklyDays?.cast<int>(),
        monthlyDays: widget.schedule?.monthlyDays?.cast<int>(),
        monthlyWeekDay: widget.schedule?.monthlyWeekDay,
        monthlyWeekNumber: widget.schedule?.monthlyWeekNumber,
      );
    } else {
      success = await service.editSelectionActivity(
        context: widget.parentContext,
        id: widget.activityId,
        newName: newName,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      widget.onEdited(newName);
      if (widget.parentContext.mounted) {
        widget.parentContext.flushBarSuccessMessage(
          message: 'Activity updated successfully',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.isPlanned ? 350.h : 270.h,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Edit Activity',
                style: context.typography.title.copyWith(
                  color: context.colors.textPrimary,
                  fontFamily: 'sfpro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'Name:',
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontFamily: 'sfpro',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            MyTextField(
              controller: _nameController,
              hint: 'Activity name',
              borderColor: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
            if (widget.isPlanned) ...[
              SizedBox(height: 20.h),
              MyButton(
                borderColor: context.colors.primary,
                backgroundColor: context.colors.background,
                textColor: context.colors.primary,
                icon: Assets.icons.pen.svg(height: 32.h, width: 32.w),
                label: 'Change Frequency',
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(
                    widget.parentContext,
                    RoutesName.frequencyScreen,
                    arguments: {
                      'activityId': widget.activityId,
                      'activities': [
                        ActivityFrequency(
                          name: _nameController.text.trim(),
                          isCustom: false,
                          frequencyType: widget.schedule?.frequency ?? 'daily',
                          selectedDays:
                              widget.schedule?.weeklyDays?.cast<int>() ?? [],
                          monthlyDays:
                              widget.schedule?.monthlyDays?.cast<int>() ?? [],
                          monthlyWeekDay: widget.schedule?.monthlyWeekDay,
                        ),
                      ],
                    },
                  );
                  if (result == true) {
                    widget.onRefresh?.call();
                  }
                },
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: context.typography.title.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                            fontFamily: "sfpro",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: MyButton(
                    label: _isSaving ? 'Saving...' : 'Save',
                    onPressed: _isSaving ? null : _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FrequencyChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const FrequencyChip({super.key, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEEB),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Text(
        label,
        style: context.typography.body.copyWith(
          fontSize: 10.sp,
          fontFamily: 'sfpro',
          fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
          color: context.colors.primary,
        ),
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
          // Solid dark green when checked, transparent inside when unchecked
          color: isChecked ? context.colors.primary : Colors.transparent,
          border: Border.all(
            // Blue highlight border when checked, soft grey ring when unchecked
            color: isChecked
                ? context.colors.primary
                : context.colors.textSecondary.withValues(alpha: 0.3),
            width: isChecked ? 2.w : 1.5.w,
          ),
        ),
        child: isChecked
            ? Icon(
                Icons.check,
                size: 14.sp,
                color: Colors.white, // White check mark inside green circle
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// 🚀 FIX: Complete TabBar rework to prevent crashes and implement indicator lines
Widget _activityTabBar(
  BuildContext context,
  ActivityTab activeTab,
  ValueChanged<ActivityTab> onTabChanged,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(ActivityTab.today),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Today',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == ActivityTab.today
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == ActivityTab.today
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(ActivityTab.planned),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Planned',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == ActivityTab.planned
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == ActivityTab.planned
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Full-width matching dynamic indicator bars underneath
      Row(
        children: [
          Expanded(
            child: Container(
              height: 2.h,
              color: activeTab == ActivityTab.today
                  ? context.colors.primary
                  : context.colors.textSecondary.withValues(alpha: 0.1),
            ),
          ),
          Expanded(
            child: Container(
              height: 2.h,
              color: activeTab == ActivityTab.planned
                  ? context.colors.primary
                  : context.colors.textSecondary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    ],
  );
}
