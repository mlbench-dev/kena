import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/native_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/community/daily_feed_model.dart';
import 'package:kena_emotional_journey/model/emotions/emotions_list.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/community/comments_screen.dart';
import 'package:kena_emotional_journey/view/community/empty_feed_screen.dart';
import 'package:kena_emotional_journey/view/community/widgets/feed_shimmer_loading.dart';
import 'package:kena_emotional_journey/view/emotions/widgets/image_zoom_viewer.dart'
    show ImageZoomViewer;
import 'package:kena_emotional_journey/view/forecast/forecast_result_screen.dart'
    show InviteFriendsDialog;
import 'package:like_button/like_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

String _formatDate(String? iso) {
  if (iso == null) return '';
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('h:mm a · MMM d').format(dt);
  } catch (_) {
    return iso;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DAILY FEEDS SCREEN
// (owns loading/error/empty states + the list of daily feed cards)
// ─────────────────────────────────────────────────────────────────────────────

class DailyFeedsScreen extends StatefulWidget {
  final String communityId;
  final String communityName;
  final String feedScope;
  final bool isStopSharing;
  const DailyFeedsScreen({
    super.key,
    required this.communityId,
    required this.communityName,
    required this.feedScope,
    required this.isStopSharing,
  });

  @override
  State<DailyFeedsScreen> createState() => DailyFeedsScreenState();
}

class DailyFeedsScreenState extends State<DailyFeedsScreen> {
  final _service = UserHomeService();
  List<DailyFeedData> _feeds = [];
  bool _isLoading = true;
  String? _error;
  bool _isStoppingAll = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadFeed();
  }

  @override
  void didUpdateWidget(DailyFeedsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feedScope != widget.feedScope) {
      _init();
    }
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final scope = widget.feedScope.toLowerCase() == 'friends'
          ? 'friends'
          : 'me';
      final result = await _service.getDailyFeed(
        communityId: widget.communityId,
        scope: scope,
        context: context,
      );
      if (mounted) {
        setState(() {
          _feeds = result?.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Exposed so a parent (e.g. pull-to-refresh on the outer screen) can
  /// trigger a reload if needed.
  Future<void> refresh() => _init();

  /// Insert one native ad after every 8 feed cards (not after the last one).
  static const int _nativeAdInterval = 8;

  int _slotCountWithAds(int feedCount) {
    if (feedCount == 0) return 0;
    return feedCount + (feedCount - 1) ~/ _nativeAdInterval;
  }

  bool _isNativeAdSlot(int slotIndex) =>
      slotIndex != 0 && (slotIndex + 1) % (_nativeAdInterval + 1) == 0;

  int _feedIndexForSlot(int slotIndex) =>
      slotIndex - slotIndex ~/ (_nativeAdInterval + 1);

  Future<void> _stopSharingWithAll() async {
    final sharedResult = await _service.getSharedMembers(context: context);
    if (!mounted) return;

    final userIds =
        sharedResult?.data?.map((m) => m.id).whereType<String>().toList() ?? [];
    if (userIds.isEmpty) return;

    setState(() => _isStoppingAll = true);

    final success = await _service.stopSharingForecast(
      userIds: userIds,
      context: context,
    );

    if (!mounted) return;
    setState(() => _isStoppingAll = false);
    if (!success) return;

    context.flushBarSuccessMessage(message: 'Stopped sharing with everyone');
    await _init();
  }

  Future<void> _onStartSharing() async {
    await MyDialogBox.show(
      context,
      child: InviteFriendsDialog(parentContext: context),
    );
    await _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedScope.toLowerCase() == 'friends' &&
        _feeds.isEmpty &&
        !_isLoading) {
      return EmptyFeedScreen(isStopSharing: false);
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        slivers: [
          if (_isLoading)
            const SliverToBoxAdapter(child: FeedsShimmer())
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 48.sp,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Couldn't load feed",
                      style: context.typography.headline.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: _loadFeed,
                      child: Text(
                        "Try again",
                        style: TextStyle(color: context.colors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_feeds.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 56.sp,
                      color: context.colors.textSecondary.withOpacity(0.4),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "No posts yet",
                      style: context.typography.headline.copyWith(
                        fontSize: 16.sp,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Your circle hasn't shared anything today.",
                      style: context.typography.body.copyWith(
                        fontSize: 13.sp,
                        color: context.colors.textSecondary.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (_isNativeAdSlot(index)) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: const NativeAdWidget(factoryId: 'listTile'),
                  );
                }

                final item = _feeds[_feedIndexForSlot(index)];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: FeedCard(
                    data: item,
                    communityId: widget.communityId,
                    isStopSharing: widget.isStopSharing,
                    isForecastShared: item.isForecastShared ?? false,
                    onStopSharing: _isStoppingAll ? null : _stopSharingWithAll,
                    onStartSharing: _onStartSharing,
                    isStopping: _isStoppingAll,
                  ),
                );
              }, childCount: _slotCountWithAds(_feeds.length)),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEED CARD  (one post per community member per day)
// ─────────────────────────────────────────────────────────────────────────────

class FeedCard extends StatefulWidget {
  final DailyFeedData data;
  final String communityId;
  final bool isStopSharing;
  final bool isForecastShared;
  final VoidCallback? onStopSharing;
  final VoidCallback? onStartSharing;
  final bool isStopping;
  const FeedCard({
    super.key,
    required this.data,
    required this.communityId,
    required this.isStopSharing,
    this.isForecastShared = true,
    this.onStopSharing,
    this.onStartSharing,
    this.isStopping = false,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final _service = UserHomeService();
  late bool _liked;
  late int _likeCount;
  late int _commentCount;
  bool _isTogglingLike = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.data.likedByMe ?? false;
    _likeCount = widget.data.likesCount ?? 0;
    _commentCount = widget.data.commentsCount ?? 0;
  }

  Future<bool> _toggleLike() async {
    if (_isTogglingLike) return _liked;

    // Optimistic update
    final previousLiked = _liked;
    final previousCount = _likeCount;
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
      _isTogglingLike = true;
    });

    final result = await _service.toggleFeedLike(
      feedId: widget.data.author?.id ?? '',
      communityId: widget.communityId,
      context: context,
    );

    if (mounted) {
      setState(() => _isTogglingLike = false);
    }

    if (result != null && mounted) {
      // Use server response as source of truth
      setState(() {
        _liked = result['likedByMe'] ?? _liked;
        _likeCount = result['likesCount'] ?? _likeCount;
      });
      return _liked;
    } else if (mounted) {
      // Revert on failure
      setState(() {
        _liked = previousLiked;
        _likeCount = previousCount;
      });
    }
    return _liked;
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.data.author;
    final forecast = widget.data.forecast;
    final reflection = widget.data.reflection;

    final displayName = author?.aliasName?.isNotEmpty == true
        ? author!.aliasName!
        : author?.username ?? 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Author header ─────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(url: author?.avatarUrl),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: context.typography.headline.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  _formatDate(widget.data.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                    fontFamily: "Raleway",
                  ),
                ),
              ],
            ),
            if (widget.isStopSharing) Spacer(),
            if (widget.isStopSharing) ...[
              if (widget.isStopping)
                SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: LoadingWidget(color: context.colors.error, size: 2),
                )
              else if (widget.isForecastShared)
                GestureDetector(
                  onTap: widget.onStopSharing,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.notshare.svg(height: 18.h, width: 18.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Stop Sharing",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          fontFamily: "sfpro",
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                SizedBox(
                  width: 98.w,
                  height: 27.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: widget.onStartSharing,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.icons.sharing.svg(height: 14.h, width: 14.w),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            "Start Sharing",
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.body.copyWith(
                              color: context.colors.background,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () {
                    MyDialogBox.show(
                      context,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Sharing Forecast",
                              style: context.typography.title.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "When you share your forecast, you decide who in your community circle can see your daily emotional updates and journal entries.",
                              textAlign: TextAlign.center,
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                color: context.colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Got it",
                                style: TextStyle(color: context.colors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: context.colors.primary,
                  ),
                ),
              ],
              SizedBox(width: 15.w),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Assets.icons.word.svg(),
              ),
            ],
          ],
        ),
        SizedBox(height: 15.h),

        // ── Forecast card ─────────────────────────────────────────────────
        if (forecast != null) ...[
          _ForecastCard(forecast: forecast),
          SizedBox(height: 12.h),
        ],

        // ── Reflection card ───────────────────────────────────────────────
        if (reflection != null) ...[
          _ReflectionCard(
            reflection: reflection,
            forecastEmotions: forecast?.emotions,
          ),
          SizedBox(height: 12.h),
        ],

        // ── Actions row ───────────────────────────────────────────────────
        Row(
          children: [
            SizedBox(width: 4.w),
            LikeButton(
              isLiked: _liked,
              likeCount: _likeCount,
              mainAxisAlignment: MainAxisAlignment.start,
              size: 20,
              circleColor: const CircleColor(
                start: Color(0xff00ddff),
                end: Color(0xff0099cc),
              ),
              bubblesColor: const BubblesColor(
                dotPrimaryColor: Color(0xff33b5e5),
                dotSecondaryColor: Color(0xff0099cc),
              ),
              likeBuilder: (bool isLiked) => Icon(
                Icons.favorite_rounded,
                color: isLiked ? Colors.red : Colors.grey,
                size: 20.sp,
              ),
              countBuilder: (int? count, bool isLiked, String text) {
                final color = isLiked ? Colors.red : Colors.grey;
                if (count == null || count == 0) {
                  return Text(
                    "love",
                    style: TextStyle(color: color, fontSize: 14.sp),
                  );
                }
                return Text(
                  text,
                  style: TextStyle(color: color, fontSize: 14.sp),
                );
              },
              onTap: (isLiked) async {
                return await _toggleLike();
              },
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () {
                CommentBottomSheet.show(
                  context,
                  entryOwnerId: author?.id ?? '',
                  communityId: widget.communityId,
                  onCommentCountChanged: (newCount) {
                    setState(() {
                      _commentCount = newCount;
                    });
                  },
                );
              },
              child: Assets.images.comments.image(width: 20.w, height: 20.h),
            ),
            SizedBox(width: 5.w),
            Text(
              '$_commentCount',
              style: context.typography.body.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(
          color: context.colors.textSecondary.withOpacity(0.12),
          thickness: 1,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORECAST CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ForecastCard extends StatelessWidget {
  final Forecast forecast;
  const _ForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final emotions = forecast.emotions ?? [];
    final imageEmotions = emotions
        .where((e) => e.imageUrl != null && e.imageUrl!.trim().isNotEmpty)
        .toList();
    final chipEmotions = emotions
        .where((e) => e.imageUrl == null || e.imageUrl!.trim().isEmpty)
        .toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Forecast",
            style: context.typography.headline.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),

          // Emotion chips — only show for emotions WITHOUT images
          if (chipEmotions.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              alignment: WrapAlignment.start, // 👈 Align chips from start
              children: chipEmotions
                  .map((e) => _FeelingChip(emotionKey: e.key))
                  .toList(),
            ),

          if (chipEmotions.isNotEmpty) SizedBox(height: 10.h),

          // Emotion image slots - show all images (up to 3 in a row)
          if (imageEmotions.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final itemWidth = imageEmotions.length == 1
                    ? maxWidth
                    : (maxWidth - (imageEmotions.length - 1) * 8.w) /
                          imageEmotions.length.clamp(2, 3);

                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment
                      .start, // 👈 Ensures row grid builds from left/start
                  children: imageEmotions.take(3).map((emotion) {
                    return _EmotionImageSlot(
                      emotionKey: emotion.key,
                      imageUrl: emotion.imageUrl,
                      width: itemWidth,
                      height: 140.h,
                    );
                  }).toList(),
                );
              },
            ),

          if (forecast.notes?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Text(
              '"${forecast.notes}"',
              style: context.typography.body.copyWith(
                fontSize: 13.sp,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                fontFamily: "Raleway",
              ),
            ),
          ],

          if (forecast.plan?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(8.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan:",
                    style: context.typography.headline.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    forecast.plan!,
                    style: context.typography.headline.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                      fontFamily: "Raleway",
                    ),
                  ),
                ],
              ),
            ),

            if (forecast.userNotes?.isNotEmpty == true) ...[
              SizedBox(height: 10.h),
              Text(
                "Notes",
                style: context.typography.headline.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              ...forecast.userNotes!.map(
                (note) => Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(8.w),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.content ?? '',
                        style: context.typography.headline.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textPrimary,
                          fontFamily: "Raleway",
                        ),
                      ),
                      if (note.postedLabel != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          note.postedLabel!,
                          style: context.typography.body.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: context.colors.textSecondary.withOpacity(
                              0.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REFLECTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  final Reflection reflection;
  final List<Emotion>? forecastEmotions;

  const _ReflectionCard({required this.reflection, this.forecastEmotions});

  @override
  Widget build(BuildContext context) {
    final emotions = reflection.emotions ?? [];
    final imageEmotions = emotions
        .where((e) => e.imageUrl != null && e.imageUrl!.trim().isNotEmpty)
        .toList();

    final forecastKeys = (forecastEmotions ?? [])
        .map((e) => e.key?.toLowerCase())
        .where((k) => k != null)
        .toSet();
    final reflectionKeys = emotions
        .map((e) => e.key?.toLowerCase())
        .where((k) => k != null)
        .toSet();

    final matched = reflectionKeys
        .intersection(forecastKeys)
        .map((k) => EmotionsList.getTitleByKey(k ?? ''))
        .join(', ');
    final different = reflectionKeys
        .difference(forecastKeys)
        .map((k) => EmotionsList.getTitleByKey(k ?? ''))
        .join(', ');
    final chipEmotions = emotions
        .where((e) => e.imageUrl == null || e.imageUrl!.trim().isEmpty)
        .toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "End of Day",
            style: context.typography.headline.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),

          if (chipEmotions.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              alignment: WrapAlignment.start, // 👈 Align chips from start
              children: chipEmotions
                  .map((e) => _FeelingChip(emotionKey: e.key))
                  .toList(),
            ),

          if (chipEmotions.isNotEmpty) SizedBox(height: 10.h),

          // Emotion images - show all images (up to 3 in a row)
          if (imageEmotions.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final itemWidth = imageEmotions.length == 1
                    ? maxWidth
                    : (maxWidth - (imageEmotions.length - 1) * 8.w) /
                          imageEmotions.length.clamp(2, 3);

                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment
                      .start, // 👈 Ensures row grid builds from left/start
                  children: imageEmotions.take(3).map((emotion) {
                    return _EmotionImageSlot(
                      emotionKey: emotion.key,
                      imageUrl: emotion.imageUrl,
                      width: itemWidth,
                      height: 140.h,
                    );
                  }).toList(),
                );
              },
            ),

          SizedBox(height: 10.h),

          // Forecast vs Actual comparison
          Container(
            padding: EdgeInsets.all(8.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F4),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forecast vs Actual:",
                  style: context.typography.headline.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                    fontFamily: "sfpro",
                  ),
                ),
                SizedBox(height: 10.h),
                if (matched.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        "✓",
                        style: context.typography.headline.copyWith(
                          fontSize: 11.sp,
                          color: context.colors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          " Matched: $matched",
                          style: context.typography.headline.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: context.colors.textPrimary,
                            fontFamily: "Raleway",
                          ),
                        ),
                      ),
                    ],
                  ),
                if (matched.isNotEmpty && different.isNotEmpty)
                  SizedBox(height: 6.h),
                if (different.isNotEmpty)
                  Text(
                    "✗ Different: $different",
                    style: context.typography.headline.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                      fontFamily: "Raleway",
                    ),
                  ),
                if (matched.isEmpty && different.isEmpty)
                  Text(
                    reflection.wentAsForecast == true
                        ? "✓ Went as forecasted"
                        : "Day differed from forecast",
                    style: context.typography.headline.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: context.colors.textSecondary,
                      fontFamily: "Raleway",
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED: EMOTION IMAGE SLOT
// ─────────────────────────────────────────────────────────────────────────────
class _EmotionImageSlot extends StatelessWidget {
  final String? emotionKey;
  final String? imageUrl;
  final double width;
  final double height;

  const _EmotionImageSlot({
    required this.emotionKey,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (!hasImage) {
      return const SizedBox.shrink();
    }

    final label = EmotionsList.getTitleByKey(emotionKey ?? '');

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment
            .start, // 👈 Shifts text details to start instead of center
        children: [
          SizedBox(
            width: width,
            height: height,
            child: PostImage(imageUrl: imageUrl!, width: width, height: height),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(
              left: 2.w,
            ), // Slight margin buffer for alignment perfection
            child: Text(
              label,
              style: context.typography.headline.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
                fontFamily: "sfpro",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED: AVATAR
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: context.colors.textPrimary,
        shape: BoxShape.circle,
      ),
      child: hasUrl
          ? CachedNetworkImage(
              imageUrl: url!,
              width: 45.r,
              height: 45.r,
              imageBuilder: (context, provider) => GestureDetector(
                onTap: () => ImageZoomViewer.show(context, url!),
                child: Container(
                  width: 45.r,
                  height: 45.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: provider, fit: BoxFit.cover),
                  ),
                ),
              ),
              placeholder: (_, __) => SizedBox(
                width: 45.r,
                height: 45.r,
                child: const Center(child: LoadingWidget()),
              ),
              errorWidget: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() => Container(
    width: 45.r,
    height: 45.r,
    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
    child: const Icon(Icons.person, color: Colors.white),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED: FEELING CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _FeelingChip extends StatelessWidget {
  final String? emotionKey;

  const _FeelingChip({required this.emotionKey});

  @override
  Widget build(BuildContext context) {
    final title = EmotionsList.getTitleByKey(emotionKey ?? '');
    final emojiWidget = EmotionsList.getEmojiByKey(
      emotionKey ?? '',
      w: 24,
      h: 24,
    );

    return Chip(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: const Color(0xFFF2F2F4),
      label: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: FittedBox(fit: BoxFit.contain, child: emojiWidget),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: context.typography.headline.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POST IMAGE
// ─────────────────────────────────────────────────────────────────────────────

class PostImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const PostImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const LoadingWidget(),
          ),
          errorWidget: (context, url, error) {
            debugPrint('❌ [PostImage] Failed to load: $url');
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
