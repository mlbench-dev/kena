import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/emotions/emotion_category.dart';
import 'package:kena_emotional_journey/model/emotions/emotions_list.dart';
import 'package:kena_emotional_journey/model/forecast/comparison_model.dart'
    as comparison;
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_search_mixin.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_status_row.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/intensity_circle.dart';
import 'package:kena_emotional_journey/view/home/widgets/intensity_box.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class SelectedEndDayReflectionEmotion {
  final String key;
  final String categoryTitle;
  final Color categoryColor;
  final Widget categoryEmoji;
  final String subEmotionTitle;
  final Widget subEmotionEmoji;
  final int intensity;
  final String? uploadedImageUrl;

  const SelectedEndDayReflectionEmotion({
    required this.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.subEmotionTitle,
    required this.subEmotionEmoji,
    required this.intensity,
    this.uploadedImageUrl,
  });
  SelectedEndDayReflectionEmotion copyWith({
    String? key,
    String? categoryTitle,
    Color? categoryColor,
    Widget? categoryEmoji,
    String? subEmotionTitle,
    Widget? subEmotionEmoji,
    int? intensity,
    String? uploadedImageUrl,
  }) {
    return SelectedEndDayReflectionEmotion(
      key: key ?? this.key,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryEmoji: categoryEmoji ?? this.categoryEmoji,
      subEmotionTitle: subEmotionTitle ?? this.subEmotionTitle,
      subEmotionEmoji: subEmotionEmoji ?? this.subEmotionEmoji,
      intensity: intensity ?? this.intensity,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class EndDayReflectionScreen extends StatefulWidget {
  final bool isFromHome;

  const EndDayReflectionScreen({super.key, this.isFromHome = false});

  @override
  State<EndDayReflectionScreen> createState() => _EndDayReflectionScreenState();
}

class _EndDayReflectionScreenState extends State<EndDayReflectionScreen>
    with EmotionSearchMixin {
  String? _expandedCategory;
  final Map<String, String> _selectedSubEmotions = {};
  final List<SelectedEndDayReflectionEmotion> _selectedEmotions = [];
  @override
  final List<EmotionCategory> categories = EmotionsList().emotionCategories;
  final UserHomeService userHomeService = UserHomeService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final TextEditingController _endDayNotesController = TextEditingController();
  List<Emotion> forecastEmotions = [];
  bool isPositive = false;
  bool planUseful = false;
  DateTime? reassessDate;
  bool _isUploading = false;
  final int _selectedIntensity = 3;
  bool? _isPlanUseFul;
  bool? _goAsForecast;

  /// Tracks uploaded image URLs per category title
  final Map<String, String> _categoryImages = {};

  /// True while the expanded panel is open — hides circles during selection
  bool get _isPanelOpen => _expandedCategory != null;

  void _onCategoryTap(String title) {
    if (_selectedEmotions.length >= 3) {
      context.flushBarErrorMessage(
        message: "You can select up to 3 emotions only",
      );
      return;
    }

    setState(() {
      _expandedCategory = _expandedCategory == title ? null : title;
      // Clear the uploaded image when expanding a category
      if (_expandedCategory != null) {
        _categoryImages.remove(title);
      }
    });
  }

  void _onSubEmotionTap(EmotionCategory category, SubEmotion sub) {
    setState(() {
      _selectedSubEmotions[category.title] = sub.title;
      // Clear the uploaded image when selecting a new sub-emotion
      _categoryImages.remove(category.title);
    });
  }

  Future<void> _pickAndUploadImage(String categoryTitle) async {
    final file = await _imagePickerService.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null || !mounted) return;

    setState(() => _isUploading = true);

    final url = await _imageUploadService.uploadImage(context, file: file);

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (url != null) {
        _categoryImages[categoryTitle] = url;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadForecast();
    _loadExistingReflection();
  }

  @override
  void dispose() {
    _endDayNotesController.dispose();
    super.dispose();
  }

  Future<void> loadForecast() async {
    final model = await userHomeService.getForecast(context: context);

    if (!mounted) return;
    setState(() {
      // Drill into data[0].forecast.emotions
      forecastEmotions = model?.data?.first.forecast?.emotions ?? [];
    });
  }

  /// Preloads any reflection emotions already saved for today (e.g. when
  /// the user comes back here to add an emotion after deleting one from
  /// the end-of-day comparison screen) so they aren't lost on the next save.
  Future<void> _loadExistingReflection() async {
    final result = await userHomeService.getComparison(context: context);
    if (!mounted) return;

    final realityEmotions = result?.data?.firstOrNull?.reality?.emotions ?? [];
    final preloaded = realityEmotions
        .map(_buildSelectedEmotionFromExisting)
        .whereType<SelectedEndDayReflectionEmotion>()
        .take(3)
        .toList();

    if (preloaded.isEmpty) return;

    setState(() {
      _selectedEmotions
        ..clear()
        ..addAll(preloaded);
      for (final emotion in preloaded) {
        _selectedSubEmotions[emotion.categoryTitle] = emotion.subEmotionTitle;
      }
    });
  }

  /// Reverse-looks-up a saved `key` (category or sub-emotion) against
  /// [categories] to rebuild the richer selection model this screen works
  /// with.
  SelectedEndDayReflectionEmotion? _buildSelectedEmotionFromExisting(
    comparison.Emotion emotion,
  ) {
    final key = emotion.key;
    if (key == null || key.isEmpty) return null;

    for (final category in categories) {
      if (category.key == key) {
        return SelectedEndDayReflectionEmotion(
          key: category.key,
          categoryTitle: category.title,
          categoryColor: category.color,
          categoryEmoji: category.emojiBuilder(28.w, 28.h),
          subEmotionTitle: category.title,
          subEmotionEmoji: category.emojiBuilder(28.w, 28.h),
          intensity: emotion.intensity ?? 3,
          // Backend sends "" (not null) when no image was uploaded.
          uploadedImageUrl: (emotion.imageUrl?.isNotEmpty ?? false)
              ? emotion.imageUrl
              : null,
        );
      }

      final sub = category.subEmotions.where((s) => s.key == key).firstOrNull;
      if (sub != null) {
        return SelectedEndDayReflectionEmotion(
          key: sub.key,
          categoryTitle: category.title,
          categoryColor: category.color,
          categoryEmoji: category.emojiBuilder(28.w, 28.h),
          subEmotionTitle: sub.title,
          subEmotionEmoji: sub.emojiBuilder(28.w, 28.h),
          intensity: emotion.intensity ?? 3,
          uploadedImageUrl: (emotion.imageUrl?.isNotEmpty ?? false)
              ? emotion.imageUrl
              : null,
        );
      }
    }

    return null;
  }

  Future<bool> _submitEmotions({bool returnOnlyStatus = false}) async {
    if (_selectedEmotions.isEmpty) return false;

    // if (_goAsForecast == null || _isPlanUseFul == null) {
    //   context.flushBarErrorMessage(message: "Please select values");
    //   return false;
    // }

    // Prepare payload for API
    final emotions = _selectedEmotions
        .map(
          (e) => {
            'key': e.key,
            'intensity': e.intensity,
            if (e.uploadedImageUrl != null) 'imageUrl': e.uploadedImageUrl,
          },
        )
        .toList();

    final success = await userHomeService.endOfDay(
      context: context,
      emotions: emotions,
      wentAsForecast: false,
      planUseful: false,
      planFeedback: _endDayNotesController.text,
      compareToForecast: _selectedIntensity,
    );

    return success; // return status, don't navigate here anymore
  }

  bool _isSubEmotionSelected(String categoryTitle, String subTitle) {
    // Highlight is purely visual for the last picked sub in this panel session
    return _selectedSubEmotions[categoryTitle] == subTitle;
  }

  @override
  List get selectedEmotions => _selectedEmotions;

  @override
  Map<String, String> get selectedSubEmotions => _selectedSubEmotions;

  @override
  Map<String, String> get categoryImages => _categoryImages;

  @override
  void Function(String) get onCategoryExpand => _onCategoryTap;

  @override
  void Function(EmotionCategory, dynamic) get onSubEmotionSelect =>
      (category, sub) => _onSubEmotionTap(category, sub as SubEmotion);

  @override
  Widget build(BuildContext context) {
    final row1 = categories.sublist(0, 3);
    final row2 = categories.sublist(3, 6);
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
          'How did the day go?',
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Forecast Emotion Status Row (reference from forecast) ──
              if (forecastEmotions.isNotEmpty) ...[
                Text(
                  'You expected to be:',
                  style: context.typography.body.copyWith(
                    fontSize: 14.sp,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                EmotionStatusRow(
                  items: forecastEmotions.take(3).map((e) {
                    final key = e.key ?? '';
                    final bgColor = EmotionsList.getColorByKey(key);
                    final borderColor = Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.08),
                      bgColor,
                    );
                    return EmotionItem(
                      label: EmotionsList.getTitleByKey(key),
                      emoji: EmotionsList.getEmojiByKey(key, w: 36, h: 36),
                      imageUrl: e.imageUrl,
                      backgroundColor: bgColor,
                      borderColor: borderColor,
                      isSelected: true,
                    );
                  }).toList(),
                ),

                SizedBox(height: 10.h),
                Text(
                  "Select up to 3 emotions  that carried the day:",
                  textAlign: TextAlign.left,
                  style: context.typography.subtitle.copyWith(
                    fontSize: 14.sp,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // ── Search ───────────────────────────────────────────────────
              MyTextField(
                controller: searchController,
                hint: searchHint,
                borderColor: const Color(0xFFd0d0d0),
                fillColor: Colors.transparent,
                hintColor: context.colors.textPrimary,
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),

              // ── Search results ───────────────────────────────────────────
              if (searchQuery.isNotEmpty)
                buildSearchResults()
              else ...[
                // ── Emotion grid — row 1 ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: row1
                      .map(
                        (cat) => EmotionsCard(
                          title: cat.title,
                          emoji: cat.emojiBuilder(24.w, 24.h),
                          color: cat.color,
                          isExpanded: _expandedCategory == cat.title,
                          onTap: () => _onCategoryTap(cat.title),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 20.h),

                // ── Emotion grid — row 2 ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: row2
                      .map(
                        (cat) => EmotionsCard(
                          title: cat.title,
                          emoji: cat.emojiBuilder(24.w, 24.h),
                          color: cat.color,
                          isExpanded: _expandedCategory == cat.title,
                          onTap: () => _onCategoryTap(cat.title),
                        ),
                      )
                      .toList(),
                ),
              ],

              // ── Expanded panel ───────────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _expandedCategory != null
                    ? _buildExpandedPanel(
                        context,
                        categories.firstWhere(
                          (c) => c.title == _expandedCategory,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              // ── Intensity circles (hidden while panel is open) ───────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: (_selectedEmotions.isEmpty || _isPanelOpen)
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Text(
                            "Your selection",
                            style: context.typography.body.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.only(
                              top: 5.h,
                              bottom: 5.h,
                              left: 15.w,
                              right: 5.w,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.background,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFebebeb),
                              ),
                            ),
                            child: _selectedEmotions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      child: Text(
                                        "No emotions selected",
                                        style: context.typography.subtitle
                                            .copyWith(fontSize: 12.sp),
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap:
                                        true, // Crucial inside a Column/Container
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Prevents nested scrolling conflicts
                                    itemCount: _selectedEmotions.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          2, // Forces exactly 2 items per row
                                      crossAxisSpacing: 18
                                          .w, // Your original horizontal spacing
                                      mainAxisSpacing:
                                          5.h, // Your original vertical spacing
                                      childAspectRatio:
                                          1.6, // Adjust this ratio if your IntensityCircle looks squeezed or stretched
                                    ),
                                    itemBuilder: (context, index) {
                                      final e = _selectedEmotions[index];
                                      return IntensityCircle(
                                        intensity: e.intensity,
                                        centerWidget: e.subEmotionEmoji,
                                        label: e.subEmotionTitle,
                                        imageUrl: e.uploadedImageUrl,
                                        isDisabled: _isUploading,
                                        onUpload: () async {
                                          final file = await _imagePickerService
                                              .pickImage(
                                                source: ImageSource.gallery,
                                              );

                                          if (file == null || !mounted) return;

                                          setState(() => _isUploading = true);

                                          final url = await _imageUploadService
                                              .uploadImage(context, file: file);

                                          if (!mounted) return;

                                          setState(() {
                                            _isUploading = false;
                                            if (url != null) {
                                              _selectedEmotions[index] =
                                                  _selectedEmotions[index]
                                                      .copyWith(
                                                        uploadedImageUrl: url,
                                                      );
                                            }
                                          });
                                        },
                                        onRemove: () {
                                          setState(() {
                                            _selectedEmotions.removeAt(index);
                                          });
                                        },
                                      );
                                    },
                                  ),
                          ),

                          SizedBox(height: 20.h),
                          // ── Reflection Save Flow ───────────────────────────────────────────
                          if (_selectedEmotions.isNotEmpty &&
                              !_isPanelOpen) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //     Text(
                                //       "Did it go as forecast?",
                                //       style: context.typography.body.copyWith(
                                //         color: context.colors.textPrimary,
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //     SizedBox(height: 10.h),
                                //     Row(
                                //       mainAxisAlignment: MainAxisAlignment.start,
                                //       children: [
                                //         Expanded(
                                //           child: RadioListTile<bool>(
                                //             value: true,
                                //             groupValue: _goAsForecast,
                                //             onChanged: (val) =>
                                //                 setState(() => _goAsForecast = val),
                                //             title: Text(
                                //               'Yes',
                                //               style: context.typography.body
                                //                   .copyWith(
                                //                     fontSize: 13.sp,
                                //                     fontWeight: FontWeight.w600,
                                //                     color:
                                //                         context.colors.textPrimary,
                                //                   ),
                                //             ),
                                //             contentPadding: EdgeInsets.zero,
                                //             dense: true,
                                //             visualDensity: const VisualDensity(
                                //               horizontal: -4,
                                //               vertical: -4,
                                //             ), // reduces spacing
                                //             fillColor: WidgetStatePropertyAll(
                                //               context.colors.primary,
                                //             ),
                                //             activeColor: Colors.white,
                                //           ),
                                //         ),
                                //         Expanded(
                                //           child: RadioListTile<bool>(
                                //             value: false,
                                //             groupValue: _goAsForecast,
                                //             onChanged: (val) =>
                                //                 setState(() => _goAsForecast = val),
                                //             title: Text(
                                //               'No',
                                //               style: context.typography.body
                                //                   .copyWith(
                                //                     fontSize: 13.sp,
                                //                     fontWeight: FontWeight.w600,
                                //                     color:
                                //                         context.colors.textPrimary,
                                //                   ),
                                //             ),
                                //             contentPadding: EdgeInsets.zero,
                                //             dense: true,
                                //             visualDensity: const VisualDensity(
                                //               horizontal: -4,
                                //               vertical: -4,
                                //             ), // reduces spacing
                                //             fillColor: WidgetStatePropertyAll(
                                //               context.colors.primary,
                                //             ),
                                //             activeColor: Colors.white,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //     SizedBox(height: 20.h),
                                //     Text(
                                //       "Was the plan you set useful?",
                                //       style: context.typography.body.copyWith(
                                //         color: context.colors.textPrimary,
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //     SizedBox(height: 10.h),
                                //     Row(
                                //       mainAxisAlignment: MainAxisAlignment.start,
                                //       children: [
                                //         Expanded(
                                //           child: RadioListTile<bool>(
                                //             value: true,
                                //             groupValue: _isPlanUseFul,
                                //             onChanged: (val) =>
                                //                 setState(() => _isPlanUseFul = val),
                                //             title: Text(
                                //               'Yes',
                                //               style: context.typography.body
                                //                   .copyWith(
                                //                     fontSize: 13.sp,
                                //                     fontWeight: FontWeight.w600,
                                //                     color:
                                //                         context.colors.textPrimary,
                                //                   ),
                                //             ),
                                //             contentPadding: EdgeInsets.zero,
                                //             dense: true,
                                //             visualDensity: const VisualDensity(
                                //               horizontal: -4,
                                //               vertical: -4,
                                //             ), // reduces spacing
                                //             fillColor: WidgetStatePropertyAll(
                                //               context.colors.primary,
                                //             ),
                                //             activeColor: Colors.white,
                                //           ),
                                //         ),
                                //         Expanded(
                                //           child: RadioListTile<bool>(
                                //             value: false,
                                //             groupValue: _isPlanUseFul,
                                //             onChanged: (val) =>
                                //                 setState(() => _isPlanUseFul = val),
                                //             title: Text(
                                //               'No',
                                //               style: context.typography.body
                                //                   .copyWith(
                                //                     fontSize: 13.sp,
                                //                     fontWeight: FontWeight.w600,
                                //                     color:
                                //                         context.colors.textPrimary,
                                //                   ),
                                //             ),
                                //             contentPadding: EdgeInsets.zero,
                                //             dense: true,
                                //             visualDensity: const VisualDensity(
                                //               horizontal: -4,
                                //               vertical: -4,
                                //             ), // reduces spacing
                                //             fillColor: WidgetStatePropertyAll(
                                //               context.colors.primary,
                                //             ),
                                //             activeColor: Colors.white,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //     SizedBox(height: 20.h),
                                //     EndDayReflectionDialog(
                                //       onSubmit: (val) {
                                //         setState(() {
                                //           _selectedIntensity = val;
                                //         });
                                //       },
                                //     ),
                                //   ],
                                // ),
                                SizedBox(height: 20.h),
                                MyButton(
                                  label: "Next",
                                  textColor: context.colors.background,
                                  onPressed: () {
                                    // Prepare emotions data for questions screen
                                    final emotionsData = _selectedEmotions
                                        .map(
                                          (e) => {
                                            'key': e.key,
                                            'intensity': e.intensity,
                                            if (e.uploadedImageUrl != null)
                                              'imageUrl': e.uploadedImageUrl,
                                          },
                                        )
                                        .toList();

                                    widget.isFromHome
                                        ? Navigator.pushNamed(
                                            context,
                                            RoutesName.questionsScreen,
                                            arguments: {
                                              'selectedEmotions': emotionsData,
                                              'notes':
                                                  _endDayNotesController.text,
                                            },
                                          )
                                        : Navigator.pushReplacementNamed(
                                            context,
                                            RoutesName.questionsScreen,
                                            arguments: {
                                              'selectedEmotions': emotionsData,
                                              'notes':
                                                  _endDayNotesController.text,
                                            },
                                          );
                                  },
                                  // onPressed: () async {
                                  //   final success = await _submitEmotions(
                                  //     returnOnlyStatus: true,
                                  //   );

                                  //   if (!mounted) return;
                                  //   if (!success) return;

                                  //   Navigator.pushReplacementNamed(
                                  //     context,
                                  //     RoutesName.homeScreen,
                                  //   );

                                  //   Future.microtask(() {
                                  //     context.flushBarSuccessMessage(
                                  //       message: "Emotions saved successfully",
                                  //     );
                                  //   });
                                  // },
                                ),
                                // SizedBox(height: 10.h),
                                // MyButton(
                                //   label: "Compare with Forecast",
                                //   fontSize: 14.sp,
                                //   fontWeight: FontWeight.w600,
                                //   textColor: context.colors.background,
                                //   onPressed: () async {
                                //     final success = await _submitEmotions(
                                //       returnOnlyStatus: true,
                                //     );
                                //     if (success && mounted) {
                                //       Navigator.pushReplacementNamed(
                                //         context,
                                //         RoutesName.endDayComparisonScreen,
                                //       );
                                //       // Navigator.pushNamed(
                                //       //   context,
                                //       //   RoutesName.chooseActivity,
                                //       //   arguments: {
                                //       //   },
                                //       // )
                                //       // .then((_) {
                                //       //   if (mounted) {
                                //       //     Navigator.pushReplacementNamed(
                                //       //       context,
                                //       //       RoutesName.endDayComparisonScreen,
                                //       //     );
                                //       //   }
                                //       // }
                                //       // );
                                //     }
                                //   },
                                // ),
                              ],
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Expanded Panel ─────────────────────────────────────────────────────────
  Widget _buildExpandedPanel(BuildContext context, EmotionCategory category) {
    final selectedSub = _selectedSubEmotions[category.title];

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(15.w),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFebebeb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category header ──────────────────────────────────────────────
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10.h, right: 10.w),
                child: SizedBox(
                  width: 70.w,
                  height: 70.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: _categoryImages.containsKey(category.title)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    _categoryImages[category.title]!,
                                    width: 60.w,
                                    height: 60.h,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : selectedSub != null
                              ? category.subEmotions
                                    .firstWhere((s) => s.title == selectedSub)
                                    .emojiBuilder(22.w, 22.h)
                              : category.emojiBuilder(22.w, 22.h),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploading
                              ? null
                              : () => _pickAndUploadImage(category.title),
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploading
                                ? Padding(
                                    padding: EdgeInsets.all(6.w),
                                    child:
                                        LoadingAnimationWidget.staggeredDotsWave(
                                          color: context.colors.tertiary,
                                          size: 18.w,
                                        ),
                                  )
                                : Icon(
                                    Icons.file_upload_outlined,
                                    size: 21.w,
                                    color: context.colors.tertiary,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -8.w,
                        right: -5.w,
                        child: _categoryImages.containsKey(category.title)
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _categoryImages.remove(category.title);
                                  });
                                },
                                child: Assets.icons.bin.svg(
                                  width: 30.w,
                                  height: 30.h,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Text(
                selectedSub != null
                    ? category.subEmotions
                          .firstWhere((s) => s.title == selectedSub)
                          .title
                    : category.title,
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),

          // ── Divider ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(height: 2.h, color: const Color(0xFFedcdde)),
              ),
              SizedBox(width: 5.w),
              Text(
                "Want to be more specific?",
                style: context.typography.body.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFFA30458),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Container(height: 2.h, color: const Color(0xFFedcdde)),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Sub-emotions grid ────────────────────────────────────────────
          ...List.generate((category.subEmotions.length / 3).ceil(), (
            rowIndex,
          ) {
            final start = rowIndex * 3;
            final end = (start + 3).clamp(0, category.subEmotions.length);
            final rowItems = category.subEmotions.sublist(start, end);

            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  for (int i = 0; i < rowItems.length; i++) ...[
                    if (i > 0) SizedBox(width: 10.w),
                    Expanded(
                      child: TypeofEmotions(
                        title: rowItems[i].title,
                        emoji: rowItems[i].emojiBuilder(16.w, 16.h),
                        isSelected: _isSubEmotionSelected(
                          category.title,
                          rowItems[i].title,
                        ),
                        onTap: () => _onSubEmotionTap(category, rowItems[i]),
                      ),
                    ),
                  ],
                  if (rowItems.length < 3)
                    for (int i = rowItems.length; i < 3; i++) ...[
                      SizedBox(width: 10.w),
                      Expanded(child: const SizedBox()),
                    ],
                ],
              ),
            );
          }),

          SizedBox(height: 10.h),

          // ── Upload hint ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 64.h,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFfefdf9),
              border: Border.all(color: const Color(0xFFcfcecc)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  color: const Color(0xFFa30558),
                  size: 23.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "Tap the upload icon to replace this emoji with your own image",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.subtitle.copyWith(
                      fontSize: 12.sp,
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ── Select Intensity button ──────────────────────────────────────
          MyButton(
            label: "Select Intensity",
            fontWeight: FontWeight.w500,
            textColor: context.colors.background,
            onPressed: () {
              IntensityDialogBox.show(
                context,
                leadingIcon: () {
                  return Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: _categoryImages.containsKey(category.title)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                _categoryImages[category.title]!,
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          : selectedSub != null
                          ? category.subEmotions
                                .firstWhere((s) => s.title == selectedSub)
                                .emojiBuilder(28.w, 28.h)
                          : category.emojiBuilder(28.w, 28.h),
                    ),
                  );
                }(),
                title: selectedSub != null
                    ? category.subEmotions
                          .firstWhere((s) => s.title == selectedSub)
                          .title
                    : category.title,
                subtitle: 'How intense is it?',
                onCancel: () => Navigator.pop(context),
                onConfirm: (selectedNumber) {
                  final SubEmotion? resolvedSub = selectedSub != null
                      ? category.subEmotions.firstWhere(
                          (s) => s.title == selectedSub,
                        )
                      : null;

                  setState(() {
                    // ✅ Remove this — don't deduplicate by category anymore:
                    // _selectedEmotions.removeWhere((e) => e.categoryTitle == category.title);

                    // Only add if under limit
                    if (_selectedEmotions.length < 3) {
                      _selectedEmotions.add(
                        SelectedEndDayReflectionEmotion(
                          categoryTitle: category.title,
                          key: resolvedSub?.key ?? category.key,
                          categoryColor: category.color,
                          categoryEmoji: category.emojiBuilder(28.w, 28.h),
                          subEmotionTitle: resolvedSub?.title ?? category.title,
                          subEmotionEmoji:
                              resolvedSub?.emojiBuilder(28.w, 28.h) ??
                              category.emojiBuilder(28.w, 28.h),
                          intensity: selectedNumber,
                          uploadedImageUrl: _categoryImages[category.title],
                        ),
                      );
                    }
                    _expandedCategory = null;
                  });

                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class EndDayNoteDialogBox extends StatelessWidget {
  const EndDayNoteDialogBox({
    super.key,
    required TextEditingController endDayNotesController,
  }) : _endDayNotesController = endDayNotesController;

  final TextEditingController _endDayNotesController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      height: 365.h,
      width: 327.w,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Text(
            "End of Day Reflection",
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontFamily: "sfpro",
              fontVariations: [FontVariation('wght', 600)],
            ),
          ),
          SizedBox(height: 20.h),
          MyTextField(
            controller: _endDayNotesController,
            hint: "Write here...",
            maxLines: 8,
            fillColor: context.colors.background,
            borderColor: context.colors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 20.h),
          MyButton(
            label: "Next",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class NumberCircle extends StatelessWidget {
  final int number;
  final bool isSelected; // New parameter
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
        // Change color based on selection
        backgroundColor: isSelected
            ? const Color(0xFFfbbf23)
            : const Color(0xFFF3F4F6),
        child: Text(
          "$number",
          style: context.typography.body.copyWith(
            // Change text color to white if selected
            color: isSelected ? Colors.white : const Color(0xFF6c7280),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class EndDayDialgoBox extends StatelessWidget {
  final String subtitle;
  final VoidCallback? onYes;
  final VoidCallback? onNo;
  const EndDayDialgoBox({
    super.key,
    required this.subtitle,
    this.onYes,
    this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175.h,
      width: 327.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "End of Day Reflection",
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 16.sp,
                fontFamily: "sfpro",
                fontVariations: [FontVariation('wght', 580)],
              ),
            ),
          ),
          Spacer(),
          Text(
            subtitle,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontFamily: "sfpro",
              fontVariations: [FontVariation('wght', 580)],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onYes,
                child: Container(
                  height: 56.h,
                  width: 140.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFdef9c8),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      "Yes",
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16.sp,
                        fontFamily: "sfpro",
                        fontVariations: [FontVariation('wght', 580)],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onNo,
                child: Container(
                  height: 56.h,
                  width: 140.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFfcd0c9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      "No",
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16.sp,
                        fontFamily: "sfpro",
                        fontVariations: [FontVariation('wght', 580)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class TypeofEmotions extends StatelessWidget {
  final String title;
  final Widget emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const TypeofEmotions({
    super.key,
    required this.title,
    required this.emoji,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(right: 6.w),
        width: 95.w,
        height: 39.w,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFf3e0f7) : const Color(0xFFFFF5EC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? context.colors.tertiary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            emoji,
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: context.typography.body.copyWith(
                  fontSize: Platform.isAndroid ? 12.sp : 11.5.sp,
                  color: isSelected
                      ? context.colors.tertiary
                      : const Color(0xFF6b5b8c),
                  fontVariations: const [FontVariation('wght', 500.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class EndDayReflectionDialog extends StatefulWidget {
//   final Function(int intensity)? onSubmit;

//   const EndDayReflectionDialog({super.key, this.onSubmit});

//   @override
//   State<EndDayReflectionDialog> createState() => _EndDayReflectionDialogState();
// }

// class _EndDayReflectionDialogState extends State<EndDayReflectionDialog> {
//   // Local state for the dialog
//   int _localIntensity = 3;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       height: 388.h, // Use .h for responsiveness
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: context.colors.background,
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               "End of Day Reflection",
//               style: context.typography.subtitle.copyWith(
//                 color: context.colors.textPrimary,
//                 fontSize: 20.sp,
//                 fontFamily: "sfpro",
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const Spacer(),
//           Text(
//             "How did it go?",
//             style: context.typography.subtitle.copyWith(
//               color: context.colors.textPrimary,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             "On a scale of 1 to 5, how did your day compare to the forecast?",
//             style: context.typography.subtitle.copyWith(
//               color: context.colors.textSecondary,
//               fontSize: 14.sp,
//             ),
//           ),
//           SizedBox(height: 20.h),

//           // Number Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: List.generate(5, (index) {
//               int currentNumber = index + 1;
//               return NumberCircle(
//                 number: currentNumber,
//                 isSelected: _localIntensity == currentNumber,
//                 onTap: () {
//                   setState(() {
//                     _localIntensity = currentNumber;
//                   });
//                 },
//               );
//             }),
//           ),

//           // Label Row (Much Worse ... Much Better)
//           SizedBox(height: 10.h),
//           _buildLabelRow(context),

//           SizedBox(height: 25.h),
//           MyButton(
//             label: "Continue",
//             onPressed: () {
//               // Pass the result back to the main screen
//               widget.onSubmit?.call(_localIntensity);
//               Navigator.pop(context, _localIntensity);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLabelRow(BuildContext context) {
//     final labels = ["Much Worse", "Worse", "Same", "Better", "Much Better"];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: labels
//           .map(
//             (label) => Text(
//               label,
//               style: context.typography.subtitle.copyWith(
//                 fontSize: 10.sp,
//                 color: context.colors.textSecondary,
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }
// }

class EndDayReflectionDialog extends StatefulWidget {
  final Function(int intensity)? onSubmit;

  const EndDayReflectionDialog({super.key, this.onSubmit});

  @override
  State<EndDayReflectionDialog> createState() => _EndDayReflectionDialogState();
}

class _EndDayReflectionDialogState extends State<EndDayReflectionDialog> {
  // Local state for the dialog
  int _localIntensity = 3;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How did it go?",
            style: context.typography.subtitle.copyWith(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              fontFamily: "sfpro",
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "On a scale of 1 to 5, how did your day compare to the forecast?",
            style: context.typography.subtitle.copyWith(
              color: context.colors.textSecondary,
              fontSize: 12.sp,
              fontFamily: "sfpro",
            ),
          ),
          SizedBox(height: 20.h),

          // Number Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              int currentNumber = index + 1;
              return NumberCircle(
                number: currentNumber,
                isSelected: _localIntensity == currentNumber,
                onTap: () {
                  setState(() {
                    _localIntensity = currentNumber;
                  });
                  widget.onSubmit?.call(currentNumber);
                },
              );
            }),
          ),

          // Label Row (Much Worse ... Much Better)
          SizedBox(height: 10.h),
          _buildLabelRow(context),
        ],
      ),
    );
  }

  Widget _buildLabelRow(BuildContext context) {
    final labels = ["Much Worse", "Worse", "Same", "Better", "Much Better"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Text(
              label,
              style: context.typography.subtitle.copyWith(
                fontSize: 10.sp,
                color: context.colors.textSecondary,
              ),
            ),
          )
          .toList(),
    );
  }
}

class EmotionsCard extends StatelessWidget {
  final String title;
  final Color color;
  final Widget emoji;
  final bool isExpanded;
  final VoidCallback onTap;

  const EmotionsCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 101.w,
        height: 89.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 17.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
          border: isExpanded
              ? Border.all(color: context.colors.tertiary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: context.colors.tertiary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            emoji,
            const Spacer(),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: context.typography.body.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class IntensityCircle extends StatelessWidget {
//   final int intensity;
//   final Widget centerWidget;
//   final String label;
//   final String? imageUrl;

//   const IntensityCircle({
//     super.key,
//     required this.intensity,
//     required this.centerWidget,
//     required this.label,
//     this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double progress = intensity.clamp(0, 5) / 5;
//     final double size = 65.r;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           width: size,
//           height: size,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: size,
//                 height: size,
//                 child: CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 7.w,
//                   backgroundColor: const Color(0xFFf1e2c5),
//                   valueColor: const AlwaysStoppedAnimation(Color(0xFF32683b)),
//                 ),
//               ),
//               Container(
//                 width: 56.r,
//                 height: 56.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: context.colors.background,
//                 ),
//                 child: Center(
//                   child: imageUrl != null
//                       ? ClipOval(
//                           child: Image.network(
//                             imageUrl!,
//                             width: 56.r,
//                             height: 56.r,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : centerWidget,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(width: 8.w),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 69.w,
//               child: Text(
//                 label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: context.typography.body.copyWith(
//                   color: context.colors.textPrimary,
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//             SizedBox(height: 5.h),
//             Text(
//               '$intensity/5',
//               style: context.typography.body.copyWith(
//                 color: const Color(0xFF399969),
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
