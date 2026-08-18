import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/capsule_tabbar.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/analytics/analytics_model.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/alltime_activities.dart';
import 'package:kena_emotional_journey/view/analytics/calendar_screen.dart';
import 'package:kena_emotional_journey/view/analytics/monthly_activities.dart';
import 'package:kena_emotional_journey/view/analytics/overall_screen.dart';
import 'package:kena_emotional_journey/view/analytics/weekly_activities.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

enum AnalyticsTab { overall, activites, calendar }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late Future<AnalyticsModel?> _analyticsFuture;
  final _service = UserHomeService();
  AnalyticsTab _activeTab = AnalyticsTab.overall;
  late TabController _tabController;
  final List<String> _tabs = ['Weekly', 'Monthly', 'All Time'];

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _service.getAnalytics(context: context);
    _tabController = TabController(length: _tabs.length, vsync: this);
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
    _tabController.dispose();
    super.dispose();
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
        ],
      ),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          "Your Analytics",
          style: context.typography.title.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
            fontSize: 20,
            fontFamily: "sfpro",
          ),
        ),
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
          // GestureDetector(
          //   onTap: () {
          //     Navigator.pushNamed(context, RoutesName.homeScreen);
          //   },
          //   child: Padding(
          //     padding: EdgeInsets.all(8.w),
          //     child: Assets.icons.homeIcon.svg(height: 40.h, width: 40.w),
          //   ),
          // ),
        ],
      ),
      body: FutureBuilder<AnalyticsModel?>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: context.colors.primary,
                size: 45,
              ),
            );
          }
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.data == null ||
              snapshot.data!.data!.isEmpty) {
            return Center(
              child: Text(
                "No analytics data available.",
                style: context.typography.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            );
          }

          final data = snapshot.data!.data!.first;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _activityTabBar(context, _activeTab, (tab) {
                    setState(() {
                      _activeTab = tab;
                    });
                  }),
                  SizedBox(height: 20.h),
                  if (_activeTab == AnalyticsTab.activites) ...[
                    CapsuleTabBar(
                      controller: _tabController,
                      tabs: _tabs,
                      activeColor: context.colors.primary,
                      inactiveTextColor: context.colors.textSecondary,
                      // Optional: You can easily change the color per-screen now!
                    ),

                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        if (_tabController.index == 2) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(height: 20.h);
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          return IndexedStack(
                            index: _tabController.index,
                            children: [
                              // --- TAB 1: WEEKLY ---
                              WeeklyActivities(),

                              // --- TAB 2: MONTHLY ---
                              MonthlyActivities(),

                              // --- TAB 3: YEARLY ---
                              AlltimeActivities(),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                  if (_activeTab == AnalyticsTab.overall)
                    OverallScreen(data: data),
                  if (_activeTab == AnalyticsTab.calendar) CalendarScreen(),
                  SizedBox(height: 20.h),
                  const BannerAdWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _activityTabBar(
  BuildContext context,
  AnalyticsTab activeTab,
  ValueChanged<AnalyticsTab> onTabChanged,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(AnalyticsTab.overall),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Overall',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == AnalyticsTab.overall
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == AnalyticsTab.overall
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(AnalyticsTab.activites),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Activities',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == AnalyticsTab.activites
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == AnalyticsTab.activites
                        ? context.colors.primary
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(AnalyticsTab.calendar),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Calendar',
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontFamily: 'sfpro',
                    fontSize: 16.sp,
                    fontWeight: activeTab == AnalyticsTab.calendar
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTab == AnalyticsTab.calendar
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
              color: activeTab == AnalyticsTab.overall
                  ? context.colors.primary
                  : context.colors.background,
            ),
          ),
          Expanded(
            child: Container(
              height: 2.h,
              color: activeTab == AnalyticsTab.activites
                  ? context.colors.primary
                  : context.colors.background,
            ),
          ),
          Expanded(
            child: Container(
              height: 2.h,
              color: activeTab == AnalyticsTab.calendar
                  ? context.colors.primary
                  : context.colors.background,
            ),
          ),
        ],
      ),
    ],
  );
}
