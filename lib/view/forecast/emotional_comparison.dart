import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kena_emotional_journey/app/components/expandable_text.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/forecast/comparison_model.dart'
    as comparison;
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    as forecast;
import 'package:kena_emotional_journey/model/forecast/forecast_notes.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/widgets/top_activities_section.dart';
import 'package:kena_emotional_journey/view/forecast/forecast_result_screen.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/edit_note_dialog.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

/// Which emotion list an image-edit action targets.
///
/// Replaces the old pair of near-identical `_handleForecastImageEdit` /
/// `_handleEndDayImageEdit` methods — the upload flow is the same for both,
/// only the source list, backend endpoint, and loading flag differ.
enum _EmotionSlot { forecast, reality }

/// Screen that shows the user's forecasted emotions next to how the day
/// actually went ("reality"), lets them swap tile images, leave notes on
/// their plan, and rate how the day compared to what they expected.
class EndOfDayComparisonScreen extends StatefulWidget {
  const EndOfDayComparisonScreen({super.key});

  @override
  State<EndOfDayComparisonScreen> createState() =>
      _EndOfDayComparisonScreenState();
}

class _EndOfDayComparisonScreenState extends State<EndOfDayComparisonScreen> {
  static const _ratingLabels = [
    'Much Worse',
    'Worse',
    'Same',
    'Better',
    'Much Better',
  ];

  final UserHomeService _service = UserHomeService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isSavingForecastNote = false;
  comparison.ComparisonModel? _comparisonResult;
  Future<ForecastNotes?>? _forecastNotesFuture;

  /// How the user rated their day (1-5) vs. the forecast.
  int _dayRating = 3;

  /// Which tile is currently showing an upload spinner, per section.
  /// `null` means no upload is in progress for that section.
  int? _loadingForecastIndex;
  int? _loadingRealityIndex;

  bool _isPlanExpanded = false;
  bool _isReflectionEditMode = false;

  /// Local, editable copies of the emotion lists.
  ///
  /// These are seeded once from the server response and then updated
  /// optimistically on image upload, so the UI never "flashes back" to a
  /// stale image while waiting on the network.
  List<comparison.Emotion> _forecastEmotions = [];
  List<comparison.Emotion> _realityEmotions = [];

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _forecastNotesFuture = _fetchForecastNotes();
    _loadComparison();
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
    _notesController.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────

  Future<void> _loadComparison() async {
    final result = await _service.getComparison(context: context);
    if (!mounted) return;

    setState(() {
      _comparisonResult = result;

      // Only seed on first load, so in-flight optimistic updates are never
      // clobbered by a (possibly stale) server response.
      if (_forecastEmotions.isEmpty) {
        _forecastEmotions = List<comparison.Emotion>.from(
          _comparisonData?.forecast?.emotions ?? const [],
        );
      }
      if (_realityEmotions.isEmpty) {
        _realityEmotions = List<comparison.Emotion>.from(
          _comparisonData?.reality?.emotions ?? const [],
        );
      }

      final serverRating = _comparisonData?.reality?.compareToForecast;
      if (serverRating != null) {
        _dayRating = serverRating;
      }

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

  // ── Convenience getters ──────────────────────────────────────────────

  comparison.ComparisonData? get _comparisonData =>
      (_comparisonResult?.data?.isNotEmpty ?? false)
      ? _comparisonResult!.data!.first
      : null;

  comparison.Forecast? get _forecast => _comparisonData?.forecast;
  comparison.Reality? get _reality => _comparisonData?.reality;

  /// Today's thought-monitoring split, as percentages of positive/neutral/
  /// negative thoughts logged for the day.
  List<ActivityDataModel> get _thoughtMonitoringActivities {
    final thoughtMonitoring = _comparisonData?.thoughtMonitoring;
    final positive = thoughtMonitoring?.positive ?? 0;
    final neutral = thoughtMonitoring?.neutral ?? 0;
    final negative = thoughtMonitoring?.negative ?? 0;
    final total = positive + neutral + negative;

    double percentOf(int value) => total == 0 ? 0 : (value / total) * 100;

    final positivePercent = percentOf(positive);
    final neutralPercent = percentOf(neutral);
    final negativePercent = percentOf(negative);

    return [
      ActivityDataModel(
        title: "Today's Thought Monitoring",
        name: 'Positive',
        currentDays: positivePercent,
        maxDays: 100,
        barColor: const Color(0xFF21573b),
        displayValue: '${positivePercent.toInt()}%',
      ),
      ActivityDataModel(
        name: 'Neutral',
        currentDays: neutralPercent,
        maxDays: 100,
        barColor: const Color(0xFFCAAC08),
        trackingBarColor: const Color(0xFFF1EAC2),
        displayValue: '${neutralPercent.toInt()}%',
      ),
      ActivityDataModel(
        name: 'Negative',
        currentDays: negativePercent,
        maxDays: 100,
        barColor: const Color(0xFFD60605),
        trackingBarColor: const Color(0xFFF5C1C1),
        displayValue: '${negativePercent.toInt()}%',
      ),
    ];
  }

  // ── Notes ────────────────────────────────────────────────────────────

  Future<void> _onEditPlanNotesTap() async {
    _notesController.text = _forecast?.notes ?? '';

    MyDialogBox.show(
      context,
      child: EditNotesDialog(
        controller: _notesController,
        onSave: () async {
          final success = await _service.updateEndDay(
            data: {'planFeedback': _notesController.text},
            context: context,
          );
          if (!success || !mounted) return;

          Navigator.pop(context);
          _loadComparison();
          context.flushBarSuccessMessage(message: 'Notes updated successfully');
        },
      ),
    );
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

  // ── Image upload (shared by forecast + reality tiles) ───────────────

  List<comparison.Emotion> _emotionsFor(_EmotionSlot slot) =>
      slot == _EmotionSlot.forecast ? _forecastEmotions : _realityEmotions;

  void _setLoadingIndex(_EmotionSlot slot, int? index) {
    setState(() {
      if (slot == _EmotionSlot.forecast) {
        _loadingForecastIndex = index;
      } else {
        _loadingRealityIndex = index;
      }
    });
  }

  Future<void> _handleEmotionImageEdit(
    _EmotionSlot slot,
    int index,
    comparison.Emotion emotion,
  ) async {
    _setLoadingIndex(slot, index);

    try {
      final file = await _imagePickerService.pickImage(
        source: ImageSource.gallery,
      );
      if (!mounted || file == null) {
        _setLoadingIndex(slot, null);
        return;
      }

      final url = await _imageUploadService.uploadImage(context, file: file);
      if (!mounted || url == null || url.isEmpty) {
        _setLoadingIndex(slot, null);
        return;
      }

      // Optimistic update — the UI reflects the new image immediately,
      // independent of whether the follow-up save call succeeds.
      setState(
        () => _emotionsFor(slot)[index] = emotion.copyWith(imageUrl: url),
      );

      final day = _comparisonData?.day;
      if (day == null || day.isEmpty) {
        _setLoadingIndex(slot, null);
        context.flushBarErrorMessage(message: 'Day not found. Please refresh.');
        return;
      }

      final payload = _emotionsFor(
        slot,
      ).take(3).map((e) => {'key': e.key, 'imageUrl': e.imageUrl}).toList();

      final result = slot == _EmotionSlot.forecast
          ? await _service.updateForecastImages(
              data: {'day': day, 'emotions': payload},
              context: context,
            )
          : await _service.updateEndDayImages(
              data: {'day': day, 'emotions': payload},
              context: context,
            );

      if (!mounted) return;
      _setLoadingIndex(slot, null);

      // Note: we intentionally don't call _loadComparison() here — the
      // backend can return a cached/stale snapshot, and the optimistic
      // update above is already the source of truth for this tile.
      if (result.data == true) {
        context.flushBarSuccessMessage(message: 'Image updated successfully');
      }
    } catch (e) {
      _setLoadingIndex(slot, null);
      debugPrint('${slot.name} image update error: $e');
      context.flushBarErrorMessage(message: 'Something went wrong. Try again.');
    }
  }

  Future<void> _handleReflectionEmotionDelete(
    int index,
    comparison.Emotion emotion,
  ) async {
    final key = emotion.key;
    if (key == null || key.isEmpty) return;

    final day = _comparisonData?.day;
    if (day == null || day.isEmpty) {
      context.flushBarErrorMessage(message: 'Day not found. Please refresh.');
      return;
    }

    _setLoadingIndex(_EmotionSlot.reality, index);

    final result = await _service.deleteReflectionEmotion(
      date: day,
      key: key,
      context: context,
    );

    if (!mounted) return;
    _setLoadingIndex(_EmotionSlot.reality, null);

    if (result.data == true) {
      setState(() => _realityEmotions.removeWhere((e) => e.key == key));
      context.flushBarSuccessMessage(
        message: 'Reflection emotion deleted successfully',
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

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
        child: _isLoading
            ? _buildLoadingState(context)
            : _buildContent(context),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: context.colors.primary,
        size: 45,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          // SizedBox(height: 25.h),

          // _buildSectionIntro(context),
          SizedBox(height: 10.h),

          _buildEmotionSection(
            context,
            slot: _EmotionSlot.forecast,
            title: 'Forecast',
            titleColor: context.colors.secondary,
          ),
          SizedBox(height: 20.h),

          _buildEmotionSection(
            context,
            slot: _EmotionSlot.reality,
            title: 'EOD Reflection',
            titleColor: context.colors.secondary,
            isEditMode: _isReflectionEditMode,
            onToggleEdit: (value) =>
                setState(() => _isReflectionEditMode = value),
            fillEmptySlotsTo: 3,
            emptySlotBuilder: (context) => EmptyTileCard(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RoutesName.endDayReflection,
                  arguments: {'isFromHome': false},
                );
                await _loadComparison();
              },
            ),
          ),
          SizedBox(height: 20.h),

          _buildPlanCard(context),
          SizedBox(height: 10.h),

          _buildActivitiesSection(context),
          SizedBox(height: 10.h),

          QuestionsCard(
            question: 'Did it go as forecast?',
            answer: (_reality?.wentAsForecast ?? false) ? 'Yes' : 'No',
          ),
          SizedBox(height: 10.h),
          QuestionsCard(
            question: 'Was the plan you set useful?',
            answer: (_reality?.planUseful ?? false) ? 'Yes' : 'No',
          ),
          SizedBox(height: 10.h),

          _buildDayRating(context),
          SizedBox(height: 16.h),

          TopActivitiesFlSection(activities: _thoughtMonitoringActivities),
          SizedBox(height: 10.h),

          _buildNotesInput(context),
          SizedBox(height: 10.h),
          _buildForecastNotesList(context),
          SizedBox(height: 70.h),

          MyButton(
            label: 'Back to home',
            onPressed: () =>
                Navigator.pushNamed(context, RoutesName.homeScreen),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // ── Header / intro labels ───────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        BackButton(color: context.colors.textPrimary),
        Expanded(
          child: Text(
            'Your Emotional Comparison',
            textAlign: TextAlign.center,
            style: context.typography.headline.copyWith(
              fontSize: 17.sp,
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
      ],
    );
  }

  Widget _buildSectionIntro(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Forecast vs. Reality',
        //   style: context.typography.label.copyWith(
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        // SizedBox(height: 8.h),
        // Text(
        //   "Here’s how your day unfolded compared to your forecast.",
        //   style: context.typography.body.copyWith(
        //     fontSize: 14.sp,
        //     color: context.colors.textSecondary,
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
        // SizedBox(height: 12.h),
        _buildSectionLabel(context, '', context.colors.textPrimary),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: context.typography.label.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: color,
        fontFamily: 'sfpro',
      ),
    );
  }

  // ── Emotion tiles ────────────────────────────────────────────────────

  Widget _buildEmotionSection(
    BuildContext context, {
    required _EmotionSlot slot,
    String? title,
    Color? titleColor,
    bool isEditMode = false,
    ValueChanged<bool>? onToggleEdit,
    int? fillEmptySlotsTo,
    WidgetBuilder? emptySlotBuilder,
  }) {
    final emotions = _emotionsFor(slot).take(3).toList();
    if (emotions.isEmpty && !isEditMode) return const SizedBox.shrink();

    final loadingIndex = slot == _EmotionSlot.forecast
        ? _loadingForecastIndex
        : _loadingRealityIndex;

    return EmotionsSectionCard(
      title: title,
      titleColor: titleColor,
      isEditMode: isEditMode,
      onToggleEdit: onToggleEdit,
      showEmptyState: false,
      fillEmptySlotsTo: fillEmptySlotsTo,
      emptySlotBuilder: emptySlotBuilder,
      tiles: List.generate(emotions.length, (index) {
        final emotion = emotions[index];
        final isLoading = loadingIndex == index;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            EmotionTile(
              isEditMode: isEditMode,
              emotion: forecast.Emotion(
                key: emotion.key,
                intensity: emotion.intensity,
                imageUrl: emotion.imageUrl,
              ),
              showImage: true,
              onEditImageTap: () =>
                  _handleEmotionImageEdit(slot, index, emotion),
              onDeleteTap: slot == _EmotionSlot.reality
                  ? () => _handleReflectionEmotionDelete(index, emotion)
                  : null,
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(top: 20.h, bottom: 20.h),
                  color: context.colors.background,
                  child: const Center(child: LoadingWidget()),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ── Plan card ────────────────────────────────────────────────────────

  Widget _buildPlanCard(BuildContext context) {
    return _InfoCard(
      title: 'Your Plan',
      showEditIcon: false,
      onEdit: null,
      child: ExpandableText(
        text: (_forecast?.plan?.isNotEmpty ?? false)
            ? _forecast!.plan!
            : 'No Plan recorded',
        expanded: _isPlanExpanded,
        onToggle: () => setState(() => _isPlanExpanded = !_isPlanExpanded),
      ),
    );
  }

  // ── Activities ───────────────────────────────────────────────────────

  Widget _buildActivitiesSection(BuildContext context) {
    final activities = _comparisonData?.activitiesToday ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activities',
              style: context.typography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: context.colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RoutesName.chooseActivity,
                  arguments: {'isToday': true, 'isFromForecast': false},
                );
                if (!context.mounted) return;
                await _loadComparison();
              },
              child: Icon(Icons.add, color: context.colors.primary),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: activities.isEmpty
              ? Center(
                  child: Text(
                    'No activity found',
                    style: context.typography.body.copyWith(
                      fontSize: 14.sp,
                      color: context.colors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < activities.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == activities.length - 1 ? 0 : 10.h,
                        ),
                        child: ActivityTile(
                          activity: activities[i].name ?? '',
                          isChecked: activities[i].isCompleted ?? false,
                          onChanged: (newValue) =>
                              _onActivityToggled(activities[i], newValue),
                          onDeleted: () => _onActivityDeleted(activities[i]),
                        ),
                      ),
                  ],
                ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  /// Optimistically flips an activity's checked state, then confirms with
  /// the server — reverting locally if the request fails.
  Future<void> _onActivityToggled(
    comparison.ActivityToday activity,
    bool newValue,
  ) async {
    final previousValue = activity.isCompleted ?? false;
    _setActivityCompleted(activity, newValue);

    final success = await _service.updateTodayActivity(
      context: context,
      id: '',
      name: activity.name ?? '',
      completed: newValue,
      isCustom: activity.isCustom ?? false,
    );

    if (!success && mounted) {
      _setActivityCompleted(activity, previousValue);
    }
  }

  void _setActivityCompleted(
    comparison.ActivityToday activity,
    bool completed,
  ) {
    final activities = _comparisonData?.activitiesToday;
    if (activities == null) return;

    final index = activities.indexWhere((e) => e.name == activity.name);
    if (index == -1) return;

    setState(() {
      activities[index] = comparison.ActivityToday(
        name: activity.name,
        isCustom: activity.isCustom,
        isCompleted: completed,
      );
    });
  }

  Future<void> _onActivityDeleted(comparison.ActivityToday activity) async {
    final success = await _service.deleteTodayActivity(
      name: activity.name ?? '',
      context: context,
    );
    if (!success || !context.mounted) return;

    context.flushBarSuccessMessage(message: 'Activity deleted successfully');
    await _loadComparison();
  }

  // ── Day rating ───────────────────────────────────────────────────────

  Widget _buildDayRating(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did it go?',
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'sfpro',
          ),
        ),
        Text(
          'On a scale of 1 to 5, how did your day compare to the forecast?',
          style: context.typography.body.copyWith(
            color: context.colors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'sfpro',
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final value = index + 1;
            return NumberCircle(
              number: value,
              isSelected: _dayRating == value,
              onTap: () {},
            );
          }),
        ),
        SizedBox(height: 10.h),
        _RatingLabelRow(labels: _ratingLabels),
      ],
    );
  }

  // ── Notes ────────────────────────────────────────────────────────────

  Widget _buildNotesInput(BuildContext context) {
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

  Widget _buildForecastNotesList(BuildContext context) {
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
}

// ── Small presentational widgets ────────────────────────────────────────

/// Rounded bordered card used for "Your Plan" / similar labeled sections,
/// with an optional trailing edit pencil icon.
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showEditIcon;
  final VoidCallback? onEdit;

  const _InfoCard({
    required this.title,
    required this.child,
    required this.showEditIcon,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
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
                child,
              ],
            ),
          ),
          if (showEditIcon)
            GestureDetector(onTap: onEdit, child: Assets.icons.pen2.svg()),
        ],
      ),
    );
  }
}

class _RatingLabelRow extends StatelessWidget {
  final List<String> labels;

  const _RatingLabelRow({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final label in labels)
          Text(
            label,
            style: context.typography.subtitle.copyWith(
              fontSize: 10.sp,
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// A yes/no question with its answer, e.g. "Did it go as forecast? — Yes".
class QuestionsCard extends StatelessWidget {
  final String question;
  final String answer;

  const QuestionsCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'sfpro',
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          answer,
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'sfpro',
          ),
        ),
      ],
    );
  }
}

/// A tappable numbered circle used for the 1-5 day rating.
class NumberCircle extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const NumberCircle({
    super.key,
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26.r,
        backgroundColor: isSelected
            ? context.colors.tertiary
            : const Color(0xFFF3F4F6),
        child: Text(
          '$number',
          style: context.typography.body.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6c7280),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
