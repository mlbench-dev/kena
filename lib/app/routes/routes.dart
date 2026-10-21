import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/routes/unknown_page.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/view/activities/activities_screen.dart';
import 'package:kena_emotional_journey/view/activities/choose_activity.dart';
import 'package:kena_emotional_journey/view/activities/frequency_screen.dart';
import 'package:kena_emotional_journey/view/analytics/analytics_screen.dart';
import 'package:kena_emotional_journey/view/auth/change_password.dart/change_password.dart';
import 'package:kena_emotional_journey/view/auth/forgot_password/forgot_password.dart';
import 'package:kena_emotional_journey/view/auth/forgot_password/reset_password.dart';
import 'package:kena_emotional_journey/view/auth/login.dart';
import 'package:kena_emotional_journey/view/auth/user/email_verification.dart';
// import 'package:kena/view/auth/user/email_verification.dart';
import 'package:kena_emotional_journey/view/auth/user/user_signup.dart';
import 'package:kena_emotional_journey/view/common/walkthroughs.dart';
import 'package:kena_emotional_journey/view/community/empty_community.dart';
import 'package:kena_emotional_journey/view/community/feeds_screen.dart';
import 'package:kena_emotional_journey/view/community/invite_members.dart';
import 'package:kena_emotional_journey/view/community/my_community_screen.dart';
import 'package:kena_emotional_journey/view/emotions/aspirational_emotions.dart';
import 'package:kena_emotional_journey/view/emotions/core_emotions.dart';
import 'package:kena_emotional_journey/view/emotions/emotions_summary.dart';
import 'package:kena_emotional_journey/view/emotions/selected_emotions.dart';
import 'package:kena_emotional_journey/view/forecast/emotional_comparison.dart';
import 'package:kena_emotional_journey/view/forecast/end_day_screen.dart';
import 'package:kena_emotional_journey/view/forecast/forecast_result_screen.dart';
import 'package:kena_emotional_journey/view/forecast/forecast_screen.dart';
import 'package:kena_emotional_journey/view/forecast/plan_activities.dart';
import 'package:kena_emotional_journey/view/forecast/previous_forecast.dart';
import 'package:kena_emotional_journey/view/forecast/questions_screen.dart';
import 'package:kena_emotional_journey/view/forecast/select_today_forecast.dart';
import 'package:kena_emotional_journey/view/forecast/start_forecast.dart';
import 'package:kena_emotional_journey/view/forecast/view_reflections.dart';
// import 'package:kena_emotional_journey/view/home/home_page.dart';
import 'package:kena_emotional_journey/view/home/home_screen.dart';
import 'package:kena_emotional_journey/view/notifications/notifications_screen.dart';
// import 'package:kena_emotional_journey/view/pro_tip/tip_screen.dart';
import 'package:kena_emotional_journey/view/profile/edit_profile.dart';
import 'package:kena_emotional_journey/view/profile/notifications_settings.dart';
import 'package:kena_emotional_journey/view/profile/profile.dart';
import 'package:kena_emotional_journey/view/profile/set_time_screen.dart';
import 'package:kena_emotional_journey/view/splash/splash_screen.dart';
// KenaSplashScreen replaces the old SplashView (see splash_view.dart).
import 'package:kena_emotional_journey/view/subscription/active_subscription_screen.dart';
import 'package:kena_emotional_journey/view/subscription/free_trail.dart';
import 'package:kena_emotional_journey/view/subscription/subscription_plan.dart';

class Routes {
  static String initialRoute() => RoutesName.splash;
  // static String initialRoute() => RoutesName.noConnection;
  static final Map<String, WidgetBuilder> _routes = {
    // RoutesName.splash: (_) => const KenaSplashScreen(),
    RoutesName.splash: (_) => const SplashScreen(),
    // RoutesName.welcome: (_) => const WelcomeScreen(),
    // RoutesName.noConnection: (_) => const NoConnectionScreen(),
    RoutesName.userSignup: (_) => const UserSignupScreen(),
    // RoutesName.vendorSignup: (_) => const VendorSignupScreen(),
    RoutesName.changePassword: (_) => const ChangePasswordScreen(),
    RoutesName.notificationScreen: (_) => const NotificationsScreen(),
    // RoutesName.homePage: (_) => const HomePage(),
    RoutesName.forgotPassword: (_) => const ForgotPassword(),
    RoutesName.activitiesScreen: (_) => const ActivitiesScreen(),
    RoutesName.myCommunity: (_) => const MyCommunityScreen(),
    RoutesName.planAndActivities: (_) => const PlanAndActivities(),
    RoutesName.frequencyScreen: (_) => const FrequencyScreen(),
    RoutesName.notificationsSettings: (_) => const NotificationsSettings(),
    RoutesName.setTime: (_) => const SetTimeScreen(),
    // RoutesName.tipScreen: (_) => const TipScreen(),
    // RoutesName.resetPassword: (_) => const ResetPassword(),
    RoutesName.login: (_) => const LoginScreen(),
    // RoutesName.chooseActivity: (_) => const ChooseActivity(),
    // RoutesName.onboardingScreen: (_) => const OnboardingScreen(),
    // RoutesName.coreEmotions: (_) => const CoreEmotions(),
    // RoutesName.aspirationalEmotions: (_) => const AspirationalEmotions(),
    RoutesName.viewReflections: (_) => const ViewReflections(),
    RoutesName.forecastScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map<String, dynamic> ? args : <String, dynamic>{};
      final forecast = map['forecast'] as Forecast?;
      final isFromHome = map['isFromHome'] as bool? ?? false;
      return ForecastScreen(forecast: forecast, isFromHome: isFromHome);
    },
    // RoutesName.community: (_) => const CommunityScreen(),
    RoutesName.emptyCommunity: (_) => const EmptyCommunityScreen(),
    RoutesName.walkthroughscreen: (context) => HomeWalkthroughScreen(
      onFinished: () {
        // Navigates directly to your Home Screen route cleanly
        Navigator.pushReplacementNamed(context, RoutesName.login);
      },
    ),
    RoutesName.analyticsScreen: (_) => const AnalyticsScreen(),
    RoutesName.profile: (_) => const ProfileScreen(),
    RoutesName.endDayReflection: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map<String, dynamic> ? args : <String, dynamic>{};
      final isFromHome = map['isFromHome'] as bool? ?? false;
      return EndDayReflectionScreen(isFromHome: isFromHome);
    },
    RoutesName.homeScreen: (_) => const HomeScreen(),
    // RoutesName.aspireScreen: (_) => const AspireScreen(),
    RoutesName.selectedEmotionsScreen: (_) => const SelectedEmotionsScreen(),
    RoutesName.emotionsSummary: (_) => const EmotionsSummary(),
    RoutesName.questionsScreen: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return QuestionsScreen(
        selectedEmotions:
            args?['selectedEmotions'] as List<Map<String, dynamic>>? ?? [],
        notes: args?['notes'] as String?,
      );
    },
    RoutesName.startForecastScreen: (_) => const StartForecastScreen(),
    // RoutesName.selectTodayForecast: (_) => const SelectTodayForecast(),
    RoutesName.previousForecast: (_) => const PreviousForecastScreen(),
    // RoutesName.forecastCompletedScreen: (_) => const ForecastCompletedScreen(),
    RoutesName.endDayComparisonScreen: (_) => const EndOfDayComparisonScreen(),
    // RoutesName.selectedActivities: (_) => const SelectedActivitiesScreen(),
    RoutesName.inviteMembers: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final communityId = args is String ? args : '';
      return InviteMembersScreen(communityId: communityId);
    },
    // RoutesName.feedScreen: (_) => const FeedsScreen(),
    // RoutesName.commentsScreen: (_) => const CommentBottomSheet(),
    RoutesName.editProfile: (_) => const EditProfileScreen(),
    RoutesName.activeSubscription: (_) => const ActiveSubscriptionScreen(),
    RoutesName.freeTrail: (_) => const FreeTrailScreen(),
    RoutesName.subscriptionPlan: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final showBackButton =
          args is Map<String, dynamic> && args['showBackButton'] == true;
      final isTrial = args is Map<String, dynamic> && args['isTrial'] == true;
      return SubscriptionPlanScreen(
        showBackButton: showBackButton,
        isTrial: isTrial,
      );
    },
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    log(
      'Navigating to: ${settings.name}\t - ${settings.arguments}',
      name: 'RouteGenerator',
    );
    switch (settings.name) {
      // case RoutesName.doctorOnboarding:
      //   final args = _getArgs(settings, requiredKeys: ['showBack']);
      //   return MaterialPageRoute(
      //     builder: (_) =>
      //         DoctorOnboardingFlowScreen(showBack: args['showBack'] as bool),
      //   );

      // case RoutesName.login:
      //   // final args = _getArgs(settings, requiredKeys: ['isVendor']);
      //   return MaterialPageRoute(
      //     builder: (_) => LoginScreen(
      //       // isVendor: args['isVendor'] as bool
      //     ),
      //   );

      // case RoutesName.forgotPassword:
      //   // final args = _getArgs(settings, requiredKeys: ['isVendor']);
      //   return MaterialPageRoute(
      //     builder: (_) =>
      //         // ForgotPasswordScreen(isVendor: args['isVendor'] as bool),
      //   );

      case RoutesName.newPassword:
        final args = _getArgs(settings, requiredKeys: ['email', 'otp']);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              ResetPassword(email: args['email'] as String, otp: args['otp']),
        );
      case RoutesName.emailVerification:
        final email = settings.arguments as String;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EmailVerification(email: email),
        );
      // case RoutesName.myCommunity:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   final communityId = args['communityId'] as String;
      //   final communityName = args['communityName'] as String;
      case RoutesName.feedScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        final communityId = args?['communityId'] as String? ?? '';
        final communityName = args?['communityName'] as String? ?? '';

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FeedsScreen(
            communityId: communityId,
            communityName: communityName,
          ),
        );
      case RoutesName.selectTodayForecast:
        final args = settings.arguments as Map<String, dynamic>?;
        final date = args?['date'] as DateTime? ?? DateTime.now();

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SelectTodayForecast(date: date),
        );
      case RoutesName.coreEmotions:
        final args = settings.arguments as Map<String, dynamic>?;
        final isFromHome = args?['isFromHome'] as bool? ?? false;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CoreEmotions(isFromHome: isFromHome),
        );
      case RoutesName.aspirationalEmotions:
        final args = settings.arguments as Map<String, dynamic>?;
        final isFromHome = args?['isFromHome'] as bool? ?? false;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AspirationalEmotions(isFromHome: isFromHome),
        );
      case RoutesName.chooseActivity:
        final args = settings.arguments as Map<String, dynamic>?;
        final isToday = args?['isToday'] as bool? ?? true;
        final isFromForecast = args?['isFromForecast'] as bool? ?? true;
        final navigateToSummaryAfterSave =
            args?['navigateToSummaryAfterSave'] as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChooseActivity(
            isToday: isToday,
            isFromForecast: isFromForecast,
            navigateToSummaryAfterSave: navigateToSummaryAfterSave,
          ),
        );
      case RoutesName.forecastResultScreen:
        final args = settings.arguments;
        final forecastData = args is ForecastData ? args : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ForecastResultScreen(forecastData: forecastData),
        );
      default:
        final builder = _routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return MaterialPageRoute(builder: (_) => const UnknownRouteScreen());
    }
  }

  static Map<String, dynamic> _getArgs(
    RouteSettings settings, {
    required List<String> requiredKeys,
  }) {
    try {
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      for (final key in requiredKeys) {
        if (!args.containsKey(key)) {
          log('Missing argument key "$key" for route ${settings.name}');
        }
      }
      return args;
    } catch (e) {
      log('Invalid arguments for route ${settings.name}: $e');
      return {};
    }
  }
}
