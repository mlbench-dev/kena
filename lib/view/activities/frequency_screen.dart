import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/ui_helper.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/activites/activity_frequency_model.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/user/activity_service.dart';
import 'package:kena_emotional_journey/view/activities/widgets/frequency_chip.dart';
import 'package:kena_emotional_journey/view/activities/widgets/month_calendar.dart';
import 'package:kena_emotional_journey/view/activities/widgets/occurrence_dropdown.dart';
import 'package:kena_emotional_journey/view/activities/widgets/radio_button.dart';
import 'package:kena_emotional_journey/view/activities/widgets/year_picker.dart';
import 'package:provider/provider.dart';

class FrequencyScreen extends StatefulWidget {
  const FrequencyScreen({super.key});

  @override
  State<FrequencyScreen> createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {
  List<ActivityFrequency> _activities = [];
  int _activeActivityIndex = 0;
  bool _isFirstLoad = true;
  bool _isSaving = false;
  String? _editActivityId;
  final ActivityService _activityService = ActivityService();

  final List<Map<String, dynamic>> _weekdays = [
    {'id': 1, 'label': 'M'},
    {'id': 2, 'label': 'T'},
    {'id': 3, 'label': 'W'},
    {'id': 4, 'label': 'T'},
    {'id': 5, 'label': 'F'},
    {'id': 6, 'label': 'S'},
    {'id': 7, 'label': 'S'},
  ];

  final List<String> _monthsList = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<String> _stringOptions = ["First", "Second", "Third", "Fourth"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _editActivityId = args?['activityId'] as String?;
      final passedList = args?['activities'];
      if (passedList != null &&
          passedList is List<ActivityFrequency> &&
          passedList.isNotEmpty) {
        _activities = passedList;
      } else {
        // Fallback placeholder activity
        _activities = [
          ActivityFrequency(name: "Acts of Kindness", isCustom: false),
        ];
      }
    }
  }

  void _changeMonth(int step) {
    setState(() {
      final active = _activities[_activeActivityIndex];
      active.currentViewMonth = DateTime(
        active.currentViewMonth.year,
        active.currentViewMonth.month + step,
        1,
      );
    });
  }

  Future<void> _save() async {
    for (final activity in _activities) {
      if (activity.frequencyType == 'weekly' && activity.selectedDays.isEmpty) {
        context.flushBarErrorMessage(
          message: 'Select at least one weekday for ${activity.name}.',
        );
        return;
      }
      if (activity.frequencyType == 'monthly' &&
          activity.monthOption == FrequencyOption.dateOfMonth &&
          activity.monthlyDays.isEmpty) {
        context.flushBarErrorMessage(
          message: 'Select at least one monthly date for ${activity.name}.',
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    bool success;
    if (_editActivityId != null && _editActivityId!.isNotEmpty) {
      // Editing existing planned activity — use PUT
      final activity = _activities.first;
      final json = activity.toRequestJson();
      success = await _activityService.editPlannedActivity(
        context: context,
        id: _editActivityId!,
        newName: json['name'] as String,
        frequency: json['frequency'] as String?,
        weeklyDays: (json['weeklyDays'] as List?)?.cast<int>(),
        monthlyDays: (json['monthlyDays'] as List?)?.cast<int>(),
        monthlyWeekDay: json['monthlyWeekDay'] as int?,
        monthlyWeekNumber: json['monthlyWeekNumber'] as int?,
      );
    } else {
      // Creating new planned activities — use POST
      success = await _activityService.addPlannedActivities(
        context: context,
        activities: _activities,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
    if (_activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeActivity = _activities[_activeActivityIndex];
    final String currentMonthName =
        _monthsList[activeActivity.currentViewMonth.month - 1];

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
        systemOverlayStyle: UIHelper.statusBarDark,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: context.colors.textPrimary,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Frequency",
                style: context.typography.body.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'sfpro',
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              // ── ACTIVITIES CONFIGURATION CARDS LIST ──
              Column(
                children: List.generate(_activities.length, (index) {
                  final activity = _activities[index];
                  final isActive = index == _activeActivityIndex;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeActivityIndex = index;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? context.colors.tertiary.withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isActive
                                ? context.colors.tertiary
                                : context.colors.textSecondary.withValues(
                                    alpha: 0.15,
                                  ),
                            width: isActive ? 1.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.name,
                                style: context.typography.body.copyWith(
                                  color: isActive
                                      ? context.colors.tertiary
                                      : context.colors.textPrimary,
                                  fontFamily: 'sfpro',
                                  fontSize: 15.sp,
                                  fontWeight: isActive
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            FrequencyChip(
                              label: "D",
                              isActive: activity.frequencyType == 'daily',
                              onTap: () {
                                setState(() {
                                  activity.frequencyType = 'daily';
                                  _activeActivityIndex = index;
                                });
                              },
                            ),
                            SizedBox(width: 6.w),
                            FrequencyChip(
                              label: "W",
                              isActive: activity.frequencyType == 'weekly',
                              onTap: () {
                                setState(() {
                                  activity.frequencyType = 'weekly';
                                  _activeActivityIndex = index;
                                });
                              },
                            ),
                            SizedBox(width: 6.w),
                            FrequencyChip(
                              label: "M",
                              isActive: activity.frequencyType == 'monthly',
                              onTap: () {
                                setState(() {
                                  activity.frequencyType = 'monthly';
                                  _activeActivityIndex = index;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 8.h),
              Text(
                "Tap an activity card to customize its daily/weekly/monthly frequency details below.",
                style: context.typography.body.copyWith(
                  fontSize: 12.sp,
                  color: context.colors.textSecondary,
                  fontFamily: 'sfpro',
                ),
              ),
              Divider(height: 30.h, thickness: 1.h),

              // ── DYNAMIC CONFIGURATION FOR ACTIVE ACTIVITY ──
              Text(
                "Configuring: ${activeActivity.name}",
                style: context.typography.body.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.tertiary,
                  fontFamily: 'sfpro',
                ),
              ),
              SizedBox(height: 16.h),

              if (activeActivity.frequencyType == 'weekly') ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Every:",
                      style: context.typography.body.copyWith(
                        fontSize: 18.sp,
                        fontFamily: 'sfpro',
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _weekdays.map((day) {
                          final int id = day['id'] as int;
                          final bool isSelected = activeActivity.selectedDays
                              .contains(id);

                          return InlineWeekdayChip(
                            label: day['label'] as String,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (activeActivity.selectedDays.contains(id)) {
                                  activeActivity.selectedDays.remove(id);
                                } else {
                                  activeActivity.selectedDays.add(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ] else if (activeActivity.frequencyType == 'monthly') ...[
                Row(
                  children: [
                    RadioSelector<FrequencyOption>(
                      label: "Date of Month",
                      value: FrequencyOption.dateOfMonth,
                      groupValue: activeActivity.monthOption,
                      onChanged: (value) {
                        setState(() => activeActivity.monthOption = value);
                      },
                    ),
                    SizedBox(width: 12.w),
                    RadioSelector<FrequencyOption>(
                      label: "Day of Week",
                      value: FrequencyOption.dayOfWeek,
                      groupValue: activeActivity.monthOption,
                      onChanged: (value) {
                        setState(() => activeActivity.monthOption = value);
                      },
                    ),
                  ],
                ),

                // ── DYNAMIC CONDITIONAL RENDERING FOR CALENDAR MATRIX ──
                activeActivity.monthOption == FrequencyOption.dateOfMonth
                    ? Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => _changeMonth(-1),
                                  icon: Icon(
                                    Icons.keyboard_double_arrow_left,
                                    color: context.colors.tertiary,
                                    size: 28.sp,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    YearPickerDropdown(
                                      currentMonthName: currentMonthName,
                                      currentViewMonth:
                                          activeActivity.currentViewMonth,
                                      onYearChanged: (selectedYear) {
                                        setState(() {
                                          activeActivity.currentViewMonth =
                                              DateTime(
                                                selectedYear,
                                                activeActivity
                                                    .currentViewMonth
                                                    .month,
                                                1,
                                              );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => _changeMonth(1),
                                  icon: Icon(
                                    Icons.keyboard_double_arrow_right,
                                    color: context.colors.tertiary,
                                    size: 28.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            MonthCalendar(
                              targetMonth: activeActivity.currentViewMonth,
                              selectedDays: activeActivity.monthlyDays,
                              onDayToggled: (day) {
                                setState(() {
                                  if (activeActivity.monthlyDays.contains(
                                    day,
                                  )) {
                                    activeActivity.monthlyDays.remove(day);
                                  } else {
                                    activeActivity.monthlyDays.add(day);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          Text(
                            'Occurrence:',
                            style: context.typography.body.copyWith(
                              color: context.colors.textPrimary,
                              fontFamily: 'sfpro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          KenaDropdown(
                            value: activeActivity.monthlyWeekOccurrence,
                            options: _stringOptions,
                            hintText: "Select Week Occurrence",
                            onChanged: (newValue) {
                              setState(() {
                                activeActivity.monthlyWeekOccurrence = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Every:",
                                style: context.typography.body.copyWith(
                                  fontSize: 18.sp,
                                  fontFamily: 'sfpro',
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: _weekdays.map((day) {
                                    final int id = day['id'] as int;
                                    final bool isSelected =
                                        activeActivity.monthlyWeekDay == id;

                                    return InlineWeekdayChip(
                                      label: day['label'] as String,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          activeActivity.monthlyWeekDay = id;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ] else ...[
                // Daily selection notice
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text(
                    "Activity will be scheduled daily.",
                    style: context.typography.body.copyWith(
                      color: context.colors.textSecondary,
                      fontSize: 14.sp,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ),
              ],

              SizedBox(height: 40.h),
              MyButton(
                label: "Save",
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InlineWeekdayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const InlineWeekdayChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFE9EEEB),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected ? context.colors.tertiary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: context.typography.body.copyWith(
            fontSize: 13.sp,
            fontFamily: 'sfpro',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: context.colors.tertiary,
          ),
        ),
      ),
    );
  }
}
