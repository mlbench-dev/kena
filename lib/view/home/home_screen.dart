import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/no_internet_dialog.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/provider/user_home_provider.dart';
import 'package:kena_emotional_journey/services/common/notifications_service.dart';
import 'package:kena_emotional_journey/services/common/push_notifications_service.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
import 'package:kena_emotional_journey/view/home/widgets/home_section_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final SessionController _sessionController = SessionController();
  final NotificationsService _notificationsService = NotificationsService();
  final SubscriptionCacheService _subscriptionCacheService =
      SubscriptionCacheService();
  StreamSubscription<void>? _foregroundMessageSub;
  bool _hasPaidSubscription = false;

  // Tour keys for onboarding
  // final GlobalKey _aspireKey = GlobalKey();
  // final GlobalKey _forecastKey = GlobalKey();
  // final GlobalKey _activitiesKey = GlobalKey();
  // final GlobalKey _analyticsKey = GlobalKey();
  // final GlobalKey _communityKey = GlobalKey();

  // final bool _isTourActive = false;
  // TourHandle? _tourHandle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUnreadCount();
    _loadSubscriptionBadgeState();

    _foregroundMessageSub = PushNotificationsService.onForegroundMessage.listen(
      (_) => _fetchUnreadCount(),
    );

    // Start the onboarding tour after widget is built. The pro tip check is
    // chained to run only once the tour has finished (or immediately if the
    // tour has already been shown before), so the two never overlap.
    // WidgetsBinding.instance.addPostFrameCallback((_) => _startOnboardingTour());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUnreadCount();
      _loadSubscriptionBadgeState();
      // if (!_isTourActive) _checkProTip();
    }
  }

  Future<void> _loadSubscriptionBadgeState() async {
    final hasPaidSubscription = await _subscriptionCacheService
        .hasPaidSubscription();
    if (!mounted) return;
    setState(() => _hasPaidSubscription = hasPaidSubscription);
  }

  @override
  void dispose() {
    // _tourHandle?.cancel();
    _foregroundMessageSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final unreadCount = await _notificationsService
          .getUnreadNotificationCount();
      if (mounted) {
        context.read<UserHomeProvider>().setUnreadNotificationCount(
          unreadCount,
        );
      }
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
    }
  }

  // Future<void> _startOnboardingTour() async {
  //   if (!mounted) return;
  //   final alreadyShown = await OnboardingTourService().isTourShown(
  //     TourSections.onboarding,
  //   );
  //   if (!mounted) return;
  //   if (alreadyShown) {
  //     _checkProTip();
  //     return;
  //   }

  //   _isTourActive = true;
  //   _tourHandle = TourController.start(
  //     context: context,
  //     sectionKey: TourSections.onboarding,
  //     targetKeys: [
  //       _aspireKey,
  //       _forecastKey,
  //       _activitiesKey,
  //       _analyticsKey,
  //       _communityKey,
  //     ],
  //     onComplete: () {
  //       _isTourActive = false;
  //       _checkProTip();
  //     },
  //   );
  // }

  // Future<void> _checkProTip() async {
  //   final tip = await ProTipManager.getNextDueTip();
  //   if (tip != null && mounted) {
  //     await ProTipManager.markTipAsShown(tip.id);
  //     if (!mounted) return;
  //     MyDialogBox.show(
  //       context,
  //       child: ProTipsDialogBox(
  //         title: tip.title,
  //         description: tip.description,
  //         buttonLabel: tip.buttonLabel,
  //         icon: tip.iconBuilder(),
  //         onButtonPressed: () => Navigator.of(context).pop(),
  //       ),
  //     );
  //   }
  // }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning'; // 5:00 AM to 11:59 AM
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon'; // 12:00 PM to 4:59 PM
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening'; // 5:00 PM to 8:59 PM
    } else {
      return 'Good Night'; // 9:00 PM to 4:59 AM (or keep "Good Evening")
    }
  }

  List<HomeSectionCard> _homeSections(
    NavigationActionsController actions,
    BuildContext context,
  ) {
    return [
      HomeSectionCard(
        background: Assets.images.aspire,
        icon: Assets.icons.aspire,
        color: context.colors.primary,
        title: 'Aspire',
        subtitle: 'Set your goals and build the \nemotional life you want.',
        onTap: () => actions.onAspireTap(context),
        isLoading: actions.aspireLoading,
        isDisabled: actions.isAnyLoading && !actions.aspireLoading,
      ),
      HomeSectionCard(
        background: Assets.images.dailyPuls,
        icon: Assets.icons.circle,
        title: 'Daily Pulse',
        color: context.colors.secondary,
        subtitle:
            'Your daily space to forecast\nanticipate, reflect and share.',
        onTap: () => actions.onForecastTap(context),
        isLoading: actions.forecastLoading,
        isDisabled: actions.isAnyLoading && !actions.forecastLoading,
      ),
      HomeSectionCard(
        background: Assets.images.activities,
        icon: Assets.icons.activity,
        color: context.colors.secondary,
        title: 'Activities',
        subtitle: 'Build habits and do activities \nthat help you grow.',
        onTap: () => actions.onActivitiesTap(context),
        isDisabled: actions.isAnyLoading,
      ),
      HomeSectionCard(
        background: Assets.images.analytics,
        icon: Assets.icons.analytic,
        color: context.colors.primary,
        title: 'Analytics',
        subtitle: "Track your progress and see \nhow you’re growing over time.",
        onTap: () => actions.onAnalyticsTap(context),
        isDisabled: actions.isAnyLoading,
      ),
      HomeSectionCard(
        background: Assets.images.circle,
        icon: Assets.icons.circle,
        color: context.colors.tertiary,
        title: 'Circles',
        subtitle:
            'Connect in invite-only \ncircles. Share, support \nand grow together.',
        onTap: () => actions.onCommunityTap(context),
        isDisabled: actions.isAnyLoading,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
    // Home is the root of the signed-in experience: back exits the app
    // instead of returning to whatever screens were pushed before it.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: ListenableBuilder(
        listenable: _sessionController,
        builder: (context, _) {
          final user = _sessionController.user;
          return MyScaffold(
            isSafeArea: false,
            // NOTE: if MyScaffold doesn't expose a bottomNavigationBar param,
            // see the note below the code for how to add it / an alternative.
            // bottomNavigationBar: MyNavBar(
            //   items: [
            //     NavBarButtonItem(
            //       key: _aspireKey,
            //       icon: Assets.icons.aspire.svg(),
            //       label: 'Aspire',
            //       isLoading: actions.aspireLoading,
            //       isDisabled: actions.isAnyLoading && !actions.aspireLoading,
            //       onTap: () => actions.onAspireTap(context),
            //     ),
            //     NavBarButtonItem(
            //       key: _forecastKey,
            //       icon: Assets.icons.dailyPuls.svg(),
            //       label: 'Daily Pulse',
            //       isLoading: actions.forecastLoading,
            //       isDisabled: actions.isAnyLoading && !actions.forecastLoading,
            //       onTap: () => actions.onForecastTap(context),
            //     ),
            //     NavBarButtonItem(
            //       key: _activitiesKey,
            //       icon: Assets.icons.activity.svg(),
            //       label: 'Activities',
            //       isDisabled: actions.isAnyLoading,
            //       onTap: () => actions.onActivitiesTap(context),
            //     ),
            //     NavBarButtonItem(
            //       key: _analyticsKey,
            //       icon: Assets.icons.analytic.svg(),
            //       label: 'Analytics',
            //       isDisabled: actions.isAnyLoading,
            //       onTap: () => actions.onAnalyticsTap(context),
            //     ),
            //     NavBarButtonItem(
            //       key: _communityKey,
            //       icon: Assets.icons.circle.svg(),
            //       label: 'Circle',
            //       isDisabled: actions.isAnyLoading,
            //       onTap: () => actions.onCommunityTap(context),
            //     ),
            //   ],
            // ),
            body: Stack(
              children: [
                Positioned(left: 0, top: 0, child: Assets.icons.vectors.svg()),
                Positioned(
                  left: 98,
                  top: 50,
                  child: Animate(
                    onPlay: (c) => c.repeat(reverse: true),
                    effects: [
                      MoveEffect(
                        begin: Offset.zero,
                        end: const Offset(0, 10),
                        duration: 4.seconds,
                        curve: Curves.easeInOut,
                      ),
                    ],
                    child: Assets.icons.ellipse.svg(),
                  ),
                ),
                Positioned(
                  left: 30,
                  right: 30,
                  top: 150,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              RoutesName.profile,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 24.r,
                                  child: CircleAvatar(
                                    backgroundColor: context.colors.background,
                                    radius: 22.r,
                                    backgroundImage:
                                        (user?.avatarUrl != null &&
                                            user!.avatarUrl!.isNotEmpty)
                                        ? CachedNetworkImageProvider(
                                            user.avatarUrl!,
                                          )
                                        : null,
                                    child:
                                        (user?.avatarUrl == null ||
                                            user!.avatarUrl!.isEmpty)
                                        ? Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                            size: 24.r,
                                          )
                                        : null,
                                  ),
                                ),
                                if (_hasPaidSubscription)
                                  Positioned(
                                    top: -5.r,
                                    right: -7.r,
                                    width: 24.r,
                                    height: 24.r,
                                    child: Assets.icons.premium.svg(),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  // "${getGreeting()}, ${user?.username}",
                                  "Hey, ${user?.username}",
                                  style: context.typography.headline.copyWith(
                                    color: context.colors.textPrimary,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                Text(
                                  "Your emotional journey continues.",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.typography.label.copyWith(
                                    fontSize: 10.5.sp,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () async {
                              if (!await NoInternetDialog.guard(context))
                                return;
                              if (!context.mounted) return;
                              Navigator.pushNamed(
                                context,
                                RoutesName.notificationScreen,
                              ).then((_) => _fetchUnreadCount());
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(6.w),
                                  child: Assets.icons.notificationNobg.svg(
                                    height: 30.h,
                                    width: 30.h,
                                  ),
                                ),
                                Consumer<UserHomeProvider>(
                                  builder: (context, homeProvider, _) {
                                    final unreadCount =
                                        homeProvider.unreadNotificationCount;
                                    if (unreadCount <= 0)
                                      return const SizedBox.shrink();
                                    return Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 16.r,
                                          minHeight: 16.r,
                                        ),
                                        child: Text(
                                          unreadCount > 9
                                              ? '9+'
                                              : '$unreadCount',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 225.h,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Builder(
                    builder: (context) {
                      final sections = _homeSections(actions, context);
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        itemCount: sections.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: sections[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  // Padding(
  //   padding: EdgeInsets.symmetric(horizontal: 15.w),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       MasonryGridView.count(
  //         crossAxisCount: 2,
  //         mainAxisSpacing: 15.h,
  //         crossAxisSpacing: 15.w,
  //         padding: EdgeInsets.only(top: 10.h),
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: 5,
  //         itemBuilder: (context, index) {
  //           final items = [
  //             {
  //               'title': 'Forecast / Reflect',
  //               'color': const Color(0xFFf8cde6),
  //               'height': 165.h,
  //               'icon': _isLoading
  //                   ? const SizedBox(
  //                       width: 18,
  //                       height: 18,
  //                       child: LoadingWidget(
  //                         color: Colors.black54,
  //                       ),
  //                     )
  //                   : Icon(
  //                       Icons.add,
  //                       color: Colors.black87,
  //                       size: 20.sp,
  //                     ),
  //             },
  //             {
  //               'title': 'Community',
  //               'color': const Color(0xFFc9edb3),
  //               'height': 165.h,
  //               'icon': Assets.icons.chat.svg(),
  //             },
  //             {
  //               'title': 'Activities',
  //               'color': const Color(0xFFc9edb3),
  //               'height': 165.h,
  //               'icon': Icon(
  //                 Icons.bar_chart,
  //                 color: Colors.black87,
  //                 size: 20.sp,
  //               ),
  //             },
  //             {
  //               'title': 'Aspire',
  //               'color': const Color(0xFFf8cde6),
  //               'height': 165.h,
  //               'icon': _aspireLoading
  //                   ? const SizedBox(
  //                       width: 18,
  //                       height: 18,
  //                       child: LoadingWidget(
  //                         color: Colors.black54,
  //                       ),
  //                     )
  //                   : Icon(
  //                       Icons.track_changes,
  //                       color: Colors.black87,
  //                       size: 20.sp,
  //                     ),
  //             },
  //             {
  //               'title': 'Analytics',
  //               'color': const Color(0xFFf8cde6),
  //               'height': 165.h,
  //               'icon': Icon(
  //                 Icons.auto_graph,
  //                 color: Colors.black87,
  //                 size: 20.sp,
  //               ),
  //             },
  //           ];

  //           final item = items[index];

  //           return _buildStaggeredCard(
  //             title: item['title'] as String,
  //             baseColor: item['color'] as Color,
  //             height: item['height'] as double,
  //             icon: item['icon'] as Widget,
  //             onTap: () {
  //               if (item['title'] == 'Aspire') {
  //                 _onAspireTap();
  //               } else if (item['title'] ==
  //                   'Forecast / Reflect') {
  //                 _onForecastTap();
  //               } else if (item['title'] == 'Activities') {
  //                 _onActivitiesTap();
  //               } else if (item['title'] == 'Community') {
  //                 _onCommunityTap();
  //               } else if (item['title'] == 'Analytics') {
  //                 _onAnalyticsTap();
  //               }
  //             },
  //           );
  //         },
  //       ),
  //       SizedBox(height: 20.h),
  //     ],
  //   ),
  // ),

  // Widget _buildStaggeredCard({
  //   required String title,
  //   required Color baseColor,
  //   required double height,
  //   required Widget icon,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: height,
  //       padding: EdgeInsets.all(15.r),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(24.r),
  //         color: baseColor,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.white.withValues(alpha: 0.9),
  //             blurRadius: 4,
  //             spreadRadius: -2,
  //           ),
  //           BoxShadow(
  //             color: Colors.white.withValues(alpha: 0.25),
  //             blurRadius: 47,
  //             spreadRadius: -7,
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           CircleAvatar(
  //             radius: 18.r,
  //             backgroundColor: Colors.white.withValues(alpha: 0.5),
  //             child: icon,
  //           ),
  //           const Spacer(),
  //           Text(
  //             title,
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black.withValues(alpha: 0.8),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Add this
// import 'package:kena_emotional_journey/app/components/loading_widget.dart';
// import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
// import 'package:kena_emotional_journey/app/routes/routes_name.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
// import 'package:kena_emotional_journey/provider/user_home_provider.dart';
// import 'package:kena_emotional_journey/services/common/notifications_service.dart';
// import 'package:kena_emotional_journey/services/common/push_notifications_service.dart';
// import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
// import 'package:kena_emotional_journey/services/user/user_home_service.dart';
// import 'package:provider/provider.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   final SessionController _sessionController = SessionController();
//   final UserHomeService _userHomeService = UserHomeService();
//   final NotificationsService _notificationsService = NotificationsService();
//   bool _aspireLoading = false;
//   bool _isLoading = false;
//   StreamSubscription<void>? _foregroundMessageSub;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _fetchUnreadCount();

//     // Refresh unread count when a foreground FCM message arrives
//     _foregroundMessageSub = PushNotificationsService.onForegroundMessage.listen(
//       (_) => _fetchUnreadCount(),
//     );
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _fetchUnreadCount();
//     }
//   }

//   @override
//   void dispose() {
//     _foregroundMessageSub?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   Future<void> _fetchUnreadCount() async {
//     try {
//       final unreadCount = await _notificationsService
//           .getUnreadNotificationCount();
//       if (mounted) {
//         context.read<UserHomeProvider>().setUnreadNotificationCount(
//           unreadCount,
//         );
//       }
//     } catch (e) {
//       debugPrint("Error fetching unread count: $e");
//     }
//   }

//   Future<void> _onAspireTap() async {
//     if (_aspireLoading) return;
//     setState(() => _aspireLoading = true);
//     try {
//       final result = await _userHomeService.getUserEmotions(context: context);
//       final hasData =
//           result != null &&
//           result.data != null &&
//           result.data!.isNotEmpty &&
//           ((result.data!.first.coreEmotions?.isNotEmpty ?? false) ||
//               (result.data!.first.aspirationEmotions?.isNotEmpty ?? false));

//       if (!mounted) return;

//       if (hasData) {
//         Navigator.pushNamed(context, RoutesName.selectedEmotionsScreen);
//       } else {
//         Navigator.pushNamed(
//           context,
//           RoutesName.coreEmotions,
//           arguments: {'isFromHome': true},
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _aspireLoading = false);
//     }
//   }

//   Future<void> _onForecastTap() async {
//     if (_isLoading) return;

//     setState(() => _isLoading = true);

//     try {
//       final forecastResult = await _userHomeService.getForecast(
//         context: context,
//       );

//       final endDayResult = await _userHomeService.getEndDay(context: context);

//       if (!mounted) return;

//       final endDay = (endDayResult?.data?.isNotEmpty ?? false)
//           ? endDayResult!.data!.first
//           : null;

//       final forecastData = (forecastResult?.data?.isNotEmpty ?? false)
//           ? forecastResult!.data!.first
//           : null;

//       final forecast = forecastData?.forecast;

//       final hasEndDay =
//           endDay != null &&
//           endDay.endDay != null &&
//           (endDay.endDay!.emotions?.isNotEmpty ?? false);

//       final hasForecast =
//           forecast != null &&
//           ((forecast.emotions?.isNotEmpty ?? false) ||
//               (forecast.plan?.isNotEmpty ?? false));
//       // if (hasEndDay) {
//       //   Navigator.pushNamed(
//       //     context,
//       //     RoutesName.endDayComparisonScreen,
//       //     arguments: endDay,
//       //   );
//       //   return;
//       // }

//       if (hasForecast) {
//         Navigator.pushNamed(
//           context,
//           RoutesName.forecastResultScreen,
//           arguments: forecastData,
//         );
//         return;
//       }

//       Navigator.pushNamed(
//         context,
//         RoutesName.startForecastScreen,
//         arguments: {'isFromHome': true},
//       );
//     } catch (e) {
//       debugPrint("Forecast tap error: $e");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListenableBuilder(
//       listenable: _sessionController,
//       builder: (context, _) {
//         final user = _sessionController.user;
//         return MyScaffold(
//           isSafeArea: false,
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- HEADER SECTION ---
//                 Container(
//                   width: double.infinity,
//                   height: 140.h,
//                   padding: EdgeInsets.only(top: 35.h, left: 15.w, right: 15.w),
//                   decoration: BoxDecoration(
//                     color: context.colors.primary,
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(20),
//                       bottomRight: Radius.circular(20),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () =>
//                             Navigator.pushNamed(context, RoutesName.profile),
//                         child: CircleAvatar(
//                           backgroundColor: context.colors.background,
//                           radius: 22.r,
//                           backgroundImage:
//                               (user?.avatarUrl != null &&
//                                   user!.avatarUrl!.isNotEmpty)
//                               ? CachedNetworkImageProvider(user.avatarUrl!)
//                               : null,
//                           child:
//                               (user?.avatarUrl == null ||
//                                   user!.avatarUrl!.isEmpty)
//                               ? Icon(
//                                   Icons.person,
//                                   color: Colors.grey,
//                                   size: 24.r,
//                                 )
//                               : null,
//                         ),
//                       ),
//                       SizedBox(width: 10.w),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Hey, ${user?.username}",
//                             style: context.typography.headline.copyWith(
//                               color: Colors.white,
//                               fontSize: 18.sp,
//                             ),
//                           ),
//                           Text(
//                             "Your emotional journey continues.",
//                             style: context.typography.label.copyWith(
//                               fontSize: 12.sp,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pushNamed(
//                             context,
//                             RoutesName.notificationScreen,
//                           ).then((_) => _fetchUnreadCount());
//                         },
//                         child: Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             Assets.icons.notifications.svg(
//                               height: 40.h,
//                               width: 40.h,
//                             ),
//                             Consumer<UserHomeProvider>(
//                               builder: (context, homeProvider, _) {
//                                 final unreadCount =
//                                     homeProvider.unreadNotificationCount;
//                                 if (unreadCount <= 0) {
//                                   return const SizedBox.shrink();
//                                 }
//                                 return Positioned(
//                                   right: -2,
//                                   top: -2,
//                                   child: Container(
//                                     padding: EdgeInsets.all(4.r),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     constraints: BoxConstraints(
//                                       minWidth: 16.r,
//                                       minHeight: 16.r,
//                                     ),
//                                     child: Text(
//                                       unreadCount > 9 ? '9+' : '$unreadCount',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10.sp,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 15.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text(
//                       //   "Selection",
//                       //   style: context.typography.headline.copyWith(
//                       //     fontSize: 23.sp,
//                       //     fontWeight: FontWeight.w600,
//                       //     fontFamily: "sfpro",
//                       //   ),
//                       // ),
//                       MasonryGridView.count(
//                         crossAxisCount: 2,
//                         mainAxisSpacing: 15.h,
//                         crossAxisSpacing: 15.w,
//                         padding: EdgeInsets.only(top: 10.h),
//                         shrinkWrap: true,
//                         physics:
//                             const NeverScrollableScrollPhysics(), // Let the Column scroll
//                         itemCount: 5,
//                         itemBuilder: (context, index) {
//                           // List of data to match your screenshot
//                           final items = [
//                             {
//                               'title': 'Forecast / Reflect',
//                               'color': const Color(0xFFf8cde6),
//                               'height': 165.h,
//                               'icon': _isLoading
//                                   ? const SizedBox(
//                                       width: 18,
//                                       height: 18,
//                                       child: LoadingWidget(
//                                         color: Colors.black54,
//                                       ),
//                                     )
//                                   : Icon(
//                                       Icons.add,
//                                       color: Colors.black87,
//                                       size: 20.sp,
//                                     ),
//                             },
//                             {
//                               'title': 'Community',
//                               'color': const Color(0xFFc9edb3),
//                               'height': 165.h,
//                               'icon': Assets.icons.chat.svg(),
//                             },
//                             {
//                               'title': 'Activities',
//                               'color': const Color(0xFFc9edb3),
//                               'height': 165.h,
//                               'icon': Icon(
//                                 Icons.bar_chart,
//                                 color: Colors.black87,
//                                 size: 20.sp,
//                               ),
//                             },
//                             {
//                               'title': 'Aspire',
//                               'color': const Color(0xFFf8cde6),
//                               'height': 165.h,
//                               'icon': _aspireLoading
//                                   ? const SizedBox(
//                                       width: 18,
//                                       height: 18,
//                                       child: LoadingWidget(
//                                         color: Colors.black54,
//                                       ),
//                                     )
//                                   : Icon(
//                                       Icons.track_changes,
//                                       color: Colors.black87,
//                                       size: 20.sp,
//                                     ),
//                             },
//                             {
//                               'title': 'Analytics',
//                               'color': const Color(0xFFf8cde6),
//                               'height': 165.h,
//                               'icon': Icon(
//                                 Icons.auto_graph,
//                                 color: Colors.black87,
//                                 size: 20.sp,
//                               ),
//                             },
//                           ];

//                           final item = items[index];

//                           return _buildStaggeredCard(
//                             title: item['title'] as String,
//                             baseColor: item['color'] as Color,
//                             height: item['height'] as double,
//                             icon: item['icon'] as Widget,
//                             onTap: () {
//                               if (item['title'] == 'Aspire') {
//                                 _onAspireTap();
//                               } else if (item['title'] ==
//                                   'Forecast / Reflect') {
//                                 _onForecastTap();
//                                 // Navigator.pushNamed(
//                                 //   context,
//                                 //   // RoutesName.viewReflections,
//                                 //   RoutesName.forecastTodayScreen,
//                                 // );
//                               } else if (item['title'] == 'Activities') {
//                                 Navigator.pushNamed(
//                                   context,
//                                   RoutesName.activitiesScreen,
//                                 );
//                               } else if (item['title'] == 'Community') {
//                                 if (_sessionController.communityId == null ||
//                                     _sessionController.communityId!
//                                         .trim()
//                                         .isEmpty) {
//                                   Navigator.pushNamed(
//                                     context,
//                                     RoutesName.emptyCommunity,
//                                   );
//                                 } else {
//                                   Navigator.pushNamed(
//                                     context,
//                                     RoutesName.myCommunity,
//                                   );
//                                 }
//                               } else if (item['title'] == 'Analytics') {
//                                 Navigator.pushNamed(
//                                   context,
//                                   RoutesName.analyticsScreen,
//                                 );
//                               }
//                             },
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20.h),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Helper method for the custom Glass/Figma style card
//   Widget _buildStaggeredCard({
//     required String title,
//     required Color baseColor, // ✅ required now
//     required double height,
//     required Widget icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: height,
//         padding: EdgeInsets.all(15.r),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24.r),

//           // ✅ Use dynamic color
//           color: baseColor,

//           // gradient: RadialGradient(
//           //   center: Alignment.center,
//           //   radius: 0.8,
//           //   colors: [
//           //     Colors.white.withOpacity(0.4),
//           //     baseColor, // ✅ dynamic here too
//           //   ],
//           //   stops: const [0.0, 0.8],
//           // ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.white.withOpacity(0.9),
//               blurRadius: 4,
//               spreadRadius: -2,
//             ),
//             BoxShadow(
//               color: Colors.white.withOpacity(0.25),
//               blurRadius: 47,
//               spreadRadius: -7,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 18.r,
//               backgroundColor: Colors.white.withOpacity(0.5),
//               child: icon,
//             ),
//             const Spacer(),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black.withOpacity(0.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
