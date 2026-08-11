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
import 'package:kena_emotional_journey/model/emotions/result_emotion_model.dart'
    as result_models;
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_search_mixin.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/intensity_circle.dart';
import 'package:kena_emotional_journey/view/home/widgets/intensity_box.dart';
import 'package:kena_emotional_journey/view/profile/widgets/date_time_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class SelectedAspirationalEmotion {
  final String key;
  final String categoryTitle;
  final Color categoryColor;
  final Widget categoryEmoji;
  final String subEmotionTitle;
  final Widget subEmotionEmoji;
  final int intensity;
  final String? uploadedImageUrl;

  const SelectedAspirationalEmotion({
    required this.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.subEmotionTitle,
    required this.subEmotionEmoji,
    required this.intensity,
    this.uploadedImageUrl,
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AspirationalEmotions extends StatefulWidget {
  final bool isFromHome;
  const AspirationalEmotions({super.key, required this.isFromHome});

  @override
  State<AspirationalEmotions> createState() => _AspirationalEmotionsState();
}

class _AspirationalEmotionsState extends State<AspirationalEmotions>
    with EmotionSearchMixin {
  String? _expandedCategory;
  final Map<String, String> _selectedSubEmotions = {};
  final List<SelectedAspirationalEmotion> _selectedEmotions = [];
  @override
  final List<EmotionCategory> categories = EmotionsList().emotionCategories;
  final UserHomeService userHomeService = UserHomeService();
  List<result_models.AspirationEmotion> _aspirationEmotions = [];
  bool _isLoading = true;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  DateTime? reassessDate;
  bool _isSubmitting = false;
  bool _isUploading = false;
  final List<Map<String, String>> selectedActivities = [
    {
      'id': 'default',
      'name': 'Default Activity',
    }, // placeholder to satisfy backend
  ];

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

  Future<void> _pickAndUploadForIndex(int index) async {
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
        final old = _selectedEmotions[index];
        _selectedEmotions[index] = SelectedAspirationalEmotion(
          key: old.key,
          categoryTitle: old.categoryTitle,
          categoryColor: old.categoryColor,
          categoryEmoji: old.categoryEmoji,
          subEmotionTitle: old.subEmotionTitle,
          subEmotionEmoji: old.subEmotionEmoji,
          intensity: old.intensity,
          uploadedImageUrl: url,
        );
      }
    });
  }

  Future<void> _load() async {
    final result = await userHomeService.getUserEmotions(context: context);
    if (!mounted) return;

    final data = result?.data?.firstOrNull;
    setState(() {
      _aspirationEmotions = List<result_models.AspirationEmotion>.from(
        data?.aspirationEmotions ?? [],
      );
      _isLoading = false;

      // If we arrived here from non-home flow and server has saved aspirational emotions,
      // pre-populate the selected circles so they appear on screen load.
      if (!widget.isFromHome && _aspirationEmotions.isNotEmpty) {
        _selectedEmotions.clear();
        for (final aspirationEmotion in _aspirationEmotions) {
          final key = aspirationEmotion.key;
          if (key == null) continue;

          EmotionCategory? matchedCategory;
          SubEmotion? matchedSub;

          for (final cat in categories) {
            if (cat.key == key) {
              matchedCategory = cat;
              break;
            }
            for (final sub in cat.subEmotions) {
              if (sub.key == key) {
                matchedCategory = cat;
                matchedSub = sub;
                break;
              }
            }
            if (matchedCategory != null) break;
          }

          if (matchedCategory == null) continue;

          final resolvedSubTitle = matchedSub?.title ?? matchedCategory.title;
          final resolvedSubEmoji = matchedSub != null
              ? matchedSub.emojiBuilder(28.w, 28.h)
              : matchedCategory.emojiBuilder(28.w, 28.h);

          _selectedEmotions.add(
            SelectedAspirationalEmotion(
              key: key,
              categoryTitle: matchedCategory.title,
              categoryColor: matchedCategory.color,
              categoryEmoji: matchedCategory.emojiBuilder(28.w, 28.h),
              subEmotionTitle: resolvedSubTitle,
              subEmotionEmoji: resolvedSubEmoji,
              intensity: aspirationEmotion.intensity ?? 5,
              uploadedImageUrl: aspirationEmotion.imageUrl,
            ),
          );

          if (aspirationEmotion.imageUrl != null) {
            _categoryImages[matchedCategory.title] =
                aspirationEmotion.imageUrl!;
          }

          // keep sub-emotion selection state for expanded panel
          if (matchedSub != null) {
            _selectedSubEmotions[matchedCategory.title] = matchedSub.title;
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
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

  // Future<void> _submitEmotions() async {
  //   if (reassessDate == null) {
  //     context.flushBarErrorMessage(message: "Please select a reassess date");
  //     return;
  //   }

  //   if (_selectedEmotions.isEmpty) {
  //     context.flushBarErrorMessage(
  //       message: "Please select at least one emotion",
  //     );
  //     return;
  //   }

  //   final emotions = _selectedEmotions
  //       .map(
  //         (e) => {
  //           'key': e.key,
  //           'intensity': e.intensity,
  //           if (e.uploadedImageUrl != null) 'imageUrl': e.uploadedImageUrl,
  //         },
  //       )
  //       .toList();

  //   // final success = await userHomeService.addAspirationalEmotions(
  //   //   context: context,
  //   //   emotions: emotions,
  //   //   reassessDate: reassessDate!,
  //   // );
  //   final success = await userHomeService.addAspirationalEmotions(
  //     context: context,
  //     emotions: emotions,
  //     reassessDate: reassessDate,
  //     activities: selectedActivities
  //         .map((a) => {'id': a['id'], 'name': a['name']})
  //         .toList(),
  //   );

  //   if (success && mounted) {
  //     Navigator.of(
  //       context,
  //     ).pushNamedAndRemoveUntil(RoutesName.onboardingScreen, (route) => false);
  //   }
  // }
  Future<void> _submitEmotions() async {
    if (_selectedEmotions.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

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

    bool success = false;
    try {
      success = await userHomeService.addAspirationalEmotions(
        context: context,
        emotions: emotions,
        reassessDate: reassessDate,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (success && mounted) {
      if (!widget.isFromHome) {
        Navigator.of(context).pop();
      } else {
        Navigator.pushReplacementNamed(
          context,
          RoutesName.chooseActivity,
          arguments: {
            'isToday': false,
            'isFromForecast': false,
            'navigateToSummaryAfterSave': true,
          },
        );
      }
      context.flushBarSuccessMessage(message: "Emotions added successfully");
    }
  }

  bool _isSubEmotionSelected(String categoryTitle, String subTitle) {
    return _selectedSubEmotions[categoryTitle] == subTitle;
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
    if (!widget.isFromHome && _isLoading) {
      return MyScaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
          child: Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: context.colors.primary,
              size: 50.w,
            ),
          ),
        ),
      );
    }

    final row1 = categories.sublist(0, 3);
    final row2 = categories.sublist(3, 6);

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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(color: context.colors.textPrimary),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (scaffoldContext) => GestureDetector(
                          onTap: () =>
                              Scaffold.of(scaffoldContext).openEndDrawer(),
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
                ],
              ),
              SizedBox(height: 20.h),

              // ── Title ────────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  text: "Select your",
                  style: context.typography.title.copyWith(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: " aspirational emotions",
                      style: context.typography.title.copyWith(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFd106a5),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Select 1-3 by searching or tapping an option below",
                textAlign: TextAlign.left,
                style: context.typography.subtitle.copyWith(
                  fontSize: 14.sp,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),

              // ── Search ───────────────────────────────────────────────────
              MyTextField(
                controller: searchController,
                hint: "Search by emotion name / body sensation",
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFebebeb),
                              ),
                            ),
                            // ── Wrap: circles flow to next line if needed ──
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedEmotions.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 👈 Always 2 per row
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio:
                                        1.8, // 👈 Adjust for width/height
                                  ),
                              itemBuilder: (context, index) {
                                final e = _selectedEmotions[index];
                                return IntensityCircle(
                                  intensity: e.intensity,
                                  centerWidget: e.subEmotionEmoji,
                                  label: e.subEmotionTitle,
                                  imageUrl: e.uploadedImageUrl,
                                  onUpload: () => _pickAndUploadForIndex(index),
                                  onRemove: () => setState(
                                    () => _selectedEmotions.removeAt(index),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "When do you want to reassess?",
                            style: context.typography.body.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'sfpro',
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          DateTimeField(
                            onDateSelected: (date) {
                              reassessDate = date;
                            },
                          ),
                        ],
                      ),
              ),

              SizedBox(height: 20.h),

              // ── Info row ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.colors.textSecondary,
                    size: 20.w,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "What are aspirational emotions?",
                    style: context.typography.subtitle.copyWith(
                      fontSize: 16.sp,
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // ── Info box ─────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFfefdf9),
                  border: Border.all(color: const Color(0xFFc0bfbd)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "These are your emotional goals. E.g. reduce intensity of some core emotions or foster some positive emotions. These goals help you curate your activities later on.",
                  textAlign: TextAlign.left,
                  style: context.typography.subtitle.copyWith(
                    fontSize: 12.sp,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ── Continue button ───────────────────────────────────────────
              if (_selectedEmotions.isNotEmpty && !_isPanelOpen) ...[
                SizedBox(height: 10.h),
                MyButton(
                  label: "Continue",
                  onPressed: _submitEmotions,
                  isLoading: _isSubmitting,
                  textColor: context.colors.background,
                ),
              ],
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
                                          color: const Color(0xFFa30558),
                                          size: 18.w,
                                        ),
                                  )
                                : Icon(
                                    Icons.file_upload_outlined,
                                    size: 21.w,
                                    color: const Color(0xFFa30558),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5.w,
                        right: 0.w,
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
                        SelectedAspirationalEmotion(
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
            color: isSelected ? context.colors.primary : Colors.transparent,
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
                      ? context.colors.primary
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
              ? Border.all(color: context.colors.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.15),
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
            Text(
              title,
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
