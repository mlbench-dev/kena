import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/delete_confirmation_dialog.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_circle_checkbox.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/premium_lock.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/tour_controller.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/community/community_members_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_notes.dart';
// import 'package:kena_emotional_journey/model/tour_section/tour_content.dart';
import 'package:kena_emotional_journey/app/utils/premium_features.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/provider/subscription_provider.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/community/widgets/user_profile_shimmer.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/edit_note_dialog.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/info_card_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

/// Shows the emotions the user forecasted for the day, their plan and
/// activities, lets them tweak forecast images, add running notes, share
/// the forecast with friends, and jump into the end-of-day reflection.
class ForecastResultScreen extends StatefulWidget {
  const ForecastResultScreen({super.key, this.forecastData});

  /// Optional pre-fetched data (e.g. passed in right after the user
  /// finished creating their forecast) so we can skip the initial network
  /// round-trip. If absent, we fetch it in [_load].
  final ForecastData? forecastData;

  @override
  State<ForecastResultScreen> createState() => _ForecastResultScreenState();
}

class _ForecastResultScreenState extends State<ForecastResultScreen> {
  // ── Services & controllers ──────────────────────────────────────────

  final UserHomeService _service = UserHomeService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final GlobalKey shareForecast = GlobalKey();
  final TextEditingController _notesController = TextEditingController();
  TourHandle? _tourHandle;

  // ── State ────────────────────────────────────────────────────────────

  bool _isLoading = true;
  bool _isUpdatingNotes = false;
  bool _isSavingForecastNote = false;
  bool _isEditMode = false;
  bool _isPlanExpanded = false;

  /// Index of the emotion tile currently uploading/deleting, or `null`.
  int? _loadingEmotionIndex;

  ForecastData? _forecastData;
  Future<ForecastNotes?>? _forecastNotesFuture;

  @override
  void initState() {
    super.initState();
    _forecastNotesFuture = _fetchForecastNotes();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _startOnboardingTour();
    // });
    _load();
    AdMobService.loadInterstitialAd();
    // Delay to allow ad to load before showing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AdMobService.showInterstitialAd();
      }
    });
  }

  @override
  void dispose() {
    _tourHandle?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  // void _startOnboardingTour() {
  //   if (!mounted) return;
  //   _tourHandle = TourController.start(
  //     context: context,
  //     sectionKey: TourSections.onboarding,
  //     targetKeys: [shareForecast],
  //   );
  // }

  // =========================================================
  // DATA FETCHING
  // =========================================================

  Future<void> _load({bool forceRefresh = false}) async {
    final canUseWidgetData =
        !forceRefresh && widget.forecastData != null && _forecastData == null;

    if (canUseWidgetData) {
      setState(() {
        _forecastData = widget.forecastData;
        _isLoading = false;
      });
      return;
    }

    final result = await _service.getForecast(context: context);
    if (!mounted) return;

    setState(() {
      _forecastData = result?.data?.firstOrNull;
      _isLoading = false;
    });
  }

  Future<ForecastNotes?> _fetchForecastNotes() {
    return _service.getForecastNotes(context: context, day: DateTime.now());
  }

  void _refreshForecastNotes() {
    setState(() {
      _forecastNotesFuture = _fetchForecastNotes();
    });
  }

  // ── Getters ──────────────────────────────────────────────────────────

  Forecast? get _forecast => _forecastData?.forecast;

  List<Emotion> get _emotions => _forecast?.emotions ?? [];

  List<Activity> get _activities {
    final activities = _forecastData?.activities ?? const <Activity>[];

    return activities.where((activity) {
      final name = activity.name?.trim();
      return name != null &&
          name.isNotEmpty &&
          name != 'End day comparison check' &&
          name != 'forecast';
    }).toList();
  }

  bool get _hasPlan => _forecast?.plan?.isNotEmpty == true;

  /// The forecast's own day if known, otherwise today — used whenever we
  /// send an update back to the server and need a `day` key.
  String get _currentDay =>
      _forecastData?.day ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Activities in the shape the update-forecast endpoint expects.
  List<Map<String, Object?>> get _activitiesPayload {
    return (_forecastData?.activities ?? const <Activity>[])
        .map((act) => {'name': act.name, 'completed': act.isCompleted ?? false})
        .toList();
  }

  // =========================================================
  // ACTIONS / HANDLERS
  // =========================================================

  Future<void> _onShareWithFriendsTap() async {
    if (!context.requirePremium(PremiumFeature.shareDailyForecast)) return;
    await MyDialogBox.show(
      context,
      child: InviteFriendsDialog(parentContext: context),
    );
    await _load(forceRefresh: true);
  }

  Future<void> _onStopSharingTap() async {
    await MyDialogBox.show(
      context,
      child: _StopSharingDialog(
        parentContext: context,
        onChanged: () => _load(forceRefresh: true),
      ),
    );
    await _load(forceRefresh: true);
  }

  Future<void> _onEditNotesTap() async {
    _notesController.text = _forecast?.notes ?? '';

    MyDialogBox.show(
      context,
      child: EditNotesDialog(
        controller: _notesController,
        onSave: _onSaveNotes,
      ),
    );
  }

  Future<void> _onSaveNotes() async {
    if (_isUpdatingNotes) return;

    setState(() => _isUpdatingNotes = true);
    try {
      final success = await _service.updateNotesOfTheDay(
        notes: _notesController.text,
        context: context,
      );
      if (!success || !mounted) return;

      Navigator.pop(context);
      await _load(forceRefresh: true);
      if (!mounted) return;

      context.flushBarSuccessMessage(message: 'Notes updated successfully');
    } finally {
      if (mounted) setState(() => _isUpdatingNotes = false);
    }
  }

  Future<void> _saveForecastNote() async {
    if (_isSavingForecastNote) return;

    final note = _notesController.text.trim();
    if (note.isEmpty) {
      context.flushBarErrorMessage(message: 'Please write a note first.');
      return;
    }

    setState(() => _isSavingForecastNote = true);
    try {
      final response = await _service.addForecastNote(
        context: context,
        day: DateTime.now(),
        note: note,
      );
      if (!mounted || response == null) return;

      _notesController.clear();
      _refreshForecastNotes();
      context.flushBarSuccessMessage(message: 'Note saved successfully.');
    } finally {
      if (mounted) setState(() => _isSavingForecastNote = false);
    }
  }

  /// Sends the full forecast back to the server with [emotionsPayload] as
  /// the new emotion list. Shared by the image-edit and delete flows, which
  /// both need to resend plan/notes/activities alongside the change.
  ///
  /// Kept untyped (matches `updateForecast`'s own return type) since the
  /// caller only ever checks it with `== true`.
  Future<dynamic> _saveForecast({
    required List<Map<String, Object?>> emotionsPayload,
  }) {
    return _service.updateForecast(
      data: {
        'day': _currentDay,
        'emotions': emotionsPayload,
        'plan': _forecast?.plan ?? '',
        'notes': _forecast?.notes ?? '',
        'activities': _activitiesPayload,
      },
      context: context,
    );
  }

  List<Map<String, Object?>> _emotionsPayload(List<Emotion> emotions) {
    return emotions
        .map(
          (e) => {
            'key': e.key,
            'intensity': e.intensity,
            'imageUrl': e.imageUrl,
          },
        )
        .toList();
  }

  Future<void> _handleForecastImageEdit(int index, Emotion emotion) async {
    setState(() => _loadingEmotionIndex = index);

    final file = await _imagePickerService.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) {
      if (mounted) setState(() => _loadingEmotionIndex = null);
      return;
    }

    final url = await _imageUploadService.uploadImage(context, file: file);
    if (!mounted) return;

    if (url == null || url.isEmpty) {
      setState(() => _loadingEmotionIndex = null);
      return;
    }

    final updatedPayload = _emotions.map((e) {
      return {
        'key': e.key,
        'intensity': e.intensity,
        'imageUrl': e.key == emotion.key ? url : e.imageUrl,
      };
    }).toList();

    final success = await _saveForecast(emotionsPayload: updatedPayload);
    if (!mounted) return;
    setState(() => _loadingEmotionIndex = null);

    if (success == true) {
      await _load(forceRefresh: true);
      if (!mounted) return;
      context.flushBarSuccessMessage(message: 'Image updated successfully');
    }
  }

  void _confirmDeleteForecastEmotion(int index, Emotion emotion) {
    MyDialogBox.show(
      context,
      child: DeleteConfirmationDialog(
        title: "Delete Emotion",
        message: "Are you sure you want to delete this emotion?",
        onConfirm: () => _handleForecastEmotionDelete(index, emotion),
      ),
    );
  }

  Future<void> _handleForecastEmotionDelete(int index, Emotion emotion) async {
    final key = emotion.key;
    if (key == null || key.isEmpty) return;

    setState(() => _loadingEmotionIndex = index);

    final isLastEmotion = _emotions.length <= 1;
    final success = isLastEmotion
        ? (await _service.deleteForecastEmotions(context: context)).data == true
        : (await _saveForecast(
                emotionsPayload: _emotionsPayload(
                  _emotions.where((e) => e.key != key).toList(),
                ),
              )) ==
              true;

    if (!mounted) return;
    setState(() => _loadingEmotionIndex = null);

    if (success) {
      await _load(forceRefresh: true);
      if (!mounted) return;
      context.flushBarSuccessMessage(
        message: 'Forecast emotion deleted successfully',
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

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
        padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h),
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() => const Center(child: LoadingWidget());

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            // Forces the content column to match the full height of the
            // screen so the Spacer below can push the buttons to the bottom.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 25.h),
                  _emotions.isEmpty
                      ? _buildNoEmotionsPlaceholder()
                      : _buildEmotionsSection(),
                  SizedBox(height: 20.h),
                  _buildPlanSection(),
                  SizedBox(height: 10.h),
                  _buildActivitiesSection(),
                  SizedBox(height: 10.h),
                  _buildNotesInput(),
                  SizedBox(height: 10.h),
                  _buildForecastNotesList(),
                  SizedBox(height: 10.h),
                  const Spacer(),
                  SizedBox(height: 10.h),
                  _buildShareButton(),
                  SizedBox(height: 10.h),
                  _buildEndDayReflectionButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // UI SECTIONS
  // =========================================================

  Widget _buildHeader() {
    return Row(
      children: [
        BackButton(color: context.colors.textPrimary),
        Expanded(
          child: Text(
            'Your Selection',
            textAlign: TextAlign.center,
            style: context.typography.headline.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
        // GestureDetector(
        //   onTap: () => Navigator.pushNamed(context, RoutesName.homeScreen),
        //   child: Assets.icons.homeIcon.svg(height: 40.h, width: 40.w),
        // ),
      ],
    );
  }

  Widget _buildNoEmotionsPlaceholder() {
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
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RoutesName.forecastScreen,
                  arguments: {'isFromHome': false, 'forecast': _forecast},
                );
                await _load(forceRefresh: true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
        ),
      ),
    );
  }

  Widget _buildEmotionsSection() {
    final emotionsToShow = _emotions.take(3).toList();

    return EmotionsSectionCard(
      title: 'Forecast',
      isEditMode: _isEditMode,
      onToggleEdit: (value) => setState(() => _isEditMode = value),
      showEmptyState: true,
      emptyText: 'No emotions selected',
      fillEmptySlotsTo: 3,
      emptySlotBuilder: (context) => EmptyTileCard(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            RoutesName.forecastScreen,
            arguments: {'isFromHome': false, 'forecast': _forecast},
          );
          await _load(forceRefresh: true);
        },
      ),
      tiles: emotionsToShow.asMap().entries.map((entry) {
        final index = entry.key;
        final emotion = entry.value;

        return Stack(
          children: [
            EmotionTile(
              isEditMode: _isEditMode,
              emotion: emotion,
              showImage: true,
              isDisabled: _loadingEmotionIndex != null,
              onEditImageTap: () => _handleForecastImageEdit(index, emotion),
              onDeleteTap: () => _confirmDeleteForecastEmotion(index, emotion),
            ),
            if (_loadingEmotionIndex == index)
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

  Widget _buildPlanSection() {
    return InfoCardWidget(
      showEditIcon: false,
      title: 'Your Plan',
      text: _hasPlan ? _forecast!.plan! : 'No plan recorded.',
      expanded: _isPlanExpanded,
      onToggle: () => setState(() => _isPlanExpanded = !_isPlanExpanded),
    );
  }

  Widget _buildActivitiesSection() {
    if (_activities.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActivitiesTitle(),
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    RoutesName.chooseActivity,
                    arguments: {'isToday': true, 'isFromForecast': true},
                  );
                  if (!context.mounted) return;
                  await _load();
                },
                child: Icon(Icons.add, color: context.colors.primary),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'No activities recorded',
            style: TextStyle(
              fontSize: 13.sp,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActivitiesTitle(),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RoutesName.chooseActivity,
                  arguments: {'isToday': true, 'isFromForecast': false},
                );
                if (!context.mounted) return;
                await _load();
              },
              child: Icon(Icons.add, color: context.colors.primary),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _activities.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == _activities.length - 1 ? 0 : 10.h,
                  ),
                  child: ActivityTile(
                    activity: _activities[i].name ?? '',
                    isChecked: _activities[i].isCompleted ?? false,
                    onChanged: (newValue) =>
                        _onActivityToggled(_activities[i], newValue),
                    onDeleted: () => _onActivityDeleted(_activities[i]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesTitle() {
    return Text(
      'Activities',
      style: context.typography.body.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        color: context.colors.textPrimary,
      ),
    );
  }

  /// Optimistically flips an activity's checked state, then confirms with
  /// the server — reverting locally if the request fails.
  Future<void> _onActivityToggled(Activity activity, bool newValue) async {
    final previousValue = activity.isCompleted ?? false;
    _setActivityCompleted(activity, newValue);

    final success = await _service.updateTodayActivity(
      context: context,
      id: activity.id ?? '',
      name: activity.name ?? '',
      completed: newValue,
      isCustom: false,
    );

    if (!success && mounted) {
      _setActivityCompleted(activity, previousValue);
    }
  }

  void _setActivityCompleted(Activity activity, bool completed) {
    final activities = _forecastData?.activities;
    if (activities == null) return;

    final index = activities.indexWhere((e) => e.name == activity.name);
    if (index == -1) return;

    setState(() {
      activities[index] = Activity(
        id: activity.id,
        name: activity.name,
        isCompleted: completed,
        isForecastOrEOD: activity.isForecastOrEOD,
      );
    });
  }

  Future<void> _onActivityDeleted(Activity activity) async {
    final success = await _service.deleteTodayActivity(
      name: activity.name ?? '',
      context: context,
    );
    if (!success || !context.mounted) return;

    context.flushBarSuccessMessage(message: 'Activity deleted successfully');
    await _load(forceRefresh: true);
  }

  Widget _buildNotesInput() {
    return MyTextField(
      controller: _notesController,
      borderColor: context.colors.textSecondary.withValues(alpha: 0.3),
      borderRadius: 10,
      hint: 'Write notes here...',
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: GestureDetector(
          onTap: _isSavingForecastNote ? null : _saveForecastNote,
          child: _isSavingForecastNote
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: context.colors.primary,
                    size: 24,
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
    );
  }

  Widget _buildForecastNotesList() {
    return FutureBuilder<ForecastNotes?>(
      future: _forecastNotesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 40.h,
            child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: context.colors.primary,
                size: 40.w,
              ),
            ),
          );
        }

        final notes = <Widget>[
          for (final day in snapshot.data?.data ?? const <ForecastNotesDay>[])
            for (final note in day.notes)
              if ((note.content?.trim() ?? '').isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: NotesCard(
                    note: note.content!.trim(),
                    day: day.day ?? '',
                  ),
                ),
        ];

        if (notes.isEmpty) {
          return Text(
            'No notes recorded',
            style: TextStyle(
              fontSize: 13.sp,
              color: context.colors.textSecondary,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notes,
        );
      },
    );
  }

  Widget _buildShareButton() {
    if (_forecastData?.isForecastShared == true) {
      return MyButton(
        label: 'Stop Sharing',
        backgroundColor: context.colors.background,
        textColor: context.colors.error,
        borderColor: context.colors.error,
        onPressed: _onStopSharingTap,
      );
    }
    return Padding(
      key: shareForecast,
      padding: EdgeInsets.all(2.w),
      child: MyButton(
        label: 'Share with Circle',
        icon: context.isFreemium ? const PremiumBadgeIcon(size: 22) : null,
        backgroundColor: context.colors.background,
        textColor: context.colors.primary,
        borderColor: context.colors.primary,
        onPressed: _onShareWithFriendsTap,
      ),
    );
  }

  Widget _buildEndDayReflectionButton() {
    final actions = context.watch<NavigationActionsController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: MyButton(
        label: 'End of Day Reflection',
        isLoading: actions.endDayReflectionLoading,
        onPressed: () => actions.onEndDayReflectionTap(context),
      ),
    );
  }
}

// =========================================================
// INVITE FRIENDS DIALOG
// =========================================================

class InviteFriendsDialog extends StatefulWidget {
  const InviteFriendsDialog({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  State<InviteFriendsDialog> createState() => _InviteFriendsDialogState();
}

class _InviteFriendsDialogState extends State<InviteFriendsDialog> {
  final TextEditingController _emailController = TextEditingController();
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
    _emailController.dispose();
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

  Future<void> _sendInvite() async {
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
    final success = await _service.sendInviteToMembers(
      memberIds: selectedIds,
      day: today,
      message: 'Check out my forecast for today!',
      context: widget.parentContext,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.pop(context);
      if (widget.parentContext.mounted) {
        widget.parentContext.flushBarSuccessMessage(
          message: 'Forecast shared successfully!',
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
            'Share Your Forecast',
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
        'Show your predictions to your friends. Keep everyone updated with your forecast.',
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
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
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
      label: 'Send Forecast',
      isLoading: _isSending,
      fontWeight: FontWeight.w400,
      onPressed: _isSending || _isLoading || _members.isEmpty
          ? null
          : _sendInvite,
    );
  }
}

// =========================================================
// STOP SHARING DIALOG
// =========================================================

class _StopSharingDialog extends StatefulWidget {
  const _StopSharingDialog({
    required this.parentContext,
    required this.onChanged,
  });

  final BuildContext parentContext;
  final VoidCallback onChanged;

  @override
  State<_StopSharingDialog> createState() => _StopSharingDialogState();
}

class _StopSharingDialogState extends State<_StopSharingDialog> {
  final UserHomeService _service = UserHomeService();
  List<MemberData> _members = [];
  bool _isLoading = true;
  bool _isStoppingAll = false;
  int? _removingIndex;

  @override
  void initState() {
    super.initState();
    _loadSharedMembers();
  }

  Future<void> _loadSharedMembers() async {
    final result = await _service.getSharedMembers(
      context: widget.parentContext,
    );
    if (!mounted) return;
    setState(() {
      _members = result?.data ?? [];
      _isLoading = false;
    });
  }

  Future<void> _removeMember(int index) async {
    final member = _members[index];
    if (member.id == null) return;

    setState(() => _removingIndex = index);

    final success = await _service.stopSharingForecast(
      userIds: [member.id!],
      context: widget.parentContext,
    );

    if (!mounted) return;
    setState(() => _removingIndex = null);
    if (!success) return;

    setState(() => _members.removeAt(index));
    widget.onChanged();

    final parentCtx = widget.parentContext;
    if (_members.isEmpty) Navigator.pop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (parentCtx.mounted) {
        parentCtx.flushBarSuccessMessage(
          message:
              'Stopped sharing with ${member.aliasName ?? member.username ?? 'member'}',
        );
      }
    });
  }

  Future<void> _stopSharingWithAll() async {
    final userIds = _members.map((m) => m.id).whereType<String>().toList();
    if (userIds.isEmpty) return;

    setState(() => _isStoppingAll = true);

    final success = await _service.stopSharingForecast(
      userIds: userIds,
      context: widget.parentContext,
    );

    if (!mounted) return;
    setState(() => _isStoppingAll = false);
    if (!success) return;

    widget.onChanged();
    final parentCtx = widget.parentContext;
    Navigator.pop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (parentCtx.mounted) {
        parentCtx.flushBarSuccessMessage(
          message: 'Stopped sharing with everyone',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          SizedBox(height: 10.h),
          _buildDescription(context),
          SizedBox(height: 10.h),
          _buildMembersSection(context),
          SizedBox(height: 12.h),
          MyButton(
            label: 'Stop Sharing ',
            isLoading: _isStoppingAll,
            backgroundColor: context.colors.tertiary,
            textColor: context.colors.background,
            // borderColor: context.colors.error,
            fontWeight: FontWeight.w600,
            onPressed: _isStoppingAll || _members.isEmpty
                ? null
                : _stopSharingWithAll,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.cancel, color: context.colors.error),
        ),
        SizedBox(width: 37.w),
        Text(
          'Shared With',
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontFamily: 'sfpro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Center(
      child: Text(
        'These members can see your forecast. Tap minus to stop sharing with a specific person.',
        textAlign: TextAlign.center,
        style: context.typography.body.copyWith(
          color: context.colors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: _isLoading
          ? const Center(child: UserProfileShimmerLoading())
          : _members.isEmpty
          ? Center(
              child: Text(
                'Not shared with anyone',
                style: context.typography.body.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _members.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (context, index) => _buildMemberItem(index),
            ),
    );
  }

  Widget _buildMemberItem(int index) {
    final member = _members[index];
    final name = (member.aliasName?.isNotEmpty ?? false)
        ? member.aliasName!
        : member.username ?? 'Unknown';
    final isRemoving = _removingIndex == index;

    return SizedBox(
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
                child: GestureDetector(
                  onTap: isRemoving ? null : () => _removeMember(index),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: context.colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: isRemoving
                        ? Padding(
                            padding: EdgeInsets.all(4.w),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            width:
                                24, // Set equal width and height to keep it a perfect circle
                            height: 24,
                            alignment: Alignment
                                .center, // Centers the child inside the container
                            decoration: BoxDecoration(
                              color: context.colors.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.tertiary,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 14.sp,
                              color: context.colors.tertiary,
                            ),
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
    );
  }
}

/// Shared circular avatar used by both the invite and stop-sharing dialogs.
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

// =========================================================
// ACTIVITY TILE
// =========================================================

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    required this.isChecked,
    required this.onChanged,
    required this.onDeleted,
  });

  final String activity;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isChecked
              ? context.colors.tertiary
              : context.colors.textSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              activity,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.tertiary,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onDeleted,
            child: Assets.icons.bin.svg(height: 27.h, width: 27.w),
          ),
          SizedBox(width: 10.w),
          // Once an activity is marked done it can't be undone, so this
          // renders as a static badge rather than a tappable checkbox.
          isChecked
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 16.sp,
                        color: context.colors.tertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: context.colors.tertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : MyCircleCheckbox(
                  isChecked: isChecked,
                  activeColor: context.colors.primary,
                  inactiveBorderColor: context.colors.textSecondary.withValues(
                    alpha: 0.3,
                  ),
                  onChanged: onChanged,
                ),
        ],
      ),
    );
  }
}

// =========================================================
// NOTES CARD
// =========================================================

class NotesCard extends StatelessWidget {
  const NotesCard({super.key, required this.note, required this.day});

  final String note;
  final String day;

  String get _displayDay {
    final parsed = DateTime.tryParse(day);
    return parsed != null ? DateFormat('dd MMM').format(parsed) : day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted on $_displayDay',
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

// =========================================================
// EMPTY EMOTION SLOT
// =========================================================

class EmptyTileCard extends StatelessWidget {
  const EmptyTileCard({super.key, this.onTap});

  final VoidCallback? onTap;

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
