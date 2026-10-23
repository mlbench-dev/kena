import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/data/exception/app_exceptions.dart';
import 'package:kena_emotional_journey/app/data/response/api_response.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/model/activites/activities_model.dart';
import 'package:kena_emotional_journey/model/activites/planned_activity_model.dart';
import 'package:kena_emotional_journey/model/activites/today_activity_model.dart';
import 'package:kena_emotional_journey/model/analytics/all_time_activities.dart';
import 'package:kena_emotional_journey/model/analytics/analytics_calendar_model.dart';
import 'package:kena_emotional_journey/model/analytics/analytics_model.dart';
import 'package:kena_emotional_journey/model/analytics/forecast_plan_activities.dart';
import 'package:kena_emotional_journey/model/analytics/month_data_model.dart';
import 'package:kena_emotional_journey/model/analytics/monthly_activities_model.dart'
    show MonthlyActivitiesModel;
import 'package:kena_emotional_journey/model/analytics/overall_alltime_model.dart';
import 'package:kena_emotional_journey/model/analytics/overall_monthly_model.dart';
import 'package:kena_emotional_journey/model/analytics/overall_weekly_model.dart';
import 'package:kena_emotional_journey/model/analytics/weekly_activities_model.dart'
    show WeeklyActivitiesModel;
import 'package:kena_emotional_journey/model/community/communities_model.dart';
import 'package:kena_emotional_journey/model/community/community_detail_model.dart';
import 'package:kena_emotional_journey/model/community/community_members_model.dart';
import 'package:kena_emotional_journey/model/community/daily_feed_model.dart';
import 'package:kena_emotional_journey/model/community/feed_model.dart';
import 'package:kena_emotional_journey/model/community/invitations_model.dart';
import 'package:kena_emotional_journey/model/community/bulk_invite_model.dart';
import 'package:kena_emotional_journey/model/community/invite_link_model.dart';
import 'package:kena_emotional_journey/model/community/user_community.dart';
import 'package:kena_emotional_journey/model/community/weekly_feed_model.dart'
    show WeeklyFeedModel;
import 'package:kena_emotional_journey/model/emotions/result_emotion_model.dart';
import 'package:kena_emotional_journey/model/forecast/comparison_model.dart';
import 'package:kena_emotional_journey/model/forecast/end_day_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_history_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_notes.dart';
import 'package:kena_emotional_journey/model/user/user_home_model.dart';
import 'package:kena_emotional_journey/repository/user_home_repo.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

class UserHomeService {
  //   final BaseApiServices api = NetworkApiService();

  final UserHomeRepository _userHomeRepo = UserHomeRepository();
  final String tag = '[UserHomeService]';

  //   ///
  //   ///gotoNotifications
  //   ///

  //   final _userAuthRepo = UserAuthRepository();
  //   static void gotoNotifications(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.notificationScreen);
  //   }

  //   ///
  //   ///gotoSearch
  //   ///
  //   static void gotoSearch(BuildContext context) {
  //     Navigator.pushNamed(context, RoutesName.userSearch);
  //   }

  //   ///
  //   ///gotoVendorMenu
  //   ///
  //   static void gotoVendorMenu(BuildContext context, List<MenuItemModel>? menu) {
  //     Navigator.pushNamed(
  //       context,
  //       arguments: {'menu': menu},
  //       RoutesName.userMenu,
  //     );
  //   }

  //   ///
  //   ///getNearbyVendors
  //   ///
  //   Future<List<VendorModel>> getNearbyVendors({
  //     required BuildContext context,
  //     required LatLng? location,
  //     required double maxDistance, // kilometers
  //   }) async {
  //     if (location == null) {
  //       debugPrint('❌ User location is null');
  //       return [];
  //     }

  //     try {
  //       final queryParams = {
  //         'lat': location.latitude,
  //         'lng': location.longitude,
  //         'maxDistance': maxDistance,
  //       };

  //       final queryString = api.buildQueryString(queryParams);

  //       final response = await _userHomeRepo.getNearbyVendors(query: queryString);

  //       debugPrint('✅ Nearby vendors fetched successfully!');

  //       // --- IMPORTANT PART ---
  //       // Convert list<dynamic> → List<VendorModel>
  //       if (response['vendors'] is List) {
  //         return (response['vendors'] as List)
  //             .map((json) => VendorModel.fromJson(json))
  //             .toList();
  //       }

  //       return [];
  //     } catch (e) {
  //       if (context.mounted) {
  //         ErrorHandler.handle(context, e, serviceName: tag);
  //       }
  //       return [];
  //     }
  //   }

  //   ///
  //   ///getVendorDetails
  //   ///
  //   Future<VendorModel?> getVendorDetails({
  //     required BuildContext context,
  //     required String vendorId,
  //   }) async {
  //     try {
  //       final response = await _userHomeRepo.getVendorDetails(vendorId: vendorId);
  //       debugPrint('vendor deails $response');
  //       debugPrint('✅ Vendor Details fetched successfully!');

  //       return VendorModel.fromJson(response['vendor']);
  //     } catch (e) {
  //       if (context.mounted) {
  //         ErrorHandler.handle(context, e, serviceName: tag);
  //       }
  //       return null;
  //     }
  //   }

  //   static void gotoReviews(
  //     BuildContext context, {
  //     bool isVendor = true,
  //     required String vendorId,
  //   }) {
  //     Navigator.pushNamed(
  //       context,
  //       arguments: {'isVendor': isVendor, 'vendorId': vendorId},
  //       RoutesName.reviews,
  //     );
  //   }

  //   ///
  //   ///getVendorReviews
  //   ///
  //   Future<ReviewsModel?> getVendorReviews(
  //     BuildContext context, {
  //     required String vendorId,
  //   }) async {
  //     try {
  //       //TODO: pagination
  //       final response = await _userHomeRepo.getVendorReviews(
  //         vendorId: vendorId,
  //         query: '?page=1&limit=99',
  //       ); //pagination will be later
  //       return ReviewsModel.fromJson(response);
  //     } catch (e) {
  //       if (context.mounted) {
  //         ErrorHandler.handle(context, e, serviceName: tag);
  //       }
  //       return null;
  //     }
  //   }

  //   Future<UserReviewsResponse?> getUserReviews(BuildContext context) async {
  //     try {
  //       final user = SessionController().user;
  //       if (user == null || user.id == null) {
  //         throw Exception("User session not found or user ID is missing");
  //       }

  //       final response = await _userHomeRepo.getUserReviews();
  //       return UserReviewsResponse.fromJson(response);
  //     } catch (e) {
  //       if (context.mounted) {
  //         ErrorHandler.handle(context, e, serviceName: tag);
  //       }
  //       return null;
  //     }
  //   }
  // Get Weekly Activites
  Future<WeeklyActivitiesModel?> getWeeklyActivites(
    BuildContext context,
  ) async {
    try {
      final response = await _userHomeRepo.getWeeklyActivites();
      return WeeklyActivitiesModel.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Overall Weekly
  Future<OverallWeeklyModel?> getOverallWeekly(BuildContext context) async {
    try {
      final response = await _userHomeRepo.getOverallWeekly();
      return OverallWeeklyModel.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Overall Monthly
  Future<OverallMonthlyModel?> getOverallMonthly(BuildContext context) async {
    try {
      final response = await _userHomeRepo.getOverallMonthly();
      return OverallMonthlyModel.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Overall All Time
  Future<OverallAlltimeModel?> getOverallAllTime(BuildContext context) async {
    try {
      final response = await _userHomeRepo.getOverallAlltime();
      return OverallAlltimeModel.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get All Time Activites
  Future<AllTimeActivities?> getAlltimeActivites(BuildContext context) async {
    try {
      final response = await _userHomeRepo.getAlltimeActivites();
      return AllTimeActivities.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  Future<MonthlyActivitiesModel?> getMonthlyActivites(
    BuildContext context,
  ) async {
    try {
      final response = await _userHomeRepo.getMonthlyActivites();
      return MonthlyActivitiesModel.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  //   ///
  //   ///addToFavorites
  //   ///
  //   Future<void> addToFavorites(
  //     BuildContext context, {
  //     required String vendorId,
  //   }) async {
  //     try {
  //       await _userHomeRepo.addToFavorites(vendorId: vendorId);
  //       if (context.mounted) {
  //         await AuthService().fetchProfile(context);
  //       }
  //     } catch (e) {
  //       if (context.mounted) {
  //         ErrorHandler.handle(context, e, serviceName: tag);
  //       }
  //     }
  //   }

  // Add Core Emotions
  Future<bool> addCoreEmotions({
    required BuildContext context,
    required List<Map<String, dynamic>> emotions,
  }) async {
    try {
      await _userHomeRepo.addCoreEmotions(emotions: emotions);
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Add Forecast
  Future<bool> forecast({
    required BuildContext context,
    required List<Map<String, dynamic>> emotions,
    required String plan,
    required String notes,
  }) async {
    try {
      final data = {"emotions": emotions, "plan": plan, "notes": notes};
      await _userHomeRepo.forecast(data: data);
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Add End of Day Reflection
  Future<bool> endOfDay({
    required BuildContext context,
    required List<Map<String, dynamic>> emotions,
    required bool wentAsForecast,
    required bool planUseful,
    required String planFeedback,
    required int compareToForecast,
    String? checkInType, // "quick" or "full"
    Map<String, String>? checkInAnswers,
  }) async {
    try {
      final now = DateTime.now();
      final day =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final data = {
        "day": day,
        "emotions": emotions,
        "wentAsForecast": wentAsForecast,
        "planUseful": planUseful,
        "compareToForecast": compareToForecast,
        "checkInType": ?checkInType,
        "checkInAnswers": ?checkInAnswers,
      };

      await _userHomeRepo.endOfDay(data: data);
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // User Details for Home Page
  ///
  ///getVendorDetails
  ///
  Future<UserHomeModel?> getUserDetails({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getUserDetails();

      debugPrint('User Details Raw: $response');

      // ✅ Convert Map → Model
      final model = UserHomeModel.fromJson(response);

      debugPrint('✅ User Details parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Share Forecast
  Future<bool> shareForecast({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await _userHomeRepo.shareForecast(email: email);
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Forecast as yesterday
  Future<bool> forecastAsYesterday({required BuildContext context}) async {
    try {
      await _userHomeRepo.forecastAsYesterday();
      if (context.mounted) {
        context.flushBarSuccessMessage(
          message: "Your forecast was copied from yesterday.",
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///getCommunityDetails
  ///
  Future<UserCommunity?> getUserCommunity({
    required String communityId,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getUserCommunity(
        communityId: communityId,
      );

      debugPrint('User Community Raw: $response');

      // ✅ Convert Map → Model
      final model = UserCommunity.fromJson(response);

      debugPrint('✅ User Details parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///Get Yestarday Forecasts
  ///
  Future<ForecastHistoryModel?> getYestardayForecasts({
    required String date,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getYesterdayForecasts(date: date);

      debugPrint('Yesterday Forecasts Raw: $response');

      // ✅ Convert Map → Model
      final model = ForecastHistoryModel.fromJson(response);

      debugPrint('✅ Yesterday Forecasts parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getCommunity Feed
  ///
  Future<FeedModel?> getCommunityFeed({
    required String communityId,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getCommunityFeed(
        communityId: communityId,
      );

      debugPrint('User Community Raw: $response');

      // ✅ Convert Map → Model
      final model = FeedModel.fromJson(response);

      debugPrint('✅ User Details parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getDaily Feed
  ///
  Future<DailyFeedModel?> getDailyFeed({
    required String communityId,
    String scope = 'me',
    String? date,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getDailyFeed(
        communityId: communityId,
        scope: scope,
        date: date,
      );

      debugPrint('Daily Feed Raw: $response');

      // ✅ Convert Map → Model
      final model = DailyFeedModel.fromJson(response);

      debugPrint('✅ Daily Feed parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getWeekly Feed
  ///
  Future<WeeklyFeedModel?> getWeeklyFeed({
    required String communityId,
    String scope = 'me',
    String? date,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getWeeklyFeed(
        communityId: communityId,
        scope: scope,
        date: date,
      );

      debugPrint('Weekly Feed Raw: $response');

      return WeeklyFeedModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getFeedLikes
  ///
  Future<List<Map<String, dynamic>>> getFeedLikes({
    required String feedId,
    required String communityId,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getFeedLikes(
        feedId: feedId,
        communityId: communityId,
      );

      debugPrint('Feed Likes Raw: $response');

      if (response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return [];
    }
  }

  ///
  ///sendAppUsage
  ///
  Future<Map<String, dynamic>> sendAppUsage({
    required String appIdentifier,
    required String platform,
    String? appName,
    String? category,
    String? day,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "appIdentifier": appIdentifier,
        "platform": platform,
        "appName": ?appName,
        "category": ?category,
        "day": day ?? DateTime.now().toIso8601String().split("T")[0],
      };

      final response = await _userHomeRepo.appUsageTime(data: data);

      return response;
    } catch (e) {
      throw Exception("AppUsageService Error: $e");
    }
  }

  ///
  ///toggleFeedLike
  ///
  Future<Map<String, dynamic>?> toggleFeedLike({
    required String feedId,
    required String communityId,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.toggleFeedLike(
        feedId: feedId,
        communityId: communityId,
      );

      debugPrint('Toggle Like Raw: $response');

      if (response['success'] == true && response['data'] is List) {
        final dataList = response['data'] as List;
        if (dataList.isNotEmpty) {
          return Map<String, dynamic>.from(dataList.first);
        }
      }
      return null;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getFeedComments
  ///
  Future<List<Map<String, dynamic>>> getFeedComments({
    required String entryOwnerId,
    required String communityId,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getFeedComments(
        entryOwnerId: entryOwnerId,
        communityId: communityId,
      );

      debugPrint('Feed Comments Raw: $response');

      if (response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return [];
    }
  }

  ///
  ///postFeedComment
  ///
  Future<Map<String, dynamic>?> postFeedComment({
    required String entryOwnerId,
    required String communityId,
    required String content,
    BuildContext? context,
  }) async {
    try {
      final data = {'communityId': communityId, 'content': content};

      final response = await _userHomeRepo.postFeedComment(
        entryOwnerId: entryOwnerId,
        data: data,
      );

      debugPrint('Post Comment Raw: $response');

      if (response['success'] == true && response['data'] is List) {
        final dataList = response['data'] as List;
        if (dataList.isNotEmpty) {
          return Map<String, dynamic>.from(dataList.first);
        }
      }
      return null;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Add Aspire Note
  Future<Map<String, dynamic>?> addAspireNote({
    BuildContext? context,
    required DateTime day,
    required String note,
  }) async {
    try {
      final data = {'day': DateFormat('yyyy-MM-dd').format(day), 'notes': note};

      final response = await _userHomeRepo.addAspireNote(data: data);

      debugPrint('Add Note Response: $response');

      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }

      return null;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Add Forecast Note
  Future<Map<String, dynamic>?> addForecastNote({
    BuildContext? context,
    required DateTime day,
    required String note,
  }) async {
    try {
      final data = {'day': DateFormat('yyyy-MM-dd').format(day), 'note': note};

      final response = await _userHomeRepo.addForecastNote(data: data);

      debugPrint('Add Forecast Note Response: $response');

      if (response['success'] == true) {
        return response;
      }

      return null;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  Future<ForecastNotes?> getForecastNotes({
    BuildContext? context,
    required DateTime day,
  }) async {
    try {
      final formattedDay = DateFormat('yyyy-MM-dd').format(day);
      final response = await _userHomeRepo.getForecastNotes(day: formattedDay);

      debugPrint('Get Forecast Notes Raw: $response');

      if (response['success'] == true) {
        return ForecastNotes.fromJson(response);
      }

      return null;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///removeCommunityMember
  ///
  Future<bool> removeCommunityMember({
    required String memberId,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.removeCommunityMember(
        memberId: memberId,
      );

      debugPrint('Remove Member Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  /// Delete Notification
  ///
  Future<bool> deleteNotification({
    required String notificationId,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deleteNotification(
        notificationId: notificationId,
      );
      debugPrint('Notification Deleted Raw: $response');
      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///acceptInvite
  ///
  Future<bool> acceptInvite({
    required String inviteId,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.acceptInvite(inviteId: inviteId);

      debugPrint('Accept Invite Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///declineInvite
  ///
  Future<bool> declineInvite({
    required String inviteId,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.declineInvite(inviteId: inviteId);

      debugPrint('Decline Invite Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///removeActivity
  ///
  Future<bool> deletePlannedActivity({
    required String name,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deletePlannedActivity(
        name: name,
        isPlanned: true,
      );

      debugPrint('Remove Activity Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///deleteTodayActivity — DELETE /activities/forecast
  ///
  Future<bool> deleteTodayActivity({
    required String name,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deleteTodayActivity(
        name: name,
        isPlanned: false,
      );

      debugPrint('Delete Today Activity Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///getCommunityMembers
  ///
  Future<CommunityMembers?> getCommunityMembers({
    required String communityId,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.getCommunityMembers(
        communityId: communityId,
      );

      debugPrint('Get Community Members Raw: $response');

      return CommunityMembers.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getCommunityMembers
  ///
  Future<CommunityMembers?> getForecastCommunityMembers({
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.getForecastCommunityMembers();

      debugPrint('Get Community Members Raw: $response');

      return CommunityMembers.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getCommunityInvitations
  ///
  Future<InvitationsModel?> getInvitations({
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.getInvitations();

      debugPrint('Get Community Invitations Raw: $response');

      return InvitationsModel.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Aspire Notes
  Future<List<Map<String, dynamic>>> getAspireNotes({
    required BuildContext context,
    required DateTime day,
  }) async {
    try {
      final formattedDay = DateFormat('yyyy-MM-dd').format(day);

      final response = await _userHomeRepo.getAspireNotes(day: formattedDay);

      debugPrint('Get Aspire Notes Raw: $response');

      if (response['success'] == true && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return [];
    }
  }

  ///
  ///sendInviteToMembers
  ///
  Future<bool> sendInviteToMembers({
    required List<String> memberIds,
    required String day,
    required String message,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.sendInviteToMembers(
        memberIds: memberIds,
        day: day,
        message: message,
      );

      debugPrint('Send Invite To Members Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  /// shareWeeklyForecast — POST /api/journal/share/weekly
  ///
  Future<bool> shareWeeklyForecast({
    required List<String> memberIds,
    String? endDate,
    String? message,
    String? communityId,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.shareWeeklyForecast(
        memberIds: memberIds,
        endDate: endDate,
        message: message,
        communityId: communityId,
      );

      debugPrint('Share Weekly Forecast Raw: $response');

      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  /// getSharedMembers — GET /api/journal/forecast/shared-users
  ///
  /// Pass `range: 'week'` and the feed's [endDate] to get who the weekly
  /// forecast is shared with; omit both for the daily forecast.
  Future<CommunityMembers?> getSharedMembers({
    required BuildContext context,
    String? range,
    String? endDate,
  }) async {
    try {
      final response = await _userHomeRepo.getStopSharingMembers(
        range: range,
        endDate: endDate,
      );
      debugPrint('Get Shared Members Raw: $response');

      // Debug: inspect the actual keys in each user object
      final rawData = response['data'];
      if (rawData is List && rawData.isNotEmpty) {
        debugPrint(
          '🔍 First shared user keys: ${(rawData[0] as Map).keys.toList()}',
        );
        debugPrint('🔍 First shared user data: ${rawData[0]}');
      }

      return CommunityMembers.fromJson(response);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  /// stopSharingForecast — POST /api/journal/forecast/stop-sharing
  ///
  Future<bool> stopSharingForecast({
    required List<String> userIds,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.stopSharingForecast(
        userIds: userIds,
      );
      debugPrint('Stop Sharing Forecast Raw: $response');
      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  /// stopSharingWeeklyForecast — POST /api/journal/forecast/stop-sharing-weekly
  ///
  /// Returns the weekly forecast's sharing status after the call (from the
  /// response's `isWeeklyShared`, `false` if the server omits it), or `null`
  /// when the request failed.
  Future<bool?> stopSharingWeeklyForecast({
    String? endDate,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.stopSharingWeeklyForecast(
        endDate: endDate,
      );
      debugPrint('Stop Sharing Weekly Forecast Raw: $response');
      if (response['success'] != true) {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Failed to stop sharing',
            serviceName: tag,
          );
        }
        return null;
      }
      final data = response['data'];
      final first = data is List && data.isNotEmpty ? data.first : data;
      final isWeeklyShared =
          response['isWeeklyShared'] ??
          (first is Map ? first['isWeeklyShared'] : null);
      return isWeeklyShared == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///updateCommunity
  ///
  Future<bool> updateCommunity({
    required String communityId,
    required String name,
    required String description,
    required BuildContext context,
  }) async {
    try {
      final data = {"name": name, "description": description};
      await _userHomeRepo.updateCommunity(communityId: communityId, data: data);
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  //Update Notes of the Day Forecast
  Future<bool> updateNotesOfTheDay({
    String? notes,
    String? plan,
    required BuildContext context,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (notes != null) data['notes'] = notes;
      if (plan != null) data['plan'] = plan;
      await _userHomeRepo.updateNotesOfTheDay(data: data);
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  //Update End Day
  Future<bool> updateEndDay({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.updateEndDay(data: data);

      // ✅ Convert to model HERE (not in repo)
      final model = EndDayModel.fromJson(response);

      if (model.success == true) {
        return true;
      } else {
        throw Exception(model.message);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Update Forecast
  Future<bool> updateForecast({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.updateForecast(data: data);

      // ✅ Convert response → Model
      final model = ForecastModel.fromJson(response);

      if (model.success == true) {
        return true;
      } else {
        throw Exception(model.message);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Delete Forecast Emotions
  Future<ApiResponse<bool>> deleteForecastEmotions({
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deleteForecastEmotions();

      if (response['success'] == true) {
        return const ApiResponse.completed(true);
      } else {
        return ApiResponse.error(response['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return ApiResponse.error(e.toString());
    }
  }

  // Delete Reflection Emotion
  Future<ApiResponse<bool>> deleteReflectionEmotion({
    required String date,
    required String key,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deleteReflectionEmotion(
        date: date,
        key: key,
      );

      if (response['success'] == true) {
        return const ApiResponse.completed(true);
      } else {
        return ApiResponse.error(response['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return ApiResponse.error(e.toString());
    }
  }

  // Update Forecast
  Future<ApiResponse<bool>> updateForecastImages({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.updateForecastImages(data: data);

      if (response['success'] == true) {
        return const ApiResponse.completed(true);
      } else {
        return ApiResponse.error(response['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return ApiResponse.error(e.toString());
    }
  }

  // Update Forecast
  Future<ApiResponse<bool>> updateEndDayImages({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.updateEndDayImages(data: data);

      if (response['success'] == true) {
        return const ApiResponse.completed(true);
      } else {
        return ApiResponse.error(response['message'] ?? "Something went wrong");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return ApiResponse.error(e.toString());
    }
  }

  // Update Core Images
  Future<ApiResponse<bool>> updateCoreImages({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.updateCoreImages(data: data);

      debugPrint("updateCoreImages response: $response");

      if (response != null && response is Map && response['success'] == true) {
        return const ApiResponse.completed(true);
      }

      return ApiResponse.error(
        response?['message']?.toString() ?? "Something went wrong",
      );
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }

      debugPrint("updateCoreImages error: $e");

      return ApiResponse.error(e.toString());
    }
  }

  // Delete Core Emotion
  Future<ApiResponse<bool>> deleteCoreEmotion({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deleteCoreEmotion(data: data);

      debugPrint("deleteCoreEmotion response: $response");

      if (response != null && response is Map && response['success'] == true) {
        return const ApiResponse.completed(true);
      }

      return ApiResponse.error(
        response?['message']?.toString() ?? "Something went wrong",
      );
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }

      debugPrint("deleteCoreEmotion error: $e");

      return ApiResponse.error(e.toString());
    }
  }

  // Update Aspiration Images
  Future<ApiResponse<bool>> updateAspirationImages({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.updateAspirationImages(data: data);

      debugPrint("updateAspirationImages response: $response");

      if (response != null && response is Map && response['success'] == true) {
        return const ApiResponse.completed(true);
      }

      return ApiResponse.error(
        response?['message']?.toString() ?? "Something went wrong",
      );
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }

      debugPrint("updateCoreImages error: $e");

      return ApiResponse.error(e.toString());
    }
  }

  // Delete Aspiration Emotion
  Future<ApiResponse<bool>> deleteAspirationEmotion({
    required Map<String, dynamic> data,
    required BuildContext context,
  }) async {
    try {
      final response = await _userHomeRepo.deleteAspirationEmotion(data: data);

      debugPrint("deleteAspirationEmotion response: $response");

      if (response != null && response is Map && response['success'] == true) {
        return const ApiResponse.completed(true);
      }

      return ApiResponse.error(
        response?['message']?.toString() ?? "Something went wrong",
      );
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }

      debugPrint("deleteAspirationEmotion error: $e");

      return ApiResponse.error(e.toString());
    }
  }

  ///
  ///getCommunities
  ///
  Future<CommunitiesModel?> getCommunities({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getCommunities();

      debugPrint('User Communities Raw: $response');

      // ✅ Convert Map → Model
      final model = CommunitiesModel.fromJson(response);

      debugPrint('✅ User Communities parsed successfully!');

      if (model.data != null && model.data!.isNotEmpty) {
        try {
          final ownCommunity = model.data!.firstWhere((c) => c.isOwner == true);
          final commId = ownCommunity.community?.id;
          if (commId != null) {
            SessionController().saveCommunityId(communityId: commId);
          }
        } catch (_) {}
      }

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///getCommunityDetails
  ///
  Future<CommunityDetailModel?> getUserCommunityDetails({
    required String communityId,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getCommunityDetails(
        communityId: communityId,
      );

      debugPrint('User Community Raw: $response');

      // ✅ Convert Map → Model
      final model = CommunityDetailModel.fromJson(response);

      debugPrint('✅ User Details parsed successfully!');

      return model;
    } on NotFoundException {
      await SessionController().clearCommunityId();
      return null;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  ///
  ///Get Emotions
  ///
  Future<ResultEmotionModel?> getUserEmotions({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getUserEmotions();

      debugPrint('User Emotions Raw: $response');

      // ✅ Convert Map → Model
      final model = ResultEmotionModel.fromJson(response);

      debugPrint('✅ User Details parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  /// Fetches core emotions, aspirational emotions, activities, and daily notes
  /// for a specific [day] via GET /api/journal/selection?day=YYYY-MM-DD.
  /// If [day] is null the server defaults to today.
  Future<ResultEmotionModel?> getJournalSelection({
    BuildContext? context,
    DateTime? day,
  }) async {
    try {
      final formattedDay = day != null
          ? DateFormat('yyyy-MM-dd').format(day)
          : null;

      final response = await _userHomeRepo.getJournalSelection(
        day: formattedDay,
      );

      debugPrint('Journal Selection Raw: $response');

      final model = ResultEmotionModel.fromJson(response);

      debugPrint('✅ Journal Selection parsed successfully!');

      return model;
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  Future<ForecastModel?> getForecast({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getForecast();
      debugPrint('Forecast Raw: $response');
      return ForecastModel.fromJson(response);
    } catch (e) {
      // 404 "forecast not found" is expected for users who haven't set one up yet.
      final msg = e.toString().toLowerCase();
      if (msg.contains('not found') || msg.contains('forecast')) {
        debugPrint('[$tag] ℹ️ No forecast data yet (expected)');
        return null;
      }
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  Future<EndDayModel?> getEndDay({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getEndDay();
      debugPrint('End Day Raw: $response');
      return EndDayModel.fromJson(response);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('not found') || msg.contains('end day')) {
        debugPrint('[$tag] ℹ️ No end-of-day data yet (expected)');
        return null;
      }
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  Future<ComparisonModel?> getComparison({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getComparison();
      debugPrint('Comparison Raw: $response');
      return ComparisonModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Analytics
  Future<AnalyticsModel?> getAnalytics({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getAnalytics();
      debugPrint('Analytics Raw: $response');
      return AnalyticsModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Analytics Calendar
  Future<AnalyticsCalendarModel?> getAnalyticsCalendar({
    required String day,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getAnalyticsCalendar(day: day);
      debugPrint('Analytics Calendar Raw: $response');
      return AnalyticsCalendarModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Calendar Month Analytics
  Future<MonthDataModel?> getCalendarMonthAnalytics({
    required String month,
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getCalendarMonthAnalytics(
        month: month,
      );
      debugPrint('Calendar Month Analytics Raw: $response');
      return MonthDataModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  Future<PlannedActivityModel?> getPlannedActivities({
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getPlannedActivities();
      debugPrint('Planned Activities Raw: $response');
      return PlannedActivityModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Future<PlannedActivityModel?> getForecastActivities({
  //   BuildContext? context,
  // }) async {
  //   try {
  //     final response = await _userHomeRepo.getForecastActivities();
  //     debugPrint('Forecast Activities Raw: $response');
  //     return PlannedActivityModel.fromJson(response);
  //   } catch (e) {
  //     if (context != null && context.mounted) {
  //       ErrorHandler.handle(context, e, serviceName: tag);
  //     }
  //     return null;
  //   }
  // }

  /// Names of all the user's current activities, Today and Planned combined.
  /// Used to enforce the Freemium activity limit.
  Future<List<String>> getAllActivityNames({BuildContext? context}) async {
    final results = await Future.wait([
      getTodayActivities(context: context),
      getPlannedActivities(context: context),
    ]);
    final today = results[0] as TodayActivityModel?;
    final planned = results[1] as PlannedActivityModel?;
    return [
      for (final day in today?.data ?? const <TodayActivityData>[])
        for (final activity in day.activities ?? const [])
          if (activity.name != null) activity.name!,
      for (final day in planned?.data ?? const <PlannedActivityData>[])
        for (final activity in day.activities ?? const [])
          if (activity.name != null) activity.name!,
    ];
  }

  // Get Today Activities
  Future<TodayActivityModel?> getTodayActivities({
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getTodayActivities();
      debugPrint('Today Activities Raw: $response');
      return TodayActivityModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get ForecastPlan Activities
  Future<ForecastPlanActivities?> getForecastPlanActivities({
    BuildContext? context,
  }) async {
    try {
      final response = await _userHomeRepo.getForecastPlanActivities();
      debugPrint('ForecastPlan Activities Raw: $response');
      return ForecastPlanActivities.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Today Activities
  Future<ActivitiesModel?> getActivities({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getActivities();
      debugPrint('Activities Raw: $response');
      return ActivitiesModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Get Invite Link
  Future<InviteLinkModel?> getInviteLink({BuildContext? context}) async {
    try {
      final response = await _userHomeRepo.getInviteLink();
      debugPrint('Invite Link Raw: $response');
      return InviteLinkModel.fromJson(response);
    } catch (e) {
      if (context != null && context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Add Aspirational Emotions

  // Future<bool> addAspirationalEmotions({
  //   required BuildContext context,
  //   required List<Map<String, dynamic>> emotions,
  //   required DateTime? reassessDate,
  // }) async {
  //   try {
  //     final data = {
  //       "emotions": emotions,
  //       "reassessDate": reassessDate != null
  //           ? DateFormat('yyyy-MM-dd').format(reassessDate)
  //           : null,
  //     };

  //     await _userHomeRepo.addAspirationalEmotions(data: data);

  //     return true;
  //   } catch (e) {
  //     if (context.mounted) {
  //       ErrorHandler.handle(context, e, serviceName: tag);
  //     }
  //     return false;
  //   }
  // }
  Future<bool> addAspirationalEmotions({
    required BuildContext context,
    required List<Map<String, dynamic>> emotions,
    required DateTime? reassessDate,
    // List<Map<String, dynamic>>? activities, // ✅ new optional parameter
  }) async {
    try {
      // If no activities provided, send a default placeholder to satisfy backend
      // final activityList = (activities != null && activities.isNotEmpty)
      //     ? activities
      //     : [
      //         {
      //           'id': 'default-activity',
      //           'name': 'Default Activity', // You can replace this text
      //         },
      //       ];

      final data = {
        "emotions": emotions,
        "reassessDate": reassessDate != null
            ? DateFormat('yyyy-MM-dd').format(reassessDate)
            : null,
        // "activities": activityList, // ✅ send activities to backend
      };

      await _userHomeRepo.addAspirationalEmotions(data: data);

      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  /// Saves "today" activities with the payload shape:
  /// ```json
  /// { "activities": [{ "name": "...", "isCustom": false, "completed": false }] }
  /// ```
  Future<bool> addTodayActivities({
    required BuildContext context,
    required List<Map<String, dynamic>> activities,
  }) async {
    try {
      final data = {"activities": activities};

      final response = await _userHomeRepo.addTodayActivities(data: data);

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Unknown error',
            serviceName: tag,
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  Future<bool> reviewDate({
    required BuildContext context,
    required DateTime reviewDate,
  }) async {
    try {
      final data = {"reviewDate": reviewDate.toUtc().toIso8601String()};

      final response = await _userHomeRepo.reviewDate(data: data);

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Unknown error',
            serviceName: tag,
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Add Activities (planned/general)

  Future<bool> addActivities({
    required BuildContext context,
    required List<Map<String, dynamic>> activities,
  }) async {
    try {
      final data = {"activities": activities};

      final response = await _userHomeRepo.addTodayActivities(data: data);

      if (response['success'] == true) {
        // Optionally, you can parse the returned activities here
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Unknown error',
            serviceName: tag,
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Add addForecastPlanActivities

  Future<bool> addForecastPlanActivities({
    required BuildContext context,
    required List<Map<String, dynamic>> activities,
  }) async {
    try {
      for (final activity in activities) {
        final response = await _userHomeRepo.addForecastPlanActivities(
          data: activity,
        );

        if (response['success'] != true) {
          if (context.mounted) {
            ErrorHandler.handle(
              context,
              response['message'] ?? 'Unknown error',
              serviceName: tag,
            );
          }
          return false;
        }
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  Future<bool> saveForecastPlanActivities({
    required BuildContext context,
    required String forecastPlan,
    required List<Map<String, dynamic>> activities,
  }) async {
    try {
      final response = await _userHomeRepo.saveForecastPlanActivities(
        data: {"plan": forecastPlan, "activities": activities},
      );

      if (response['success'] == true) {
        return true;
      }

      if (context.mounted) {
        ErrorHandler.handle(
          context,
          response['message'] ?? 'Unknown error',
          serviceName: tag,
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  // Create Community
  Future<String?> createCommunity({
    required BuildContext context,
    required String name,
    required String description,
  }) async {
    try {
      final data = {"name": name, "description": description};

      final response = await _userHomeRepo.createCommunity(data: data);

      if (response['success'] == true) {
        // Extract communityId from response
        final data = response['data'];

        if (data is List && data.isNotEmpty) {
          final firstItem = data.first;
          if (firstItem is Map) {
            if (firstItem.containsKey('communityId')) {
              return firstItem['communityId']?.toString();
            }
            if (firstItem.containsKey('_id')) {
              return firstItem['_id']?.toString();
            }
          }
        } else if (data is Map) {
          if (data.containsKey('communityId')) {
            return data['communityId']?.toString();
          }
          if (data.containsKey('_id')) {
            return data['_id']?.toString();
          }
          if (data.containsKey('id')) {
            return data['id']?.toString();
          }
          if (data.containsKey('community') && data['community'] is Map) {
            final community = data['community'];
            return (community['_id'] ?? community['id'])?.toString();
          }
        }

        if (response.containsKey('communityId')) {
          return response['communityId']?.toString();
        }
        return null;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Unknown error',
            serviceName: tag,
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  // Set Reminder for forecast and End Day
  Future<String?> setReminderForecastEndDay({
    required BuildContext context,
    required String dailyPulseTime,
    required String eodTime,
  }) async {
    try {
      final data = {"dailyPulseTime": dailyPulseTime, "eodTime": eodTime};

      final response = await _userHomeRepo.reminderSet(data: data);

      if (response['success'] == true) {
        return response['message']?.toString();
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Unknown error',
            serviceName: tag,
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }

  //   //go to vendor search

  //   // Search Vendors Service
  //   Future<List<VendorModel>> searchVendors({
  //     required BuildContext context,
  //     required String query,
  //     required LatLng userLocation,
  //     double searchRadius = 5,
  //   }) async {
  //     try {
  //       final queryParams = {
  //         'query': query,
  //         'lat': userLocation.latitude,
  //         'lng': userLocation.longitude,
  //         'distance': searchRadius,
  //       };

  //       final queryString = api.buildQueryString(queryParams);

  //       // final response = await _userAuthRepo.searchVendors(query: query);
  //       final response = await _userAuthRepo.searchVendors(
  //         queryString: queryString,
  //       );

  //       if (response['success'] == true) {
  //         final vendors = response['vendors'] as List<dynamic>? ?? [];
  //         return vendors
  //             .map((e) => VendorModel.fromJson(e as Map<String, dynamic>))
  //             .toList();
  //       }

  //       return [];
  //     } catch (e) {
  //       // ignore: use_build_context_synchronously
  //       ErrorHandler.handle(context, e, serviceName: 'SearchVendorService');
  //       return [];
  //     }
  //   }

  // /
  // / Update Today Activity
  // /
  Future<bool> updateTodayActivity({
    required BuildContext context,
    required String id,
    required String name,
    required bool completed,
    required bool isCustom,
  }) async {
    try {
      final response = await _userHomeRepo.updateTodayActivity(
        data: {"name": name, "completed": completed},
      );

      if (response['success'] == true) {
        if (context.mounted) {
          await getActivities();
        }
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Update failed',
            serviceName: tag,
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  //invite Usernames (bulk)
  Future<BulkInviteData?> inviteUsernames({
    required BuildContext context,
    required List<String> usernames,
    required String communityId,
    String? message,
  }) {
    return _sendBulkInvite(
      context: context,
      data: {
        "usernames": usernames,
        "communityId": communityId,
        if (message != null && message.trim().isNotEmpty) "message": message,
      },
      request: _userHomeRepo.inviteUsername,
    );
  }

  //invite Emails (bulk)
  Future<BulkInviteData?> inviteEmails({
    required BuildContext context,
    required List<String> emails,
    required String communityId,
    String? message,
  }) {
    return _sendBulkInvite(
      context: context,
      data: {
        "emails": emails,
        "communityId": communityId,
        if (message != null && message.trim().isNotEmpty) "message": message,
      },
      request: _userHomeRepo.inviteEmail,
    );
  }

  /// Shared handler for the bulk invite endpoints. Shows a success flushbar
  /// when every invite went out, otherwise an error flushbar listing each
  /// failed recipient. Returns the per-recipient result, or null on error.
  Future<BulkInviteData?> _sendBulkInvite({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Future<Map<String, dynamic>> Function({
      required Map<String, dynamic> data,
    })
    request,
  }) async {
    try {
      final response = await request(data: data);
      final model = BulkInviteModel.fromJson(response);
      final result = model.data?.isNotEmpty == true ? model.data!.first : null;

      if (model.success != true || result == null) {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            model.message ?? 'Unknown error',
            serviceName: tag,
          );
        }
        return result;
      }

      final failed = result.failed ?? [];
      if (context.mounted) {
        if (failed.isEmpty) {
          context.flushBarSuccessMessage(
            message: model.message ?? "Invites sent successfully",
          );
        } else {
          final reasons = failed
              .map((f) => '• ${f.message ?? f.username ?? f.email ?? 'Failed'}')
              .join('\n');
          context.flushBarErrorMessage(
            message: '${model.message ?? 'Some invites failed'}\n$reasons',
          );
        }
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return null;
    }
  }
}
