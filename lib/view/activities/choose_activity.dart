import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/ui_helper.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/tour_controller.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/activites/activity_frequency_model.dart';
import 'package:kena_emotional_journey/model/tour_section/tour_content.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/thought_monitoring_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/activities/widgets/add_activity_bottom_sheet.dart';
import 'package:kena_emotional_journey/view/activities/widgets/time_picker_input.dart';
import 'package:provider/provider.dart';

// Single activity model to keep selection state and metadata together
class ActivityItem {
  final String name;
  bool isSelected;
  final bool isCustom;

  ActivityItem({
    required this.name,
    this.isSelected = false,
    this.isCustom = false,
  });
}

class ChooseActivity extends StatefulWidget {
  const ChooseActivity({
    super.key,
    required this.isToday,
    required this.isFromForecast,
    this.navigateToSummaryAfterSave = false,
  });
  final bool isToday;
  final bool isFromForecast;
  final bool navigateToSummaryAfterSave;
  @override
  State<ChooseActivity> createState() => _ChooseActivityState();
}

class _ChooseActivityState extends State<ChooseActivity> {
  final TextEditingController _customActivityController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final GlobalKey _activityKey = GlobalKey();
  TourHandle? _tourHandle;

  String selectedPeriod = "AM";
  final UserHomeService _homeService = UserHomeService();
  final ThoughtMonitoringService _thoughtMonitoringService =
      ThoughtMonitoringService();
  // Single model for activities
  // ActivityItem holds name, selection state and whether it's a custom activity
  final List<ActivityItem> _activities = [];
  bool _isSaving = false;
  bool isChecked = false;
  String? _savedStartTime24;
  String? _savedEndTime24;

  @override
  void initState() {
    super.initState();
    _initActivities();
    _loadSavedActivities();
    _loadThoughtMonitoringSettings();
  }

  // ── Load current thought monitoring settings to prefill the checkbox ────
  Future<void> _loadThoughtMonitoringSettings() async {
    final settings = await _thoughtMonitoringService.getSettings(
      context: context,
    );
    if (!mounted || settings == null) return;
    setState(() {
      isChecked = settings.enabled ?? false;
      _savedStartTime24 = settings.startTime;
      _savedEndTime24 = settings.endTime;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.navigateToSummaryAfterSave) return;
      _tourHandle?.cancel();
      _tourHandle = TourController.start(
        context: context,
        sectionKey: TourSections.activities,
        targetKeys: [_activityKey],
        onComplete: () {
          // Optional: handle tour completion
        },
      );
    });
  }

  @override
  void dispose() {
    _tourHandle?.cancel();
    _customActivityController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // ── Initialize default activities ───────────────────────────────────────
  void _initActivities() {
    _activities.clear();
    _activities.addAll([
      ActivityItem(name: 'Gratitude'),
      ActivityItem(name: 'Kind Acts'),
      ActivityItem(name: 'Meditation'),
      ActivityItem(name: 'Reframing'),
      ActivityItem(name: 'Find Benefit'),
      ActivityItem(name: 'Listen actively'),
      ActivityItem(name: 'Physical Exercise'),
      ActivityItem(
        name: 'Practice being present',
      ), // ActivityItem(name: 'Acts of kindness'),
      // ActivityItem(name: 'Nature retreat'),
    ]);
  }

  // ── Load previously saved activities from session ─────────────────────────
  void _loadSavedActivities() {
    final savedActivities = SessionController().activities;

    for (final act in savedActivities) {
      final name = act['name'] as String?;
      final isCustom = act['isCustom'] as bool? ?? false;

      if (name == null) continue;

      final index = _activities.indexWhere((e) => e.name == name);
      if (index != -1) {
        _activities[index].isSelected = true;
      }
      // Do not add custom activities to the predefined list.
    }
  }

  // ── Toggle selection ──────────────────────────────────────────────────────

  void _toggle(ActivityItem item) {
    setState(() {
      item.isSelected = !item.isSelected;
    });
  }

  List<Map<String, dynamic>> _buildTodayPayload() {
    return _activities
        .where((e) => e.isSelected)
        .map<Map<String, dynamic>>(
          (e) => {"name": e.name, "isCustom": e.isCustom, "completed": false},
        )
        .toList();
  }

  // ── Save today activities via API ─────────────────────────────────────────

  Future<void> _saveTodayActivities() async {
    final payload = _buildTodayPayload();

    // Validate at least one activity is selected
    if (payload.isEmpty) {
      context.flushBarErrorMessage(
        message: "Please select at least one activity.",
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await _homeService.addTodayActivities(
      context: context,
      activities: payload,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Persist to local session so the UI reflects selection on next visit
      // await SessionController().saveActivities(payload);
      if (!mounted) return;

      Navigator.pop(context, true);
      context.flushBarSuccessMessage(message: "Activities saved successfully");
    }
  }

  // ── Save a single custom activity directly via API ──────────────────────

  Future<void> _saveCustomActivity(String name) async {
    // Build a single-item payload with isCustom always true
    final payload = [
      {"name": name, "isCustom": true, "completed": false},
    ];

    setState(() => _isSaving = true);

    final success = await _homeService.addTodayActivities(
      context: context,
      activities: payload,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Persist to local session
      // await SessionController().saveActivities(payload);
      if (!mounted) return;

      Navigator.pop(context, true);
      context.flushBarSuccessMessage(message: "Activities saved successfully");
    }
  }

  // ── Handle Save button tap ────────────────────────────────────────────────

  Future<void> _onSavePressed() async {
    if (widget.isToday) {
      _saveTodayActivities();
    } else {
      // Non-today path (planned mode) → navigate to frequency selection
      final selected = _activities
          .where((e) => e.isSelected)
          .map((e) => ActivityFrequency(name: e.name, isCustom: e.isCustom))
          .toList();

      if (selected.isEmpty) {
        context.flushBarErrorMessage(
          message: "Please select at least one activity.",
        );
        return;
      }

      final saved = await Navigator.pushNamed(
        context,
        RoutesName.frequencyScreen,
        arguments: {'activities': selected},
      );
      if (saved == true && mounted) {
        if (widget.navigateToSummaryAfterSave) {
          Navigator.pushReplacementNamed(context, RoutesName.emotionsSummary);
        } else {
          Navigator.pop(context, true);
          context.flushBarSuccessMessage(
            message: "Activities saved successfully",
          );
        }
      }
    }
  }

  // ── Show bottom sheet: add a custom activity ──────────────────────────────

  void _showAddActivitySheet() {
    _customActivityController.clear();

    MyBottomSheet.show(
      context,
      isDismissible: true,
      child: AddActivityBottomSheet(
        controller: _customActivityController,

        saveButtonText: widget.isFromForecast
            ? "Add & Next"
            : widget.isToday
            ? "Save"
            : "Next",

        onCancel: () {
          Navigator.pop(context);
        },

        onSave: (name) async {
          Navigator.pop(context);

          if (widget.isToday) {
            await _saveCustomActivity(name);
          } else if (widget.isFromForecast) {
            // Forecast logic
          } else {
            setState(() {
              _activities.add(
                ActivityItem(name: name, isSelected: true, isCustom: true),
              );
            });

            await _onSavePressed();
          }
        },
      ),
    );
  }
  // ── Build activity rows (paired into a 2-column grid) ─────────────────────

  List<Widget> _buildActivityRows() {
    final rows = <Widget>[];

    for (int i = 0; i < _activities.length; i += 2) {
      final left = _activities[i];
      final right = i + 1 < _activities.length ? _activities[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              child: SelectionBox(
                label: left.name,
                isSelected: left.isSelected,
                onTap: () => _toggle(left),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: right != null
                  ? SelectionBox(
                      label: right.name,
                      isSelected: right.isSelected,
                      onTap: () => _toggle(right),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );

      if (i + 2 < _activities.length) rows.add(SizedBox(height: 10.h));
    }

    return rows;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        systemOverlayStyle: UIHelper.statusBarDark,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        "Choose activities",
                        style: context.typography.title.copyWith(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // ── Subtitle ───────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        "Meaningful action can help us manage or navigate our emotions. Select or customize your activities here.",
                        textAlign: TextAlign.left,
                        style: context.typography.subtitle.copyWith(
                          fontSize: 14.sp,
                          color: context.colors.textSecondary.withValues(
                            alpha: 0.8,
                          ),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'sfpro',
                        ),
                      ),
                    ),

                    // SizedBox(height: 10.h),
                    Padding(
                      key: _activityKey,
                      padding: EdgeInsets.only(
                        left: 12.w,
                        right: 12.w,
                        bottom: 10.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                checkColor: context.colors.background,
                                // 1. Dynamically change fill color based on selection state
                                fillColor: WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return context
                                        .colors
                                        .primary; // Checked: Primary color
                                  }
                                  return context
                                      .colors
                                      .background; // Unchecked: White background
                                }),
                                // 2. Dynamically change or add a grey border when unchecked
                                side: WidgetStateBorderSide.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return BorderSide
                                        .none; // Checked: No border (fills the shape)
                                  }
                                  return BorderSide(
                                    color: context.colors.textSecondary
                                        .withValues(
                                          alpha: 0.8,
                                        ), // Unchecked: Grey border
                                    width: 2.0,
                                  );
                                }),
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                  if (value == true) {
                                    MyDialogBox.show(
                                      context,
                                      child: ThoughtMonitoringDialogBox(
                                        initialStartTime: _savedStartTime24,
                                        initialEndTime: _savedEndTime24,
                                      ),
                                    );
                                  } else {
                                    _thoughtMonitoringService.saveSettings(
                                      context: context,
                                      enabled: false,
                                    );
                                  }
                                },
                              ),
                              Text(
                                "Thought Monitoring",
                                style: context.typography.body.copyWith(
                                  fontSize: 12.sp,
                                  fontFamily: 'sfpro',
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(height: 25.h),

                          // ── Activity selection grid ────────────────────────
                          ..._buildActivityRows(),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    const Spacer(),

                    // ── Add custom activity button ─────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: MyButton(
                        icon: const Icon(Icons.add),
                        label: "Customise Activity",
                        onPressed: _showAddActivitySheet,
                        backgroundColor: Colors.transparent,
                        borderWidth: 1,
                        borderColor: context.colors.primary,
                        textColor: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // ── Save button ────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: MyButton(
                        label: widget.isToday ? "Save" : "Continue",
                        onPressed: _isSaving ? null : _onSavePressed,
                        isLoading: _isSaving,
                        textColor: _isSaving ? null : context.colors.background,
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ThoughtMonitoringDialogBox extends StatefulWidget {
  const ThoughtMonitoringDialogBox({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
  });

  /// Existing settings in 24-hour "HH:mm" format, used to prefill the dialog.
  final String? initialStartTime;
  final String? initialEndTime;

  @override
  State<ThoughtMonitoringDialogBox> createState() =>
      _ThoughtMonitoringDialogBoxState();
}

class _ThoughtMonitoringDialogBoxState
    extends State<ThoughtMonitoringDialogBox> {
  final ThoughtMonitoringService _service = ThoughtMonitoringService();

  // Held in 24-hour "HH:mm" format — exactly what the API expects.
  late String _startTime24 = widget.initialStartTime ?? '';
  late String _endTime24 = widget.initialEndTime ?? '';
  bool _isSaving = false;

  /// Converts a "h:mm AM/PM" string (from the time picker) to 24-hour "HH:mm".
  String _to24Hour(String time12h) {
    try {
      final dt = DateFormat('h:mm a').parseStrict(time12h.trim());
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  /// Converts a 24-hour "HH:mm" string to the picker's "h:mm" display text.
  String? _to12HourTime(String? time24h) {
    if (time24h == null || time24h.isEmpty) return null;
    try {
      return DateFormat(
        'h:mm',
      ).format(DateFormat('HH:mm').parseStrict(time24h));
    } catch (_) {
      return null;
    }
  }

  /// Converts a 24-hour "HH:mm" string to its "AM"/"PM" period.
  String _periodOf(String? time24h) {
    if (time24h == null || time24h.isEmpty) return 'AM';
    try {
      return DateFormat(
        'a',
      ).format(DateFormat('HH:mm').parseStrict(time24h)).toUpperCase();
    } catch (_) {
      return 'AM';
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    if (_startTime24.isEmpty || _endTime24.isEmpty) {
      context.flushBarErrorMessage(
        message: 'Please select both start and end time',
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await _service.saveSettings(
      context: context,
      enabled: true,
      startTime: _startTime24,
      endTime: _endTime24,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      if (context.mounted) {
        context.flushBarSuccessMessage(
          message: 'Thought monitoring hours saved',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Thought monitoring",
                  style: context.typography.body.copyWith(
                    color: context.colors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Active Hours:",
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'sfpro',
                ),
              ),
              SizedBox(height: 10.h),
              TimePickerInputField(
                initialTime: _to12HourTime(widget.initialStartTime),
                initialPeriod: _periodOf(widget.initialStartTime),
                onTimeChanged: (value) =>
                    setState(() => _startTime24 = _to24Hour(value)),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "to",
                  style: context.typography.body.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'sfpro',
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TimePickerInputField(
                initialTime: _to12HourTime(widget.initialEndTime),
                initialPeriod: _periodOf(widget.initialEndTime),
                onTimeChanged: (value) =>
                    setState(() => _endTime24 = _to24Hour(value)),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: context.colors.textSecondary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: context.typography.body.copyWith(
                              color: context.colors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'sfpro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: MyButton(
                      label: "Save",
                      onPressed: _isSaving ? null : _onSave,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SelectionBox Widget
//
// A tappable row with label + checkbox, used for each activity in the grid.
// ─────────────────────────────────────────────────────────────────────────────

class SelectionBox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionBox({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        height: 40.h,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : const Color(0xFFFAF5EB),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: context.typography.body.copyWith(
                  fontSize: Platform.isIOS ? 11.sp : 11.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : context.colors.textSecondary,
                ),
              ),
            ),
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                side: BorderSide(
                  color: isSelected
                      ? Colors.white
                      : context.colors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                activeColor: Colors.white,
                checkColor: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
