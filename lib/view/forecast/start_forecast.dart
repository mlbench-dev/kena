import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/emotions/result_emotion_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class StartForecastScreen extends StatefulWidget {
  const StartForecastScreen({super.key});

  @override
  State<StartForecastScreen> createState() => _StartForecastScreenState();
}

class _StartForecastScreenState extends State<StartForecastScreen> {
  final UserHomeService _userHomeService = UserHomeService();
  List<AspirationEmotion> _aspirationEmotions = [];
  final UserHomeService _service = UserHomeService();
  bool _isLoading = true;

  bool _yesterdayLoading = false;

  @override
  void initState() {
    super.initState();
    _load(); // FIXED: Triggers the backend call upon screen instantiation
  }

  Future<void> _onSameAsYesterdayTap() async {
    setState(() => _yesterdayLoading = true);

    try {
      // Step 1: Ask the backend to copy yesterday's forecast to today
      final copied = await _userHomeService.forecastAsYesterday(
        context: context,
      );
      if (!copied || !mounted) return;

      // Step 2: Fetch the newly created forecast so we have its full data
      final forecastModel = await _userHomeService.getForecast(
        context: context,
      );
      if (!mounted) return;

      final forecast = forecastModel?.data?.firstOrNull?.forecast;

      if (forecast == null) {
        // Fallback: just go to blank ForecastScreen
        Navigator.pushNamed(context, RoutesName.forecastScreen);
        return;
      }

      // Step 3: Open ForecastScreen pre-filled with yesterday's data
      Navigator.pushNamed(
        context,
        RoutesName.forecastScreen,
        arguments: {'forecast': forecast},
      );
    } finally {
      if (mounted) setState(() => _yesterdayLoading = false);
    }
  }

  Future<void> _load() async {
    final result = await _service.getUserEmotions(context: context);
    if (!mounted) return;

    final data = result?.data?.firstOrNull;
    setState(() {
      _aspirationEmotions = List<AspirationEmotion>.from(
        data?.aspirationEmotions ?? [],
      );
      _isLoading = false;
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
      body: SingleChildScrollView(
        // FIXED: Added to safeguard viewport vertical rendering spacing
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              Row(
                children: [
                  BackButton(color: context.colors.textPrimary),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      "Forecast",
                      style: context.typography.headline.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "sfpro",
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
              ),
              SizedBox(height: 30.h),

              // Added to layout tree so data renders dynamically on page
              _isLoading
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: context.colors.primary,
                        size: 45,
                      ),
                    )
                  : _aspireEmotionBox(context),
              SizedBox(height: 20.h),
              // Container(
              //   width: double.infinity,
              //   height: 204.h,
              //   padding: EdgeInsets.all(16.w),
              //   decoration: BoxDecoration(
              //     color: Color(0xFFBCE8A2),
              //     borderRadius: BorderRadius.circular(20.r),
              //   ),
              //   child: Column(
              //     children: [
              //       Row(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           CircleAvatar(
              //             radius: 24.r,
              //             backgroundColor: context.colors.background.withOpacity(
              //               0.6,
              //             ),
              //             child: Icon(
              //               Icons.wb_sunny,
              //               color: context.colors.primary,
              //             ),
              //           ),
              //           SizedBox(width: 20.w),
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 "Forecast Today",
              //                 style: context.typography.headline.copyWith(
              //                   fontSize: 18.sp,
              //                   fontWeight: FontWeight.w600,
              //                   fontFamily: "sfpro",
              //                 ),
              //               ),
              //               Text(
              //                 "Set expectations for today",
              //                 style: context.typography.headline.copyWith(
              //                   fontSize: 13.sp,
              //                   fontWeight: FontWeight.w400,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              GestureDetector(
                onTap: _yesterdayLoading
                    ? null // disabled while same-as-yesterday is loading
                    : () => Navigator.pushReplacementNamed(
                        context,
                        RoutesName.forecastScreen,
                        arguments: {'isFromHome': true},
                      ),
                child: Container(
                  width: double.infinity,
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      "Start today's forecast",
                      style: context.typography.body.copyWith(
                        fontSize: 15.sp,
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: "sfpro",
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: MyButton(
                  backgroundColor: context.colors.primary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  label: "Select a previous forecast",
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesName.previousForecast);
                  },

                  // isLoading: _yesterdayLoading,
                  // onPressed: _yesterdayLoading ? null : _onSameAsYesterdayTap,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                // FIXED: Removed fixed height constraint so container naturally wraps the rich text content
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.5, -0.6),
                    radius: 1.2,
                    colors: const [Color(0xFFFFFBE6), Color(0xFFFFF9E6)],
                    stops: const [0.0, 0.7],
                  ),
                  border: Border.all(
                    color: const Color(0xFFEBD98F),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text.rich(
                  TextSpan(
                    style: context.typography.body.copyWith(
                      fontSize: 12.sp,
                      fontFamily: "Raleway",
                      color: const Color(0xFF666666),
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: "Emotional forecasting",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555555), // Dark gray emphasis
                        ),
                      ),
                      const TextSpan(
                        text:
                            " is predicting how your planned choices (e.g. a short walk) and unavoidable events (e.g. a tough meeting) might affect how you feel later. It helps you prepare emotionally, respond better, and protect your energy.\n\n",
                      ),
                      const TextSpan(
                        text: "When forecasting, think:\n",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const TextSpan(text: "•  What's on today's calendar?\n"),
                      const TextSpan(text: "•  What emotions can I expect?\n"),
                      const TextSpan(text: "•  What am I aspiring to?\n"),
                      const TextSpan(text: "•  How will I tackle it?\n"),
                      const TextSpan(
                        text: "End of day: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const TextSpan(
                        text: "Reflect on what happened and how you felt.",
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Moved method inside the State class declaration block
  Widget _aspireEmotionBox(BuildContext context) {
    return _emotionBoxShell(
      context,
      title: "You are aspiring to be...",
      titleColor: context.colors.textPrimary,
      isEmpty: _aspirationEmotions.isEmpty,
      tiles: _aspirationEmotions.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          // FIX: Instantiate it as an Emotion type instead of AspirationEmotion
          emotion: Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }

  // FIXED: Moved helper layout constructor inside the class boundary scope
  Widget _emotionBoxShell(
    BuildContext context, {
    required String title,
    required Color titleColor,
    required bool isEmpty,
    required List<Widget> tiles,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.typography.headline.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isEmpty)
            const Text("No emotions recorded")
          else
            Wrap(
              // FIXED: Replaced Row with Wrap to handle grid spacing naturally without overflowing screens horizontally
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.start,
              children: tiles,
            ),
        ],
      ),
    );
  }
}
