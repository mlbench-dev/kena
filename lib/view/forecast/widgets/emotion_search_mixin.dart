import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/model/emotions/emotion_category.dart';
import 'package:kena_emotional_journey/model/emotions/search_library.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/components/premium_dialog.dart';
import 'package:kena_emotional_journey/app/components/premium_lock.dart';
import 'package:kena_emotional_journey/app/utils/premium_features.dart';
import 'package:kena_emotional_journey/provider/subscription_provider.dart';
import 'package:provider/provider.dart';

/// Reusable search logic for emotion selection screens
/// Use this mixin to add search functionality to emotion selection screens
mixin EmotionSearchMixin<T extends StatefulWidget> on State<T> {
  /// Search controller
  late final TextEditingController searchController = TextEditingController();

  /// Current search query
  String searchQuery = '';

  /// All emotion categories (must be provided by the implementing class)
  List<EmotionCategory> get categories;

  /// Currently selected emotions (must be provided by the implementing class)
  List get selectedEmotions;

  /// Maximum number of emotions that can be selected
  int get maxEmotions => 3;

  /// Map of selected sub-emotions (must be provided by the implementing class)
  Map<String, String> get selectedSubEmotions;

  /// Map of category images (must be provided by the implementing class)
  Map<String, String> get categoryImages;

  /// Callback to expand a category (must be provided by the implementing class)
  void Function(String) get onCategoryExpand;

  /// Callback to select a sub-emotion (must be provided by the implementing class)
  void Function(EmotionCategory, dynamic) get onSubEmotionSelect;

  /// Callback to show error message (optional, defaults to flushBarErrorMessage)
  void showError(String message) {
    context.flushBarErrorMessage(message: message);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ─── Result model ───────────────────────────────────────────────────────────

  /// Internal result type carrying extra metadata for rendering
  static const String _directMatch = 'direct';
  static const String _keywordMatch = 'keyword';

  /// Body sensation / keyword search is Premium-only; name search is free.
  bool get canSearchBySensation => context
      .read<SubscriptionProvider>()
      .canUse(PremiumFeature.bodySensationSearch);

  /// Hint for the search field, matching what the user's plan can search.
  String get searchHint => canSearchBySensation
      ? "Search by emotion name / body sensation"
      : "Search by emotion name";

  /// Returns merged, deduplicated search results from:
  ///  1. Direct name matches against sub-emotion titles
  ///  2. Keyword matches from [emotionSearchLibrary] → resolved to sub-emotions
  ///     (only when [includeKeywordMatches] is true)
  List<Map<String, dynamic>> getFilteredSubEmotions({
    bool includeKeywordMatches = true,
  }) {
    if (searchQuery.isEmpty) return [];

    final seen = <String>{}; // tracks "categoryTitle|subKey" pairs
    final results = <Map<String, dynamic>>[];

    // ── 1. Direct name matches ──────────────────────────────────────────────
    for (final category in categories) {
      for (final sub in category.subEmotions) {
        final id = '${category.title}|${sub.key}';
        if (sub.title.toLowerCase().contains(searchQuery) && seen.add(id)) {
          results.add({
            'category': category,
            'subEmotion': sub,
            'matchType': _directMatch,
            'matchedKeyword': null,
          });
        }
      }
    }

    if (!includeKeywordMatches) return results;

    // ── 2. Keyword matches from the search library ──────────────────────────
    for (final item in emotionSearchLibrary) {
      final matchedKeyword = item.keywords.firstWhere(
        (kw) =>
            kw.toLowerCase().contains(searchQuery) ||
            searchQuery.contains(kw.toLowerCase()),
        orElse: () => '',
      );
      if (matchedKeyword.isEmpty) continue;

      // Resolve the mainEmotion key to the actual SubEmotion in categories
      for (final category in categories) {
        final sub = category.subEmotions
            .where((s) => s.key == item.mainEmotion)
            .firstOrNull;
        if (sub == null) continue;

        final id = '${category.title}|${sub.key}';
        if (seen.add(id)) {
          results.add({
            'category': category,
            'subEmotion': sub,
            'matchType': _keywordMatch,
            'matchedKeyword': matchedKeyword,
          });
        }
        break;
      }
    }

    return results;
  }

  /// Handle tap on a searched emotion
  void onSearchedEmotionTap(EmotionCategory category, dynamic sub) {
    if (selectedEmotions.length >= maxEmotions) {
      showError("You can select up to $maxEmotions emotions only");
      return;
    }
    setState(() {
      onCategoryExpand(category.title);
      onSubEmotionSelect(category, sub);
      categoryImages.remove(category.title);
      searchController.clear();
      searchQuery = '';
    });
  }

  /// Build the search results widget
  Widget buildSearchResults() {
    if (searchQuery.isEmpty) return const SizedBox.shrink();

    final canSearchSensation = canSearchBySensation;
    final filtered = getFilteredSubEmotions(
      includeKeywordMatches: canSearchSensation,
    );
    // Body-sensation matches a Freemium user would have seen with Premium.
    final lockedMatches = canSearchSensation
        ? 0
        : getFilteredSubEmotions().length - filtered.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Search Results",
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        ...filtered.map((result) {
          final category = result['category'] as EmotionCategory;
          final sub = result['subEmotion'];
          final isKeyword = result['matchType'] == _keywordMatch;
          final matchedKeyword = result['matchedKeyword'] as String?;

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: GestureDetector(
              onTap: () => onSearchedEmotionTap(category, sub),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F4),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    sub.emojiBuilder(20.w, 20.h),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sub.title,
                            style: context.typography.body.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (isKeyword && matchedKeyword != null) ...[
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                matchedKeyword,
                                style: context.typography.bodySmall.copyWith(
                                  color: context.colors.primary,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      category.title,
                      style: context.typography.body.copyWith(
                        color: context.colors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        if (lockedMatches > 0) _buildLockedSensationMatches(lockedMatches),
        if (filtered.isEmpty && lockedMatches == 0)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              "No emotions found",
              style: context.typography.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLockedSensationMatches(int count) {
    return GestureDetector(
      onTap: () => PremiumDialog.show(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            const PremiumBadgeIcon(size: 18),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                count == 1
                    ? "1 more match by body sensation"
                    : "$count more matches by body sensation",
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            Text(
              "Premium",
              style: context.typography.body.copyWith(
                color: context.colors.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
