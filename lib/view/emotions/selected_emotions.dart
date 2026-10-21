import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/delete_confirmation_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
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
import 'package:kena_emotional_journey/model/emotions/result_emotion_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    as fm;
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/activity_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/emotions/widgets/activities_card.dart';
import 'package:kena_emotional_journey/view/emotions/widgets/emotion_type_sheet.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:kena_emotional_journey/view/profile/widgets/date_time_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SelectedEmotionsScreen extends StatefulWidget {
  const SelectedEmotionsScreen({super.key});

  @override
  State<SelectedEmotionsScreen> createState() => _SelectedEmotionsScreenState();
}

class _SelectedEmotionsScreenState extends State<SelectedEmotionsScreen> {
  final UserHomeService _service = UserHomeService();
  final UserHomeService _userHomeService = UserHomeService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final TextEditingController _notesController = TextEditingController();
  DateTime? reassessDate;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  Future<List<dynamic>>? _notesFuture;
  int? _loadingCoreIndex;
  int? _loadingAspirationIndex;
  bool _isSavingReviewDate = false;
  List<CoreEmotion> _coreEmotions = [];
  List<AspirationEmotion> _aspirationEmotions = [];
  List<Activity> _activities = [];

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _currentEmotionDay =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool get _isToday {
    final now = DateTime.now();

    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  bool get _isAnyEmotionTileLoading =>
      _loadingCoreIndex != null || _loadingAspirationIndex != null;

  @override
  void initState() {
    super.initState();
    _load(_selectedDate);
    _notesFuture = _service.getAspireNotes(
      context: context,
      day: _selectedDate,
    );
    AdMobService.loadInterstitialAd();
    // Delay to allow ad to load before showing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AdMobService.showInterstitialAd();
      }
    });
  }

  Future<void> _load(DateTime date) async {
    final result = await _service.getJournalSelection(
      context: context,
      day: date,
    );
    if (!mounted) return;

    final data = result?.data?.firstOrNull;
    setState(() {
      _coreEmotions = List<CoreEmotion>.from(data?.coreEmotions ?? []);
      _aspirationEmotions = List<AspirationEmotion>.from(
        data?.aspirationEmotions ?? [],
      );
      _activities = List<Activity>.from(data?.activities ?? []);
      reassessDate = DateTime.tryParse(data?.aspirationReassessDate ?? '');
      _isLoading = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  bool isCoreEditMode = false;
  bool isAspirationEditMode = false;
  bool isActivityEditMode = false;
  bool _isSavingForecastNote = false;
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            SizedBox(height: 15.h),
            _dateNavigator(context),
            SizedBox(height: 12.h),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: context.colors.primary,
                        size: 45,
                      ),
                    )
                  : _buildScrollableContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_coreEmotions.isEmpty && _aspirationEmotions.isEmpty)
                    _buildNoEmotionsPlaceholder(showAddButton: _isToday)
                  else ...[
                    _coreEmotionBox(context),
                    SizedBox(height: 12.h),
                    _aspirationEmotionBox(context),
                  ],
                  SizedBox(height: 10.h),
                  ActivitiesCard(
                    onAdd: () async {
                      final saved = await Navigator.pushNamed(
                        context,
                        RoutesName.chooseActivity,
                        arguments: {'isToday': false, 'isFromForecast': false},
                      );
                      if (saved != null) {
                        _load(_selectedDate);
                      }
                    },
                    onEditTap: null,
                    title: 'Activities',
                    isEditMode: _isToday ? isActivityEditMode : false,
                    onToggleEdit: _isToday
                        ? (value) {
                            setState(() {
                              isActivityEditMode = value;
                            });
                          }
                        : null,
                    child: _activities.isEmpty
                        ? Text(
                            'No activities recorded',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: context.colors.textSecondary,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _activities
                                .map(
                                  (activity) => _buildActivityItem(
                                    context,
                                    activity,
                                    _isToday ? isActivityEditMode : false,
                                    _selectedDate,
                                    () => _load(_selectedDate),
                                    () {
                                      final firstActivity = activity;
                                      MyDialogBox.show(
                                        context,
                                        child: EditActivityDialogBox(
                                          parentContext: context,
                                          activityId: firstActivity.id ?? '',
                                          activityName:
                                              firstActivity.name ?? '',
                                          schedule:
                                              firstActivity.schedule != null
                                              ? planned.Schedule(
                                                  frequency: firstActivity
                                                      .schedule!
                                                      .frequency,
                                                  weeklyDays: firstActivity
                                                      .schedule!
                                                      .weeklyDays,
                                                  monthlyDays: firstActivity
                                                      .schedule!
                                                      .monthlyDays,
                                                  monthlyWeekDay: firstActivity
                                                      .schedule!
                                                      .monthlyWeekDay,
                                                  monthlyWeekNumber:
                                                      firstActivity
                                                          .schedule!
                                                          .monthlyWeekNumber,
                                                )
                                              : null,
                                          onEdited: (String newName) {
                                            _load(_selectedDate);
                                          },
                                          onRefresh: () {
                                            _load(_selectedDate);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  if (_isToday) ...[
                    SizedBox(height: 10.h),
                    MyTextField(
                      controller: _notesController,
                      borderColor: context.colors.textSecondary.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: 10,
                      hint: 'Write notes here...',
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: GestureDetector(
                          onTap: _isSavingForecastNote
                              ? null
                              : () async {
                                  final text = _notesController.text.trim();
                                  if (text.isEmpty) return;

                                  setState(() {
                                    _isSavingForecastNote = true;
                                  });

                                  try {
                                    await _userHomeService.addAspireNote(
                                      day: DateTime.now(),
                                      note: text,
                                    );
                                    if (!mounted) return;
                                    _notesController.clear();
                                    setState(() {
                                      _notesFuture = _service.getAspireNotes(
                                        context: context,
                                        day: DateTime.now(),
                                      );
                                    });
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSavingForecastNote = false;
                                      });
                                    }
                                  }
                                },
                          child: _isSavingForecastNote
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  child: Center(
                                    child:
                                        LoadingAnimationWidget.staggeredDotsWave(
                                          color: context.colors.primary,
                                          size: 16,
                                        ),
                                  ),
                                )
                              : Assets.icons.send.svg(
                                  width: 24.w,
                                  height: 24.h,
                                  colorFilter: ColorFilter.mode(
                                    context.colors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  FutureBuilder<List<dynamic>>(
                    future: _notesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 40.h,
                          child: Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: context.colors.primary,
                              size: 24,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text(
                          'No notes recorded',
                          style: context.typography.body.copyWith(
                            fontSize: 13.sp,
                            color: context.colors.textPrimary,
                          ),
                        );
                      }

                      final notes = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notes.map<Widget>((n) {
                          final day = n['day']?.toString() ?? '';
                          final dailyNotes =
                              n['notes']?.toString() ??
                              n['dailyNotes']?.toString() ??
                              '';
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: NotesCard(note: dailyNotes, day: day),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  if (_isToday) ...[
                    SizedBox(height: 10.h),
                    Text(
                      'Set a Review Date',
                      style: context.typography.body.copyWith(
                        fontFamily: 'sfpro',
                        color: context.colors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    DateTimeField(
                      initialDate: reassessDate,
                      onDateSelected: (date) {
                        reassessDate = date;
                      },
                    ),

                    SizedBox(height: 10.h),
                    const Spacer(),
                    SizedBox(height: 20.h),
                    MyButton(
                      backgroundColor: context.colors.background,
                      textColor: context.colors.textPrimary,
                      borderColor: context.colors.primary,
                      isLoading: _isSavingReviewDate,
                      label: 'Set date',
                      onPressed: () async {
                        if (reassessDate == null) {
                          context.flushBarErrorMessage(
                            message: 'Please select a date',
                          );
                          return;
                        }
                        setState(() {
                          _isSavingReviewDate = true;
                        });
                        final emotions = _aspirationEmotions
                            .map(
                              (e) => {
                                'key': e.key,
                                'intensity': e.intensity,
                                if (e.imageUrl != null) 'imageUrl': e.imageUrl,
                              },
                            )
                            .toList();
                        final success = await _userHomeService
                            .addAspirationalEmotions(
                              context: context,
                              emotions: emotions,
                              reassessDate: reassessDate,
                            );
                        if (!mounted) return;
                        if (success) {
                          await _load(_selectedDate);
                          if (!mounted) return;
                        }
                        setState(() {
                          _isSavingReviewDate = false;
                        });
                        if (success) {
                          context.flushBarSuccessMessage(
                            message: 'Review date set successfully',
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Date Naviagtion

  Widget _dateNavigator(BuildContext context) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final selectedMidnight = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    // Determine if the Next button should be enabled (Is selected date before today?)
    final isNextEnabled = selectedMidnight.isBefore(todayMidnight);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ◀◀ PREVIOUS DAY BUTTON
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              _isLoading = true; // Show loader immediately
              _notesFuture = _service.getAspireNotes(
                context: context,
                day: _selectedDate,
              );
            });
            _load(_selectedDate); // 🚀 Fetch data for the selected date
          },
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.keyboard_double_arrow_left_rounded,
              color: context.colors.primary,
              size: 26.sp,
            ),
          ),
        ),

        // 📅 DATE TEXT & CALENDAR PICKER CLICKABLE CENTER
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              // Prevent users from picking a future date via the calendar picker popup as well
              lastDate: todayMidnight,
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
                _isLoading = true;
                _notesFuture = _service.getAspireNotes(
                  context: context,
                  day: _selectedDate,
                );
              });
              _load(_selectedDate);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(_selectedDate),
                style: context.typography.headline.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.calendar_month_outlined,
                color: context.colors.primary,
                size: 22.sp,
              ),
            ],
          ),
        ),

        // ▶▶ NEXT DAY BUTTON
        GestureDetector(
          onTap: isNextEnabled
              ? () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                    _isLoading = true;
                    _notesFuture = _service.getAspireNotes(
                      context: context,
                      day: _selectedDate,
                    );
                  });
                  _load(
                    _selectedDate,
                  ); // 🚀 Fetch data for the newly advanced date
                }
              : null, // 👈 Passing null cleanly disables the GestureDetector tap action
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.keyboard_double_arrow_right_rounded,
              // 🎨 COLOR FIX: If enabled show primary theme color, if disabled look greyed out
              color: isNextEnabled
                  ? context.colors.primary
                  : context.colors.textSecondary.withValues(alpha: 0.4),
              size: 26.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoEmotionsPlaceholder({required bool showAddButton}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: context.colors.textPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sentiment_satisfied_alt_outlined,
                size: 36.sp,
                color: context.colors.textPrimary.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No emotions selected',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pick how you\'re feeling to keep track\nof your emotional patterns over time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 1.4,
                color: context.colors.textPrimary.withValues(alpha: 0.5),
              ),
            ),
            if (showAddButton) ...[
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () async {
                  final emotionType = await MyBottomSheet.show(
                    context,
                    child: const EmotionTypeBottomSheet(),
                  );
                  if (!mounted) return;
                  if (emotionType is String) {
                    await Navigator.pushNamed(
                      context,
                      emotionType,
                      arguments: const {'isFromHome': false},
                    );
                    if (!mounted) return;
                    _load(_selectedDate);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Add Emotions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Emotion boxes ─────────────────────────────────────────────────────────

  Widget _coreEmotionBox(BuildContext context) {
    return EmotionsSectionCard(
      title: "Core Emotions",
      titleColor: context.colors.textPrimary,
      titleFontSize: 14.sp,
      isEditMode: _isToday ? isCoreEditMode : false,
      onToggleEdit: _isToday
          ? (value) {
              setState(() {
                isCoreEditMode = value;
              });
            }
          : null,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      fillEmptySlotsTo: 3,
      emptySlotBuilder: (context) => EmptyTileCard(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            RoutesName.coreEmotions,
            arguments: {"isFromHome": false},
          );
          if (mounted) {
            _load(_selectedDate);
          }
        },
      ),
      tiles: _coreEmotions.asMap().entries.map((e) {
        final index = e.key;
        final emotion = e.value;
        return Stack(
          children: [
            EmotionTile(
              isEditMode: _isToday ? isCoreEditMode : false,
              emotion: fm.Emotion(
                key: emotion.key,
                intensity: emotion.intensity,
                imageUrl: emotion.imageUrl,
              ),
              showImage: true,
              isDisabled: _isAnyEmotionTileLoading,
              onEditImageTap: () => _handleCoreImageEdit(index, emotion),
              onDeleteTap: () => _confirmDeleteCoreEmotion(index, emotion),
            ),
            if (_loadingCoreIndex == index)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(top: 20.h, bottom: 20.h),
                  color: context.colors.background,
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: context.colors.primary,
                      size: 25,
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _aspirationEmotionBox(BuildContext context) {
    return EmotionsSectionCard(
      title: "Aspirational Emotions",
      titleColor: context.colors.textPrimary,
      titleFontSize: 14.sp,
      isEditMode: _isToday ? isAspirationEditMode : false,
      onToggleEdit: _isToday
          ? (value) {
              setState(() {
                isAspirationEditMode = value;
              });
            }
          : null,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      fillEmptySlotsTo: 3,
      emptySlotBuilder: (context) => EmptyTileCard(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            RoutesName.aspirationalEmotions,
            arguments: const {"isFromHome": false},
          );
          if (mounted) {
            _load(_selectedDate);
          }
        },
      ),
      tiles: _aspirationEmotions.asMap().entries.map((e) {
        final index = e.key;
        final emotion = e.value;
        return Stack(
          children: [
            EmotionTile(
              isEditMode: _isToday ? isAspirationEditMode : false,
              emotion: fm.Emotion(
                key: emotion.key,
                intensity: emotion.intensity,
                imageUrl: emotion.imageUrl,
              ),
              showImage: true,
              isDisabled: _isAnyEmotionTileLoading,
              onEditImageTap: () => _handleAspirationImageEdit(index, emotion),
              onDeleteTap: () =>
                  _confirmDeleteAspirationEmotion(index, emotion),
            ),
            if (_loadingAspirationIndex == index)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(top: 20.h, bottom: 20.h),
                  color: context.colors.background,
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: context.colors.primary,
                      size: 25,
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  // Handle core image edit
  Future<void> _handleCoreImageEdit(int index, CoreEmotion emotion) async {
    setState(() => _loadingCoreIndex = index);

    final imageUrl = await _pickAndUpload();

    if (imageUrl == null) {
      setState(() => _loadingCoreIndex = null);
      return;
    }

    setState(() {
      _coreEmotions[index] = CoreEmotion(
        key: emotion.key,
        intensity: emotion.intensity,
        imageUrl: imageUrl,
        id: emotion.id,
      );
    });

    await _updateCoreEmotions();

    setState(() => _loadingCoreIndex = null);
  }

  void _confirmDeleteCoreEmotion(int index, CoreEmotion emotion) {
    MyDialogBox.show(
      context,
      child: DeleteConfirmationDialog(
        title: "Delete Emotion",
        message: "Are you sure you want to delete this emotion?",
        onConfirm: () => _handleCoreEmotionDelete(index, emotion),
      ),
    );
  }

  Future<void> _handleCoreEmotionDelete(int index, CoreEmotion emotion) async {
    final key = emotion.key;
    if (key == null || key.isEmpty) return;

    setState(() => _loadingCoreIndex = index);

    final response = await _userHomeService.deleteCoreEmotion(
      data: {"day": _currentEmotionDay, "key": key},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load(_selectedDate);
      if (!mounted) return;
      context.flushBarSuccessMessage(
        message: "Core emotion deleted successfully",
      );
    }

    if (mounted) {
      setState(() => _loadingCoreIndex = null);
    }
  }

  // Handle aspiration image edit
  Future<void> _handleAspirationImageEdit(
    int index,
    AspirationEmotion emotion,
  ) async {
    setState(() => _loadingAspirationIndex = index);

    final imageUrl = await _pickAndUpload();

    if (imageUrl == null) {
      setState(() => _loadingAspirationIndex = null);
      return;
    }

    setState(() {
      _aspirationEmotions[index] = AspirationEmotion(
        key: emotion.key,
        intensity: emotion.intensity,
        imageUrl: imageUrl,
        id: emotion.id,
      );
    });

    await _updateAspirationEmotions();

    setState(() => _loadingAspirationIndex = null);
  }

  void _confirmDeleteAspirationEmotion(int index, AspirationEmotion emotion) {
    MyDialogBox.show(
      context,
      child: DeleteConfirmationDialog(
        title: "Delete Emotion",
        message: "Are you sure you want to delete this emotion?",
        onConfirm: () => _handleAspirationEmotionDelete(index, emotion),
      ),
    );
  }

  Future<void> _handleAspirationEmotionDelete(
    int index,
    AspirationEmotion emotion,
  ) async {
    final key = emotion.key;
    if (key == null || key.isEmpty) return;

    setState(() => _loadingAspirationIndex = index);

    final response = await _userHomeService.deleteAspirationEmotion(
      data: {"day": _currentEmotionDay, "key": key},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load(_selectedDate);
      if (!mounted) return;
      context.flushBarSuccessMessage(
        message: "Aspirational emotion deleted successfully",
      );
    }

    if (mounted) {
      setState(() => _loadingAspirationIndex = null);
    }
  }

  // Shared helpers
  Future<String?> _pickAndUpload() async {
    final file = await _imagePickerService.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null || !mounted) return null;

    final url = await _imageUploadService.uploadImage(context, file: file);
    if (!mounted) return null;

    if (url == null || url.isEmpty) return null;
    return url;
  }

  /// Sends the updated emotion list to the server and refreshes local state.
  Future<void> _updateCoreEmotions() async {
    final payload = _coreEmotions
        .map((e) => {"key": e.key, "imageUrl": e.imageUrl})
        .toList();

    final response = await _userHomeService.updateCoreImages(
      data: {"emotions": payload},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load(_selectedDate);
      if (!mounted) return;
      context.flushBarSuccessMessage(
        message: "Core emotions updated successfully",
      );
    }
  }

  Future<void> _updateAspirationEmotions() async {
    final payload = _aspirationEmotions
        .map((e) => {"key": e.key, "imageUrl": e.imageUrl})
        .toList();

    final response = await _userHomeService.updateAspirationImages(
      data: {"emotions": payload},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load(_selectedDate);
      if (!mounted) return;
      context.flushBarSuccessMessage(
        message: "Aspirational emotions updated successfully",
      );
    }
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Transform.translate(
          offset: Offset(
            -16.w,
            0,
          ), // Pulls the BackButton left by screen padding amount
          child: BackButton(color: context.colors.textPrimary),
        ),
        Expanded(
          child: Text(
            "Your Selection",
            textAlign: TextAlign.center,
            style: context.typography.headline.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // GestureDetector(
        //   onTap: () => Navigator.pushNamed(context, RoutesName.homeScreen),
        //   child: Assets.icons.homeIcon.svg(height: 40.h, width: 40.w),
        // ),
        Builder(
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
      ],
    );
  }
}

class NotesCard extends StatelessWidget {
  final String note;
  final String day;
  const NotesCard({super.key, required this.note, required this.day});

  @override
  Widget build(BuildContext context) {
    final displayDay = () {
      try {
        final parsed = DateTime.tryParse(day);
        if (parsed != null) return DateFormat('dd MMM').format(parsed);
        return day;
      } catch (_) {
        return day;
      }
    }();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Color(0xFFEFF3F1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted on $displayDay',
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontFamily: 'sfpro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontFamily: 'sfpro',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteActivityDialogBox extends StatelessWidget {
  final BuildContext parentContext;
  final String activityName;
  final VoidCallback onDeleted;
  final VoidCallback? onDeleteStart;
  final VoidCallback? onDeleteEnd;

  const DeleteActivityDialogBox({
    super.key,
    required this.parentContext,
    required this.activityName,
    required this.onDeleted,
    this.onDeleteStart,
    this.onDeleteEnd,
  });

  void _confirmDelete(BuildContext context) {
    // Close dialog, call API, then update UI on success
    Navigator.pop(context);
    onDeleteStart?.call();
    Future.microtask(() async {
      if (!parentContext.mounted) return;

      bool success;
      success = await UserHomeService().deletePlannedActivity(
        name: activityName,
        context: parentContext,
      );

      if (!parentContext.mounted) return;

      if (success) {
        onDeleted();
      } else {
        parentContext.flushBarErrorMessage(
          message: 'Failed to delete activity',
        );
      }
      onDeleteEnd?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150.h,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'Are you sure you want to delete "$activityName"?',
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontFamily: 'sfpro',
                fontSize: 14.sp,
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
  final planned.Schedule? schedule;
  final ValueChanged<String> onEdited;
  final VoidCallback? onRefresh;

  const EditActivityDialogBox({
    super.key,
    required this.parentContext,
    required this.activityId,
    required this.activityName,
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
      height: 350.h,
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

Widget _buildActivityItem(
  BuildContext context,
  Activity activity,
  bool isEditMode,
  DateTime selectedDate,
  VoidCallback? onRefresh,
  VoidCallback? onEditTap,
) {
  final apiLabel = activity.name?.trim();
  final title = apiLabel?.isNotEmpty == true
      ? apiLabel!
      : (activity.name ?? 'Unnamed activity');
  final badge = activity.uiBadge?.trim().isNotEmpty == true
      ? activity.uiBadge!
      : activity.schedule?.frequency;

  return Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.background, // choose visible color
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.colors.textPrimary,
            ),
          ),
          if (isEditMode) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {
                MyDialogBox.show(
                  context,
                  child: DeleteActivityDialogBox(
                    parentContext: context,
                    activityName: title,
                    onDeleted: () {
                      // Refresh activities
                      onRefresh?.call();
                    },
                  ),
                );
              },
              child: Assets.icons.bin.svg(height: 22.h, width: 22.h),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onEditTap,
              child: Assets.icons.pen.svg(height: 22.h, width: 22.h),
            ),
          ],
          const Spacer(),
          if (badge?.isNotEmpty == true)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEEB),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                badge!,
                style: context.typography.body.copyWith(
                  color: context.colors.primary,
                  fontSize: 11.sp,
                  fontFamily: 'sfpro',
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class EmptyTileCard extends StatelessWidget {
  final Function()? onTap;
  const EmptyTileCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 99.w,
        height: 77.h,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: context.colors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Center(child: Icon(Icons.add, color: context.colors.primary)),
      ),
    );
  }
}
