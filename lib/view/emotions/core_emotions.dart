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
import 'package:kena_emotional_journey/app/utils/tour_controller.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/emotions/emotion_category.dart';
import 'package:kena_emotional_journey/model/emotions/emotions_list.dart';
import 'package:kena_emotional_journey/model/emotions/result_emotion_model.dart'
    as result_models;
import 'package:kena_emotional_journey/model/tour_section/tour_content.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_search_mixin.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/intensity_circle.dart';
import 'package:kena_emotional_journey/view/home/widgets/intensity_box.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class SelectedCoreEmotion {
  final String key;
  final String categoryTitle;
  final Color categoryColor;
  final Widget categoryEmoji;
  final String subEmotionTitle;
  final Widget subEmotionEmoji;
  final int intensity;
  final String? uploadedImageUrl;

  const SelectedCoreEmotion({
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
class CoreEmotions extends StatefulWidget {
  final bool isFromHome;

  const CoreEmotions({super.key, required this.isFromHome});

  @override
  State<CoreEmotions> createState() => _CoreEmotionsState();
}

class _CoreEmotionsState extends State<CoreEmotions> with EmotionSearchMixin {
  String? _expandedCategory;
  final Map<String, String> _selectedSubEmotions = {};
  final List<SelectedCoreEmotion> _selectedEmotions = [];
  @override
  final List<EmotionCategory> categories = EmotionsList().emotionCategories;
  final UserHomeService userHomeService = UserHomeService();
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey uploadKey = GlobalKey();
  final GlobalKey emotionGridKey = GlobalKey();
  List<result_models.CoreEmotion> _coreEmotions = [];
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  bool _isLoading = true;
  bool _isSubmitting = false;
  TourHandle? _tourHandle;

  /// Tracks uploaded image URLs per category title
  final Map<String, String> _categoryImages = {};
  bool _isUploading = false;

  /// True while the expanded panel is open — hides circles during selection
  bool get _isPanelOpen => _expandedCategory != null;

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
        _selectedEmotions[index] = SelectedCoreEmotion(
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
      _coreEmotions = List<result_models.CoreEmotion>.from(
        data?.coreEmotions ?? [],
      );
      _isLoading = false;

      // If we arrived here from non-home flow and server has saved core emotions,
      // pre-populate the selected circles so they appear on screen load.
      if (!widget.isFromHome &&
          data?.coreEmotions != null &&
          data!.coreEmotions!.isNotEmpty) {
        _selectedEmotions.clear();
        for (final ce in data.coreEmotions!) {
          final key = ce.key;
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

          // Backend sends "" (not null) when no image was uploaded.
          final sanitizedImageUrl = (ce.imageUrl?.isNotEmpty ?? false)
              ? ce.imageUrl
              : null;

          _selectedEmotions.add(
            SelectedCoreEmotion(
              key: key,
              categoryTitle: matchedCategory.title,
              categoryColor: matchedCategory.color,
              categoryEmoji: matchedCategory.emojiBuilder(28.w, 28.h),
              subEmotionTitle: resolvedSubTitle,
              subEmotionEmoji: resolvedSubEmoji,
              intensity: ce.intensity ?? 5,
              uploadedImageUrl: sanitizedImageUrl,
            ),
          );

          if (sanitizedImageUrl != null) {
            _categoryImages[matchedCategory.title] = sanitizedImageUrl;
          }

          // keep sub-emotion selection state for expanded panel
          if (matchedSub != null) {
            _selectedSubEmotions[matchedCategory.title] = matchedSub.title;
          }
        }
      }
    });

    // Start the tour after the UI has built with the loaded data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tourHandle = TourController.start(
        context: context,
        sectionKey: TourSections.emotionTracking,
        targetKeys: [searchKey, emotionGridKey, uploadKey],
        onStepChanged: (index) {
          if (index == 2) {
            setState(() {
              if (categories.isNotEmpty) {
                _expandedCategory = categories.first.title;
              }
            });
          } else {
            setState(() {
              _expandedCategory = null;
            });
          }
        },
        onComplete: () {
          setState(() {
            _expandedCategory = null;
          });
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tourHandle?.cancel();
    super.dispose();
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
      // Clear the uploaded image when selecting any sub-emotion
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

    final success = await userHomeService.addCoreEmotions(
      context: context,
      emotions: emotions,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      if (widget.isFromHome) {
        Navigator.of(context).pushReplacementNamed(
          RoutesName.aspirationalEmotions,
          arguments: {'isFromHome': widget.isFromHome},
        );
      } else {
        // final result = await Navigator.pushNamed(
        //   context,
        //   RoutesName.chooseActivity,
        //   arguments: {'isToday': false},
        // );
        // Only pop ourselves if activities saved successfully and in a safe microtask.
        // if (result == true) {
        Future.microtask(() {
          if (mounted) Navigator.pop(context);
        });
        // }
      }
    }
  }

  bool _isSubEmotionSelected(String categoryTitle, String subTitle) {
    return _selectedSubEmotions[categoryTitle] == subTitle;
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
    // If we're opened from the non-home flow, block UI until server data loads
    // so pre-selected intensity circles render immediately after load.
    if (!widget.isFromHome && _isLoading) {
      return MyScaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Row(
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
                      // GestureDetector(
                      //   onTap: () =>
                      //       Navigator.of(context).pushNamedAndRemoveUntil(
                      //         RoutesName.homeScreen,
                      //         (route) => false,
                      //       ),
                      //   child: Assets.icons.homeIcon.svg(
                      //     width: 40.w,
                      //     height: 40.h,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── Title ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                "Select your current core emotions",
                style: context.typography.title.copyWith(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                "Select 1-3 emotions below by searching or tapping a section below for more options",
                textAlign: TextAlign.left,
                style: context.typography.subtitle.copyWith(
                  fontSize: 14.sp,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Search ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: MyTextField(
                controller: searchController,
                key: searchKey,
                hint: "Search by emotion name / body sensation",
                borderColor: const Color(0xFFd0d0d0),
                fillColor: Colors.transparent,
                hintColor: context.colors.textPrimary,
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 15.h),

            // ── Search results ───────────────────────────────────────────
            if (searchQuery.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: buildSearchResults(),
              )
            else ...[
              // ── Emotion grid (both rows) ──────────────────────────────────
              Padding(
                key: emotionGridKey,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                child: Column(
                  children: [
                    // ── Row 1 ──────────────────────────────────────────────────
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
                    SizedBox(height: 15.h),

                    // ── Row 2 ──────────────────────────────────────────────────
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
                ),
              ),
            ],

            // ── Expanded panel ───────────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expandedCategory != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: _buildExpandedPanel(
                        context,
                        categories.firstWhere(
                          (c) => c.title == _expandedCategory,
                        ),
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
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
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
                            // child: Wrap(
                            //   spacing: 32.w,
                            //   runSpacing: 20.h,
                            //   children: _selectedEmotions
                            //       .map(
                            //         (e) => IntensityCircle(
                            //           intensity: e.intensity,
                            //           centerWidget: e.subEmotionEmoji,
                            //           label: e.subEmotionTitle,
                            //           imageUrl: e.uploadedImageUrl,
                            //         ),
                            //       )
                            //       .toList(),
                            // ),
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
                        ],
                      ),
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
                  "What are core emotions?",
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFfefdf9),
                  border: Border.all(color: const Color(0xFFc0bfbd)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "These are those feelings that hang around for a bit, like feeling super down or sad after losing something important or totally pumped and confident from a big win. They don't vanish quick—they linger, and we usually have to step-up to handle them",
                  textAlign: TextAlign.left,
                  style: context.typography.subtitle.copyWith(
                    fontSize: 12.sp,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // ── Continue button ───────────────────────────────────────────
            if (_selectedEmotions.isNotEmpty && !_isPanelOpen) ...[
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: MyButton(
                  label: "Continue",
                  onPressed: _submitEmotions,
                  isLoading: _isSubmitting,
                  textColor: context.colors.background,
                ),
              ),
            ],
          ],
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
                          key: uploadKey,
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
              // SizedBox(width: 5.w),
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
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
                    if (_selectedEmotions.length < 3) {
                      _selectedEmotions.add(
                        SelectedCoreEmotion(
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
