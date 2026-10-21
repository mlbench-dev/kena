import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/activites/planned_activity_model.dart'
    as planned;
// 🚀 CRITICAL FIX 1: Import the exact model file your service layer uses
import 'package:kena_emotional_journey/model/emotions/result_emotion_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    as fm;
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/emotions/selected_emotions.dart'
    show DeleteActivityDialogBox, EditActivityDialogBox, EmptyTileCard;
import 'package:kena_emotional_journey/view/emotions/widgets/activities_card.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class EmotionsSummary extends StatefulWidget {
  const EmotionsSummary({super.key});

  @override
  State<EmotionsSummary> createState() => _EmotionsSummaryState();
}

class _EmotionsSummaryState extends State<EmotionsSummary> {
  List<CoreEmotion> _coreEmotions = [];
  List<AspirationEmotion> _aspirationEmotions = [];
  List<Activity> _activities = [];
  final UserHomeService _service = UserHomeService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;
  int? _loadingCoreIndex;
  int? _loadingAspirationIndex;
  String? _loadingActivityKey;

  bool get _isAnyEmotionTileLoading =>
      _loadingCoreIndex != null || _loadingAspirationIndex != null;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
    AdMobService.loadInterstitialAd();
  }

  /// Shown once as the user leaves this summary — see
  /// AdMobService.showInterstitialAd for the session cap/cooldown rules.
  Future<void> _onBackTap() async {
    await AdMobService.showInterstitialAd();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _load() async {
    final result = await _service.getJournalSelection(context: context);
    if (!mounted) return;

    final data = result?.data?.firstOrNull;
    setState(() {
      _coreEmotions = List<CoreEmotion>.from(data?.coreEmotions ?? []);
      _aspirationEmotions = List<AspirationEmotion>.from(
        data?.aspirationEmotions ?? [],
      );
      _activities = List<Activity>.from(data?.activities ?? []);
      _isLoading = false;
    });
  }

  void _onSavePressed() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // Simulate a 2-second saving process
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Reset loading state if needed before navigation
    setState(() {
      _isSaving = false;
    });

    Navigator.pushReplacementNamed(context, RoutesName.selectedEmotionsScreen);
    context.flushBarSuccessMessage(
      message: "Your emotions have been saved successfully",
    );
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
        leading: BackButton(
          color: context.colors.textPrimary,
          onPressed: _onBackTap,
        ),
        title: Text(
          'Your Summary',
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            fontFamily: 'sfpro',
          ),
        ),
        actions: [
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: _isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: context.colors.primary,
                  size: 45,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _coreEmotionBox(context),
                    SizedBox(height: 16.h),
                    _aspireEmotionBox(
                      context,
                    ), // 🚀 MATCHED: Pointing cleanly to helper now
                    SizedBox(height: 16.h),
                    _activitiesSection(context),
                    SizedBox(height: 50.h),
                    MyButton(
                      label: _isEditMode ? "Done" : "Edit",
                      onPressed: () =>
                          setState(() => _isEditMode = !_isEditMode),
                      backgroundColor: context.colors.background,
                      borderColor: context.colors.primary,
                      textColor: context.colors.primary,
                    ),
                    SizedBox(height: 20.h),
                    MyButton(
                      label: "Save",
                      onPressed: _onSavePressed,
                      isLoading: _isSaving,
                      backgroundColor: context.colors.primary,
                      textColor: context.colors.background,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _coreEmotionBox(BuildContext context) {
    return EmotionsSectionCard(
      title: "Core Emotions",
      titleColor: context.colors.textPrimary,
      titleFontSize: 16.sp,
      isEditMode: _isEditMode,
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
          if (mounted) _load();
        },
      ),
      tiles: _coreEmotions.asMap().entries.map((e) {
        final index = e.key;
        final emotion = e.value;
        return Stack(
          children: [
            EmotionTile(
              isEditMode: _isEditMode,
              emotion: fm.Emotion(
                key: emotion.key,
                intensity: emotion.intensity,
                imageUrl: emotion.imageUrl,
              ),
              showImage: true,
              isDisabled: _isAnyEmotionTileLoading,
              onEditImageTap: () => _handleCoreImageEdit(index, emotion),
              onDeleteTap: () => _handleCoreEmotionDelete(index, emotion),
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

  // 🚀 FIXED: Moved inside the Class state scope + cleaned up map/stack boilerplate
  Widget _aspireEmotionBox(BuildContext context) {
    return EmotionsSectionCard(
      title: "Aspirational Emotions",
      titleColor: const Color(0xFFD108A5),
      titleFontSize: 16.sp,
      isEditMode: _isEditMode,
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
          if (mounted) _load();
        },
      ),
      tiles: _aspirationEmotions.asMap().entries.map((e) {
        final index = e.key;
        final emotion = e.value;
        return Stack(
          children: [
            EmotionTile(
              isEditMode: _isEditMode,
              emotion: fm.Emotion(
                key: emotion.key,
                intensity: emotion.intensity,
                imageUrl: emotion.imageUrl,
              ),
              showImage: true,
              isDisabled: _isAnyEmotionTileLoading,
              onEditImageTap: () => _handleAspirationImageEdit(index, emotion),
              onDeleteTap: () => _handleAspirationEmotionDelete(index, emotion),
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

  Widget _activitiesSection(BuildContext context) {
    return ActivitiesCard(
      onAdd: () async {
        final saved = await Navigator.pushNamed(
          context,
          RoutesName.chooseActivity,
          arguments: {'isToday': false, 'isFromForecast': false},
        );
        if (saved != null) {
          _load();
        }
      },
      onEditTap: null,
      title: 'Activities',
      isEditMode: _isEditMode,
      showEditToggle: false,
      onToggleEdit: (value) {
        setState(() => _isEditMode = value);
      },
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
                      _isEditMode,
                      () => _load(),
                      isDeleting:
                          _loadingActivityKey ==
                          (activity.id ?? activity.name ?? ''),
                      onDeleteStart: () => setState(
                        () => _loadingActivityKey =
                            activity.id ?? activity.name ?? '',
                      ),
                      onDeleteEnd: () {
                        if (mounted) {
                          setState(() => _loadingActivityKey = null);
                        }
                      },
                      onEditTap: () {
                        MyDialogBox.show(
                          context,
                          child: EditActivityDialogBox(
                            parentContext: context,
                            activityId: activity.id ?? '',
                            activityName: activity.name ?? '',
                            schedule: activity.schedule != null
                                ? planned.Schedule(
                                    frequency: activity.schedule!.frequency,
                                    weeklyDays: activity.schedule!.weeklyDays,
                                    monthlyDays: activity.schedule!.monthlyDays,
                                    monthlyWeekDay:
                                        activity.schedule!.monthlyWeekDay,
                                    monthlyWeekNumber:
                                        activity.schedule!.monthlyWeekNumber,
                                  )
                                : null,
                            onEdited: (String newName) => _load(),
                            onRefresh: () => _load(),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
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

  Future<void> _handleCoreEmotionDelete(int index, CoreEmotion emotion) async {
    final key = emotion.key;
    if (key == null || key.isEmpty) return;

    setState(() => _loadingCoreIndex = index);

    final response = await _service.deleteCoreEmotion(
      data: {"day": _todayKey, "key": key},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load();
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

  Future<void> _handleAspirationEmotionDelete(
    int index,
    AspirationEmotion emotion,
  ) async {
    final key = emotion.key;
    if (key == null || key.isEmpty) return;

    setState(() => _loadingAspirationIndex = index);

    final response = await _service.deleteAspirationEmotion(
      data: {"day": _todayKey, "key": key},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load();
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

  Future<void> _updateCoreEmotions() async {
    final payload = _coreEmotions
        .map((e) => {"key": e.key, "imageUrl": e.imageUrl})
        .toList();

    final response = await _service.updateCoreImages(
      data: {"emotions": payload},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load();
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

    final response = await _service.updateAspirationImages(
      data: {"emotions": payload},
      context: context,
    );

    if (!mounted) return;

    if (response.data == true) {
      await _load();
      if (!mounted) return;
      context.flushBarSuccessMessage(
        message: "Aspirational emotions updated successfully",
      );
    }
  }
}

Widget _buildActivityItem(
  BuildContext context,
  Activity activity,
  bool isEditMode,
  VoidCallback? onRefresh, {
  bool isDeleting = false,
  VoidCallback? onDeleteStart,
  VoidCallback? onDeleteEnd,
  VoidCallback? onEditTap,
}) {
  final apiLabel = activity.name?.trim();
  final title = apiLabel?.isNotEmpty == true
      ? apiLabel!
      : (activity.name ?? 'Unnamed activity');
  final badge = activity.uiBadge?.trim().isNotEmpty == true
      ? activity.uiBadge!
      : activity.schedule?.frequency;

  return Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: Stack(
      children: [
        Container(
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
                  onTap: isDeleting
                      ? null
                      : () {
                          MyDialogBox.show(
                            context,
                            child: DeleteActivityDialogBox(
                              parentContext: context,
                              activityName: title,
                              onDeleteStart: onDeleteStart,
                              onDeleteEnd: onDeleteEnd,
                              onDeleted: () {
                                onRefresh?.call();
                                context.flushBarSuccessMessage(
                                  message: 'Activity deleted successfully',
                                );
                              },
                            ),
                          );
                        },
                  child: Assets.icons.bin.svg(height: 22.h, width: 22.h),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: isDeleting ? null : onEditTap,
                  child: Assets.icons.penOutline.svg(
                    height: 13.h,
                    width: 13.w,
                    color: context.colors.secondary,
                  ),
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
                      color: context.colors.tertiary,
                      fontSize: 11.sp,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.colors.textSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
