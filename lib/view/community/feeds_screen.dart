import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/view/community/daily_feeds.dart';
import 'package:kena_emotional_journey/view/community/weekly_feeds.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FEEDS SCREEN
// (clean shell: app bar + Me/Friends toggle + Daily/Weekly tabs.
//  The actual feed content now lives in DailyFeedsScreen.)
// ─────────────────────────────────────────────────────────────────────────────
enum FeedType { daily, weekly }

class FeedsScreen extends StatefulWidget {
  final String communityId;
  final String communityName;
  const FeedsScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });
  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  FeedType _activeTab = FeedType.daily;
  String _feedScope = "Me";
  bool isVisible = false;
  bool isStopSharing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AdMobService.loadInterstitialAd();
    // Delay to allow ad to load before showing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AdMobService.showInterstitialAd();
      }
    });
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
      body: Column(
        children: [
          // ── App bar ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(color: context.colors.textPrimary),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Feed",
                          style: context.typography.headline.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: "sfpro",
                          ),
                        ),
                      ),
                    ),
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
                    //   onTap: () {
                    //     Navigator.pushNamed(context, RoutesName.homeScreen);
                    //   },
                    //   child: Assets.icons.homeIcon.svg(
                    //     height: 40.h,
                    //     width: 40.w,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 10.h),
                TopToggleBar(
                  onChanged: (value) {
                    setState(() {
                      _feedScope = value;
                    });
                  },
                ),
                SizedBox(height: 10.h),
                _activityTabBar(
                  context,
                  _activeTab,
                  (tab) => setState(() => _activeTab = tab),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),

          // ── Body: swap content based on active tab ───────────────────────
          Expanded(
            child:
                //  !isVisible
                //     ? EmptyFeedScreen(isStopSharing: isStopSharing)
                //     :
                _activeTab == FeedType.daily
                ? DailyFeedsScreen(
                    communityId: widget.communityId,
                    communityName: widget.communityName,
                    feedScope: _feedScope,
                    isStopSharing: _feedScope == 'Me',
                  )
                : WeeklyFeeds(
                    scope: _feedScope.toLowerCase(),
                    communityId: widget.communityId,
                  ),
          ),
          // const BannerAdWidget(),
        ],
      ),
    );
  }
}

Widget _activityTabBar(
  BuildContext context,
  FeedType activeTab,
  ValueChanged<FeedType> onTabChanged,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(FeedType.daily),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Daily',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == FeedType.daily
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == FeedType.daily
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(FeedType.weekly),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Weekly',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == FeedType.weekly
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == FeedType.weekly
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Full-width matching dynamic indicator bars underneath
      Row(
        children: [
          Expanded(
            child: Container(
              height: 2.h,
              color: activeTab == FeedType.daily
                  ? context.colors.primary
                  : context.colors.background,
            ),
          ),
          Expanded(
            child: Container(
              height: 2.h,
              color: activeTab == FeedType.weekly
                  ? context.colors.primary
                  : context.colors.background,
            ),
          ),
        ],
      ),
    ],
  );
}

class TopToggleBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const TopToggleBar({super.key, required this.onChanged});

  @override
  State<TopToggleBar> createState() => _TopToggleBarState();
}

class _TopToggleBarState extends State<TopToggleBar> {
  String selectedType = "Me";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final gap = 10.w;

          final itemWidth = (totalWidth - gap) / 2;

          return Stack(
            children: [
              /// 🔥 Sliding Indicator (with gap)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                left: selectedType == "Me" ? 0 : itemWidth + gap,
                top: 0,
                child: Container(
                  width: itemWidth,
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              /// 🔘 Buttons
              Row(
                children: [
                  /// Username
                  SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = "Me";
                        });
                        widget.onChanged(selectedType);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedType == "Me"
                              ? Colors.transparent
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 6),
                            Text(
                              "Me",
                              style: TextStyle(
                                color: selectedType == "Me"
                                    ? context.colors.background
                                    : context.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: gap), // 👈 spacing
                  /// Friends
                  SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = "Friends";
                        });
                        widget.onChanged(selectedType);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selectedType == "Friends"
                              ? Colors.transparent
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Friends",
                              style: TextStyle(
                                color: selectedType == "Friends"
                                    ? context.colors.background
                                    : context.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
