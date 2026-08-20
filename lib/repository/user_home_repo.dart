import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';
import 'package:kena_emotional_journey/model/forecast/end_day_model.dart';

class UserHomeRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  //Get notifications (for both user and vendor)
  Future<Map<String, dynamic>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    return _apiServices.get(
      url: '${AppUrl.getNotifications}?limit=$limit&offset=$offset',
    );
  }

  Future<Map<String, dynamic>> markNotificationsRead() async {
    return _apiServices.put(url: AppUrl.markNotificationsRead, data: {});
  }

  Future<Map<String, dynamic>> getNearbyVendors({String query = ''}) async {
    return _apiServices.get(url: '${AppUrl.getNearbyVendors}?$query');
  }

  Future<Map<String, dynamic>> getVendorDetails({
    required String vendorId,
  }) async {
    return _apiServices.get(url: AppUrl.getVendorDetails(vendorId));
  }

  Future<Map<String, dynamic>> addPlannedActivity({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.post(url: AppUrl.addPlannedActivity, data: data);
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    return _apiServices.get(url: AppUrl.getUserDetails);
  }

  //fetch User Community
  Future<Map<String, dynamic>> getUserCommunity({
    required String communityId,
  }) async {
    return _apiServices.get(
      url: '${AppUrl.getUserCommunity}?communityId=$communityId',
    );
  }

  //fetch Yesterday Forecasts
  Future<Map<String, dynamic>> getYesterdayForecasts({
    required String date,
  }) async {
    final response = await _apiServices.get(
      url: '${AppUrl.getYesterdayForecasts}$date',
    );

    return response;
  }

  //fetch User Emotions
  Future<Map<String, dynamic>> getUserEmotions() async {
    return _apiServices.get(url: AppUrl.getUserEmotions);
  }

  // fetch Journal Selection data for a specific day (core emotions, aspirational emotions, activities, notes)
  Future<Map<String, dynamic>> getJournalSelection({String? day}) async {
    final query = day != null ? '?day=$day' : '';
    return _apiServices.get(url: '${AppUrl.getJournalSelection}$query');
  }

  //fetch User Community
  Future<Map<String, dynamic>> getCommunityFeed({
    required String communityId,
  }) async {
    return _apiServices.get(url: AppUrl.getCommunityFeed(communityId));
  }

  //get Feed Likes
  Future<Map<String, dynamic>> getFeedLikes({
    required String feedId,
    required String communityId,
  }) async {
    return _apiServices.get(url: AppUrl.getFeedLikes(feedId, communityId));
  }

  //get Invite Link
  Future<Map<String, dynamic>> getInviteLink() async {
    return _apiServices.get(url: AppUrl.inviteLink);
  }

  //share Forecast
  Future<Map<String, dynamic>> shareForecast({required String email}) async {
    return _apiServices.post(url: AppUrl.shareForecast, data: {'email': email});
  }

  //toggle Feed Like
  Future<Map<String, dynamic>> toggleFeedLike({
    required String feedId,
    required String communityId,
  }) async {
    return _apiServices.post(
      url: AppUrl.toggleFeedLike(feedId),
      data: {'communityId': communityId},
    );
  }

  //get Feed Comments
  Future<Map<String, dynamic>> getFeedComments({
    required String entryOwnerId,
    required String communityId,
  }) async {
    return _apiServices.get(
      url: AppUrl.getFeedComments(entryOwnerId, communityId),
    );
  }

  //post Feed Comment
  Future<Map<String, dynamic>> postFeedComment({
    required String entryOwnerId,
    required Map<String, dynamic> data,
  }) async {
    return _apiServices.post(
      url: AppUrl.postFeedComment(entryOwnerId),
      data: data,
    );
  }

  // Add Aspire Note
  Future<Map<String, dynamic>> addAspireNote({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.post(url: AppUrl.addAspireNotes, data: data);
  }

  // Add Forecast Note
  Future<Map<String, dynamic>> addForecastNote({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.post(url: AppUrl.addForecastNotes, data: data);
  }

  Future<Map<String, dynamic>> reviewDate({
    required Map<String, dynamic> data,
  }) {
    return _apiServices.post(url: AppUrl.reviewDate, data: data);
  }

  Future<Map<String, dynamic>> getForecastNotes({required String day}) async {
    return _apiServices.get(url: '${AppUrl.getForecastNotes}?day=$day');
  }

  //remove Community Member
  Future<Map<String, dynamic>> removeCommunityMember({
    required String memberId,
  }) async {
    return _apiServices.delete(url: AppUrl.removeCommunityMember(memberId));
  }

  //Delete Notification
  Future<Map<String, dynamic>> deleteNotification({
    required String notificationId,
  }) async {
    return _apiServices.delete(url: AppUrl.deleteNotification(notificationId));
  }

  //accept Invite
  Future<Map<String, dynamic>> acceptInvite({required String inviteId}) async {
    return _apiServices.post(url: AppUrl.acceptInvite(inviteId), data: {});
  }

  //decline Invite
  Future<Map<String, dynamic>> declineInvite({required String inviteId}) async {
    return _apiServices.post(url: AppUrl.declineInvite(inviteId), data: {});
  }

  //remove Activities Selections
  Future<Map<String, dynamic>> deletePlannedActivity({
    required String name,
    required bool isPlanned,
  }) async {
    return _apiServices.delete(
      url: AppUrl.removeActivities,
      data: {"name": name, "isPlanned": isPlanned},
    );
  }

  //delete Today Activity (DELETE /activities/forecast)
  Future<Map<String, dynamic>> deleteTodayActivity({
    required String name,
    required bool isPlanned,
  }) async {
    return _apiServices.delete(
      url: AppUrl.deleteTodayActivity,
      data: {"name": name, "isPlanned": isPlanned},
    );
  }

  //Get Community Member
  Future<Map<String, dynamic>> getCommunityMembers({
    required String communityId,
  }) async {
    return _apiServices.get(url: AppUrl.getCommunityMembers(communityId));
  }

  //Get Forecast Community Members
  Future<Map<String, dynamic>> getForecastCommunityMembers() async {
    return _apiServices.get(url: AppUrl.getForecastCommunityMembers);
  }

  //Get Community Invitations
  Future<Map<String, dynamic>> getInvitations() async {
    return _apiServices.get(url: AppUrl.getCommunityInvites);
  }

  //Get Daily Feed
  Future<Map<String, dynamic>> getDailyFeed({
    required String communityId,
    String scope = 'me',
    String? date,
  }) async {
    return _apiServices.get(
      url: AppUrl.getDailyFeed(communityId, scope: scope, date: date),
    );
  }

  //Get Weekly Feed
  Future<Map<String, dynamic>> getWeeklyFeed({
    required String communityId,
    String scope = 'me',
    String? date,
  }) async {
    return _apiServices.get(
      url: AppUrl.getWeeklyFeed(communityId, scope: scope, date: date),
    );
  }

  // Get Aspire Notes
  Future<Map<String, dynamic>> getAspireNotes({required String day}) async {
    return _apiServices.get(url: '${AppUrl.getAspireNotes}?day=$day');
  }

  // Invite Members
  Future<Map<String, dynamic>> sendInviteToMembers({
    required List<String> memberIds,
    required String day,
    required String message,
  }) async {
    return _apiServices.post(
      url: AppUrl.sendInviteToMembers,
      data: {"day": day, "memberIds": memberIds, "message": message},
    );
  }

  // Get members currently shared with (stop-sharing list)
  Future<Map<String, dynamic>> getStopSharingMembers() async {
    return _apiServices.get(url: AppUrl.getStopSharingMembers);
  }

  // Stop sharing forecast with specific or all members
  Future<Map<String, dynamic>> stopSharingForecast({
    required List<String> userIds,
  }) async {
    final Map<String, dynamic> data = {'userIds': userIds};
    return _apiServices.post(url: AppUrl.stopSharingForecast, data: data);
  }

  // Share weekly forecast with community members
  Future<Map<String, dynamic>> shareWeeklyForecast({
    required List<String> memberIds,
    String? endDate,
    String? message,
    String? communityId,
  }) async {
    final Map<String, dynamic> data = {
      'memberIds': memberIds,
      'endDate': ?endDate,
      'message': ?message,
      'communityId': ?communityId,
    };
    return _apiServices.post(url: AppUrl.shareWeeklyForecast, data: data);
  }

  // Stop sharing weekly forecast with specific members
  Future<Map<String, dynamic>> stopSharingWeeklyForecast({
    required List<String> userIds,
    String? endDate,
  }) async {
    final Map<String, dynamic> data = {'userIds': userIds, 'endDate': ?endDate};
    return _apiServices.post(url: AppUrl.stopSharingWeeklyForecast, data: data);
  }

  //update Community
  Future<Map<String, dynamic>> updateCommunity({
    required String communityId,
    required Map<String, dynamic> data,
  }) async {
    return _apiServices.put(
      url: AppUrl.updateCommunity(communityId),
      data: data,
    );
  }

  //update Today Activity
  Future<Map<String, dynamic>> updateTodayActivity({
    required Map<String, dynamic> data,
  }) async {
    return _apiServices.put(url: AppUrl.updateTodayActivities, data: data);
  }

  //Update Notes of the Day Forecast
  Future<EndDayModel> updateNotesOfTheDay({
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiServices.put(
      url: AppUrl.updateNotesOfTheDay,
      data: data,
    );
    return EndDayModel.fromJson(response);
  }

  //Update End Day
  Future<Map<String, dynamic>> updateEndDay({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.put(url: AppUrl.updateEndDay, data: data);
  }

  // Update Forecast
  Future<Map<String, dynamic>> updateForecast({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.put(
      url: AppUrl.updateForecast, // make sure this endpoint is correct
      data: data,
    );
  }

  // Delete Forecast Emotions
  Future<Map<String, dynamic>> deleteForecastEmotions() async {
    return await _apiServices.delete(
      url: AppUrl.deleteForecastEmotions,
      data: {},
    );
  }

  // Delete a single reflection emotion (DELETE /api/emotions/reflection?date=...&key=...)
  Future<Map<String, dynamic>> deleteReflectionEmotion({
    required String date,
    required String key,
  }) async {
    final query = Uri(queryParameters: {'date': date, 'key': key}).query;
    return await _apiServices.delete(
      url: '${AppUrl.deleteReflectionEmotion}?$query',
    );
  }

  // // Update Core Emotions
  // Future<Map<String, dynamic>> updateCoreEmotions({
  //   required Map<String, dynamic> data,
  // }) async {
  //   return await _apiServices.put(
  //     url: AppUrl.updateCoreEmotions, // make sure this endpoint is correct
  //     data: data,
  //   );
  // }

  // // Update Aspire Emotions
  // Future<Map<String, dynamic>> updateAspirationEmotions({
  //   required Map<String, dynamic> data,
  // }) async {
  //   return await _apiServices.put(
  //     url: AppUrl.updateAspirationEmotions,
  //     data: data,
  //   );
  // }

  // Update Forecast Images
  Future<dynamic> updateForecastImages({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.put(url: AppUrl.updateForecastImages, data: data);
  }

  // Update Core Images
  Future<dynamic> updateCoreImages({required Map<String, dynamic> data}) async {
    return await _apiServices.put(url: AppUrl.updateCoreImages, data: data);
  }

  // Delete Core Emotion
  Future<dynamic> deleteCoreEmotion({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.delete(
      url: AppUrl.deleteCoreEmotions,
      data: data,
    );
  }

  // Update Aspiration Images
  Future<dynamic> updateAspirationImages({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.put(
      url: AppUrl.updateAspirationImages,
      data: data,
    );
  }

  // Delete Aspiration Emotion
  Future<dynamic> deleteAspirationEmotion({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.delete(
      url: AppUrl.deleteAspirationalEmotions,
      data: data,
    );
  }

  Future<dynamic> updateEndDayImages({
    required Map<String, dynamic> data,
  }) async {
    return await _apiServices.put(url: AppUrl.updateEndDayImages, data: data);
  }

  //get reviews
  Future<Map<String, dynamic>> getVendorReviews({
    String query = '',
    required String vendorId,
  }) async {
    return _apiServices.get(
      url: '${AppUrl.getVendorReviewsById(vendorId)}?$query',
    );
  }

  // get User Review that he will get from vendors
  Future<Map<String, dynamic>> getUserReviews() async {
    return _apiServices.get(url: AppUrl.getUserReviews);
  }

  // Get Weekly Activites
  Future<Map<String, dynamic>> getWeeklyActivites() {
    return _apiServices.get(url: AppUrl.getWeeklyActivities);
  }

  // Get Overall Weekly
  Future<Map<String, dynamic>> getOverallWeekly() {
    return _apiServices.get(url: AppUrl.getOverallWeekly);
  }

  // Get Overall Monthly
  Future<Map<String, dynamic>> getOverallMonthly() {
    return _apiServices.get(url: AppUrl.getOverallMonthly);
  }

  // Get Overall All time
  Future<Map<String, dynamic>> getOverallAlltime() {
    return _apiServices.get(url: AppUrl.getOverallAlltime);
  }

  // Get All Time Activites
  Future<Map<String, dynamic>> getAlltimeActivites() {
    return _apiServices.get(url: AppUrl.getAlltimeActivities);
  }

  // Get Monthly Activites
  Future<Map<String, dynamic>> getMonthlyActivites() {
    return _apiServices.get(url: AppUrl.getMonthlyActivities);
  }

  //add Core Emotions
  Future<Map<String, dynamic>> addCoreEmotions({
    required List<Map<String, dynamic>> emotions,
  }) async {
    final data = {'emotions': emotions}; // build request body
    return _apiServices.post(url: AppUrl.addCoreEmotions, data: data);
  }

  //forecast as yesterday
  Future<Map<String, dynamic>> forecastAsYesterday() async {
    return _apiServices.get(url: AppUrl.forecastAsYesterday);
  }

  //add Aspirational Emotions
  Future<Map<String, dynamic>> addAspirationalEmotions({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.addAspirationalEmotions, data: data);
  }

  //add Forecast
  Future<Map<String, dynamic>> forecast({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.getForecast, data: data);
  }

  //App Usage Time
  Future<Map<String, dynamic>> appUsageTime({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.appUsageTime, data: data);
  }

  //Get Forecast
  Future<Map<String, dynamic>> getForecast() async {
    return _apiServices.get(url: AppUrl.getForecast);
  }

  //Get End Day
  Future<Map<String, dynamic>> getEndDay() async {
    return _apiServices.get(url: AppUrl.getEndDay);
  }

  //Get Comparison
  Future<Map<String, dynamic>> getComparison() async {
    return _apiServices.get(url: AppUrl.getComparison);
  }

  //Get Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    return _apiServices.get(url: AppUrl.getAnalytics);
  }

  //Get Analytics Calendar
  Future<Map<String, dynamic>> getAnalyticsCalendar({
    required String day,
  }) async {
    return _apiServices.get(url: '${AppUrl.getAnalyticsCalendar}?day=$day');
  }

  //Get Calendar Month Analytics
  Future<Map<String, dynamic>> getCalendarMonthAnalytics({
    required String month,
  }) async {
    return _apiServices.get(
      url: '${AppUrl.getCalendarMonthAnalytics}?month=$month',
    );
  }

  // //Get Activities
  Future<Map<String, dynamic>> getActivities() async {
    return _apiServices.get(url: AppUrl.getActivities);
  }

  //Get Today Activities
  Future<Map<String, dynamic>> getTodayActivities() async {
    return _apiServices.get(url: AppUrl.getTodayActivities);
  }

  //Get ForecastPlan Activities
  Future<Map<String, dynamic>> getForecastPlanActivities() async {
    return _apiServices.get(url: AppUrl.getForecastPlanActivities);
  }

  //Get Planned Activities
  Future<Map<String, dynamic>> getPlannedActivities() async {
    return _apiServices.get(url: AppUrl.getPlannedActivities);
  }

  // //Get Forecast Activities
  // Future<Map<String, dynamic>> getForecastActivities() async {
  //   return _apiServices.get(url: AppUrl.getForecastActivities);
  // }

  //Get Communities
  Future<Map<String, dynamic>> getCommunities() async {
    return _apiServices.get(url: AppUrl.getCommunities);
  }

  Future<Map<String, dynamic>> getCommunityDetails({
    required String communityId,
  }) async {
    return _apiServices.get(url: AppUrl.getCommunityDetails(communityId));
  }

  //add End of Day Reflection
  Future<Map<String, dynamic>> endOfDay({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.endOfDay, data: data);
  }

  //add  Activities
  Future<Map<String, dynamic>> addActivities({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.addActivities, data: data);
  }

  //add  addForecastPlanActivities
  Future<Map<String, dynamic>> addForecastPlanActivities({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.addForecastPlanActivities, data: data);
  }

  Future<Map<String, dynamic>> saveForecastPlanActivities({
    required Map<String, dynamic> data,
  }) async {
    return _apiServices.post(
      url: AppUrl.saveForecastPlanActivities,
      data: data,
    );
  }

  //add today  Activities
  Future<Map<String, dynamic>> addTodayActivities({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.addTodayActivities, data: data);
  }

  //Create Community
  Future<Map<String, dynamic>> createCommunity({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.createCommunity, data: data);
  }

  //update Activity
  Future<Map<String, dynamic>> updateActivity({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.put(url: AppUrl.updateActivity, data: data);
  }

  //invite Username
  Future<Map<String, dynamic>> inviteUsername({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.inviteUsername, data: data);
  }

  //invite Email
  Future<Map<String, dynamic>> inviteEmail({
    required Map<String, dynamic> data, // 👈 generic
  }) async {
    return _apiServices.post(url: AppUrl.inviteEmail, data: data);
  }
}
