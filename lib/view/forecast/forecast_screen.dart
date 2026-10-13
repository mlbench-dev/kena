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
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/model/tour_section/tour_content.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_search_mixin.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/intensity_circle.dart';
import 'package:kena_emotional_journey/view/home/widgets/intensity_box.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class SelectedForecastEmotion {
  final String key;
  final String categoryTitle;
  final Color categoryColor;
  final Widget categoryEmoji;
  final String subEmotionTitle;
  final Widget subEmotionEmoji;
  final int intensity;
  final String? uploadedImageUrl;

  const SelectedForecastEmotion({
    required this.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryEmoji,
    required this.subEmotionTitle,
    required this.subEmotionEmoji,
    required this.intensity,
    this.uploadedImageUrl,
  });

  SelectedForecastEmotion copyWith({
    String? key,
    String? categoryTitle,
    Color? categoryColor,
    Widget? categoryEmoji,
    String? subEmotionTitle,
    Widget? subEmotionEmoji,
    int? intensity,
    String? uploadedImageUrl,
  }) {
    return SelectedForecastEmotion(
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
class ForecastScreen extends StatefulWidget {
  final Forecast? forecast;
  final bool isFromHome;
  const ForecastScreen({super.key, this.forecast, required this.isFromHome});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen>
    with EmotionSearchMixin {
  String? _expandedCategory;
  final Map<String, String> _selectedSubEmotions = {};
  final List<SelectedForecastEmotion> _selectedEmotions = [];
  @override
  final List<EmotionCategory> categories = EmotionsList().emotionCategories;
  final UserHomeService userHomeService = UserHomeService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  TourHandle? _tourHandle;
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey emotionGridKey = GlobalKey();
  final GlobalKey uploadKey = GlobalKey();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? reassessDate;
  bool _isUploading = false;
  bool _isSubmitting = false;

  /// The forecast to edit — from widget prop OR from route arguments.
  /// Null when creating a brand-new forecast.
  Forecast? _resolvedForecast;

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

  void _prefillData(Forecast forecast) {
    // _planController.text = forecast.plan ?? '';
    // _notesController.text = forecast.notes ?? '';

    for (var e in forecast.emotions ?? []) {
      EmotionCategory? category;
      SubEmotion? subEmotion;

      // First try to match as category key
      try {
        category = categories.firstWhere((cat) => cat.key == e.key);
      } catch (_) {
        category = null;
      }

      // If no category match, search through sub-emotions
      if (category == null) {
        for (final cat in categories) {
          try {
            subEmotion = cat.subEmotions.firstWhere((sub) => sub.key == e.key);
            category = cat;
            break;
          } catch (_) {
            continue;
          }
        }
      }

      // Fallback to first category if still null
      category ??= categories.first;

      _selectedEmotions.add(
        SelectedForecastEmotion(
          key: e.key ?? '',
          categoryTitle: category.title,
          categoryColor: category.color,
          categoryEmoji: category.emojiBuilder(28.w, 28.h),
          subEmotionTitle: subEmotion?.title ?? category.title,
          subEmotionEmoji:
              subEmotion?.emojiBuilder(28.w, 28.h) ??
              category.emojiBuilder(28.w, 28.h),
          intensity: e.intensity ?? 1,
          // Backend sends "" (not null) when no image was uploaded.
          uploadedImageUrl: (e.imageUrl?.isNotEmpty ?? false)
              ? e.imageUrl
              : null,
        ),
      );
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tourHandle = TourController.start(
        context: context,
        sectionKey: TourSections.forecast,
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
  void dispose() {
    _tourHandle?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    final forecast = args is Map && args['forecast'] is Forecast
        ? args['forecast'] as Forecast
        : widget.forecast;

    if (forecast != null && _selectedEmotions.isEmpty) {
      _resolvedForecast = forecast;
      _prefillData(forecast);
    }
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

    final isUpdate = _resolvedForecast != null;
    debugPrint(
      '[ForecastScreen] Submitting — isUpdate: $isUpdate, emotions: ${emotions.length}',
    );

    final success = isUpdate
        ? await userHomeService.updateForecast(
            context: context,
            data: {
              "emotions": emotions,
              "plan": _planController.text,
              "notes": _notesController.text,
            },
          )
        : await userHomeService.forecast(
            context: context,
            emotions: emotions,
            plan: _planController.text,
            notes: _notesController.text,
          );

    debugPrint('[ForecastScreen] API result — success: $success');

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      if (widget.isFromHome) {
        Navigator.of(context).pushReplacementNamed(
          RoutesName.planAndActivities,
          // arguments: {'isToday': false},
        );
      } else {
        Navigator.of(context).pop();
      }
    } else {
      context.flushBarErrorMessage(
        message: isUpdate
            ? 'Failed to update forecast. Please try again.'
            : 'Failed to save forecast. Please try again.',
      );
    }
  }

  bool _isSubEmotionSelected(String categoryTitle, String subTitle) {
    return _selectedSubEmotions[categoryTitle] == subTitle;
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
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
          DrawerMenuItem(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: 'Logout',
            isDisabled: actions.isAnyLoading,
            onTap: () => AuthService.logout(context),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(color: context.colors.textPrimary),
                  Text(
                    "Forecast Your Emotions",
                    style: context.typography.title.copyWith(
                      color: context.colors.textPrimary,
                      fontFamily: 'sfpro',
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
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
              ),
            ),
            SizedBox(height: 20.h),

            // ── Title ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "How do you expect to feel today?",
                style: context.typography.title.copyWith(
                  color: context.colors.textPrimary,
                  fontFamily: 'sfpro',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                key: searchKey,
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
            ),
            SizedBox(height: 15.h),

            // ── Search results ───────────────────────────────────────────
            if (searchQuery.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: buildSearchResults(),
              )
            else ...[
              // ── Emotion grid — row 1 ─────────────────────────────────────
              Padding(
                key: emotionGridKey,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                child: Column(
                  children: [
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

              // ── Emotion grid — row 2 ─────────────────────────────────────
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
                                return GestureDetector(
                                  onTap: () {
                                    IntensityDialogBox.show(
                                      context,
                                      leadingIcon: () {
                                        return Container(
                                          width: 60.w,
                                          height: 60.h,
                                          decoration: BoxDecoration(
                                            color: e.categoryColor,
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                          ),
                                          child: Center(
                                            child:
                                                (e
                                                        .uploadedImageUrl
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10.r,
                                                        ),
                                                    child: Image.network(
                                                      e.uploadedImageUrl!,
                                                      width: 60.w,
                                                      height: 60.h,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : e.subEmotionEmoji,
                                          ),
                                        );
                                      }(),
                                      title: e.subEmotionTitle,
                                      subtitle: 'How intense is it?',
                                      onCancel: () => Navigator.pop(context),
                                      onConfirm: (newValue) {
                                        setState(() {
                                          _selectedEmotions[index] =
                                              _selectedEmotions[index].copyWith(
                                                intensity: newValue,
                                              );
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  child: IntensityCircle(
                                    intensity: e.intensity,
                                    centerWidget: e.subEmotionEmoji,
                                    label: e.subEmotionTitle,
                                    imageUrl: e.uploadedImageUrl,

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
                                              _selectedEmotions[index].copyWith(
                                                uploadedImageUrl: url,
                                              );
                                        }
                                      });
                                    },

                                    onRemove: () {
                                      final emotion = e;

                                      setState(() {
                                        _selectedEmotions.remove(emotion);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),

                          ///
                          /// Start Phase 2
                          ///
                          // SizedBox(height: 10.h),
                          // Text(
                          //   "Proactive emotions plan",
                          //   style: context.typography.body.copyWith(
                          //     color: context.colors.textPrimary,
                          //     fontVariations: [
                          //       const FontVariation("wght", 510),
                          //     ],
                          //     fontFamily: 'sfpro',
                          //   ),
                          // ),
                          // SizedBox(height: 5.h),
                          // Text(
                          //   "How do you plan to tackle the day’s emotional forecast? Think umbrella for rain or hat for sunny day.",
                          //   style: context.typography.subtitle.copyWith(
                          //     color: context.colors.textSecondary,
                          //     fontSize: 14.sp,
                          //     fontFamily: 'sfpro',
                          //   ),
                          // ),
                          // SizedBox(height: 5.h),
                          // MyTextField(
                          //   textCapitalization: TextCapitalization.none,
                          //   controller: _planController,
                          //   hint: "Write your plan here...",
                          //   maxLines: 4,
                          //   fillColor: context.colors.background,
                          //   borderColor: context.colors.textSecondary
                          //       .withOpacity(0.4),
                          // ),
                          // SizedBox(height: 20.h),
                          // Text(
                          //   "Notes of the day",
                          //   style: context.typography.body.copyWith(
                          //     color: context.colors.textPrimary,
                          //     fontVariations: [
                          //       const FontVariation("wght", 510),
                          //     ],
                          //     fontFamily: 'sfpro',
                          //   ),
                          // ),
                          // SizedBox(height: 5.h),
                          // MyTextField(
                          //   textCapitalization: TextCapitalization.none,
                          //   controller: _notesController,
                          //   hint:
                          //       "Write one sentence about your day or feelings....",
                          //   maxLines: 4,
                          //   fillColor: context.colors.background,
                          //   borderColor: context.colors.textSecondary
                          //       .withOpacity(0.4),
                          // ),
                          ///
                          /// End Phase 2
                          ///
                          // Text(
                          //   "When do you want to reassess?",
                          //   style: context.typography.body.copyWith(
                          //     color: context.colors.textPrimary,
                          //     fontWeight: FontWeight.w600,
                          //     fontFamily: 'sfpro',
                          //     fontSize: 14.sp,
                          //   ),
                          // ),
                          // SizedBox(height: 10.h),
                          // DateTimeField(
                          //   onDateSelected: (date) {
                          //     reassessDate = date;
                          //   },
                          // ),
                        ],
                      ),
                    ),
            ),

            SizedBox(height: 20.h),

            // // ── Info row ─────────────────────────────────────────────────
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Icon(
            //       Icons.info_outline,
            //       color: context.colors.textSecondary,
            //       size: 20.w,
            //     ),
            //     SizedBox(width: 5.w),
            //     Text(
            //       "What are aspirational emotions?",
            //       style: context.typography.subtitle.copyWith(
            //         fontSize: 16.sp,
            //         color: context.colors.textSecondary,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 20.h),

            // // ── Info box ─────────────────────────────────────────────────
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.all(10.w),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFfefdf9),
            //     border: Border.all(color: const Color(0xFFc0bfbd)),
            //     borderRadius: BorderRadius.circular(10.r),
            //   ),
            //   child: Text(
            //     "These are those feelings that hang around for a bit, like feeling super down or sad after losing something important or totally pumped and confident from a big win. They don't vanish quick—they linger, and we usually have to step-up to handle them",
            //     textAlign: TextAlign.left,
            //     style: context.typography.subtitle.copyWith(
            //       fontSize: 12.sp,
            //       color: context.colors.textSecondary,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),

            // ── Continue button ───────────────────────────────────────────
            if (_selectedEmotions.isNotEmpty && !_isPanelOpen) ...[
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: MyButton(
                  label: "Save",
                  onPressed: _isSubmitting ? null : _submitEmotions,
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
                  key: uploadKey,
                  width: 78.w,
                  height: 78.h,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
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
                          bottom: -8,
                          right: -8,
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
                          right: -8.w,
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
                        SelectedForecastEmotion(
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

// class IntensityCircle extends StatelessWidget {
//   final int intensity;
//   final Widget centerWidget;
//   final String label;
//   final String? imageUrl;
//   final VoidCallback? onUpload;
//   final VoidCallback? onRemove;

//   const IntensityCircle({
//     super.key,
//     required this.intensity,
//     required this.centerWidget,
//     required this.label,
//     this.imageUrl,
//     this.onUpload,
//     this.onRemove,
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
//             // CRITICAL FIX: This stops Flutter from cutting off your elements
//             clipBehavior: Clip.none,
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
//               // Upload Button
//               if (onUpload != null)
//                 Positioned(
//                   bottom: -2.r, // Fine-tuned positioning
//                   right: -2.r,
//                   child: GestureDetector(
//                     onTap: onUpload,
//                     child: Container(
//                       width: 24.r,
//                       height: 24.r,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 Colors.black12, // Softer shadow looks cleaner
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.file_upload_outlined,
//                         size: 14.r,
//                         color: const Color(0xFFa30558),
//                       ),
//                     ),
//                   ),
//                 ),
//               // Edit Button
//               if (onUpload != null)
//                 Positioned(
//                   top: -6.r, // Fine-tuned positioning
//                   left: -2.r,
//                   child: GestureDetector(
//                     onTap: onRemove,
//                     child: Container(
//                       width: 24.r,
//                       height: 24.r,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.remove,
//                         size: 14.r,
//                         color: const Color(0xFFa30558),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         SizedBox(
//           width: 12.w,
//         ), // Increased slightly so text doesn't overlap the buttons
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: context.typography.body.copyWith(
//                 color: context.colors.textPrimary,
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w400,
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
